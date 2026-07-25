import 'package:get/get.dart';

import '../../core/class/data_request.dart';
import '../../core/class/request_status.dart';
import '../../data/education_data/education_data.dart';
import '../../model/education/education_levels_model.dart';
import '../../routing/app_routes.dart';

/// Drives the two onboarding steps that precede registration:
///   step 1 — pick an education level
///   step 2 — pick a grade within that level
///
/// The chosen ids are handed to the sign-up screen, which sends them to
/// POST /auth/register.
class EducationOnboardingController extends GetxController {
  late EducationData educationData;

  RequestStatus requestStatus = RequestStatus.none;
  String? errorMessage;

  List<EducationLevelDatum> levels = [];

  EducationLevelDatum? selectedLevel;
  GradeDatum? selectedGrade;

  /// Grades of the selected level. Populated from the nested list, and
  /// fetched separately only if the level arrived without one.
  List<GradeDatum> grades = [];
  bool isLoadingGrades = false;

  bool get canContinueFromLevel => selectedLevel?.id != null;
  bool get canContinueFromGrade => selectedGrade?.id != null;

  @override
  void onInit() {
    final dataRequest = Get.isRegistered<DataRequest>()
        ? Get.find<DataRequest>()
        : Get.put(DataRequest(), permanent: true);
    educationData = EducationData(dataRequest);
    getEducationLevels();
    super.onInit();
  }

  Future<void> getEducationLevels() async {
    requestStatus = RequestStatus.loading;
    errorMessage = null;
    update();

    try {
      final response = await educationData.getEducationLevels();
      final status = response.$1 as RequestStatus;

      if (status == RequestStatus.success) {
        final model = GetEducationLevelsModel.fromJson(
          Map<String, dynamic>.from(response.$2 as Map),
        );
        levels = model.data?.data ?? [];
        requestStatus =
            levels.isEmpty ? RequestStatus.failed : RequestStatus.success;
        if (levels.isEmpty) {
          errorMessage = 'No education levels available yet';
        }
      } else {
        requestStatus = RequestStatus.failed;
        final body = response.$2;
        errorMessage = body is Map
            ? body['message']?.toString() ?? "Couldn't load education levels"
            : "Couldn't load education levels";
      }
    } catch (_) {
      requestStatus = RequestStatus.failed;
      errorMessage = "Couldn't load education levels";
    }

    update();
  }

  void selectLevel(EducationLevelDatum level) {
    // Switching level invalidates a grade chosen under the previous one
    if (selectedLevel?.id != level.id) {
      selectedGrade = null;
    }
    selectedLevel = level;
    grades = level.grades;
    update();
  }

  void selectGrade(GradeDatum grade) {
    selectedGrade = grade;
    update();
  }

  /// Move to step 2, loading grades on demand if they weren't nested.
  Future<void> goToGradeStep() async {
    final level = selectedLevel;
    if (level?.id == null) return;

    if (grades.isEmpty) {
      isLoadingGrades = true;
      update();
      await _fetchGradesForLevel(level!.id!);
      isLoadingGrades = false;
      update();
    }

    Get.toNamed(AppRoutesNames.selectGradeScreen);
  }

  Future<void> _fetchGradesForLevel(String levelId) async {
    try {
      final response = await educationData.getGradesByLevel(levelId);
      if ((response.$1 as RequestStatus) == RequestStatus.success) {
        final model = GetGradesModel.fromJson(
          Map<String, dynamic>.from(response.$2 as Map),
        );
        grades = model.data?.data ?? [];
      }
    } catch (_) {
      // Non-fatal: the grade step shows its own empty state
    }
  }

  /// Hand the selection to the sign-up screen.
  void goToSignUp() {
    if (!canContinueFromGrade) return;

    Get.toNamed(
      AppRoutesNames.signUpScreen,
      arguments: {
        'educationLevelId': selectedLevel!.id,
        'gradeId': selectedGrade!.id,
        'educationLevelName': selectedLevel!.name,
        'gradeName': selectedGrade!.name,
      },
    );
  }
}
