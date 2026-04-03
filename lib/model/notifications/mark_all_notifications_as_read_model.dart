// To parse this JSON data, do
//
//     final markAllNotificationsAsReadModel = markAllNotificationsAsReadModelFromJson(jsonString);

import 'dart:convert';

MarkAllNotificationsAsReadModel markAllNotificationsAsReadModelFromJson(
  String str,
) => MarkAllNotificationsAsReadModel.fromJson(json.decode(str));

String markAllNotificationsAsReadModelToJson(
  MarkAllNotificationsAsReadModel data,
) => json.encode(data.toJson());

class MarkAllNotificationsAsReadModel {
  bool? success;
  int? statusCode;
  MarkAllNotificationsAsReadModelData? data;
  DateTime? timestamp;

  MarkAllNotificationsAsReadModel({
    this.success,
    this.statusCode,
    this.data,
    this.timestamp,
  });

  factory MarkAllNotificationsAsReadModel.fromJson(Map<String, dynamic> json) =>
      MarkAllNotificationsAsReadModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : MarkAllNotificationsAsReadModelData.fromJson(json["data"]),
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

class MarkAllNotificationsAsReadModelData {
  String? message;
  DataData? data;

  MarkAllNotificationsAsReadModelData({this.message, this.data});

  factory MarkAllNotificationsAsReadModelData.fromJson(
    Map<String, dynamic> json,
  ) => MarkAllNotificationsAsReadModelData(
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
