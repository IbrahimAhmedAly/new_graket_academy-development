import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_dimentions.dart';
import '../../constants/app_strings.dart';
import '../../constants/colors.dart';
import '../../services/screen_protection_service.dart';

/// Covers the whole app while the screen is being recorded, shared or
/// mirrored, so a capture shows this notice instead of course content.
///
/// Lives in GetMaterialApp's builder, above the navigator, so dialogs and
/// bottom sheets are covered too. The app underneath stays mounted: when the
/// capture stops, the student is back exactly where they were.
class ScreenCaptureShield extends StatelessWidget {
  final Widget child;

  const ScreenCaptureShield({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final protection = ScreenProtectionService.instance;
    if (protection == null) return child;

    return Obx(
      () => Stack(
        children: [
          child,
          if (protection.isCaptured.value)
            const Positioned.fill(child: _CaptureNotice()),
        ],
      ),
    );
  }
}

class _CaptureNotice extends StatelessWidget {
  const _CaptureNotice();

  @override
  Widget build(BuildContext context) {
    // Opaque and on top: taps can't reach the app, and screen readers only
    // announce the notice.
    return BlockSemantics(
      child: Material(
        color: AppColor.scaffoldBg,
        child: SafeArea(
          child: Center(
            // Scrolls instead of overflowing on short landscape screens or
            // with large accessibility text.
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppPadding.pad24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.videocam_off_rounded,
                    size: 64,
                    color: AppColor.primaryColor,
                  ),
                  SizedBox(height: AppHeight.h16),
                  Text(
                    AppStrings.screenCaptureBlockedTitle.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize18,
                      fontWeight: FontWeight.w800,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppHeight.h12),
                  Text(
                    AppStrings.screenCaptureBlockedMessage.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize14,
                      color: AppColor.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
