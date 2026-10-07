import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// The resolutions a loaded YouTube video can be switched between.
class YoutubeQualityOptions {
  const YoutubeQualityOptions({required this.levels, required this.current});

  /// YouTube's level names (`hd1080`, `hd720`, `large`, …), best first,
  /// without `auto`.
  final List<String> levels;

  /// The level YouTube is streaming right now.
  final String current;
}

/// Lets the student choose the resolution of a YouTube lesson.
///
/// The IFrame API's own `setPlaybackQuality` has been an empty function since
/// 2019. What still works is `setPlaybackQualityRange` on the player element
/// inside YouTube's embed iframe — the same call YouTube's quality menu makes.
/// That iframe is cross-origin to the page youtube_player_flutter loads, so
/// [install] injects a small listener into it and the page reaches it through
/// postMessage.
///
/// This leans on YouTube internals. If they change, [read] returns null and
/// the quality menu reports that it isn't available; playback is unaffected.
class YoutubeQuality {
  YoutubeQuality._();

  /// Lets YouTube pick the resolution from bandwidth and player size.
  static const String auto = 'auto';

  /// Injects the listener into frames loaded from now on. Call it as soon as
  /// the player's webview exists: the embed iframe only starts loading once
  /// the IFrame API scripts have downloaded, which leaves a few hundred
  /// milliseconds to get in first.
  static Future<void> install(InAppWebViewController webView) async {
    try {
      await webView.addUserScript(
        userScript: UserScript(
          source: _bridgeSource,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: false,
        ),
      );
    } on Exception {
      // Without the listener, read() reports quality as unavailable.
    }
  }

  /// The levels the current video offers, or null when quality can't be
  /// changed: the player isn't loaded yet or the listener isn't reachable.
  static Future<YoutubeQualityOptions?> read(
    YoutubePlayerController controller,
  ) async {
    final webView = controller.value.webViewController;
    if (webView == null || !controller.value.isReady) return null;

    try {
      final result = await webView.callAsyncJavaScript(
        functionBody: _readSource,
      );
      final value = result?.value;
      if (value is! Map || value['supported'] != true) return null;

      final levels = (value['levels'] as List? ?? const [])
          .whereType<String>()
          .where((level) => level != auto)
          .toList();
      if (levels.isEmpty) return null;

      final current = value['current'];
      return YoutubeQualityOptions(
        levels: levels,
        current: current is String && current.isNotEmpty ? current : auto,
      );
    } on Exception {
      return null;
    }
  }

  /// Switches the video to [level], or back to [auto]. Playback carries on
  /// from the same position after a brief rebuffer.
  static Future<void> select(
    YoutubePlayerController controller,
    String level,
  ) async {
    final webView = controller.value.webViewController;
    if (webView == null) return;

    try {
      await webView.callAsyncJavaScript(
        functionBody: _selectSource,
        arguments: {'level': level},
      );
    } on Exception {
      // Nothing to recover: the video keeps playing at its current quality.
    }
  }

  /// A human label for one of YouTube's level names, e.g. `hd720` → `720p`.
  static String label(String level) {
    final hd = RegExp(r'^hd(\d+)$').firstMatch(level);
    if (hd != null) return '${hd.group(1)}p';

    return switch (level) {
      auto => 'Auto',
      'highres' => '4320p',
      'large' => '480p',
      'medium' => '360p',
      'small' => '240p',
      'tiny' || 'light' => '144p',
      _ => level,
    };
  }

  /// Runs in every frame; acts only inside YouTube's embed iframe, and only on
  /// messages from the page that hosts it.
  static const String _bridgeSource = '''
(function () {
  if (window.top === window || window.graketQualityBridge) return;
  window.graketQualityBridge = true;
  window.addEventListener('message', function (event) {
    var data = event.data;
    if (event.source !== window.parent || !data || typeof data.graketQuality !== 'string') return;
    var player = document.getElementById('movie_player') || document.querySelector('.html5-video-player');
    var supported = !!player && typeof player.setPlaybackQualityRange === 'function';
    if (data.graketQuality === 'ping') {
      window.parent.postMessage({ graketQualitySupported: supported }, '*');
    } else if (supported) {
      player.setPlaybackQualityRange(data.graketQuality, data.graketQuality);
    }
  });
})();
''';

  /// Pings the listener — no answer within a second means it isn't there —
  /// then reads the levels through the public IFrame API, which still
  /// reports them correctly.
  static const String _readSource = '''
var frame = typeof player === 'object' && player && player.getIframe ? player.getIframe() : null;
if (!frame || !frame.contentWindow) return null;
var supported = await new Promise(function (resolve) {
  var timer = setTimeout(function () { finish(false); }, 1000);
  function onMessage(event) {
    var data = event.data;
    if (event.source !== frame.contentWindow || !data || typeof data.graketQualitySupported !== 'boolean') return;
    finish(data.graketQualitySupported);
  }
  function finish(value) {
    clearTimeout(timer);
    window.removeEventListener('message', onMessage);
    resolve(value);
  }
  window.addEventListener('message', onMessage);
  frame.contentWindow.postMessage({ graketQuality: 'ping' }, '*');
});
return { supported: supported, levels: player.getAvailableQualityLevels() || [], current: player.getPlaybackQuality() || '' };
''';

  static const String _selectSource = '''
var frame = typeof player === 'object' && player && player.getIframe ? player.getIframe() : null;
if (frame && frame.contentWindow) frame.contentWindow.postMessage({ graketQuality: level }, '*');
''';
}
