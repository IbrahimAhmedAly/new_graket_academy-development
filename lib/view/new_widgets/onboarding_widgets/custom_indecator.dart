import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class CustomIndecator extends StatelessWidget {
  final bool isActive;
  const CustomIndecator({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColor.primaryColor
            : AppColor.primaryColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
