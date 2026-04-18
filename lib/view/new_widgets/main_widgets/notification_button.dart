import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutesNames.notificationsScreen);
      },
      child: Container(
        width: AppHeight.h44,
        height: AppHeight.h44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.primaryLight,
        ),
        child: Icon(
          Icons.notifications_none_rounded,
          color: AppColor.primaryColor,
          size: 22,
        ),
      ),
    );
  }
}
