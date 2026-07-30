import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/reports/progress_dashboard_controller.dart';
import '../../../core/class/request_status.dart';
import '../../../core/constants/app_dimentions.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/colors.dart';
import '../../../model/reports/dashboard_model.dart';
import '../../new_widgets/dashboard_widgets/activity_heatmap.dart';
import '../../new_widgets/dashboard_widgets/circular_progress_ring.dart';
import '../../new_widgets/dashboard_widgets/dashboard_cards.dart';
import '../../new_widgets/dashboard_widgets/weekly_activity_chart.dart';

/// The student's progress dashboard.
///
/// Every figure shown here is aggregated from recorded activity. Where the
/// backend reports a null — an average with no attempts behind it, a Success
/// Index for a student with too little history — this screen says so rather
/// than printing a zero, because a fabricated number is worse than an honest
/// blank.
class ProgressDashboardScreen extends StatelessWidget {
  const ProgressDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBg,
      body: GetBuilder<ProgressDashboardController>(
        init: Get.isRegistered<ProgressDashboardController>()
            ? Get.find<ProgressDashboardController>()
            : ProgressDashboardController(),
        builder: (controller) {
          if (controller.requestStatus == RequestStatus.loading) {
            return const _DashboardSkeleton();
          }

          if (controller.requestStatus != RequestStatus.success ||
              controller.dashboard == null) {
            return _ErrorState(onRetry: controller.reload);
          }

          return RefreshIndicator(
            color: theme.primary,
            onRefresh: controller.reload,
            child: _DashboardBody(controller: controller),
          );
        },
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final ProgressDashboardController controller;

  const _DashboardBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.dashboard!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.pad16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + AppHeight.h16),

            // 1 — welcome
            _WelcomeCard(
              name: controller.userName,
              level: data.student.educationLevel,
              grade: data.student.grade,
            ),
            SizedBox(height: AppHeight.h24),

            // 3 — headline ring
            Center(
              child: CircularProgressRing(
                percent: data.circularPercent,
                label: 'Overall progress',
              ),
            ),
            SizedBox(height: AppHeight.h24),

            // 9 — success index
            _SuccessIndexCard(index: data.successIndex),
            SizedBox(height: AppHeight.h16),

            // 10 — ranking, only when meaningful
            if (data.ranking.available) ...[
              _RankingCard(ranking: data.ranking),
              SizedBox(height: AppHeight.h16),
            ],

            // 12 — today's mission
            if (controller.missionTasks.isNotEmpty) ...[
              _MissionCard(tasks: controller.missionTasks),
              SizedBox(height: AppHeight.h24),
            ],

            // 2 — progress overview
            const SectionHeader(title: 'Your progress'),
            SizedBox(height: AppHeight.h12),
            _OverviewGrid(overview: data.overview),
            SizedBox(height: AppHeight.h24),

            // 4 — per-subject
            const SectionHeader(title: 'Subjects'),
            SizedBox(height: AppHeight.h12),
            _SubjectsCard(subjects: data.subjects),
            SizedBox(height: AppHeight.h24),

            // 5 — weekly activity
            const SectionHeader(
              title: 'This week',
              subtitle: 'Minutes studied each day',
            ),
            SizedBox(height: AppHeight.h12),
            DashboardCard(child: WeeklyActivityChart(days: data.weeklyActivity)),
            SizedBox(height: AppHeight.h24),

            // 6 — heat map
            const SectionHeader(
              title: 'Activity',
              subtitle: 'Last 30 days',
            ),
            SizedBox(height: AppHeight.h12),
            DashboardCard(child: ActivityHeatmap(cells: data.heatmap)),
            SizedBox(height: AppHeight.h24),

            // 7 — quiz analytics
            if (controller.quizAnalytics != null) ...[
              const SectionHeader(title: 'Quiz performance'),
              SizedBox(height: AppHeight.h12),
              _QuizAnalyticsCard(analytics: controller.quizAnalytics!),
              SizedBox(height: AppHeight.h24),
            ],

