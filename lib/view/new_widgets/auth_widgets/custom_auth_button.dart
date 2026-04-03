// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class CustomAuthButton extends StatelessWidget {
 final String name;
  final void Function()? onTap;
  const CustomAuthButton({
    super.key,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: AppHeight.h45,
        width: AppWidth.w150,
        decoration: BoxDecoration(
          color:onTap == null ? AppColor.gray : AppColor.buttonColor,
          borderRadius: BorderRadius.circular(AppRadius.radius15),
          boxShadow: [
            BoxShadow(
              color: AppColor.whiteColor.withOpacity(0.8),
              offset: Offset(-2, -2),
              blurRadius: 2,
              spreadRadius: -2,
            ),
            BoxShadow(
              color:AppColor. blackColor.withOpacity(0.2),
              offset: Offset(5, 5),
              blurRadius: 10,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
