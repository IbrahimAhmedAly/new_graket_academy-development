import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/home_controller/home_controller.dart';
import 'package:new_graket_acadimy/core/class/handling_view_data.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
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

  Widget _buildCoursesGrid({
    required List<course_model.Datum> courses,
    required void Function(String courseId) onTapCourse,
  }) {
    final itemCount = courses.length > 4 ? 4 : courses.length;
    if (itemCount == 0) {
      return Center(child: Text("No courses"));
    }
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppWidth.w5,
        crossAxisSpacing: AppWidth.w5,
        childAspectRatio: AppWidth.w170 / AppHeight.h150,
      ),
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final course = courses[index];
        final courseName = _stringValue(
          course.title,
          fallback: "Course",
        );
        final courseImage = _stringValue(
          course.thumbnail,
        );
        final price = course.price ?? 0;
        final rating = course.averageRating ?? 0;
        final hours = course.totalDuration ?? 0;
        final courseId = _stringValue(course.id);
        return CategorizedCourseItem(
          courseName: courseName,
          courseImage: courseImage,
          price: price,
          discountPrice: course.discountPrice,
          rate: rating,
          totalTime: _formatDuration(hours),
          onTap: () => onTapCourse(courseId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      assignId: true,
      builder: (controller) {
        return  HandlingViewData(requestStatus: controller.requestStatus,
            widget: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: AppPadding.pad25,
                  horizontal: AppPadding.pad10
                ),
                color: Colors.transparent,
                child: Column(
                  children: [
                    SizedBox(height: AppHeight.h20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi,${controller.userName}",
                              style: TextStyle(
                                fontSize: AppTextSize.textSize24,
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
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(() => AppRoutesNames.profileScreen);
                              },
                              child: Container(
                                width: AppHeight.h40,
                                height: AppHeight.h40,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius:
                                  BorderRadius.circular(AppRadius.radius40),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    AssetsPath.profile,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            NotificationButton(),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: AppHeight.h20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "All Courses",
                          style: TextStyle(
                            fontSize: AppTextSize.textSize20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.grayColor,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.toNamed(
                              AppRoutesNames.coursesScreen,
                              arguments: {'type': 'all'},
                            );
                          },
                          child: Text(
                            AppStrings.viewMore,
                            style: TextStyle(
                              fontSize: AppTextSize.textSize12,
                              fontWeight: FontWeight.bold,
                              color: AppColor.headerTextColor,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColor.headerTextColor,
                              decorationThickness: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppHeight.h10),
                    _buildCoursesGrid(
                      courses: controller.allCourses,
                      onTapCourse: (courseId) {
                        if (courseId.isEmpty) return;
                        Get.toNamed(AppRoutesNames.exploreCourseScreen,
                            arguments: {"courseId": courseId});
                      },
                    ),
                    SizedBox(height: AppHeight.h20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Popular",
                          style: TextStyle(
                            fontSize: AppTextSize.textSize20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.grayColor,
                          ),
                        ),
                        InkWell(
                          onTap: controller.goToPopularScreen,
                          child: Text(
                            AppStrings.viewMore,
                            style: TextStyle(
                              fontSize: AppTextSize.textSize12,
                              fontWeight: FontWeight.bold,
                              color: AppColor.headerTextColor,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColor.headerTextColor,
                              decorationThickness: 2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    _buildCoursesGrid(
                      courses: controller.popularCourses,
                      onTapCourse: (courseId) {
                        if (courseId.isEmpty) return;
                        Get.toNamed(AppRoutesNames.exploreCourseScreen,
                            arguments: {"courseId": courseId});
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recommended",
                          style: TextStyle(
                            fontSize: AppTextSize.textSize20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.grayColor,
                          ),
                        ),
                        InkWell(
                          onTap: controller.goToRecommendedScreen,
                          child: Text(
                            AppStrings.viewMore,
                            style: TextStyle(
                              fontSize: AppTextSize.textSize12,
                              fontWeight: FontWeight.bold,
                              color: AppColor.headerTextColor,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColor.headerTextColor,
                              decorationThickness: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildCoursesGrid(
                      courses: controller.recommendedCourses,
                      onTapCourse: (courseId) {
                        if (courseId.isEmpty) return;
                        Get.toNamed(AppRoutesNames.exploreCourseScreen,
                            arguments: {"courseId": courseId});
                      },
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }
}
