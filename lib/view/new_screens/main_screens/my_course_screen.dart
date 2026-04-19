import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/my_courses_controller.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/common/widgets/shimmer_loading.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/app_theme.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/model/my_courses/get_my_courses_model.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/view/new_widgets/main_widgets/notification_button.dart';

/// Modern, single-source-of-truth My Courses screen. Two tabs only
/// (Ongoing & Completed) — the legacy "Saved" tab moved to the wishlist
/// tab in the bottom nav.
class MyCourseScreen extends StatefulWidget {
  const MyCourseScreen({super.key});

  @override
  State<MyCourseScreen> createState() => _MyCourseScreenState();
}

class _MyCourseScreenState extends State<MyCourseScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  int _tab = 0; // 0 = Ongoing, 1 = Completed

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (index == _tab) return;
    HapticFeedback.selectionClick();
    setState(() => _tab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return GetBuilder<MyCoursesController>(
      init: Get.isRegistered<MyCoursesController>()
          ? Get.find<MyCoursesController>()
          : MyCoursesController(),
      builder: (controller) {
        final isLoading =
            controller.requestStatus == RequestStatus.loading &&
                controller.ongoingCourses.isEmpty &&
                controller.completedCourses.isEmpty;

        return Scaffold(
          backgroundColor: theme.scaffoldBg,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(
                  ongoingCount: controller.ongoingCourses.length,
                  completedCount: controller.completedCourses.length,
                ),
                _SegmentedTabs(
                  selected: _tab,
                  ongoingCount: controller.ongoingCourses.length,
                  completedCount: controller.completedCourses.length,
                  onTap: _selectTab,
                ),
                SizedBox(height: AppHeight.h12),
                Expanded(
                  child: isLoading
                      ? const _MyCoursesSkeleton()
                      : PageView(
                          controller: _pageController,
                          onPageChanged: (i) => setState(() => _tab = i),
                          children: [
                            _CourseList(
                              key: const PageStorageKey('mc-ongoing'),
                              items: controller.ongoingCourses,
                              scrollController:
                                  controller.ongoingScrollController,
                              onRefresh: controller.onRefresh,
                              status: 'ONGOING',
                              hasMore: controller.hasMore('ONGOING'),
                            ),
                            _CourseList(
                              key: const PageStorageKey('mc-completed'),
                              items: controller.completedCourses,
                              scrollController:
                                  controller.completedScrollController,
                              onRefresh: controller.onRefresh,
                              status: 'COMPLETED',
                              hasMore: controller.hasMore('COMPLETED'),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Header: greeting row + stat strip
// ═══════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final int ongoingCount;
  final int completedCount;
  const _Header({
    required this.ongoingCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppPadding.pad20,
        AppPadding.pad16,
        AppPadding.pad20,
        AppPadding.pad16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.myCourses,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize24,
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: AppHeight.h4),
                    Text(
                      AppStrings.learnWithGrakeT,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize13,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              NotificationButton(),
            ],
          ),
          SizedBox(height: AppHeight.h20),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.play_circle_outline_rounded,
                  value: '$ongoingCount',
                  label: 'Active',
                  colorA: AppColor.primaryColor,
                  colorB: AppColor.primaryDark,
                ),
              ),
              SizedBox(width: AppWidth.w12),
              Expanded(
                child: _StatTile(
                  icon: Icons.emoji_events_outlined,
                  value: '$completedCount',
                  label: 'Completed',
                  colorA: const Color(0xFF2E7D32),
                  colorB: const Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color colorA;
  final Color colorB;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.colorA,
    required this.colorB,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppPadding.pad12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorA, colorB],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radius15),
        boxShadow: [
          BoxShadow(
            color: colorA.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          SizedBox(width: AppWidth.w10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: AppTextSize.textSize20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppTextSize.textSize12,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Segmented pill tabs — two-state (Ongoing / Completed)
// ═══════════════════════════════════════════════════════════════
class _SegmentedTabs extends StatelessWidget {
  final int selected;
  final int ongoingCount;
  final int completedCount;
  final ValueChanged<int> onTap;

  const _SegmentedTabs({
    required this.selected,
    required this.ongoingCount,
    required this.completedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.pad20),
      child: Container(
        padding: EdgeInsets.all(AppPadding.pad4),
        decoration: BoxDecoration(
          color: theme.cardBg,
          borderRadius: BorderRadius.circular(AppRadius.radius25),
          border: Border.all(
            color: AppColor.primaryColor.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            _PillTab(
              label: 'Ongoing',
              count: ongoingCount,
              active: selected == 0,
              onTap: () => onTap(0),
            ),
            _PillTab(
              label: 'Completed',
              count: completedCount,
              active: selected == 1,
              onTap: () => onTap(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  const _PillTab({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: AppPadding.pad10),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [AppColor.primaryColor, AppColor.primaryDark],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(AppRadius.radius25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: AppTextSize.textSize13,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppColor.textSecondary,
                ),
              ),
              if (count > 0) ...[
                SizedBox(width: AppWidth.w8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppPadding.pad8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withValues(alpha: 0.25)
                        : AppColor.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.radius20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize10,
                      fontWeight: FontWeight.w800,
                      color: active ? Colors.white : AppColor.primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  List with pull-to-refresh, infinite scroll, empty + loading-more
// ═══════════════════════════════════════════════════════════════
class _CourseList extends StatelessWidget {
  final List<Datum> items;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final String status;
  final bool hasMore;

  const _CourseList({
    super.key,
    required this.items,
    required this.scrollController,
    required this.onRefresh,
    required this.status,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColor.primaryColor,
      onRefresh: onRefresh,
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(AppPadding.pad40),
              children: [_EmptyState(status: status)],
            )
          : ListView.separated(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppPadding.pad20,
                AppPadding.pad8,
                AppPadding.pad20,
                AppPadding.pad100,
              ),
              itemCount: items.length + (hasMore ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(height: AppHeight.h12),
              itemBuilder: (ctx, i) {
                if (i >= items.length) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: AppPadding.pad16),
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                  );
                }
                return _CourseRow(item: items[i]);
              },
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Course row card — modern design with progress bar
// ═══════════════════════════════════════════════════════════════
class _CourseRow extends StatelessWidget {
  final Datum item;
  const _CourseRow({required this.item});

  bool _isNetworkImage(String? value) {
    if (value == null || value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final course = item.course;
    final title = course?.title ?? 'Course';
    final thumbnail = course?.thumbnail;
    final progress = (item.progress ?? 0).toDouble().clamp(0, 100).toDouble();
    final isComplete = progress >= 100;
    final instructor = course?.instructor?.name ?? '';
    final totalVideos = course?.totalVideos ?? 0;
    final durationMins = course?.totalDuration ?? 0;

    return Material(
      color: theme.cardBg,
      borderRadius: BorderRadius.circular(AppRadius.radius15),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.radius15),
        onTap: () {
          final id = course?.id;
          if (id == null || id.isEmpty) return;
          HapticFeedback.selectionClick();
          Get.toNamed(
            AppRoutesNames.exploreCourseScreen,
            arguments: {'courseId': id},
          );
        },
        child: Padding(
          padding: EdgeInsets.all(AppPadding.pad12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Thumbnail with completion check overlay
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppRadius.radius12),
                        child: SizedBox(
                          width: 88,
                          height: 88,
                          child: _isNetworkImage(thumbnail)
                              ? CachedNetworkImage(
                                  imageUrl: thumbnail!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Image.asset(
                                    AssetsPath.courseImage_1,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  AssetsPath.courseImage_1,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      if (isComplete)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(
                                  AppRadius.radius12),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: AppColor.greenColor,
                              size: 32,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: AppWidth.w12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTextSize.textSize14,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        if (instructor.isNotEmpty) ...[
                          SizedBox(height: AppHeight.h4),
                          Text(
                            instructor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppTextSize.textSize12,
                              color: theme.textHint,
                            ),
                          ),
                        ],
                        SizedBox(height: AppHeight.h6),
                        Row(
                          children: [
                            const Icon(
                              Icons.play_circle_outline_rounded,
                              size: 12,
                              color: AppColor.textHint,
                            ),
                            SizedBox(width: AppWidth.w4),
                            Text(
                              '$totalVideos videos',
                              style: TextStyle(
                                fontSize: AppTextSize.textSize10,
                                color: theme.textHint,
                              ),
                            ),
                            SizedBox(width: AppWidth.w8),
                            if (durationMins > 0) ...[
                              const Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: AppColor.textHint,
                              ),
                              SizedBox(width: AppWidth.w4),
                              Text(
                                _formatDuration(durationMins),
                                style: TextStyle(
                                  fontSize: AppTextSize.textSize10,
                                  color: theme.textHint,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppHeight.h12),
              // Progress row
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.radius10),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 6,
                        backgroundColor:
                            AppColor.gray.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isComplete
                              ? AppColor.greenColor
                              : AppColor.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppWidth.w10),
                  Text(
                    '${progress.toInt()}%',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize12,
                      fontWeight: FontWeight.w800,
                      color: isComplete
                          ? AppColor.greenColor
                          : AppColor.primaryColor,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

// ═══════════════════════════════════════════════════════════════
//  Empty state
// ═══════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final String status;
  const _EmptyState({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isOngoing = status == 'ONGOING';
    final icon = isOngoing
        ? Icons.school_outlined
        : Icons.emoji_events_outlined;
    final title =
        isOngoing ? 'No active courses yet' : 'No completed courses yet';
    final subtitle = isOngoing
        ? 'Start learning — your enrolled courses will appear here.'
        : 'Finish a course to celebrate your achievements here.';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: AppHeight.h40),
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: AppColor.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 48, color: AppColor.primaryColor),
        ),
        SizedBox(height: AppHeight.h20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppTextSize.textSize16,
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
        SizedBox(height: AppHeight.h8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppTextSize.textSize13,
            color: theme.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: AppHeight.h24),
        if (isOngoing)
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Get.offAllNamed(AppRoutesNames.mainScreen, arguments: 2);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.pad24,
                vertical: AppPadding.pad12,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColor.primaryColor, AppColor.primaryDark],
                ),
                borderRadius: BorderRadius.circular(AppRadius.radius25),
              ),
              child: const Text(
                'Browse courses',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Skeleton that mirrors the layout
// ═══════════════════════════════════════════════════════════════
class _MyCoursesSkeleton extends StatelessWidget {
  const _MyCoursesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppPadding.pad20,
        AppPadding.pad8,
        AppPadding.pad20,
        AppPadding.pad100,
      ),
      children: List.generate(
        5,
        (_) => Padding(
          padding: EdgeInsets.only(bottom: AppPadding.pad12),
          child: ShimmerBox(
            width: double.infinity,
            height: 140,
            borderRadius: 15,
          ),
        ),
      ),
    );
  }
}
