import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/instructor/instructor_controller.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';

class InstructorProfileScreen extends StatelessWidget {
  const InstructorProfileScreen({super.key});

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
    final tag = _resolveTag();
    Get.put(InstructorControllerImp(), tag: tag);

    return GetBuilder<InstructorControllerImp>(
      tag: tag,
      builder: (c) {
        return Scaffold(
          backgroundColor: AppColor.scaffoldBg,
          appBar: AppBar(
            backgroundColor: AppColor.scaffoldBg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColor.textPrimary),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'Instructor',
              style: TextStyle(
                fontSize: AppTextSize.textSize16,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
            centerTitle: true,
          ),
          body: _buildBody(c),
        );
      },
    );
  }

  String _resolveTag() {
    final args = Get.arguments as Map? ?? {};
    final id = args['instructorId']?.toString() ??
        args['id']?.toString() ??
        'instructor';
    return 'instructor-$id';
  }

  Widget _buildBody(InstructorControllerImp c) {
    if (c.requestStatus == RequestStatus.loading && c.profile == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.primaryColor),
      );
    }
    if (c.requestStatus != RequestStatus.success && c.profile == null) {
      return _buildError(c);
    }

    return RefreshIndicator(
      color: AppColor.primaryColor,
      onRefresh: c.load,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(c)),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppPadding.pad16,
                AppPadding.pad16,
                AppPadding.pad16,
                AppPadding.pad8,
              ),
              child: Row(
                children: [
                  Text(
                    'Courses',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize16,
                      fontWeight: FontWeight.w800,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  SizedBox(width: AppWidth.w8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppPadding.pad8,
                      vertical: AppPadding.pad4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primaryLight,
                      borderRadius:
                          BorderRadius.circular(AppRadius.radius20),
                    ),
                    child: Text(
                      '${c.courses.length}',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize12,
                        fontWeight: FontWeight.w700,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (c.courses.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppPadding.pad40),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.folder_open_rounded,
                        size: 48,
                        color: AppColor.textHint,
                      ),
                      SizedBox(height: AppHeight.h12),
                      Text(
                        'No courses yet',
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
            )
          else
            SliverList.builder(
              itemCount: c.courses.length,
              itemBuilder: (ctx, i) =>
                  _buildCourseRow(context: ctx, course: c.courses[i]),
            ),
          SliverToBoxAdapter(child: SizedBox(height: AppHeight.h40)),
        ],
      ),
    );
  }

  Widget _buildHeader(InstructorControllerImp c) {
    final profile = c.profile;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppPadding.pad16,
        AppPadding.pad16,
        AppPadding.pad16,
        AppPadding.pad24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor.withValues(alpha: 0.08),
            AppColor.primaryColor.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          _buildAvatar(profile?.avatar, profile?.name ?? ''),
          SizedBox(height: AppHeight.h12),
          Text(
            profile?.name ?? 'Instructor',
            style: TextStyle(
              fontSize: AppTextSize.textSize20,
              fontWeight: FontWeight.w800,
              color: AppColor.textPrimary,
            ),
          ),
          if ((profile?.title ?? '').isNotEmpty) ...[
            SizedBox(height: AppHeight.h4),
            Text(
              profile!.title!,
              style: TextStyle(
                fontSize: AppTextSize.textSize13,
                color: AppColor.textHint,
              ),
            ),
          ],
          if ((profile?.bio ?? '').isNotEmpty) ...[
            SizedBox(height: AppHeight.h16),
            Text(
              profile!.bio!,
              textAlign: TextAlign.center,
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

  Widget _buildAvatar(String? avatarUrl, String name) {
    if (_isNetworkImage(avatarUrl)) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl!,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _initialsAvatar(name),
        ),
      );
    }
    return _initialsAvatar(name);
  }

  Widget _initialsAvatar(String name) {
    return Container(
      width: 96,
      height: 96,
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
          fontSize: AppTextSize.textSize24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildCourseRow({
    required BuildContext context,
    required InstructorCourseItem course,
  }) {
    final price = course.discountPrice ?? course.price ?? 0;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pad16,
        vertical: AppPadding.pad6,
      ),
      child: Material(
        color: AppColor.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.radius15),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.radius15),
          onTap: () {
            if (course.id.isEmpty) return;
            Get.toNamed(
              AppRoutesNames.exploreCourseScreen,
              arguments: {'courseId': course.id},
              preventDuplicates: false,
            );
          },
          child: Padding(
            padding: EdgeInsets.all(AppPadding.pad12),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.radius10),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: _isNetworkImage(course.thumbnail)
                        ? CachedNetworkImage(
                            imageUrl: course.thumbnail!,
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
                SizedBox(width: AppWidth.w12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTextSize.textSize13,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      if ((course.categoryName ?? '').isNotEmpty) ...[
                        SizedBox(height: AppHeight.h3),
                        Text(
                          course.categoryName!,
                          style: TextStyle(
                            fontSize: AppTextSize.textSize10,
                            color: AppColor.textHint,
                          ),
                        ),
                      ],
                      SizedBox(height: AppHeight.h6),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColor.starColor,
                            size: 14,
                          ),
                          SizedBox(width: AppWidth.w4),
                          Text(
                            (course.averageRating ?? 0).toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: AppTextSize.textSize12,
                              fontWeight: FontWeight.w700,
                              color: AppColor.textPrimary,
                            ),
                          ),
                          SizedBox(width: AppWidth.w4),
                          Text(
                            '(${course.totalReviews})',
                            style: TextStyle(
                              fontSize: AppTextSize.textSize10,
                              color: AppColor.textHint,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            price == 0 ? 'Free' : '${price.toStringAsFixed(0)} EGP',
                            style: TextStyle(
                              fontSize: AppTextSize.textSize13,
                              fontWeight: FontWeight.w800,
                              color: AppColor.priceColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(InstructorControllerImp c) {
    final msg = c.errorMessage.isNotEmpty
        ? c.errorMessage
        : AppStrings.serverError.tr;
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
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: AppHeight.h20),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTextSize.textSize15,
                color: AppColor.textSecondary,
              ),
            ),
            SizedBox(height: AppHeight.h20),
            GestureDetector(
              onTap: c.retry,
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
                  'Try Again',
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
