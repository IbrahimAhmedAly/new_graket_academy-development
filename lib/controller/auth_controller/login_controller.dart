import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/data/auth_data/login_data.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';

import '../../core/debug_print.dart';
import '../../core/functions/get_device_serial.dart';
import '../../core/services/services.dart';
import '../../core/class/data_request.dart';

abstract class LoginController extends GetxController {
  void onPressLogin();
  void goToRegisterScreen();
  void goToHomeScreen();
  void goToForgotPasswordScreen();
}

class LoginControllerImpl extends LoginController {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  RequestStatus requestStatus = RequestStatus.none;

  late MyServices myServices;
  String? serial;
  Map<String, dynamic>? userData;

  /// remember me flag
  bool rememberMe = true;

  late LoginData loginData;

  String _normalizeStatus(dynamic status) {
    if (status == null) return "";
    return status.toString().toLowerCase();
  }

  String _stringValue(dynamic value) {
    if (value == null) return "";
    return value is String ? value : value.toString();
  }

  Map<String, dynamic> _extractUserData(Map rawData) {
    final data = rawData['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return Map<String, dynamic>.from(rawData);
  }

  Map<String, dynamic> _mergeUserData(Map rawData) {
    final user = _extractUserData(rawData);
    return {...rawData, ...user};
  }

  String _extractAccessToken(Map rawData) {
    final direct = _stringValue(rawData['accessToken']);
    if (direct.isNotEmpty) return direct;
    final token = _stringValue(rawData['token']);
    if (token.isNotEmpty) return token;
    final data = rawData['data'];
    if (data is Map) {
      final accessToken = _stringValue(
          data['accessToken'] ?? data['token']);
      if (accessToken.isNotEmpty) return accessToken;
      final access = data['access'];
      if (access is Map) {
        final accessToken = _stringValue(access['token']);
        if (accessToken.isNotEmpty) return accessToken;
      }
      final inner = data['data'];
      if (inner is Map) {
        final innerToken =
            _stringValue(inner['accessToken'] ?? inner['token']);
        if (innerToken.isNotEmpty) return innerToken;
        final innerAccess = inner['access'];
        if (innerAccess is Map) {
          return _stringValue(innerAccess['token']);
        }
      }
    }
    return "";
  }

  String _extractVerificationToken(Map rawData) {
    final direct = _stringValue(rawData['verificationToken']);
    if (direct.isNotEmpty) return direct;
    final data = rawData['data'];
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

  String _extractRefreshToken(Map rawData) {
    final direct = _stringValue(rawData['refreshToken']);
    if (direct.isNotEmpty) return direct;
    final data = rawData['data'];
    if (data is Map) {
      final token = _stringValue(data['refreshToken'] ?? data['refresh_token']);
      if (token.isNotEmpty) return token;
      final refresh = data['refresh'];
      if (refresh is Map) {
        final refreshToken = _stringValue(refresh['token']);
        if (refreshToken.isNotEmpty) return refreshToken;
      }
      final inner = data['data'];
      if (inner is Map) {
        final token = _stringValue(inner['refreshToken'] ?? inner['refresh_token']);
        if (token.isNotEmpty) return token;
        final refresh = inner['refresh'];
        if (refresh is Map) {
          return _stringValue(refresh['token']);
        }
      }
    }
    return "";
  }

  bool _needsVerification(Map rawData) {
    final merged = _mergeUserData(rawData);
    final statusString = _normalizeStatus(merged['status']);
    final hasVerificationToken = _stringValue(
            merged['verificationToken'] ?? rawData['verificationToken'])
        .isNotEmpty;
    final userStatus = merged['status'];
    final accessToken = _extractAccessToken(rawData);
    final missingAccessToken = accessToken.isEmpty;

    final statusPending = statusString == 'pending' ||
        statusString == 'inactive' ||
        statusString == '0' ||
        statusString == 'unverified';
    final numericPending = userStatus is num && userStatus == 0;

    return hasVerificationToken ||
        statusPending ||
        numericPending ||
        missingAccessToken;
  }

  @override
  onInit() async {
    myServices = Get.isRegistered<MyServices>()
        ? Get.find<MyServices>()
        : await Get.putAsync(() => MyServices().init(), permanent: true);
    final dataRequest = Get.isRegistered<DataRequest>()
        ? Get.find<DataRequest>()
        : Get.put(DataRequest(), permanent: true);
    loginData = LoginData(dataRequest);
    serial = await getSerial();

    // ✅ Load saved login if exist
    final savedEmail = myServices.sharedPreferences.getString("saved_email");
    final savedPassword =
        myServices.sharedPreferences.getString("saved_password");
    if (savedEmail != null && savedPassword != null) {
      emailTextEditingController.text = savedEmail;
      passwordTextEditingController.text = savedPassword;
      rememberMe = true;
    } else {
      if (kDebugMode) {
        emailTextEditingController.text = "mobtester@gmail.com";
        passwordTextEditingController.text = "123456";
      }
    }

    super.onInit();
  }

  @override
  void onPressLogin() async {
    appPrint(serial);

    requestStatus = RequestStatus.loading;
    update();

    var response = await loginData.postLoginData(
      email: emailTextEditingController.text,
      password: passwordTextEditingController.text,
      serial: serial ?? "",
    );

    requestStatus = response.$1;

    if (requestStatus == RequestStatus.success) {
      final Map<String, dynamic> rawData =
          Map<String, dynamic>.from(response.$2);
      userData = _extractUserData(rawData);

      final extractedToken = _extractVerificationToken(rawData);
      final verificationToken = extractedToken.isNotEmpty
          ? extractedToken
          : _stringValue(userData?['verificationToken']).isNotEmpty
              ? _stringValue(userData?['verificationToken'])
              : myServices.sharedPreferences
                      .getString(AppSharedPrefKeys.verificationTokenKey) ??
                  '';

      /// redirect inactive users to verification screen
      if (_needsVerification(rawData)) {
        if (verificationToken.isNotEmpty) {
          myServices.sharedPreferences
              .setString(AppSharedPrefKeys.verificationTokenKey, verificationToken);
          myServices.sharedPreferences
              .setString('verification_token', verificationToken);
        }

        myServices.sharedPreferences
          ..setBool(AppSharedPrefKeys.savedLoginKey, false)
          ..setString(AppSharedPrefKeys.userEmailKey,
              emailTextEditingController.text);

        if (verificationToken.isEmpty) {
          Get.defaultDialog(
            title: AppStrings.warning,
            content: const Text("Verification token missing. Please sign up again."),
            backgroundColor: Colors.white,
            titleStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            barrierDismissible: false,
            confirmTextColor: Colors.white,
            onConfirm: () => Get.back(),
          );
          update();
          return;
        }

        Get.toNamed(
          AppRoutesNames.signUpVerification,
          arguments: {
            'verificationToken': verificationToken,
            'email': emailTextEditingController.text,
          },
        );
        update();
        return;
      }

      /// save token
      final accessToken = _extractAccessToken(rawData);
      myServices.sharedPreferences
          .setString(AppSharedPrefKeys.userTokenKey, accessToken);
      final refreshToken = _extractRefreshToken(rawData);
      if (refreshToken.isNotEmpty) {
        myServices.sharedPreferences
            .setString(AppSharedPrefKeys.refreshTokenKey, refreshToken);
      }
      saveUserNeededData();

      /// ✅ save email + password only if rememberMe is active
      if (rememberMe) {
        myServices.sharedPreferences
            .setString("saved_email", emailTextEditingController.text);
        myServices.sharedPreferences
            .setString("saved_password", passwordTextEditingController.text);
      } else {
        myServices.sharedPreferences.remove("saved_email");
        myServices.sharedPreferences.remove("saved_password");
      }

      goToHomeScreen();
    } else {
      final error = response.$2;
      final message =
          error is Map ? error['message'] ?? "Unknown Error" : "Unknown Error";
      requestStatus = RequestStatus.none;
      update();
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
        onConfirm: () {
          Get.back();
        },
      );
    }
  }

  /// toggle remember me
  void toggleRememberMe(bool value) {
    rememberMe = value;
    update();
  }

  /// save user needed data
  saveUserNeededData() {
    final data = userData ?? {};
    final fallbackEmail = emailTextEditingController.text.trim();
    final currentName =
        myServices.sharedPreferences.getString(AppSharedPrefKeys.userNameKey) ??
            '';
    final currentEmail =
        myServices.sharedPreferences.getString(AppSharedPrefKeys.userEmailKey) ??
            '';
    final extractedName = _stringValue(
        data['displayName'] ?? data['name'] ?? data['fullName'] ?? data['username']);
    final extractedEmail = _stringValue(data['email'] ?? data['mail']);
    final resolvedName = extractedName.isNotEmpty
        ? extractedName
        : currentName.isNotEmpty
            ? currentName
            : 'Unknown';
    final resolvedEmail = extractedEmail.isNotEmpty
        ? extractedEmail
        : fallbackEmail.isNotEmpty
            ? fallbackEmail
            : currentEmail.isNotEmpty
                ? currentEmail
                : 'Unknown';
    myServices.sharedPreferences.setBool(AppSharedPrefKeys.savedLoginKey, true);
    myServices.sharedPreferences
        .setString(AppSharedPrefKeys.userEmailKey, resolvedEmail);
    myServices.sharedPreferences.setString(
        AppSharedPrefKeys.userIdKey, _stringValue(data['_id'] ?? data['id']));
    myServices.sharedPreferences.setString(
        AppSharedPrefKeys.userNameKey, resolvedName);
    myServices.sharedPreferences
        .setString(AppSharedPrefKeys.userPhoneKey, _stringValue(data['phone']));
    // myServices.sharedPreferences.setString(AppSharedPrefKeys.userImageKey, userModel?.image ?? "");
    // myServices.sharedPreferences.setInt(AppSharedPrefKeys.userStatusKey, userModel?.status ?? 0);
    appPrint("userData will be saved : $userData");
  }

  @override
  void goToRegisterScreen() {
    Get.toNamed(AppRoutesNames.signUpScreen);
  }

  @override
  void goToHomeScreen() {
    Get.offAllNamed(AppRoutesNames.mainScreen);
  }

  @override
  void goToForgotPasswordScreen() {}
}
