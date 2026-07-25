import '../../core/class/data_request.dart';
import '../../core/class/request_status.dart';
import '../../core/constants/app_apis.dart';
import '../../core/debug/tracking_logger.dart';

/// Reads the student's progress reports.
///
/// The device's UTC offset is sent with any date-bucketed request so days,
/// streaks and the heat map are computed against the student's own calendar
/// rather than the server's.
class ReportsData {
  final DataRequest dataRequest;

  ReportsData(this.dataRequest);

  int get _tzOffset => DateTime.now().timeZoneOffset.inMinutes;

  /// Issues a GET and logs its outcome.
  ///
  /// Logging here rather than only in the controller means a non-200 is
  /// visible even when parsing would have silently produced an empty screen.
  Future<dynamic> _get(String name, String url, String token) async {
    final response = await dataRequest.getData(url, token: token);
    final folded = response.fold((l) => l, (r) => r);

    try {
      if (folded.$1 != RequestStatus.success) {
        TrackLog.reportFailure(name, folded.$1);
      }
    } catch (_) {
      // Never let logging break a request.
    }

    return folded;
  }

  Future<dynamic> getDashboard({required String token}) =>
      _get('dashboard', AppApis.reportsDashboard(_tzOffset), token);

  Future<dynamic> getQuizAnalytics({required String token}) =>
      _get('quiz-analytics', AppApis.reportsQuizAnalytics, token);

  Future<dynamic> getSuggestions({required String token}) =>
      _get('suggestions', AppApis.reportsSuggestions, token);

  Future<dynamic> getRewards({required String token}) =>
      _get('rewards', AppApis.reportsRewards, token);

  Future<dynamic> getMission({required String token}) =>
      _get('mission', AppApis.reportsMission(_tzOffset), token);

  Future<dynamic> getInsights({required String token}) =>
      _get('insights', AppApis.reportsInsights(_tzOffset), token);
}
