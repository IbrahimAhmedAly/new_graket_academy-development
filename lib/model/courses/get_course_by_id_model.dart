// To parse this JSON data, do
//
//     final getCourseById = getCourseByIdFromJson(jsonString);

import 'dart:convert';

GetCourseByIdModel getCourseByIdFromJson(String str) =>
    GetCourseByIdModel.fromJson(json.decode(str));

String getCourseByIdToJson(GetCourseByIdModel data) =>
    json.encode(data.toJson());

class GetCourseByIdModel {
  bool? success;
  int? statusCode;
  GetCourseByIdData? data;
  DateTime? timestamp;

  GetCourseByIdModel({
    this.success,
    this.statusCode,
    this.data,
    this.timestamp,
  });

  factory GetCourseByIdModel.fromJson(Map<String, dynamic> json) =>
      GetCourseByIdModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : GetCourseByIdData.fromJson(json["data"]),
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

class GetCourseByIdData {
  String? message;
  DataData? data;

  GetCourseByIdData({this.message, this.data});

  factory GetCourseByIdData.fromJson(Map<String, dynamic> json) =>
      GetCourseByIdData(
        message: json["message"],
        data: json["data"] == null ? null : DataData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

enum PurchaseType { course, video, none }

class PurchaseInfo {
  bool isPurchased;
  PurchaseType purchaseType;
  List<String> purchasedVideoIds;

  PurchaseInfo({
    required this.isPurchased,
    this.purchaseType = PurchaseType.none,
    this.purchasedVideoIds = const [],
  });

  factory PurchaseInfo.fromJson(Map<String, dynamic> json) {
    final purchased = json["isPurchased"] == true;
    if (!purchased) {
      return PurchaseInfo(isPurchased: false);
    }
    final typeStr = (json["purchaseType"] as String? ?? "").toUpperCase();
    final type = typeStr == "COURSE"
        ? PurchaseType.course
        : typeStr == "VIDEO"
            ? PurchaseType.video
            : PurchaseType.none;
    final ids = json["purchasedVideoIds"] == null
        ? <String>[]
        : List<String>.from(json["purchasedVideoIds"].map((x) => x.toString()));
    return PurchaseInfo(
      isPurchased: true,
      purchaseType: type,
      purchasedVideoIds: ids,
    );
  }

  Map<String, dynamic> toJson() => {
    "isPurchased": isPurchased,
    "purchaseType": purchaseType.name.toUpperCase(),
    "purchasedVideoIds": purchasedVideoIds,
  };

  bool get hasFullAccess => isPurchased && purchaseType == PurchaseType.course;

  bool hasVideoAccess(String contentId) =>
      hasFullAccess ||
      (isPurchased &&
          purchaseType == PurchaseType.video &&
          purchasedVideoIds.contains(contentId));
}

class DataData {
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
  List<Section>? sections;
  List<Review>? reviews;
  double? averageRating;
  int? totalReviews;
  PurchaseInfo? purchaseInfo;

  DataData({
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
    this.sections,
    this.reviews,
    this.averageRating,
    this.totalReviews,
    this.purchaseInfo,
  });

  factory DataData.fromJson(Map<String, dynamic> json) => DataData(
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
    sections: json["sections"] == null
        ? []
        : List<Section>.from(json["sections"]!.map((x) => Section.fromJson(x))),
    reviews: json["reviews"] == null
        ? []
        : List<Review>.from(json["reviews"]!.map((x) => Review.fromJson(x))),
    averageRating: json["averageRating"]?.toDouble(),
    totalReviews: json["totalReviews"],
    purchaseInfo: json["purchaseInfo"] == null
        ? null
        : PurchaseInfo.fromJson(json["purchaseInfo"]),
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
    "sections": sections == null
        ? []
        : List<dynamic>.from(sections!.map((x) => x.toJson())),
    "reviews": reviews == null
        ? []
        : List<dynamic>.from(reviews!.map((x) => x.toJson())),
    "averageRating": averageRating,
    "totalReviews": totalReviews,
    "purchaseInfo": purchaseInfo?.toJson(),
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
  String? bio;

  Instructor({this.id, this.name, this.avatar, this.title, this.bio});

  factory Instructor.fromJson(Map<String, dynamic> json) => Instructor(
    id: json["id"],
    name: json["name"],
    avatar: json["avatar"],
    title: json["title"],
    bio: json["bio"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "avatar": avatar,
    "title": title,
    "bio": bio,
  };
}

class Review {
  String? id;
  String? userId;
  String? courseId;
  double? rating;
  String? comment;
  DateTime? createdAt;
  DateTime? updatedAt;
  User? user;

  Review({
    this.id,
    this.userId,
    this.courseId,
    this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json["id"],
    userId: json["userId"],
    courseId: json["courseId"],
    rating: json["rating"]?.toDouble(),
    comment: json["comment"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "courseId": courseId,
    "rating": rating,
    "comment": comment,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "user": user?.toJson(),
  };
}

class User {
  String? id;
  String? name;

  User({this.id, this.name});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class Section {
  String? id;
  String? title;
  int? order;
  String? courseId;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Content>? contents;

  Section({
    this.id,
    this.title,
    this.order,
    this.courseId,
    this.createdAt,
    this.updatedAt,
    this.contents,
  });

  factory Section.fromJson(Map<String, dynamic> json) => Section(
    id: json["id"],
    title: json["title"],
    order: json["order"],
    courseId: json["courseId"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    contents: json["contents"] == null
        ? []
        : List<Content>.from(json["contents"]!.map((x) => Content.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "order": order,
    "courseId": courseId,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
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
  bool? hasAccess;
  String? videoUrl;
  String? pdfUrl;

  Content({
    this.id,
    this.title,
    this.type,
    this.order,
    this.duration,
    this.hasAccess,
    this.videoUrl,
    this.pdfUrl,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    id: json["id"],
    title: json["title"],
    type: json["type"],
    order: json["order"],
    duration: json["duration"],
    hasAccess: json["hasAccess"],
    videoUrl: json["videoUrl"],
    pdfUrl: json["pdfUrl"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "type": type,
    "order": order,
    "duration": duration,
    "hasAccess": hasAccess,
    "videoUrl": videoUrl,
    "pdfUrl": pdfUrl,
  };
}
