import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class CustomIndecator extends StatelessWidget {
  final bool isActive;
  const CustomIndecator({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      margin: EdgeInsets.only(right: AppMargin.margin5),
      height: AppHeight.h10,
      width: isActive ? AppWidth.w18 : AppWidth.w10,
      decoration: BoxDecoration(
        color: isActive ? AppColor.buttonColor : Colors.grey,
        borderRadius: BorderRadius.circular(AppRadius.radius100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
    );
  }
}
