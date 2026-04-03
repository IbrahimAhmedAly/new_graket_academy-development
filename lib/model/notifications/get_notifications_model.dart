// To parse this JSON data, do
//
//     final getNotificationsModel = getNotificationsModelFromJson(jsonString);

import 'dart:convert';

GetNotificationsModel getNotificationsModelFromJson(String str) =>
    GetNotificationsModel.fromJson(json.decode(str));

String getNotificationsModelToJson(GetNotificationsModel data) =>
    json.encode(data.toJson());

class GetNotificationsModel {
  bool? success;
  int? statusCode;
  GetNotificationsModelData? data;
  DateTime? timestamp;

  GetNotificationsModel({
    this.success,
    this.statusCode,
    this.data,
    this.timestamp,
  });

  factory GetNotificationsModel.fromJson(Map<String, dynamic> json) =>
      GetNotificationsModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : GetNotificationsModelData.fromJson(json["data"]),
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

class GetNotificationsModelData {
  String? message;
  DataData? data;

  GetNotificationsModelData({this.message, this.data});

  factory GetNotificationsModelData.fromJson(Map<String, dynamic> json) =>
      GetNotificationsModelData(
        message: json["message"],
        data: json["data"] == null ? null : DataData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class DataData {
  List<dynamic>? data;
  Metadata? metadata;
  int? unreadCount;

  DataData({this.data, this.metadata, this.unreadCount});

  factory DataData.fromJson(Map<String, dynamic> json) => DataData(
    data: json["data"] == null
        ? []
        : List<dynamic>.from(json["data"]!.map((x) => x)),
    metadata: json["metadata"] == null
        ? null
        : Metadata.fromJson(json["metadata"]),
    unreadCount: json["unreadCount"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x)),
    "metadata": metadata?.toJson(),
    "unreadCount": unreadCount,
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
