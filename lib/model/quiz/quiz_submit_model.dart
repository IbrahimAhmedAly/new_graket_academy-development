import 'dart:convert';

// Request body for POST /quiz/submit
class QuizSubmitRequest {
  final String quizId;
  final List<QuizAnswer> answers;
  final int? timeTaken;

  QuizSubmitRequest({
    required this.quizId,
    required this.answers,
    this.timeTaken,
  });

  Map<String, dynamic> toJson() => {
    "quizId": quizId,
    "answers": answers.map((a) => a.toJson()).toList(),
    if (timeTaken != null) "timeTaken": timeTaken,
  };
}

class QuizAnswer {
  final String questionId;
  final String selectedOptionId;

  QuizAnswer({required this.questionId, required this.selectedOptionId});

  Map<String, dynamic> toJson() => {
    "questionId": questionId,
    "selectedOptionId": selectedOptionId,
  };
}

// Response from POST /quiz/submit
QuizSubmitResultModel quizSubmitResultFromJson(String str) =>
    QuizSubmitResultModel.fromJson(json.decode(str));

class QuizSubmitResultModel {
  bool? success;
  int? statusCode;
  QuizSubmitResultOuter? data;

  QuizSubmitResultModel({this.success, this.statusCode, this.data});

  factory QuizSubmitResultModel.fromJson(Map<String, dynamic> json) =>
      QuizSubmitResultModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : QuizSubmitResultOuter.fromJson(json["data"]),
      );
}

class QuizSubmitResultOuter {
  String? message;
  QuizSubmitResult? data;

  QuizSubmitResultOuter({this.message, this.data});

  factory QuizSubmitResultOuter.fromJson(Map<String, dynamic> json) =>
      QuizSubmitResultOuter(
        message: json["message"],
        data: json["data"] == null
            ? null
            : QuizSubmitResult.fromJson(json["data"]),
      );
}

class QuizSubmitResult {
  String? attemptId;
  double? score;
  bool? passed;
  int? passingScore;
  int? correctAnswers;
  int? totalQuestions;
  int? earnedPoints;
  int? totalPoints;
  int? timeTaken;
  List<QuizQuestionResult>? results;

  QuizSubmitResult({
    this.attemptId,
    this.score,
    this.passed,
    this.passingScore,
    this.correctAnswers,
    this.totalQuestions,
    this.earnedPoints,
    this.totalPoints,
    this.timeTaken,
    this.results,
  });

  factory QuizSubmitResult.fromJson(Map<String, dynamic> json) =>
      QuizSubmitResult(
        attemptId: json["attemptId"],
        score: json["score"]?.toDouble(),
        passed: json["passed"],
        passingScore: json["passingScore"],
        correctAnswers: json["correctAnswers"],
        totalQuestions: json["totalQuestions"],
        earnedPoints: json["earnedPoints"],
        totalPoints: json["totalPoints"],
        timeTaken: json["timeTaken"],
        results: json["results"] == null
            ? []
            : List<QuizQuestionResult>.from(
                json["results"]!.map((x) => QuizQuestionResult.fromJson(x))),
      );
}

class QuizQuestionResult {
  String? questionId;
  String? questionText;
  int? points;
  bool? isCorrect;
  QuizResultOption? selectedOption;
  QuizResultOption? correctOption;
  List<QuizResultOptionFull>? options;

  QuizQuestionResult({
    this.questionId,
    this.questionText,
    this.points,
    this.isCorrect,
    this.selectedOption,
    this.correctOption,
    this.options,
  });

  factory QuizQuestionResult.fromJson(Map<String, dynamic> json) =>
      QuizQuestionResult(
        questionId: json["questionId"],
        questionText: json["questionText"],
        points: json["points"],
        isCorrect: json["isCorrect"],
        selectedOption: json["selectedOption"] == null
            ? null
            : QuizResultOption.fromJson(json["selectedOption"]),
        correctOption: json["correctOption"] == null
            ? null
            : QuizResultOption.fromJson(json["correctOption"]),
        options: json["options"] == null
            ? []
            : List<QuizResultOptionFull>.from(
                json["options"]!.map((x) => QuizResultOptionFull.fromJson(x))),
      );
}

class QuizResultOption {
  String? id;
  String? text;

  QuizResultOption({this.id, this.text});

  factory QuizResultOption.fromJson(Map<String, dynamic> json) =>
      QuizResultOption(id: json["id"], text: json["text"]);
}

class QuizResultOptionFull {
  String? id;
  String? text;
  bool? isCorrect;
  bool? isSelected;

  QuizResultOptionFull({this.id, this.text, this.isCorrect, this.isSelected});

  factory QuizResultOptionFull.fromJson(Map<String, dynamic> json) =>
      QuizResultOptionFull(
        id: json["id"],
        text: json["text"],
        isCorrect: json["isCorrect"],
        isSelected: json["isSelected"],
      );
}
