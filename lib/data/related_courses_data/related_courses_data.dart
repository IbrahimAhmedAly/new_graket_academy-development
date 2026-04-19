import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class RelatedCoursesData {
  DataRequest dataRequest;
  RelatedCoursesData(this.dataRequest);

  Future getRelated({
    required String courseId,
    required String userToken,
    int limit = 6,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getRelatedCourses(courseId),
      token: userToken,
      queryParameters: {'limit': limit},
    );
    return response.fold((l) => l, (r) => r);
  }
}
