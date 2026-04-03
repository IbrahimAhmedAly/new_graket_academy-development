import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class CoursesData {
  final DataRequest dataRequest;
  CoursesData(this.dataRequest);

  String _withParams(String url,
      {int? page, int? limit, String? search}) {
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (search != null && search.isNotEmpty) params['search'] = search;
    final uri = Uri.parse(url);
    return uri.replace(queryParameters: params.isEmpty ? null : params).toString();
  }

  Future<dynamic> getAllCourses({String? token, int? page, int? limit, String? search}) async {
    final response = await dataRequest.getData(
      _withParams(AppApis.getAllCouses, page: page, limit: limit, search: search),
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getRecommendedCourses(
      {String? token, int? page, int? limit, String? search}) async {
    final response = await dataRequest.getData(
      _withParams(AppApis.getRecommendedCourses,
          page: page, limit: limit, search: search),
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getPopularCourses(
      {String? token, int? page, int? limit, String? search}) async {
    final response = await dataRequest.getData(
      _withParams(AppApis.getPopularCourses,
          page: page, limit: limit, search: search),
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }
}
