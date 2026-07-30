import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/auth_controller/education_onboarding_controller.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/custom_auth_button.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/education_option_card.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/onboarding_step_header.dart';

/// Step 2 of 2 — the student picks a grade within the level chosen in step 1.
class SelectGradeScreen extends StatelessWidget {
  const SelectGradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBg,
      body: GetBuilder<EducationOnboardingController>(
        init: Get.isRegistered<EducationOnboardingController>()
            ? Get.find<EducationOnboardingController>()
            : EducationOnboardingController(),
        builder: (controller) {
          final levelName = controller.selectedLevel?.name ?? '';

          return SafeArea(
            child: Column(
              children: [
                // ── Header ──
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppPadding.pad24),
                  child: OnboardingStepHeader(
                    step: 2,
                    totalSteps: 2,
                    title: "What's your grade?",
                    subtitle:
                        'Choose your grade in $levelName to get the right courses.',
                    onBack: () => Get.back(),
                  ),
                ),

                SizedBox(height: AppHeight.h20),

                // ── Selected level chip ──
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppPadding.pad24),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppPadding.pad12,
                        vertical: AppPadding.pad8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primaryLight,
                        borderRadius:
                            BorderRadius.circular(AppRadius.radius100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 16,
                            color: AppColor.primaryColor,
                          ),
                          SizedBox(width: AppWidth.w8),
                          Text(
                            levelName,
                            style: TextStyle(
                              fontSize: AppTextSize.textSize13,
                              fontWeight: FontWeight.w700,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppHeight.h16),

                // ── Body ──
                Expanded(child: _buildBody(controller)),

                // ── Continue ──
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppPadding.pad24,
                    AppPadding.pad12,
                    AppPadding.pad24,
                    AppPadding.pad24,
                  ),
                  child: CustomAuthButton(
                    name: 'Continue to sign up',
                    onTap: controller.canContinueFromGrade
                        ? () => controller.goToSignUp()
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
    if (controller.isLoadingGrades) {
      return Center(
        child: CircularProgressIndicator(color: AppColor.primaryColor),
      );
    }

    if (controller.grades.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_rounded,
                size: 48,
                color: AppColor.textHint,
              ),
              SizedBox(height: AppHeight.h16),
              Text(
                'No grades available in this level yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppTextSize.textSize14,
                  fontWeight: FontWeight.w500,
                  color: AppColor.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
      itemCount: controller.grades.length,
      separatorBuilder: (_, __) => SizedBox(height: AppHeight.h12),
      itemBuilder: (context, index) {
        final grade = controller.grades[index];
        return EducationOptionCard(
          title: grade.name ?? '',
          icon: Icons.class_rounded,
          isSelected: controller.selectedGrade?.id == grade.id,
          onTap: () => controller.selectGrade(grade),
        );
      },
    );
  }
}
