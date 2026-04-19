import 'dart:convert';

GetQuizModel getQuizModelFromJson(String str) =>
    GetQuizModel.fromJson(json.decode(str));

class GetQuizModel {
  bool? success;
  int? statusCode;
  GetQuizModelData? data;
  DateTime? timestamp;

  GetQuizModel({this.success, this.statusCode, this.data, this.timestamp});

  factory GetQuizModel.fromJson(Map<String, dynamic> json) => GetQuizModel(
    success: json["success"],
    statusCode: json["statusCode"],
    data: json["data"] == null
        ? null
        : GetQuizModelData.fromJson(json["data"]),
    timestamp: json["timestamp"] == null
        ? null
        : DateTime.parse(json["timestamp"]),
  );
}

class GetQuizModelData {
  String? message;
  QuizData? data;

  GetQuizModelData({this.message, this.data});

  factory GetQuizModelData.fromJson(Map<String, dynamic> json) =>
      GetQuizModelData(
        message: json["message"],
        data: json["data"] == null ? null : QuizData.fromJson(json["data"]),
      );
}

class QuizData {
  String? id;
  String? title;
  String? section;
  QuizCourse? course;
  int? timeLimit;
  int? passingScore;
  int? totalQuestions;
  int? totalPoints;
  List<QuizQuestion>? questions;
  int? previousAttempts;
  double? bestScore;

  QuizData({
    this.id,
    this.title,
    this.section,
    this.course,
    this.timeLimit,
    this.passingScore,
    this.totalQuestions,
    this.totalPoints,
    this.questions,
    this.previousAttempts,
    this.bestScore,
  });

  factory QuizData.fromJson(Map<String, dynamic> json) => QuizData(
    id: json["id"],
    title: json["title"],
    section: json["section"],
    course: json["course"] == null ? null : QuizCourse.fromJson(json["course"]),
    timeLimit: json["timeLimit"],
    passingScore: json["passingScore"],
    totalQuestions: json["totalQuestions"],
    totalPoints: json["totalPoints"],
    questions: json["questions"] == null
        ? []
        : List<QuizQuestion>.from(
            json["questions"]!.map((x) => QuizQuestion.fromJson(x))),
    previousAttempts: json["previousAttempts"],
    bestScore: json["bestScore"]?.toDouble(),
  );
}

class QuizCourse {
  String? id;
  String? title;

  QuizCourse({this.id, this.title});

  factory QuizCourse.fromJson(Map<String, dynamic> json) =>
      QuizCourse(id: json["id"], title: json["title"]);
}

class QuizQuestion {
  String? id;
  String? questionText;
  int? order;
  int? points;
  List<QuizOption>? options;

  QuizQuestion({
    this.id,
    this.questionText,
    this.order,
    this.points,
    this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json["id"],
    questionText: json["questionText"],
    order: json["order"],
    points: json["points"],
    options: json["options"] == null
        ? []
        : List<QuizOption>.from(
            json["options"]!.map((x) => QuizOption.fromJson(x))),
  );
}

class QuizOption {
  String? id;
  String? text;
  int? order;
  // isCorrect is null before submission, true/false after
  bool? isCorrect;
  bool? isSelected;

  QuizOption({this.id, this.text, this.order, this.isCorrect, this.isSelected});

  factory QuizOption.fromJson(Map<String, dynamic> json) => QuizOption(
    id: json["id"],
    text: json["text"],
    order: json["order"],
    isCorrect: json["isCorrect"],
    isSelected: json["isSelected"],
  );
}
