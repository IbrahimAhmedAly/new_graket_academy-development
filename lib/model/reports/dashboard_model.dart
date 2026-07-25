/// Models for the student progress dashboard.
///
/// Numeric fields are deliberately nullable where the API may legitimately
/// return null — an average with no quiz attempts behind it, or a Success Index
/// for a student with too little activity. Defaulting those to 0 would turn
/// "we don't know yet" into a claim about the student, which is exactly what
/// the reporting layer avoids.
class DashboardData {
  final StudentSummary student;
  final ProgressOverview overview;
  final int circularPercent;
  final List<SubjectProgress> subjects;
  final List<DayActivity> weeklyActivity;
  final List<HeatmapCell> heatmap;
  final SuccessIndex successIndex;
  final RankingInfo ranking;

  DashboardData({
    required this.student,
    required this.overview,
    required this.circularPercent,
    required this.subjects,
    required this.weeklyActivity,
    required this.heatmap,
    required this.successIndex,
    required this.ranking,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      student: StudentSummary.fromJson(_map(json['student'])),
      overview: ProgressOverview.fromJson(_map(json['overview'])),
      circularPercent: _int(_map(json['circularProgress'])['percent']),
      subjects: _list(json['subjects'])
          .map((e) => SubjectProgress.fromJson(_map(e)))
          .toList(),
      weeklyActivity: _list(json['weeklyActivity'])
          .map((e) => DayActivity.fromJson(_map(e)))
          .toList(),
      heatmap: _list(json['heatmap'])
          .map((e) => HeatmapCell.fromJson(_map(e)))
          .toList(),
      successIndex: SuccessIndex.fromJson(_map(json['successIndex'])),
      ranking: RankingInfo.fromJson(_map(json['ranking'])),
    );
  }
}

class StudentSummary {
  final String? name;
  final String? educationLevel;
  final String? grade;
  final String? today;

  StudentSummary({this.name, this.educationLevel, this.grade, this.today});

  factory StudentSummary.fromJson(Map<String, dynamic> json) => StudentSummary(
    name: json['name']?.toString(),
    educationLevel: json['educationLevel']?.toString(),
    grade: json['grade']?.toString(),
    today: json['today']?.toString(),
  );
}

class ProgressOverview {
  final int overallProgressPercent;
  final int videosWatched;
  final int videosRemaining;
  final int totalVideos;
  final int pdfsOpened;
  final int totalPdfs;
  final int quizzesTaken;

  /// Null when no quiz has been attempted — distinct from an average of zero.
  final int? averageQuizScore;

  final double studyHours;
  final int currentStreak;
  final int longestStreak;
  final int totalPoints;

  ProgressOverview({
    required this.overallProgressPercent,
    required this.videosWatched,
    required this.videosRemaining,
    required this.totalVideos,
    required this.pdfsOpened,
    required this.totalPdfs,
    required this.quizzesTaken,
    required this.averageQuizScore,
    required this.studyHours,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPoints,
  });

  factory ProgressOverview.fromJson(Map<String, dynamic> json) =>
      ProgressOverview(
        overallProgressPercent: _int(json['overallProgressPercent']),
        videosWatched: _int(json['videosWatched']),
        videosRemaining: _int(json['videosRemaining']),
        totalVideos: _int(json['totalVideos']),
        pdfsOpened: _int(json['pdfsOpened']),
        totalPdfs: _int(json['totalPdfs']),
        quizzesTaken: _int(json['quizzesTaken']),
        averageQuizScore: _intOrNull(json['averageQuizScore']),
        studyHours: _double(json['studyHours']),
        currentStreak: _int(json['currentStreak']),
        longestStreak: _int(json['longestStreak']),
        totalPoints: _int(json['totalPoints']),
      );
}

class SubjectProgress {
  final String courseId;
  final String title;
  final String? thumbnail;
  final String? category;
  final int totalContents;
  final int completedContents;
  final int progressPercent;

