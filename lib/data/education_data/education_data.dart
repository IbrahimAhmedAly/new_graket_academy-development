import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

/// Public education endpoints — no token needed, the student picks a level
/// and grade before an account exists.
class EducationData {
  final DataRequest dataRequest;
  EducationData(this.dataRequest);

  /// All levels, each with its grades nested
  Future<dynamic> getEducationLevels() async {
    final response = await dataRequest.getData(AppApis.getEducationLevels);
    return response.fold((l) => l, (r) => r);
  }

  /// Grades of a single level (fallback when the nested list is empty)
  Future<dynamic> getGradesByLevel(String levelId) async {
    final response = await dataRequest.getData(
      AppApis.getGradesByLevel(levelId),
    );
    return response.fold((l) => l, (r) => r);
  }
}
