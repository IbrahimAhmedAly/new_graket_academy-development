import 'dart:async';

import 'package:get/get.dart';

import '../../data/tracking_data/tracking_data.dart';
import '../class/data_request.dart';
import '../class/request_status.dart';
import '../debug/tracking_logger.dart';
import '../constants/app_strings.dart';
import 'services.dart';

/// Records which parts of a video a student actually played.
///
/// The player reports a position several times a second. Rather than posting
/// each tick, this accumulates contiguous playback into segments locally and
/// flushes them on a timer, when the video changes, and on dispose.
///
/// Only real playback becomes a segment: a jump in position while paused, or a
/// scrub through the timeline, breaks the current segment instead of extending
/// it. That is what keeps "watched 80%" from meaning "dragged the scrubber
/// once".
class VideoWatchTracker {
  VideoWatchTracker({TrackingData? trackingData})
    : _trackingData = trackingData ?? TrackingData(Get.find<DataRequest>());

  final TrackingData _trackingData;

  /// How often accumulated segments are sent. Long enough to batch a burst of
  /// ticks, short enough that closing the app loses little.
  static const Duration _flushInterval = Duration(seconds: 20);

  /// A position jump larger than this means a seek, not playback. Generous
  /// enough to absorb a dropped frame or a slow tick without splitting a
  /// genuine continuous watch into fragments.
  static const double _seekThresholdSec = 2.5;

  /// The server rejects a report carrying more than this many segments. A
  /// long offline stretch can accumulate that many, and sending them all would
  /// have the whole batch refused and re-queued forever — losing every segment
  /// behind it rather than the overflow.
  static const int _maxSegmentsPerReport = 200;

  /// Playing this close to the beginning of a finished video is a restart.
  /// Wide enough that a tick or two of playback before the tracker sees it
  /// still reads as "from the top".
  static const double _restartWindowSec = 2;

  String? _contentId;
  int? _durationSec;

  /// Segments captured since the last successful flush.
  final List<Map<String, int>> _pending = [];

  double? _segmentStart;
  double? _lastPosition;
  double _latestPosition = 0;

  /// Playhead carried by the last report the server accepted, so a flush with
  /// no new segments can tell a moved playhead from an idle one.
  int? _reportedPosition;

  /// Whether the student has played anything in this sitting. Until they have,
  /// the playhead is the player's idle 0 and must not be reported as where
  /// they stopped.
  bool _hasPlayed = false;

  bool _reachedEnd = false;
  bool _pendingReplay = false;

  Timer? _flushTimer;

  /// Points at a new video, flushing whatever the previous one accumulated.
  Future<void> attach({required String contentId, int? durationSec}) async {
    if (_contentId == contentId) {
      // Same video; just refresh duration if the player now knows it.
      if (durationSec != null && durationSec > 0) _durationSec = durationSec;
      return;
    }

    await flush();
    _resetForNewVideo();

    _contentId = contentId;
    _durationSec = (durationSec != null && durationSec > 0)
        ? durationSec
        : null;

    TrackLog.videoAttached(contentId, _durationSec);

    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_flushInterval, (_) => flush());

