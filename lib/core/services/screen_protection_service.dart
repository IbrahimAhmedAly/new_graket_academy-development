import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:screen_protector/screen_protector.dart';

import '../constants/app_strings.dart';
import '../constants/security_flags.dart';

/// Keeps course content out of screenshots, screen recordings, screen sharing
/// and mirroring — app-wide, from launch.
///
/// The platforms allow different things:
///
/// * Android: FLAG_SECURE blanks the app in screenshots, recordings, screen
///   shares (Meet, Zoom, WhatsApp…), casts and the recent-apps preview.
///   `allowAudioPlaybackCapture="false"` in the manifest keeps lesson audio
///   out of recordings as well.
/// * iOS: capture can't be blocked outright. Screenshots and recordings are
///   blanked with a secure-layer technique, but that isn't an official API,
///   so [isCaptured] also reports whenever the screen is being recorded,
///   shared or mirrored. The app then covers itself (ScreenCaptureShield) and
///   pauses playback, whose audio would otherwise still be recorded. The
///   app-switcher preview is blurred.
///
/// On both, [protectWebView] stops embedded videos from being sent to a TV
/// with AirPlay or Chromecast, or popped out into picture-in-picture.
///
/// Turned off entirely with [kEnableScreenSecurity].
class ScreenProtectionService extends GetxService with WidgetsBindingObserver {
  /// The running service, or null when it hasn't been registered (tests).
  static ScreenProtectionService? get instance =>
      Get.isRegistered<ScreenProtectionService>()
      ? Get.find<ScreenProtectionService>()
      : null;

  /// True while iOS reports the screen as being recorded, shared or mirrored.
  /// Stays false on Android, where FLAG_SECURE already blanks every capture.
  final RxBool isCaptured = false.obs;

  /// How often the iOS capture state is re-read while the app is in front.
  ///
  /// screen_protector's capture listener is dropped every time the app
  /// becomes active again — closing Control Center included, which is where
  /// recordings are started — so this poll is what reliably catches them.
  static const Duration _capturePollInterval = Duration(seconds: 2);

  Timer? _capturePoll;

  Future<ScreenProtectionService> init() async {
    if (!kEnableScreenSecurity) {
      await _run('turn off protection', ScreenProtector.preventScreenshotOff);
      return this;
    }

    // Android: FLAG_SECURE. iOS: the secure layer over the window.
    await _run('block screen capture', ScreenProtector.preventScreenshotOn);

    if (Platform.isIOS) {
      await _run(
        'blur the app switcher',
        ScreenProtector.protectDataLeakageWithBlur,
      );
      WidgetsBinding.instance.addObserver(this);
      _watchCapture();
    }
    return this;
  }

  /// Injects a script that keeps every video in [webView] from leaving the
  /// app: no AirPlay, no Chromecast, no picture-in-picture. Call it as soon as
  /// the webview exists, before its pages load — it applies to frames loaded
  /// from then on.
  Future<void> protectWebView(InAppWebViewController webView) async {
    if (!kEnableScreenSecurity) return;

    try {
      await webView.addUserScript(
        userScript: UserScript(
          source: _mediaLockSource,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: false,
        ),
      );
    } on Exception catch (error, stackTrace) {
      log(
        'Failed to protect web video: $error',
        name: 'ScreenProtection',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _watchCapture();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _capturePoll?.cancel();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _capturePoll?.cancel();
    if (Platform.isIOS) ScreenProtector.removeListener();
    super.onClose();
  }

  /// Listens for capture changes, reads the current state and (re)starts the
  /// poll. Safe to repeat: the plugin replaces its observers on each call.
  void _watchCapture() {
    ScreenProtector.addListener(_onScreenshot, _onCaptureChanged);
    _syncCaptureState();
    _capturePoll?.cancel();
    _capturePoll = Timer.periodic(
      _capturePollInterval,
      (_) => _syncCaptureState(),
    );
  }

  Future<void> _syncCaptureState() async {
    try {
      _onCaptureChanged(await ScreenProtector.isRecording());
    } catch (error, stackTrace) {
      log(
        'Failed to read screen capture state: $error',
        name: 'ScreenProtection',
        stackTrace: stackTrace,
      );
    }
  }

  void _onCaptureChanged(bool captured) => isCaptured.value = captured;

  /// iOS still saves the screenshot — blank, thanks to the secure layer — so
  /// say why, the way Android's own "can't take screenshot" message does.
  void _onScreenshot() {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      AppStrings.protectedContent.tr,
      AppStrings.screenshotNotAllowed.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _run(String action, Future<void> Function() call) async {
    try {
      await call();
    } catch (error, stackTrace) {
      log(
        'Failed to $action: $error',
        name: 'ScreenProtection',
        stackTrace: stackTrace,
      );
    }
  }

  /// Runs in every frame of a protected webview, YouTube's embed iframe
  /// included, and re-applies itself whenever the page changes, so videos
  /// added later are covered too.
  static const String _mediaLockSource = '''
(function () {
  if (window.graketMediaLock) return;
  window.graketMediaLock = true;
  function lockAll() {
    var videos = document.getElementsByTagName('video');
    for (var i = 0; i < videos.length; i++) {
      videos[i].disableRemotePlayback = true;
      videos[i].disablePictureInPicture = true;
      videos[i].setAttribute('x-webkit-airplay', 'deny');
    }
  }
  new MutationObserver(lockAll).observe(document, { childList: true, subtree: true });
  lockAll();
})();
''';
}
