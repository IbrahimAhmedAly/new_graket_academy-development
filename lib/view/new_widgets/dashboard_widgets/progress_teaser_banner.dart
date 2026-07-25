import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimentions.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/colors.dart';
import '../../../routing/app_routes.dart';

/// Compact entry point to the progress dashboard, shown on the home screen.
///
/// Deliberately carries no numbers. Home loads before the reports call
/// returns, so showing a figure here would mean either blocking the home
/// screen on an extra request or flashing a placeholder value that changes
/// under the student a moment later.
class ProgressTeaserBanner extends StatelessWidget {
  const ProgressTeaserBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutesNames.progressDashboardScreen),
      child: Container(
        padding: EdgeInsets.all(AppPadding.pad16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primaryColor.withValues(alpha: 0.12),
              AppColor.accentBlue.withValues(alpha: 0.12),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.radius15),
          border: Border.all(
            color: AppColor.primaryColor.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColor.primaryColor, AppColor.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.radius12),
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            SizedBox(width: AppWidth.w12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your progress',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize15,
                      fontWeight: FontWeight.w700,
                      color: theme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppHeight.h4),
                  Text(
                    'Streak, study time and quiz results',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize12,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: theme.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
