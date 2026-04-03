import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/onboarding_widgets/custom_indecator.dart';
import 'package:new_graket_acadimy/view/new_widgets/onboarding_widgets/onboard_page.dart';
import '../../../core/services/services.dart';
import '../../../routing/app_routes.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}


class _OnboardScreenState extends State<OnboardScreen> {
  late MyServices myServices;
  @override
  void initState() {
   myServices = Get.find();
    super.initState();
  }


  final PageController _controller = PageController();
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: AppColor.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (value) {
                setState(() {
                  index = value;
                });
              },
              children: [
                OnboardPage(imagePath: AssetsPath.onboarding_1),
                OnboardPage(imagePath: AssetsPath.onboarding_2),
                OnboardPage(imagePath: AssetsPath.onboarding_3),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppPadding.pad20, vertical: AppPadding.pad40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    myServices.sharedPreferences.setBool(AppSharedPrefKeys.firstTimeKey, false);
                    Navigator.pushNamedAndRemoveUntil(context,
                        AppRoutesNames.welcomeScreen, (route) => false);
                  },
                  child: Text(
                    AppStrings.skip,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: AppTextSize.textSize18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIndecator(isActive: index == 0),
                    SizedBox(width: AppWidth.sizeBox),
                    CustomIndecator(isActive: index == 1),
                    SizedBox(width: AppWidth.sizeBox),
                    CustomIndecator(isActive: index == 2),
                  ],
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.radius40),
                  onTap: () {
                    if (index == 2) {
                      myServices.sharedPreferences.setBool(AppSharedPrefKeys.firstTimeKey, false);
                      Navigator.pushNamedAndRemoveUntil(context,
                          AppRoutesNames.welcomeScreen, (route) => false);
                    }
                    _controller.animateToPage(
                      index + 1,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColor.buttonColor,
                      borderRadius: BorderRadius.circular(AppRadius.radius40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: index != 2
                        ? Icon(Icons.arrow_forward_ios,
                            color: AppColor.buttonTextColor, size: AppRadius.radius24)
                        : Text(
                            textAlign: TextAlign.center,
                            AppStrings.start,
                            style: TextStyle(
                              fontSize: AppTextSize.textSize16,
                              fontWeight: FontWeight.bold,
                              color: AppColor.buttonTextColor,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
