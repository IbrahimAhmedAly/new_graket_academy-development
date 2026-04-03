import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/auth_controller/signup_varification_controller.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/custom_auth_button.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';

class VarificationScreen extends StatelessWidget {
  const VarificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.whiteColor),
          onPressed: () => Get.offAllNamed(AppRoutesNames.loginScreen),
        ),
      ),
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: GetBuilder<SignupVarificationControllerImpl>(
        init: Get.isRegistered<SignupVarificationControllerImpl>()
            ? Get.find<SignupVarificationControllerImpl>()
            : SignupVarificationControllerImpl(),
        builder: (controller) {
          final isLoading = controller.requestStatus == RequestStatus.loading;
          final canSubmit = controller.verificationCode.length == 6 && !isLoading;

          return Container(
            alignment: Alignment.bottomCenter,
            width: double.maxFinite,
            height: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                    AssetsPath.login,
                  )),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                    height: AppHeight.h366,
                    width: double.maxFinite,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(AppPadding.pad15),
                          child: Column(
                            children: [
                              Text(
                                textAlign: TextAlign.center,
                                AppStrings.emailSent,
                                style: TextStyle(
                                  color: AppColor.headerTextColor,
                                  fontSize: AppTextSize.textSize14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              if (controller.email != null &&
                                  controller.email!.isNotEmpty)
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: AppPadding.pad8),
                                  child: Text(
                                    controller.email!,
                                    style: TextStyle(
                                      color: AppColor.grayColor,
                                      fontSize: AppTextSize.textSize12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppPadding.pad25),
                          child: OtpTextField(
                            numberOfFields: 6,
                            borderColor: AppColor.buttonColor,
                            focusedBorderColor: AppColor.buttonColor,
                            borderRadius: BorderRadius.all(
                                Radius.circular(AppRadius.radius15)),
                            margin: EdgeInsets.all(AppMargin.margin10),
                            showFieldAsBox: true,
                            onCodeChanged: controller.onCodeChanged,
                            onSubmit: controller.onCodeChanged,
                          ),
                        ),
                        CustomAuthButton(
                          name: isLoading
                              ? "${AppStrings.confirm}..."
                              : AppStrings.confirm,
                          onTap: canSubmit ? controller.onPressVerify : null,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppPadding.pad15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.donNotAnyMails,
                                style: TextStyle(
                                  fontSize: AppTextSize.textSize12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              InkWell(
                                onTap:
                                    isLoading ? null : controller.onPressSendAgain,
                                child: Text(
                                  AppStrings.sendAgain,
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
