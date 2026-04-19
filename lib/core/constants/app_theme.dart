import 'package:flutter/material.dart';
import 'colors.dart';

/// Dark-mode aware color provider.
///
/// The existing app wires everything to the static [AppColor] palette, which
/// is light-mode only. Rather than break every existing screen, this helper
/// lets new code ask for *theme-aware* variants via [AppTheme.of(context)].
/// Legacy widgets keep using [AppColor.*] unchanged and stay in their
/// original (light) palette; screens that want dark support simply switch to
/// the equivalent getter here.
class AppTheme {
  final Brightness brightness;
  const AppTheme._(this.brightness);

  factory AppTheme.of(BuildContext context) =>
      AppTheme._(Theme.of(context).brightness);

  bool get isDark => brightness == Brightness.dark;

  // ── Surfaces ──
  Color get scaffoldBg =>
      isDark ? const Color(0xFF121014) : AppColor.scaffoldBg;

  Color get cardBg => isDark ? const Color(0xFF1C1A21) : AppColor.cardBg;

  Color get surfaceBg => isDark ? const Color(0xFF242028) : AppColor.scaffoldBg;

  // ── Text ──
  Color get textPrimary =>
      isDark ? const Color(0xFFF4F2F8) : AppColor.textPrimary;

  Color get textSecondary =>
      isDark ? const Color(0xFFB4B0BD) : AppColor.textSecondary;

  Color get textHint => isDark ? const Color(0xFF7D7889) : AppColor.textHint;

  // ── Borders / dividers ──
  Color get divider => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : AppColor.gray.withValues(alpha: 0.15);

  Color get border => isDark
      ? Colors.white.withValues(alpha: 0.12)
      : AppColor.gray.withValues(alpha: 0.2);

  // ── Accents (kept consistent across themes — brand color) ──
  Color get primary => AppColor.primaryColor;
  Color get primaryLight => isDark
      ? AppColor.primaryColor.withValues(alpha: 0.18)
      : AppColor.primaryLight;
  Color get primaryDark => AppColor.primaryDark;
  Color get green => AppColor.greenColor;
  Color get star => AppColor.starColor;
  Color get error => AppColor.errorColor;
  Color get price => isDark ? const Color(0xFF7FE08D) : AppColor.priceColor;
}