            // 8 — suggestions
            if (controller.suggestions.isNotEmpty) ...[
              const SectionHeader(
                title: 'Worth reviewing',
                subtitle: 'Based on your quiz answers',
              ),
              SizedBox(height: AppHeight.h12),
              _SuggestionsCard(suggestions: controller.suggestions),
              SizedBox(height: AppHeight.h24),
            ],

            // 11 — rewards
            if (controller.rewards != null) ...[
              const SectionHeader(title: 'Rewards'),
              SizedBox(height: AppHeight.h12),
              _RewardsCard(rewards: controller.rewards!),
              SizedBox(height: AppHeight.h24),
            ],

            // 13 — insights
            if (controller.insights.isNotEmpty) ...[
              const SectionHeader(title: 'For you'),
              SizedBox(height: AppHeight.h12),
              ...controller.insights.map(
                (i) => Padding(
                  padding: EdgeInsets.only(bottom: AppHeight.h8),
                  child: _InsightCard(insight: i),
                ),
              ),
            ],

            SizedBox(height: AppHeight.h120),
          ],
        ),
      ),
    );
  }
}

// ── 1. welcome ──────────────────────────────────────────────────────────

class _WelcomeCard extends StatelessWidget {
  final String name;
  final String? level;
  final String? grade;

  const _WelcomeCard({required this.name, this.level, this.grade});

