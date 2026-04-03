import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/auth_controller/signup_controller.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/debug_print.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/agreement.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/auth_header.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/auth_text_field.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/custom_auth_button.dart';

import '../../../core/class/handling_view_data.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.whiteColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: GetBuilder<SignUpControllerImpl>(
        // Create the controller if dependency injection wasn't set up yet.
        init: Get.isRegistered<SignUpControllerImpl>()
            ? Get.find<SignUpControllerImpl>()
            : SignUpControllerImpl(),
        assignId: true,
        builder: (controller) {
          return Container(
            alignment: Alignment.bottomCenter,
            width: double.maxFinite,
            height: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                    AssetsPath.signup,
                  )),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AuthHeader(
                    name: AppStrings.signUp,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.radius25),
                        topRight: Radius.circular(AppRadius.radius25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.grayColor,
                        ),
                        BoxShadow(
                          color: AppColor.whiteColor,
                          spreadRadius: -5.0,
                          blurRadius: 40.0,
                        ),
                      ],
                    ),
                    height: AppHeight.h445,
                    width: double.maxFinite,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(AppPadding.pad15),
                          child: Text(
                            AppStrings.createYourNewAccount,
                            style: TextStyle(
                              color: AppColor.headerTextColor,
                              fontSize: AppTextSize.textSize14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        AuthTextField(
                          hintText: AppStrings.fullName,
                          isSecure: false,
                          textEditingController:
                              controller.fullNameTextEditingController,
                        ),
                        AuthTextField(
                          hintText: AppStrings.email,
                          isSecure: false,
                          textEditingController:
                              controller.emailTextEditingController,
                        ),
                        AuthTextField(
                          hintText: AppStrings.password,
                          isSecure: true,
                          textEditingController:
                              controller.passwordTextEditingController,
                        ),
                        Agreement(
                          isAgree: controller.isAgreementChecked,
                          agreementCheckFun: (value) {
                            controller.agreementCheckFun();
                          },
                          goToAgreementFun: () {},
                        ),
                        CustomAuthButton(
                          name: AppStrings.signUp,
                          onTap: controller.isAgreementChecked == false
                              ? null
                              : () {
                                  controller.onPressSignUp();
                                },
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppPadding.pad15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.alreadyHaveAnAccount,
                                style: TextStyle(
                                  fontSize: AppTextSize.textSize12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRoutesNames.loginScreen);
                                },
                                child: Text(
                                  AppStrings.login,
                                  style: TextStyle(
                                    fontSize: AppTextSize.textSize13,
                                    color: AppColor.headerTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
