import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/data_request.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/data/auth_data/login_data.dart';

/// Drives `POST /auth/change-password` for the signed-in user.
///
/// The backend keeps the session alive after a successful change, so this
/// controller never clears the stored tokens and never logs the user out — it
/// only reports success and pops back to Settings.
class ChangePasswordController extends GetxController {
  /// Same rule the sign-up form already enforces — see the
  /// `AuthFieldType.password` branch in
  /// `lib/view/new_widgets/auth_widgets/auth_text_field.dart`.
  static const int minPasswordLength = 6;

  final MyServices myServices = Get.find();
  late final LoginData authData;

  /// Guards against a double tap firing two change-password requests.
  bool isSubmitting = false;
  String? errorMessage;

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  @override
  void onInit() {
    super.onInit();
    final dataRequest = Get.isRegistered<DataRequest>()
        ? Get.find<DataRequest>()
        : Get.put(DataRequest(), permanent: true);
    authData = LoginData(dataRequest);

    currentPasswordController.addListener(_onFieldChanged);
    newPasswordController.addListener(_onFieldChanged);
    confirmPasswordController.addListener(_onFieldChanged);
  }

  @override
  void onClose() {
    currentPasswordController.removeListener(_onFieldChanged);
    newPasswordController.removeListener(_onFieldChanged);
    confirmPasswordController.removeListener(_onFieldChanged);
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// Keeps [allFieldsFilled] fresh and drops a stale error as soon as the user
  /// starts fixing the form.
  void _onFieldChanged() {
    if (errorMessage != null) errorMessage = null;
    update();
  }

  bool get allFieldsFilled =>
      currentPasswordController.text.isNotEmpty &&
      newPasswordController.text.isNotEmpty &&
      confirmPasswordController.text.isNotEmpty;

  bool get canSubmit => allFieldsFilled && !isSubmitting;

  void toggleCurrentPasswordVisibility() {
    obscureCurrentPassword = !obscureCurrentPassword;
    update();
  }

  void toggleNewPasswordVisibility() {
    obscureNewPassword = !obscureNewPassword;
    update();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    update();
  }

  /// Client-side gate. Deliberately does NOT check "new must differ from
  /// current" — the server owns that rule and its Arabic wording is surfaced
  /// verbatim instead of being replaced with a local message.
  ///
  /// Empty fields are not checked here: [canSubmit] already requires all three
  /// to be filled, so the submit button and the keyboard "done" action are both
  /// inert until then.
  String? _validate() {
    final next = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    if (next.length < minPasswordLength) {
      return '${AppStrings.valueCannotBeLessThan.tr} $minPasswordLength';
    }
    if (next != confirm) {
      return AppStrings.passwordNotMatch.tr;
    }
    return null;
  }

  /// Pulls the server's wording out of an error body.
  ///
  /// `DataRequest._parseErrorResponse` flattens every non-2xx response to a
  /// plain `{status, message}` map, so the top-level `message` is the only key
  /// that can ever carry text — the doubly-wrapped `data` / `data.data`
  /// envelope only exists on the success path, which never reaches here.
  String? _serverMessage(dynamic body) {
    if (body is! Map) return null;

    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    return null;
  }

  Future<void> changePassword() async {
    if (isSubmitting) return;

    final validationError = _validate();
    if (validationError != null) {
      errorMessage = validationError;
      update();
      return;
    }

    final token =
        myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
            '';
    if (token.isEmpty) {
      errorMessage = AppStrings.unExpectedError.tr;
      update();
      return;
    }

    isSubmitting = true;
    errorMessage = null;
    update();

    // Defaults cover a throw escaping the transport layer — same class of
    // failure as the status DataRequest reports for its own caught exceptions.
    RequestStatus status = RequestStatus.serverException;
    dynamic body;
    try {
      final response = await authData.changePassword(
        token: token,
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );
      status = response.$1;
      body = response.$2;
    } catch (_) {
      // Keep the defaults above; the shared error branch below renders them.
    } finally {
      // `finally` so the button can never be stranded in its loading state.
      isSubmitting = false;
    }

    // The request runs for up to 30s and the user can leave in the meantime —
    // Android system/gesture back and the iOS edge-swipe both pop this route
    // and dispose the controller. If that happened, the navigator's top route
    // now belongs to a different screen and Get.back() would pop *that*, so
    // bail out before touching navigation, state or the overlay.
    if (isClosed) return;

    if (status == RequestStatus.success) {
      update();

      // The session survives a password change — no logout, no token reset.
      // Settings opens this screen with Get.toNamed, so Get.back() is the
      // matching pop. The snackbar is deferred a frame so its overlay route
      // isn't pushed while the pop is still being scheduled.
      Get.back();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          AppStrings.changePassword.tr,
          AppStrings.passwordChanged.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      });
      return;
    }

    if (status == RequestStatus.offline || status == RequestStatus.noInternet) {
      errorMessage = AppStrings.youAreOffline.tr;
    } else if (status == RequestStatus.serverException) {
      // Transport failure, not a server verdict: the API was unreachable, timed
      // out or answered with something undecodable. `checkInternetFunction()`
      // pings google.com rather than the API, so this is reachable on a device
      // with perfectly good internet. DataRequest fills the body with the
      // developer-facing sentinel {"status": 404, "message": "Server
      // Exception"} — a non-empty string that would otherwise sail past the
      // fallback below and show literal English in an Arabic-first app.
      errorMessage = AppStrings.unExpectedError.tr;
    } else {
      // Genuine server verdict (failed / serverFailure): its wording wins —
      // the API answers in Arabic and those messages are the only ones that
      // tell the user what actually went wrong.
      errorMessage = _serverMessage(body) ?? AppStrings.unExpectedError.tr;
    }
    update();
  }
}
