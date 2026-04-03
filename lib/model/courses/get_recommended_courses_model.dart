// To parse this JSON data, do
//
//     final getRecommendedCoursesModel = getRecommendedCoursesModelFromJson(jsonString);

import 'dart:convert';

GetRecommendedCoursesModel getRecommendedCoursesModelFromJson(String str) =>
    GetRecommendedCoursesModel.fromJson(json.decode(str));

String getRecommendedCoursesModelToJson(GetRecommendedCoursesModel data) =>
    json.encode(data.toJson());

class GetRecommendedCoursesModel {
  bool? success;
  int? statusCode;
  Data? data;
  DateTime? timestamp;

  GetRecommendedCoursesModel({
    this.success,
    this.statusCode,
    this.data,
    this.timestamp,
  });

  factory GetRecommendedCoursesModel.fromJson(Map<String, dynamic> json) =>
      GetRecommendedCoursesModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
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

class Data {
  String? message;
  List<Datum>? data;

  Data({this.message, this.data});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    message: json["message"],
    data: json["data"] == null
        ? []
        : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
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
  int? totalEnrollments;

  Datum({
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
    this.totalEnrollments,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
    totalEnrollments: json["totalEnrollments"],
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
    "totalEnrollments": totalEnrollments,
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
