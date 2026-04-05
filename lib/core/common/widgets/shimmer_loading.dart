import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/other_widgets/categorized_course_item.dart';

/// A single pulsing shimmer block used to build skeleton layouts.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColor.gray.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton that mimics a single horizontal course card.
class ShimmerCourseCard extends StatelessWidget {
  const ShimmerCourseCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.42;
    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: AppPadding.pad12),
      decoration: BoxDecoration(
        color: AppColor.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.radius15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          ShimmerBox(
            width: cardWidth,
            height: cardWidth * 0.65,
            borderRadius: AppRadius.radius15,
          ),
          Padding(
            padding: EdgeInsets.all(AppPadding.pad10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: cardWidth * 0.8, height: 12),
                SizedBox(height: AppHeight.h8),
                ShimmerBox(width: cardWidth * 0.5, height: 10),
                SizedBox(height: AppHeight.h12),
                ShimmerBox(width: cardWidth * 0.35, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full home screen skeleton: header shimmer + 3 section shimmers.
class HomeShimmerSkeleton extends StatefulWidget {
  const HomeShimmerSkeleton({super.key});

  @override
  State<HomeShimmerSkeleton> createState() => _HomeShimmerSkeletonState();
}

class _HomeShimmerSkeletonState extends State<HomeShimmerSkeleton>
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

  Widget _buildSectionSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppHeight.h24),
        // Section header skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerBox(width: 120, height: 18),
            ShimmerBox(width: 70, height: 28, borderRadius: 20),
          ],
        ),
        SizedBox(height: AppHeight.h12),
        // Cards row skeleton
        SizedBox(
          height: CategorizedCourseItem.cardHeight(context),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) => const ShimmerCourseCard(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.pad16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height:
                      MediaQuery.of(context).padding.top + AppHeight.h16),
              // Header skeleton
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 180, height: 24),
                        SizedBox(height: AppHeight.h8),
                        ShimmerBox(width: 130, height: 14),
                      ],
                    ),
                  ),
                  ShimmerBox(width: 44, height: 44, borderRadius: 22),
                  SizedBox(width: AppWidth.w10),
                  ShimmerBox(width: 44, height: 44, borderRadius: 22),
                ],
              ),
              // 3 section skeletons
              _buildSectionSkeleton(),
              _buildSectionSkeleton(),
              _buildSectionSkeleton(),
              SizedBox(height: AppHeight.h120),
            ],
          ),
        ),
      ),
    );
  }
}
