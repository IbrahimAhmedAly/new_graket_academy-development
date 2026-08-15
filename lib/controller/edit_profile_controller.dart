import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/class/data_request.dart';
import '../core/class/request_status.dart';
import '../core/constants/app_strings.dart';
import '../core/services/services.dart';
import '../data/education_data/education_data.dart';
import '../data/profile_data/profile_data.dart';
import '../model/education/education_levels_model.dart';
import 'profile_controller.dart';

/// Drives the edit-profile form.
///
/// Loads GET /user/me, keeps the editable fields, and submits **only** the
/// fields the student actually changed through PATCH /user/me — the backend
/// rejects an empty body, so a no-op save never leaves the client.
class EditProfileController extends GetxController {
  /// Mirrors the server DTO — `@Length(2, 60)` on `name`. Enforced here because
  /// a DTO rejection comes back as HTTP 400 whose top-level `message` is the
  /// generic i18n string "Validation Failed"; the real per-field message only
  /// lives in the `errors[]` array the transport layer discards, so the user
  /// would otherwise be told nothing useful.
  static const int minNameLength = 2;
  static const int maxNameLength = 60;

  late final ProfileData profileData;
  late final EducationData educationData;
  final MyServices myServices = Get.find();

  // ── Editable fields ──
  final TextEditingController nameController = TextEditingController();
  final TextEditingController parentPhoneController = TextEditingController();

  /// Read-only, shown for context only — the API does not accept an email change.
  String email = '';

  // ── Initial load ──
  RequestStatus requestStatus = RequestStatus.none;
  String? loadErrorMessage;

  // ── Save ──
  bool isSaving = false;

  /// Server / submit-level failure, surfaced verbatim (the API answers in Arabic).
  String? errorMessage;
  String? nameError;
  String? parentPhoneError;

  // ── Education pickers (same data layer as the onboarding steps) ──
  List<EducationLevelDatum> levels = [];
  List<GradeDatum> grades = [];
  bool isLoadingLevels = false;
  bool isLoadingGrades = false;
  EducationLevelDatum? selectedLevel;
  GradeDatum? selectedGrade;

  // ── Baseline used to diff what changed ──
  String _originalName = '';
  String _originalParentPhone = '';
  String? _originalLevelId;

  /// The whole grade, not just its id: coming back to the originally loaded
  /// level has to restore the grade object so the picker can render its name
  /// again — see [selectLevel].
  GradeDatum? _originalGrade;

  /// Mirrors [canSave] so keystrokes only rebuild the form when the button
  /// actually flips state.
  bool _lastCanSave = false;

  String get _token =>
      myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
          '';

  String? get _originalGradeId => _originalGrade?.id;

  bool get levelChanged => selectedLevel?.id != _originalLevelId;

  bool get gradeChanged => selectedGrade?.id != _originalGradeId;

  bool get hasChanges =>
      nameController.text.trim() != _originalName.trim() ||
      parentPhoneController.text.trim() != _originalParentPhone.trim() ||
      levelChanged ||
      gradeChanged;

  /// A grade belongs to exactly one level, and the server rejects a pair that
  /// doesn't match. So the moment the level changes the old grade is void and
  /// the student has to pick a new one before the form can be submitted.
  bool get mustRepickGrade => levelChanged && selectedGrade?.id == null;

  bool get canSave =>
      !isSaving &&
      requestStatus == RequestStatus.success &&
      hasChanges &&
      !mustRepickGrade;

  @override
  void onInit() {
    final dataRequest = Get.isRegistered<DataRequest>()
        ? Get.find<DataRequest>()
        : Get.put(DataRequest(), permanent: true);
    profileData = ProfileData(dataRequest);
    educationData = EducationData(dataRequest);

    nameController.addListener(_onFieldChanged);
    parentPhoneController.addListener(_onFieldChanged);

    loadProfile();
    super.onInit();
  }

  @override
  void onClose() {
    nameController
      ..removeListener(_onFieldChanged)
      ..dispose();
    parentPhoneController
      ..removeListener(_onFieldChanged)
      ..dispose();
    super.onClose();
  }

  /// Drops every stale error — the field ones *and* the submit/server box — as
  /// soon as the student starts fixing the form. Leaving [errorMessage] up
  /// would keep a red notice about a save that no longer describes the form.
  void _onFieldChanged() {
    final hadError =
        nameError != null || parentPhoneError != null || errorMessage != null;
    if (hadError) {
      nameError = null;
      parentPhoneError = null;
      errorMessage = null;
    }
    final can = canSave;
    if (can != _lastCanSave || hadError) {
      _lastCanSave = can;
      update();
    }
  }

