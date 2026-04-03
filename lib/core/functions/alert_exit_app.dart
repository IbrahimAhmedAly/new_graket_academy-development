
import 'dart:io';

import 'package:get/get.dart';
import '../constants/app_strings.dart';
import '../constants/colors.dart';

Future<bool> alertExitApp() {
  bool exitApp = false ;
  Get.defaultDialog(
      title: AppStrings.exitAlert,
      middleText: AppStrings.doYouWantToExit,
      buttonColor: AppColor.primaryColor,
      cancelTextColor: AppColor.primaryColor,
      confirmTextColor: AppColor.white,
      onCancel: (){
        exitApp = false;
        //Get.back();
      },
      onConfirm: (){
       exit(0);
      },


  );
  return Future.value(exitApp);
}