    // Register the video immediately, before any playback.
    //
    // Without this, a video the student opens but never plays has no progress
    // row at all, so reporting cannot tell "opened and watched nothing" apart
    // from "never opened" — and an average across videos silently skips it.
    // An empty segment list merges to a no-op server-side, so this establishes
    // the row at 0% without inventing watch time.
    //
    // Only once the stored state is known, though: the registration posts a
    // playhead, and posting an unverified one would rewind the student's stop
    // position rather than establish a row.
    if (await _loadStoredState(contentId)) {
      await _register();
    }
  }

  /// Seeds this sitting from what the server already knows about the video.
  ///
  /// Three separate numbers depend on it. The resume point must be known
  /// before the registration below writes one, because the server stores
  /// whatever position arrives — registering a blind 0 rewound the stored stop
  /// position on every open. The player-measured length must win over the
  /// admin-entered minutes, because watch percentage is computed against
  /// whichever arrives last. And a video finished in an earlier visit has to
  /// count a restart as a replay even though this sitting never saw it end.
  ///
  /// Returns whether the stored state was actually read.
  Future<bool> _loadStoredState(String contentId) async {
    final token = _token;
    if (token.isEmpty) return false;

    try {
      final response = await _trackingData.getVideoWatchProgress(
        token: token,
        contentId: contentId,
      );

      // The student may have moved on while this was in flight.
      if (!_isSuccess(response) || _contentId != contentId) return false;

      final stored = _payload(response);
      if (stored == null) return false;

      final position = (stored['lastPositionSec'] as num?)?.round() ?? 0;
      if (position > 0) {
        _latestPosition = position.toDouble();
        _reportedPosition = position;
      }

      final storedDuration = (stored['durationSec'] as num?)?.round();
      if (storedDuration != null && storedDuration > 0) {
        _durationSec = storedDuration;
      }

      _reachedEnd = stored['isCompleted'] == true;
      return true;
    } catch (e) {
      TrackLog.videoFailed('resume state: $e');
      return false;
    }
  }

  /// Creates the progress row for the attached video with no watch time.
  ///
  /// Failure is not retried: the next flush carries the same information, and
  /// a missing row is only a reporting gap, never lost watch time.
  Future<void> _register() async {
    final contentId = _contentId;
    if (contentId == null) return;

    final token = _token;
    if (token.isEmpty) return;

    // Echoes the stored playhead back unchanged unless the student has already
    // started playing. The server takes this field as the resume point
    // verbatim, and the player reports an idle 0 until the first play, so
    // anything else here erases where the student stopped the moment they
    // reopen the lesson.
    final position = _hasPlayed
        ? _latestPosition.round()
        : (_reportedPosition ?? 0);

    try {
      await _trackingData.trackVideoProgress(
        token: token,
        contentId: contentId,
        segments: const [],
        positionSec: position,
        durationSec: _durationSec,
        isReplay: false,
        tzOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
      );
      _reportedPosition = position;
      TrackLog.videoRegistered(contentId, _durationSec);
    } catch (e) {
      TrackLog.videoFailed('register: $e');
    }
  }

  /// Feeds a player tick.
  ///
  /// [positionSec] is the playhead; [isPlaying] distinguishes real playback
  /// from a paused scrub, and [durationSec] carries the media length once the
  /// player has resolved it.
  void onTick({
    required double positionSec,
    required bool isPlaying,
    int? durationSec,
  }) {
    if (_contentId == null) return;

    if (durationSec != null && durationSec > 0) _durationSec = durationSec;
    _latestPosition = positionSec;

    _noteRestart(positionSec, isPlaying);
    if (isPlaying) _hasPlayed = true;

    if (!isPlaying) {
      // Paused: bank whatever was playing and wait for playback to resume.
      _closeSegment();
      _lastPosition = positionSec;
      return;
    }

    final last = _lastPosition;

    if (last == null) {
      _segmentStart = positionSec;
      _lastPosition = positionSec;
      return;
    }

    final delta = positionSec - last;

    // A backwards jump, or a forward jump too large to be playback, is a seek.
    // Close the segment at the old position and start fresh at the new one, so
    // the skipped span is never counted as watched.
    if (delta < 0 || delta > _seekThresholdSec) {
      _closeSegment();
      _segmentStart = positionSec;
      _lastPosition = positionSec;
      return;
    }

    _segmentStart ??= last;
    _lastPosition = positionSec;
  }

  /// Flags a replay when a video that has already been finished is playing
  /// from the top again.
  ///
  /// Checked on every playing tick rather than only on a backwards jump. The
  /// player reports a rewind to 0 *before* it reports that playback resumed,
  /// so by the time the tick says "playing" the jump has already been consumed
  /// and looks like ordinary playback — which is why "Watch Again" never
  /// registered as a replay. A video finished in an earlier visit produces no
  /// jump at all: it simply opens at the beginning.
  void _noteRestart(double positionSec, bool isPlaying) {
    if (!_reachedEnd || !isPlaying) return;
    if (positionSec > _restartWindowSec) return;

    markReplay();
  }

  /// Records an explicit restart, such as the player's "Watch Again" action.
  ///
  /// Worth its own entry point: a student can mark a lesson complete without
  /// ever playing the video to the end, and only the button knows that the
  /// next play is a deliberate re-watch.
  void markReplay() {
    if (_contentId == null) return;
    _pendingReplay = true;
    _reachedEnd = false;
  }

  /// Marks that playback reached the end, so a later restart counts as a replay.
  void onEnded() {
    _closeSegment();
    _reachedEnd = true;
  }

  /// Sends accumulated segments. Safe to call when there is nothing to send.
  Future<void> flush() async {
    final contentId = _contentId;
    if (contentId == null) return;

    _closeSegment();

    final position = _latestPosition.round();

    // A moved playhead is worth a report on its own: scrubbing to a new spot
    // and leaving produces no segments, and without this the dashboard would
    // still show the student stopped wherever they last played. Gated on
    // having played, because a player sitting idle at 0 reports a playhead
    // too, and that one would erase the stop position instead of updating it.
    final positionMoved = _hasPlayed && _reportedPosition != position;

    if (_pending.isEmpty && !_pendingReplay && !positionMoved) {
      TrackLog.videoNothingToSend();
      return;
    }

    final token = _token;
    if (token.isEmpty) return;

    // Hand the batch off before awaiting, so ticks arriving mid-flight
    // accumulate into the next batch rather than being dropped on success.
    final size = _pending.length < _maxSegmentsPerReport
        ? _pending.length
        : _maxSegmentsPerReport;
    final batch = List<Map<String, int>>.from(_pending.take(size));
    final wasReplay = _pendingReplay;
    _pending.removeRange(0, size);
    _pendingReplay = false;

    TrackLog.videoFlush(
      contentId: contentId,
      segments: batch,
      positionSec: position,
      durationSec: _durationSec,
      isReplay: wasReplay,
    );

    try {
      final response = await _trackingData.trackVideoProgress(
        token: token,
        contentId: contentId,
        segments: batch,
        positionSec: position,
        durationSec: _durationSec,
        isReplay: wasReplay,
        tzOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
      );

      if (_isSuccess(response)) {
        _reportedPosition = position;
        _logAck(response);
      } else {
        TrackLog.videoFailed('server rejected the batch');
        _requeue(batch, wasReplay);
      }
    } catch (e) {
      // Keep the batch for the next attempt: the server merges segments, so a
      // resend cannot inflate watch time.
      TrackLog.videoFailed(e);
      _requeue(batch, wasReplay);
    }
  }

  /// Flushes and detaches. Call from the player's dispose.
  Future<void> dispose() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    await flush();
    _resetForNewVideo();
    _contentId = null;
  }

  // ── internals ────────────────────────────────────────────────────────

  /// Banks the open segment, if it covers a meaningful span.
  void _closeSegment() {
    final start = _segmentStart;
    final end = _lastPosition;
    _segmentStart = null;

    if (start == null || end == null) return;

    final s = start.floor();
    final e = end.ceil();

    // Sub-second slivers carry no information and would bloat the payload.
    if (e - s < 1) return;

    _pending.add({'start': s < 0 ? 0 : s, 'end': e});
  }

  void _requeue(List<Map<String, int>> batch, bool wasReplay) {
    _pending.insertAll(0, batch);
    _pendingReplay = _pendingReplay || wasReplay;
  }

  void _resetForNewVideo() {
    _pending.clear();
    _segmentStart = null;
    _lastPosition = null;
    _latestPosition = 0;
    _reportedPosition = null;
    _durationSec = null;
    _hasPlayed = false;
    _reachedEnd = false;
    _pendingReplay = false;
  }

  String get _token =>
      Get.find<MyServices>().sharedPreferences.getString(
        AppSharedPrefKeys.userTokenKey,
      ) ??
      '';

  /// The service payload out of `{ data: { data: … } }`.
  Map? _payload(dynamic response) {
    try {
      final body = response.$2;
      if (body is! Map) return null;
      final data = body['data'];
      if (data is! Map) return null;
      final inner = data['data'];
      return inner is Map ? inner : null;
    } catch (_) {
      return null;
    }
  }

  /// Logs the server's merged totals, which is where the union rule becomes
  /// visible: the running total can be lower than the sum of what was sent.
  void _logAck(dynamic response) {
    final inner = _payload(response);
    if (inner == null) return;

    TrackLog.videoAck(
      watchedSeconds: (inner['watchedSeconds'] as num?)?.round() ?? 0,
      watchPercent: (inner['watchPercent'] as num?)?.round() ?? 0,
      isCompleted: inner['isCompleted'] == true,
      replayCount: (inner['replayCount'] as num?)?.round() ?? 0,
    );
  }

  bool _isSuccess(dynamic response) {
    if (response == null) return false;
    try {
      return response.$1 == RequestStatus.success;
    } catch (_) {
      return false;
    }
  }
}
