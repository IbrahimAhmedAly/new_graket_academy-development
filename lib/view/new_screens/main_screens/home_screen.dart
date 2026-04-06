import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/home_controller/home_controller.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/common/widgets/shimmer_loading.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/model/courses/get_all_courses_model.dart'
    as course_model;
import 'package:new_graket_acadimy/view/new_widgets/other_widgets/categorized_course_item.dart';
import 'package:new_graket_acadimy/view/new_widgets/main_widgets/notification_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Helpers ──
  String _stringValue(dynamic value, {String fallback = ""}) {
    if (value == null) return fallback;
    final result = value is String ? value : value.toString();
    return result.isEmpty ? fallback : result;
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) return "0 h";
    if (minutes < 60) return "${minutes} m";
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins == 0 ? "${hours} h" : "${hours} h ${mins} m";
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ────────────────────────────────────────────────
  //  Section header: title on the left, pill "View more" on the right
  // ────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onViewMore,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppPadding.pad16,
        right: AppPadding.pad16,
        top: AppPadding.pad24,
        bottom: AppPadding.pad12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppTextSize.textSize18,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          GestureDetector(
            onTap: onViewMore,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.viewMore,
                  style: TextStyle(
                    fontSize: AppTextSize.textSize13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primaryColor,
                  ),
                ),
                SizedBox(width: AppWidth.w4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColor.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────
  //  Horizontal scrolling course list
  // ────────────────────────────────────────────────
  Widget _buildHorizontalCourseList({
    required List<course_model.Datum> courses,
    required void Function(String courseId) onTapCourse,
  }) {
    if (courses.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppPadding.pad20,
          horizontal: AppPadding.pad16,
        ),
        child: Center(
          child: Text(
            "No courses yet",
            style: TextStyle(
              fontSize: AppTextSize.textSize14,
              color: AppColor.textHint,
            ),
          ),
        ),
      );
    }

    final itemCount = courses.length > 6 ? 6 : courses.length;
    final listHeight = CategorizedCourseItem.cardHeight(context);

    return SizedBox(
      height: listHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: AppPadding.pad16,
          right: AppPadding.pad4,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final course = courses[index];
          return CategorizedCourseItem(
            courseName: _stringValue(course.title, fallback: "Course"),
            courseImage: _stringValue(course.thumbnail),
            price: course.price ?? 0,
            discountPrice: course.discountPrice,
            rate: course.averageRating ?? 0,
            totalTime: _formatDuration(course.totalDuration ?? 0),
            onTap: () {
              final courseId = _stringValue(course.id);
              if (courseId.isEmpty) return;
              onTapCourse(courseId);
            },
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────────
  //  Build
  // ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      assignId: true,
      builder: (controller) {
        // Show shimmer skeleton while loading
        if (controller.requestStatus == RequestStatus.loading ||
            controller.requestStatus == RequestStatus.none) {
          return const HomeShimmerSkeleton();
        }

        // Error / offline / no data states — keep original handling
        if (controller.requestStatus != RequestStatus.success) {
          return _buildErrorState(controller.requestStatus);
        }

        // ── Success state ──
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top safe area ──
              SizedBox(
                  height:
                      MediaQuery.of(context).padding.top + AppHeight.h16),

              // ── Header ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.pad16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, ${controller.userName} \u{1F44B}",
                            style: TextStyle(
                              fontSize: AppTextSize.textSize24,
                              fontWeight: FontWeight.w800,
                              color: AppColor.textPrimary,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: AppHeight.h4),
                          Text(
                            AppStrings.learnWithGrakeT,
                            style: TextStyle(
                              fontSize: AppTextSize.textSize14,
                              fontWeight: FontWeight.w400,
                              color: AppColor.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const NotificationButton(),
                  ],
                ),
              ),

              // ── All Courses ──
              _buildSectionHeader(
                title: "All Courses",
                onViewMore: () {
                  Get.toNamed(
                    AppRoutesNames.coursesScreen,
                    arguments: {'type': 'all'},
                  );
                },
              ),
              _buildHorizontalCourseList(
                courses: controller.allCourses,
                onTapCourse: (courseId) {
                  Get.toNamed(AppRoutesNames.exploreCourseScreen,
                      arguments: {"courseId": courseId});
                },
              ),

              // ── Popular ──
              _buildSectionHeader(
                title: "Popular",
                onViewMore: controller.goToPopularScreen,
              ),
              _buildHorizontalCourseList(
                courses: controller.popularCourses,
                onTapCourse: (courseId) {
                  Get.toNamed(AppRoutesNames.exploreCourseScreen,
                      arguments: {"courseId": courseId});
                },
              ),

              // ── Recommended ──
              _buildSectionHeader(
                title: "Recommended",
                onViewMore: controller.goToRecommendedScreen,
              ),
              _buildHorizontalCourseList(
                courses: controller.recommendedCourses,
                onTapCourse: (courseId) {
                  Get.toNamed(AppRoutesNames.exploreCourseScreen,
                      arguments: {"courseId": courseId});
                },
              ),

              // ── Bottom safe area for nav bar ──
              SizedBox(height: AppHeight.h120),
            ],
          ),
        );
      },
    );
  }

  // ── Error / offline fallback (reuses Lottie from original) ──
  Widget _buildErrorState(RequestStatus status) {
    String message;
    IconData icon;
    switch (status) {
      case RequestStatus.offline:
      case RequestStatus.noInternet:
        message = AppStrings.youAreOffline.tr;
        icon = Icons.wifi_off_rounded;
        break;
      case RequestStatus.serverFailure:
      case RequestStatus.serverException:
        message = AppStrings.serverError.tr;
        icon = Icons.cloud_off_rounded;
        break;
      case RequestStatus.failed:
        message = AppStrings.noData.tr;
        icon = Icons.inbox_rounded;
        break;
      default:
        message = AppStrings.serverError.tr;
        icon = Icons.error_outline_rounded;
    }

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
              child: Icon(icon, size: 40, color: AppColor.primaryColor),
            ),
            SizedBox(height: AppHeight.h20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTextSize.textSize16,
                fontWeight: FontWeight.w500,
                color: AppColor.textSecondary,
              ),
            ),
            SizedBox(height: AppHeight.h20),
            GestureDetector(
              onTap: () {
                final controller = Get.find<HomeController>();
                controller.getHomeData();
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pad24,
                  vertical: AppPadding.pad12,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(AppRadius.radius25),
                ),
                child: Text(
                  "Try Again",
                  style: TextStyle(
                    fontSize: AppTextSize.textSize14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
