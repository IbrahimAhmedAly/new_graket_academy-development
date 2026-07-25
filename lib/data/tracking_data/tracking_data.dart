import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

/// Activity-tracking endpoints.
///
/// These calls are fire-and-forget from the caller's point of view: a failed
/// heartbeat or watch report must never interrupt a student mid-lesson. The
/// controllers that use this class swallow failures deliberately.
class TrackingData {
  final DataRequest dataRequest;

  TrackingData(this.dataRequest);

  /// Reports intervals of a video that were actually played.
  ///
  /// [segments] are `{start, end}` pairs in seconds. The server merges them
  /// into a union, so re-sending a segment after a network retry cannot
  /// inflate the student's watch time.
  Future<dynamic> trackVideoProgress({
    required String token,
    required String contentId,
    required List<Map<String, int>> segments,
    required int positionSec,
    int? durationSec,
    bool isReplay = false,
    int? tzOffsetMinutes,
  }) async {
    final body = <String, dynamic>{
      'contentId': contentId,
      'segments': segments,
      'positionSec': positionSec,
      if (durationSec != null) 'durationSec': durationSec,
      if (isReplay) 'isReplay': true,
      if (tzOffsetMinutes != null) 'tzOffsetMinutes': tzOffsetMinutes,
    };

    final response = await dataRequest.postDataJsonBody(
      AppApis.trackVideoProgress,
      body,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  /// Stored watch state for a video, used to resume where the student left off.
  Future<dynamic> getVideoWatchProgress({
    required String token,
    required String contentId,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getVideoWatchProgress(contentId),
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  /// Opens a view when the student enters a content item.
  Future<dynamic> startContentView({
    required String token,
    required String contentId,
    required String type,
    int? totalPages,
    int? tzOffsetMinutes,
  }) async {
    final body = <String, dynamic>{
      'contentId': contentId,
      'type': type,
      if (totalPages != null) 'totalPages': totalPages,
      if (tzOffsetMinutes != null) 'tzOffsetMinutes': tzOffsetMinutes,
    };

    final response = await dataRequest.postDataJsonBody(
      AppApis.startContentView,
      body,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  /// Closes a view, recording dwell time and (for PDFs) how far they read.
  Future<dynamic> endContentView({
    required String token,
    required String viewId,
    required int durationSec,
    int? pagesRead,
    int? totalPages,
  }) async {
    final body = <String, dynamic>{
      'viewId': viewId,
      'durationSec': durationSec,
      if (pagesRead != null) 'pagesRead': pagesRead,
      if (totalPages != null) 'totalPages': totalPages,
    };

    final response = await dataRequest.postDataJsonBody(
      AppApis.endContentView,
      body,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  /// Opens a study session, or resumes the one already open server-side.
  Future<dynamic> startSession({
    required String token,
    int? tzOffsetMinutes,
  }) async {
    final body = <String, dynamic>{
      if (tzOffsetMinutes != null) 'tzOffsetMinutes': tzOffsetMinutes,
    };

    final response = await dataRequest.postDataJsonBody(
      AppApis.startSession,
      body,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  /// Keeps a session alive while the app is in the foreground.
  Future<dynamic> heartbeat({
    required String token,
    required String sessionId,
  }) async {
    final response = await dataRequest.postDataJsonBody(
      AppApis.sessionHeartbeat,
      {'sessionId': sessionId},
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  /// Closes a session when the app goes to the background.
  Future<dynamic> endSession({
    required String token,
    required String sessionId,
  }) async {
    final response = await dataRequest.postDataJsonBody(
      AppApis.endSession,
      {'sessionId': sessionId},
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }
}
