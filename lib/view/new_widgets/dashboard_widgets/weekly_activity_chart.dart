import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimentions.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/colors.dart';
import '../../../model/reports/dashboard_model.dart';

/// Seven-day study-minutes bar chart.
///
/// Days with no activity are drawn as faint stubs rather than omitted, so the
/// week reads honestly — a gap is visible as a gap instead of the axis
/// silently compressing to hide it.
class WeeklyActivityChart extends StatelessWidget {
  final List<DayActivity> days;

  const WeeklyActivityChart({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    final maxMinutes = days.fold<int>(
      0,
      (max, d) => d.studyMinutes > max ? d.studyMinutes : max,
    );

    // A floor on the axis keeps a light week from rendering as full-height
    // bars, which would overstate a 3-minute day.
    final axisMax = (maxMinutes < 30 ? 30 : maxMinutes * 1.25).toDouble();

    return SizedBox(
      height: 170,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: axisMax,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => theme.isDark
                  ? const Color(0xFF2A2630)
                  : AppColor.textPrimary,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final day = days[group.x.toInt()];
                return BarTooltipItem(
                  '${day.studyMinutes} min',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: AppTextSize.textSize12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= days.length) {
                    return const SizedBox.shrink();
                  }
                  final isToday = index == days.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(top: AppPadding.pad6),
                    child: Text(
                      days[index].weekdayLabel,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize12,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                        color: isToday ? theme.primary : theme.textHint,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: axisMax / 3,
            getDrawingHorizontalLine: (_) => FlLine(
              color: theme.divider,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(days.length, (index) {
            final day = days[index];
            final isToday = index == days.length - 1;
            final hasActivity = day.studyMinutes > 0;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  // Zero-activity days still draw a small stub so the bar is
                  // visible as an explicit "nothing", not a missing column.
                  toY: hasActivity ? day.studyMinutes.toDouble() : axisMax * 0.02,
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                  gradient: hasActivity
                      ? LinearGradient(
                          colors: isToday
                              ? [AppColor.primaryColor, AppColor.primaryDark]
                              : [
                                  AppColor.primaryColor.withValues(alpha: 0.65),
                                  AppColor.primaryColor.withValues(alpha: 0.45),
                                ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        )
                      : null,
                  color: hasActivity
                      ? null
                      : AppColor.gray.withValues(alpha: 0.22),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
