import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/course_player/course_player_controller.dart';
import 'package:new_graket_acadimy/controller/my_courses_controller.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/services/content_view_tracker.dart';
import 'package:new_graket_acadimy/core/services/video_watch_tracker.dart';
import 'package:new_graket_acadimy/model/courses/get_course_by_id_model.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/view/new_screens/course_player/notes_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class CoursePlayerScreen extends StatefulWidget {
  const CoursePlayerScreen({super.key});

  @override
  State<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends State<CoursePlayerScreen>
    with WidgetsBindingObserver {
  YoutubePlayerController? _yt;
  String? _activeVideoId;
  bool _finishedFired = false;

  /// Records which parts of each video are actually played, so the dashboard
  /// can report a real watch percentage rather than a completion checkbox.
  final VideoWatchTracker _watchTracker = VideoWatchTracker();

  /// Records opens and read depth for the item on screen.
  final ContentViewTracker _viewTracker = ContentViewTracker();

  /// The content whose view is currently open, so switching lessons closes the
  /// previous one exactly once.
  String? _trackedContentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Get.put(CoursePlayerControllerImp());
  }

  /// Banks what has been tracked so far whenever the app leaves the screen.
  ///
  /// Leaving the foreground is the last moment tracking can be sure of
  /// reaching the network: an app killed from the background never gets
  /// another callback, and everything held locally — segments, the playhead,
  /// how far into a PDF the student got — would go with it. Re-sending
  /// segments is safe, because the server merges them into a union.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _viewTracker.onForegrounded();
        break;
      case AppLifecycleState.inactive:
        // Transient — a notification shade or an incoming call.
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _watchTracker.flush();
        _viewTracker.onBackgrounded();
        break;
      case AppLifecycleState.detached:
        // The engine is going away, so the view will never be closed by a
        // lesson switch or a dispose. Closing it here is the only chance to
        // record its dwell time and read depth at all.
        _watchTracker.flush();
        _viewTracker.end();
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Flush before tearing down: whatever was watched up to this moment still
    // counts, even though the screen is going away.
    _watchTracker.dispose();
    _viewTracker.end();

    _yt?.dispose();
    _yt = null;
    // Make sure we leave portrait + system UI in a good state, even if the
    // user exits the screen while still in fullscreen.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  /// Ensure we have a YoutubePlayerController for the current video id.
  /// Returns null if the given URL isn't a YouTube URL we can resolve.
  ///
  /// NOTE: this runs inside build(). We must NOT dispose the previous
  /// controller here — the old player subtree (ProgressBar, PlayPauseButton…)
  /// is still mounted this frame and would touch a dead controller, which is
  /// what threw "A YoutubePlayerController was used after being disposed".
  /// Instead we retire the old controller in a post-frame callback, and the
  /// ValueKey on YoutubePlayerBuilder (see build) tears the old subtree down
  /// cleanly before that disposal runs.
  YoutubePlayerController? _ensureYtController(String? videoUrl) {
    if (videoUrl == null || videoUrl.isEmpty) return null;
    final id = YoutubePlayer.convertUrlToId(videoUrl);
    if (id == null || id.isEmpty) return null;
    if (_activeVideoId == id && _yt != null) return _yt;

    // Lesson changed → build a fresh controller for the new video and retire
    // the old one *after* this frame so nothing references it mid-build.
    final old = _yt;
    if (old != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
    _finishedFired = false;
    _activeVideoId = id;
    _yt = _createController(id);
    return _yt;
  }

  /// Opens tracking for the lesson now on screen, closing the previous one.
  ///
  /// Called from build, so the actual work is deferred to after the frame —
  /// these are network calls and must not run during a build pass.
  void _syncTrackedContent(dynamic item) {
    final contentId = item?.content?.id?.toString();
    if (contentId == null || contentId == _trackedContentId) return;

    _trackedContentId = contentId;
    final type = (item.content.type ?? '').toString().toUpperCase();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Videos get their own segment-level tracker; every type also gets a
      // view row so opens and dwell time are recorded uniformly.
      if (type == 'VIDEO') {
        await _watchTracker.attach(
          contentId: contentId,
          durationSec: (item.content.duration is int)
              ? (item.content.duration as int) * 60
              : null,
        );
      } else {
        // Leaving a video for a non-video lesson: bank what was watched.
        await _watchTracker.dispose();
      }

      await _viewTracker.start(
        contentId: contentId,
        type: type.isEmpty ? 'VIDEO' : type,
      );
    });
  }

  YoutubePlayerController _createController(String id) {
    late final YoutubePlayerController controller;
    controller =
        YoutubePlayerController(
          initialVideoId: id,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: true,
          ),
        )..addListener(() {
          // Ignore callbacks from a controller that has been swapped out.
          if (!identical(_yt, controller)) return;

          // Feed playback into the watch tracker. Only positions reported while
          // actually playing become watched segments, so scrubbing through the
          // timeline never counts as having watched it.
          final value = controller.value;
          _watchTracker.onTick(
            positionSec: value.position.inMilliseconds / 1000,
            isPlaying: value.isPlaying,
            durationSec: value.metaData.duration.inSeconds > 0
                ? value.metaData.duration.inSeconds
                : null,
          );

          if (_finishedFired) return;
          if (value.playerState == PlayerState.ended) {
            _finishedFired = true;
            _watchTracker.onEnded();
            if (Get.isRegistered<CoursePlayerControllerImp>()) {
              Get.find<CoursePlayerControllerImp>().markCurrentComplete();
            }
          }
        });
    return controller;
  }

  /// Called by YoutubePlayerBuilder when the user enters fullscreen via the
  /// expand button or landscape rotation. Lock to landscape + hide system UI
  /// so the video genuinely fills the whole device screen like YouTube.
  void _onEnterFullScreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// Called when the user taps the fullscreen exit icon (or double-taps back).
  /// Restore portrait + show the status/nav bar.
  void _onExitFullScreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
    // Make sure we leave any lingering landscape lock behind us
    _onExitFullScreen();
    if (Get.isRegistered<MyCoursesController>()) {
      Get.find<MyCoursesController>().onRefresh();
    }
  }

  /// Restart the current YouTube lesson from the beginning. Wired to the
  /// "Watch Again" button that appears once a video is completed.
  void _watchAgain() {
    final c = _yt;
    if (c == null) return;
    _finishedFired = false;
    // Told to the tracker directly rather than left to be inferred from the
    // player: this button is the one place where a re-watch is unambiguous,
    // and a lesson can be marked complete without the video ever ending.
    _watchTracker.markReplay();
    c.seekTo(Duration.zero);
    c.play();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CoursePlayerControllerImp>(
      builder: (controller) {
        _maybeShowCompletion(controller);

        // Decide whether the current content is a YouTube video. If so we
        // spin up / reuse a controller and wrap the whole Scaffold in a
        // YoutubePlayerBuilder — that lets the player replace the entire
        // screen in landscape/fullscreen, just like the YouTube app.
        final item = controller.currentContent;
        final isVideoContent =
            item != null && (item.content.type ?? '').toUpperCase() == 'VIDEO';
        final ytController = isVideoContent
            ? _ensureYtController(item.content.videoUrl)
            : null;

        // Track the lesson the student moved to. Deferred to after the frame
        // because it performs network calls and must not run during build.
        _syncTrackedContent(item);

        Widget scaffold = PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) _onWillPop();
          },
          child: Scaffold(
            backgroundColor: AppColor.scaffoldBg,
            appBar: _buildAppBar(controller),
            body: _buildBody(controller, ytController),
          ),
        );

        if (ytController != null) {
          // The builder swaps the subtree for the bare player widget when in
          // landscape orientation — exactly the YouTube fullscreen pattern.
          // Keying by the video id forces a clean teardown/rebuild of the
          // player subtree on every lesson switch, so the new controller never
          // gets hot-swapped onto the old (about-to-be-disposed) element tree.
          return YoutubePlayerBuilder(
            key: ValueKey('yt-$_activeVideoId'),
            onEnterFullScreen: _onEnterFullScreen,
            onExitFullScreen: _onExitFullScreen,
            player: YoutubePlayer(
              controller: ytController,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColor.primaryColor,
              progressColors: ProgressBarColors(
                playedColor: AppColor.primaryColor,
                handleColor: AppColor.primaryColor,
              ),
            ),
            builder: (ctx, player) {
              // Inject the supplied player widget into the Scaffold via
              // InheritedWidget so _buildBody → _VideoViewer can grab it.
              return _InheritedYtPlayer(player: player, child: scaffold);
            },
          );
        }

        return scaffold;
      },
    );
  }

  PreferredSizeWidget _buildAppBar(CoursePlayerControllerImp c) {
    return AppBar(
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
        c.courseTitle,
        style: TextStyle(
          fontSize: AppTextSize.textSize16,
          fontWeight: FontWeight.w700,
          color: AppColor.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        // Notes for the current lesson
        IconButton(
          icon: const Icon(
            Icons.sticky_note_2_outlined,
            color: AppColor.textPrimary,
          ),
          tooltip: 'Notes',
          onPressed: () {
            final item = c.currentContent;
            if (item == null) return;
            NotesBottomSheet.show(
              context: context,
              contentId: item.content.id ?? '',
              contentTitle: item.content.title ?? 'Note',
              userToken: c.userToken,
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(
    CoursePlayerControllerImp c,
    YoutubePlayerController? ytController,
  ) {
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
        // The current lesson is pinned at the very top, like Udemy.
        _buildTopStage(type, item, c, ytController),
        // Below the player: lesson info + the full, scrollable curriculum
        // the user taps to jump between lessons.
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              _LessonInfoBar(
                controller: c,
                onWatchAgain: ytController != null ? _watchAgain : null,
              ),
              _InlineCurriculum(controller: c),
            ],
          ),
        ),
      ],
    );
  }

  /// The fixed-height stage at the top that shows the current lesson. A real
  /// YouTube video gets a clean 16:9 frame; other content types (PDF/quiz) get
  /// a comfortable slice of the screen and scroll their own content.
  Widget _buildTopStage(
    String type,
    ContentWithSection item,
    CoursePlayerControllerImp c,
    YoutubePlayerController? ytController,
  ) {
    if (type == 'VIDEO' && ytController != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: _buildViewer(type, item, c, ytController),
      );
    }
    return SizedBox(
      height: 320,
      child: _buildViewer(type, item, c, ytController),
    );
  }

  Widget _buildViewer(
    String type,
    ContentWithSection item,
    CoursePlayerControllerImp c,
    YoutubePlayerController? ytController,
  ) {
    switch (type) {
      case 'VIDEO':
        return _VideoViewer(
          key: ValueKey('video-${item.content.id}'),
          content: item.content,
          ytAvailable: ytController != null,
        );
      case 'PDF':
        return _PdfViewer(
          // Without a per-document key the element for the previous PDF is
          // reused: initState never runs again, so the old file stays on
          // screen and its page callbacks are recorded against the new
          // lesson's view.
          key: ValueKey('pdf-${item.content.id}'),
          content: item.content,
          isCompleted: c.isCompleted(item.content.id ?? ''),
          onMarkComplete: c.markCurrentComplete,
          onPdfRendered: _viewTracker.setTotalPages,
          onPdfPageChanged: _viewTracker.onPageChanged,
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

// InheritedWidget that carries the YoutubePlayer widget built by
// YoutubePlayerBuilder down to the VideoViewer in the body tree.
class _InheritedYtPlayer extends InheritedWidget {
  final Widget player;
  const _InheritedYtPlayer({required this.player, required super.child});

  static Widget? playerOf(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<_InheritedYtPlayer>();
    return w?.player;
  }

  @override
  bool updateShouldNotify(_InheritedYtPlayer old) => old.player != player;
}

// ═══════════════════════════════════════════════════════════════
//  Lesson info bar: section + title + a single action button
//  (Mark as Complete / Watch Again). No prev/next — the user jumps
//  between lessons from the curriculum list below.
// ═══════════════════════════════════════════════════════════════
class _LessonInfoBar extends StatelessWidget {
  final CoursePlayerControllerImp controller;
  final VoidCallback? onWatchAgain;
  const _LessonInfoBar({required this.controller, this.onWatchAgain});

  @override
  Widget build(BuildContext context) {
    final item = controller.currentContent;
    if (item == null) return const SizedBox.shrink();
    final isDone = controller.isCompleted(item.content.id ?? '');
    final isVideo = (item.content.type ?? '').toUpperCase() == 'VIDEO';

    return Container(
      padding: EdgeInsets.all(AppPadding.pad16),
      color: AppColor.cardBg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
              fontSize: AppTextSize.textSize18,
              fontWeight: FontWeight.w800,
              color: AppColor.textPrimary,
            ),
          ),
          SizedBox(height: AppHeight.h16),
          // A single full-width action that depends on completion state.
          SizedBox(
            width: double.infinity,
            child: !isDone
                ? _PrimaryButton(
                    label: 'Mark as Complete',
                    onTap: controller.markCurrentComplete,
                    icon: Icons.check_rounded,
                  )
                : (isVideo && onWatchAgain != null)
                ? _PrimaryButton(
                    label: 'Watch Again',
                    onTap: onWatchAgain!,
                    icon: Icons.replay_rounded,
                  )
                : const _CompletedChip(),
          ),
        ],
      ),
    );
  }
}

