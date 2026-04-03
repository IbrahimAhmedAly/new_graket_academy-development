import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';

import '../../data/course_details_data/enter_code_data.dart';

class CodeControllerImpl extends GetxController {
  EnterCodeData codeData = EnterCodeData(Get.find());
  MyServices myServices = Get.find();
  RequestStatus requestStatus = RequestStatus.loading;
  final TextEditingController codeTextController = TextEditingController();
  bool isLoading = false;
  String? errorMessage = "";
  String userToken = "";

  @override
  void onInit() {
    userToken = myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ?? "";
    super.onInit();
  }
  @override
  void onClose() {
    codeTextController.dispose();
    super.onClose();
  }

  void onCodeChanged(String value) {
    errorMessage = null;
    update();
  }

  Future<void> sendCode() async {


    final code = codeTextController.text.trim();
    if (code.isEmpty) {
      errorMessage = 'Code cannot be empty.';
      update();
      return;
    }
    isLoading = true;
    errorMessage = null;
    update();
    try {
      var response = await codeData.postCourseCode(
          code: code,
          userToken: userToken);

      requestStatus = response.$1;
      if(requestStatus == RequestStatus.success){
        Get.snackbar('Success', 'Code accepted successfully.',
            snackPosition: SnackPosition.BOTTOM);
        Get.toNamed(AppRoutesNames.myCoursesScreen);
      } else {
        errorMessage = response.$2['message']?.toString() ?? 'An error occurred.';
        print(errorMessage);
      }

    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      update();
    }
  }
}

