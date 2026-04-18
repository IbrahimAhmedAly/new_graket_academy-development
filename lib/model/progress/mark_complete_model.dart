import 'dart:convert';

// Request body for POST /progress/complete
class MarkCompleteRequest {
  final String contentId;
  final bool completed;

  MarkCompleteRequest({required this.contentId, this.completed = true});

  Map<String, dynamic> toJson() => {
    "contentId": contentId,
    "completed": completed,
  };
}

// Response from POST /progress/complete
MarkCompleteModel markCompleteModelFromJson(String str) =>
    MarkCompleteModel.fromJson(json.decode(str));

class MarkCompleteModel {
  bool? success;
  int? statusCode;
  MarkCompleteModelOuter? data;

  MarkCompleteModel({this.success, this.statusCode, this.data});

  factory MarkCompleteModel.fromJson(Map<String, dynamic> json) =>
      MarkCompleteModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : MarkCompleteModelOuter.fromJson(json["data"]),
      );
}

class MarkCompleteModelOuter {
  String? message;
  MarkCompleteData? data;

  MarkCompleteModelOuter({this.message, this.data});

  factory MarkCompleteModelOuter.fromJson(Map<String, dynamic> json) =>
      MarkCompleteModelOuter(
        message: json["message"],
        data: json["data"] == null
            ? null
            : MarkCompleteData.fromJson(json["data"]),
      );
}

class MarkCompleteData {
  ContentProgress? progress;
  CourseProgressSummary? courseProgress;

  MarkCompleteData({this.progress, this.courseProgress});

  factory MarkCompleteData.fromJson(Map<String, dynamic> json) =>
      MarkCompleteData(
        progress: json["progress"] == null
            ? null
            : ContentProgress.fromJson(json["progress"]),
        courseProgress: json["courseProgress"] == null
            ? null
            : CourseProgressSummary.fromJson(json["courseProgress"]),
      );
}

class ContentProgress {
  String? id;
  String? userId;
  String? contentId;
  bool? completed;
  DateTime? completedAt;

  ContentProgress({
    this.id,
    this.userId,
    this.contentId,
    this.completed,
    this.completedAt,
  });

  factory ContentProgress.fromJson(Map<String, dynamic> json) =>
      ContentProgress(
        id: json["id"],
        userId: json["userId"],
        contentId: json["contentId"],
        completed: json["completed"],
        completedAt: json["completedAt"] == null
            ? null
            : DateTime.parse(json["completedAt"]),
      );
}

class CourseProgressSummary {
  int? completed;
  int? total;
  int? percentage;
  String? status;
  bool? isCompleted;

  CourseProgressSummary({
    this.completed,
    this.total,
    this.percentage,
    this.status,
    this.isCompleted,
  });

  factory CourseProgressSummary.fromJson(Map<String, dynamic> json) =>
      CourseProgressSummary(
        completed: json["completed"],
        total: json["total"],
        percentage: json["percentage"],
        status: json["status"],
        isCompleted: json["isCompleted"],
      );
}
