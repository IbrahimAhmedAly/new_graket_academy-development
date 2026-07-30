import 'package:get/get.dart';

import '../../core/class/request_status.dart';
import '../../core/constants/app_strings.dart';
import '../../core/debug/tracking_logger.dart';
import '../../core/services/services.dart';
import '../../data/reports_data/reports_data.dart';
import '../../model/reports/dashboard_model.dart';

/// Drives the student progress dashboard.
///
/// The dashboard is assembled from several endpoints. They are fetched
/// concurrently and each is allowed to fail on its own: a missing rewards
/// response should blank one card, not replace the whole screen with an error.
class ProgressDashboardController extends GetxController {
  final ReportsData _reportsData = ReportsData(Get.find());
  final MyServices _services = Get.find();

  RequestStatus requestStatus = RequestStatus.loading;

  DashboardData? dashboard;

  /// Today's tasks. Empty until loaded.
  List<MissionTask> missionTasks = [];

  /// Activity-derived nudges.
  List<Insight> insights = [];

  /// Points and badges.
  RewardsInfo? rewards;

  /// Areas the student may want to revisit.
  List<Suggestion> suggestions = [];

  /// Quiz performance.
  QuizAnalytics? quizAnalytics;

  String get userToken =>
      _services.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
      '';

  String get userName =>
      dashboard?.student.name ??
      _services.sharedPreferences.getString(AppSharedPrefKeys.userNameKey) ??
      'there';

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    requestStatus = RequestStatus.loading;
    update();

    final token = userToken;
    if (token.isEmpty) {
      TrackLog.reportFailure('dashboard', 'no auth token');
      requestStatus = RequestStatus.failed;
      update();
      return;
    }

    TrackLog.reportRequest(
      'dashboard, mission, insights, rewards, suggestions, quiz-analytics',
    );

    // Concurrent so the screen appears in one round trip rather than six.
    final results = await Future.wait([
      _reportsData.getDashboard(token: token),
      _reportsData.getMission(token: token),
      _reportsData.getInsights(token: token),
      _reportsData.getRewards(token: token),
      _reportsData.getSuggestions(token: token),
      _reportsData.getQuizAnalytics(token: token),
    ]);

    _parseDashboard(results[0]);
    _parseMission(results[1]);
    _parseInsights(results[2]);
    _parseRewards(results[3]);
    _parseSuggestions(results[4]);
    _parseQuizAnalytics(results[5]);

    _logLoaded();

