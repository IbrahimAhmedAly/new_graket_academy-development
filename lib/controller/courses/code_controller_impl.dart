import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/controller/home_controller/course_details_controller.dart';

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

  /// Returns true on success so the screen can pop itself with its own
  /// BuildContext (more reliable than Get.back() in this app's setup).
  Future<bool> sendCode() async {
    final code = codeTextController.text.trim();
    if (code.isEmpty) {
      errorMessage = 'Code cannot be empty.';
      update();
      return false;
    }
    isLoading = true;
    errorMessage = null;
    update();
    try {
      var response = await codeData.postCourseCode(
          code: code,
          userToken: userToken);

      requestStatus = response.$1;
      if (requestStatus == RequestStatus.success) {
        Get.snackbar('Success', 'Code accepted successfully.',
            snackPosition: SnackPosition.BOTTOM);

        final body = response.$2 as Map?;
        final purchase = (body?['data'] as Map?)?['purchase'] as Map?;
        final purchasedCourseId = purchase?['courseId']?.toString() ?? '';

        codeTextController.clear();

        // Refresh course details so the ExploreCourseScreen below this one
        // shows "Continue Learning" instead of "Start Learning"/"Enter Code"
        // without needing an app restart.
        if (Get.isRegistered<CourseDetailsControllerImp>()) {
          final detailsController = Get.find<CourseDetailsControllerImp>();
          if (purchasedCourseId.isNotEmpty &&
              detailsController.courseId.isEmpty) {
            detailsController.courseId = purchasedCourseId;
          }
          await detailsController.getCourseDetails();
        }

        isLoading = false;
        update();
        return true;
      } else {
        errorMessage =
            response.$2['message']?.toString() ?? 'An error occurred.';
        print(errorMessage);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      update();
    }
    return false;
  }
}