  // ─────────────────────────────── Load ───────────────────────────────

  Future<void> loadProfile() async {
    final token = _token;
    if (token.isEmpty) {
      requestStatus = RequestStatus.failed;
      loadErrorMessage = AppStrings.loginAgainToEditProfile.tr;
      update();
      return;
    }

    requestStatus = RequestStatus.loading;
    loadErrorMessage = null;
    update();

    // Defaults cover a throw escaping the transport layer — the same class of
    // failure as the status DataRequest reports for its own caught exceptions.
    RequestStatus status = RequestStatus.serverException;
    dynamic raw;
    try {
      final response = await profileData.getMe(token: token);
      status = response.$1 as RequestStatus;
      raw = response.$2;
    } catch (_) {
      // Keep the defaults above; the error branch below renders them.
    }

    // The student can leave while the GET is in flight; popping deletes this
    // controller and disposes the text controllers, so _applyPayload below
    // would write to a disposed TextEditingController.
    if (isClosed) return;

    if (status != RequestStatus.success || raw is! Map) {
      requestStatus = RequestStatus.failed;
      loadErrorMessage = _failureMessage(
        status,
        raw,
        AppStrings.couldNotLoadProfile.tr,
      );
      update();
      return;
    }

    _applyPayload(payloadOf(Map<String, dynamic>.from(raw)));
    requestStatus = RequestStatus.success;
    _lastCanSave = false;
    update();

    await loadLevels();
  }

  /// The double envelope the API always answers with:
  /// `{ success, statusCode, data: { message, data: <payload> }, timestamp }`.
  /// Falls back gracefully if a layer is missing.
  Map<String, dynamic> payloadOf(Map<String, dynamic> raw) {
    final data = raw['data'];
    if (data is Map) {
      final inner = data['data'];
      if (inner is Map) return Map<String, dynamic>.from(inner);
      return Map<String, dynamic>.from(data);
    }
    return raw;
  }

  /// Pulls the human-readable message out of a response or an error map.
  /// The server message lives at `data.message`; `DataRequest` failures put a
  /// flat `message` at the top level; Nest validation errors send a list.
  String? serverMessageOf(dynamic body) {
    if (body is! Map) return null;

    String? read(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        final joined = value.map((e) => e.toString()).join('\n').trim();
        return joined.isEmpty ? null : joined;
      }
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    final data = body['data'];
    if (data is Map) {
      final nested = read(data['message']);
      if (nested != null) return nested;
    }
    return read(body['message']);
  }

  /// Turns a failed request into something an Arabic-first user can read.
  ///
  /// `offline` / `noInternet` / `serverException` are sentinels DataRequest
  /// invents for transport problems, and it fills their bodies with
  /// developer-facing English ("No Internet Connection", "Server Exception")
  /// that must never be shown. Every other status is a genuine server verdict,
  /// and its own wording — the API answers in Arabic — wins over [fallback].
  String _failureMessage(RequestStatus status, dynamic body, String fallback) {
    if (status == RequestStatus.offline || status == RequestStatus.noInternet) {
      return AppStrings.youAreOffline.tr;
    }
    if (status == RequestStatus.serverException) {
      return AppStrings.unExpectedError.tr;
    }
    return serverMessageOf(body) ?? fallback;
  }

  void _applyPayload(Map<String, dynamic> payload) {
    email = payload['email']?.toString() ?? '';

    final name = payload['name']?.toString() ?? '';
    final parentPhone = payload['parentPhone']?.toString() ?? '';
    nameController.text = name;
    parentPhoneController.text = parentPhone;
    _originalName = name;
    _originalParentPhone = parentPhone;

    final levelJson = payload['educationLevel'];
    selectedLevel = levelJson is Map
        ? EducationLevelDatum.fromJson(Map<String, dynamic>.from(levelJson))
        : null;

    final gradeJson = payload['grade'];
    selectedGrade = gradeJson is Map
        ? GradeDatum.fromJson(Map<String, dynamic>.from(gradeJson))
        : null;

    _originalLevelId = selectedLevel?.id;
    _originalGrade = selectedGrade;
  }

  // ──────────────────────── Education pickers ────────────────────────

