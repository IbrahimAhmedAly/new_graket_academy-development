// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class LoginButton extends StatelessWidget {
  final void Function()? onTap;
  LoginButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            alignment: Alignment.centerLeft,
            height: AppHeight.h80,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.all(Radius.circular(AppRadius.radius25)),
              color: Colors.grey.shade200.withValues(alpha: 0.5),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: AppPadding.pad20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.login,
                    style: TextStyle(
                      color: AppColor.grayColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppTextSize.textSize24,
                    ),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    AppStrings.haveAccount,
                    style: TextStyle(
                      color: AppColor.grayColor,
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
