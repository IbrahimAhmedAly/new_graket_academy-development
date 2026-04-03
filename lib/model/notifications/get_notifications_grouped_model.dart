// To parse this JSON data, do
//
//     final getNotificationsGroupedModel = getNotificationsGroupedModelFromJson(jsonString);

import 'dart:convert';

GetNotificationsGroupedModel getNotificationsGroupedModelFromJson(String str) =>
    GetNotificationsGroupedModel.fromJson(json.decode(str));

String getNotificationsGroupedModelToJson(GetNotificationsGroupedModel data) =>
    json.encode(data.toJson());

class GetNotificationsGroupedModel {
  bool? success;
  int? statusCode;
  GetNotificationsGroupedModelData? data;
  DateTime? timestamp;

  GetNotificationsGroupedModel({
    this.success,
    this.statusCode,
    this.data,
    this.timestamp,
  });

  factory GetNotificationsGroupedModel.fromJson(Map<String, dynamic> json) =>
      GetNotificationsGroupedModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : GetNotificationsGroupedModelData.fromJson(json["data"]),
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

class GetNotificationsGroupedModelData {
  String? message;
  DataData? data;

  GetNotificationsGroupedModelData({this.message, this.data});

  factory GetNotificationsGroupedModelData.fromJson(
    Map<String, dynamic> json,
  ) => GetNotificationsGroupedModelData(
    message: json["message"],
    data: json["data"] == null ? null : DataData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class DataData {
  List<dynamic>? groups;
  int? unreadCount;
  Metadata? metadata;

  DataData({this.groups, this.unreadCount, this.metadata});

  factory DataData.fromJson(Map<String, dynamic> json) => DataData(
    groups: json["groups"] == null
        ? []
        : List<dynamic>.from(json["groups"]!.map((x) => x)),
    unreadCount: json["unreadCount"],
    metadata: json["metadata"] == null
        ? null
        : Metadata.fromJson(json["metadata"]),
  );

  Map<String, dynamic> toJson() => {
    "groups": groups == null ? [] : List<dynamic>.from(groups!.map((x) => x)),
    "unreadCount": unreadCount,
    "metadata": metadata?.toJson(),
  };
}

class Metadata {
  int? currentPage;
  int? itemsPerPage;
  int? totalItems;
  int? totalPages;

  Metadata({
    this.currentPage,
    this.itemsPerPage,
    this.totalItems,
    this.totalPages,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    currentPage: json["currentPage"],
    itemsPerPage: json["itemsPerPage"],
    totalItems: json["totalItems"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "itemsPerPage": itemsPerPage,
    "totalItems": totalItems,
    "totalPages": totalPages,
  };
}
