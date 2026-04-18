import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/basket_controller.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/common/widgets/shimmer_loading.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/main_widgets/basket_item.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';

class BasketScreen extends StatelessWidget {
  const BasketScreen({super.key});

  String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final result = value is String ? value : value.toString();
    return result.isEmpty ? fallback : result;
  }

  double _doubleValue(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  int _intValue(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) return "0 h";
    if (minutes < 60) return "${minutes} m";
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins == 0 ? "${hours} h" : "${hours} h ${mins} m";
  }

  Map<String, dynamic> _extractCourse(Map<String, dynamic> item) {
    final course = item['course'];
    if (course is Map) return Map<String, dynamic>.from(course);
    return item;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BasketController>(
      init: Get.isRegistered<BasketController>()
          ? Get.find<BasketController>()
          : BasketController(),
      builder: (controller) {
        // Loading
        if (controller.requestStatus == RequestStatus.loading) {
          return const _BasketSkeleton();
        }

        // Empty state
        if (controller.items.isEmpty) {
          return _buildEmptyState(context, controller);
        }

        // Content
        return _buildContent(context, controller);
      },
    );
  }

  Widget _buildContent(BuildContext context, BasketController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top + AppHeight.h16),

        // ── Header ──
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.basket,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize24,
                      fontWeight: FontWeight.w800,
                      color: AppColor.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: AppHeight.h4),
                  Text(
                    "${controller.basketCount} ${controller.basketCount == 1 ? 'course' : 'courses'}",
                    style: TextStyle(
                      fontSize: AppTextSize.textSize13,
                      fontWeight: FontWeight.w400,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: controller.clearBasket,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppPadding.pad12,
                    vertical: AppPadding.pad8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.errorColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.radius20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: AppColor.errorColor,
                      ),
                      SizedBox(width: AppWidth.w4),
                      Text(
                        "Clear",
                        style: TextStyle(
                          fontSize: AppTextSize.textSize13,
                          fontWeight: FontWeight.w600,
                          color: AppColor.errorColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: AppHeight.h20),

        // ── Items list ──
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              final course = _extractCourse(item);
              final courseName = _stringValue(
                course['title'] ?? course['name'],
                fallback: 'Course',
              );
              final courseImage = _stringValue(
                course['thumbnail'] ?? course['cover'] ?? course['image'],
                fallback: AssetsPath.courseImage_1,
              );
              final price = _doubleValue(
                course['discountPrice'] ?? course['price'],
              );
              final rate = _doubleValue(
                course['averageRating'] ?? course['rating'],
              );
              final duration = _intValue(
                course['totalDuration'] ?? course['hours'],
              );
              final courseId = _stringValue(course['id'] ?? course['_id']);

              return BasketItem(
                courseName: courseName,
                courseImage: courseImage,
                price: price,
                rate: rate,
                totalTime: _formatDuration(duration),
                onRemove: courseId.isEmpty
                    ? null
                    : () => controller.removeFromBasket(courseId),
                onTapExplor: courseId.isEmpty
                    ? null
                    : () => Get.toNamed(
                          AppRoutesNames.exploreCourseScreen,
                          arguments: {'courseId': courseId},
                        ),
              );
            },
          ),
        ),

        // ── Order Summary + Checkout ──
        Container(
          padding: EdgeInsets.fromLTRB(
            AppPadding.pad24,
            AppPadding.pad16,
            AppPadding.pad24,
            MediaQuery.of(context).padding.bottom + AppPadding.pad8,
          ),
          decoration: BoxDecoration(
            color: AppColor.cardBg,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.radius25),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryColor.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subtotal
              _summaryRow(
                "Subtotal",
                "${controller.totalPrice.toStringAsFixed(0)} EGP",
                isMain: false,
              ),
              if (controller.savings > 0) ...[
                SizedBox(height: AppHeight.h8),
                _summaryRow(
                  "Discount",
                  "- ${controller.savings.toStringAsFixed(0)} EGP",
                  isMain: false,
                  valueColor: AppColor.priceColor,
                ),
              ],
              SizedBox(height: AppHeight.h8),
              Divider(height: 1, color: AppColor.scaffoldBg),
              SizedBox(height: AppHeight.h12),
              // Total
              _summaryRow(
                "Total",
                "${controller.totalDiscountPrice.toStringAsFixed(0)} EGP",
                isMain: true,
              ),

              SizedBox(height: AppHeight.h20),

              // ── Checkout button ──
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutesNames.paymentWayScreen);
                },
                child: Container(
                  width: double.infinity,
                  height: AppHeight.h44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(AppRadius.radius12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primaryColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: AppWidth.w8),
                      Text(
                        "Checkout",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    required bool isMain,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMain ? AppTextSize.textSize16 : AppTextSize.textSize14,
            fontWeight: isMain ? FontWeight.w700 : FontWeight.w400,
            color: isMain ? AppColor.textPrimary : AppColor.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isMain ? AppTextSize.textSize18 : AppTextSize.textSize14,
            fontWeight: isMain ? FontWeight.w800 : FontWeight.w500,
            color: valueColor ??
                (isMain ? AppColor.textPrimary : AppColor.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, BasketController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top + AppHeight.h16),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
          child: Text(
            AppStrings.basket,
            style: TextStyle(
              fontSize: AppTextSize.textSize24,
              fontWeight: FontWeight.w800,
              color: AppColor.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ),

        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppPadding.pad40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColor.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_basket_outlined,
                      size: 36,
                      color: AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: AppHeight.h20),
                  Text(
                    "Your basket is empty",
                    style: TextStyle(
                      fontSize: AppTextSize.textSize18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppHeight.h8),
                  Text(
                    "Browse courses and add them\nto your basket to get started.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize14,
                      fontWeight: FontWeight.w400,
                      color: AppColor.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: AppHeight.h24),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        AppRoutesNames.coursesScreen,
                        arguments: {'type': 'all'},
                      );
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
                        "Browse Courses",
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
          ),
        ),
      ],
    );
  }
}

