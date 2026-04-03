
import 'package:flutter/material.dart';


import '../../constants/app_dimentions.dart';
import '../../constants/app_font.dart';
import '../../constants/colors.dart';

class CustomTitleWidget extends StatelessWidget {
  final String title;
  final double fontSize;
  const CustomTitleWidget({super.key, required this.title, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.symmetric(vertical: AppMargin.margin5),
      child: Text(title,
        style: TextStyle(
            color: AppColor.primaryColor,
            fontWeight: AppFontWeight.bold,
            fontSize: fontSize),
      ),
    );
  }
}
