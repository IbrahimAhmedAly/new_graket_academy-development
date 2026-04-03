// To parse this JSON data, do
//
//     final getUnreadCountModel = getUnreadCountModelFromJson(jsonString);

import 'dart:convert';

GetUnreadNotificationsCountModel getUnreadCountModelFromJson(String str) =>
    GetUnreadNotificationsCountModel.fromJson(json.decode(str));

String getUnreadCountModelToJson(GetUnreadNotificationsCountModel data) =>
    json.encode(data.toJson());

class GetUnreadNotificationsCountModel {
  bool? success;
  int? statusCode;
  GetUnreadCountModelData? data;
  DateTime? timestamp;

  GetUnreadNotificationsCountModel({
    this.success,
    this.statusCode,
    this.data,
    this.timestamp,
  });

  factory GetUnreadNotificationsCountModel.fromJson(
    Map<String, dynamic> json,
  ) => GetUnreadNotificationsCountModel(
    success: json["success"],
    statusCode: json["statusCode"],
    data: json["data"] == null
        ? null
        : GetUnreadCountModelData.fromJson(json["data"]),
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

class GetUnreadCountModelData {
  String? message;
  DataData? data;

  GetUnreadCountModelData({this.message, this.data});

  factory GetUnreadCountModelData.fromJson(Map<String, dynamic> json) =>
      GetUnreadCountModelData(
        message: json["message"],
        data: json["data"] == null ? null : DataData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class DataData {
  int? count;

  DataData({this.count});

  factory DataData.fromJson(Map<String, dynamic> json) =>
      DataData(count: json["count"]);

  Map<String, dynamic> toJson() => {"count": count};
}
