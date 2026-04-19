import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class NotesData {
  DataRequest dataRequest;
  NotesData(this.dataRequest);

  Future getNote({
    required String contentId,
    required String userToken,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getContentNote(contentId),
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future upsertNote({
    required String contentId,
    required String body,
    required String userToken,
  }) async {
    final response = await dataRequest.putDataJsonBody(
      AppApis.upsertContentNote(contentId),
      {'body': body},
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future deleteNote({
    required String contentId,
    required String userToken,
  }) async {
    final response = await dataRequest.deleteData(
      AppApis.deleteContentNote(contentId),
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future getCourseNotes({
    required String courseId,
    required String userToken,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getCourseNotes(courseId),
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }
}
