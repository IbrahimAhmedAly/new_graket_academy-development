import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/image_assets.dart';
import 'package:lottie/lottie.dart';


import '../../routing/app_routes.dart';
import '../common/widgets/loading_widget.dart';
import '../constants/app_strings.dart';
import '../constants/colors.dart';

class HandlingRequestData extends StatelessWidget {
  final RequestStatus requestStatus;
  final Widget widget;

  const HandlingRequestData(
      {super.key, required this.requestStatus, required this.widget});

  @override
  Widget build(BuildContext context) {
    return requestStatus == RequestStatus.loading
        ? const LoadingWidget()
        : requestStatus == RequestStatus.offline
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Lottie.asset(AppLottieAssets.offline,
                        width: 200.w, height: 200.h),
                  ),
                   Center(
                      child: Text(
                    AppStrings.youAreOffline.tr,
                    style: const TextStyle(fontSize: 20),
                  )),
                  MaterialButton(
                      color: AppColor.primaryColor,
                      onPressed: () {
                        requestStatus == RequestStatus.none;
                        Get.offAndToNamed(AppRoutesNames.loginScreen);
                      },
                      child:  Text(AppStrings.refresh.tr,style: TextStyle(
                          color: AppColor.white,
                          fontWeight: FontWeight.bold
                      ),),
                  ),
                ],
              )
            : requestStatus == RequestStatus.serverFailure
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: Lottie.asset(AppLottieAssets.error,
                              width: 200.w, height: 200.h)),
                       Center(
                          child: Text(
                        AppStrings.serverError.tr,
                        style: const TextStyle(fontSize: 20),
                      )),
                      MaterialButton(
                        color: AppColor.primaryColor,
                          onPressed: () {
                            requestStatus == RequestStatus.none;
                            Get.offAndToNamed(AppRoutesNames.loginScreen);
                          },
                          child:  Text(AppStrings.refresh.tr,style: TextStyle(
                            color: AppColor.white,
                            fontWeight: FontWeight.bold
                          ),)),
                    ],
                  )
                : widget;
  }
}
