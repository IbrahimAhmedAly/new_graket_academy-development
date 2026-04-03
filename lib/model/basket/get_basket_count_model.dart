// To parse this JSON data, do
//
//     final getBasketCountModel = getBasketCountModelFromJson(jsonString);

import 'dart:convert';

GetBasketCountModel getBasketCountModelFromJson(String str) =>
    GetBasketCountModel.fromJson(json.decode(str));

String getBasketCountModelToJson(GetBasketCountModel data) =>
    json.encode(data.toJson());

class GetBasketCountModel {
  bool? success;
  int? statusCode;
  GetBasketCountModelData? data;
  DateTime? timestamp;

  GetBasketCountModel({
    this.success,
    this.statusCode,
    this.data,
    this.timestamp,
  });

  factory GetBasketCountModel.fromJson(Map<String, dynamic> json) =>
      GetBasketCountModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : GetBasketCountModelData.fromJson(json["data"]),
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

class GetBasketCountModelData {
  String? message;
  DataData? data;

  GetBasketCountModelData({this.message, this.data});

  factory GetBasketCountModelData.fromJson(Map<String, dynamic> json) =>
      GetBasketCountModelData(
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