// ── Skeleton loading ──
class _BasketSkeleton extends StatefulWidget {
  const _BasketSkeleton();

  @override
  State<_BasketSkeleton> createState() => _BasketSkeletonState();
}

class _BasketSkeletonState extends State<_BasketSkeleton>
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

  Widget _itemSkeleton() {
    return Container(
      margin: EdgeInsets.only(bottom: AppPadding.pad12),
      padding: EdgeInsets.all(AppPadding.pad12),
      decoration: BoxDecoration(
        color: AppColor.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.radius15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 80, height: 80, borderRadius: 12),
          SizedBox(width: AppWidth.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 14),
                SizedBox(height: AppHeight.h8),
                ShimmerBox(width: 140, height: 12),
                SizedBox(height: AppHeight.h16),
                ShimmerBox(width: 100, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + AppHeight.h16),

          // Title skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 100, height: 24),
                SizedBox(height: AppHeight.h4),
                ShimmerBox(width: 70, height: 13),
              ],
            ),
          ),

          SizedBox(height: AppHeight.h20),

          // Items skeleton
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
              child: Column(
                children: [
                  _itemSkeleton(),
                  _itemSkeleton(),
                  _itemSkeleton(),
                ],
              ),
            ),
          ),

          // Summary skeleton
          Container(
            padding: EdgeInsets.all(AppPadding.pad24),
            decoration: BoxDecoration(
              color: AppColor.cardBg,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.radius25),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 70, height: 14),
                    ShimmerBox(width: 80, height: 14),
                  ],
                ),
                SizedBox(height: AppHeight.h12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 50, height: 18),
                    ShimmerBox(width: 90, height: 18),
                  ],
                ),
                SizedBox(height: AppHeight.h20),
                ShimmerBox(
                  width: double.infinity,
                  height: AppHeight.h56,
                  borderRadius: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
