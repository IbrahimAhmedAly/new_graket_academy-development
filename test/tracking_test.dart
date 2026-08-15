import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:new_graket_acadimy/core/class/data_request.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/services/content_view_tracker.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/core/services/video_watch_tracker.dart';
import 'package:new_graket_acadimy/data/tracking_data/tracking_data.dart';

/// Pins the parts of activity tracking that fail silently.
///
/// Every one of these produced a valid-looking request with the wrong number in
/// it, which is the failure mode that matters here: nothing errors, nothing is
/// retried, and the dashboard simply reports something untrue.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppSharedPrefKeys.userTokenKey: 'test-token',
    });
    await Get.putAsync(() => MyServices().init());
  });

  tearDown(Get.reset);

  group('video watch tracker', () {
    test('opening a video does not rewind the stored stop position', () async {
      final api = _FakeTrackingData()
        ..stored = _progress(lastPositionSec: 742, durationSec: 9680);
      final tracker = VideoWatchTracker(trackingData: api);

      // 2700 is the admin-entered 45 minutes; the player measured 9680.
      await tracker.attach(contentId: 'c1', durationSec: 2700);

      expect(api.videoCalls, hasLength(1));
      expect(api.videoCalls.single.positionSec, 742);
      expect(api.videoCalls.single.durationSec, 9680);
    });

    test(
      'a finished video restarted in a later visit counts as a replay',
      () async {
        final api = _FakeTrackingData()..stored = _progress(isCompleted: true);
        final tracker = VideoWatchTracker(trackingData: api);

        await tracker.attach(contentId: 'c1', durationSec: 600);
        // The player opens at the beginning; the student presses play.
        tracker.onTick(positionSec: 0, isPlaying: false);
        tracker.onTick(positionSec: 0.3, isPlaying: true);
        tracker.onTick(positionSec: 4, isPlaying: true);
        await tracker.flush();

        expect(api.videoCalls.last.isReplay, isTrue);
      },
    );

    test(
      '"Watch Again" is reported even though the rewind arrives paused',
      () async {
        final api = _FakeTrackingData();
        final tracker = VideoWatchTracker(trackingData: api);

        await tracker.attach(contentId: 'c1', durationSec: 600);
        tracker.onTick(positionSec: 598, isPlaying: true);
        tracker.onTick(positionSec: 600, isPlaying: true);
        tracker.onEnded();
        // seekTo(0) reports the new playhead before playback resumes.
        tracker.onTick(positionSec: 0, isPlaying: false);
        tracker.onTick(positionSec: 0.4, isPlaying: true);
        await tracker.flush();

        expect(api.videoCalls.last.isReplay, isTrue);
      },
    );

    test(
      'scrubbing away and leaving still reports where they stopped',
      () async {
        final api = _FakeTrackingData();
        final tracker = VideoWatchTracker(trackingData: api);

        await tracker.attach(contentId: 'c1', durationSec: 600);
        tracker.onTick(positionSec: 0, isPlaying: true);
        tracker.onTick(positionSec: 30, isPlaying: false);
        await tracker.flush();

        // Paused scrub to a new spot: no playback, so no new segments.
        tracker.onTick(positionSec: 480, isPlaying: false);
        await tracker.dispose();

        expect(api.videoCalls.last.segments, isEmpty);
        expect(api.videoCalls.last.positionSec, 480);
      },
    );

    test('an idle player never reports a playhead of its own', () async {
      final api = _FakeTrackingData()
        ..stored = _progress(lastPositionSec: 742, durationSec: 9680);
      final tracker = VideoWatchTracker(trackingData: api);

      await tracker.attach(contentId: 'c1', durationSec: 2700);
      // Opened, never played: the player still ticks at 0.
      tracker.onTick(positionSec: 0, isPlaying: false);
      await tracker.dispose();

      expect(api.videoCalls, hasLength(1)); // the registration only
    });

    test('a scrub is not counted as watched', () async {
      final api = _FakeTrackingData();
      final tracker = VideoWatchTracker(trackingData: api);

      await tracker.attach(contentId: 'c1', durationSec: 600);
      tracker.onTick(positionSec: 0, isPlaying: true);
      tracker.onTick(positionSec: 10, isPlaying: true);
      tracker.onTick(positionSec: 400, isPlaying: true); // dragged forward
      tracker.onTick(positionSec: 404, isPlaying: true);
      await tracker.flush();

      final covered = api.videoCalls.last.segments.fold<int>(
        0,
        (sum, s) => sum + (s['end']! - s['start']!),
      );
      expect(covered, lessThan(20));
    });

    test('seeking backward starts a new watched segment', () async {
      final api = _FakeTrackingData();
      final tracker = VideoWatchTracker(trackingData: api);

      await tracker.attach(contentId: 'c1', durationSec: 600);
      tracker.onTick(positionSec: 100, isPlaying: true);
      tracker.onTick(positionSec: 102, isPlaying: true);
      tracker.onTick(positionSec: 104, isPlaying: true);
      tracker.onTick(positionSec: 106, isPlaying: true);
      tracker.onTick(positionSec: 108, isPlaying: true);
      tracker.onTick(positionSec: 110, isPlaying: true);
      tracker.onTick(positionSec: 50, isPlaying: true); // rewound
      tracker.onTick(positionSec: 52, isPlaying: true);
      tracker.onTick(positionSec: 54, isPlaying: true);
      tracker.onTick(positionSec: 55, isPlaying: true);
      await tracker.flush();

      expect(api.videoCalls.last.segments, [
        {'start': 100, 'end': 110},
        {'start': 50, 'end': 55},
      ]);
    });
  });

  group('content view tracker', () {
    test('switching lessons pairs each open with exactly one close', () async {
      final api = _FakeTrackingData();
      final tracker = ContentViewTracker(trackingData: api);

      // Deliberately not awaited: a fast tap switches lessons while the first
      // open is still in flight.
      tracker.start(contentId: 'a', type: 'PDF');
      tracker.onPageChanged(6); // 0-based, so page 7
      final second = tracker.start(contentId: 'b', type: 'PDF');
      await second;
      await tracker.end();

      expect(api.startedViews, ['a', 'b']);
      expect(api.endedViews, hasLength(2));
      expect(api.endedViews.first.pagesRead, 7);
      expect(api.endedViews.last.pagesRead, isNull);
    });

    test('closing twice does not close twice', () async {
      final api = _FakeTrackingData();
      final tracker = ContentViewTracker(trackingData: api);

      await tracker.start(contentId: 'a', type: 'PDF');
      await tracker.end();
      await tracker.end();

      expect(api.endedViews, hasLength(1));
    });

    test('read depth is the furthest page, not the last one', () async {
      final api = _FakeTrackingData();
      final tracker = ContentViewTracker(trackingData: api);

      await tracker.start(contentId: 'a', type: 'PDF');
      tracker.setTotalPages(20);
      tracker.onPageChanged(11); // page 12
      tracker.onPageChanged(2); // paged back to re-read
      await tracker.end();

      expect(api.endedViews.single.pagesRead, 12);
      expect(api.endedViews.single.totalPages, 20);
    });
  });
}

