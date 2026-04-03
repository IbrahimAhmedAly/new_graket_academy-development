// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class AddToBasketButton extends StatelessWidget {
  final void Function()? onTap;
  AddToBasketButton({
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
            height: AppHeight.h60,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.all(Radius.circular(AppRadius.radius25)),
              color: AppColor.buttonColor.withValues(alpha: 0.5),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: AppPadding.pad15,
              ),
              child: Text(
                AppStrings.addToBasket,
                style: TextStyle(
                  color: AppColor.grayColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTextSize.textSize20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
