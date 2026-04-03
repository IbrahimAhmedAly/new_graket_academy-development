// To parse this JSON data, do
//
//     final getCourseProgressDetailsModel = getCourseProgressDetailsModelFromJson(jsonString);

import 'dart:convert';

GetCourseProgressDetailsModel getCourseProgressDetailsModelFromJson(
  String str,
) => GetCourseProgressDetailsModel.fromJson(json.decode(str));

String getCourseProgressDetailsModelToJson(
  GetCourseProgressDetailsModel data,
) => json.encode(data.toJson());

class GetCourseProgressDetailsModel {
  bool? success;
  int? statusCode;
  GetCourseProgressDetailsModelData? data;
  DateTime? timestamp;

  GetCourseProgressDetailsModel({
    this.success,
    this.statusCode,
    this.data,
    this.timestamp,
  });

  factory GetCourseProgressDetailsModel.fromJson(Map<String, dynamic> json) =>
      GetCourseProgressDetailsModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : GetCourseProgressDetailsModelData.fromJson(json["data"]),
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

class GetCourseProgressDetailsModelData {
  String? message;
  DataData? data;

  GetCourseProgressDetailsModelData({this.message, this.data});

  factory GetCourseProgressDetailsModelData.fromJson(
    Map<String, dynamic> json,
  ) => GetCourseProgressDetailsModelData(
    message: json["message"],
    data: json["data"] == null ? null : DataData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class DataData {
  Enrollment? enrollment;
  Course? course;
  Stats? stats;
  List<Section>? sections;

  DataData({this.enrollment, this.course, this.stats, this.sections});

  factory DataData.fromJson(Map<String, dynamic> json) => DataData(
    enrollment: json["enrollment"] == null
        ? null
        : Enrollment.fromJson(json["enrollment"]),
    course: json["course"] == null ? null : Course.fromJson(json["course"]),
    stats: json["stats"] == null ? null : Stats.fromJson(json["stats"]),
    sections: json["sections"] == null
        ? []
        : List<Section>.from(json["sections"]!.map((x) => Section.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "enrollment": enrollment?.toJson(),
    "course": course?.toJson(),
    "stats": stats?.toJson(),
    "sections": sections == null
        ? []
        : List<dynamic>.from(sections!.map((x) => x.toJson())),
  };
}

class Course {
  String? id;
  String? title;
  String? thumbnail;
  Instructor? instructor;
  Category? category;

  Course({this.id, this.title, this.thumbnail, this.instructor, this.category});

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json["id"],
    title: json["title"],
    thumbnail: json["thumbnail"],
    instructor: json["instructor"] == null
        ? null
        : Instructor.fromJson(json["instructor"]),
    category: json["category"] == null
        ? null
        : Category.fromJson(json["category"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "thumbnail": thumbnail,
    "instructor": instructor?.toJson(),
    "category": category?.toJson(),
  };
}

class Category {
  String? id;
  String? name;
  String? slug;
  String? description;
  String? icon;
  DateTime? createdAt;
  DateTime? updatedAt;

  Category({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.icon,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    description: json["description"],
    icon: json["icon"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "description": description,
    "icon": icon,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Instructor {
  String? id;
  String? name;
  String? email;
  String? avatar;
  String? bio;
  String? title;
  DateTime? createdAt;
  DateTime? updatedAt;

  Instructor({
    this.id,
    this.name,
    this.email,
    this.avatar,
    this.bio,
    this.title,
    this.createdAt,
    this.updatedAt,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) => Instructor(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    avatar: json["avatar"],
    bio: json["bio"],
    title: json["title"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "avatar": avatar,
    "bio": bio,
    "title": title,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Enrollment {
  String? id;
  String? status;
  int? progress;
  DateTime? enrolledAt;
  DateTime? completedAt;

  Enrollment({
    this.id,
    this.status,
    this.progress,
    this.enrolledAt,
    this.completedAt,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) => Enrollment(
    id: json["id"],
    status: json["status"],
    progress: json["progress"],
    enrolledAt: json["enrolledAt"] == null
        ? null
        : DateTime.parse(json["enrolledAt"]),
    completedAt: json["completedAt"] == null
        ? null
        : DateTime.parse(json["completedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "progress": progress,
    "enrolledAt": enrolledAt?.toIso8601String(),
    "completedAt": completedAt?.toIso8601String(),
  };
}

class Section {
  String? id;
  String? title;
  int? order;
  List<Content>? contents;

  Section({this.id, this.title, this.order, this.contents});

  factory Section.fromJson(Map<String, dynamic> json) => Section(
    id: json["id"],
    title: json["title"],
    order: json["order"],
    contents: json["contents"] == null
        ? []
        : List<Content>.from(json["contents"]!.map((x) => Content.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "order": order,
    "contents": contents == null
        ? []
        : List<dynamic>.from(contents!.map((x) => x.toJson())),
  };
}

class Content {
  String? id;
  String? title;
  String? type;
  int? order;
  int? duration;
  String? sectionId;
  String? videoUrl;
  String? pdfUrl;
  int? fileSize;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? completed;
  dynamic completedAt;

  Content({
    this.id,
    this.title,
    this.type,
    this.order,
    this.duration,
    this.sectionId,
    this.videoUrl,
    this.pdfUrl,
    this.fileSize,
    this.createdAt,
    this.updatedAt,
    this.completed,
    this.completedAt,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    id: json["id"],
    title: json["title"],
    type: json["type"],
    order: json["order"],
    duration: json["duration"],
    sectionId: json["sectionId"],
    videoUrl: json["videoUrl"],
    pdfUrl: json["pdfUrl"],
    fileSize: json["fileSize"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    completed: json["completed"],
    completedAt: json["completedAt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "type": type,
    "order": order,
    "duration": duration,
    "sectionId": sectionId,
    "videoUrl": videoUrl,
    "pdfUrl": pdfUrl,
    "fileSize": fileSize,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "completed": completed,
    "completedAt": completedAt,
  };
}

class Stats {
  int? totalContents;
  int? completedContents;
  int? progressPercentage;

  Stats({this.totalContents, this.completedContents, this.progressPercentage});

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    totalContents: json["totalContents"],
    completedContents: json["completedContents"],
    progressPercentage: json["progressPercentage"],
  );

  Map<String, dynamic> toJson() => {
    "totalContents": totalContents,
    "completedContents": completedContents,
    "progressPercentage": progressPercentage,
  };
}
