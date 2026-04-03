import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/clipping.dart'
    show Clipping;

class SavedScreen extends StatelessWidget {
  final void Function()? onTap;
  int listIndex;
  SavedScreen({
    super.key,
    required this.onTap,
    required this.listIndex,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipPath(
        clipper: Clipping(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.radius25),
          child: Container(
            height: AppHeight.h40,
            width: 1.sw / 2.7,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(AppRadius.radius25),
                topRight: Radius.circular(AppRadius.radius25),
              ),
              color: listIndex == 2
                  ? AppColor.whiteColor
                  :AppColor. myCourseScreenButtons.withOpacity(0.4),
              boxShadow: listIndex == 2
                  ? []
                  : [
                      BoxShadow(
                        blurRadius: 25,
                        color: AppColor.offWhiteColor.withValues(alpha: 0.5),
                      ),
                      BoxShadow(
                        color: AppColor.myCourseScreenButtons,
                        spreadRadius: -5.0,
                        blurRadius: 25.0,
                      ),
                    ],
            ),
            child: Padding(
              padding: EdgeInsets.only(left: AppPadding.pad60),
              child: Text(
                AppStrings.saved,
                style: TextStyle(
                  color: listIndex == 2 ? AppColor.grayColor : AppColor.whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTextSize.textSize14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
