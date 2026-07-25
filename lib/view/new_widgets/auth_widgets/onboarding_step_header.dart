import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

/// Back button + "Step N of total" progress bar + headline, shared by both
/// education onboarding steps so they stay visually identical.
class OnboardingStepHeader extends StatelessWidget {
  final int step;
  final int totalSteps;
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const OnboardingStepHeader({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppHeight.h20),

        // ── Back button ──
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColor.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.radius12),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColor.primaryColor,
            ),
          ),
        ),

        SizedBox(height: AppHeight.h24),

        // ── Progress: one segment per step ──
        Row(
          children: List.generate(totalSteps, (index) {
            final isDone = index < step;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == totalSteps - 1 ? 0 : AppWidth.w8,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColor.primaryColor
                        : AppColor.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.radius10),
                  ),
                ),
              ),
            );
          }),
        ),

        SizedBox(height: AppHeight.h12),

        Text(
          'Step $step of $totalSteps',
          style: TextStyle(
            fontSize: AppTextSize.textSize12,
            fontWeight: FontWeight.w600,
            color: AppColor.primaryColor,
          ),
        ),

        SizedBox(height: AppHeight.h20),

        // ── Headline ──
        Text(
          title,
          style: TextStyle(
            fontSize: AppTextSize.textSize24,
            fontWeight: FontWeight.w800,
            color: AppColor.textPrimary,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        SizedBox(height: AppHeight.h8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: AppTextSize.textSize14,
            fontWeight: FontWeight.w400,
            color: AppColor.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
