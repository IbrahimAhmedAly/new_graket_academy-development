import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:lottie/lottie.dart';

import '../constants/app_strings.dart';
import '../constants/image_assets.dart';

/// TODO ADD LOADING AND ERROR SCREENS AS LOTTIE FILE ANIME. @AHMED YOUSSEF
class HandlingViewData extends StatelessWidget {
  final RequestStatus requestStatus;
  final Widget widget;

  const HandlingViewData(
      {super.key, required this.requestStatus, required this.widget});

  @override
  Widget build(BuildContext context) {
    return requestStatus == RequestStatus.loading
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Lottie.asset(AppLottieAssets.loading,
                      width: 200.w, height: 200.h)),
              const Center(child: Text(AppStrings.loading)),
            ],
          )
        : requestStatus == RequestStatus.offline
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: Lottie.asset(AppLottieAssets.offline,
                          width: 200.w, height: 200.h)),
                   Center(
                      child: Text(
                    AppStrings.youAreOffline.tr,
                    style: const TextStyle(fontSize: 20),
                  )),
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
                    ],
                  )
                : requestStatus == RequestStatus.failed
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                              child: Lottie.asset(AppLottieAssets.empty,
                                  width: 200.w, height: 200.h)),
                           Center(
                              child: Text(
                            AppStrings.noData.tr,
                            style: const TextStyle(fontSize: 20),
                          )),
                        ],
                      )
                    : requestStatus == RequestStatus.noInternet
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                  child: Lottie.asset(AppLottieAssets.error,
                                      width: 200.w, height: 200.h)),
                               Center(
                                  child: Text(
                                AppStrings.noInternet.tr,
                                style: const TextStyle(fontSize: 20),
                              )),
                            ],
                          )
                        : widget;
  }
}
