import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/clipping.dart';

class BuyNowButton extends StatelessWidget {
  final void Function()? onTap;
  final String price;
  const BuyNowButton({
    super.key,
    required this.onTap,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipPath(
        clipper: Clipping(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.radius25),
          child: Container(
            height: AppHeight.h65,
            width: 1.sw / 1.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(AppRadius.radius25),
                topRight: Radius.circular(AppRadius.radius25),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 25,
                  color: AppColor.grayColor,
                ),
                BoxShadow(
                  color: AppColor.buttonColor,
                  spreadRadius: -5.0,
                  blurRadius: 25.0,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(left: AppPadding.pad30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.buyNow,
                    style: TextStyle(
                      color: AppColor.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppTextSize.textSize20,
                    ),
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       AppStrings.ffor,
                  //       style: TextStyle(
                  //         color: AppColor.whiteColor,
                  //         fontWeight: FontWeight.normal,
                  //         fontSize: AppTextSize.textSize14,
                  //       ),
                  //     ),
                  //     Text(
                  //       "LE $price",
                  //       style: TextStyle(
                  //         color: AppColor.starColor,
                  //         fontWeight: FontWeight.normal,
                  //         fontSize: AppTextSize.textSize14,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
