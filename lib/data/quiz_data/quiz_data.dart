import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';
import '../../model/quiz/quiz_submit_model.dart';

class QuizData {
  DataRequest dataRequest;
  QuizData(this.dataRequest);

  Future getQuizByContent({
    required String contentId,
    required String userToken,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getQuizByContent(contentId),
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future getQuiz({
    required String quizId,
    required String userToken,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getQuiz(quizId),
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future submitQuiz({
    required QuizSubmitRequest request,
    required String userToken,
  }) async {
    final response = await dataRequest.postDataJsonBody(
      AppApis.submitQuiz,
      request.toJson(),
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future getQuizAttempts({
    required String quizId,
    required String userToken,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getQuizAttempts(quizId),
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future getAttemptResult({
    required String attemptId,
    required String userToken,
  }) async {
    final response = await dataRequest.getData(
      AppApis.getAttemptResult(attemptId),
      token: userToken,
    );
    return response.fold((l) => l, (r) => r);
  }
}
