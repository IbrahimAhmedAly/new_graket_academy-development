// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class RememberForget extends StatelessWidget {
 final void Function(bool?)? onChanged;
 final void Function()? onTap;
 final bool? rememberMeState;
  const RememberForget({
    super.key,
    this.onChanged,
    this.onTap,
    required this.rememberMeState,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.all(AppPadding.pad15),
          child: Row(
            children: [
              Checkbox(
                value: rememberMeState,
                onChanged: onChanged,
              ),
              Text(
                AppStrings.rememberMe,
                style: TextStyle(
                  fontSize: AppTextSize.textSize12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(AppPadding.pad15),
          child: GestureDetector(
            onTap:onTap,
            child: Text(
              AppStrings.forgetPassword,
              style: TextStyle(
                color: AppColor.headerTextColor,
                fontSize: AppTextSize.textSize13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }
}
