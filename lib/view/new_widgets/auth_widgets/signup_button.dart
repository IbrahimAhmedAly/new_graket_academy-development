import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/clipping.dart';

class SignupButton extends StatelessWidget {
  final void Function()? onTap;
  const SignupButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipPath(
        clipper: Clipping(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.radius25),
          child: Container(
            height: AppHeight.h80,
            width: 1.sw / 1.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(AppRadius.radius25),
                topRight: Radius.circular(AppRadius.radius25),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 25,
                  color: AppColor.grayColor,
                ),
                BoxShadow(
                  color:AppColor. whiteColor,
                  spreadRadius: -5.0,
                  blurRadius: 25.0,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(left: AppPadding.pad30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.signUp,
                    style: TextStyle(
                      color: AppColor.headerTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppTextSize.textSize24,
                    ),
                  ),
                  Text(
                    AppStrings.forTheFirstTime,
                    style: TextStyle(
                      color: AppColor.headerTextColor,
                      fontWeight: FontWeight.normal,
                      fontSize: AppTextSize.textSize14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
