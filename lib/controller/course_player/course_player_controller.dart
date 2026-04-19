import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/debug_print.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/data/course_details_data/course_details_data.dart';
import 'package:new_graket_acadimy/data/progress_data/progress_data.dart';
import 'package:new_graket_acadimy/model/courses/get_course_by_id_model.dart';

class ContentWithSection {
  final Content content;
  final String sectionTitle;
  final String sectionId;

  ContentWithSection({
    required this.content,
    required this.sectionTitle,
    required this.sectionId,
  });
}

abstract class CoursePlayerController extends GetxController {}

class CoursePlayerControllerImp extends CoursePlayerController {
  final CourseDetailsData _courseDetailsData = CourseDetailsData(Get.find());
  final ProgressData _progressData = ProgressData(Get.find());
  final MyServices _services = Get.find();

  String userToken = '';
  String courseId = '';
  String courseTitle = '';

  DataData? courseData;
  RequestStatus requestStatus = RequestStatus.loading;

  List<ContentWithSection> allContents = [];
  int currentIndex = 0;
  Set<String> completedIds = {};
  int progressPercentage = 0;
  bool isSidebarOpen = false;

  /// Set to true the moment the course crosses into 100% complete. UI reads
  /// this to fire the celebration dialog, then clears it via [acknowledgeCompletion].
  bool courseJustCompleted = false;

  ContentWithSection? get currentContent =>
      allContents.isEmpty ? null : allContents[currentIndex];

  bool get hasPrev => currentIndex > 0;
  bool get hasNext => currentIndex < allContents.length - 1;

  bool isCompleted(String contentId) => completedIds.contains(contentId);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map? ?? {};
    courseId = args['courseId']?.toString() ?? '';
    courseTitle = args['courseTitle']?.toString() ?? 'Course';
    userToken =
        _services.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
            '';
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    if (courseId.isEmpty) {
      requestStatus = RequestStatus.failed;
      update();
      return;
    }
    requestStatus = RequestStatus.loading;
    update();

    final response = await _courseDetailsData.getCourseDetailsData(
      courseId: courseId,
      userToken: userToken,
    );
    final status = response.$1;

    if (status == RequestStatus.success && response.$2 is Map<String, dynamic>) {
      final raw = response.$2 as Map<String, dynamic>;
      try {
        final model = GetCourseByIdModel.fromJson(raw);
        courseData = model.data?.data;
      } catch (_) {
        courseData = null;
      }
      if (courseData == null) {
        try {
          final inner = raw['data'];
          if (inner is Map) {
            final dataMap = inner['data'] ?? inner;
            if (dataMap is Map<String, dynamic>) {
              courseData = DataData.fromJson(dataMap);
            }
          }
        } catch (_) {}
      }

      if (courseData != null) {
        _buildContentList();
        await _loadProgress();
        requestStatus = RequestStatus.success;
      } else {
        requestStatus = RequestStatus.failed;
      }
    } else {
      requestStatus = status;
    }
    update();
  }

  void _buildContentList() {
    allContents = [];
    for (final section in courseData?.sections ?? []) {
      for (final content in section.contents ?? []) {
        if (content.hasAccess == true) {
          allContents.add(ContentWithSection(
            content: content,
            sectionTitle: section.title ?? '',
            sectionId: section.id ?? '',
          ));
        }
      }
    }
    currentIndex = 0;
  }

  Future<void> _loadProgress() async {
    try {
      final response = await _progressData.getCourseProgress(
        courseId: courseId,
        userToken: userToken,
      );
      if (response.$1 == RequestStatus.success && response.$2 is Map) {
        final raw = response.$2 as Map<String, dynamic>;
        final inner = raw['data'];
        final dataMap = inner is Map && inner['data'] is Map
            ? inner['data'] as Map<String, dynamic>
            : inner is Map<String, dynamic>
                ? inner
                : <String, dynamic>{};

        final ids = dataMap['completedContentIds'];
        if (ids is List) {
          completedIds = ids.map((e) => e.toString()).toSet();
        }
        final progress = dataMap['progress'];
        if (progress is Map) {
          progressPercentage = (progress['percentage'] as num?)?.toInt() ?? 0;
        }

        final firstIncomplete = allContents.indexWhere(
          (c) => !completedIds.contains(c.content.id),
        );
        if (firstIncomplete >= 0) currentIndex = firstIncomplete;
      }
    } catch (e) {
      appPrint('Progress load error: $e');
    }
  }

  void goToContent(int index) {
    if (index < 0 || index >= allContents.length) return;
    currentIndex = index;
    isSidebarOpen = false;
    update();
  }

  void goNext() {
    if (hasNext) goToContent(currentIndex + 1);
  }

  void goPrev() {
    if (hasPrev) goToContent(currentIndex - 1);
  }

  void toggleSidebar() {
    isSidebarOpen = !isSidebarOpen;
    update();
  }

  Future<void> markCurrentComplete() async {
    final item = currentContent;
    if (item == null) return;
    final id = item.content.id;
    if (id == null || completedIds.contains(id)) return;

    try {
      final response = await _progressData.markContentComplete(
        contentId: id,
        userToken: userToken,
      );
      if (response.$1 == RequestStatus.success && response.$2 is Map) {
        completedIds.add(id);
        final raw = response.$2 as Map<String, dynamic>;
        final inner = raw['data'];
        final dataMap = inner is Map && inner['data'] is Map
            ? inner['data'] as Map<String, dynamic>
            : inner is Map<String, dynamic>
                ? inner
                : <String, dynamic>{};
        final cp = dataMap['courseProgress'];
        if (cp is Map) {
          final prev = progressPercentage;
          progressPercentage =
              (cp['percentage'] as num?)?.toInt() ?? progressPercentage;
          final isCompletedFlag = cp['isCompleted'] == true;
          if ((isCompletedFlag || progressPercentage >= 100) && prev < 100) {
            courseJustCompleted = true;
          }
        }
        update();
      }
    } catch (e) {
      appPrint('markComplete error: $e');
    }
  }

  Future<void> retry() => _loadCourse();

  /// Clear the celebration flag once the UI has shown the dialog.
  void acknowledgeCompletion() {
    courseJustCompleted = false;
    update();
  }

  /// Called when an external flow (e.g. quiz submission) may have changed
  /// completion state. Re-pulls progress only, preserving the current index.
  Future<void> refreshAfterExternalChange() async {
    final keptIndex = currentIndex;
    final prevPercentage = progressPercentage;
    await _loadProgress();
    if (keptIndex >= 0 && keptIndex < allContents.length) {
      currentIndex = keptIndex;
    }
    if (progressPercentage >= 100 && prevPercentage < 100) {
      courseJustCompleted = true;
    }
    update();
  }
}
