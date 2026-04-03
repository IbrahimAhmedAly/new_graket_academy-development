import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/debug_print.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/routing/extention.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/custom_button.dart';

class CongratulationPayment extends StatelessWidget {
  const CongratulationPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.all(Radius.circular(25)),

          image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(
                AssetsPath.congratePayment,
              )),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: AppPadding.pad15, horizontal: AppPadding.pad6),
              child: CustomButton(
                name: AppStrings.myCourses,
                onTap: () {
                  appPrint(AppStrings.myCourses);
                  context.pushNamed(AppRoutesNames.mainScreen, arguments: 0);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
