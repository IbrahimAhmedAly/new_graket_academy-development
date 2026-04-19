import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class QaData {
  DataRequest dataRequest;
  QaData(this.dataRequest);

  Future getQuestions({
    required String courseId,
    required String userToken,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getCourseQuestions(courseId),
      token: userToken,
      queryParameters: {'page': page, 'limit': limit},
    );
    return response.fold((l) => l, (r) => r);
  }

  Future askQuestion({
    required String courseId,
    required String title,
    required String body,
    required String userToken,
  }) async {
    final response = await dataRequest.postDataJsonBody(
      AppApis.askCourseQuestion(courseId),
      {'title': title, 'body': body},
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future getQuestionThread({
    required String questionId,
    required String userToken,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getQuestionThread(questionId),
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future answerQuestion({
    required String questionId,
    required String body,
    required String userToken,
  }) async {
    final response = await dataRequest.postDataJsonBody(
      AppApis.answerQuestion(questionId),
      {'body': body},
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }
}
