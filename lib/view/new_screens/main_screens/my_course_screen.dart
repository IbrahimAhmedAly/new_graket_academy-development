import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/my_courses_controller.dart';
import 'package:new_graket_acadimy/model/my_courses/get_my_courses_model.dart';
import 'package:new_graket_acadimy/core/class/handling_view_data.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/main_widgets/my_course_item.dart';
import 'package:new_graket_acadimy/view/new_widgets/main_widgets/notification_button.dart';
import 'package:new_graket_acadimy/view/new_widgets/main_widgets/ongoing_button.dart';
import 'package:new_graket_acadimy/view/new_widgets/main_widgets/pass_button.dart';
import 'package:new_graket_acadimy/view/new_widgets/main_widgets/saved_screen.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';

class MyCourseScreen extends StatefulWidget {
  const MyCourseScreen({super.key});

  @override
  State<MyCourseScreen> createState() => _MyCourseScreenState();
}

class _MyCourseScreenState extends State<MyCourseScreen> {
  final PageController _pageController = PageController();
  int listIndex = 0;

  Widget _buildList(
    List<Datum> items,
    MyCoursesController controller,
    String status,
    ScrollController scrollController,
  ) {
    if (items.isEmpty) {
      return _buildEmptyState(status);
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(bottom: AppPadding.pad20),
      itemCount: items.length + (controller.hasMore(status) ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom
        if (index >= items.length) {
          return _buildLoadingMoreIndicator();
        }

        final item = items[index];
        final course = item.course;
        final courseName = course?.title ?? "Course";
        final courseImage = course?.thumbnail ?? AssetsPath.courseImage_1;
        final progress = (item.progress ?? 0).toDouble();
        final rate = (course?.averageRating ?? 0).toDouble();
        final isSaved = (item.status ?? '').toString().toLowerCase() == 'saved';
        final courseId = course?.id ?? '';

        return MyCourseItem(
          courseName: courseName,
          courseImage: courseImage,
          percentage: progress,
          rate: rate,
          isSaved: isSaved,
          onTap: () {
            if (courseId.isEmpty) return;
            Get.toNamed(
              AppRoutesNames.exploreCourseScreen,
              arguments: {'courseId': courseId},
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppPadding.pad20),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.savedIconColor),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String message;
    IconData icon;

    switch (status) {
      case 'ONGOING':
        message = "No ongoing courses yet.\nStart learning today!";
        icon = Icons.school_outlined;
        break;
      case 'COMPLETED':
        message = "No completed courses yet.\nKeep learning to see your achievements!";
        icon = Icons.emoji_events_outlined;
        break;
      case 'SAVED':
        message = "No saved courses.\nSave courses to access them later!";
        icon = Icons.bookmark_border;
        break;
      default:
        message = "No courses available";
        icon = Icons.info_outline;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColor.grayColor.withValues(alpha: 0.3),
          ),
          SizedBox(height: AppHeight.h20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTextSize.textSize14,
              color: AppColor.grayColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyCoursesController>(
      init: Get.isRegistered<MyCoursesController>()
          ? Get.find<MyCoursesController>()
          : MyCoursesController(),
      builder: (controller) {
        return HandlingViewData(
          requestStatus: controller.requestStatus,
          widget: RefreshIndicator(
            onRefresh: controller.onRefresh,
            color: AppColor.savedIconColor,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.pad20,
                vertical: AppPadding.pad25,
              ),
              color: Colors.transparent,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.myCourses,
                            style: TextStyle(
                              fontSize: AppTextSize.textSize32,
                              fontWeight: FontWeight.bold,
                              color: AppColor.grayColor,
                            ),
                          ),
                          Text(
                            AppStrings.learnWithGrakeT,
                            style: TextStyle(
                              fontSize: AppTextSize.textSize13,
                              fontWeight: FontWeight.bold,
                              color: AppColor.grayColor,
                            ),
                          ),
                        ],
                      ),
                      NotificationButton(),
                    ],
                  ),
                  SizedBox(height: AppHeight.h20),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      OngoingButton(
                        onTap: () {
                          listIndex = 0;
                          _pageController.animateToPage(
                            0,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                          setState(() {});
                        },
                        listIndex: listIndex,
                      ),
                      PassButton(
                        onTap: () {
                          listIndex = 1;
                          _pageController.animateToPage(
                            1,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                          setState(() {});
                        },
                        listIndex: listIndex,
                      ),
                      SavedScreen(
                        onTap: () {
                          listIndex = 2;
                          _pageController.animateToPage(
                            2,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                          setState(() {});
                        },
                        listIndex: listIndex,
                      ),
                    ],
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (value) {
                        setState(() {
                          listIndex = value;
                        });
                      },
                      children: [
                        _buildList(
                          controller.ongoingCourses,
                          controller,
                          'ONGOING',
                          controller.ongoingScrollController,
                        ),
                        _buildList(
                          controller.completedCourses,
                          controller,
                          'COMPLETED',
                          controller.completedScrollController,
                        ),
                        _buildList(
                          controller.savedCourses,
                          controller,
                          'SAVED',
                          controller.savedScrollController,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
