import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/auth_controller/signup_varification_controller.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/custom_auth_button.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';

class VarificationScreen extends StatelessWidget {
  const VarificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBg,
      resizeToAvoidBottomInset: true,
      body: GetBuilder<SignupVarificationControllerImpl>(
        init: Get.isRegistered<SignupVarificationControllerImpl>()
            ? Get.find<SignupVarificationControllerImpl>()
            : SignupVarificationControllerImpl(),
        builder: (controller) {
          final isLoading = controller.requestStatus == RequestStatus.loading;
          final canSubmit = controller.verificationCode.length == 6 && !isLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppHeight.h20),

                  // ── Back button ──
                  GestureDetector(
                    onTap: () => Get.offAllNamed(AppRoutesNames.loginScreen),
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

                  SizedBox(height: AppHeight.h40),

                  // ── Email icon ──
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColor.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      size: 32,
                      color: AppColor.primaryColor,
                    ),
                  ),

                  SizedBox(height: AppHeight.h24),

                  // ── Headline ──
                  Text(
                    "Verify your email",
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
                    AppStrings.emailSent,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize14,
                      fontWeight: FontWeight.w400,
                      color: AppColor.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  // Email address pill
                  if (controller.email != null &&
                      controller.email!.isNotEmpty) ...[
                    SizedBox(height: AppHeight.h12),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppPadding.pad12,
                        vertical: AppPadding.pad6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.radius20),
                      ),
                      child: Text(
                        controller.email!,
                        style: TextStyle(
                          fontSize: AppTextSize.textSize13,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: AppHeight.h40),

                  // ── OTP fields ──
                  OtpTextField(
                    numberOfFields: 6,
                    borderColor: AppColor.textHint.withValues(alpha: 0.4),
                    focusedBorderColor: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(AppRadius.radius12),
                    margin: EdgeInsets.symmetric(horizontal: AppMargin.margin5),
                    showFieldAsBox: true,
                    fieldWidth: (MediaQuery.of(context).size.width - AppPadding.pad24 * 2 - AppMargin.margin5 * 12) / 6,
                    textStyle: TextStyle(
                      fontSize: AppTextSize.textSize20,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                    onCodeChanged: controller.onCodeChanged,
                    onSubmit: controller.onCodeChanged,
                  ),

                  SizedBox(height: AppHeight.h40),

                  // ── Confirm button ──
                  CustomAuthButton(
                    name: AppStrings.confirm,
                    isLoading: isLoading,
                    onTap: canSubmit ? controller.onPressVerify : null,
                  ),

                  SizedBox(height: AppHeight.h24),

                  // ── Resend link ──
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.donNotAnyMails,
                          style: TextStyle(
                            fontSize: AppTextSize.textSize14,
                            color: AppColor.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: AppWidth.w4),
                        GestureDetector(
                          onTap: isLoading ? null : controller.onPressSendAgain,
                          child: Text(
                            AppStrings.sendAgain,
                            style: TextStyle(
                              fontSize: AppTextSize.textSize14,
                              color: isLoading
                                  ? AppColor.textHint
                                  : AppColor.primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppHeight.h40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
