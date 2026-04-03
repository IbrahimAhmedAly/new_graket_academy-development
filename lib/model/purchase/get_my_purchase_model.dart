// To parse this JSON data, do
//
//     final getMyPurchaseModel = getMyPurchaseModelFromJson(jsonString);

import 'dart:convert';

GetMyPurchaseModel getMyPurchaseModelFromJson(String str) =>
    GetMyPurchaseModel.fromJson(json.decode(str));

String getMyPurchaseModelToJson(GetMyPurchaseModel data) =>
    json.encode(data.toJson());

class GetMyPurchaseModel {
  bool? success;
  int? statusCode;
  Data? data;
  DateTime? timestamp;

  GetMyPurchaseModel({
    this.success,
    this.statusCode,
    this.data,
    this.timestamp,
  });

  factory GetMyPurchaseModel.fromJson(Map<String, dynamic> json) =>
      GetMyPurchaseModel(
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
  String? type;
  String? userId;
  dynamic courseId;
  String? contentId;
  String? purchaseCodeId;
  DateTime? purchasedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic course;

  Datum({
    this.id,
    this.type,
    this.userId,
    this.courseId,
    this.contentId,
    this.purchaseCodeId,
    this.purchasedAt,
    this.createdAt,
    this.updatedAt,
    this.course,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    type: json["type"],
    userId: json["userId"],
    courseId: json["courseId"],
    contentId: json["contentId"],
    purchaseCodeId: json["purchaseCodeId"],
    purchasedAt: json["purchasedAt"] == null
        ? null
        : DateTime.parse(json["purchasedAt"]),
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    course: json["course"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "userId": userId,
    "courseId": courseId,
    "contentId": contentId,
    "purchaseCodeId": purchaseCodeId,
    "purchasedAt": purchasedAt?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "course": course,
  };
}
