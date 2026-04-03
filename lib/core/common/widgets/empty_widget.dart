import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/constants/image_assets.dart';
import 'package:lottie/lottie.dart';

import '../../constants/app_strings.dart';
import '../../constants/colors.dart';


class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
            child: Lottie.asset(AppLottieAssets.empty,
                width: 200.w, height: 200.h)),
         Center(
            child: Text(
              AppStrings.noItems.tr,
              style: TextStyle(fontSize: 30,color: AppColor.red),
            )),
      ],
    );
  }
}
