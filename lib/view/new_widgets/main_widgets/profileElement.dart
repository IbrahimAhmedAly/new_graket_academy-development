import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class Profileelement extends StatelessWidget {
  final String elementName;
  final IconData icon;
  final Color iconColor;
  final void Function()? onTap;
  final bool isDestructive;

  const Profileelement({
    super.key,
    required this.elementName,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppPadding.pad12),
        child: Row(
          children: [
            // ── Icon container ──
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColor.errorColor.withValues(alpha: 0.1)
                    : iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.radius12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColor.errorColor : iconColor,
                size: 20,
              ),
            ),
            SizedBox(width: AppWidth.w12),
            // ── Label ──
            Expanded(
              child: Text(
                elementName,
                style: TextStyle(
                  fontSize: AppTextSize.textSize15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppColor.errorColor : AppColor.textPrimary,
                ),
              ),
            ),
            // ── Chevron ──
            if (!isDestructive)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColor.textHint,
              ),
          ],
        ),
      ),
    );
  }
}
