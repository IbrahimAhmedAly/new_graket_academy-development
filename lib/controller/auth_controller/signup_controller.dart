import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';

import '../../core/class/request_status.dart';
import '../../core/functions/get_device_serial.dart';
import '../../data/auth_data/signup_data.dart';
import '../../core/class/data_request.dart';

abstract class SignUpController extends GetxController {
  void onPressSignUp();
  void goToLoginScreen();
  void goToVerificationScreen({String? verificationToken, String? email});
  void goToAgreementScreen();
  void showErrorDialog({required (RequestStatus, Map<String, dynamic>) status});
}

class SignUpControllerImpl extends SignUpController {
  late MyServices myServices;
  String? serial;
  bool isAgreementChecked = false;
  late SignUpData signupData;
  RequestStatus requestStatus = RequestStatus.none;

  Map<String, dynamic> signupDataMap = {};
  String? errorMessage;
  TextEditingController fullNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  bool get allFieldsFilled =>
      fullNameTextEditingController.text.trim().isNotEmpty &&
      emailTextEditingController.text.trim().isNotEmpty &&
      passwordTextEditingController.text.isNotEmpty;

  String _stringValue(dynamic value) {
    if (value == null) return "";
    return value is String ? value : value.toString();
  }

  String _extractVerificationToken(Map raw) {
    final direct = _stringValue(raw['verificationToken']);
    if (direct.isNotEmpty) return direct;
    final data = raw['data'];
    if (data is Map) {
      final token = _stringValue(
          data['verificationToken'] ?? data['verification_token'] ?? data['token']);
      if (token.isNotEmpty) return token;
      final inner = data['data'];
      if (inner is Map) {
        return _stringValue(
            inner['verificationToken'] ?? inner['verification_token'] ?? inner['token']);
      }
    }
    return "";
  }

  @override
  onInit() async {
    myServices = Get.isRegistered<MyServices>()
        ? Get.find<MyServices>()
        : await Get.putAsync(() => MyServices().init(), permanent: true);
    final dataRequest = Get.isRegistered<DataRequest>()
        ? Get.find<DataRequest>()
        : Get.put(DataRequest(), permanent: true);
    signupData = SignUpData(dataRequest);
    serial = await getSerial();

    fullNameTextEditingController.addListener(update);
    emailTextEditingController.addListener(update);
    passwordTextEditingController.addListener(update);

    super.onInit();
  }

  @override
  void onClose() {
    fullNameTextEditingController.removeListener(update);
    emailTextEditingController.removeListener(update);
    passwordTextEditingController.removeListener(update);
    super.onClose();
  }

  @override
  void onPressSignUp() async {
    requestStatus = RequestStatus.loading;
    errorMessage = null;
    update();

    var response = await signupData.postSignUpData(
      email: emailTextEditingController.text,
      password: passwordTextEditingController.text,
      serial: serial ?? "",
      displayedName: fullNameTextEditingController.text,
    );
    requestStatus = response.$1;
    if (requestStatus == RequestStatus.success) {
      signupDataMap = Map<String, dynamic>.from(response.$2);

      /// save verification context for later
      final verificationToken = _extractVerificationToken(signupDataMap);
      myServices.sharedPreferences
        ..setString(AppSharedPrefKeys.verificationTokenKey, verificationToken)
        ..setString(AppSharedPrefKeys.userEmailKey,
            emailTextEditingController.text)
        ..setString(
            AppSharedPrefKeys.userNameKey, fullNameTextEditingController.text)
        ..setBool(AppSharedPrefKeys.savedLoginKey, false)
        ..setString("saved_email", emailTextEditingController.text)
        ..setString("saved_password", passwordTextEditingController.text);
      // keep legacy key in sync for old code paths that may read it
      myServices.sharedPreferences
          .setString('verification_token', verificationToken);
      goToVerificationScreen(
        verificationToken: verificationToken,
        email: emailTextEditingController.text,
      );
    } else {
      final errorResponse = response.$2;
      errorMessage = errorResponse is Map
          ? errorResponse['message']?.toString() ?? "An error occurred"
          : "An error occurred";
      requestStatus = RequestStatus.none;
    }
    update();
  }

  @override
  void goToLoginScreen() {}

  @override
  void goToVerificationScreen({String? verificationToken, String? email}) {
    Get.offAllNamed(
      AppRoutesNames.signUpVerification,
      arguments: {
        if (verificationToken != null) 'verificationToken': verificationToken,
        if (email != null) 'email': email,
      },
    );
  }

  void agreementCheckFun() {
    isAgreementChecked = !isAgreementChecked;
    update();
  }

  @override
  void goToAgreementScreen() {
    // TODO: implement goToAgreementScreen
  }

  @override
  void showErrorDialog({required (RequestStatus, Map<String, dynamic>) status}) {
    errorMessage = status.$2["message"]?.toString() ?? "An error occurred";
    update();
  }
}
