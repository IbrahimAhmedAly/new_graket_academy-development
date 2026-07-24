/// Response model for the public legal-document endpoints (`/privacy`, `/terms`).
///
/// Backend envelope shape:
/// {
///   "success": true,
///   "statusCode": 200,
///   "data": {
///     "message": "...",
///     "data": { "type": "PRIVACY_POLICY", "content": "...html...", "updatedAt": "..." }
///   },
///   "timestamp": "..."
/// }
class LegalDocumentModel {
  bool? success;
  int? statusCode;
  LegalDocumentBody? data;
  DateTime? timestamp;

  LegalDocumentModel({
    this.success,
    this.statusCode,
    this.data,
    this.timestamp,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) =>
      LegalDocumentModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : LegalDocumentBody.fromJson(
                Map<String, dynamic>.from(json["data"])),
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.tryParse(json["timestamp"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "statusCode": statusCode,
        "data": data?.toJson(),
        "timestamp": timestamp?.toIso8601String(),
      };
}

class LegalDocumentBody {
  String? message;
  LegalDocumentData? data;

  LegalDocumentBody({this.message, this.data});

  factory LegalDocumentBody.fromJson(Map<String, dynamic> json) =>
      LegalDocumentBody(
        message: json["message"],
        data: json["data"] == null
            ? null
            : LegalDocumentData.fromJson(
                Map<String, dynamic>.from(json["data"])),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class LegalDocumentData {
  String? type;
  String? content;
  DateTime? updatedAt;

  LegalDocumentData({this.type, this.content, this.updatedAt});

  factory LegalDocumentData.fromJson(Map<String, dynamic> json) =>
      LegalDocumentData(
        type: json["type"],
        content: json["content"],
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.tryParse(json["updatedAt"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "content": content,
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
