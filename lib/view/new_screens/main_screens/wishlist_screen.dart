import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/wishlist_controller.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/common/widgets/shimmer_loading.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/model/my_courses/get_my_courses_model.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WishlistController>(
      init: Get.isRegistered<WishlistController>()
          ? Get.find<WishlistController>()
          : WishlistController(),
      builder: (c) {
        // ── Loading state ──
        if (c.requestStatus == RequestStatus.loading && c.items.isEmpty) {
          return const _WishlistSkeleton();
        }

        // ── Error state ──
        if (c.requestStatus == RequestStatus.failed && c.items.isEmpty) {
          return _buildError(context, c);
        }

        // ── Empty / content ──
        return RefreshIndicator(
          color: AppColor.primaryColor,
          onRefresh: c.onRefresh,
          child: CustomScrollView(
            controller: c.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(context, c),
              ),
              if (c.items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppPadding.pad16,
                    AppPadding.pad12,
                    AppPadding.pad16,
                    AppPadding.pad100,
                  ),
                  sliver: SliverList.separated(
                    itemCount: c.items.length + (c.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppHeight.h12),
                    itemBuilder: (ctx, i) {
                      if (i >= c.items.length) {
                        return Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppPadding.pad16),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ),
                        );
                      }
                      final item = c.items[i];
                      return _WishlistCard(
                        item: item,
                        onTap: () {
                          final id = item.course?.id;
                          if (id == null || id.isEmpty) return;
                          HapticFeedback.selectionClick();
                          Get.toNamed(
                            AppRoutesNames.exploreCourseScreen,
                            arguments: {'courseId': id},
                          );
                        },
                        onRemove: () {
                          HapticFeedback.mediumImpact();
                          c.removeFromWishlist(item);
                        },
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

  Widget _buildHeader(BuildContext context, WishlistController c) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppPadding.pad24,
        MediaQuery.of(context).padding.top + AppPadding.pad16,
        AppPadding.pad24,
        AppPadding.pad8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.saved,
            style: TextStyle(
              fontSize: AppTextSize.textSize24,
              fontWeight: FontWeight.w800,
              color: AppColor.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: AppHeight.h4),
          Text(
            c.items.isEmpty
                ? 'Courses you save will appear here'
                : "${c.totalCount == 0 ? c.items.length : c.totalCount} ${(c.totalCount == 0 ? c.items.length : c.totalCount) == 1 ? 'course' : 'courses'}",
            style: TextStyle(
              fontSize: AppTextSize.textSize13,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppPadding.pad40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColor.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 48,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: AppHeight.h20),
            Text(
              'No saved courses yet',
              style: TextStyle(
                fontSize: AppTextSize.textSize16,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(height: AppHeight.h8),
            Text(
              'Tap the bookmark icon on any course to save it for later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTextSize.textSize13,
                color: AppColor.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppHeight.h24),
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
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(AppRadius.radius25),
                ),
                child: Text(
                  'Browse courses',
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
      ),
    );
  }

  Widget _buildError(BuildContext context, WishlistController c) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppPadding.pad40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 56, color: AppColor.textHint),
            SizedBox(height: AppHeight.h12),
            Text(
              "Couldn't load your saved courses",
              style: TextStyle(
                fontSize: AppTextSize.textSize14,
                color: AppColor.textSecondary,
              ),
            ),
            SizedBox(height: AppHeight.h16),
            GestureDetector(
              onTap: c.loadInitial,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pad24,
                  vertical: AppPadding.pad12,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(AppRadius.radius25),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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

// ─────────────────────────────────────────────────────────────
//  Card — shows thumbnail + title + meta + remove-bookmark button
// ─────────────────────────────────────────────────────────────
class _WishlistCard extends StatelessWidget {
  final Datum item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _WishlistCard({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  bool _isNetworkImage(String? value) {
    if (value == null || value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    final course = item.course;
    final title = course?.title ?? 'Course';
    final thumbnail = course?.thumbnail;
    final rating = (course?.averageRating ?? 0).toDouble();
    final totalReviews = course?.totalReviews ?? 0;
    final price = (course?.discountPrice ?? course?.price ?? 0).toDouble();
    final hasDiscount = course?.discountPrice != null &&
        (course?.price ?? 0) > (course?.discountPrice ?? 0);
    final originalPrice = (course?.price ?? 0).toDouble();

    return Material(
      color: AppColor.cardBg,
      borderRadius: BorderRadius.circular(AppRadius.radius15),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.radius15),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppPadding.pad12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.radius10),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: _isNetworkImage(thumbnail)
                      ? CachedNetworkImage(
                          imageUrl: thumbnail!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Image.asset(
                            AssetsPath.courseImage_1,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(AssetsPath.courseImage_1,
                          fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: AppWidth.w12),
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
                        color: AppColor.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: AppHeight.h6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColor.starColor, size: 14),
                        SizedBox(width: AppWidth.w4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: AppTextSize.textSize12,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        SizedBox(width: AppWidth.w4),
                        Text(
                          '($totalReviews)',
                          style: TextStyle(
                            fontSize: AppTextSize.textSize10,
                            color: AppColor.textHint,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppHeight.h6),
                    Row(
                      children: [
                        if (hasDiscount)
                          Padding(
                            padding: EdgeInsets.only(right: AppWidth.w8),
                            child: Text(
                              '${originalPrice.toStringAsFixed(0)} EGP',
                              style: TextStyle(
                                fontSize: AppTextSize.textSize12,
                                color: AppColor.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        Text(
                          price == 0
                              ? 'Free'
                              : '${price.toStringAsFixed(0)} EGP',
                          style: TextStyle(
                            fontSize: AppTextSize.textSize14,
                            fontWeight: FontWeight.w800,
                            color: AppColor.priceColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppWidth.w8),
              IconButton(
                icon: const Icon(
                  Icons.bookmark_rounded,
                  color: AppColor.primaryColor,
                ),
                tooltip: 'Remove from saved',
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Skeleton
// ─────────────────────────────────────────────────────────────
class _WishlistSkeleton extends StatelessWidget {
  const _WishlistSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppPadding.pad24,
        MediaQuery.of(context).padding.top + AppPadding.pad16,
        AppPadding.pad24,
        AppPadding.pad16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 120, height: 28),
          SizedBox(height: AppHeight.h6),
          ShimmerBox(width: 180, height: 14),
          SizedBox(height: AppHeight.h20),
          for (int i = 0; i < 4; i++) ...[
            ShimmerBox(
              width: double.infinity,
              height: 120,
              borderRadius: 15,
            ),
            SizedBox(height: AppHeight.h12),
          ],
        ],
      ),
    );
  }
}
