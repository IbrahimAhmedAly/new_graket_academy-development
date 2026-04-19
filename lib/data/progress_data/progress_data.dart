import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';
import '../../model/progress/mark_complete_model.dart';

class ProgressData {
  DataRequest dataRequest;
  ProgressData(this.dataRequest);

  Future markContentComplete({
    required String contentId,
    required String userToken,
    bool completed = true,
  }) async {
    final body = MarkCompleteRequest(
      contentId: contentId,
      completed: completed,
    ).toJson();
    final response = await dataRequest.postDataJsonBody(
      AppApis.markContentComplete,
      body,
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future getContentProgress({
    required String contentId,
    required String userToken,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getContentProgress(contentId),
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future getCourseProgress({
    required String courseId,
    required String userToken,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getCourseProgress(courseId),
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }
}
