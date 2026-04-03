

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_dimentions.dart';
import '../../constants/colors.dart';

class CustomMaterialButton extends StatelessWidget {
  final String name ;
  final void Function()? onPressed;
  const CustomMaterialButton({Key? key, required this.name, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal:AppPadding.pad20 ),
      margin:  EdgeInsets.only(top: AppMargin.margin16.h),
      child: MaterialButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppWidth.w20)),
        color: AppColor.primaryColor,
        textColor: AppColor.white,
        child: Text(name,
        ),
      ),
    );
  }
}