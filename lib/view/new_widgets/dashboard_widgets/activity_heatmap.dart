import 'package:flutter/material.dart';

import '../../../core/constants/app_dimentions.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/colors.dart';
import '../../../model/reports/dashboard_model.dart';

/// A 30-day activity heat map.
///
/// Intensity levels come from the server against fixed minute thresholds, so a
/// quiet month renders as genuinely quiet rather than being rescaled against
/// its own peak and made to look busy.
class ActivityHeatmap extends StatelessWidget {
  final List<HeatmapCell> cells;

  const ActivityHeatmap({super.key, required this.cells});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed 7-wide grid so columns line up as weeks.
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cells.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: AppWidth.w5,
            mainAxisSpacing: AppHeight.h4,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final cell = cells[index];
            return _HeatCell(cell: cell, theme: theme);
          },
        ),
        SizedBox(height: AppHeight.h12),
        _Legend(theme: theme),
      ],
    );
  }
}

class _HeatCell extends StatelessWidget {
  final HeatmapCell cell;
  final AppTheme theme;

  const _HeatCell({required this.cell, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: cell.studyMinutes > 0
          ? '${cell.date}: ${cell.studyMinutes} min'
          : '${cell.date}: no study',
      child: Container(
        decoration: BoxDecoration(
          color: levelColor(cell.level, theme),
          borderRadius: BorderRadius.circular(AppRadius.radius3),
        ),
      ),
    );
  }
}

/// Colour for an intensity level, 0 (none) through 4 (heaviest).
///
/// Uses the brand purple at increasing opacity rather than the conventional
/// green scale, so the map reads as part of this app rather than a transplant.
Color levelColor(int level, AppTheme theme) {
  final empty = theme.isDark
      ? Colors.white.withValues(alpha: 0.06)
      : AppColor.gray.withValues(alpha: 0.13);

  switch (level) {
    case 1:
      return AppColor.primaryColor.withValues(alpha: 0.28);
    case 2:
      return AppColor.primaryColor.withValues(alpha: 0.52);
    case 3:
      return AppColor.primaryColor.withValues(alpha: 0.76);
    case 4:
      return AppColor.primaryColor;
    default:
      return empty;
  }
}

class _Legend extends StatelessWidget {
  final AppTheme theme;

  const _Legend({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: AppTextSize.textSize10,
            color: theme.textHint,
          ),
        ),
        SizedBox(width: AppWidth.w5),
        ...List.generate(5, (level) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.pad4),
            child: Container(
              width: AppWidth.w12,
              height: AppWidth.w12,
              decoration: BoxDecoration(
                color: levelColor(level, theme),
                borderRadius: BorderRadius.circular(AppRadius.radius3),
              ),
            ),
          );
        }),
        SizedBox(width: AppWidth.w5),
        Text(
          'More',
          style: TextStyle(
            fontSize: AppTextSize.textSize10,
            color: theme.textHint,
          ),
        ),
      ],
    );
  }
}
