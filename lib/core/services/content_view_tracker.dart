import 'package:get/get.dart';

import '../../data/tracking_data/tracking_data.dart';
import '../class/data_request.dart';
import '../class/request_status.dart';
import '../debug/tracking_logger.dart';
import '../constants/app_strings.dart';
import 'services.dart';

/// Records that a student opened a piece of content, how long they stayed, and
/// — for PDFs — how far through the document they read.
///
/// One tracker instance follows one open item. The server clamps the reported
/// duration against the real elapsed time, so a stale or manipulated client
/// clock cannot manufacture reading time.
class ContentViewTracker {
  ContentViewTracker({TrackingData? trackingData})
    : _trackingData = trackingData ?? TrackingData(Get.find<DataRequest>());

  final TrackingData _trackingData;

  String? _viewId;
  DateTime? _openedAt;
  int? _totalPages;
  int _furthestPage = 0;

  /// When the app left the foreground, and how long it has been away for the
  /// current item.
  DateTime? _awaySince;
  Duration _away = Duration.zero;

  /// Serialises opens and closes.
  ///
  /// Two lessons tapped in quick succession would otherwise interleave: the
  /// second open reads `_viewId` before the first has written it, leaving the
  /// first view open forever with no dwell time and no read depth. Chaining
  /// keeps every open paired with exactly one close.
  Future<void> _queue = Future<void>.value();

  bool get isOpen => _viewId != null;

  /// Opens a view. [type] is `VIDEO`, `PDF`, or `QUIZ`.
  Future<void> start({
    required String contentId,
    required String type,
    int? totalPages,
  }) {
    // Close any previous item first, so its dwell time is attributed
    // correctly. `end` captures that item's numbers synchronously, which is
    // what lets the reset below run now rather than after the close has been
    // acknowledged — the new viewer can render and report its page count while
    // that close is still in flight, and those pages belong to this item.
    end();

    _totalPages = totalPages;
    _furthestPage = 0;
    _awaySince = null;
    _away = Duration.zero;

    return _serialize(() => _open(contentId, type, totalPages));
  }

  Future<void> _open(String contentId, String type, int? totalPages) async {
    final token = _token;
    if (token.isEmpty) return;

    _openedAt = DateTime.now();

    try {
      final response = await _trackingData.startContentView(
        token: token,
        contentId: contentId,
        type: type,
        totalPages: totalPages,
        tzOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
      );

      _viewId = _extractViewId(response);
      if (_viewId != null) {
        TrackLog.viewStarted(type, contentId, totalPages);
      }
    } catch (_) {
      // Tracking must never block a student from opening their material.
    }
  }

  /// Records the document length once the viewer has rendered it.
  void setTotalPages(int totalPages) {
    if (totalPages > 0) _totalPages = totalPages;
  }

  /// Notes the furthest page reached.
  ///
  /// Furthest rather than current: paging back to re-read something should not
  /// reduce how much of the document the student has seen.
  void onPageChanged(int page) {
    // Viewer callbacks are 0-based; report a human page count.
    final humanPage = page + 1;
    if (humanPage > _furthestPage) _furthestPage = humanPage;
  }

  /// Stops counting dwell time while the app is off screen.
  ///
  /// The server can only clamp a reported duration against elapsed time, not
  /// tell whether the student was actually looking at the item, so a phone left
  /// in a pocket on an open lesson would report hours of reading. Study
  /// sessions already stop at the same boundary.
  void onBackgrounded() => _awaySince ??= DateTime.now();

  void onForegrounded() {
    final since = _awaySince;
    if (since == null) return;

    _away += DateTime.now().difference(since);
    _awaySince = null;
  }

  /// Closes the view and reports dwell time and read depth.
  ///
  /// Read depth and the moment the student left are read synchronously, before
  /// the close is queued: a view being replaced must report its own pages, not
  /// the incoming item's, and its dwell must stop when the student left rather
  /// than whenever the request happens to go out.
  Future<void> end() {
    final pagesRead = _furthestPage > 0 ? _furthestPage : null;
    final totalPages = _totalPages;
    final closedAt = DateTime.now();

    onForegrounded(); // an item closed while backgrounded stops counting then
    final away = _away;

    _totalPages = null;
    _furthestPage = 0;
    _away = Duration.zero;

    return _serialize(() => _close(closedAt, away, pagesRead, totalPages));
  }

  /// The id is read here rather than in [end] because the open it belongs to
  /// may still have been in flight when the student moved on; by the time this
  /// runs, the queue guarantees it has landed.
  Future<void> _close(
    DateTime closedAt,
    Duration away,
    int? pagesRead,
    int? totalPages,
  ) async {
    final viewId = _viewId;
    final openedAt = _openedAt;

    _viewId = null;
    _openedAt = null;

    if (viewId == null || openedAt == null) return;

    final token = _token;
    if (token.isEmpty) return;

    final elapsed = closedAt.difference(openedAt) - away;
    final durationSec = elapsed.inSeconds < 0 ? 0 : elapsed.inSeconds;

    try {
      await _trackingData.endContentView(
        token: token,
        viewId: viewId,
        durationSec: durationSec,
        pagesRead: pagesRead,
        totalPages: totalPages,
      );
      TrackLog.viewEnded(
        viewId: viewId,
        durationSec: durationSec,
        pagesRead: pagesRead,
        totalPages: totalPages,
      );
    } catch (_) {
      // An unclosed view simply carries no dwell time; nothing is corrupted.
    }
  }

  /// Runs [action] after every operation queued before it.
  Future<void> _serialize(Future<void> Function() action) {
    final next = _queue.then((_) => action()).catchError((_) {});
    _queue = next;
    return next;
  }

  String get _token =>
      Get.find<MyServices>().sharedPreferences.getString(
        AppSharedPrefKeys.userTokenKey,
      ) ??
      '';

  String? _extractViewId(dynamic response) {
    if (response == null) return null;
    try {
      if (response.$1 != RequestStatus.success) return null;
      final body = response.$2;
      if (body is! Map) return null;

      final data = body['data'];
      if (data is Map) {
        final inner = data['data'];
        if (inner is Map && inner['viewId'] != null) {
          return inner['viewId'].toString();
        }
        if (data['viewId'] != null) return data['viewId'].toString();
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
