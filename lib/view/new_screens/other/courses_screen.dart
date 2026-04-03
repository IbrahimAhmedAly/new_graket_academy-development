import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/handling_view_data.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/other_widgets/categorized_course_item.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';

import '../../../controller/home_controller/courses_controller.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    final controller = Get.isRegistered<CoursesControllerImp>()
        ? Get.find<CoursesControllerImp>()
        : null;
    if (controller == null) return;
    if (!_scrollController.hasClients) return;
    final threshold = 200.0;
    if (_scrollController.position.pixels + threshold >=
        _scrollController.position.maxScrollExtent) {
      controller.loadMore();
    }
  }

  String _stringValue(dynamic value, {String fallback = ""}) {
    if (value == null) return fallback;
    final result = value is String ? value : value.toString();
    return result.isEmpty ? fallback : result;
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) return "0 h";
    if (minutes < 60) return "$minutes m";
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins == 0 ? "$hours h" : "$hours h $mins m";
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CoursesControllerImp>(
      init: Get.isRegistered<CoursesControllerImp>()
          ? Get.find<CoursesControllerImp>()
          : CoursesControllerImp(),
      assignId: true,
      builder: (controller) {
        if (_searchController.text != controller.searchQuery) {
          _searchController.text = controller.searchQuery;
        }
        final title = controller.type == 'popular'
            ? 'Popular'
            : controller.type == 'recommended'
                ? 'Recommended'
                : AppStrings.allCategory;
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: false,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            forceMaterialTransparency: true,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              title,
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          body: Container(
            alignment: Alignment.bottomCenter,
            width: double.maxFinite,
            height: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(AssetsPath.mainScreen),
              ),
            ),
            child: HandlingViewData(
              requestStatus: controller.requestStatus,
              widget: Padding(
                padding: EdgeInsets.only(top: AppPadding.pad60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 50),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppPadding.pad20,
                          vertical: AppPadding.pad10),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          _debounce?.cancel();
                          _debounce =
                              Timer(const Duration(milliseconds: 350), () {
                            controller.applySearch(value.trim());
                          });
                        },
                        onSubmitted: (value) {
                          _debounce?.cancel();
                          controller.applySearch(value.trim());
                        },
                        decoration: InputDecoration(
                          hintText: 'Search courses...',
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              controller.applySearch('');
                            },
                          ),
                          filled: true,
                          fillColor: AppColor.whiteColor,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.radius15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppWidth.w5,
                          crossAxisSpacing: AppWidth.w5,
                          childAspectRatio: 0.75,
                        ),
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: AppPadding.pad20,
                            vertical: AppPadding.pad10),
                        itemCount: controller.courses.length +
                            (controller.hasNextPage ? 1 : 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (index >= controller.courses.length) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppPadding.pad10),
                                child: CircularProgressIndicator(
                                  color: AppColor.buttonColor,
                                ),
                              ),
                            );
                          }
                          final course = controller.courses[index];
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
                          final courseId = _stringValue(
                            course.id,
                            fallback: "",
                          );
                          return CategorizedCourseItem(
                            courseName: courseName,
                            courseImage: courseImage,
                            price: price,
                            discountPrice: course.discountPrice,
                            rate: rating,
                            totalTime: _formatDuration(hours),
                            onTap: () {
                              if (courseId.isEmpty) return;
                              Get.toNamed(AppRoutesNames.exploreCourseScreen,
                                  arguments: {"courseId": courseId});
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
