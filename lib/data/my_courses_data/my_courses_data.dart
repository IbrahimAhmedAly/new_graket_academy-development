import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class MyCoursesData {
  final DataRequest dataRequest;
  MyCoursesData(this.dataRequest);

  Future<dynamic> getMyCourses({
    required String token,
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await dataRequest.getData(
      AppApis.getMyCourses,
      token: token,
      queryParameters: queryParams,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getCourseProgressDetails({
    required String token,
    required String courseId,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getCourseProgressDetails(courseId),
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }
}
