// To parse this JSON data, do
//
//     final getCourseProgressModel = getCourseProgressModelFromJson(jsonString);

import 'dart:convert';

GetCourseProgressModel getCourseProgressModelFromJson(String str) =>
    GetCourseProgressModel.fromJson(json.decode(str));

String getCourseProgressModelToJson(GetCourseProgressModel data) =>
    json.encode(data.toJson());

class GetCourseProgressModel {
  bool? success;
  int? statusCode;
  GetCourseProgressModelData? data;
  DateTime? timestamp;

  GetCourseProgressModel({
    this.success,
    this.statusCode,
    this.data,
    this.timestamp,
  });

  factory GetCourseProgressModel.fromJson(Map<String, dynamic> json) =>
      GetCourseProgressModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : GetCourseProgressModelData.fromJson(json["data"]),
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "statusCode": statusCode,
    "data": data?.toJson(),
    "timestamp": timestamp?.toIso8601String(),
  };
}

class GetCourseProgressModelData {
  String? message;
  DataData? data;

  GetCourseProgressModelData({this.message, this.data});

  factory GetCourseProgressModelData.fromJson(Map<String, dynamic> json) =>
      GetCourseProgressModelData(
        message: json["message"],
        data: json["data"] == null ? null : DataData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class DataData {
  String? courseId;
  String? enrollmentId;
  String? status;
  Progress? progress;
  List<dynamic>? completedContentIds;
  DateTime? enrolledAt;
  DateTime? completedAt;

  DataData({
    this.courseId,
    this.enrollmentId,
    this.status,
    this.progress,
    this.completedContentIds,
    this.enrolledAt,
    this.completedAt,
  });

  factory DataData.fromJson(Map<String, dynamic> json) => DataData(
    courseId: json["courseId"],
    enrollmentId: json["enrollmentId"],
    status: json["status"],
    progress: json["progress"] == null
        ? null
        : Progress.fromJson(json["progress"]),
    completedContentIds: json["completedContentIds"] == null
        ? []
        : List<dynamic>.from(json["completedContentIds"]!.map((x) => x)),
    enrolledAt: json["enrolledAt"] == null
        ? null
        : DateTime.parse(json["enrolledAt"]),
    completedAt: json["completedAt"] == null
        ? null
        : DateTime.parse(json["completedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "courseId": courseId,
    "enrollmentId": enrollmentId,
    "status": status,
    "progress": progress?.toJson(),
    "completedContentIds": completedContentIds == null
        ? []
        : List<dynamic>.from(completedContentIds!.map((x) => x)),
    "enrolledAt": enrolledAt?.toIso8601String(),
    "completedAt": completedAt?.toIso8601String(),
  };
}

class Progress {
  int? completed;
  int? total;
  int? percentage;

  Progress({this.completed, this.total, this.percentage});

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
    completed: json["completed"],
    total: json["total"],
    percentage: json["percentage"],
  );

  Map<String, dynamic> toJson() => {
    "completed": completed,
    "total": total,
    "percentage": percentage,
  };
}