// A static "Completed" pill shown for finished non-video lessons.
class _CompletedChip extends StatelessWidget {
  const _CompletedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppPadding.pad10),
      decoration: BoxDecoration(
        color: AppColor.greenColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.radius10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColor.greenColor,
            size: 18,
          ),
          SizedBox(width: AppWidth.w8),
          Text(
            'Completed',
            style: TextStyle(
              fontSize: AppTextSize.textSize14,
              fontWeight: FontWeight.w700,
              color: AppColor.greenColor,
            ),
          ),
        ],
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            SizedBox(width: AppWidth.w4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTextSize.textSize12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
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
//  Video viewer — for YouTube URLs we consume the player widget that
//  YoutubePlayerBuilder injected via _InheritedYtPlayer (so fullscreen
//  rotation can replace the whole subtree). Non-YouTube URLs fall back
//  to an external-open button.
// ═══════════════════════════════════════════════════════════════
class _VideoViewer extends StatelessWidget {
  final Content content;
  final bool ytAvailable;

  const _VideoViewer({
    super.key,
    required this.content,
    required this.ytAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final url = content.videoUrl ?? '';
    if (url.isEmpty) {
      return _centeredMessage(
        icon: Icons.videocam_off_rounded,
        text: 'No video URL available',
      );
    }
    if (ytAvailable) {
      final player = _InheritedYtPlayer.playerOf(context);
      if (player != null) {
        return Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: player,
        );
      }
    }
    // Non-YouTube: fallback to external viewer
    return _ExternalMediaView(
      url: url,
      icon: Icons.play_circle_outline_rounded,
      title: content.title ?? 'Video',
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
class _PdfViewer extends StatefulWidget {
  final Content content;
  final bool isCompleted;
  final VoidCallback onMarkComplete;

  /// Fires with the document's page count once it renders.
  final void Function(int totalPages)? onPdfRendered;

  /// Fires with the current page (0-based) as the student scrolls.
  final void Function(int page)? onPdfPageChanged;

  const _PdfViewer({
    super.key,
    required this.content,
    required this.isCompleted,
    required this.onMarkComplete,
    this.onPdfRendered,
    this.onPdfPageChanged,
  });

  @override
  State<_PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<_PdfViewer> {
  String? _localPath;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  @override
  void dispose() {
    // Best-effort cleanup so the cached file doesn't linger after the
    // lesson is closed.
    if (_localPath != null) {
      final f = File(_localPath!);
      f.exists().then((exists) {
        if (exists) f.delete();
      });
    }
    super.dispose();
  }

  Future<void> _downloadPdf() async {
    final url = widget.content.pdfUrl ?? '';
    if (url.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'No PDF URL available';
      });
      return;
    }
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        setState(() {
          _loading = false;
          _error = 'Failed to load PDF';
        });
        return;
      }
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/lesson_${widget.content.id ?? DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(response.bodyBytes, flush: true);
      if (!mounted) return;
      setState(() {
        _localPath = file.path;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not open this PDF';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.primaryColor),
      );
    }
    if (_error != null || _localPath == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.picture_as_pdf_rounded,
              size: 48,
              color: AppColor.textHint,
            ),
            SizedBox(height: AppHeight.h12),
            Text(
              _error ?? 'Could not open this PDF',
              style: TextStyle(
                fontSize: AppTextSize.textSize14,
                color: AppColor.textHint,
              ),
            ),
          ],
        ),
      );
    }
    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      fitPolicy: FitPolicy.BOTH,
      // Read depth: how far through the document the student actually got.
      // Without these the only signal is "opened", which cannot distinguish
      // skimming the first page from reading the whole thing.
      onRender: (pages) {
        if (pages != null && pages > 0) {
          widget.onPdfRendered?.call(pages);
        }
      },
      onPageChanged: (page, total) {
        if (page != null) widget.onPdfPageChanged?.call(page);
        if (total != null && total > 0) widget.onPdfRendered?.call(total);
      },
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
                  const Icon(
                    Icons.open_in_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
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

    // The stage above gives this a fixed height, and at larger text scales the
    // icon, title, description and button together exceed it. Scrolling inside
    // that box keeps every element reachable instead of clipping the button —
    // and the icon shrinks first, since it carries no information the title
    // does not already convey.
    return Container(
      color: AppColor.scaffoldBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 340;
          final circle = compact ? 64.0 : 96.0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: AppPadding.pad24,
              vertical: compact ? AppPadding.pad16 : AppPadding.pad24,
            ),
            child: ConstrainedBox(
              // Fill the stage when there is room to spare, so the content
              // stays vertically centred rather than hugging the top.
              constraints: BoxConstraints(
                minHeight:
                    constraints.maxHeight -
                    (compact ? AppPadding.pad16 : AppPadding.pad24) * 2,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: circle,
                    height: circle,
                    decoration: const BoxDecoration(
                      color: AppColor.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.quiz_rounded,
                      size: compact ? 32 : 48,
                      color: AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: compact ? AppHeight.h12 : AppHeight.h20),
                  Text(
                    content.title ?? 'Quiz',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                  SizedBox(height: compact ? AppHeight.h16 : AppHeight.h24),
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
                            isDone
                                ? Icons.refresh_rounded
                                : Icons.play_arrow_rounded,
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
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Inline curriculum — all sections + lessons shown right under the
//  player (Udemy style). It lives inside the body's ListView, so it is
//  a plain Column (no inner scroll). Tapping a lesson jumps to it.
// ═══════════════════════════════════════════════════════════════
class _InlineCurriculum extends StatelessWidget {
  final CoursePlayerControllerImp controller;
  const _InlineCurriculum({required this.controller});

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: "Course Content" + overall progress %.
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppPadding.pad16,
            AppPadding.pad16,
            AppPadding.pad16,
            AppPadding.pad8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Course Content',
                  style: TextStyle(
                    fontSize: AppTextSize.textSize16,
                    fontWeight: FontWeight.w800,
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
        // Sections — plain entries; the parent ListView handles scrolling.
        ...List.generate(sections.length, (i) {
          final section = sections[i];
          final contents = section.contents ?? const [];
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: PageStorageKey('sec-${section.id ?? i}'),
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
                  (c) => c.content.id == content.id,
                );
                final isAccessible = idx >= 0;
                final isCurrent = idx == controller.currentIndex;
                final isDone = controller.isCompleted(content.id ?? '');
                return ListTile(
                  dense: true,
                  onTap: isAccessible
                      ? () => controller.goToContent(idx)
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
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isAccessible
                          ? AppColor.textPrimary
                          : AppColor.textHint,
                    ),
                  ),
                  trailing: Icon(
                    isDone
                        ? Icons.check_circle_rounded
                        : isCurrent
                        ? Icons.play_circle_fill_rounded
                        : isAccessible
                        ? Icons.play_circle_outline_rounded
                        : Icons.lock_rounded,
                    size: 18,
                    color: isDone
                        ? AppColor.greenColor
                        : isAccessible
                        ? AppColor.primaryColor
                        : AppColor.textHint,
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
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
            const Icon(Icons.lock_rounded, size: 56, color: AppColor.textHint),
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
                        padding: EdgeInsets.symmetric(
                          vertical: AppPadding.pad12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryLight,
                          borderRadius: BorderRadius.circular(
                            AppRadius.radius12,
                          ),
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
                        padding: EdgeInsets.symmetric(
                          vertical: AppPadding.pad12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(
                            AppRadius.radius12,
                          ),
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
