import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/common/widgets/shimmer_loading.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/view/new_widgets/other_widgets/categorized_course_item.dart';

import '../../../controller/home_controller/courses_controller.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  late final TextEditingController _searchController;
  late final CoursesControllerImp _coursesController;
  late final String _controllerTag;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final initialType = args is Map ? args['type']?.toString() : null;
    final initialSearch = args is Map ? args['search']?.toString() : null;

    _controllerTag = 'courses-${identityHashCode(this)}';
    _searchController = TextEditingController(text: initialSearch?.trim());
    _coursesController = CoursesControllerImp(
      initialType: initialType,
      initialSearch: initialSearch,
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter <= 240) {
      unawaited(_coursesController.loadMore());
    }
  }

  void _scheduleSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _applySearch(value);
    });
  }

  void _applySearch(String value) {
    final normalizedQuery = value.trim();
    if (normalizedQuery == _coursesController.searchQuery) return;

    unawaited(_coursesController.applySearch(normalizedQuery));
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      unawaited(
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        ),
      );
    }
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    _applySearch('');
    _searchFocusNode.requestFocus();
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
      init: _coursesController,
      tag: _controllerTag,
      builder: (controller) {
        final title = controller.type == 'popular'
            ? 'Popular'
            : controller.type == 'recommended'
            ? 'Recommended'
            : AppStrings.allCategory;
        return Scaffold(
          backgroundColor: AppColor.scaffoldBg,
          appBar: AppBar(
            backgroundColor: AppColor.scaffoldBg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              title,
              style: TextStyle(
                fontSize: AppTextSize.textSize24,
                fontWeight: FontWeight.w800,
                color: AppColor.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ),
          body: Column(
            children: [
              _buildSearchField(),
              Expanded(child: _buildResults(controller)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppPadding.pad20,
        AppPadding.pad10,
        AppPadding.pad20,
        AppPadding.pad8,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColor.cardBg,
          borderRadius: BorderRadius.circular(AppRadius.radius15),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          textInputAction: TextInputAction.search,
          onChanged: _scheduleSearch,
          onSubmitted: (value) {
            _debounce?.cancel();
            _applySearch(value);
          },
          onTapOutside: (_) => _searchFocusNode.unfocus(),
          decoration: InputDecoration(
            hintText: 'Search courses...',
            hintStyle: TextStyle(color: AppColor.textHint),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColor.textSecondary,
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, child) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  tooltip: 'Clear search',
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColor.textSecondary,
                  ),
                  onPressed: _clearSearch,
                );
              },
            ),
            filled: true,
            fillColor: AppColor.cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radius15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radius15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radius15),
              borderSide: BorderSide(
                color: AppColor.primaryColor.withValues(alpha: 0.45),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(CoursesControllerImp controller) {
    if (controller.requestStatus == RequestStatus.loading ||
        controller.requestStatus == RequestStatus.none) {
      return const CourseGridShimmerSkeleton();
    }

    if (controller.requestStatus != RequestStatus.success) {
      return _buildErrorState(controller);
    }

    if (controller.courses.isEmpty) {
      return _buildEmptyState(controller.searchQuery);
    }

    return Stack(
      children: [
        IgnorePointer(
          ignoring: controller.isSearching,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pad20,
                  vertical: AppPadding.pad10,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppWidth.w5,
                    crossAxisSpacing: AppWidth.w5,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate((
                    BuildContext context,
                    int index,
                  ) {
                    final course = controller.courses[index];
                    final courseId = _stringValue(course.id);
                    return CategorizedCourseItem(
                      courseName: _stringValue(
                        course.title,
                        fallback: 'Course',
                      ),
                      courseImage: _stringValue(course.thumbnail),
                      price: course.price ?? 0,
                      discountPrice: course.discountPrice,
                      rate: course.averageRating ?? 0,
                      totalTime: _formatDuration(course.totalDuration ?? 0),
                      isGridLayout: true,
                      onTap: () {
                        if (courseId.isEmpty) return;
                        Get.toNamed(
                          AppRoutesNames.exploreCourseScreen,
                          arguments: {'courseId': courseId},
                        );
                      },
                    );
                  }, childCount: controller.courses.length),
                ),
              ),
              if (controller.isLoadingMore || controller.hasLoadMoreError)
                SliverToBoxAdapter(child: _buildPaginationFooter(controller)),
            ],
          ),
        ),
        if (controller.isSearching)
          Positioned(
            top: 0,
            left: AppPadding.pad20,
            right: AppPadding.pad20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.radius20),
              child: LinearProgressIndicator(
                minHeight: 3,
                color: AppColor.primaryColor,
                backgroundColor: AppColor.primaryLight,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaginationFooter(CoursesControllerImp controller) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 64,
        child: Center(
          child: controller.isLoadingMore
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColor.primaryColor,
                  ),
                )
              : TextButton.icon(
                  onPressed: () => unawaited(controller.retryLoadMore()),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Couldn't load more. Retry"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColor.primaryColor,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    final isSearch = query.isNotEmpty;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppPadding.pad40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearch ? Icons.search_off_rounded : Icons.school_outlined,
              size: 56,
              color: AppColor.textHint,
            ),
            SizedBox(height: AppHeight.h12),
            Text(
              isSearch ? 'No courses found' : 'No courses available yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTextSize.textSize16,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
            if (isSearch) ...[
              SizedBox(height: AppHeight.h4),
              Text(
                'Try a different search or clear the current one.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppTextSize.textSize13,
                  color: AppColor.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(CoursesControllerImp controller) {
    final isOffline =
        controller.requestStatus == RequestStatus.offline ||
        controller.requestStatus == RequestStatus.noInternet;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppPadding.pad40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
              size: 56,
              color: AppColor.textHint,
            ),
            SizedBox(height: AppHeight.h12),
            Text(
              isOffline
                  ? AppStrings.youAreOffline.tr
                  : AppStrings.serverError.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTextSize.textSize16,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(height: AppHeight.h16),
            OutlinedButton.icon(
              onPressed: () => unawaited(controller.fetchFirstPage()),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.primaryColor,
                side: const BorderSide(color: AppColor.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
