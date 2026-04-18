import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class CustomAuthButton extends StatelessWidget {
  final String name;
  final void Function()? onTap;
  final bool isLoading;

  const CustomAuthButton({
    super.key,
    required this.name,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onTap == null || isLoading;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: AppHeight.h56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: disabled
              ? AppColor.primaryColor.withValues(alpha: 0.5)
              : AppColor.primaryColor,
          borderRadius: BorderRadius.circular(AppRadius.radius12),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: AppColor.primaryColor.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
