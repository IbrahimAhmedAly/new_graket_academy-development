// To parse this JSON data, do
//
//     final registerModel = registerModelFromJson(jsonString);

import 'dart:convert';

RegisterModel registerModelFromJson(String str) =>
    RegisterModel.fromJson(json.decode(str));

String registerModelToJson(RegisterModel data) => json.encode(data.toJson());

class RegisterModel {
  final bool? success;
  final int? statusCode;
  final Data? data;
  final DateTime? timestamp;

  RegisterModel({this.success, this.statusCode, this.data, this.timestamp});

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
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
  final String? message;
  final String? verificationToken;
  final String? status;
  final String? code;

  Data({this.message, this.verificationToken, this.status, this.code});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    message: json["message"],
    verificationToken: json["verificationToken"],
    status: json["status"],
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "verificationToken": verificationToken,
    "status": status,
    "code": code,
  };
}
