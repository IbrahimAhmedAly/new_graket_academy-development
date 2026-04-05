import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/debug_print.dart';
import 'package:new_graket_acadimy/core/services/screen_security.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/auth_text_field.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/custom_auth_button.dart';

import '../../../controller/auth_controller/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    disableScreenSecurity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBg,
      resizeToAvoidBottomInset: true,
      body: GetBuilder<LoginControllerImpl>(
        init: Get.isRegistered<LoginControllerImpl>()
            ? Get.find<LoginControllerImpl>()
            : LoginControllerImpl(),
        assignId: true,
        builder: (controller) {
          final isLoading = controller.requestStatus == RequestStatus.loading;

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
                    "Welcome back",
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
                    AppStrings.enterYourInformationCarefully,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize14,
                      fontWeight: FontWeight.w400,
                      color: AppColor.textSecondary,
                    ),
                  ),

                  SizedBox(height: AppHeight.h40),

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

                  SizedBox(height: AppHeight.h8),

                  // ── Remember me + Forgot password ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: controller.rememberMe,
                              activeColor: AppColor.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              side: BorderSide(
                                color: AppColor.textHint,
                                width: 1.5,
                              ),
                              onChanged: (value) {
                                controller.toggleRememberMe(value ?? false);
                              },
                            ),
                          ),
                          SizedBox(width: AppWidth.w8),
                          Text(
                            AppStrings.rememberMe,
                            style: TextStyle(
                              fontSize: AppTextSize.textSize13,
                              fontWeight: FontWeight.w500,
                              color: AppColor.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          AppStrings.forgetPassword,
                          style: TextStyle(
                            fontSize: AppTextSize.textSize13,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppHeight.h32),

                  // ── Login button ──
                  CustomAuthButton(
                    name: AppStrings.login,
                    isLoading: isLoading,
                    onTap: isLoading
                        ? null
                        : () {
                            appPrint(AppStrings.login);
                            controller.onPressLogin();
                          },
                  ),

                  SizedBox(height: AppHeight.h24),

                  // ── Sign up link ──
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.donNotHaveAnAccount,
                          style: TextStyle(
                            fontSize: AppTextSize.textSize14,
                            color: AppColor.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutesNames.signUpScreen,
                            );
                          },
                          child: Text(
                            AppStrings.signUp,
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
