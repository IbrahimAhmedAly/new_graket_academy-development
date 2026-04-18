import 'dart:async';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/debug_print.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/data/quiz_data/quiz_data.dart';
import 'package:new_graket_acadimy/model/quiz/get_quiz_model.dart' as qm;
import 'package:new_graket_acadimy/model/quiz/quiz_submit_model.dart';

enum QuizFetchMode { byContentId, byQuizId }

abstract class QuizController extends GetxController {}

class QuizControllerImp extends QuizController {
  final QuizData _quizData = QuizData(Get.find());
  final MyServices _services = Get.find();

  String userToken = '';
  String _lookupId = '';
  QuizFetchMode _mode = QuizFetchMode.byContentId;

  RequestStatus requestStatus = RequestStatus.loading;
  RequestStatus submitStatus = RequestStatus.none;

  qm.QuizData? quiz;

  // questionId -> selectedOptionId
  final Map<String, String> answers = {};

  // Elapsed time in seconds
  int elapsedSeconds = 0;
  Timer? _timer;
  bool quizStarted = false;

  // Submit result
  QuizSubmitResult? result;

  // Error message surfaced to UI
  String errorMessage = '';

  int get totalQuestions =>
      quiz?.totalQuestions ?? (quiz?.questions?.length ?? 0);
  int get answeredCount => answers.length;
  bool get canSubmit =>
      totalQuestions > 0 && answeredCount == totalQuestions && !isSubmitting;
  bool get isSubmitting => submitStatus == RequestStatus.loading;

  /// Remaining time in seconds. null = no time limit.
  int? get remainingSeconds {
    final limit = quiz?.timeLimit;
    if (limit == null || limit <= 0) return null;
    final total = limit * 60;
    final remaining = total - elapsedSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  bool get timeExpired {
    final r = remainingSeconds;
    return r != null && r <= 0;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map? ?? {};
    _lookupId = args['id']?.toString() ?? '';
    final modeStr = args['mode']?.toString() ?? 'content';
    _mode =
        modeStr == 'quiz' ? QuizFetchMode.byQuizId : QuizFetchMode.byContentId;
    userToken =
        _services.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
            '';
    loadQuiz();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> loadQuiz() async {
    if (_lookupId.isEmpty) {
      requestStatus = RequestStatus.failed;
      errorMessage = 'Missing quiz reference';
      update();
      return;
    }
    requestStatus = RequestStatus.loading;
    errorMessage = '';
    update();

    final response = _mode == QuizFetchMode.byContentId
        ? await _quizData.getQuizByContent(
            contentId: _lookupId, userToken: userToken)
        : await _quizData.getQuiz(quizId: _lookupId, userToken: userToken);

    final status = response.$1;
    requestStatus = status;

    if (status == RequestStatus.success && response.$2 is Map) {
      final raw = response.$2 as Map<String, dynamic>;
      quiz = _parseQuiz(raw);
      if (quiz == null) {
        requestStatus = RequestStatus.failed;
        errorMessage = 'Could not parse quiz';
      } else if ((quiz!.questions ?? []).isEmpty) {
        requestStatus = RequestStatus.failed;
        errorMessage = 'This quiz has no questions yet';
      }
    } else if (response.$2 is Map) {
      final raw = response.$2 as Map;
      errorMessage = raw['message']?.toString() ?? 'Failed to load quiz';
    }
    update();
  }

  qm.QuizData? _parseQuiz(Map<String, dynamic> raw) {
    try {
      final model = qm.GetQuizModel.fromJson(raw);
      return model.data?.data;
    } catch (_) {}
    try {
      final inner = raw['data'];
      if (inner is Map) {
        final dataMap = inner['data'] ?? inner;
        if (dataMap is Map<String, dynamic>) {
          return qm.QuizData.fromJson(dataMap);
        }
      }
    } catch (_) {}
    return null;
  }

  void startQuiz() {
    if (quizStarted) return;
    quizStarted = true;
    elapsedSeconds = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds += 1;
      if (timeExpired && !isSubmitting && result == null) {
        _timer?.cancel();
        submit(auto: true);
        return;
      }
      update();
    });
    update();
  }

  void selectAnswer(String questionId, String optionId) {
    answers[questionId] = optionId;
    update();
  }

  String? selectedFor(String questionId) => answers[questionId];

  Future<void> submit({bool auto = false}) async {
    if (quiz == null || isSubmitting) return;
    if (!auto && answeredCount < totalQuestions) return;

    submitStatus = RequestStatus.loading;
    errorMessage = '';
    update();

    final answerList = (quiz!.questions ?? [])
        .where((q) => q.id != null && answers.containsKey(q.id))
        .map((q) => QuizAnswer(
              questionId: q.id!,
              selectedOptionId: answers[q.id]!,
            ))
        .toList();

    final request = QuizSubmitRequest(
      quizId: quiz!.id ?? '',
      answers: answerList,
      timeTaken: elapsedSeconds,
    );

    try {
      final response = await _quizData.submitQuiz(
        request: request,
        userToken: userToken,
      );
      submitStatus = response.$1;

      if (submitStatus == RequestStatus.success && response.$2 is Map) {
        final raw = response.$2 as Map<String, dynamic>;
        result = _parseSubmitResult(raw);
        _timer?.cancel();
        if (result == null) {
          submitStatus = RequestStatus.failed;
          errorMessage = 'Could not parse quiz result';
        }
      } else if (response.$2 is Map) {
        final raw = response.$2 as Map;
        errorMessage = raw['message']?.toString() ?? 'Failed to submit quiz';
      }
    } catch (e) {
      submitStatus = RequestStatus.serverException;
      errorMessage = 'Something went wrong. Please try again.';
      appPrint('Quiz submit error: $e');
    }
    update();
  }

  QuizSubmitResult? _parseSubmitResult(Map<String, dynamic> raw) {
    try {
      final model = QuizSubmitResultModel.fromJson(raw);
      return model.data?.data;
    } catch (_) {}
    try {
      final inner = raw['data'];
      if (inner is Map) {
        final dataMap = inner['data'] ?? inner;
        if (dataMap is Map<String, dynamic>) {
          return QuizSubmitResult.fromJson(dataMap);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Reset for another attempt — keeps the same loaded quiz.
  void retryQuiz() {
    answers.clear();
    elapsedSeconds = 0;
    quizStarted = false;
    result = null;
    submitStatus = RequestStatus.none;
    errorMessage = '';
    _timer?.cancel();
    update();
  }
}
