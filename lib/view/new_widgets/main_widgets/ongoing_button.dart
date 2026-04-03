// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class OngoingButton extends StatelessWidget {
  int listIndex = 0;
  final void Function()? onTap;
  OngoingButton({
    super.key,
    required this.listIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.centerLeft,
        height: AppHeight.h40,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius25)),
          color: listIndex == 0 ? AppColor.whiteColor : AppColor.myCourseScreenButtons,
          boxShadow: listIndex == 0
              ? []
              : [
                  BoxShadow(
                    blurRadius: 25,
                    color: AppColor.whiteColor,
                  ),
                  BoxShadow(
                    color: AppColor.myCourseScreenButtons,
                    spreadRadius: -5.0,
                    blurRadius: 25.0,
                  ),
                ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: AppPadding.pad20,
          ),
          child: Text(
            AppStrings.ongoing,
            style: TextStyle(
              color: listIndex == 0 ? AppColor.grayColor : AppColor.whiteColor,
              fontWeight: FontWeight.bold,
              fontSize: AppTextSize.textSize14,
            ),
          ),
        ),
      ),
    );
  }
}
