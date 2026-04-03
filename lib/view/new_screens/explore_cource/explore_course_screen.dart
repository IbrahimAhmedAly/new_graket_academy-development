import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/functions/date_time_extensions.dart';
import 'package:new_graket_acadimy/core/class/handling_view_data.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/view/new_widgets/explore_widgets/add_to_basket_button.dart';
import 'package:new_graket_acadimy/view/new_widgets/explore_widgets/buy_now_button.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../controller/home_controller/course_details_controller.dart';
import '../../../model/courses/get_course_by_id_model.dart';

class ExploreCourseScreen extends StatefulWidget {
  const ExploreCourseScreen({super.key});

  @override
  State<ExploreCourseScreen> createState() => _ExploreCourseScreenState();
}

class _ExploreCourseScreenState extends State<ExploreCourseScreen> {
  late YoutubePlayerController _controller;
  String _currentVideoId = '';

  String _stringValue(dynamic value, {String fallback = ""}) {
    if (value == null) return fallback;
    final result = value is String ? value : value.toString();
    return result.isEmpty ? fallback : result;
  }

  bool _boolValue(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == "true";
    if (value is num) return value != 0;
    return fallback;
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }

  String _formatCreatedAt(dynamic value) {
    final parsed = _parseDate(value);
    if (parsed == null) return "unknown";
    final local = parsed.isUtc ? parsed.toLocal() : parsed;
    return local.to_dd_MMM_yyyy;
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) return "0 h";
    if (minutes < 60) return "${minutes} m";
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins == 0 ? "${hours} h" : "${hours} h ${mins} m";
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: 'dQw4w9WgXcQ',
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ensurePlayer(String url) {
    if (url.isEmpty) return;
    final videoId = YoutubePlayer.convertUrlToId(url) ?? url;
    if (videoId.isEmpty) return;
    if (videoId == _currentVideoId) return;
    _currentVideoId = videoId;
    _controller.load(videoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
         centerTitle: true,
        title: Text("Course Details"),
      ),
      body: GetBuilder<CourseDetailsControllerImp>(
        assignId: true,
        builder: (controller) {
          final details = controller.courseDetails;
          final name = _stringValue(details?.title, fallback: "Course Name");
          final cover = _stringValue(details?.thumbnail);
          final isSubscriber = controller.isSubscriber;
          final createdAtText = _formatCreatedAt(details?.createdAt);
          final durationText =
              _formatDuration(details?.totalDuration ?? 0);
          final videosLength = details?.totalVideos ?? 0;
          final quizzesLength = details?.totalQuizzes ?? 0;
          final description =
              _stringValue(details?.description, fallback: "No description");
          final priceValue =
              details?.discountPrice ?? details?.price ?? 0;
          final priceText = priceValue == 0 ? "ask admin" : priceValue.toString();
          final categoryName =
              _stringValue(details?.category?.name, fallback: "Category");
          final instructorName =
              _stringValue(details?.instructor?.name, fallback: "Instructor");

          if (controller.previewVideoUrl.isNotEmpty) {
            _ensurePlayer(controller.previewVideoUrl);
          }

          return HandlingViewData(
            requestStatus: controller.requestStatus,
            widget: Container(
              alignment: Alignment.bottomCenter,
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                      top: AppPadding.pad70,
                      left: AppHeight.h10,
                      right: AppHeight.h10,
                      bottom: AppPadding.pad20,
                  ),
                  child: Column(
                    spacing: AppHeight.h10,
                    children: [
                    Container(
                      width: AppWidth.w340,
                      height: AppHeight.h150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(AppRadius.radius40),
                            bottomLeft: Radius.circular(AppRadius.radius40)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(AppRadius.radius40),
                            bottomLeft: Radius.circular(AppRadius.radius40)),
                        child:
                        isSubscriber && controller.previewVideoUrl.isNotEmpty
                            ? YoutubePlayer(
                                controller: _controller,
                                showVideoProgressIndicator: true,
                                progressIndicatorColor: AppColor.buttonColor,
                                progressColors: ProgressBarColors(
                                  playedColor: AppColor.buttonColor,
                                  handleColor: AppColor.buttonColor,
                                ),
                                onReady: () {
                                  _controller.addListener(() {});
                                },
                              )
                            : CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: cover,
                                placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                      color: AppColor.buttonColor,
                                    )),
                                errorWidget: (context, url, error) => Image.asset(
                                  AssetsPath.courseImage_1,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    Column(
                      spacing: AppHeight.h3,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: AppPadding.pad6),
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppTextSize.textSize16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          spacing: AppWidth.w10,
                          children: [
                            Text(
                              'Course Category',
                              style: TextStyle(
                                fontSize: AppTextSize.textSize14,
                                fontWeight: FontWeight.bold,
                                color: AppColor.grayColor,
                              ),
                            ),
                            Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: AppTextSize.textSize14,
                                fontWeight: FontWeight.normal,
                                color: AppColor.grayColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          spacing: AppWidth.w10,
                          children: [
                            Text(
                              'Instructor',
                              style: TextStyle(
                                fontSize: AppTextSize.textSize14,
                                fontWeight: FontWeight.bold,
                                color: AppColor.grayColor,
                              ),
                            ),
                            Text(
                              instructorName,
                              style: TextStyle(
                                fontSize: AppTextSize.textSize14,
                                fontWeight: FontWeight.normal,
                                color: AppColor.grayColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          spacing: AppWidth.w10,
                          children: [
                            Text(
                              'Created',
                              style: TextStyle(
                                fontSize: AppTextSize.textSize14,
                                fontWeight: FontWeight.bold,
                                color: AppColor.grayColor,
                              ),
                            ),
                            Text(
                              createdAtText,
                              style: TextStyle(
                                fontSize: AppTextSize.textSize14,
                                fontWeight: FontWeight.normal,
                                color: AppColor.grayColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      spacing: AppHeight.h3,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppWidth.w18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.av_timer_outlined,
                                    color: AppColor.buttonColor,
                                    size: AppRadius.radius20,
                                  ),
                                  SizedBox(
                                    width: AppWidth.sizeBox,
                                  ),
                                  Text(
                                    durationText,
                                    style: TextStyle(
                                      fontSize: AppTextSize.textSize14,
                                      fontWeight: FontWeight.normal,
                                      color: AppColor.blackColor,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_circle_outline_outlined,
                                    color: AppColor.buttonColor,
                                    size: AppRadius.radius20,
                                  ),
                                  SizedBox(
                                    width: AppWidth.sizeBox,
                                  ),
                                  Text(
                                    "${videosLength == 0 ? "none" : videosLength} Video",
                                    style: TextStyle(
                                      fontSize: AppTextSize.textSize14,
                                      fontWeight: FontWeight.normal,
                                      color: AppColor.blackColor,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.quiz_outlined,
                                    color: AppColor.buttonColor,
                                    size: AppRadius.radius20,
                                  ),
                                  SizedBox(
                                    width: AppWidth.sizeBox,
                                  ),
                                  Text(
                                    "${quizzesLength} Quiz",
                                    style: TextStyle(
                                      fontSize: AppTextSize.textSize14,
                                      fontWeight: FontWeight.normal,
                                      color: AppColor.blackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: AppColor.grayColor,
                          thickness: 1,
                        ),
                      ],
                    ),
                    DefaultTabController(
                      animationDuration: Duration(milliseconds: 300),
                      length: 3,
                      child: Column(
                        children: [
                          TabBar(
                            labelPadding:
                            EdgeInsets.symmetric(horizontal: AppPadding.pad30),
                            tabAlignment: TabAlignment.center,
                            unselectedLabelStyle: TextStyle(
                              fontSize: AppTextSize.textSize14,
                              fontWeight: FontWeight.bold,
                            ),
                            labelStyle: TextStyle(
                              fontSize: AppTextSize.textSize16,
                              fontWeight: FontWeight.bold,
                            ),
                            isScrollable: true,
                            labelColor: AppColor.buttonColor,
                            unselectedLabelColor: AppColor.grayColor,
                            tabs: [
                              Tab(text: 'Detail'),
                              Tab(text: 'Content'),
                              Tab(text: 'Review'),
                            ],
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: AppHeight.h180,
                            width: AppWidth.w340,
                            child: TabBarView(
                              viewportFraction: 1,
                              children: [
                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,

                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: AppPadding.pad6),
                                            child: Text(
                                              'About Course ',
                                              style: TextStyle(
                                                fontSize: AppTextSize.textSize12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            description,
                                            textAlign: TextAlign.justify,
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(
                                              fontSize: AppTextSize.textSize12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: AppPadding.pad6),
                                            child: Text(
                                              'Instructor ',
                                              style: TextStyle(
                                                fontSize: AppTextSize.textSize12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              ClipOval(
                                                child: Image.asset(
                                                  width: AppHeight.h25,
                                                  height: AppHeight.h25,
                                                  AssetsPath.profile,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Text(
                                                instructorName,
                                                textAlign: TextAlign.justify,
                                                overflow: TextOverflow.visible,
                                                style: TextStyle(
                                                  fontSize: AppTextSize
                                                      .textSize12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (_stringValue(details?.instructor?.bio).isNotEmpty)
                                            Text(
                                              _stringValue(details?.instructor?.bio),
                                              textAlign: TextAlign.justify,
                                              overflow: TextOverflow.visible,
                                              style: TextStyle(
                                                fontSize: AppTextSize.textSize12,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                CourseContentWidget(
                                  sections: details?.sections ?? const [],
                                  isSubscriber: isSubscriber,
                                ),
                                Center(child: Text("🔜 Will be available soon 💕")),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          AddToBasketButton(onTap: () {
                            controller.addToBasket();
                          }),
                          BuyNowButton(
                              onTap: () {
                                Get.toNamed(AppRoutesNames.enterCodeScreen);
                          },
                            price: priceText,),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CourseContentWidget extends StatelessWidget {
  final int selectedChapterIndex = 0;
  final int selectedVideoIndex = 0;
  final List<Section> sections;
  final bool isSubscriber;
  const CourseContentWidget({
    super.key,
    required this.sections,
    required this.isSubscriber,
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return Center(child: Text("No content yet"));
    }
    return SingleChildScrollView(
      dragStartBehavior: DragStartBehavior.start,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppWidth.w10),
        child: Column(
          children: List.generate(sections.length, (chapterIndex) {
            final section = sections[chapterIndex];
            final contents = section.contents ?? const [];
            return ExpansionTile(
              title: Text(
                section.title ?? 'Chapter ${chapterIndex + 1}',
                style: TextStyle(
                  fontSize: AppTextSize.textSize16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: List.generate(contents.length, (videoIndex) {
                final content = contents[videoIndex];
                return ListTile(
                  textColor: videoIndex == selectedVideoIndex &&
                          chapterIndex == selectedChapterIndex
                      ? AppColor.greenColor
                      : AppColor.blackColor,
                  leading: Icon(
                    Icons.play_circle_outline,
                    color: AppColor.buttonColor,
                  ),
                  title: Text(
                    content.title ?? 'Lecture ${videoIndex + 1}',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(
                    isSubscriber ? Icons.lock_open : Icons.lock,
                    color: AppColor.grayColor,
                    size: AppRadius.radius20,
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
