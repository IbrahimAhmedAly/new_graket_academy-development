// To parse this JSON data, do
//
//     final getBasketModel = getBasketModelFromJson(jsonString);

import 'dart:convert';

GetBasketModel getBasketModelFromJson(String str) =>
    GetBasketModel.fromJson(json.decode(str));

String getBasketModelToJson(GetBasketModel data) => json.encode(data.toJson());

class GetBasketModel {
  bool? success;
  int? statusCode;
  GetBasketModelData? data;
  DateTime? timestamp;

  GetBasketModel({this.success, this.statusCode, this.data, this.timestamp});

  factory GetBasketModel.fromJson(Map<String, dynamic> json) => GetBasketModel(
    success: json["success"],
    statusCode: json["statusCode"],
    data: json["data"] == null
        ? null
        : GetBasketModelData.fromJson(json["data"]),
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

class GetBasketModelData {
  String? message;
  DataData? data;

  GetBasketModelData({this.message, this.data});

  factory GetBasketModelData.fromJson(Map<String, dynamic> json) =>
      GetBasketModelData(
        message: json["message"],
        data: json["data"] == null ? null : DataData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class DataData {
  List<dynamic>? items;
  int? itemCount;
  int? totalPrice;
  int? totalDiscountPrice;
  int? savings;

  DataData({
    this.items,
    this.itemCount,
    this.totalPrice,
    this.totalDiscountPrice,
    this.savings,
  });

  factory DataData.fromJson(Map<String, dynamic> json) => DataData(
    items: json["items"] == null
        ? []
        : List<dynamic>.from(json["items"]!.map((x) => x)),
    itemCount: json["itemCount"],
    totalPrice: json["totalPrice"],
    totalDiscountPrice: json["totalDiscountPrice"],
    savings: json["savings"],
  );

  Map<String, dynamic> toJson() => {
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x)),
    "itemCount": itemCount,
    "totalPrice": totalPrice,
    "totalDiscountPrice": totalDiscountPrice,
    "savings": savings,
  };
}
