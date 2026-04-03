
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_graket_acadimy/core/constants/image_assets.dart';
import 'package:lottie/lottie.dart';

import '../../constants/app_strings.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
            child: Lottie.asset(AppLottieAssets.loading,
                width: 250.w, height: 250.h)),
        const Center(child: Text(AppStrings.loading)),
      ],
    );
  }
}
