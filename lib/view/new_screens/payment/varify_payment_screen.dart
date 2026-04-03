import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/debug_print.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/routing/extention.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/custom_auth_button.dart';

class VarifyPaymentScreen extends StatelessWidget {
  const VarifyPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        alignment: Alignment.bottomCenter,
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(
                AssetsPath.payment_2,
              )),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.radius25),
                  topRight: Radius.circular(AppRadius.radius25),
                ),
                clipBehavior: Clip.hardEdge,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.radius25),
                        topRight: Radius.circular(AppRadius.radius25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.blackColor.withOpacity(0.05),
                          offset: Offset(0, -5),
                          blurRadius: 10,
                          spreadRadius: -5,
                        ),
                        BoxShadow(
                          color: AppColor.whiteColor.withOpacity(0.1),
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
                            spacing: AppPadding.pad6,
                            children: [
                              Text(
                                textAlign: TextAlign.center,
                                AppStrings.verificationCode,
                                style: TextStyle(
                                  color: AppColor.grayColor,
                                  fontSize: AppTextSize.textSize32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                textAlign: TextAlign.center,
                                AppStrings.paymentCodeSent,
                                style: TextStyle(
                                  color: AppColor.blackColor,
                                  fontSize: AppTextSize.textSize14,
                                  fontWeight: FontWeight.normal,
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
                          onCodeChanged: (String code) {},
                          onSubmit: (String verificationCode) {},
                        ),
                        ),
                        CustomAuthButton(
                          name: AppStrings.confirm,
                          onTap: () {
                            appPrint(AppStrings.confirm);
                            context
                                .pushNamed(AppRoutesNames.paymentSuccessScreen);
                          },
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppPadding.pad15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.dontHaveAnyCode,
                                style: TextStyle(
                                  fontSize: AppTextSize.textSize12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  appPrint(AppStrings.sendAgain);
                                },
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
