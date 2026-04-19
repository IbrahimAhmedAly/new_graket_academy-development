import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class InstructorData {
  DataRequest dataRequest;
  InstructorData(this.dataRequest);

  Future getInstructorById({
    required String instructorId,
    required String userToken,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getInstructorById(instructorId),
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future getInstructorCourses({
    required String instructorId,
    required String userToken,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getInstructorCourses(instructorId),
      token: userToken,
      queryParameters: {'page': page, 'limit': limit},
    );
    return response.fold((l) => l, (r) => r);
  }
}
