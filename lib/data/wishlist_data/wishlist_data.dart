import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class WishlistData {
  DataRequest dataRequest;
  WishlistData(this.dataRequest);

  Future getSavedStatus({
    required String courseId,
    required String userToken,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getSavedStatus(courseId),
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future saveCourse({
    required String courseId,
    required String userToken,
  }) async {
    final response = await dataRequest.postDataJsonBody(
      AppApis.saveCourse(courseId),
      <String, dynamic>{},
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future unsaveCourse({
    required String courseId,
    required String userToken,
  }) async {
    final response = await dataRequest.deleteData(
      AppApis.unsaveCourse(courseId),
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }
}
