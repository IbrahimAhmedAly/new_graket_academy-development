import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

/// A large, tappable option row used by the onboarding pickers.
/// Selected state is carried by the border, tint and trailing check.
class EducationOptionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const EducationOptionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.pad16,
          vertical: AppPadding.pad16,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primaryLight : AppColor.cardBg,
          borderRadius: BorderRadius.circular(AppRadius.radius15),
          border: Border.all(
            color: isSelected
                ? AppColor.primaryColor
                : AppColor.textHint.withValues(alpha: 0.25),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColor.primaryColor.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Leading icon badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColor.primaryColor
                    : AppColor.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.radius12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.white : AppColor.primaryColor,
              ),
            ),
            SizedBox(width: AppWidth.w16),

            // Title + optional subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize16,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    SizedBox(height: AppHeight.h4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize13,
                        fontWeight: FontWeight.w400,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? AppColor.primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColor.primaryColor
                      : AppColor.textHint.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
