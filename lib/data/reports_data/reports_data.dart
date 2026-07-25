import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

/// Reads the student's progress reports.
///
/// The device's UTC offset is sent with any date-bucketed request so days,
/// streaks and the heat map are computed against the student's own calendar
/// rather than the server's.
class ReportsData {
  final DataRequest dataRequest;

  ReportsData(this.dataRequest);

  int get _tzOffset => DateTime.now().timeZoneOffset.inMinutes;

  Future<dynamic> getDashboard({required String token}) async {
    final response = await dataRequest.getData(
      AppApis.reportsDashboard(_tzOffset),
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getQuizAnalytics({required String token}) async {
    final response = await dataRequest.getData(
      AppApis.reportsQuizAnalytics,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getSuggestions({required String token}) async {
    final response = await dataRequest.getData(
      AppApis.reportsSuggestions,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getRewards({required String token}) async {
    final response = await dataRequest.getData(
      AppApis.reportsRewards,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getMission({required String token}) async {
    final response = await dataRequest.getData(
      AppApis.reportsMission(_tzOffset),
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getInsights({required String token}) async {
    final response = await dataRequest.getData(
      AppApis.reportsInsights(_tzOffset),
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }
}
