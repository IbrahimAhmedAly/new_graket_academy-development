import 'package:flutter/material.dart';

import '../../../core/constants/app_dimentions.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/colors.dart';

/// Shared building blocks for the progress dashboard.
///
/// All of these follow the existing card language: white surface, 12-15px
/// radius, and a purple-tinted shadow rather than a neutral black one.

/// Standard card shell — surface, radius, and the app's tinted shadow.
class DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const DashboardCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(AppPadding.pad16),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.radius15),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Section heading with an optional trailing action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppTextSize.textSize18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: theme.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: AppHeight.h4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: AppTextSize.textSize12,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// A small metric tile: icon chip, value, label.
class StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      padding: EdgeInsets.all(AppPadding.pad12),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(AppPadding.pad8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.radius10),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          SizedBox(height: AppHeight.h8),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTextSize.textSize20,
              fontWeight: FontWeight.w900,
              height: 1.1,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: AppHeight.h4),
          Text(
            label,
            style: TextStyle(
              fontSize: AppTextSize.textSize12,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A headline metric on a colour gradient, for figures that deserve emphasis.
class GradientStatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color colorA;
  final Color colorB;

  const GradientStatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.colorA,
    required this.colorB,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppPadding.pad16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorA, colorB],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radius15),
        boxShadow: [
          BoxShadow(
            color: colorA.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(width: AppWidth.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: AppTextSize.textSize20,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: AppHeight.h4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTextSize.textSize12,
                    color: Colors.white.withValues(alpha: 0.9),
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

/// A labelled progress bar, matching the track styling used elsewhere.
class LabelledProgressBar extends StatelessWidget {
  final String label;
  final String? sublabel;
  final int percent;
  final Color? color;

  const LabelledProgressBar({
    super.key,
    required this.label,
    this.sublabel,
    required this.percent,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isComplete = percent >= 100;
    final barColor = color ?? (isComplete ? theme.green : theme.primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTextSize.textSize14,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: theme.textPrimary,
                ),
              ),
            ),
            SizedBox(width: AppWidth.w8),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: AppTextSize.textSize14,
                fontWeight: FontWeight.w800,
                color: barColor,
              ),
            ),
          ],
        ),
        if (sublabel != null) ...[
          SizedBox(height: AppHeight.h4),
          Text(
            sublabel!,
            style: TextStyle(
              fontSize: AppTextSize.textSize12,
              color: theme.textHint,
            ),
          ),
        ],
        SizedBox(height: AppHeight.h8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.radius10),
          child: LinearProgressIndicator(
            value: (percent / 100).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColor.gray.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

/// Placeholder shown when a section has nothing to display yet.
///
/// Used instead of rendering zeros: an empty state invites the student to act,
/// where "0%" reads as a verdict on them.
class EmptySection extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptySection({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppPadding.pad20),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 26, color: theme.primary),
          ),
          SizedBox(height: AppHeight.h12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTextSize.textSize13,
              color: theme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
