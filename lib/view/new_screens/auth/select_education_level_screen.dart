import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/auth_controller/education_onboarding_controller.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/model/education/education_levels_model.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/custom_auth_button.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/education_option_card.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/onboarding_step_header.dart';

/// Step 1 of 2 — the student picks their education level.
class SelectEducationLevelScreen extends StatelessWidget {
  const SelectEducationLevelScreen({super.key});

  /// Picks an icon that reads at a glance for the common level names,
  /// with a sensible fallback for anything the admin adds later.
  IconData _iconForLevel(String? name) {
    final value = (name ?? '').toLowerCase();
    if (value.contains('universit') || value.contains('جامع')) {
      return Icons.school_rounded;
    }
    if (value.contains('middle') || value.contains('اعداد') ||
        value.contains('إعداد') || value.contains('متوسط')) {
      return Icons.menu_book_rounded;
    }
    if (value.contains('primary') || value.contains('ابتدائ')) {
      return Icons.auto_stories_rounded;
    }
    if (value.contains('secondary') || value.contains('ثانو')) {
      return Icons.history_edu_rounded;
    }
    return Icons.school_outlined;
  }

  String? _gradesSubtitle(EducationLevelDatum level) {
    final count = level.grades.length;
    if (count == 0) return null;
    return '$count ${count == 1 ? 'grade' : 'grades'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBg,
      body: GetBuilder<EducationOnboardingController>(
        init: Get.isRegistered<EducationOnboardingController>()
            ? Get.find<EducationOnboardingController>()
            : EducationOnboardingController(),
        builder: (controller) {
          return SafeArea(
            child: Column(
              children: [
                // ── Header ──
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppPadding.pad24),
                  child: OnboardingStepHeader(
                    step: 1,
                    totalSteps: 2,
                    title: "What's your education level?",
                    subtitle:
                        'Pick your level so we only show you the courses that fit.',
                    onBack: () => Get.back(),
                  ),
                ),

                SizedBox(height: AppHeight.h24),

                // ── Body ──
                Expanded(
                  child: _buildBody(controller),
                ),

                // ── Continue ──
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppPadding.pad24,
                    AppPadding.pad12,
                    AppPadding.pad24,
                    AppPadding.pad24,
                  ),
                  child: CustomAuthButton(
                    name: 'Continue',
                    isLoading: controller.isLoadingGrades,
                    onTap: controller.canContinueFromLevel &&
                            !controller.isLoadingGrades
                        ? () => controller.goToGradeStep()
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(EducationOnboardingController controller) {
    if (controller.requestStatus == RequestStatus.loading) {
      return Center(
        child: CircularProgressIndicator(color: AppColor.primaryColor),
      );
    }

    if (controller.requestStatus == RequestStatus.failed ||
        controller.levels.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: AppColor.textHint,
              ),
              SizedBox(height: AppHeight.h16),
              Text(
                controller.errorMessage ??
                    "Couldn't load education levels",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppTextSize.textSize14,
                  fontWeight: FontWeight.w500,
                  color: AppColor.textSecondary,
                ),
              ),
              SizedBox(height: AppHeight.h20),
              GestureDetector(
                onTap: controller.getEducationLevels,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppPadding.pad24,
                    vertical: AppPadding.pad12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primaryLight,
                    borderRadius:
                        BorderRadius.circular(AppRadius.radius12),
                  ),
                  child: Text(
                    'Try again',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize14,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
      itemCount: controller.levels.length,
      separatorBuilder: (_, __) => SizedBox(height: AppHeight.h12),
      itemBuilder: (context, index) {
        final level = controller.levels[index];
        return EducationOptionCard(
          title: level.name ?? '',
          subtitle: _gradesSubtitle(level),
          icon: _iconForLevel(level.name),
          isSelected: controller.selectedLevel?.id == level.id,
          onTap: () => controller.selectLevel(level),
        );
      },
    );
  }
}
