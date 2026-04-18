import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/constants/image_assets.dart';

class BasketItem extends StatelessWidget {
  final String courseName;
  final String courseImage;
  final double price;
  final double rate;
  final String totalTime;
  final void Function()? onTapExplor;
  final void Function()? onRemove;

  const BasketItem({
    super.key,
    required this.courseName,
    required this.courseImage,
    required this.price,
    required this.rate,
    required this.totalTime,
    this.onTapExplor,
    this.onRemove,
  });

  bool _isNetworkImage(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapExplor,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: AppPadding.pad12),
        padding: EdgeInsets.all(AppPadding.pad12),
        decoration: BoxDecoration(
          color: AppColor.cardBg,
          borderRadius: BorderRadius.circular(AppRadius.radius15),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ──
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.radius12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: _isNetworkImage(courseImage)
                    ? CachedNetworkImage(
                        imageUrl: courseImage,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColor.primaryLight,
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Image.asset(
                          AppImageAssets.courseErrorImage,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(courseImage, fit: BoxFit.cover),
              ),
            ),

            SizedBox(width: AppWidth.w12),

            // ── Info ──
            Expanded(
              child: SizedBox(
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      courseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    // Meta row
                    Row(
                      children: [
                        // Rating
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColor.starColor,
                        ),
                        SizedBox(width: AppWidth.w2),
                        Text(
                          rate.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: AppTextSize.textSize12,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        SizedBox(width: AppWidth.w8),
                        // Duration
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: AppColor.textHint,
                        ),
                        SizedBox(width: AppWidth.w2),
                        Text(
                          totalTime,
                          style: TextStyle(
                            fontSize: AppTextSize.textSize12,
                            fontWeight: FontWeight.w400,
                            color: AppColor.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        // Price
                        Text(
                          "${price.toStringAsFixed(0)} EGP",
                          style: TextStyle(
                            fontSize: AppTextSize.textSize15,
                            fontWeight: FontWeight.w700,
                            color: AppColor.priceColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Remove button ──
            if (onRemove != null)
              GestureDetector(
                onTap: onRemove,
                child: Padding(
                  padding: EdgeInsets.only(left: AppPadding.pad4),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColor.errorColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColor.errorColor,
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
