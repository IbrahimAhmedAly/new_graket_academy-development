import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/enums/notification_type.dart';

class NotifiedItem extends StatelessWidget {
  final String headerName;
  final String subHeaderName;
  final NotificationType notificationType;
  final void Function()? onPress;

  const NotifiedItem({
    super.key,
    required this.headerName,
    required this.subHeaderName,
    required this.notificationType,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final config = _typeConfig(notificationType);

    return GestureDetector(
      onTap: onPress,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.pad24,
          vertical: AppPadding.pad8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon ──
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: config.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.radius12),
              ),
              child: Icon(
                config.icon,
                color: config.color,
                size: 22,
              ),
            ),
            SizedBox(width: AppWidth.w12),

            // ── Content ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headerName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  if (subHeaderName.isNotEmpty) ...[
                    SizedBox(height: AppHeight.h4),
                    Text(
                      subHeaderName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize13,
                        fontWeight: FontWeight.w400,
                        color: AppColor.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _NotificationTypeConfig _typeConfig(NotificationType type) {
    return switch (type) {
      NotificationType.promo => _NotificationTypeConfig(
          icon: Icons.local_offer_outlined,
          color: AppColor.priceColor,
        ),
      NotificationType.reminder => _NotificationTypeConfig(
          icon: Icons.notifications_active_outlined,
          color: AppColor.starColor,
        ),
      NotificationType.newCourse => _NotificationTypeConfig(
          icon: Icons.auto_awesome_outlined,
          color: AppColor.primaryColor,
        ),
      NotificationType.achievement => _NotificationTypeConfig(
          icon: Icons.emoji_events_outlined,
          color: AppColor.greenColor,
        ),
      NotificationType.system => _NotificationTypeConfig(
          icon: Icons.info_outline_rounded,
          color: AppColor.textSecondary,
        ),
    };
  }
}

class _NotificationTypeConfig {
  final IconData icon;
  final Color color;
  const _NotificationTypeConfig({required this.icon, required this.color});
}
