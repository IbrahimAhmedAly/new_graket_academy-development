import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/debug_print.dart';
import 'package:new_graket_acadimy/core/services/screen_security.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/auth_header.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/auth_text_field.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/custom_auth_button.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/remember_forget.dart';

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
  //
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      body: Container(
        alignment: Alignment.bottomCenter,
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage(AssetsPath.login),
          ),
        ),
        child: GetBuilder<LoginControllerImpl>(
          // Provide a local fallback so the widget does not crash if the
          // controller wasn't registered in an initial binding.
          init: Get.isRegistered<LoginControllerImpl>()
              ? Get.find<LoginControllerImpl>()
              : LoginControllerImpl(),
          assignId: true,
          builder: (controller) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AuthHeader(name: AppStrings.login),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.radius25),
                      topRight: Radius.circular(AppRadius.radius25),
                    ),
                    boxShadow: [
                      BoxShadow(color: AppColor.grayColor),
                      BoxShadow(
                        color: AppColor.whiteColor,
                        spreadRadius: -5.0,
                        blurRadius: 40.0,
                      ),
                    ],
                  ),
                  height: AppHeight.h366,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(AppPadding.pad15),
                        child: Text(
                          AppStrings.enterYourInformationCarefully,
                          style: TextStyle(
                            color: AppColor.headerTextColor,
                            fontSize: AppTextSize.textSize14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
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
                      RememberForget(
                        rememberMeState: controller.rememberMe,
                        onChanged: (value) {
                          controller.toggleRememberMe(value ?? false);
                        },
                        onTap: () {},
                      ),
                      CustomAuthButton(
                        name: AppStrings.login,
                        onTap: () {
                          appPrint(AppStrings.login);
                          controller.onPressLogin();
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppPadding.pad15,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.donNotHaveAnAccount,
                              style: TextStyle(
                                fontSize: AppTextSize.textSize13,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutesNames.signUpScreen,
                                );
                              },
                              child: Text(
                                AppStrings.signUp,
                                style: TextStyle(
                                  fontSize: AppTextSize.textSize13,
                                  color: AppColor.headerTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
