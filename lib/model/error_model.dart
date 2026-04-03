// To parse this JSON data, do
//
//     final errorModel = errorModelFromJson(jsonString);

import 'dart:convert';

ErrorModel errorModelFromJson(String str) =>
    ErrorModel.fromJson(json.decode(str));

String errorModelToJson(ErrorModel data) => json.encode(data.toJson());

class ErrorModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final String? error;
  final List<Error>? errors;
  final DateTime? timestamp;
  final String? path;

  ErrorModel({
    this.success,
    this.statusCode,
    this.message,
    this.error,
    this.errors,
    this.timestamp,
    this.path,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) => ErrorModel(
    success: json["success"],
    statusCode: json["statusCode"],
    message: json["message"],
    error: json["error"],
    errors: json["errors"] == null
        ? []
        : List<Error>.from(json["errors"]!.map((x) => Error.fromJson(x))),
    timestamp: json["timestamp"] == null
        ? null
        : DateTime.parse(json["timestamp"]),
    path: json["path"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "statusCode": statusCode,
    "message": message,
    "error": error,
    "errors": errors == null
        ? []
        : List<dynamic>.from(errors!.map((x) => x.toJson())),
    "timestamp": timestamp?.toIso8601String(),
    "path": path,
  };
}

class Error {
  final String? field;
  final String? message;
  final String? value;

  Error({this.field, this.message, this.value});

  factory Error.fromJson(Map<String, dynamic> json) => Error(
    field: json["field"],
    message: json["message"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "field": field,
    "message": message,
    "value": value,
  };
}
