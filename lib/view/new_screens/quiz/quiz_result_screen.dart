import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/quiz/quiz_controller.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/model/quiz/quiz_submit_model.dart';

// Result view shown inline in QuizScreen after submit.
class QuizResultView extends StatelessWidget {
  final QuizControllerImp controller;
  const QuizResultView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final result = controller.result!;
    final passed = result.passed == true;
    final score = result.score ?? 0.0;
    final passingScore = result.passingScore ?? 0;

    return Scaffold(
      backgroundColor: AppColor.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColor.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.textPrimary,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Results',
          style: TextStyle(
            fontSize: AppTextSize.textSize16,
            fontWeight: FontWeight.w700,
            color: AppColor.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ScoreHeader(
              passed: passed,
              score: score,
              passingScore: passingScore,
              correctAnswers: result.correctAnswers ?? 0,
              totalQuestions: result.totalQuestions ?? 0,
              earnedPoints: result.earnedPoints ?? 0,
              totalPoints: result.totalPoints ?? 0,
              timeTaken: result.timeTaken,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppPadding.pad16,
                AppPadding.pad16,
                AppPadding.pad16,
                AppPadding.pad8,
              ),
              child: Text(
                'Question Breakdown',
                style: TextStyle(
                  fontSize: AppTextSize.textSize16,
                  fontWeight: FontWeight.w700,
                  color: AppColor.textPrimary,
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: (result.results ?? []).length,
            itemBuilder: (ctx, i) => _QuestionResultCard(
              result: result.results![i],
              index: i,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: AppHeight.h100)),
        ],
      ),
      bottomNavigationBar: _buildFooter(passed),
    );
  }

  Widget _buildFooter(bool passed) {
    return Container(
      padding: EdgeInsets.only(
        left: AppPadding.pad16,
        right: AppPadding.pad16,
        top: AppPadding.pad12,
        bottom: AppPadding.pad16,
      ),
      decoration: BoxDecoration(
        color: AppColor.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: controller.retryQuiz,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: AppPadding.pad12),
                  decoration: BoxDecoration(
                    color: AppColor.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.radius12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        color: AppColor.primaryColor,
                        size: 18,
                      ),
                      SizedBox(width: AppWidth.w8),
                      Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: AppTextSize.textSize14,
                          fontWeight: FontWeight.w700,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: AppWidth.w12),
            Expanded(
              child: GestureDetector(
                onTap: () => Get.back(result: passed),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: AppPadding.pad12),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(AppRadius.radius12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Done',
                        style: TextStyle(
                          fontSize: AppTextSize.textSize14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: AppWidth.w8),
                      const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
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

// ═══════════════════════════════════════════════════════════════
//  Score header
// ═══════════════════════════════════════════════════════════════
class _ScoreHeader extends StatelessWidget {
  final bool passed;
  final double score;
  final int passingScore;
  final int correctAnswers;
  final int totalQuestions;
  final int earnedPoints;
  final int totalPoints;
  final int? timeTaken;

  const _ScoreHeader({
    required this.passed,
    required this.score,
    required this.passingScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.earnedPoints,
    required this.totalPoints,
    required this.timeTaken,
  });

  String _formatTime(int s) {
    final m = s ~/ 60;
    final rem = s % 60;
    if (m == 0) return '${rem}s';
    return '${m}m ${rem}s';
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = passed ? AppColor.greenColor : AppColor.errorColor;
    final bgGradient = passed
        ? [AppColor.greenColor, AppColor.greenColor.withValues(alpha: 0.85)]
        : [AppColor.errorColor, AppColor.errorColor.withValues(alpha: 0.85)];

    return Container(
      margin: EdgeInsets.all(AppPadding.pad16),
      padding: EdgeInsets.all(AppPadding.pad24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radius20),
        boxShadow: [
          BoxShadow(
            color: headerColor.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              passed
                  ? Icons.emoji_events_rounded
                  : Icons.sentiment_dissatisfied_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
          SizedBox(height: AppHeight.h16),
          Text(
            passed ? 'Congratulations!' : 'Keep Trying',
            style: TextStyle(
              fontSize: AppTextSize.textSize24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppHeight.h4),
          Text(
            passed
                ? 'You passed the quiz'
                : 'You didn\'t meet the passing score',
            style: TextStyle(
              fontSize: AppTextSize.textSize13,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: AppHeight.h20),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppPadding.pad20,
              vertical: AppPadding.pad12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.radius15),
            ),
            child: Column(
              children: [
                Text(
                  '${score.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: AppTextSize.textSize32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Passing: $passingScore%',
                  style: TextStyle(
                    fontSize: AppTextSize.textSize12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppHeight.h20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statTile(
                label: 'Correct',
                value: '$correctAnswers / $totalQuestions',
              ),
              _statTile(
                label: 'Points',
                value: '$earnedPoints / $totalPoints',
              ),
              _statTile(
                label: 'Time',
                value: timeTaken == null ? '—' : _formatTime(timeTaken!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: AppTextSize.textSize14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: AppHeight.h3),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTextSize.textSize10,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Question result card — shows per-option status
// ═══════════════════════════════════════════════════════════════
class _QuestionResultCard extends StatelessWidget {
  final QuizQuestionResult result;
  final int index;

  const _QuestionResultCard({required this.result, required this.index});

  @override
  Widget build(BuildContext context) {
    final isCorrect = result.isCorrect == true;
    final options = result.options ?? const [];
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppPadding.pad16,
        AppPadding.pad8,
        AppPadding.pad16,
        AppPadding.pad8,
      ),
      padding: EdgeInsets.all(AppPadding.pad16),
      decoration: BoxDecoration(
        color: AppColor.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.radius15),
        border: Border.all(
          color: (isCorrect ? AppColor.greenColor : AppColor.errorColor)
              .withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pad8,
                  vertical: AppPadding.pad4,
                ),
                decoration: BoxDecoration(
                  color: (isCorrect ? AppColor.greenColor : AppColor.errorColor)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.radius20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 14,
                      color:
                          isCorrect ? AppColor.greenColor : AppColor.errorColor,
                    ),
                    SizedBox(width: AppWidth.w4),
                    Text(
                      'Q${index + 1}',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize12,
                        fontWeight: FontWeight.w700,
                        color: isCorrect
                            ? AppColor.greenColor
                            : AppColor.errorColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${result.points ?? 0} pts',
                style: TextStyle(
                  fontSize: AppTextSize.textSize12,
                  color: AppColor.textHint,
                ),
              ),
            ],
          ),
          SizedBox(height: AppHeight.h12),
          Text(
            result.questionText ?? '',
            style: TextStyle(
              fontSize: AppTextSize.textSize14,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppHeight.h12),
          ...options.map((opt) => _OptionRow(option: opt)),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final QuizResultOptionFull option;
  const _OptionRow({required this.option});

  @override
  Widget build(BuildContext context) {
    final correct = option.isCorrect == true;
    final selected = option.isSelected == true;

    Color borderColor;
    Color bgColor;
    IconData? icon;
    Color iconColor = AppColor.textHint;

    if (correct) {
      borderColor = AppColor.greenColor;
      bgColor = AppColor.greenColor.withValues(alpha: 0.08);
      icon = Icons.check_circle_rounded;
      iconColor = AppColor.greenColor;
    } else if (selected && !correct) {
      borderColor = AppColor.errorColor;
      bgColor = AppColor.errorColor.withValues(alpha: 0.08);
      icon = Icons.cancel_rounded;
      iconColor = AppColor.errorColor;
    } else {
      borderColor = AppColor.gray.withValues(alpha: 0.2);
      bgColor = AppColor.scaffoldBg;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: AppPadding.pad8),
      child: Container(
        padding: EdgeInsets.all(AppPadding.pad12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.radius10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(
              icon ?? Icons.radio_button_unchecked_rounded,
              size: 18,
              color: iconColor,
            ),
            SizedBox(width: AppWidth.w12),
            Expanded(
              child: Text(
                option.text ?? '',
                style: TextStyle(
                  fontSize: AppTextSize.textSize13,
                  fontWeight: (correct || selected)
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: AppColor.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            if (selected)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pad8,
                  vertical: AppPadding.pad4,
                ),
                decoration: BoxDecoration(
                  color: (correct ? AppColor.greenColor : AppColor.errorColor)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.radius10),
                ),
                child: Text(
                  'Your answer',
                  style: TextStyle(
                    fontSize: AppTextSize.textSize10,
                    fontWeight: FontWeight.w700,
                    color: correct
                        ? AppColor.greenColor
                        : AppColor.errorColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
