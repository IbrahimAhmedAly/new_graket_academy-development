import 'dart:async';

import 'package:get/get.dart';

import '../../data/tracking_data/tracking_data.dart';
import '../class/data_request.dart';
import '../class/request_status.dart';
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

  String? _contentId;
  int? _durationSec;

  /// Segments captured since the last successful flush.
  final List<Map<String, int>> _pending = [];

  double? _segmentStart;
  double? _lastPosition;
  double _latestPosition = 0;

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

    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_flushInterval, (_) => flush());
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

      // Seeking back to the start after finishing is a replay.
      if (_reachedEnd && positionSec < 1) {
        _pendingReplay = true;
        _reachedEnd = false;
      }
      return;
    }

    _segmentStart ??= last;
    _lastPosition = positionSec;
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

    if (_pending.isEmpty && !_pendingReplay) return;

    final token = _token;
    if (token.isEmpty) return;

    // Hand the batch off before awaiting, so ticks arriving mid-flight
    // accumulate into the next batch rather than being dropped on success.
    final batch = List<Map<String, int>>.from(_pending);
    final wasReplay = _pendingReplay;
    _pending.clear();
    _pendingReplay = false;

    try {
      final response = await _trackingData.trackVideoProgress(
        token: token,
        contentId: contentId,
        segments: batch,
        positionSec: _latestPosition.round(),
        durationSec: _durationSec,
        isReplay: wasReplay,
        tzOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
      );

      if (!_isSuccess(response)) {
        _requeue(batch, wasReplay);
      }
    } catch (_) {
      // Keep the batch for the next attempt: the server merges segments, so a
      // resend cannot inflate watch time.
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
    _durationSec = null;
    _reachedEnd = false;
    _pendingReplay = false;
  }

  String get _token =>
      Get.find<MyServices>().sharedPreferences.getString(
        AppSharedPrefKeys.userTokenKey,
      ) ??
      '';

  bool _isSuccess(dynamic response) {
    if (response == null) return false;
    try {
      return response.$1 == RequestStatus.success;
    } catch (_) {
      return false;
    }
  }
}
