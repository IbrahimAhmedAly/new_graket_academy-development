// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/enums/notification_type.dart';

class NotifiedItem extends StatelessWidget {
  final String headerName;
  final String subHeaderName;
  final NotificationType notificationType;
  void Function()? onPress;
  NotifiedItem(
      {super.key,
      required this.headerName,
      required this.subHeaderName,
      required this.notificationType,
      required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppPadding.pad10),
      child: TextButton(
        style: ButtonStyle(
          fixedSize:
              WidgetStateProperty.all<Size>(Size(AppWidth.w335, AppHeight.h60)),
          backgroundColor: WidgetStateProperty.all<Color>(
              // ignore: deprecated_member_use
              AppColor. whiteColor.withOpacity(0.2)),
          foregroundColor: WidgetStateProperty.all<Color>(
              // ignore: deprecated_member_use
              AppColor.whiteColor.withOpacity(0.2)),
          padding: WidgetStateProperty.all<EdgeInsets>(
              EdgeInsets.all(AppPadding.pad10)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radius15),
              side:
                  // ignore: deprecated_member_use
                  BorderSide(color: AppColor.blackColor.withOpacity(0.2)),
            ),
          ),
        ),
        onPressed: onPress,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.pad6),
              child: SvgPicture.asset(getNotificationType(notificationType)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerName,
                  style: TextStyle(
                    fontSize: AppTextSize.textSize14,
                    fontWeight: FontWeight.bold,
                    color: AppColor.blackColor,
                  ),
                ),
                Text(
                  subHeaderName,
                  style: TextStyle(
                    fontSize: AppTextSize.textSize12,
                    fontWeight: FontWeight.normal,
                    color: AppColor.blackColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getNotificationType(NotificationType notificationType) {
    return switch (notificationType) {
      NotificationType.discount => AssetsPath.discount,
      NotificationType.finishCourses => AssetsPath.finishCourses,
      NotificationType.newCourses => AssetsPath.newCourses,
      NotificationType.worning => AssetsPath.worning
    };
  }
}
