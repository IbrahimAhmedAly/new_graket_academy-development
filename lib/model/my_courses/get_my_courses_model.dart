// To parse this JSON data, do
//
//     final getMyCoursesModel = getMyCoursesModelFromJson(jsonString);

import 'dart:convert';

GetMyCoursesModel getMyCoursesModelFromJson(String str) =>
    GetMyCoursesModel.fromJson(json.decode(str));

String getMyCoursesModelToJson(GetMyCoursesModel data) =>
    json.encode(data.toJson());

class GetMyCoursesModel {
  bool? success;
  int? statusCode;
  GetMyCoursesModelData? data;
  DateTime? timestamp;

  GetMyCoursesModel({this.success, this.statusCode, this.data, this.timestamp});

  factory GetMyCoursesModel.fromJson(Map<String, dynamic> json) =>
      GetMyCoursesModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : GetMyCoursesModelData.fromJson(json["data"]),
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

class GetMyCoursesModelData {
  String? message;
  DataData? data;

  GetMyCoursesModelData({this.message, this.data});

  factory GetMyCoursesModelData.fromJson(Map<String, dynamic> json) =>
      GetMyCoursesModelData(
        message: json["message"],
        data: json["data"] == null ? null : DataData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class DataData {
  List<Datum>? data;
  Metadata? metadata;

  DataData({this.data, this.metadata});

  factory DataData.fromJson(Map<String, dynamic> json) => DataData(
    data: json["data"] == null
        ? []
        : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    metadata: json["metadata"] == null
        ? null
        : Metadata.fromJson(json["metadata"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "metadata": metadata?.toJson(),
  };
}

class Datum {
  String? id;
  String? status;
  int? progress;
  DateTime? enrolledAt;
  DateTime? completedAt;
  Course? course;

  Datum({
    this.id,
    this.status,
    this.progress,
    this.enrolledAt,
    this.completedAt,
    this.course,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    status: json["status"],
    progress: json["progress"],
    enrolledAt: json["enrolledAt"] == null
        ? null
        : DateTime.parse(json["enrolledAt"]),
    completedAt: json["completedAt"] == null
        ? null
        : DateTime.parse(json["completedAt"]),
    course: json["course"] == null ? null : Course.fromJson(json["course"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "progress": progress,
    "enrolledAt": enrolledAt?.toIso8601String(),
    "completedAt": completedAt?.toIso8601String(),
    "course": course?.toJson(),
  };
}

class Course {
  String? id;
  String? title;
  String? slug;
  String? description;
  String? thumbnail;
  String? instructorId;
  String? categoryId;
  double? price;
  double? discountPrice;
  int? totalDuration;
  int? totalVideos;
  int? totalQuizzes;
  bool? isPublished;
  DateTime? createdAt;
  DateTime? updatedAt;
  Instructor? instructor;
  Category? category;
  double? averageRating;
  int? totalReviews;
  int? totalSections;

  Course({
    this.id,
    this.title,
    this.slug,
    this.description,
    this.thumbnail,
    this.instructorId,
    this.categoryId,
    this.price,
    this.discountPrice,
    this.totalDuration,
    this.totalVideos,
    this.totalQuizzes,
    this.isPublished,
    this.createdAt,
    this.updatedAt,
    this.instructor,
    this.category,
    this.averageRating,
    this.totalReviews,
    this.totalSections,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json["id"],
    title: json["title"],
    slug: json["slug"],
    description: json["description"],
    thumbnail: json["thumbnail"],
    instructorId: json["instructorId"],
    categoryId: json["categoryId"],
    price: json["price"]?.toDouble(),
    discountPrice: json["discountPrice"]?.toDouble(),
    totalDuration: json["totalDuration"],
    totalVideos: json["totalVideos"],
    totalQuizzes: json["totalQuizzes"],
    isPublished: json["isPublished"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    instructor: json["instructor"] == null
        ? null
        : Instructor.fromJson(json["instructor"]),
    category: json["category"] == null
        ? null
        : Category.fromJson(json["category"]),
    averageRating: json["averageRating"]?.toDouble(),
    totalReviews: json["totalReviews"],
    totalSections: json["totalSections"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "slug": slug,
    "description": description,
    "thumbnail": thumbnail,
    "instructorId": instructorId,
    "categoryId": categoryId,
    "price": price,
    "discountPrice": discountPrice,
    "totalDuration": totalDuration,
    "totalVideos": totalVideos,
    "totalQuizzes": totalQuizzes,
    "isPublished": isPublished,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "instructor": instructor?.toJson(),
    "category": category?.toJson(),
    "averageRating": averageRating,
    "totalReviews": totalReviews,
    "totalSections": totalSections,
  };
}

class Category {
  String? id;
  String? name;
  String? slug;

  Category({this.id, this.name, this.slug});

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: json["id"], name: json["name"], slug: json["slug"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "slug": slug};
}

class Instructor {
  String? id;
  String? name;
  String? avatar;
  String? title;

  Instructor({this.id, this.name, this.avatar, this.title});

  factory Instructor.fromJson(Map<String, dynamic> json) => Instructor(
    id: json["id"],
    name: json["name"],
    avatar: json["avatar"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "avatar": avatar,
    "title": title,
  };
}

class Metadata {
  int? currentPage;
  int? itemsPerPage;
  int? totalItems;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPreviousPage;

  Metadata({
    this.currentPage,
    this.itemsPerPage,
    this.totalItems,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    currentPage: json["currentPage"],
    itemsPerPage: json["itemsPerPage"],
    totalItems: json["totalItems"],
    totalPages: json["totalPages"],
    hasNextPage: json["hasNextPage"],
    hasPreviousPage: json["hasPreviousPage"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "itemsPerPage": itemsPerPage,
    "totalItems": totalItems,
    "totalPages": totalPages,
    "hasNextPage": hasNextPage,
    "hasPreviousPage": hasPreviousPage,
  };
}
