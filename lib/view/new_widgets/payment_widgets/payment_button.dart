import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class PaymentButton extends StatelessWidget {
  final String imagePath;
  final void Function()? onTap;

  const PaymentButton({super.key, required this.imagePath, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: AppHeight.h32,
        width: AppWidth.w98,
        decoration: BoxDecoration(
          color: AppColor.buttonColor,
          borderRadius: BorderRadius.circular(AppRadius.radius15),
          boxShadow: [
            BoxShadow(
              color: AppColor.whiteColor.withOpacity(0.8),
              offset: Offset(-2, -2),
              blurRadius: 2,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: AppColor.blackColor.withOpacity(0.2),
              offset: Offset(5, 5),
              blurRadius: 10,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: AppHeight.h32,
              width: AppWidth.w98,
              decoration: BoxDecoration(
                color: _paymentButtonColor(imagePath),
                borderRadius: BorderRadius.circular(AppRadius.radius15),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.whiteColor.withOpacity(0.8),
                    offset: Offset(-2, -2),
                    blurRadius: 2,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: AppColor.blackColor.withOpacity(0.2),
                    offset: Offset(5, 5),
                    blurRadius: 10,
                    spreadRadius: -5,
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              imagePath,
              fit: BoxFit.scaleDown,
            ),
          ],
        ),
      ),
    );
  }

  Color _paymentButtonColor(String imagePath) {
    switch (imagePath) {
      case AssetsPath.amanLogo:
        return Colors.blue;
      case AssetsPath.vodafoneLogo:
        return Colors.red;
      case AssetsPath.fawryLogo:
        return Colors.yellowAccent;
      default:
        return AppColor.buttonColor;
    }
  }
}
