import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Console logging for the activity-tracking and reporting features.
///
/// Tracking runs silently in the background — segments accumulate, heartbeats
/// fire, rollups happen server-side — so when a number on the dashboard looks
/// wrong there is normally nothing on screen to explain why. These logs make
/// that pipeline visible.
///
/// ## Filtering the terminal
///
/// Every line is prefixed `[TRACK][<TAG>]`, so the console can be narrowed by
/// typing a plain word:
///
/// ```
///   REPORT    dashboard and report fetches
///   VIDEO     watch segments and watch percentage
///   PDF       document opens and read depth
///   SESSION   study sessions and heartbeats
///   TRACK     all of the above at once
/// ```
///
/// In a terminal: `flutter run | grep REPORT`
/// In an IDE console: type `REPORT` in the filter box.
///
/// The emoji are decoration — they make a busy console scannable, but the
/// bracketed tags are what you actually search for, because emoji are awkward
/// to type into a filter.
///
/// Every call is behind [kDebugMode], so nothing reaches a release build.
class TrackLog {
  TrackLog._();

  /// Master switch. Set to false to silence tracking logs while keeping other
  /// debug output — useful when the player's per-tick noise gets in the way.
  static bool enabled = true;

  static bool get _on => kDebugMode && enabled;

  // ── searchable tags ─────────────────────────────────────────────────────
  static const tagReport = 'REPORT';
  static const tagVideo = 'VIDEO';
  static const tagPdf = 'PDF';
  static const tagSession = 'SESSION';

  /// On every line, so one search shows the whole pipeline.
  static const tagAll = 'TRACK';

  // ── emoji vocabulary ────────────────────────────────────────────────────
  static const _video = '🎬';
  static const _pdf = '📄';
  static const _session = '⏱️';
  static const _beat = '💓';
  static const _report = '📊';
  static const _success = '✅';
  static const _failure = '❌';
  static const _send = '📤';
  static const _receive = '📥';
  static const _skip = '⏭️';
  static const _warn = '⚠️';
  static const _phone = '📱';

  /// Writes one tagged line.
  ///
  /// Uses `debugPrint` rather than `print` because it rate-limits: a burst of
  /// player ticks would otherwise overflow the platform log buffer and get
  /// silently truncated.
  static void _out(String tag, String message) {
    if (!_on) return;
    debugPrint('[$tagAll][$tag] $message');
  }

  // ── video watch tracking ────────────────────────────────────────────────

  /// A new video became the active lesson.
  static void videoAttached(String contentId, int? durationSec) {
    _out(
      tagVideo,
      '$_video ATTACH   content=${_short(contentId)}  '
      'duration=${durationSec != null ? _time(durationSec) : 'unknown'}',
    );
  }

  /// The video was registered server-side at 0%, before any playback.
  static void videoRegistered(String contentId, int? durationSec) {
    _out(
      tagVideo,
      '$_video REGISTER content=${_short(contentId)}  '
      'duration=${durationSec != null ? _time(durationSec) : 'unknown'}  '
      '(row created at 0%)',
    );
  }

  /// A batch of watched segments is being sent.
  static void videoFlush({
    required String contentId,
    required List<Map<String, int>> segments,
    required int positionSec,
    int? durationSec,
    bool isReplay = false,
  }) {
    if (!_on) return;

    final covered = segments.fold<int>(
      0,
      (sum, s) => sum + (s['end']! - s['start']!),
    );
    final pretty = segments
        .map((s) => '${_time(s['start']!)}→${_time(s['end']!)}')
        .join(', ');

    _out(tagVideo, '$_video $_send SENDING WATCH PROGRESS');
    _out(tagVideo, '   content   ${_short(contentId)}');
    _out(tagVideo, '   segments  ${segments.length} → [$pretty]');
    _out(tagVideo, '   covered   ${covered}s in this batch');
    _out(tagVideo, '   position  ${_time(positionSec)}');
    if (durationSec != null && durationSec > 0) {
      _out(tagVideo, '   duration  ${_time(durationSec)}');
    }
    if (isReplay) _out(tagVideo, '   replay    yes');
  }

  /// The server's response to a watch report.
  ///
  /// The server merges segments into a union, so its running total can be
  /// lower than the sum of everything sent — that is the anti-inflation rule
  /// working, not a bug. Printing both numbers makes that visible instead of
  /// looking like lost data.
  static void videoAck({
    required int watchedSeconds,
    required int watchPercent,
    required bool isCompleted,
    int replayCount = 0,
  }) {
    _out(
      tagVideo,
      '$_receive $_success SERVER   total=${watchedSeconds}s  '
      '$watchPercent%  ${isCompleted ? 'COMPLETE' : 'in progress'}'
      '${replayCount > 0 ? '  replays=$replayCount' : ''}',
    );
  }

  static void videoNothingToSend() {
    _out(tagVideo, '$_video $_skip flush skipped — no new segments');
  }

