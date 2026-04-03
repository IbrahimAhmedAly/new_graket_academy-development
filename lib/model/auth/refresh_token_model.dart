// To parse this JSON data, do
//
//     final refreshTokenModel = refreshTokenModelFromJson(jsonString);

import 'dart:convert';

RefreshTokenModel refreshTokenModelFromJson(String str) =>
    RefreshTokenModel.fromJson(json.decode(str));

String refreshTokenModelToJson(RefreshTokenModel data) =>
    json.encode(data.toJson());

class RefreshTokenModel {
  bool? success;
  int? statusCode;
  Data? data;
  DateTime? timestamp;

  RefreshTokenModel({this.success, this.statusCode, this.data, this.timestamp});

  factory RefreshTokenModel.fromJson(Map<String, dynamic> json) =>
      RefreshTokenModel(
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
  Access? access;

  Data({this.access});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    access: json["access"] == null ? null : Access.fromJson(json["access"]),
  );

  Map<String, dynamic> toJson() => {"access": access?.toJson()};
}

class Access {
  String? token;
  DateTime? expires;

  Access({this.token, this.expires});

  factory Access.fromJson(Map<String, dynamic> json) => Access(
    token: json["token"],
    expires: json["expires"] == null ? null : DateTime.parse(json["expires"]),
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "expires": expires?.toIso8601String(),
  };
}