  Future<void> loadLevels() async {
    if (isLoadingLevels) return;
    isLoadingLevels = true;
    update();

    try {
      final response = await educationData.getEducationLevels();
      if ((response.$1 as RequestStatus) == RequestStatus.success) {
        final model = GetEducationLevelsModel.fromJson(
          Map<String, dynamic>.from(response.$2 as Map),
        );
        levels = model.data?.data ?? [];

        // Re-bind the level that came back on the profile to the fetched
        // instance so we also get its nested grades for the second picker.
        final match = _levelById(selectedLevel?.id);
        if (match != null) {
          selectedLevel = match;
          if (grades.isEmpty) grades = match.grades;
        }
      }
    } catch (_) {
      // Non-fatal: the picker shows its own empty state and can be retried.
    }

    if (isClosed) return;

    isLoadingLevels = false;
    update();

    if (grades.isEmpty) {
      await _loadGradesForLevel(selectedLevel?.id);
    }
  }

  /// Called before the grade sheet opens — the nested list is usually enough,
  /// this only covers a level that arrived without one.
  Future<void> ensureGradesLoaded() async {
    if (grades.isNotEmpty || isLoadingGrades) return;
    await _loadGradesForLevel(selectedLevel?.id);
  }

  Future<void> _loadGradesForLevel(String? levelId) async {
    if (levelId == null || levelId.isEmpty) return;

    isLoadingGrades = true;
    update();

    try {
      final response = await educationData.getGradesByLevel(levelId);
      if ((response.$1 as RequestStatus) == RequestStatus.success) {
        final model = GetGradesModel.fromJson(
          Map<String, dynamic>.from(response.$2 as Map),
        );
        grades = model.data?.data ?? [];
      }
    } catch (_) {
      // Non-fatal: the picker shows its own empty state.
    }

    if (isClosed) return;

    isLoadingGrades = false;
    _lastCanSave = canSave;
    update();
  }

