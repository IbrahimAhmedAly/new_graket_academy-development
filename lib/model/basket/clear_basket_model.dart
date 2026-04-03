// To parse this JSON data, do
//
//     final clearBasketModel = clearBasketModelFromJson(jsonString);

import 'dart:convert';

ClearBasketModel clearBasketModelFromJson(String str) =>
    ClearBasketModel.fromJson(json.decode(str));

String clearBasketModelToJson(ClearBasketModel data) =>
    json.encode(data.toJson());

class ClearBasketModel {
  bool? success;
  int? statusCode;
  Data? data;
  DateTime? timestamp;

  ClearBasketModel({this.success, this.statusCode, this.data, this.timestamp});

  factory ClearBasketModel.fromJson(Map<String, dynamic> json) =>
      ClearBasketModel(
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

  Data({this.message});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(message: json["message"]);

  Map<String, dynamic> toJson() => {"message": message};
}
