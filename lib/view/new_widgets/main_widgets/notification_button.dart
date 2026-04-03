import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/routing/extention.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //Navigator.pushNamed(context, AppRoutesNames.notificationsScreen);
        context.pushNamed(AppRoutesNames.notificationsScreen);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.mainScreenButtons,
          borderRadius: BorderRadius.circular(AppRadius.radius40),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Icon(
          Icons.notifications_none_rounded,
          color: AppColor.whiteColor,
          size: 40,
        ),
      ),
    );
  }
}
