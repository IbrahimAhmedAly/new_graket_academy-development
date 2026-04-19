import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/common/widgets/shimmer_loading.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/functions/date_time_extensions.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../controller/home_controller/course_details_controller.dart';
import '../../../data/reviews_data/reviews_data.dart';
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

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
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
    if (minutes < 60) return "$minutes m";
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins == 0 ? "$hours h" : "$hours h $mins m";
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: 'dQw4w9WgXcQ',
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
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
    if (videoId.isEmpty || videoId == _currentVideoId) return;
    _currentVideoId = videoId;
    _controller.load(videoId);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CourseDetailsControllerImp>(
      assignId: true,
      builder: (controller) {
        // ── Loading state ──
        if (controller.requestStatus == RequestStatus.loading ||
            controller.requestStatus == RequestStatus.none) {
          return Scaffold(
            backgroundColor: AppColor.scaffoldBg,
            appBar: _buildAppBar(),
            body: const _CourseDetailsSkeleton(),
          );
        }

        // ── Error state ──
        if (controller.requestStatus != RequestStatus.success) {
          return Scaffold(
            backgroundColor: AppColor.scaffoldBg,
            appBar: _buildAppBar(),
            body: _buildErrorState(controller),
          );
        }

        // ── Success state ──
        final details = controller.courseDetails;
        final name = _stringValue(details?.title, fallback: "Course Name");
        final cover = _stringValue(details?.thumbnail);
        final isSubscriber = controller.isSubscriber;
        final description =
            _stringValue(details?.description, fallback: "No description");
        final priceValue = details?.discountPrice ?? details?.price ?? 0;
        final originalPrice = details?.price ?? 0;
        final hasDiscount = details?.discountPrice != null &&
            details!.discountPrice! > 0 &&
            details.discountPrice! < originalPrice;
        final priceText =
            priceValue == 0 ? "ask admin" : "${priceValue.toStringAsFixed(0)} EGP";
        final categoryName =
            _stringValue(details?.category?.name, fallback: "Category");
        final instructorName =
            _stringValue(details?.instructor?.name, fallback: "Instructor");
        final rating = details?.averageRating ?? 0;
        final totalReviews = details?.totalReviews ?? 0;
        final durationText = _formatDuration(details?.totalDuration ?? 0);
        final videosLength = details?.totalVideos ?? 0;
        final quizzesLength = details?.totalQuizzes ?? 0;

        if (controller.previewVideoUrl.isNotEmpty) {
          _ensurePlayer(controller.previewVideoUrl);
        }

        return Scaffold(
          backgroundColor: AppColor.scaffoldBg,
          body: Column(
            children: [
              // ── Scrollable content ──
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ── Hero image / video with back button ──
                    SliverAppBar(
                      expandedHeight: 220,
                      pinned: true,
                      backgroundColor: AppColor.primaryDark,
                      leading: IconButton(
                        onPressed: () => Get.back(),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      actions: [
                        _CircleIconButton(
                          icon: controller.isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          iconColor: controller.isSaved
                              ? AppColor.starColor
                              : Colors.white,
                          onTap: controller.toggleSaved,
                        ),
                        _CircleIconButton(
                          icon: Icons.share_rounded,
                          iconColor: Colors.white,
                          onTap: controller.shareCourse,
                        ),
                        SizedBox(width: AppWidth.w8),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: isSubscriber &&
                                controller.previewVideoUrl.isNotEmpty
                            ? YoutubePlayer(
                                controller: _controller,
                                showVideoProgressIndicator: true,
                                progressIndicatorColor: AppColor.primaryColor,
                                progressColors: ProgressBarColors(
                                  playedColor: AppColor.primaryColor,
                                  handleColor: AppColor.primaryColor,
                                ),
                                onReady: () {
                                  _controller.addListener(() {});
                                },
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: cover,
                                    placeholder: (context, url) => Container(
                                      color: AppColor.primaryLight,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColor.primaryColor,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      AssetsPath.courseImage_1,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Gradient overlay
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.5),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    // ── Body content ──
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.scaffoldBg,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        transform: Matrix4.translationValues(0, -20, 0),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppPadding.pad16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: AppHeight.h24),

                              // ── Category pill ──
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppPadding.pad12,
                                  vertical: AppPadding.pad4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.primaryLight,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.radius20),
                                ),
                                child: Text(
                                  categoryName,
                                  style: TextStyle(
                                    fontSize: AppTextSize.textSize12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(height: AppHeight.h12),

                              // ── Title ──
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: AppTextSize.textSize20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.textPrimary,
                                  height: 1.25,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: AppHeight.h12),

                              // ── Instructor ──
                              Row(
                                children: [
                                  ClipOval(
                                    child: Image.asset(
                                      AssetsPath.profile,
                                      width: 28,
                                      height: 28,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: AppWidth.w8),
                                  Text(
                                    instructorName,
                                    style: TextStyle(
                                      fontSize: AppTextSize.textSize14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppHeight.h12),

                              // ── Rating + reviews ──
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: AppColor.starColor, size: 18),
                                  SizedBox(width: AppWidth.w4),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: AppTextSize.textSize14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.textPrimary,
                                    ),
                                  ),
                                  SizedBox(width: AppWidth.w4),
                                  Text(
                                    "($totalReviews reviews)",
                                    style: TextStyle(
                                      fontSize: AppTextSize.textSize12,
                                      color: AppColor.textHint,
                                    ),
                                  ),
                                  SizedBox(width: AppWidth.w16),
                                  Text(
                                    _formatCreatedAt(details?.createdAt),
                                    style: TextStyle(
                                      fontSize: AppTextSize.textSize12,
                                      color: AppColor.textHint,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppHeight.h20),

                              // ── Stats row ──
                              _buildStatsRow(
                                duration: durationText,
                                videos: videosLength,
                                quizzes: quizzesLength,
                              ),

                              // ── Progress banner (purchased courses only) ──
                              if (controller.isPurchased) ...[
                                SizedBox(height: AppHeight.h16),
                                _ProgressBanner(controller: controller),
                              ],

                              SizedBox(height: AppHeight.h28),

                              // ── What you'll learn ──
                              if ((details?.learningOutcomes ?? const [])
                                  .isNotEmpty) ...[
                                _SectionTitle(title: "What you'll learn"),
                                SizedBox(height: AppHeight.h12),
                                _LearningOutcomesCard(
                                  outcomes: details!.learningOutcomes!,
                                ),
                                SizedBox(height: AppHeight.h28),
                              ],

                              // ── About this course ──
                              _SectionTitle(title: "About this course"),
                              SizedBox(height: AppHeight.h8),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: AppTextSize.textSize14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.textSecondary,
                                  height: 1.6,
                                ),
                              ),
                              SizedBox(height: AppHeight.h28),

                              // ── Instructor ──
                              _SectionTitle(title: "Instructor"),
                              SizedBox(height: AppHeight.h12),
                              _InstructorCard(
                                instructor: details?.instructor,
                                fallbackName: instructorName,
                              ),
                              if (_stringValue(details?.instructor?.bio)
                                  .isNotEmpty) ...[
                                SizedBox(height: AppHeight.h8),
                                Text(
                                  _stringValue(details?.instructor?.bio),
                                  style: TextStyle(
                                    fontSize: AppTextSize.textSize13,
                                    fontWeight: FontWeight.w400,
                                    color: AppColor.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                              SizedBox(height: AppHeight.h28),

                              // ── Course content ──
                              _SectionTitle(title: "Course Content"),
                              SizedBox(height: AppHeight.h12),
                              CourseContentWidget(
                                sections: details?.sections ?? const [],
                                controller: controller,
                              ),
                              SizedBox(height: AppHeight.h28),

                              // ── Reviews ──
                              _ReviewsSection(
                                reviews: details?.reviews ?? const [],
                                averageRating:
                                    details?.averageRating ?? 0,
                                totalReviews: details?.totalReviews ?? 0,
                                courseId: details?.id ?? '',
                                userToken: controller.userToken,
                              ),

                              SizedBox(height: AppHeight.h100),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Sticky bottom action bar ──
              _buildBottomActionBar(
                priceText: priceText,
                hasDiscount: hasDiscount,
                originalPrice: originalPrice,
                controller: controller,
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: const Text("Course Details"),
      backgroundColor: AppColor.scaffoldBg,
      elevation: 0,
    );
  }

  // ── Stats row (duration, videos, quizzes) ──
  Widget _buildStatsRow({
    required String duration,
    required int videos,
    required int quizzes,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppPadding.pad12,
        horizontal: AppPadding.pad16,
      ),
      decoration: BoxDecoration(
        color: AppColor.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
              icon: Icons.access_time_rounded,
              label: duration,
              subtitle: "Duration"),
          Container(width: 1, height: 36, color: AppColor.gray.withValues(alpha: 0.2)),
          _StatItem(
              icon: Icons.play_circle_outline_rounded,
              label: videos == 0 ? "—" : "$videos",
              subtitle: "Videos"),
          Container(width: 1, height: 36, color: AppColor.gray.withValues(alpha: 0.2)),
          _StatItem(
              icon: Icons.quiz_outlined,
              label: "$quizzes",
              subtitle: "Quizzes"),
        ],
      ),
    );
  }

  // ── Sticky bottom action bar ──
  Widget _buildBottomActionBar({
    required String priceText,
    required bool hasDiscount,
    required double originalPrice,
    required CourseDetailsControllerImp controller,
  }) {
    final isPurchased = controller.isPurchased;

    return Container(
      padding: EdgeInsets.only(
        left: AppPadding.pad16,
        right: AppPadding.pad16,
        top: AppPadding.pad12,
        bottom: MediaQuery.of(context).padding.bottom + AppPadding.pad12,
      ),
      decoration: BoxDecoration(
        color: AppColor.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: isPurchased
          // ── Purchased: single full-width "Continue Learning" button ──
          ? GestureDetector(
              onTap: () => controller.continueLearning(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: AppPadding.pad12),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(AppRadius.radius12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_outline_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: AppWidth.w8),
                    Text(
                      "Continue Learning",
                      style: TextStyle(
                        fontSize: AppTextSize.textSize15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          // ── Not purchased: price + basket icon + buy now ──
          : Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasDiscount)
                        Text(
                          "${originalPrice.toStringAsFixed(0)} EGP",
                          style: TextStyle(
                            fontSize: AppTextSize.textSize12,
                            color: AppColor.textHint,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColor.textHint,
                          ),
                        ),
                      Text(
                        priceText,
                        style: TextStyle(
                          fontSize: AppTextSize.textSize20,
                          fontWeight: FontWeight.w800,
                          color: AppColor.priceColor,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.addToBasket(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.radius12),
                    ),
                    child: const Icon(
                      Icons.shopping_basket_outlined,
                      color: AppColor.primaryColor,
                      size: 22,
                    ),
                  ),
                ),
                SizedBox(width: AppWidth.w10),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutesNames.enterCodeScreen),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppPadding.pad24,
                      vertical: AppPadding.pad12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(AppRadius.radius12),
                    ),
                    child: Text(
                      AppStrings.buyNow,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ── Error state ──
  Widget _buildErrorState(CourseDetailsControllerImp controller) {
    String message;
    IconData icon;
    switch (controller.requestStatus) {
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
      default:
        message = AppStrings.noData.tr;
        icon = Icons.inbox_rounded;
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
              decoration: const BoxDecoration(
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
              onTap: () => controller.getCourseDetails(),
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

// ═══════════════════════════════════════════════════
//  Stat item widget
// ═══════════════════════════════════════════════════
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColor.primaryColor, size: 22),
        SizedBox(height: AppHeight.h4),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTextSize.textSize14,
            fontWeight: FontWeight.w700,
            color: AppColor.textPrimary,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: AppTextSize.textSize10,
            color: AppColor.textHint,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
//  Section title widget
// ═══════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppTextSize.textSize16,
        fontWeight: FontWeight.w700,
        color: AppColor.textPrimary,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  Course Content Widget (sections / chapters)
// ═══════════════════════════════════════════════════
class CourseContentWidget extends StatelessWidget {
  final List<Section> sections;
  final CourseDetailsControllerImp controller;

  const CourseContentWidget({
    super.key,
    required this.sections,
    required this.controller,
  });

  IconData _contentIcon(String? type) {
    switch ((type ?? '').toUpperCase()) {
      case 'VIDEO':
        return Icons.play_circle_outline_rounded;
      case 'PDF':
        return Icons.picture_as_pdf_outlined;
      case 'QUIZ':
        return Icons.quiz_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppPadding.pad40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.folder_open_rounded,
                  size: 48, color: AppColor.textHint),
              SizedBox(height: AppHeight.h12),
              Text(
                "No content yet",
                style: TextStyle(
                  fontSize: AppTextSize.textSize14,
                  color: AppColor.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: List.generate(sections.length, (index) {
        final section = sections[index];
        final contents = section.contents ?? const [];
        return Container(
          margin: EdgeInsets.only(bottom: AppPadding.pad8),
          decoration: BoxDecoration(
            color: AppColor.cardBg,
            borderRadius: BorderRadius.circular(AppRadius.radius12),
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryColor.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(
                horizontal: AppPadding.pad16,
                vertical: AppPadding.pad4,
              ),
              childrenPadding: EdgeInsets.only(bottom: AppPadding.pad8),
              title: Text(
                section.title ?? 'Section ${index + 1}',
                style: TextStyle(
                  fontSize: AppTextSize.textSize14,
                  fontWeight: FontWeight.w700,
                  color: AppColor.textPrimary,
                ),
              ),
              subtitle: Text(
                "${contents.length} lessons",
                style: TextStyle(
                  fontSize: AppTextSize.textSize12,
                  color: AppColor.textHint,
                ),
              ),
              iconColor: AppColor.primaryColor,
              collapsedIconColor: AppColor.textHint,
              children: List.generate(contents.length, (contentIndex) {
                final content = contents[contentIndex];
                final hasAccess = controller.contentHasAccess(content);
                return GestureDetector(
                  onTap: hasAccess ? () => controller.continueLearning() : null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppPadding.pad16,
                      vertical: AppPadding.pad6,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: hasAccess
                                ? AppColor.primaryLight
                                : AppColor.gray.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppRadius.radius10),
                          ),
                          child: Icon(
                            _contentIcon(content.type),
                            color: hasAccess
                                ? AppColor.primaryColor
                                : AppColor.textHint,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: AppWidth.w12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                content.title ?? 'Lesson ${contentIndex + 1}',
                                style: TextStyle(
                                  fontSize: AppTextSize.textSize13,
                                  fontWeight: FontWeight.w500,
                                  color: hasAccess
                                      ? AppColor.textPrimary
                                      : AppColor.textHint,
                                ),
                              ),
                              if (content.duration != null &&
                                  content.duration! > 0)
                                Text(
                                  "${content.duration} min",
                                  style: TextStyle(
                                    fontSize: AppTextSize.textSize10,
                                    color: AppColor.textHint,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          hasAccess
                              ? Icons.lock_open_rounded
                              : Icons.lock_rounded,
                          color: hasAccess
                              ? AppColor.greenColor
                              : AppColor.textHint,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════
//  Shimmer skeleton for loading state
// ═══════════════════════════════════════════════════
class _CourseDetailsSkeleton extends StatefulWidget {
  const _CourseDetailsSkeleton();

  @override
  State<_CourseDetailsSkeleton> createState() => _CourseDetailsSkeletonState();
}

class _CourseDetailsSkeletonState extends State<_CourseDetailsSkeleton>
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image skeleton
            ShimmerBox(
              width: double.infinity,
              height: 200,
              borderRadius: 0,
            ),
            Padding(
              padding: EdgeInsets.all(AppPadding.pad16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category pill
                  ShimmerBox(width: 80, height: 24, borderRadius: 12),
                  SizedBox(height: AppHeight.h12),
                  // Title
                  ShimmerBox(width: double.infinity, height: 22),
                  SizedBox(height: AppHeight.h8),
                  ShimmerBox(width: 200, height: 22),
                  SizedBox(height: AppHeight.h16),
                  // Instructor row
                  Row(
                    children: [
                      ShimmerBox(width: 28, height: 28, borderRadius: 14),
                      SizedBox(width: AppWidth.w8),
                      ShimmerBox(width: 120, height: 14),
                    ],
                  ),
                  SizedBox(height: AppHeight.h12),
                  // Rating row
                  ShimmerBox(width: 180, height: 14),
                  SizedBox(height: AppHeight.h20),
                  // Stats row
                  ShimmerBox(
                      width: double.infinity, height: 70, borderRadius: 12),
                  SizedBox(height: AppHeight.h24),
                  // Tabs
                  ShimmerBox(
                      width: double.infinity, height: 44, borderRadius: 12),
                  SizedBox(height: AppHeight.h16),
                  // Description lines
                  ShimmerBox(width: double.infinity, height: 14),
                  SizedBox(height: AppHeight.h8),
                  ShimmerBox(width: double.infinity, height: 14),
                  SizedBox(height: AppHeight.h8),
                  ShimmerBox(width: 250, height: 14),
                  SizedBox(height: AppHeight.h24),
                  // Section cards
                  ShimmerBox(
                      width: double.infinity, height: 60, borderRadius: 12),
                  SizedBox(height: AppHeight.h8),
                  ShimmerBox(
                      width: double.infinity, height: 60, borderRadius: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Progress banner (shown on course details for purchased courses)
// ═══════════════════════════════════════════════════════════════
class _ProgressBanner extends StatelessWidget {
  final CourseDetailsControllerImp controller;
  const _ProgressBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    final pct = controller.progressPercentage;
    final isComplete = pct >= 100;
    final isStarted = controller.hasStartedCourse;

    final titleText = isComplete
        ? 'Course Completed'
        : isStarted
            ? 'Your Progress'
            : 'Ready to Start';
    final subtitleText = isComplete
        ? 'You finished every lesson. Amazing work!'
        : isStarted
            ? '${controller.completedContents} of ${controller.totalContents} lessons complete'
            : 'Jump in and start learning';

    return Container(
      padding: EdgeInsets.all(AppPadding.pad16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isComplete
              ? [
                  AppColor.greenColor.withValues(alpha: 0.15),
                  AppColor.greenColor.withValues(alpha: 0.05),
                ]
              : [
                  AppColor.primaryColor.withValues(alpha: 0.12),
                  AppColor.primaryColor.withValues(alpha: 0.04),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radius15),
        border: Border.all(
          color: (isComplete ? AppColor.greenColor : AppColor.primaryColor)
              .withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isComplete ? AppColor.greenColor : AppColor.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isComplete
                  ? Icons.emoji_events_rounded
                  : Icons.play_circle_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: AppWidth.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleText,
                  style: TextStyle(
                    fontSize: AppTextSize.textSize14,
                    fontWeight: FontWeight.w800,
                    color: AppColor.textPrimary,
                  ),
                ),
                SizedBox(height: AppHeight.h4),
                Text(
                  subtitleText,
                  style: TextStyle(
                    fontSize: AppTextSize.textSize12,
                    color: AppColor.textSecondary,
                  ),
                ),
                SizedBox(height: AppHeight.h8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.radius10),
                  child: LinearProgressIndicator(
                    value: (pct / 100).clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor:
                        AppColor.gray.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isComplete
                          ? AppColor.greenColor
                          : AppColor.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppWidth.w12),
          Text(
            '$pct%',
            style: TextStyle(
              fontSize: AppTextSize.textSize18,
              fontWeight: FontWeight.w800,
              color:
                  isComplete ? AppColor.greenColor : AppColor.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Reviews section — inline summary card + list of recent reviews
//  Tapping "See all" opens a bottom sheet with paginated reviews.
// ═══════════════════════════════════════════════════════════════
class _ReviewsSection extends StatelessWidget {
  final List<Review> reviews;
  final double averageRating;
  final int totalReviews;
  final String courseId;
  final String userToken;

  const _ReviewsSection({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
    required this.courseId,
    required this.userToken,
  });

  @override
  Widget build(BuildContext context) {
    // Empty state
    if (reviews.isEmpty && totalReviews == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: "Reviews"),
          SizedBox(height: AppHeight.h12),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppPadding.pad20),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.rate_review_outlined,
                      size: 40, color: AppColor.textHint),
                  SizedBox(height: AppHeight.h8),
                  Text(
                    "No reviews yet",
                    style: TextStyle(
                      fontSize: AppTextSize.textSize14,
                      color: AppColor.textHint,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final preview = reviews.take(3).toList();
    final canSeeAll = totalReviews > preview.length && courseId.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SectionTitle(title: "Reviews"),
            SizedBox(width: AppWidth.w8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.pad8,
                vertical: AppPadding.pad4,
              ),
              decoration: BoxDecoration(
                color: AppColor.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.radius20),
              ),
              child: Text(
                '$totalReviews',
                style: TextStyle(
                  fontSize: AppTextSize.textSize12,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primaryColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppHeight.h12),
        _RatingSummary(
          averageRating: averageRating,
          totalReviews: totalReviews,
        ),
        SizedBox(height: AppHeight.h16),
        ...preview.map((r) => Padding(
              padding: EdgeInsets.only(bottom: AppPadding.pad8),
              child: _ReviewCard(review: r),
            )),
        if (canSeeAll) ...[
          SizedBox(height: AppHeight.h8),
          Center(
            child: GestureDetector(
              onTap: () => _ReviewsBottomSheet.show(
                context: context,
                courseId: courseId,
                userToken: userToken,
                totalReviews: totalReviews,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pad20,
                  vertical: AppPadding.pad10,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.radius25),
                ),
                child: Text(
                  "See all $totalReviews reviews",
                  style: TextStyle(
                    fontSize: AppTextSize.textSize13,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  const _RatingSummary({
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppPadding.pad16),
      decoration: BoxDecoration(
        color: AppColor.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.radius15),
        border: Border.all(
          color: AppColor.starColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Text(
            averageRating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: AppTextSize.textSize32,
              fontWeight: FontWeight.w900,
              color: AppColor.textPrimary,
              height: 1,
            ),
          ),
          SizedBox(width: AppWidth.w12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: List.generate(5, (i) {
                  final filled = i < averageRating.round();
                  return Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColor.starColor,
                    size: 18,
                  );
                }),
              ),
              SizedBox(height: AppHeight.h3),
              Text(
                "$totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}",
                style: TextStyle(
                  fontSize: AppTextSize.textSize12,
                  color: AppColor.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  String _timeAgo(DateTime? d) {
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    final rating = (review.rating ?? 0).round();
    final name = review.user?.name?.isNotEmpty == true
        ? review.user!.name!
        : 'Student';
    final comment = (review.comment ?? '').trim();

    return Container(
      padding: EdgeInsets.all(AppPadding.pad12),
      decoration: BoxDecoration(
        color: AppColor.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        border: Border.all(
          color: AppColor.gray.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColor.primaryColor, AppColor.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(name),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTextSize.textSize13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: AppWidth.w12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize13,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppHeight.h3),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: AppColor.starColor,
                            size: 14,
                          ),
                        ),
                        SizedBox(width: AppWidth.w8),
                        Text(
                          _timeAgo(review.createdAt),
                          style: TextStyle(
                            fontSize: AppTextSize.textSize10,
                            color: AppColor.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            SizedBox(height: AppHeight.h8),
            Text(
              comment,
              style: TextStyle(
                fontSize: AppTextSize.textSize13,
                color: AppColor.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Bottom sheet that paginates through GET /course/:id/reviews
class _ReviewsBottomSheet extends StatefulWidget {
  final String courseId;
  final String userToken;
  final int totalReviews;

  const _ReviewsBottomSheet({
    required this.courseId,
    required this.userToken,
    required this.totalReviews,
  });

  static Future<void> show({
    required BuildContext context,
    required String courseId,
    required String userToken,
    required int totalReviews,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewsBottomSheet(
        courseId: courseId,
        userToken: userToken,
        totalReviews: totalReviews,
      ),
    );
  }

  @override
  State<_ReviewsBottomSheet> createState() => _ReviewsBottomSheetState();
}

class _ReviewsBottomSheetState extends State<_ReviewsBottomSheet> {
  final ReviewsData _reviewsData = ReviewsData(Get.find());
  final ScrollController _scrollController = ScrollController();
  final List<Review> _reviews = [];
  int _page = 1;
  final int _limit = 20;
  bool _loading = false;
  bool _hasMore = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadPage();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_loading &&
          _hasMore) {
        _loadPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPage() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final response = await _reviewsData.getCourseReviews(
        courseId: widget.courseId,
        userToken: widget.userToken,
        page: _page,
        limit: _limit,
      );
      if (response.$1 == RequestStatus.success && response.$2 is Map) {
        final raw = response.$2 as Map<String, dynamic>;
        final inner = raw['data'];
        // Response shape: { data: { message, data: [...], metadata: {...} } }
        List<dynamic> list = [];
        Map metadata = {};
        if (inner is Map) {
          final deeper = inner['data'];
          if (deeper is List) {
            list = deeper;
          }
          if (inner['metadata'] is Map) {
            metadata = inner['metadata'] as Map;
          } else if (inner['pagination'] is Map) {
            metadata = inner['pagination'] as Map;
          }
        }
        final newOnes = list
            .whereType<Map>()
            .map((m) => Review.fromJson(Map<String, dynamic>.from(m)))
            .toList();
        setState(() {
          _reviews.addAll(newOnes);
          _page += 1;
          final totalPages = (metadata['totalPages'] as num?)?.toInt() ?? 0;
          _hasMore = totalPages > 0 ? (_page - 1) < totalPages : newOnes.length >= _limit;
        });
      } else {
        setState(() => _error = 'Could not load reviews');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load reviews');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColor.scaffoldBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Grab handle
              Container(
                margin: EdgeInsets.symmetric(vertical: AppPadding.pad8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.gray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pad16,
                  vertical: AppPadding.pad8,
                ),
                child: Row(
                  children: [
                    Text(
                      'All Reviews',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize16,
                        fontWeight: FontWeight.w800,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    SizedBox(width: AppWidth.w8),
                    Text(
                      '(${widget.totalReviews})',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize13,
                        color: AppColor.textHint,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _reviews.isEmpty && _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.primaryColor,
                        ),
                      )
                    : _reviews.isEmpty && _error.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.cloud_off_rounded,
                                  size: 48,
                                  color: AppColor.textHint,
                                ),
                                SizedBox(height: AppHeight.h12),
                                Text(
                                  _error,
                                  style: TextStyle(
                                    color: AppColor.textSecondary,
                                    fontSize: AppTextSize.textSize14,
                                  ),
                                ),
                                SizedBox(height: AppHeight.h12),
                                GestureDetector(
                                  onTap: _loadPage,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppPadding.pad20,
                                      vertical: AppPadding.pad10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryColor,
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.radius25),
                                    ),
                                    child: const Text(
                                      'Retry',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(AppPadding.pad16),
                            itemCount: _reviews.length + (_hasMore ? 1 : 0),
                            itemBuilder: (ctx, i) {
                              if (i >= _reviews.length) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: AppPadding.pad16),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                );
                              }
                              return Padding(
                                padding:
                                    EdgeInsets.only(bottom: AppPadding.pad8),
                                child: _ReviewCard(review: _reviews[i]),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Tappable instructor card — opens InstructorProfileScreen
// ═══════════════════════════════════════════════════════════════
class _InstructorCard extends StatelessWidget {
  final Instructor? instructor;
  final String fallbackName;

  const _InstructorCard({
    required this.instructor,
    required this.fallbackName,
  });

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  bool _isNetworkImage(String? v) {
    if (v == null || v.isEmpty) return false;
    final uri = Uri.tryParse(v);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    final id = instructor?.id ?? '';
    final name = instructor?.name?.isNotEmpty == true
        ? instructor!.name!
        : fallbackName;
    final title = instructor?.title ?? '';
    final avatar = instructor?.avatar;
    final isTappable = id.isNotEmpty;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.radius12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        onTap: isTappable
            ? () => Get.toNamed(
                  AppRoutesNames.instructorProfileScreen,
                  arguments: {
                    'instructorId': id,
                    'profile': {
                      'id': id,
                      'name': name,
                      'avatar': avatar,
                      'title': title,
                      'bio': instructor?.bio,
                    },
                  },
                )
            : null,
        child: Padding(
          padding: EdgeInsets.all(AppPadding.pad4),
          child: Row(
            children: [
              _isNetworkImage(avatar)
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: avatar!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            _initialsAvatar(name),
                      ),
                    )
                  : _initialsAvatar(name),
              SizedBox(width: AppWidth.w12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: AppTextSize.textSize12,
                          color: AppColor.textHint,
                        ),
                      ),
                  ],
                ),
              ),
              if (isTappable)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColor.textHint,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initialsAvatar(String name) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primaryColor, AppColor.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: TextStyle(
          color: Colors.white,
          fontSize: AppTextSize.textSize13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  "What you'll learn" checklist card
// ═══════════════════════════════════════════════════════════════
class _LearningOutcomesCard extends StatelessWidget {
  final List<String> outcomes;
  const _LearningOutcomesCard({required this.outcomes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppPadding.pad16),
      decoration: BoxDecoration(
        color: AppColor.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.radius15),
        border: Border.all(
          color: AppColor.primaryColor.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: outcomes
            .map(
              (item) => Padding(
                padding: EdgeInsets.symmetric(vertical: AppPadding.pad6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColor.greenColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    SizedBox(width: AppWidth.w12),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: AppTextSize.textSize13,
                          color: AppColor.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Circular icon button with translucent black background
//  Used for share / save actions in the SliverAppBar.
// ═══════════════════════════════════════════════════════════════
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
        ),
      ),
    );
  }
}
