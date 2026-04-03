import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/debug_print.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/routing/extention.dart';
import 'package:new_graket_acadimy/view/new_widgets/payment_widgets/payment_button.dart';
import 'package:phone_form_field/phone_form_field.dart';

class PaymentWayScreen extends StatelessWidget {
  const PaymentWayScreen({super.key});

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
            image: AssetImage(AssetsPath.payment_1),
          ),
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
                    height: AppHeight.h400,
                    width: double.maxFinite,
                    child: Column(
                      spacing: AppPadding.pad10,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(AppPadding.pad15),
                          child: Column(
                            spacing: AppPadding.pad6,
                            children: [
                              Text(
                                textAlign: TextAlign.center,
                                AppStrings.buyCourseNow,
                                style: TextStyle(
                                  color: AppColor.grayColor,
                                  fontSize: AppTextSize.textSize32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                textAlign: TextAlign.center,
                                AppStrings.buyCourseNowDescription,
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
                            padding: EdgeInsets.symmetric(
                                vertical: AppPadding.pad25,
                                horizontal: AppPadding.pad25),
                            child: PhoneFormField(
                              initialValue: PhoneNumber.parse(
                                  '+20'), // or use the controller
                              validator: PhoneValidator.compose([
                                PhoneValidator.validMobile(context,
                                    errorText:
                                        "You must enter a valid phone number"),
                              ]),
                              countrySelectorNavigator:
                                  const CountrySelectorNavigator.page(),
                              onChanged: (phoneNumber) =>
                                  print('changed into $phoneNumber'),
                              enabled: true,
                              isCountrySelectionEnabled: true,
                              isCountryButtonPersistent: true,
                              countryButtonStyle: const CountryButtonStyle(
                                  showDialCode: true,
                                  showIsoCode: true,
                                  showFlag: true,
                                  flagSize: 16),
                            )),
                        Column(
                          spacing: AppPadding.pad10,
                          children: [
                            Row(
                              spacing: AppPadding.pad10,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PaymentButton(
                                  imagePath: AssetsPath.vodafoneLogo,
                                  onTap: () {
                                    appPrint("Vodafone Payment Confirmed");
                                    context.pushNamed(
                                        AppRoutesNames.varifyPaymentScreen);
                                  },
                                ),
                                PaymentButton(
                                  imagePath: AssetsPath.amanLogo,
                                  onTap: () {
                                    appPrint("Aman Payment Confirmed");
                                    context.pushNamed(
                                        AppRoutesNames.varifyPaymentScreen);
                                  },
                                ),
                              ],
                            ),
                            PaymentButton(
                              imagePath: AssetsPath.fawryLogo,
                              onTap: () {
                                appPrint("Fawry Payment Confirmed");
                                context.pushNamed(
                                    AppRoutesNames.varifyPaymentScreen);
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: AppHeight.h32,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppPadding.pad15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.youAlreadyPay,
                                style: TextStyle(
                                  fontSize: AppTextSize.textSize12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  appPrint(AppStrings.skipThis);
                                },
                                child: Text(
                                  AppStrings.skipThis,
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
