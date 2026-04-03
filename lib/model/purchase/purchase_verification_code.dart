// To parse this JSON data, do
//
//     final purchaseVerificationCode = purchaseVerificationCodeFromJson(jsonString);

import 'dart:convert';

PurchaseVerificationCode purchaseVerificationCodeFromJson(String str) =>
    PurchaseVerificationCode.fromJson(json.decode(str));

String purchaseVerificationCodeToJson(PurchaseVerificationCode data) =>
    json.encode(data.toJson());

class PurchaseVerificationCode {
  bool? success;
  int? statusCode;
  PurchaseVerificationCodeData? data;
  DateTime? timestamp;

  PurchaseVerificationCode({
    this.success,
    this.statusCode,
    this.data,
    this.timestamp,
  });

  factory PurchaseVerificationCode.fromJson(Map<String, dynamic> json) =>
      PurchaseVerificationCode(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : PurchaseVerificationCodeData.fromJson(json["data"]),
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

class PurchaseVerificationCodeData {
  String? message;
  DataData? data;

  PurchaseVerificationCodeData({this.message, this.data});

  factory PurchaseVerificationCodeData.fromJson(Map<String, dynamic> json) =>
      PurchaseVerificationCodeData(
        message: json["message"],
        data: json["data"] == null ? null : DataData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class DataData {
  bool? valid;
  String? type;
  Item? item;
  dynamic isExpired;
  bool? isFullyUsed;
  int? remainingUses;

  DataData({
    this.valid,
    this.type,
    this.item,
    this.isExpired,
    this.isFullyUsed,
    this.remainingUses,
  });

  factory DataData.fromJson(Map<String, dynamic> json) => DataData(
    valid: json["valid"],
    type: json["type"],
    item: json["item"] == null ? null : Item.fromJson(json["item"]),
    isExpired: json["isExpired"],
    isFullyUsed: json["isFullyUsed"],
    remainingUses: json["remainingUses"],
  );

  Map<String, dynamic> toJson() => {
    "valid": valid,
    "type": type,
    "item": item?.toJson(),
    "isExpired": isExpired,
    "isFullyUsed": isFullyUsed,
    "remainingUses": remainingUses,
  };
}

class Item {
  String? id;
  String? title;
  String? slug;
  String? thumbnail;
  double? price;
  dynamic discountPrice;

  Item({
    this.id,
    this.title,
    this.slug,
    this.thumbnail,
    this.price,
    this.discountPrice,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"],
    title: json["title"],
    slug: json["slug"],
    thumbnail: json["thumbnail"],
    price: json["price"]?.toDouble(),
    discountPrice: json["discountPrice"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "slug": slug,
    "thumbnail": thumbnail,
    "price": price,
    "discountPrice": discountPrice,
  };
}
