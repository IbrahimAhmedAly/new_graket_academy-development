import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:new_graket_acadimy/controller/notifications_controller.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/common/widgets/shimmer_loading.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/enums/notification_type.dart';
import 'package:new_graket_acadimy/view/new_widgets/other_widgets/notified_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsController>(
      init: Get.isRegistered<NotificationsController>()
          ? Get.find<NotificationsController>()
          : NotificationsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColor.scaffoldBg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppHeight.h8),

                // ── Header ──
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColor.primaryLight,
                            borderRadius:
                                BorderRadius.circular(AppRadius.radius12),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: AppWidth.w12),
                      Text(
                        AppStrings.notifications,
                        style: TextStyle(
                          fontSize: AppTextSize.textSize20,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppHeight.h20),

                // ── Content ──
                Expanded(
                  child: _buildContent(controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(NotificationsController controller) {
    // Loading
    if (controller.requestStatus == RequestStatus.loading) {
      return const _NotificationsSkeleton();
    }

    // Empty / error state
    if (controller.elements.isEmpty) {
      return _buildEmptyState();
    }

    // Grouped list
    return GroupedListView<Map<String, dynamic>, String>(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: AppPadding.pad40),
      elements: controller.elements,
      groupBy: (element) => element["date"]?.toString() ?? "",
      groupComparator: (value1, value2) => value2.compareTo(value1),
      itemComparator: (item1, item2) => (item1["header"]?.toString() ?? "")
          .compareTo(item2["header"]?.toString() ?? ""),
      order: GroupedListOrder.DESC,
      useStickyGroupSeparators: false,
      groupSeparatorBuilder: (String value) => Padding(
        padding: EdgeInsets.only(
          left: AppPadding.pad24,
          right: AppPadding.pad24,
          top: AppPadding.pad16,
          bottom: AppPadding.pad4,
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: AppTextSize.textSize13,
            fontWeight: FontWeight.w600,
            color: AppColor.textHint,
            letterSpacing: 0.3,
          ),
        ),
      ),
      itemBuilder: (context, element) {
        return NotifiedItem(
          headerName: element["header"]?.toString() ?? "",
          subHeaderName: element["subHeader"]?.toString() ?? "",
          notificationType: element["notificationType"] is NotificationType
              ? element["notificationType"] as NotificationType
              : NotificationType.newCourses,
          onPress: () {},
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppPadding.pad40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColor.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 36,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: AppHeight.h20),
            Text(
              "You're all caught up!",
              style: TextStyle(
                fontSize: AppTextSize.textSize18,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(height: AppHeight.h8),
            Text(
              "No new notifications right now.\nWe'll let you know when something arrives.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTextSize.textSize14,
                fontWeight: FontWeight.w400,
                color: AppColor.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer skeleton ──
class _NotificationsSkeleton extends StatefulWidget {
  const _NotificationsSkeleton();

  @override
  State<_NotificationsSkeleton> createState() => _NotificationsSkeletonState();
}

class _NotificationsSkeletonState extends State<_NotificationsSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildItemSkeleton() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pad24,
        vertical: AppPadding.pad8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 44, height: 44, borderRadius: 12),
          SizedBox(width: AppWidth.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 14),
                SizedBox(height: AppHeight.h8),
                ShimmerBox(width: 180, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Group label skeleton
          Padding(
            padding: EdgeInsets.only(
              left: AppPadding.pad24,
              bottom: AppPadding.pad4,
            ),
            child: ShimmerBox(width: 50, height: 13),
          ),
          _buildItemSkeleton(),
          _buildItemSkeleton(),
          _buildItemSkeleton(),

          SizedBox(height: AppHeight.h16),

          // Second group
          Padding(
            padding: EdgeInsets.only(
              left: AppPadding.pad24,
              bottom: AppPadding.pad4,
            ),
            child: ShimmerBox(width: 70, height: 13),
          ),
          _buildItemSkeleton(),
          _buildItemSkeleton(),
        ],
      ),
    );
  }
}
