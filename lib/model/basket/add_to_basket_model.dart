// To parse this JSON data, do
//
//     final addToBasketModel = addToBasketModelFromJson(jsonString);

import 'dart:convert';

AddToBasketModel addToBasketModelFromJson(String str) =>
    AddToBasketModel.fromJson(json.decode(str));

String addToBasketModelToJson(AddToBasketModel data) =>
    json.encode(data.toJson());

class AddToBasketModel {
  bool? success;
  int? statusCode;
  AddToBasketModelData? data;
  DateTime? timestamp;

  AddToBasketModel({this.success, this.statusCode, this.data, this.timestamp});

  factory AddToBasketModel.fromJson(Map<String, dynamic> json) =>
      AddToBasketModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : AddToBasketModelData.fromJson(json["data"]),
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

class AddToBasketModelData {
  String? message;
  DataData? data;

  AddToBasketModelData({this.message, this.data});

  factory AddToBasketModelData.fromJson(Map<String, dynamic> json) =>
      AddToBasketModelData(
        message: json["message"],
        data: json["data"] == null ? null : DataData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class DataData {
  String? id;
  String? userId;
  String? courseId;
  DateTime? createdAt;
  Course? course;

  DataData({this.id, this.userId, this.courseId, this.createdAt, this.course});

  factory DataData.fromJson(Map<String, dynamic> json) => DataData(
    id: json["id"],
    userId: json["userId"],
    courseId: json["courseId"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    course: json["course"] == null ? null : Course.fromJson(json["course"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "courseId": courseId,
    "createdAt": createdAt?.toIso8601String(),
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
  };
}

class Category {
  String? id;
  String? name;

  Category({this.id, this.name});

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class Instructor {
  String? id;
  String? name;
  String? avatar;

  Instructor({this.id, this.name, this.avatar});

  factory Instructor.fromJson(Map<String, dynamic> json) =>
      Instructor(id: json["id"], name: json["name"], avatar: json["avatar"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "avatar": avatar};
}
