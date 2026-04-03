// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class CategoryButton extends StatelessWidget {
  final String buttonName;
  bool isSelected;
  void Function()? onPress;
  CategoryButton({
    super.key,
    required this.buttonName,
    this.isSelected = false,
    this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.pad8),
      child: Container(
        height: AppHeight.h124,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.radius5),
        ),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                // ignore: deprecated_member_use
                MaterialStateProperty.all(
                    isSelected ? AppColor.mainScreenButtons : AppColor.offWhiteColor),
          ),
          child: Text(
            buttonName,
            style: TextStyle(
              color: isSelected ? AppColor.whiteColor : AppColor.blackColor,
              fontWeight: FontWeight.bold,
              fontSize: AppTextSize.textSize14,
            ),
          ),
          onPressed: onPress,
        ),
      ),
    );
  }
}
