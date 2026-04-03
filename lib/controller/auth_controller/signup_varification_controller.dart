import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/data/auth_data/varification_data.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';

import '../../core/debug_print.dart';
import '../../core/services/services.dart';
import '../../core/class/data_request.dart';

abstract class SignupVarificationController extends GetxController {
  void onPressVerify();
  void onPressSendAgain();
  void goToHomeScreen();
  void onCodeChanged(String code);
}

class SignupVarificationControllerImpl extends SignupVarificationController {
  TextEditingController emailTextEditingController = TextEditingController();
  String verificationCode = '';

  RequestStatus requestStatus = RequestStatus.none;

  late MyServices myServices;
  Map<String, dynamic>? userData;
  String? verificationToken;
  String? email;
  late final VarificationData varificationData;

  String _stringValue(dynamic value) {
    if (value == null) return '';
    return value is String ? value : value.toString();
  }

  String _extractAccessToken(Map data) {
    final direct = _stringValue(data['accessToken']);
    if (direct.isNotEmpty) return direct;
    final token = _stringValue(data['token']);
    if (token.isNotEmpty) return token;
    final inner = data['data'];
    if (inner is Map) {
      final t = _stringValue(inner['accessToken'] ?? inner['token']);
      if (t.isNotEmpty) return t;
      final access = inner['access'];
      if (access is Map) {
        return _stringValue(access['token']);
      }
    }
    final access = data['access'];
    if (access is Map) {
      return _stringValue(access['token']);
    }
    return '';
  }

  String _extractRefreshToken(Map data) {
    final direct = _stringValue(data['refreshToken'] ?? data['refresh_token']);
    if (direct.isNotEmpty) return direct;
    final refresh = data['refresh'];
    if (refresh is Map) {
      final token = _stringValue(refresh['token']);
      if (token.isNotEmpty) return token;
    }
    final inner = data['data'];
    if (inner is Map) {
      final t = _stringValue(inner['refreshToken'] ?? inner['refresh_token']);
      if (t.isNotEmpty) return t;
      final innerRefresh = inner['refresh'];
      if (innerRefresh is Map) {
        return _stringValue(innerRefresh['token']);
      }
    }
    return '';
  }

  @override
  onInit() async {
    myServices = Get.isRegistered<MyServices>()
        ? Get.find<MyServices>()
        : await Get.putAsync(() => MyServices().init(), permanent: true);
    final dataRequest = Get.isRegistered<DataRequest>()
        ? Get.find<DataRequest>()
        : Get.put(DataRequest(), permanent: true);
    varificationData = VarificationData(dataRequest);
    verificationToken = Get.arguments?['verificationToken'] ??
        myServices.sharedPreferences
            .getString(AppSharedPrefKeys.verificationTokenKey);
    email = Get.arguments?['email'] ??
        myServices.sharedPreferences.getString(AppSharedPrefKeys.userEmailKey);

    if (email != null) {
      emailTextEditingController.text = email!;
    }
    super.onInit();
  }

  @override
  void onPressSendAgain() async {
    Get.snackbar(
      "Verification",
      "If you didn't receive a code, please check your email again.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// save user needed data
  saveUserNeededData() {
    appPrint("userData will be saved : $userData");
  }

  @override
  void goToHomeScreen() {
    Get.offAllNamed(AppRoutesNames.mainScreen);
  }

  @override
  void onPressVerify() async {
    if (verificationCode.length < 6) {
      Get.snackbar(
        AppStrings.warning,
        "Please enter the verification code.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (verificationToken == null || verificationToken!.isEmpty) {
      Get.snackbar(
        AppStrings.warning,
        "Verification token missing. Please sign up again.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    requestStatus = RequestStatus.loading;
    update();

    final response = await varificationData.postVarificationCode(
      verificationToken: verificationToken!,
      code: verificationCode,
    );
    requestStatus = response.$1;

    if (requestStatus == RequestStatus.success) {
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(response.$2);
      userData = data;

      final accessToken = _extractAccessToken(data);
      final refreshToken = _extractRefreshToken(data);
      myServices.sharedPreferences
        ..setString(AppSharedPrefKeys.userTokenKey, accessToken)
        ..setBool(AppSharedPrefKeys.savedLoginKey, true);
      if (refreshToken.isNotEmpty) {
        myServices.sharedPreferences
            .setString(AppSharedPrefKeys.refreshTokenKey, refreshToken);
      }

      if (email?.isNotEmpty == true) {
        myServices.sharedPreferences
            .setString(AppSharedPrefKeys.userEmailKey, email!);
      }
      myServices.sharedPreferences.remove(AppSharedPrefKeys.verificationTokenKey);
      myServices.sharedPreferences.remove('verification_token');

      goToHomeScreen();
    } else {
      final error = response.$2;
      final message = error is Map
          ? error['message'] ?? "Verification failed"
          : "Verification failed";
      Get.defaultDialog(
        title: AppStrings.warning,
        content: Text(message),
        backgroundColor: Colors.white,
        titleStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        barrierDismissible: false,
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    }
    update();
  }

  @override
  void onCodeChanged(String code) {
    verificationCode = code;
    update();
  }
}
