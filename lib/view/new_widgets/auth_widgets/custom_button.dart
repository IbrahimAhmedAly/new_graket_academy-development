import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/clipping.dart';

class CustomButton extends StatelessWidget {
  final void Function()? onTap;
  final String name;
  const CustomButton({
    super.key,
    this.onTap,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipPath(
        clipper: Clipping(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            height: 80,
            width: MediaQuery.of(context).size.width / 1.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 25,
                  color: const Color.fromARGB(255, 97, 97, 97),
                ),
                BoxShadow(
                  color: name == AppStrings.complete ? AppColor.whiteColor : AppColor.buttonColor,
                  spreadRadius: -5.0,
                  blurRadius: 25.0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 40, top: 20),
              child: Text(
                textAlign: TextAlign.center,
                name,
                style: TextStyle(
                  color: name == AppStrings.complete ? AppColor.buttonColor : AppColor.whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
