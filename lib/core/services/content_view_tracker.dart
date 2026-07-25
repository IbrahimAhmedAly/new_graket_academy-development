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

  bool get isOpen => _viewId != null;

  /// Opens a view. [type] is `VIDEO`, `PDF`, or `QUIZ`.
  Future<void> start({
    required String contentId,
    required String type,
    int? totalPages,
  }) async {
    // Close any previous item first, so its dwell time is attributed correctly.
    await end();

    final token = _token;
    if (token.isEmpty) return;

    _openedAt = DateTime.now();
    _totalPages = totalPages;
    _furthestPage = 0;

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

  /// Closes the view and reports dwell time and read depth.
  Future<void> end() async {
    final viewId = _viewId;
    final openedAt = _openedAt;

    _viewId = null;
    _openedAt = null;

    if (viewId == null || openedAt == null) return;

    final token = _token;
    if (token.isEmpty) return;

    final durationSec = DateTime.now().difference(openedAt).inSeconds;

    try {
      await _trackingData.endContentView(
        token: token,
        viewId: viewId,
        durationSec: durationSec < 0 ? 0 : durationSec,
        pagesRead: _furthestPage > 0 ? _furthestPage : null,
        totalPages: _totalPages,
      );
      TrackLog.viewEnded(
        viewId: viewId,
        durationSec: durationSec < 0 ? 0 : durationSec,
        pagesRead: _furthestPage > 0 ? _furthestPage : null,
        totalPages: _totalPages,
      );
    } catch (_) {
      // An unclosed view simply carries no dwell time; nothing is corrupted.
    } finally {
      _totalPages = null;
      _furthestPage = 0;
    }
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
