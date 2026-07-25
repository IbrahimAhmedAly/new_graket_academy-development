import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../data/tracking_data/tracking_data.dart';
import '../class/data_request.dart';
import '../class/request_status.dart';
import '../constants/app_strings.dart';
import 'services.dart';

/// Tracks how long the student actually spends studying in the app.
///
/// A session opens when the app comes to the foreground and closes when it
/// leaves. While it is open, a heartbeat fires on a timer so the server can
/// tell a live session from one abandoned by a crash or a dead battery — the
/// server credits an abandoned session only up to its last heartbeat, so study
/// hours cannot quietly inflate while the app sits closed in a pocket.
///
/// Every call here is best-effort. Tracking must never interrupt a lesson, so
/// failures are swallowed rather than surfaced.
class StudySessionService extends GetxService with WidgetsBindingObserver {
  StudySessionService({TrackingData? trackingData})
    : _trackingData = trackingData ?? TrackingData(Get.find<DataRequest>());

  final TrackingData _trackingData;

  /// Must stay below the server's 150s idle timeout, with room for a missed
  /// beat or two on a poor connection.
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  String? _sessionId;
  Timer? _heartbeatTimer;
  bool _starting = false;

  String? get sessionId => _sessionId;
  bool get isActive => _sessionId != null;

  String get _token =>
      Get.find<MyServices>().sharedPreferences.getString(
        AppSharedPrefKeys.userTokenKey,
      ) ??
      '';

  Future<StudySessionService> init() async {
    WidgetsBinding.instance.addObserver(this);
    // The app is already in the foreground when this runs at startup.
    await startSession();
    return this;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        startSession();
        break;
      case AppLifecycleState.inactive:
        // Transient — a notification shade or an incoming call. Ending here
        // would fragment one genuine study session into many.
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        endSession();
        break;
    }
  }

  /// Opens a session, or resumes the one the server already has open.
  Future<void> startSession() async {
    if (_sessionId != null || _starting) return;

    final token = _token;
    if (token.isEmpty) return; // signed out: nothing to attribute time to

    _starting = true;
    try {
      final response = await _trackingData.startSession(
        token: token,
        tzOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
      );

      final id = _extractSessionId(response);
      if (id != null) {
        _sessionId = id;
        _startHeartbeat();
      }
    } catch (_) {
      // Tracking is never worth interrupting a lesson for.
    } finally {
      _starting = false;
    }
  }

  /// Closes the session and stops the heartbeat.
  Future<void> endSession() async {
    final id = _sessionId;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _sessionId = null;

    if (id == null) return;

    final token = _token;
    if (token.isEmpty) return;

    try {
      await _trackingData.endSession(token: token, sessionId: id);
    } catch (_) {
      // The server's idle sweep will close it at the last heartbeat.
    }
  }

  /// Ends the current session on sign-out so the next student starts clean.
  Future<void> handleLogout() => endSession();

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) => _beat());
  }

  Future<void> _beat() async {
    final id = _sessionId;
    if (id == null) return;

    final token = _token;
    if (token.isEmpty) return;

    try {
      final response = await _trackingData.heartbeat(
        token: token,
        sessionId: id,
      );

      // The server reports a session it has already closed (idle sweep) as
      // inactive. Reopen rather than beating against a dead session forever.
      if (_isInactive(response)) {
        _sessionId = null;
        _heartbeatTimer?.cancel();
        _heartbeatTimer = null;
        await startSession();
      }
    } catch (_) {
      // A missed beat is fine; the interval leaves room before the timeout.
    }
  }

  /// Digs the id out of `{ data: { data: { sessionId } } }`, tolerating the
  /// flatter shapes the API layer sometimes hands back.
  String? _extractSessionId(dynamic response) {
    final body = _successBody(response);
    if (body == null) return null;

    final data = body['data'];
    if (data is Map) {
      final inner = data['data'];
      if (inner is Map && inner['sessionId'] != null) {
        return inner['sessionId'].toString();
      }
      if (data['sessionId'] != null) return data['sessionId'].toString();
    }
    return null;
  }

  bool _isInactive(dynamic response) {
    final body = _successBody(response);
    if (body == null) return false;

    final data = body['data'];
    if (data is Map) {
      final inner = data['data'];
      if (inner is Map && inner['active'] == false) return true;
    }
    return false;
  }

  /// The response body when the call succeeded, otherwise null.
  ///
  /// `DataRequest` folds to a `(RequestStatus, Map)` record, but the two sides
  /// carry differently-typed maps, so this reads the fields positionally
  /// rather than pattern-matching on an exact record type.
  Map? _successBody(dynamic response) {
    if (response == null) return null;
    try {
      final status = response.$1;
      final body = response.$2;
      if (status != RequestStatus.success) return null;
      return body is Map ? body : null;
    } catch (_) {
      return null;
    }
  }
}