Map<String, dynamic> _progress({
  int lastPositionSec = 0,
  int? durationSec,
  bool isCompleted = false,
}) => {
  'watchedSeconds': 0,
  'watchPercent': 0,
  'lastPositionSec': lastPositionSec,
  'durationSec': durationSec,
  'replayCount': 0,
  'isCompleted': isCompleted,
};

class _VideoCall {
  _VideoCall(this.segments, this.positionSec, this.durationSec, this.isReplay);

  final List<Map<String, int>> segments;
  final int positionSec;
  final int? durationSec;
  final bool isReplay;
}

class _EndCall {
  _EndCall(this.viewId, this.durationSec, this.pagesRead, this.totalPages);

  final String viewId;
  final int durationSec;
  final int? pagesRead;
  final int? totalPages;
}

/// Records what the trackers put on the wire instead of sending it.
class _FakeTrackingData extends TrackingData {
  _FakeTrackingData() : super(DataRequest());

  final List<_VideoCall> videoCalls = [];
  final List<String> startedViews = [];
  final List<_EndCall> endedViews = [];

  Map<String, dynamic> stored = _progress();

  int _nextViewId = 0;

  @override
  Future<dynamic> trackVideoProgress({
    required String token,
    required String contentId,
    required List<Map<String, int>> segments,
    required int positionSec,
    int? durationSec,
    bool isReplay = false,
    int? tzOffsetMinutes,
  }) async {
    videoCalls.add(_VideoCall(segments, positionSec, durationSec, isReplay));
    return (RequestStatus.success, _envelope(stored));
  }

  @override
  Future<dynamic> getVideoWatchProgress({
    required String token,
    required String contentId,
  }) async => (RequestStatus.success, _envelope(stored));

  @override
  Future<dynamic> startContentView({
    required String token,
    required String contentId,
    required String type,
    int? totalPages,
    int? tzOffsetMinutes,
  }) async {
    startedViews.add(contentId);
    return (
      RequestStatus.success,
      _envelope({'viewId': 'view-${_nextViewId++}'}),
    );
  }

  @override
  Future<dynamic> endContentView({
    required String token,
    required String viewId,
    required int durationSec,
    int? pagesRead,
    int? totalPages,
  }) async {
    endedViews.add(_EndCall(viewId, durationSec, pagesRead, totalPages));
    return (RequestStatus.success, _envelope(const {}));
  }

  /// The `{data: {data: …}}` shape the interceptor produces.
  Map<String, dynamic> _envelope(Map<String, dynamic> payload) => {
    'data': {'message': 'ok', 'data': payload},
  };
}