  static void videoFailed(Object? detail) {
    _out(
      tagVideo,
      '$_video $_failure send failed — segments kept for retry  ${detail ?? ''}',
    );
  }

  // ── content views ───────────────────────────────────────────────────────

  static void viewStarted(String type, String contentId, int? totalPages) {
    final isPdf = type == 'PDF';
    _out(
      isPdf ? tagPdf : tagVideo,
      '${isPdf ? _pdf : _video} OPEN     $type  content=${_short(contentId)}'
      '${totalPages != null ? '  pages=$totalPages' : ''}',
    );
  }

  static void viewEnded({
    required String viewId,
    required int durationSec,
    int? pagesRead,
    int? totalPages,
  }) {
    final depth = (pagesRead != null && totalPages != null && totalPages > 0)
        ? '  read=$pagesRead/$totalPages '
              '(${(pagesRead / totalPages * 100).round()}%)'
        : pagesRead != null
        ? '  read=$pagesRead pages'
        : '';
    _out(
      tagPdf,
      '$_pdf CLOSE    view=${_short(viewId)}  time=${durationSec}s$depth',
    );
  }

  // ── study sessions ──────────────────────────────────────────────────────

  static void sessionStarted(String sessionId, {required bool resumed}) {
    _out(
      tagSession,
      '$_session ${resumed ? 'RESUMED ' : 'STARTED '} id=${_short(sessionId)}',
    );
  }

  static void heartbeat(String sessionId, {required bool active}) {
    _out(
      tagSession,
      '$_beat beat     id=${_short(sessionId)}  '
      '${active ? 'alive' : '$_warn server says inactive — reopening'}',
    );
  }

  static void sessionEnded(String sessionId) {
    _out(tagSession, '$_session ENDED    id=${_short(sessionId)}');
  }

  static void sessionSkipped(String reason) {
    _out(tagSession, '$_session $_skip not started — $reason');
  }

  static void lifecycle(String state) {
    _out(tagSession, '$_phone LIFECYCLE  $state');
  }

  // ── reports ─────────────────────────────────────────────────────────────

  static void reportRequest(String name) {
    _out(tagReport, '$_report $_send GET   $name');
  }

  static void reportSuccess(String name, {String? summary}) {
    _out(
      tagReport,
      '$_report $_success $name${summary != null ? '  →  $summary' : ''}',
    );
  }

  static void reportFailure(String name, [Object? detail]) {
    _out(tagReport, '$_report $_failure $name failed  ${detail ?? ''}');
  }

  /// Prints the loaded dashboard as a readable summary.
  ///
  /// Renders null as an em dash rather than 0. "No data recorded" and "a
  /// measured zero" are different claims, and when a figure on screen looks
  /// wrong, which of the two it is happens to be the first thing worth
  /// knowing.
  static void dashboardSummary({
    required int progressPercent,
    required int videosWatched,
    required int totalVideos,
    required int quizzesTaken,
    required int? averageQuizScore,
    required double studyHours,
    required int streak,
    required int points,
    required int? successIndex,
    required String? successBand,
    required int subjects,
    required int weeklyDays,
    required int heatmapCells,
  }) {
    if (!_on) return;

    _out(tagReport, '$_report $_success DASHBOARD LOADED');
    _out(tagReport, '   progress      $progressPercent%');
    _out(tagReport, '   videos        $videosWatched / $totalVideos');
    _out(
      tagReport,
      '   quizzes       $quizzesTaken   avg=${_orDash(averageQuizScore, '%')}',
    );
    _out(tagReport, '   study time    ${studyHours}h');
    _out(tagReport, '   streak        $streak days');
    _out(tagReport, '   points        $points');
    _out(
      tagReport,
      '   successIndex  ${_orDash(successIndex)}  '
      '${successBand ?? '(not enough data yet)'}',
    );
    _out(tagReport, '   subjects      $subjects');
    _out(tagReport, '   weekly        $weeklyDays days');
    _out(tagReport, '   heatmap       $heatmapCells cells');
  }

  /// Full JSON body, for when a summary is not enough.
  static void json(String label, Object? body) {
    if (!_on) return;
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final pretty = encoder.convert(body);
      _out(tagReport, '$_report $label:');
      // Chunked so a long payload cannot be truncated by the log buffer.
      for (final match in RegExp('.{1,800}', dotAll: true).allMatches(pretty)) {
        _out(tagReport, match.group(0)!);
      }
    } catch (e) {
      _out(tagReport, '$_report $_failure could not encode $label: $e');
    }
  }

  // ── helpers ─────────────────────────────────────────────────────────────

  /// First 8 characters of a uuid — enough to correlate, short enough to scan.
  static String _short(String id) =>
      id.length <= 8 ? id : '${id.substring(0, 8)}…';

  /// Seconds as m:ss.
  static String _time(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// A value, or an em dash when the server reported null.
  static String _orDash(int? value, [String suffix = '']) =>
      value == null ? '—' : '$value$suffix';
}
