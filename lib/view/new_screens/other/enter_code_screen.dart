import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/courses/code_controller_impl.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/custom_auth_button.dart';

class EnterCodeScreen extends StatelessWidget {
  const EnterCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CodeControllerImpl>(
      builder: (controller) => Scaffold(
        backgroundColor: AppColor.scaffoldBg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppHeight.h20),

                // ── Back button ──
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
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

                // ── Icon ──
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColor.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.confirmation_number_outlined,
                    size: 32,
                    color: AppColor.primaryColor,
                  ),
                ),

                SizedBox(height: AppHeight.h24),

                // ── Headline ──
                Text(
                  "Enter Code",
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
                  "Enter your course activation code\nto unlock your content.",
                  style: TextStyle(
                    fontSize: AppTextSize.textSize14,
                    fontWeight: FontWeight.w400,
                    color: AppColor.textSecondary,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: AppHeight.h40),

                // ── Code field ──
                TextField(
                  controller: controller.codeTextController,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppTextSize.textSize18,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    hintText: "XXXX-XXXX-XXXX",
                    hintStyle: TextStyle(
                      fontSize: AppTextSize.textSize16,
                      fontWeight: FontWeight.w400,
                      color: AppColor.textHint,
                      letterSpacing: 2,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppPadding.pad16,
                      vertical: AppPadding.pad16,
                    ),
                    filled: true,
                    fillColor: AppColor.scaffoldBg,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.radius12),
                      borderSide: BorderSide(
                        color: AppColor.textHint.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.radius12),
                      borderSide: BorderSide(
                        color: AppColor.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: controller.onCodeChanged,
                ),

                SizedBox(height: AppHeight.h32),

                // ── Send button ──
                CustomAuthButton(
                  name: "Activate",
                  isLoading: controller.isLoading,
                  onTap: controller.isLoading ? null : controller.sendCode,
                ),

                // ── Inline error ──
                if (controller.errorMessage != null &&
                    controller.errorMessage!.isNotEmpty) ...[
                  SizedBox(height: AppHeight.h12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppPadding.pad16,
                      vertical: AppPadding.pad12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.errorColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.radius12),
                      border: Border.all(
                        color: AppColor.errorColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: AppColor.errorColor,
                          size: 18,
                        ),
                        SizedBox(width: AppWidth.w8),
                        Expanded(
                          child: Text(
                            controller.errorMessage!,
                            style: TextStyle(
                              fontSize: AppTextSize.textSize13,
                              fontWeight: FontWeight.w500,
                              color: AppColor.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
