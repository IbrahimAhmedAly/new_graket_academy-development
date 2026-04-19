import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/quiz/quiz_controller.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/model/quiz/get_quiz_model.dart' as qm;
import 'package:new_graket_acadimy/view/new_screens/quiz/quiz_result_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(QuizControllerImp(), tag: _resolveTag());

    return GetBuilder<QuizControllerImp>(
      tag: _resolveTag(),
      builder: (controller) {
        // Once result arrives, show results view within same screen
        if (controller.result != null) {
          return QuizResultView(controller: controller);
        }
        return Scaffold(
          backgroundColor: AppColor.scaffoldBg,
          appBar: _buildAppBar(controller),
          body: _buildBody(controller),
        );
      },
    );
  }

  String _resolveTag() {
    final args = Get.arguments as Map? ?? {};
    final id = args['id']?.toString() ?? 'quiz';
    return 'quiz-$id';
  }

  PreferredSizeWidget _buildAppBar(QuizControllerImp c) {
    return AppBar(
      backgroundColor: AppColor.scaffoldBg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: AppColor.textPrimary),
        onPressed: () => _confirmExit(c),
      ),
      title: Text(
        c.quiz?.title ?? 'Quiz',
        style: TextStyle(
          fontSize: AppTextSize.textSize16,
          fontWeight: FontWeight.w700,
          color: AppColor.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
      actions: [
        if (c.quizStarted && c.quiz?.timeLimit != null && c.quiz!.timeLimit! > 0)
          Padding(
            padding: EdgeInsets.only(right: AppPadding.pad16),
            child: Center(child: _TimerChip(seconds: c.remainingSeconds ?? 0)),
          ),
      ],
    );
  }

  void _confirmExit(QuizControllerImp c) {
    if (!c.quizStarted || c.result != null) {
      Get.back();
      return;
    }
    Get.dialog(
      AlertDialog(
        title: const Text('Leave Quiz?'),
        content: const Text(
          'Your progress in this attempt will be lost. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // dismiss dialog
              Get.back(); // leave quiz screen
            },
            child: const Text(
              'Leave',
              style: TextStyle(color: AppColor.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(QuizControllerImp c) {
    if (c.requestStatus == RequestStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.primaryColor),
      );
    }
    if (c.requestStatus != RequestStatus.success || c.quiz == null) {
      return _QuizErrorView(controller: c);
    }

    if (!c.quizStarted) {
      return _QuizIntro(controller: c);
    }

    return _QuizQuestions(controller: c);
  }
}

// ═══════════════════════════════════════════════════════════════
//  Timer chip
// ═══════════════════════════════════════════════════════════════
class _TimerChip extends StatelessWidget {
  final int seconds;
  const _TimerChip({required this.seconds});

  String _format(int s) {
    final m = s ~/ 60;
    final rem = s % 60;
    return '$m:${rem.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isLow = seconds <= 30 && seconds > 0;
    final bg = isLow
        ? AppColor.errorColor.withValues(alpha: 0.12)
        : AppColor.primaryLight;
    final fg = isLow ? AppColor.errorColor : AppColor.primaryColor;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pad12,
        vertical: AppPadding.pad6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.radius20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 14, color: fg),
          SizedBox(width: AppWidth.w4),
          Text(
            _format(seconds),
            style: TextStyle(
              fontSize: AppTextSize.textSize12,
              fontWeight: FontWeight.w700,
              color: fg,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Intro view — shown before quiz starts
// ═══════════════════════════════════════════════════════════════
class _QuizIntro extends StatelessWidget {
  final QuizControllerImp controller;
  const _QuizIntro({required this.controller});

  @override
  Widget build(BuildContext context) {
    final quiz = controller.quiz!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppPadding.pad24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppPadding.pad24),
            decoration: BoxDecoration(
              color: AppColor.cardBg,
              borderRadius: BorderRadius.circular(AppRadius.radius20),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColor.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.quiz_rounded,
                    color: AppColor.primaryColor,
                    size: 36,
                  ),
                ),
                SizedBox(height: AppHeight.h16),
                Text(
                  quiz.title ?? 'Quiz',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppTextSize.textSize18,
                    fontWeight: FontWeight.w800,
                    color: AppColor.textPrimary,
                  ),
                ),
                if ((quiz.section ?? '').isNotEmpty) ...[
                  SizedBox(height: AppHeight.h6),
                  Text(
                    quiz.section!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize13,
                      color: AppColor.textHint,
                    ),
                  ),
                ],
                SizedBox(height: AppHeight.h24),
                _infoRow(
                  icon: Icons.help_outline_rounded,
                  label: 'Questions',
                  value: '${quiz.totalQuestions ?? quiz.questions?.length ?? 0}',
                ),
                _divider(),
                _infoRow(
                  icon: Icons.timer_outlined,
                  label: 'Time Limit',
                  value: quiz.timeLimit == null || quiz.timeLimit == 0
                      ? 'No limit'
                      : '${quiz.timeLimit} min',
                ),
                _divider(),
                _infoRow(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Passing Score',
                  value: '${quiz.passingScore ?? 0}%',
                ),
                if (quiz.totalPoints != null && quiz.totalPoints! > 0) ...[
                  _divider(),
                  _infoRow(
                    icon: Icons.star_outline_rounded,
                    label: 'Total Points',
                    value: '${quiz.totalPoints}',
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: AppHeight.h16),
          if ((quiz.previousAttempts ?? 0) > 0)
            Container(
              padding: EdgeInsets.all(AppPadding.pad16),
              decoration: BoxDecoration(
                color: AppColor.cardBg,
                borderRadius: BorderRadius.circular(AppRadius.radius12),
                border: Border.all(
                  color: AppColor.primaryColor.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    color: AppColor.primaryColor,
                  ),
                  SizedBox(width: AppWidth.w12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Previous Attempts: ${quiz.previousAttempts}',
                          style: TextStyle(
                            fontSize: AppTextSize.textSize13,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        if (quiz.bestScore != null)
                          Text(
                            'Best Score: ${quiz.bestScore!.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: AppTextSize.textSize12,
                              color: AppColor.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: AppHeight.h24),
          GestureDetector(
            onTap: controller.startQuiz,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: AppPadding.pad16),
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(AppRadius.radius12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  SizedBox(width: AppWidth.w8),
                  Text(
                    'Start Quiz',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppHeight.h12),
          Text(
            'Once started, you cannot pause the timer.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTextSize.textSize12,
              color: AppColor.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppPadding.pad8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColor.primaryColor),
          SizedBox(width: AppWidth.w12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppTextSize.textSize13,
                color: AppColor.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTextSize.textSize13,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        color: AppColor.gray.withValues(alpha: 0.15),
      );
}

// ═══════════════════════════════════════════════════════════════
//  Questions view — PageView of questions
// ═══════════════════════════════════════════════════════════════
class _QuizQuestions extends StatefulWidget {
  final QuizControllerImp controller;
  const _QuizQuestions({required this.controller});

  @override
  State<_QuizQuestions> createState() => _QuizQuestionsState();
}

class _QuizQuestionsState extends State<_QuizQuestions> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final questions = c.quiz?.questions ?? const [];
    if (questions.isEmpty) {
      return const Center(child: Text('No questions'));
    }

    final total = questions.length;
    final answered = c.answeredCount;
    final progress = total == 0 ? 0.0 : answered / total;

    return SafeArea(
      child: Column(
        children: [
          // Progress header
          Container(
            padding: EdgeInsets.fromLTRB(
              AppPadding.pad16,
              AppPadding.pad8,
              AppPadding.pad16,
              AppPadding.pad12,
            ),
            color: AppColor.cardBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Question ${_currentPage + 1} of $total',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize13,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$answered/$total answered',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize12,
                        color: AppColor.textHint,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppHeight.h8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.radius10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColor.gray.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColor.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Questions
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: total,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (ctx, i) => _QuestionCard(
                question: questions[i],
                index: i,
                controller: c,
              ),
            ),
          ),

          // Navigation footer
          _buildFooter(c, total),
        ],
      ),
    );
  }

  Widget _buildFooter(QuizControllerImp c, int total) {
    final isLast = _currentPage >= total - 1;
    return Container(
      padding: EdgeInsets.only(
        left: AppPadding.pad16,
        right: AppPadding.pad16,
        top: AppPadding.pad12,
        bottom: MediaQuery.of(context).padding.bottom + AppPadding.pad12,
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
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: _secondaryButton(
                label: 'Previous',
                icon: Icons.arrow_back_ios_rounded,
                onTap: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.ease,
                  );
                },
              ),
            ),
          if (_currentPage > 0) SizedBox(width: AppWidth.w12),
          Expanded(
            child: isLast
                ? _submitButton(c)
                : _primaryButton(
                    label: 'Next',
                    icon: Icons.arrow_forward_rounded,
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.ease,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton(QuizControllerImp c) {
    final enabled = c.canSubmit;
    return GestureDetector(
      onTap: enabled ? () => _confirmSubmit(c) : null,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppPadding.pad12),
        decoration: BoxDecoration(
          color: enabled
              ? AppColor.primaryColor
              : AppColor.gray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppRadius.radius12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (c.isSubmitting)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else ...[
              const Icon(Icons.check_rounded, color: Colors.white, size: 18),
              SizedBox(width: AppWidth.w8),
              Text(
                c.answeredCount == c.totalQuestions
                    ? 'Submit Quiz'
                    : 'Answer all questions',
                style: TextStyle(
                  fontSize: AppTextSize.textSize14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
              label,
              style: TextStyle(
                fontSize: AppTextSize.textSize14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: AppWidth.w8),
            Icon(icon, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppPadding.pad12),
        decoration: BoxDecoration(
          color: AppColor.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.radius12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColor.primaryColor, size: 16),
            SizedBox(width: AppWidth.w8),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTextSize.textSize14,
                fontWeight: FontWeight.w700,
                color: AppColor.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSubmit(QuizControllerImp c) {
    Get.dialog(
      AlertDialog(
        title: const Text('Submit Quiz?'),
        content: Text(
          'You have answered ${c.answeredCount} of ${c.totalQuestions} questions. '
          'You cannot change your answers after submission.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Review'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              c.submit();
            },
            child: const Text(
              'Submit',
              style: TextStyle(
                color: AppColor.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Question card
// ═══════════════════════════════════════════════════════════════
class _QuestionCard extends StatelessWidget {
  final qm.QuizQuestion question;
  final int index;
  final QuizControllerImp controller;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final options = question.options ?? const [];
    final selected = controller.selectedFor(question.id ?? '');
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppPadding.pad20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(AppPadding.pad20),
            decoration: BoxDecoration(
              color: AppColor.cardBg,
              borderRadius: BorderRadius.circular(AppRadius.radius15),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
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
                        color: AppColor.primaryLight,
                        borderRadius:
                            BorderRadius.circular(AppRadius.radius20),
                      ),
                      child: Text(
                        'Q${index + 1}',
                        style: TextStyle(
                          fontSize: AppTextSize.textSize12,
                          fontWeight: FontWeight.w700,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if ((question.points ?? 0) > 0)
                      Text(
                        '${question.points} pts',
                        style: TextStyle(
                          fontSize: AppTextSize.textSize12,
                          color: AppColor.textHint,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppHeight.h12),
                Text(
                  question.questionText ?? '',
                  style: TextStyle(
                    fontSize: AppTextSize.textSize16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppHeight.h16),
          ...options.map((opt) {
            final isSelected = opt.id == selected;
            return Padding(
              padding: EdgeInsets.only(bottom: AppPadding.pad10),
              child: GestureDetector(
                onTap: () {
                  if (question.id != null && opt.id != null) {
                    controller.selectAnswer(question.id!, opt.id!);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.all(AppPadding.pad16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColor.primaryLight
                        : AppColor.cardBg,
                    borderRadius: BorderRadius.circular(AppRadius.radius12),
                    border: Border.all(
                      color: isSelected
                          ? AppColor.primaryColor
                          : AppColor.gray.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColor.primaryColor
                                : AppColor.textHint,
                            width: 2,
                          ),
                          color: isSelected
                              ? AppColor.primaryColor
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
                      ),
                      SizedBox(width: AppWidth.w12),
                      Expanded(
                        child: Text(
                          opt.text ?? '',
                          style: TextStyle(
                            fontSize: AppTextSize.textSize14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: AppColor.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: AppHeight.h40),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Error view
// ═══════════════════════════════════════════════════════════════
class _QuizErrorView extends StatelessWidget {
  final QuizControllerImp controller;
  const _QuizErrorView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final msg = controller.errorMessage.isNotEmpty
        ? controller.errorMessage
        : _messageForStatus(controller.requestStatus);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppPadding.pad40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColor.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColor.primaryColor,
                size: 40,
              ),
            ),
            SizedBox(height: AppHeight.h20),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTextSize.textSize15,
                color: AppColor.textSecondary,
              ),
            ),
            SizedBox(height: AppHeight.h20),
            GestureDetector(
              onTap: controller.loadQuiz,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pad24,
                  vertical: AppPadding.pad12,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(AppRadius.radius25),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: AppTextSize.textSize14,
                    fontWeight: FontWeight.w600,
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

  String _messageForStatus(RequestStatus s) {
    switch (s) {
      case RequestStatus.offline:
      case RequestStatus.noInternet:
        return AppStrings.youAreOffline.tr;
      case RequestStatus.serverFailure:
      case RequestStatus.serverException:
        return AppStrings.serverError.tr;
      default:
        return 'Could not load quiz';
    }
  }
}
