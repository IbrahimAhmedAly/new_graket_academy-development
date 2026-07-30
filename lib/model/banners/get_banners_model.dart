// Model for GET /banners
// Envelope: { success, statusCode, data: { message, data: [ ... ] }, timestamp }

class GetBannersModel {
  final bool? success;
  final int? statusCode;
  final GetBannersModelData? data;

  GetBannersModel({this.success, this.statusCode, this.data});

  factory GetBannersModel.fromJson(Map<String, dynamic> json) =>
      GetBannersModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : GetBannersModelData.fromJson(
                Map<String, dynamic>.from(json["data"])),
      );
}

class GetBannersModelData {
  final String? message;
  final List<BannerDatum> data;

  GetBannersModelData({this.message, this.data = const []});

  factory GetBannersModelData.fromJson(Map<String, dynamic> json) {
    final raw = json["data"];
    final list = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => BannerDatum.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <BannerDatum>[];
    return GetBannersModelData(message: json["message"], data: list);
  }
}

class BannerDatum {
  final String? id;
  final String? image;
  final bool? isActive;

  BannerDatum({this.id, this.image, this.isActive});

  factory BannerDatum.fromJson(Map<String, dynamic> json) => BannerDatum(
        id: json["id"]?.toString(),
        image: json["image"]?.toString(),
        isActive: json["isActive"] is bool ? json["isActive"] : null,
      );
}
