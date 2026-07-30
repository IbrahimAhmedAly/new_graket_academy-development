import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/notifications_controller.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsController>(
      init: Get.isRegistered<NotificationsController>()
          ? Get.find<NotificationsController>()
          : NotificationsController(),
      builder: (controller) {
        final count = controller.unreadCount;
        return GestureDetector(
          onTap: () async {
            await Get.toNamed(AppRoutesNames.notificationsScreen);
            // Refresh the badge after returning from the list.
            controller.refreshUnreadCount();
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
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
              if (count > 0)
                PositionedDirectional(
                  end: -2,
                  top: -2,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: AppColor.errorColor,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: AppColor.primaryLight, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count > 99 ? "99+" : "$count",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
