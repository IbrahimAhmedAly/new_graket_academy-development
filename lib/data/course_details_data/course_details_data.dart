import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class CourseDetailsData {
  DataRequest dataRequest;
  CourseDetailsData(this.dataRequest);

  getCourseDetailsData({required String courseId, required String userToken}) async {
    var response = await dataRequest.getData(
      AppApis.getCourseByID(courseId),
      token: userToken,
    );

    return response.fold((l) => l, (r) => r);
  }
}
