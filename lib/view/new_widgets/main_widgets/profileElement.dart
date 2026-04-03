import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class Profileelement extends StatelessWidget {
  final String elementName;
  final IconData icon;
  final Color iconColor;
  void Function()? onTap;
  Profileelement(
      {super.key,
      required this.elementName,
      required this.icon,
      required this.iconColor,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppHeight.h3),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: AppWidth.w310,
          height: AppHeight.h35,
          decoration: BoxDecoration(
            color: AppColor.whiteColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppRadius.radius10),
            border: Border.all(
              color:AppColor. mainScreenButtons,
              width: 2.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.pad10),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: AppRadius.radius30,
                ),
              ),
              Text(
                elementName,
                style: TextStyle(
                  fontSize: AppTextSize.textSize15,
                  fontWeight: FontWeight.bold,
                  color: AppColor.blackColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