  EducationLevelDatum? _levelById(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final level in levels) {
      if (level.id == id) return level;
    }
    return null;
  }

  void selectLevel(EducationLevelDatum level) {
    if (selectedLevel?.id == level.id) return;

    selectedLevel = level;
    if (level.id != null && level.id == _originalLevelId) {
      // Back on the level the profile was loaded with. Restoring its grade is
      // what makes the L1 → L2 → L1 round-trip a true no-op: leaving the grade
      // null would light up Save (gradeChanged) while changedFields() stayed
      // empty and mustRepickGrade stayed false — a lit button that can only
      // answer "nothing to update", over a Grade field lying about a value the
      // server still holds.
      selectedGrade = _originalGrade;
    } else {
      // Switching level voids the grade — the API refuses a gradeId that lives
      // under a different educationLevelId, so both must be re-sent as a pair.
      selectedGrade = null;
    }
    grades = level.grades;
    errorMessage = null;
    _lastCanSave = canSave;
    update();

    if (grades.isEmpty) {
      _loadGradesForLevel(level.id);
    }
  }

  void selectGrade(GradeDatum grade) {
    selectedGrade = grade;
    errorMessage = null;
    _lastCanSave = canSave;
    update();
  }

  // ─────────────────────────────── Save ───────────────────────────────

  bool _validate() {
    nameError = null;
    parentPhoneError = null;

    final name = nameController.text.trim();
    if (name.isEmpty) {
      nameError = AppStrings.fullNameRequired.tr;
    } else if (name.length < minNameLength) {
      nameError = '${AppStrings.valueCannotBeLessThan.tr} $minNameLength';
    } else if (name.length > maxNameLength) {
      nameError = '${AppStrings.valueCannotBeMoreThan.tr} $maxNameLength';
    }

    // Only what the student actually touched. This regex is stricter than
    // whatever wrote the stored value, so validating an untouched parentPhone
    // would let a pre-existing malformed number block an unrelated name change
    // — and the phone isn't even part of that request body.
    final phone = parentPhoneController.text.trim();
    if (phone != _originalParentPhone.trim() && phone.isNotEmpty) {
      final compact = phone.replaceAll(RegExp(r'[\s\-()]'), '');
      if (!RegExp(r'^\+?\d{8,15}$').hasMatch(compact)) {
        parentPhoneError = AppStrings.notValidPhoneNum.tr;
      }
    }

    return nameError == null && parentPhoneError == null;
  }

  /// Only what the student actually touched. Level and grade always travel
  /// together so the server can validate the pair.
  Map<String, dynamic> changedFields() {
    final body = <String, dynamic>{};

    final name = nameController.text.trim();
    if (name != _originalName.trim()) body['name'] = name;

    final phone = parentPhoneController.text.trim();
    if (phone != _originalParentPhone.trim()) body['parentPhone'] = phone;

    if (levelChanged) {
      body['educationLevelId'] = selectedLevel?.id;
      body['gradeId'] = selectedGrade?.id;
    } else if (gradeChanged && selectedGrade?.id != null) {
      body['gradeId'] = selectedGrade!.id;
    }

    body.removeWhere((_, value) => value == null);
    return body;
  }

  Future<void> save() async {
    if (isSaving) return;

    if (!_validate()) {
      update();
      return;
    }

    if (mustRepickGrade) {
      errorMessage = AppStrings.pickGradeForNewLevel.tr;
      update();
      return;
    }

    final body = changedFields();
    if (body.isEmpty) {
      // The API rejects an empty body — nothing to send means nothing to do.
      errorMessage = AppStrings.nothingToUpdate.tr;
      update();
      return;
    }

    final token = _token;
    if (token.isEmpty) {
      errorMessage = AppStrings.loginAgainToEditProfile.tr;
      update();
      return;
    }

    isSaving = true;
    errorMessage = null;
    update();

    // Defaults cover a throw escaping the transport layer — the same class of
    // failure as the status DataRequest reports for its own caught exceptions.
    RequestStatus status = RequestStatus.serverException;
    dynamic raw;
    try {
      final response = await profileData.updateMe(token: token, body: body);
      status = response.$1 as RequestStatus;
      raw = response.$2;
    } catch (_) {
      // Keep the defaults above; the error branch below renders them.
    }

    // The PATCH runs for up to 30s and the student can leave in the meantime.
    // The screen's GetBuilder is the creator of this controller, so popping
    // deletes it: onClose() disposes nameController and the route is gone. Any
    // work below would then either write to a disposed TextEditingController
    // (_applyPayload) or pop whatever screen is now on top (Get.back). Bail out
    // before touching state, the text controllers, navigation or the overlay.
    if (isClosed) return;

    // Cleared before _applyPayload so a throw in there can never strand the
    // Save button in its loading state.
    isSaving = false;

    if (status != RequestStatus.success) {
      errorMessage = _failureMessage(
        status,
        raw,
        AppStrings.couldNotSaveChanges.tr,
      );
      update();
      return;
    }

    // The name the server just accepted — `_originalName` still holds the
    // pre-edit one until _applyPayload reseeds it, and it stays stale when the
    // response body isn't the expected map.
    final submittedName = body['name'] as String?;

    // PATCH answers with the same payload as GET — reseed the baseline from it
    // so a second save diffs against what the server really stored.
    if (raw is Map) {
      _applyPayload(payloadOf(Map<String, dynamic>.from(raw)));
    }
    _persistNameLocally(submittedName);

    _lastCanSave = false;
    update();

    // Keep the profile tab in sync — but only if the student has actually
    // opened it. `isRegistered` alone is vacuous here: injection.dart registers
    // ProfileController with `Get.lazyPut(fenix: true)`, which puts the key in
    // the map up front, so `Get.find` would *create* the controller and its
    // onInit would fire a fetch this user never asked for. `isPrepared` is true
    // exactly while that lazy factory is still uninstantiated.
    if (Get.isRegistered<ProfileController>() &&
        !Get.isPrepared<ProfileController>()) {
      Get.find<ProfileController>().refreshProfile();
    }

    // This is the only refresh path: Settings opens this screen with a bare
    // `Get.toNamed`, so nothing awaits a pop result (ProfileController's
    // `openEditProfile` was deleted rather than left as a second, latent fetch).
    // The snackbar is deferred a frame so its overlay route isn't pushed while
    // the pop is still being scheduled.
    Get.back();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        AppStrings.editProfile.tr,
        AppStrings.profileUpdated.tr,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    });
  }

  /// The profile screen falls back to SharedPreferences before its own fetch
  /// lands, so the cached name has to follow the edit.
  ///
  /// [submittedName] is the value that actually went out in the PATCH body, or
  /// null when the name wasn't part of this save — in which case the (possibly
  /// re-seeded) baseline is still the right thing to cache.
  void _persistNameLocally(String? submittedName) {
    final prefs = myServices.sharedPreferences;
    final name = (submittedName ?? _originalName).trim();
    if (name.isNotEmpty) {
      prefs.setString(AppSharedPrefKeys.userNameKey, name);
    }
    if (email.isNotEmpty) {
      prefs.setString(AppSharedPrefKeys.userEmailKey, email);
    }
  }
}