    // The dashboard payload is the only one the screen cannot render without.
    requestStatus = dashboard != null
        ? RequestStatus.success
        : RequestStatus.failed;
    update();
  }

  /// Pull-to-refresh entry point.
  ///
  /// Named distinctly from GetxController's own `refresh()`, which forces a
  /// rebuild — this refetches, which is a different thing.
  Future<void> reload() => loadAll();

  /// Prints what actually arrived, so a wrong figure on screen can be traced
  /// to either the API or the widget without guessing.
  void _logLoaded() {
    final d = dashboard;
    if (d == null) {
      TrackLog.reportFailure('dashboard', 'payload missing or unparseable');
      return;
    }

    TrackLog.dashboardSummary(
      progressPercent: d.overview.overallProgressPercent,
      videosWatched: d.overview.videosWatched,
      totalVideos: d.overview.totalVideos,
      quizzesTaken: d.overview.quizzesTaken,
      averageQuizScore: d.overview.averageQuizScore,
      studyHours: d.overview.studyHours,
      streak: d.overview.currentStreak,
      points: d.overview.totalPoints,
      successIndex: d.successIndex.score,
      successBand: d.successIndex.band,
      subjects: d.subjects.length,
      weeklyDays: d.weeklyActivity.length,
      heatmapCells: d.heatmap.length,
    );

    TrackLog.reportSuccess(
      'mission',
      summary: '${missionTasks.where((t) => t.done).length}'
          '/${missionTasks.length} tasks done',
    );
    TrackLog.reportSuccess('insights', summary: '${insights.length} items');
    TrackLog.reportSuccess(
      'rewards',
      summary: rewards != null
          ? '${rewards!.totalPoints} pts, '
              '${rewards!.badgesEarned}/${rewards!.badgesAvailable} badges'
          : 'not loaded',
    );
    TrackLog.reportSuccess(
      'suggestions',
      summary: '${suggestions.length} areas to review',
    );
    TrackLog.reportSuccess(
      'quiz-analytics',
      summary: quizAnalytics != null
          ? '${quizAnalytics!.totalAttempts} attempts'
          : 'not loaded',
    );

    if (d.ranking.available) {
      TrackLog.reportSuccess(
        'ranking',
        summary: '${d.ranking.band} of ${d.ranking.cohortSize} students',
      );
    } else {
      TrackLog.reportSuccess(
        'ranking',
        summary: 'unavailable — ${d.ranking.reason ?? "not enough data"}',
      );
    }
  }

  // ── parsing ───────────────────────────────────────────────────────────

  /// Unwraps `{ data: { data: <payload> } }`, tolerating flatter shapes.
  Map<String, dynamic>? _payload(dynamic response) {
    if (response == null) return null;
    try {
      if (response.$1 != RequestStatus.success) return null;
      final body = response.$2;
      if (body is! Map) return null;

      final data = body['data'];
      if (data is Map) {
        final inner = data['data'];
        if (inner is Map) return Map<String, dynamic>.from(inner);
        return Map<String, dynamic>.from(data);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  void _parseDashboard(dynamic response) {
    final payload = _payload(response);
    if (payload == null) return;
    try {
      dashboard = DashboardData.fromJson(payload);
    } catch (_) {
      dashboard = null;
    }
  }

  void _parseMission(dynamic response) {
    final payload = _payload(response);
    if (payload == null) return;

    final tasks = payload['tasks'];
    if (tasks is! List) return;

    missionTasks = tasks
        .whereType<Map>()
        .map(
          (t) => MissionTask(
            key: t['key']?.toString() ?? '',
            label: t['label']?.toString() ?? '',
            done: t['done'] == true,
          ),
        )
        .toList();
  }

  void _parseInsights(dynamic response) {
    final payload = _payload(response);
    if (payload == null) return;

    final items = payload['insights'];
    if (items is! List) return;

    insights = items
        .whereType<Map>()
        .map(
          (i) => Insight(
            type: i['type']?.toString() ?? '',
            message: i['message']?.toString() ?? '',
            severity: i['severity']?.toString() ?? 'info',
          ),
        )
        .toList();
  }

  void _parseRewards(dynamic response) {
    final payload = _payload(response);
    if (payload == null) return;

    final next = payload['nextBadge'];
    final latest = payload['latestBadge'];

    rewards = RewardsInfo(
      totalPoints: _asInt(payload['totalPoints']),
      badgesEarned: _asInt(payload['badgesEarned']),
      badgesAvailable: _asInt(payload['badgesAvailable']),
      latestBadgeName: latest is Map ? latest['name']?.toString() : null,
      latestBadgeIcon: latest is Map ? latest['icon']?.toString() : null,
      nextBadgeName: next is Map ? next['name']?.toString() : null,
      nextBadgeIcon: next is Map ? next['icon']?.toString() : null,
      pointsToNextBadge: next is Map ? _asInt(next['pointsRemaining']) : null,
    );
  }

  void _parseSuggestions(dynamic response) {
    final payload = _payload(response);
    if (payload == null) return;

    final items = payload['suggestions'];
    if (items is! List) return;

    suggestions = items
        .whereType<Map>()
        .map(
          (s) => Suggestion(
            label: s['label']?.toString() ?? '',
            course: s['course']?.toString(),
            accuracy: _asInt(s['accuracy']),
            questionsAnswered: _asInt(s['questionsAnswered']),
          ),
        )
        .toList();
  }

  void _parseQuizAnalytics(dynamic response) {
    final payload = _payload(response);
    if (payload == null) return;

    final weakSubject = payload['weakestSubject'];
    final weakLesson = payload['weakestLesson'];

    quizAnalytics = QuizAnalytics(
      totalAttempts: _asInt(payload['totalAttempts']),
      averageScore: _asIntOrNull(payload['averageScore']),
      highestScore: _asIntOrNull(payload['highestScore']),
      lowestScore: _asIntOrNull(payload['lowestScore']),
      passRate: _asIntOrNull(payload['passRate']),
      weakestSubject: weakSubject is Map
          ? weakSubject['title']?.toString()
          : null,
      weakestLesson: weakLesson is Map ? weakLesson['title']?.toString() : null,
    );
  }

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  int? _asIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse(v.toString());
  }
}

// ── view models ─────────────────────────────────────────────────────────

class MissionTask {
  final String key;
  final String label;
  final bool done;

  MissionTask({required this.key, required this.label, required this.done});
}

class Insight {
  final String type;
  final String message;
  final String severity;

  Insight({required this.type, required this.message, required this.severity});
}

class RewardsInfo {
  final int totalPoints;
  final int badgesEarned;
  final int badgesAvailable;
  final String? latestBadgeName;
  final String? latestBadgeIcon;
  final String? nextBadgeName;
  final String? nextBadgeIcon;
  final int? pointsToNextBadge;

  RewardsInfo({
    required this.totalPoints,
    required this.badgesEarned,
    required this.badgesAvailable,
    this.latestBadgeName,
    this.latestBadgeIcon,
    this.nextBadgeName,
    this.nextBadgeIcon,
    this.pointsToNextBadge,
  });
}

class Suggestion {
  final String label;
  final String? course;
  final int accuracy;
  final int questionsAnswered;

  Suggestion({
    required this.label,
    this.course,
    required this.accuracy,
    required this.questionsAnswered,
  });
}

class QuizAnalytics {
  final int totalAttempts;
  final int? averageScore;
  final int? highestScore;
  final int? lowestScore;
  final int? passRate;
  final String? weakestSubject;
  final String? weakestLesson;

  QuizAnalytics({
    required this.totalAttempts,
    this.averageScore,
    this.highestScore,
    this.lowestScore,
    this.passRate,
    this.weakestSubject,
    this.weakestLesson,
  });
}
