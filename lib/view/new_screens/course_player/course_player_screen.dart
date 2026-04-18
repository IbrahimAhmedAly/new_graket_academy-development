import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/course_player/course_player_controller.dart';
import 'package:new_graket_acadimy/controller/my_courses_controller.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/model/courses/get_course_by_id_model.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CoursePlayerScreen extends StatefulWidget {
  const CoursePlayerScreen({super.key});

  @override
  State<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends State<CoursePlayerScreen> {
  @override
  void initState() {
    super.initState();
    Get.put(CoursePlayerControllerImp());
  }

  void _maybeShowCompletion(CoursePlayerControllerImp c) {
    if (!c.courseJustCompleted || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!c.courseJustCompleted) return;
      c.acknowledgeCompletion();
      _showCourseCompletedDialog(context);
    });
  }

  void _onWillPop() {
    // Refresh My Courses so returning to that tab reflects latest progress.
    if (Get.isRegistered<MyCoursesController>()) {
      Get.find<MyCoursesController>().onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CoursePlayerControllerImp>(
      builder: (controller) {
        _maybeShowCompletion(controller);
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) _onWillPop();
          },
          child: Scaffold(
            backgroundColor: AppColor.scaffoldBg,
            appBar: _buildAppBar(controller),
            body: _buildBody(controller),
            endDrawer: _SectionsDrawer(controller: controller),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(CoursePlayerControllerImp c) {
    return AppBar(
      backgroundColor: AppColor.scaffoldBg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColor.textPrimary),
        onPressed: () => Get.back(),
      ),
      title: Text(
        c.courseTitle,
        style: TextStyle(
          fontSize: AppTextSize.textSize16,
          fontWeight: FontWeight.w700,
          color: AppColor.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColor.textPrimary),
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            tooltip: 'Course Content',
          ),
        ),
      ],
    );
  }

  Widget _buildBody(CoursePlayerControllerImp c) {
    if (c.requestStatus == RequestStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.primaryColor),
      );
    }
    if (c.requestStatus != RequestStatus.success) {
      return _ErrorView(controller: c);
    }
    if (c.allContents.isEmpty) {
      return _EmptyAccessView(controller: c);
    }

    final item = c.currentContent!;
    final type = (item.content.type ?? '').toUpperCase();

    return Column(
      children: [
        _ProgressBar(percentage: c.progressPercentage),
        Expanded(
          child: Column(
            children: [
              // Main content viewer
              Expanded(
                child: _buildViewer(type, item, c),
              ),
              // Footer: title + prev/next
              _ContentFooter(controller: c),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewer(
    String type,
    ContentWithSection item,
    CoursePlayerControllerImp c,
  ) {
    switch (type) {
      case 'VIDEO':
        return _VideoViewer(
          key: ValueKey('video-${item.content.id}'),
          content: item.content,
          onFinished: c.markCurrentComplete,
        );
      case 'PDF':
        return _PdfViewer(
          content: item.content,
          isCompleted: c.isCompleted(item.content.id ?? ''),
          onMarkComplete: c.markCurrentComplete,
        );
      case 'QUIZ':
        return _QuizLauncher(content: item.content, controller: c);
      default:
        return Center(
          child: Text(
            'Unknown content type: $type',
            style: TextStyle(color: AppColor.textHint),
          ),
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  Progress bar at top
// ═══════════════════════════════════════════════════════════════
class _ProgressBar extends StatelessWidget {
  final int percentage;
  const _ProgressBar({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pad16,
        vertical: AppPadding.pad8,
      ),
      color: AppColor.cardBg,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.radius10),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColor.gray.withValues(alpha: 0.15),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
              ),
            ),
          ),
          SizedBox(width: AppWidth.w12),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: AppTextSize.textSize12,
              fontWeight: FontWeight.w700,
              color: AppColor.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Content footer: title + prev/next
// ═══════════════════════════════════════════════════════════════
class _ContentFooter extends StatelessWidget {
  final CoursePlayerControllerImp controller;
  const _ContentFooter({required this.controller});

  @override
  Widget build(BuildContext context) {
    final item = controller.currentContent;
    if (item == null) return const SizedBox.shrink();
    final isDone = controller.isCompleted(item.content.id ?? '');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pad16,
        vertical: AppPadding.pad12,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.sectionTitle,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize12,
                        color: AppColor.textHint,
                      ),
                    ),
                    SizedBox(height: AppHeight.h3),
                    Text(
                      item.content.title ?? '',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize15,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isDone)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppPadding.pad8,
                    vertical: AppPadding.pad4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.greenColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.radius20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColor.greenColor, size: 14),
                      SizedBox(width: AppWidth.w4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: AppTextSize.textSize10,
                          fontWeight: FontWeight.w700,
                          color: AppColor.greenColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: AppHeight.h12),
          Row(
            children: [
              _NavButton(
                icon: Icons.arrow_back_ios_rounded,
                label: 'Previous',
                enabled: controller.hasPrev,
                onTap: controller.goPrev,
              ),
              SizedBox(width: AppWidth.w8),
              if (!isDone)
                Expanded(
                  child: _PrimaryButton(
                    label: 'Mark as Complete',
                    onTap: controller.markCurrentComplete,
                    icon: Icons.check_rounded,
                  ),
                )
              else
                const Spacer(),
              SizedBox(width: AppWidth.w8),
              _NavButton(
                icon: Icons.arrow_forward_ios_rounded,
                label: 'Next',
                enabled: controller.hasNext,
                onTap: controller.goNext,
                trailingIcon: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool trailingIcon;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.trailingIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.pad12,
          vertical: AppPadding.pad10,
        ),
        decoration: BoxDecoration(
          color: enabled
              ? AppColor.primaryLight
              : AppColor.gray.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.radius10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!trailingIcon)
              Icon(icon,
                  size: 14,
                  color:
                      enabled ? AppColor.primaryColor : AppColor.textHint),
            if (!trailingIcon) SizedBox(width: AppWidth.w4),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTextSize.textSize12,
                fontWeight: FontWeight.w600,
                color: enabled ? AppColor.primaryColor : AppColor.textHint,
              ),
            ),
            if (trailingIcon) SizedBox(width: AppWidth.w4),
            if (trailingIcon)
              Icon(icon,
                  size: 14,
                  color:
                      enabled ? AppColor.primaryColor : AppColor.textHint),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppPadding.pad10),
        decoration: BoxDecoration(
          color: AppColor.primaryColor,
          borderRadius: BorderRadius.circular(AppRadius.radius10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            SizedBox(width: AppWidth.w4),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTextSize.textSize12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Video viewer (uses YouTube player for YT URLs, fallback for others)
// ═══════════════════════════════════════════════════════════════
class _VideoViewer extends StatefulWidget {
  final Content content;
  final VoidCallback onFinished;

  const _VideoViewer({
    super.key,
    required this.content,
    required this.onFinished,
  });

  @override
  State<_VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<_VideoViewer> {
  YoutubePlayerController? _ytController;
  bool _finishedFired = false;

  bool get _isYouTube {
    final url = widget.content.videoUrl ?? '';
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  @override
  void initState() {
    super.initState();
    if (_isYouTube) {
      final id = YoutubePlayer.convertUrlToId(widget.content.videoUrl ?? '') ??
          '';
      if (id.isNotEmpty) {
        _ytController = YoutubePlayerController(
          initialVideoId: id,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        )..addListener(_ytListener);
      }
    }
  }

  void _ytListener() {
    final c = _ytController;
    if (c == null || _finishedFired) return;
    if (c.value.playerState == PlayerState.ended) {
      _finishedFired = true;
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    _ytController?.removeListener(_ytListener);
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.content.videoUrl ?? '';
    if (url.isEmpty) {
      return _centeredMessage(
        icon: Icons.videocam_off_rounded,
        text: 'No video URL available',
      );
    }
    if (_isYouTube && _ytController != null) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: YoutubePlayer(
          controller: _ytController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColor.primaryColor,
          progressColors: ProgressBarColors(
            playedColor: AppColor.primaryColor,
            handleColor: AppColor.primaryColor,
          ),
        ),
      );
    }
    // Non-YouTube: fallback to external viewer
    return _ExternalMediaView(
      url: url,
      icon: Icons.play_circle_outline_rounded,
      title: widget.content.title ?? 'Video',
      buttonLabel: 'Open Video',
    );
  }

  Widget _centeredMessage({required IconData icon, required String text}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColor.textHint),
          SizedBox(height: AppHeight.h12),
          Text(
            text,
            style: TextStyle(
              fontSize: AppTextSize.textSize14,
              color: AppColor.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  PDF viewer — opens externally via url_launcher
// ═══════════════════════════════════════════════════════════════
class _PdfViewer extends StatelessWidget {
  final Content content;
  final bool isCompleted;
  final VoidCallback onMarkComplete;

  const _PdfViewer({
    required this.content,
    required this.isCompleted,
    required this.onMarkComplete,
  });

  @override
  Widget build(BuildContext context) {
    final url = content.pdfUrl ?? '';
    if (url.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf_rounded,
                size: 48, color: AppColor.textHint),
            SizedBox(height: AppHeight.h12),
            Text(
              'No PDF URL available',
              style: TextStyle(
                fontSize: AppTextSize.textSize14,
                color: AppColor.textHint,
              ),
            ),
          ],
        ),
      );
    }
    return _ExternalMediaView(
      url: url,
      icon: Icons.picture_as_pdf_rounded,
      title: content.title ?? 'Document',
      buttonLabel: 'Open PDF',
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  External media placeholder with "Open in browser" button
// ═══════════════════════════════════════════════════════════════
class _ExternalMediaView extends StatelessWidget {
  final String url;
  final IconData icon;
  final String title;
  final String buttonLabel;

  const _ExternalMediaView({
    required this.url,
    required this.icon,
    required this.title,
    required this.buttonLabel,
  });

  Future<void> _open() async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'Open failed',
        'Could not open this file',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.scaffoldBg,
      padding: EdgeInsets.all(AppPadding.pad24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColor.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppColor.primaryColor),
          ),
          SizedBox(height: AppHeight.h20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTextSize.textSize16,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
            ),
          ),
          SizedBox(height: AppHeight.h8),
          Text(
            'Tap below to open this file',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTextSize.textSize13,
              color: AppColor.textSecondary,
            ),
          ),
          SizedBox(height: AppHeight.h24),
          GestureDetector(
            onTap: _open,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.pad24,
                vertical: AppPadding.pad12,
              ),
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(AppRadius.radius25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.open_in_new_rounded,
                      color: Colors.white, size: 18),
                  SizedBox(width: AppWidth.w8),
                  Text(
                    buttonLabel,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Quiz launcher — shows a "Start Quiz" entry card in the player
// ═══════════════════════════════════════════════════════════════
class _QuizLauncher extends StatelessWidget {
  final Content content;
  final CoursePlayerControllerImp controller;

  const _QuizLauncher({required this.content, required this.controller});

  Future<void> _openQuiz() async {
    final contentId = content.id;
    if (contentId == null || contentId.isEmpty) return;
    final result = await Get.toNamed(
      AppRoutesNames.quizScreen,
      arguments: {'id': contentId, 'mode': 'content'},
    );
    // Quiz backend auto-completes content on pass. Sync local state.
    if (result == true) {
      await controller.refreshAfterExternalChange();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = controller.isCompleted(content.id ?? '');
    return Container(
      color: AppColor.scaffoldBg,
      padding: EdgeInsets.all(AppPadding.pad24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColor.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.quiz_rounded,
                size: 48, color: AppColor.primaryColor),
          ),
          SizedBox(height: AppHeight.h20),
          Text(
            content.title ?? 'Quiz',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTextSize.textSize18,
              fontWeight: FontWeight.w800,
              color: AppColor.textPrimary,
            ),
          ),
          SizedBox(height: AppHeight.h8),
          Text(
            isDone
                ? 'You already passed this quiz. You can retake it anytime.'
                : 'Test your knowledge and unlock this lesson.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTextSize.textSize13,
              color: AppColor.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: AppHeight.h24),
          GestureDetector(
            onTap: _openQuiz,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.pad24,
                vertical: AppPadding.pad12,
              ),
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(AppRadius.radius25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDone ? Icons.refresh_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: AppWidth.w8),
                  Text(
                    isDone ? 'Retake Quiz' : 'Start Quiz',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Sections drawer (right side) — all sections + contents with status
// ═══════════════════════════════════════════════════════════════
class _SectionsDrawer extends StatelessWidget {
  final CoursePlayerControllerImp controller;
  const _SectionsDrawer({required this.controller});

  IconData _iconForType(String? type) {
    switch ((type ?? '').toUpperCase()) {
      case 'VIDEO':
        return Icons.play_circle_outline_rounded;
      case 'PDF':
        return Icons.picture_as_pdf_outlined;
      case 'QUIZ':
        return Icons.quiz_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = controller.courseData?.sections ?? [];
    return Drawer(
      backgroundColor: AppColor.cardBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(AppPadding.pad16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Course Content',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize16,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${controller.progressPercentage}%',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize14,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: sections.length,
                itemBuilder: (ctx, i) {
                  final section = sections[i];
                  final contents = section.contents ?? const [];
                  return Theme(
                    data: Theme.of(ctx)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded:
                          controller.currentContent?.sectionId == section.id,
                      title: Text(
                        section.title ?? 'Section ${i + 1}',
                        style: TextStyle(
                          fontSize: AppTextSize.textSize14,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      children: contents.map((content) {
                        final idx = controller.allContents.indexWhere(
                            (c) => c.content.id == content.id);
                        final isAccessible = idx >= 0;
                        final isCurrent = idx == controller.currentIndex;
                        final isDone =
                            controller.isCompleted(content.id ?? '');
                        return ListTile(
                          dense: true,
                          onTap: isAccessible
                              ? () {
                                  controller.goToContent(idx);
                                  Navigator.of(ctx).pop();
                                }
                              : null,
                          tileColor: isCurrent
                              ? AppColor.primaryLight.withValues(alpha: 0.5)
                              : null,
                          leading: Icon(
                            _iconForType(content.type),
                            size: 18,
                            color: isAccessible
                                ? AppColor.primaryColor
                                : AppColor.textHint,
                          ),
                          title: Text(
                            content.title ?? '',
                            style: TextStyle(
                              fontSize: AppTextSize.textSize13,
                              fontWeight:
                                  isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: isAccessible
                                  ? AppColor.textPrimary
                                  : AppColor.textHint,
                            ),
                          ),
                          trailing: Icon(
                            isDone
                                ? Icons.check_circle_rounded
                                : isAccessible
                                    ? Icons.lock_open_rounded
                                    : Icons.lock_rounded,
                            size: 16,
                            color: isDone
                                ? AppColor.greenColor
                                : isAccessible
                                    ? AppColor.greenColor
                                    : AppColor.textHint,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Error & empty states
// ═══════════════════════════════════════════════════════════════
class _ErrorView extends StatelessWidget {
  final CoursePlayerControllerImp controller;
  const _ErrorView({required this.controller});

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;
    switch (controller.requestStatus) {
      case RequestStatus.offline:
      case RequestStatus.noInternet:
        message = AppStrings.youAreOffline.tr;
        icon = Icons.wifi_off_rounded;
        break;
      case RequestStatus.serverFailure:
      case RequestStatus.serverException:
        message = AppStrings.serverError.tr;
        icon = Icons.cloud_off_rounded;
        break;
      default:
        message = AppStrings.noData.tr;
        icon = Icons.inbox_rounded;
    }
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
              child: Icon(icon, size: 40, color: AppColor.primaryColor),
            ),
            SizedBox(height: AppHeight.h20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTextSize.textSize16,
                fontWeight: FontWeight.w500,
                color: AppColor.textSecondary,
              ),
            ),
            SizedBox(height: AppHeight.h20),
            GestureDetector(
              onTap: controller.retry,
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
}

class _EmptyAccessView extends StatelessWidget {
  final CoursePlayerControllerImp controller;
  const _EmptyAccessView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppPadding.pad40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_rounded,
                size: 56, color: AppColor.textHint),
            SizedBox(height: AppHeight.h16),
            Text(
              'No accessible content',
              style: TextStyle(
                fontSize: AppTextSize.textSize16,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(height: AppHeight.h8),
            Text(
              'This course has no content you can access yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTextSize.textSize13,
                color: AppColor.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Course completion celebration dialog
// ═══════════════════════════════════════════════════════════════
void _showCourseCompletedDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
        child: Container(
          padding: EdgeInsets.all(AppPadding.pad24),
          decoration: BoxDecoration(
            color: AppColor.cardBg,
            borderRadius: BorderRadius.circular(AppRadius.radius20),
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryColor.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColor.primaryColor, AppColor.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
              SizedBox(height: AppHeight.h20),
              Text(
                'Course Completed!',
                style: TextStyle(
                  fontSize: AppTextSize.textSize20,
                  fontWeight: FontWeight.w800,
                  color: AppColor.textPrimary,
                ),
              ),
              SizedBox(height: AppHeight.h8),
              Text(
                "You've finished every lesson. Great job!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppTextSize.textSize13,
                  color: AppColor.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: AppHeight.h24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: AppPadding.pad12),
                        decoration: BoxDecoration(
                          color: AppColor.primaryLight,
                          borderRadius:
                              BorderRadius.circular(AppRadius.radius12),
                        ),
                        child: Center(
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: AppTextSize.textSize14,
                              fontWeight: FontWeight.w700,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppWidth.w12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Get.back(); // close player
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: AppPadding.pad12),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius:
                              BorderRadius.circular(AppRadius.radius12),
                        ),
                        child: Center(
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: AppTextSize.textSize14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
