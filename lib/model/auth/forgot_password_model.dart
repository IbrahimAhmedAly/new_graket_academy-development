// To parse this JSON data, do
//
//     final forgotPasswordModel = forgotPasswordModelFromJson(jsonString);

import 'dart:convert';

ForgotPasswordModel forgotPasswordModelFromJson(String str) =>
    ForgotPasswordModel.fromJson(json.decode(str));

String forgotPasswordModelToJson(ForgotPasswordModel data) =>
    json.encode(data.toJson());

class ForgotPasswordModel {
  bool? success;
  int? statusCode;
  Data? data;
  DateTime? timestamp;

  ForgotPasswordModel({
    this.success,
    this.statusCode,
    this.data,
    this.timestamp,
  });

  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordModel(
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
  String? verificationToken;
  String? code;

  Data({this.message, this.verificationToken, this.code});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    message: json["message"],
    verificationToken: json["verificationToken"],
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "verificationToken": verificationToken,
    "code": code,
  };
}
