import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/constants/image_assets.dart';

class CategorizedCourseItem extends StatelessWidget {
  final String courseName;
  final String courseImage;
  final double price;
  final double? discountPrice;
  final double rate;
  final String totalTime;
  final void Function()? onTap;

  const CategorizedCourseItem({
    super.key,
    required this.courseName,
    required this.courseImage,
    required this.price,
    required this.discountPrice,
    required this.rate,
    required this.totalTime,
    this.onTap,
  });

  /// Height of the info section below the image.
  static double infoHeight(BuildContext context) => 80;

  /// Total card height for use by parent lists.
  static double cardHeight(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.42;
    return cardWidth * 0.65 + infoHeight(context);
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.42;
    final imageHeight = cardWidth * 0.65;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: imageHeight + infoHeight(context),
        margin: EdgeInsets.only(right: AppPadding.pad12),
        decoration: BoxDecoration(
          color: AppColor.cardBg,
          borderRadius: BorderRadius.circular(AppRadius.radius15),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image section ──
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.radius15),
              ),
              child: SizedBox(
                width: cardWidth,
                height: imageHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Course image
                    CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: courseImage,
                      placeholder: (context, url) => Container(
                        color: AppColor.primaryLight,
                        child: const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        AppImageAssets.courseErrorImage,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Subtle gradient overlay for badge readability
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [
                              Colors.black.withValues(alpha: 0.25),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Duration badge (top-left)
                    Positioned(
                      top: AppPadding.pad8,
                      left: AppPadding.pad8,
                      child: _Badge(
                        icon: Icons.access_time_rounded,
                        label: totalTime,
                        backgroundColor:
                            AppColor.textPrimary.withValues(alpha: 0.6),
                        foregroundColor: AppColor.whiteColor,
                      ),
                    ),

                    // Rating badge (top-right)
                    Positioned(
                      top: AppPadding.pad8,
                      right: AppPadding.pad8,
                      child: _Badge(
                        icon: Icons.star_rounded,
                        label: rate.toStringAsFixed(1),
                        backgroundColor: AppColor.starColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Info section ──
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pad10,
                  vertical: AppPadding.pad8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Course name
                    Text(
                      courseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize12,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    // Price row
                    _buildPriceRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    final hasDiscount = discountPrice != null && discountPrice! > 0;
    return Row(
      children: [
        if (hasDiscount) ...[
          Text(
            "${price.toStringAsFixed(0)} EGP",
            style: TextStyle(
              fontSize: AppTextSize.textSize10,
              fontWeight: FontWeight.w400,
              color: AppColor.textHint,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColor.textHint,
            ),
          ),
          SizedBox(width: AppWidth.sizeBox),
          Text(
            "${discountPrice!.toStringAsFixed(0)} EGP",
            style: TextStyle(
              fontSize: AppTextSize.textSize14,
              fontWeight: FontWeight.w700,
              color: AppColor.priceColor,
            ),
          ),
        ] else
          Text(
            "${price.toStringAsFixed(0)} EGP",
            style: TextStyle(
              fontSize: AppTextSize.textSize14,
              fontWeight: FontWeight.w700,
              color: AppColor.priceColor,
            ),
          ),
      ],
    );
  }
}

/// Small reusable pill badge for overlaying on images.
class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _Badge({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pad6,
        vertical: AppPadding.pad4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.radius20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foregroundColor, size: 11),
          SizedBox(width: AppWidth.w2),
          Text(
            label,
            style: TextStyle(
              fontSize: AppTextSize.textSize10,
              fontWeight: FontWeight.w700,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