  SubjectProgress({
    required this.courseId,
    required this.title,
    this.thumbnail,
    this.category,
    required this.totalContents,
    required this.completedContents,
    required this.progressPercent,
  });

  factory SubjectProgress.fromJson(Map<String, dynamic> json) =>
      SubjectProgress(
        courseId: json['courseId']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        thumbnail: json['thumbnail']?.toString(),
        category: json['category']?.toString(),
        totalContents: _int(json['totalContents']),
        completedContents: _int(json['completedContents']),
        progressPercent: _int(json['progressPercent']),
      );
}

class DayActivity {
  final String date;
  final int studyMinutes;
  final int videos;
  final int quizzes;

  DayActivity({
    required this.date,
    required this.studyMinutes,
    required this.videos,
    required this.quizzes,
  });

  factory DayActivity.fromJson(Map<String, dynamic> json) => DayActivity(
    date: json['date']?.toString() ?? '',
    studyMinutes: _int(json['studyMinutes']),
    videos: _int(json['videos']),
    quizzes: _int(json['quizzes']),
  );

  /// Single-letter weekday label for the chart axis.
  String get weekdayLabel {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return '';
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[parsed.weekday - 1];
  }
}

class HeatmapCell {
  final String date;
  final int studyMinutes;

  /// 0 (no activity) through 4 (heaviest), assigned server-side against fixed
  /// thresholds so a quiet week is not rescaled to look busy.
  final int level;

  HeatmapCell({
    required this.date,
    required this.studyMinutes,
    required this.level,
  });

  factory HeatmapCell.fromJson(Map<String, dynamic> json) => HeatmapCell(
    date: json['date']?.toString() ?? '',
    studyMinutes: _int(json['studyMinutes']),
    level: _int(json['level']),
  );
}

class SuccessIndex {
  /// Null when there is too little activity to judge. The UI must show the
  /// [reason] instead of rendering a zero.
  final int? score;
  final String? band;
  final String? reason;
  final List<IndexComponent> components;

  SuccessIndex({
    this.score,
    this.band,
    this.reason,
    this.components = const [],
  });

  bool get hasScore => score != null;

  factory SuccessIndex.fromJson(Map<String, dynamic> json) => SuccessIndex(
    score: _intOrNull(json['score']),
    band: json['band']?.toString(),
    reason: json['reason']?.toString(),
    components: _list(json['components'])
        .map((e) => IndexComponent.fromJson(_map(e)))
        .toList(),
  );
}

class IndexComponent {
  final String key;
  final String label;
  final int weight;
  final int raw;
  final int contribution;
  final bool hasData;

  IndexComponent({
    required this.key,
    required this.label,
    required this.weight,
    required this.raw,
    required this.contribution,
    required this.hasData,
  });

  factory IndexComponent.fromJson(Map<String, dynamic> json) => IndexComponent(
    key: json['key']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
    weight: _int(json['weight']),
    raw: _int(json['raw']),
    contribution: _int(json['contribution']),
    hasData: json['hasData'] == true,
  );
}

class RankingInfo {
  final bool available;
  final String? band;
  final int? percentile;
  final int cohortSize;
  final String? reason;
  final String? scope;

  RankingInfo({
    required this.available,
    this.band,
    this.percentile,
    this.cohortSize = 0,
    this.reason,
    this.scope,
  });

  factory RankingInfo.fromJson(Map<String, dynamic> json) => RankingInfo(
    available: json['available'] == true,
    band: json['band']?.toString(),
    percentile: _intOrNull(json['percentile']),
    cohortSize: _int(json['cohortSize']),
    reason: json['reason']?.toString(),
    scope: json['scope']?.toString(),
  );
}

// ── shared parsing helpers ──────────────────────────────────────────────
// The API envelope nests payloads inconsistently across endpoints, and a
// tracking screen must never crash a student's app over a shape mismatch.

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};

List<dynamic> _list(dynamic value) => value is List ? value : const [];

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _intOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString());
}

double _double(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
