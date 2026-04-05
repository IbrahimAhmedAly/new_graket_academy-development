import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/auth_controller/signup_controller.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/auth_text_field.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/custom_auth_button.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBg,
      resizeToAvoidBottomInset: true,
      body: GetBuilder<SignUpControllerImpl>(
        init: Get.isRegistered<SignUpControllerImpl>()
            ? Get.find<SignUpControllerImpl>()
            : SignUpControllerImpl(),
        assignId: true,
        builder: (controller) {
          final isLoading = controller.requestStatus == RequestStatus.loading;
          final canSubmit = controller.isAgreementChecked && !isLoading;

          return SafeArea(
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

                  // ── Headline ──
                  Text(
                    "Create account",
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
                    AppStrings.createYourNewAccount,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize14,
                      fontWeight: FontWeight.w400,
                      color: AppColor.textSecondary,
                    ),
                  ),

                  SizedBox(height: AppHeight.h40),

                  // ── Full name field ──
                  AuthTextField(
                    label: AppStrings.fullName,
                    hintText: AppStrings.fullName,
                    isSecure: false,
                    keyboardType: TextInputType.name,
                    textEditingController:
                        controller.fullNameTextEditingController,
                  ),

                  SizedBox(height: AppHeight.h4),

                  // ── Email field ──
                  AuthTextField(
                    label: AppStrings.email,
                    hintText: AppStrings.email,
                    isSecure: false,
                    keyboardType: TextInputType.emailAddress,
                    textEditingController:
                        controller.emailTextEditingController,
                  ),

                  SizedBox(height: AppHeight.h4),

                  // ── Password field ──
                  AuthTextField(
                    label: AppStrings.password,
                    hintText: AppStrings.password,
                    isSecure: true,
                    textEditingController:
                        controller.passwordTextEditingController,
                  ),

                  SizedBox(height: AppHeight.h16),

                  // ── Agreement row ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: controller.isAgreementChecked,
                          activeColor: AppColor.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          side: BorderSide(
                            color: AppColor.textHint,
                            width: 1.5,
                          ),
                          onChanged: (value) {
                            controller.agreementCheckFun();
                          },
                        ),
                      ),
                      SizedBox(width: AppWidth.w8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: AppTextSize.textSize13,
                                fontWeight: FontWeight.w400,
                                color: AppColor.textSecondary,
                              ),
                              children: [
                                TextSpan(text: AppStrings.iAgree),
                                TextSpan(
                                  text: "terms and policy",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppHeight.h32),

                  // ── Sign up button ──
                  CustomAuthButton(
                    name: AppStrings.signUp,
                    isLoading: isLoading,
                    onTap: canSubmit
                        ? () {
                            controller.onPressSignUp();
                          }
                        : null,
                  ),

                  SizedBox(height: AppHeight.h24),

                  // ── Login link ──
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAnAccount,
                          style: TextStyle(
                            fontSize: AppTextSize.textSize14,
                            color: AppColor.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: AppWidth.w4),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutesNames.loginScreen,
                            );
                          },
                          child: Text(
                            AppStrings.login,
                            style: TextStyle(
                              fontSize: AppTextSize.textSize14,
                              color: AppColor.primaryColor,
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
