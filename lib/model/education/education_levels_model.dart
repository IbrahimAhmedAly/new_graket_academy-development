// Models for the education pickers used during onboarding.
//
// GET /education-levels
//   { success, statusCode, data: { message, data: [ { id, name, order,
//     grades: [ { id, name, order } ] } ] }, timestamp }
//
// GET /education-levels/:id/grades
//   { success, statusCode, data: { message, data: [ { id, name, order,
//     educationLevelId } ] }, timestamp }

class GetEducationLevelsModel {
  final bool? success;
  final int? statusCode;
  final GetEducationLevelsModelData? data;

  GetEducationLevelsModel({this.success, this.statusCode, this.data});

  factory GetEducationLevelsModel.fromJson(Map<String, dynamic> json) =>
      GetEducationLevelsModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : GetEducationLevelsModelData.fromJson(
                Map<String, dynamic>.from(json["data"])),
      );
}

class GetEducationLevelsModelData {
  final String? message;
  final List<EducationLevelDatum> data;

  GetEducationLevelsModelData({this.message, this.data = const []});

  factory GetEducationLevelsModelData.fromJson(Map<String, dynamic> json) {
    final raw = json["data"];
    final list = raw is List
        ? raw
            .whereType<Map>()
            .map((e) =>
                EducationLevelDatum.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <EducationLevelDatum>[];
    return GetEducationLevelsModelData(message: json["message"], data: list);
  }
}

class EducationLevelDatum {
  final String? id;
  final String? name;
  final int? order;

  /// Grades come nested in the levels response, so the picker can move to
  /// step 2 without a second request.
  final List<GradeDatum> grades;

  EducationLevelDatum({
    this.id,
    this.name,
    this.order,
    this.grades = const [],
  });

  factory EducationLevelDatum.fromJson(Map<String, dynamic> json) {
    final raw = json["grades"];
    final list = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => GradeDatum.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <GradeDatum>[];

    return EducationLevelDatum(
      id: json["id"]?.toString(),
      name: json["name"]?.toString(),
      order: json["order"] is int ? json["order"] : null,
      grades: list,
    );
  }
}

class GradeDatum {
  final String? id;
  final String? name;
  final int? order;
  final String? educationLevelId;

  GradeDatum({this.id, this.name, this.order, this.educationLevelId});

  factory GradeDatum.fromJson(Map<String, dynamic> json) => GradeDatum(
        id: json["id"]?.toString(),
        name: json["name"]?.toString(),
        order: json["order"] is int ? json["order"] : null,
        educationLevelId: json["educationLevelId"]?.toString(),
      );
}

class GetGradesModel {
  final bool? success;
  final int? statusCode;
  final GetGradesModelData? data;

  GetGradesModel({this.success, this.statusCode, this.data});

  factory GetGradesModel.fromJson(Map<String, dynamic> json) => GetGradesModel(
        success: json["success"],
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? null
            : GetGradesModelData.fromJson(
                Map<String, dynamic>.from(json["data"])),
      );
}

class GetGradesModelData {
  final String? message;
  final List<GradeDatum> data;

  GetGradesModelData({this.message, this.data = const []});

  factory GetGradesModelData.fromJson(Map<String, dynamic> json) {
    final raw = json["data"];
    final list = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => GradeDatum.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <GradeDatum>[];
    return GetGradesModelData(message: json["message"], data: list);
  }
}
