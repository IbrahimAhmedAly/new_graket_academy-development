// To parse this JSON data, do
//
//     final removeFromBasketModel = removeFromBasketModelFromJson(jsonString);

import 'dart:convert';

RemoveFromBasketModel removeFromBasketModelFromJson(String str) =>
    RemoveFromBasketModel.fromJson(json.decode(str));

String removeFromBasketModelToJson(RemoveFromBasketModel data) =>
    json.encode(data.toJson());

class RemoveFromBasketModel {
  bool? success;
  int? statusCode;
  Data? data;
  DateTime? timestamp;

  RemoveFromBasketModel({
    this.success,
    this.statusCode,
    this.data,
    this.timestamp,
  });

  factory RemoveFromBasketModel.fromJson(Map<String, dynamic> json) =>
      RemoveFromBasketModel(
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