  /// A rotating line, keyed to the day so it is stable within a session but
  /// changes daily.
  String get _motivation {
    const lines = [
      'Every lesson moves you forward.',
      'Small steps, every day.',
      'Consistency beats intensity.',
      'Today is a good day to learn something.',
      'Progress, not perfection.',
      'Your future self will thank you.',
      'Keep the streak alive.',
    ];
    return lines[DateTime.now().day % lines.length];
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      level,
      grade,
    ].where((s) => s != null && s.isNotEmpty).join(' · ');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppPadding.pad20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColor.primaryColor, AppColor.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radius20),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials(name),
                    style: TextStyle(
                      fontSize: AppTextSize.textSize16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppWidth.w12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting, $name',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      SizedBox(height: AppHeight.h4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: AppTextSize.textSize12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppHeight.h16),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppPadding.pad12,
              vertical: AppPadding.pad10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.radius12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: AppWidth.w8),
                Expanded(
                  child: Text(
                    _motivation,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

// ── 2. overview grid ────────────────────────────────────────────────────

class _OverviewGrid extends StatelessWidget {
  final ProgressOverview overview;

  const _OverviewGrid({required this.overview});

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      StatTile(
        icon: Icons.play_circle_outline_rounded,
        value: '${overview.videosWatched}',
        label: 'Videos watched',
        accent: AppColor.primaryColor,
      ),
      StatTile(
        icon: Icons.hourglass_bottom_rounded,
        value: '${overview.videosRemaining}',
        label: 'Videos left',
        accent: AppColor.accentBlue,
      ),
      StatTile(
        icon: Icons.picture_as_pdf_outlined,
        value: '${overview.pdfsOpened}',
        label: 'PDFs read',
        accent: AppColor.accentPink,
      ),
      StatTile(
        icon: Icons.quiz_outlined,
        value: '${overview.quizzesTaken}',
        label: 'Quizzes taken',
        accent: AppColor.starColor,
      ),
      StatTile(
        icon: Icons.trending_up_rounded,
        // A dash, not "0%" — no attempts means no average exists.
        value: overview.averageQuizScore != null
            ? '${overview.averageQuizScore}%'
            : '—',
        label: 'Average score',
        accent: AppColor.greenColor,
      ),
      StatTile(
        icon: Icons.schedule_rounded,
        value: overview.studyTimeLabel,
        label: 'Study time',
        accent: AppColor.primaryDark,
      ),
    ];

    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: AppWidth.w8,
          mainAxisSpacing: AppHeight.h8,
          childAspectRatio: 0.82,
          children: tiles,
        ),
        SizedBox(height: AppHeight.h12),
        Row(
          children: [
            Expanded(
              child: GradientStatTile(
                icon: Icons.local_fire_department_rounded,
                value: '${overview.currentStreak}',
                label: overview.currentStreak == 1 ? 'Day streak' : 'Day streak',
                colorA: const Color(0xFFFF8A3D),
                colorB: const Color(0xFFE85D04),
              ),
            ),
            SizedBox(width: AppWidth.w8),
            Expanded(
              child: GradientStatTile(
                icon: Icons.stars_rounded,
                value: '${overview.totalPoints}',
                label: 'Points',
                colorA: AppColor.primaryColor,
                colorB: AppColor.primaryDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── 4. subjects ─────────────────────────────────────────────────────────

class _SubjectsCard extends StatelessWidget {
  final List<SubjectProgress> subjects;

  const _SubjectsCard({required this.subjects});

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return const DashboardCard(
        child: EmptySection(
          icon: Icons.menu_book_rounded,
          message: 'You are not enrolled in any courses yet.',
        ),
      );
    }

    return DashboardCard(
      child: Column(
        children: [
          for (var i = 0; i < subjects.length; i++) ...[
            LabelledProgressBar(
              label: subjects[i].title,
              sublabel:
                  '${subjects[i].completedContents} of ${subjects[i].totalContents} lessons',
              percent: subjects[i].progressPercent,
            ),
            if (i != subjects.length - 1) SizedBox(height: AppHeight.h16),
          ],
        ],
      ),
    );
  }
}

// ── 7. quiz analytics ───────────────────────────────────────────────────

class _QuizAnalyticsCard extends StatelessWidget {
  final QuizAnalytics analytics;

  const _QuizAnalyticsCard({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    if (analytics.totalAttempts == 0) {
      return const DashboardCard(
        child: EmptySection(
          icon: Icons.quiz_outlined,
          message: 'Take a quiz to see your performance here.',
        ),
      );
    }

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MiniStat(
                label: 'Average',
                value: '${analytics.averageScore ?? '—'}%',
                color: theme.primary,
              ),
              _MiniStat(
                label: 'Best',
                value: '${analytics.highestScore ?? '—'}%',
                color: theme.green,
              ),
              _MiniStat(
                label: 'Lowest',
                value: '${analytics.lowestScore ?? '—'}%',
                color: theme.error,
              ),
              _MiniStat(
                label: 'Passed',
                value: '${analytics.passRate ?? '—'}%',
                color: AppColor.accentBlue,
              ),
            ],
          ),
          if (analytics.weakestSubject != null) ...[
            SizedBox(height: AppHeight.h16),
            Divider(color: theme.divider, height: 1),
            SizedBox(height: AppHeight.h12),
            _WeakRow(
              icon: Icons.school_outlined,
              label: 'Hardest subject',
              value: analytics.weakestSubject!,
            ),
          ],
          if (analytics.weakestLesson != null) ...[
            SizedBox(height: AppHeight.h8),
            _WeakRow(
              icon: Icons.bookmark_border_rounded,
              label: 'Hardest lesson',
              value: analytics.weakestLesson!,
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: AppTextSize.textSize18,
              fontWeight: FontWeight.w900,
              color: color,
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

class _WeakRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeakRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: theme.textHint),
        SizedBox(width: AppWidth.w8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: AppTextSize.textSize13,
            color: theme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppTextSize.textSize13,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── 8. suggestions ──────────────────────────────────────────────────────

class _SuggestionsCard extends StatelessWidget {
  final List<Suggestion> suggestions;

  const _SuggestionsCard({required this.suggestions});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in suggestions)
            Padding(
              padding: EdgeInsets.only(bottom: AppHeight.h12),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppPadding.pad8),
                    decoration: BoxDecoration(
                      color: AppColor.starColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.radius10),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 16,
                      color: AppColor.starColor,
                    ),
                  ),
                  SizedBox(width: AppWidth.w12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTextSize.textSize14,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppHeight.h4),
                        // The evidence is shown alongside the suggestion, so
                        // the student can judge it rather than just be told.
                        Text(
                          '${s.accuracy}% correct across ${s.questionsAnswered} questions',
                          style: TextStyle(
                            fontSize: AppTextSize.textSize12,
                            color: theme.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Text(
            'Suggestions based on your quiz answers.',
            style: TextStyle(
              fontSize: AppTextSize.textSize12,
              fontStyle: FontStyle.italic,
              color: theme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 9. success index ────────────────────────────────────────────────────

class _SuccessIndexCard extends StatelessWidget {
  final SuccessIndex index;

  const _SuccessIndexCard({required this.index});

  Color _bandColor(String? band) {
    switch (band) {
      case 'green':
        return AppColor.greenColor;
      case 'yellow':
        return AppColor.starColor;
      case 'red':
        return AppColor.errorColor;
      default:
        return AppColor.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    // No score yet: explain, never show a zero. A fresh account should not be
    // greeted with a red 0/100.
    if (!index.hasScore) {
      return DashboardCard(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppPadding.pad12),
              decoration: BoxDecoration(
                color: theme.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.radius12),
              ),
              child: Icon(
                Icons.insights_rounded,
                color: theme.primary,
                size: 22,
              ),
            ),
            SizedBox(width: AppWidth.w12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Success Index',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize15,
                      fontWeight: FontWeight.w700,
                      color: theme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppHeight.h4),
                  Text(
                    index.reason ?? 'Keep studying to unlock your score.',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize12,
                      color: theme.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final color = _bandColor(index.band);

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index.score}',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize20,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppWidth.w12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Success Index',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize15,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppHeight.h4),
                    Text(
                      'Out of 100, across four areas',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize12,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppHeight.h16),
          // The breakdown is shown so the number is inspectable rather than
          // an opaque verdict.
          for (final c in index.components)
            Padding(
              padding: EdgeInsets.only(bottom: AppHeight.h8),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      c.label,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize12,
                        color: c.hasData
                            ? theme.textSecondary
                            : theme.textHint,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.radius10),
                      child: LinearProgressIndicator(
                        value: (c.raw / 100).clamp(0.0, 1.0),
                        minHeight: 5,
                        backgroundColor: AppColor.gray.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          c.hasData
                              ? color
                              : AppColor.gray.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppWidth.w8),
                  SizedBox(
                    width: 34,
                    child: Text(
                      c.hasData ? '${c.raw}%' : '—',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize12,
                        fontWeight: FontWeight.w700,
                        color: c.hasData ? theme.textPrimary : theme.textHint,
                      ),
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

// ── 10. ranking ─────────────────────────────────────────────────────────

class _RankingCard extends StatelessWidget {
  final RankingInfo ranking;

  const _RankingCard({required this.ranking});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return DashboardCard(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppPadding.pad12),
            decoration: BoxDecoration(
              color: AppColor.starColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.radius12),
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: AppColor.starColor,
              size: 22,
            ),
          ),
          SizedBox(width: AppWidth.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A band, never a raw position. See percentileBand on the
                // server for why the exact rank is deliberately withheld.
                Text(
                  ranking.band ?? '',
                  style: TextStyle(
                    fontSize: AppTextSize.textSize18,
                    fontWeight: FontWeight.w800,
                    color: theme.textPrimary,
                  ),
                ),
                SizedBox(height: AppHeight.h4),
                Text(
                  'Among ${ranking.cohortSize} students in your ${ranking.scope ?? 'group'}',
                  style: TextStyle(
                    fontSize: AppTextSize.textSize12,
                    color: theme.textSecondary,
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

// ── 11. rewards ─────────────────────────────────────────────────────────

class _RewardsCard extends StatelessWidget {
  final RewardsInfo rewards;

  const _RewardsCard({required this.rewards});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Points',
                  value: '${rewards.totalPoints}',
                  color: theme.primary,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'Badges',
                  value: '${rewards.badgesEarned}/${rewards.badgesAvailable}',
                  color: AppColor.starColor,
                ),
              ),
            ],
          ),
          if (rewards.latestBadgeName != null) ...[
            SizedBox(height: AppHeight.h16),
            Divider(color: theme.divider, height: 1),
            SizedBox(height: AppHeight.h12),
            Row(
              children: [
                Text(
                  rewards.latestBadgeIcon ?? '🏅',
                  style: const TextStyle(fontSize: 22),
                ),
                SizedBox(width: AppWidth.w8),
                Expanded(
                  child: Text(
                    'Latest: ${rewards.latestBadgeName}',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize13,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (rewards.nextBadgeName != null) ...[
            SizedBox(height: AppHeight.h12),
            Container(
              padding: EdgeInsets.all(AppPadding.pad12),
              decoration: BoxDecoration(
                color: theme.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.radius12),
              ),
              child: Row(
                children: [
                  Text(
                    rewards.nextBadgeIcon ?? '🎯',
                    style: const TextStyle(fontSize: 20),
                  ),
                  SizedBox(width: AppWidth.w8),
                  Expanded(
                    child: Text(
                      '${rewards.pointsToNextBadge} points to "${rewards.nextBadgeName}"',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize12,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 12. today's mission ─────────────────────────────────────────────────

class _MissionCard extends StatelessWidget {
  final List<MissionTask> tasks;

  const _MissionCard({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final done = tasks.where((t) => t.done).length;

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Today's mission",
                  style: TextStyle(
                    fontSize: AppTextSize.textSize16,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pad10,
                  vertical: AppPadding.pad4,
                ),
                decoration: BoxDecoration(
                  color: done == tasks.length
                      ? theme.green.withValues(alpha: 0.14)
                      : theme.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.radius25),
                ),
                child: Text(
                  '$done/${tasks.length}',
                  style: TextStyle(
                    fontSize: AppTextSize.textSize12,
                    fontWeight: FontWeight.w800,
                    color: done == tasks.length ? theme.green : theme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppHeight.h12),
          for (final task in tasks)
            Padding(
              padding: EdgeInsets.only(bottom: AppHeight.h8),
              child: Row(
                children: [
                  Icon(
                    task.done
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: task.done ? theme.green : theme.textHint,
                  ),
                  SizedBox(width: AppWidth.w8),
                  Text(
                    task.label,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize13,
                      fontWeight: task.done ? FontWeight.w400 : FontWeight.w600,
                      color: task.done ? theme.textHint : theme.textPrimary,
                      decoration: task.done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: theme.textHint,
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

// ── 13. insights ────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final Insight insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    final (color, icon) = switch (insight.severity) {
      'positive' => (AppColor.greenColor, Icons.trending_up_rounded),
      'warning' => (AppColor.starColor, Icons.info_outline_rounded),
      _ => (AppColor.primaryColor, Icons.notifications_none_rounded),
    };

    return Container(
      padding: EdgeInsets.all(AppPadding.pad12),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        border: Border(left: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          SizedBox(width: AppWidth.w12),
          Expanded(
            child: Text(
              insight.message,
              style: TextStyle(
                fontSize: AppTextSize.textSize13,
                color: theme.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── states ──────────────────────────────────────────────────────────────

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final block = theme.isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppColor.gray.withValues(alpha: 0.14);

    Widget bar(double height, {double? width}) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: block,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
      ),
    );

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.pad16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + AppHeight.h16),
            bar(110),
            SizedBox(height: AppHeight.h24),
            Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(color: block, shape: BoxShape.circle),
              ),
            ),
            SizedBox(height: AppHeight.h24),
            bar(90),
            SizedBox(height: AppHeight.h16),
            bar(140),
            SizedBox(height: AppHeight.h16),
            bar(170),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppPadding.pad20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: theme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insights_rounded,
                size: 34,
                color: theme.primary,
              ),
            ),
            SizedBox(height: AppHeight.h16),
            Text(
              "We couldn't load your progress",
              style: TextStyle(
                fontSize: AppTextSize.textSize16,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
            ),
            SizedBox(height: AppHeight.h8),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTextSize.textSize13,
                color: theme.textSecondary,
              ),
            ),
            SizedBox(height: AppHeight.h16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pad20,
                  vertical: AppPadding.pad12,
                ),
                decoration: BoxDecoration(
                  color: theme.primary,
                  borderRadius: BorderRadius.circular(AppRadius.radius25),
                ),
                child: Text(
                  'Try again',
                  style: TextStyle(
                    fontSize: AppTextSize.textSize14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
