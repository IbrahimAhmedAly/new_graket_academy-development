import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class ReviewsData {
  DataRequest dataRequest;
  ReviewsData(this.dataRequest);

  Future getCourseReviews({
    required String courseId,
    required String userToken,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getCourseReviews(courseId),
      token: userToken,
      queryParameters: {'page': page, 'limit': limit},
    );
    return response.fold((l) => l, (r) => r);
  }
}
