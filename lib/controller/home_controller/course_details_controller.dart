import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/debug_print.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/controller/basket_controller.dart';
import 'package:new_graket_acadimy/data/basket_data/basket_data.dart';
import 'package:new_graket_acadimy/data/course_details_data/course_details_data.dart';
import 'package:new_graket_acadimy/controller/wishlist_controller.dart';
import 'package:new_graket_acadimy/data/progress_data/progress_data.dart';
import 'package:new_graket_acadimy/data/related_courses_data/related_courses_data.dart';
import 'package:new_graket_acadimy/data/wishlist_data/wishlist_data.dart';
import 'package:new_graket_acadimy/model/courses/get_course_by_id_model.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:share_plus/share_plus.dart';


abstract class CourseDetailsController extends GetxController {}


class CourseDetailsControllerImp extends CourseDetailsController {
  CourseDetailsData courseDetailsData = CourseDetailsData(Get.find());
  BasketData basketData = BasketData(Get.find());
  ProgressData progressData = ProgressData(Get.find());
  WishlistData wishlistData = WishlistData(Get.find());
  RelatedCoursesData relatedData = RelatedCoursesData(Get.find());
  MyServices myServices = Get.find();
  String userToken = "";
  String courseId = "";
  DataData? courseDetails;
  RequestStatus requestStatus = RequestStatus.loading;
  bool isSubscriber = false;
  String previewVideoUrl = "";

  // Progress state for purchased courses
  int progressPercentage = 0;
  int completedContents = 0;
  int totalContents = 0;
  bool get hasStartedCourse => completedContents > 0;

  // Wishlist state
  bool isSaved = false;
  bool isWishlistBusy = false;

  // Related courses state (independent request, non-blocking)
  List<DataData> relatedCourses = [];
  RequestStatus relatedStatus = RequestStatus.none;

  // Completed content IDs — used to derive "continue watching" next item.
  Set<String> completedContentIds = {};

  /// First accessible, not-yet-completed content across all sections.
  /// Used to render the "Continue: Lesson X" banner + one-tap resume.
  ({Content content, Section section})? get nextLesson {
    final sections = courseDetails?.sections;
    if (sections == null) return null;
    for (final s in sections) {
      for (final c in s.contents ?? const <Content>[]) {
        if (contentHasAccess(c) &&
            c.id != null &&
            !completedContentIds.contains(c.id)) {
          return (content: c, section: s);
        }
      }
    }
    return null;
  }

  // Purchase state derived from purchaseInfo
  bool get isPurchased => courseDetails?.purchaseInfo?.isPurchased == true;
  bool get hasFullAccess =>
      courseDetails?.purchaseInfo?.hasFullAccess == true;
  PurchaseType get purchaseType =>
      courseDetails?.purchaseInfo?.purchaseType ?? PurchaseType.none;

  bool contentHasAccess(Content content) {
    final info = courseDetails?.purchaseInfo;
    if (info == null) return false;
    if (info.hasFullAccess) return true;
    if (content.hasAccess == true) return true;
    if (info.purchaseType == PurchaseType.video &&
        content.id != null &&
        info.purchasedVideoIds.contains(content.id)) {
      return true;
    }
    return false;
  }
  @override
  void onInit() {
    final args = Get.arguments;
    courseId = args is Map
        ? (args['courseId'] ?? args['courseID'] ?? "").toString()
        : "";
     userToken = myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ?? "";
    getCourseDetails();
    super.onInit();
  }

  bool _boolValue(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == "true" || normalized == "1" || normalized == "yes";
    }
    return false;
  }

  String _stringValue(dynamic value) {
    if (value == null) return "";
    return value is String ? value : value.toString();
  }

  Map<String, dynamic> _extractDataMap(Map raw) {
    final data = raw['data'];
    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data']);
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return Map<String, dynamic>.from(raw);
  }

  Future<void> getCourseDetails() async {
    appPrint(userToken);
    appPrint(courseId);
    if (courseId.isEmpty) {
      requestStatus = RequestStatus.failed;
      update();
      return;
    }
    requestStatus = RequestStatus.loading;
    update();

    final response = await courseDetailsData.getCourseDetailsData(
        userToken: userToken, courseId: courseId);
    requestStatus = response.$1;

    if (requestStatus == RequestStatus.success &&
        response.$2 is Map<String, dynamic>) {
      final raw = response.$2 as Map<String, dynamic>;
      final dataMap = _extractDataMap(raw);
      try {
        final model = GetCourseByIdModel.fromJson(raw);
        courseDetails = model.data?.data;
      } catch (_) {
        courseDetails = null;
      }

      if (courseDetails == null && dataMap.isNotEmpty) {
        try {
          courseDetails = DataData.fromJson(dataMap);
        } catch (_) {}
      }

      isSubscriber = _boolValue(
        dataMap['isSubscriber'] ?? dataMap['isSubscribed'] ?? dataMap['subscribed'],
      );
      previewVideoUrl = _stringValue(
        dataMap['previewVideoUrl'] ??
            dataMap['previewVideo'] ??
            dataMap['promoVideo'] ??
            dataMap['introVideoUrl'],
      );

      // If purchaseInfo wasn't parsed by the model (e.g. fallback parse path),
      // try to hydrate it from the raw map.
      if (courseDetails != null && courseDetails!.purchaseInfo == null) {
        final piRaw = dataMap['purchaseInfo'];
        if (piRaw is Map<String, dynamic>) {
          try {
            courseDetails!.purchaseInfo = PurchaseInfo.fromJson(piRaw);
          } catch (_) {}
        }
      }
    } else {
      courseDetails = null;
    }

    if (courseDetails == null && requestStatus == RequestStatus.success) {
      requestStatus = RequestStatus.failed;
    }

    appPrint(courseDetails?.title ?? "no name");
    update();

    // Fetch progress asynchronously for purchased courses
    if (isPurchased) {
      _loadProgress();
    }
    // Fetch wishlist status independently — a non-purchased course can still be saved
    _loadSavedStatus();
    // Related courses carousel (non-blocking)
    loadRelatedCourses();
  }

  Future<void> _loadSavedStatus() async {
    if (courseId.isEmpty || userToken.isEmpty) return;
    try {
      final response = await wishlistData.getSavedStatus(
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
        isSaved = dataMap['isSaved'] == true;
        update();
      }
    } catch (e) {
      appPrint('Wishlist fetch error: $e');
    }
  }

  /// Optimistic toggle — flips the heart immediately, rolls back if the API fails.
  Future<void> toggleSaved() async {
    if (courseId.isEmpty) return;
    if (userToken.isEmpty) {
      Get.snackbar(
        "Login",
        "Please login to save courses",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (isWishlistBusy) return;

    final previous = isSaved;
    isSaved = !previous;
    isWishlistBusy = true;
    update();

    try {
      final response = previous
          ? await wishlistData.unsaveCourse(
              courseId: courseId, userToken: userToken)
          : await wishlistData.saveCourse(
              courseId: courseId, userToken: userToken);
      final status = response.$1;
      if (status != RequestStatus.success) {
        // Rollback on failure and show reason
        isSaved = previous;
        final msg = response.$2 is Map
            ? (response.$2 as Map)['message']?.toString()
            : null;
        Get.snackbar(
          "Wishlist",
          msg?.isNotEmpty == true ? msg! : "Could not update saved courses",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "Wishlist",
          isSaved ? "Course saved" : "Removed from saved",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        // Keep the wishlist tab in sync if the user already opened it.
        if (Get.isRegistered<WishlistController>()) {
          // Fire-and-forget — no need to await from this flow.
          Get.find<WishlistController>().loadInitial();
        }
      }
    } catch (e) {
      isSaved = previous;
      appPrint('toggleSaved error: $e');
    } finally {
      isWishlistBusy = false;
      update();
    }
  }

  /// Build a shareable message + URL for this course and open the system
  /// share sheet. Uses the course slug where available, otherwise the id.
  Future<void> shareCourse() async {
    final course = courseDetails;
    if (course == null) return;
    final title = course.title ?? 'this course';
    final slugOrId = (course.slug != null && course.slug!.isNotEmpty)
        ? course.slug!
        : (course.id ?? '');
    // Public-facing web link; the app can handle deep links to /course/:slug later.
    final url = 'https://graketacademy.com/course/$slugOrId';
    final text = 'Check out "$title" on Graket Academy\n$url';
    try {
      await Share.share(text, subject: title);
    } catch (e) {
      appPrint('Share error: $e');
      Get.snackbar(
        "Share",
        "Could not open share sheet",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _loadProgress() async {
    if (courseId.isEmpty || userToken.isEmpty) return;
    try {
      final response = await progressData.getCourseProgress(
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
        final progress = dataMap['progress'];
        if (progress is Map) {
          progressPercentage =
              (progress['percentage'] as num?)?.toInt() ?? 0;
          completedContents = (progress['completed'] as num?)?.toInt() ?? 0;
          totalContents = (progress['total'] as num?)?.toInt() ?? 0;
        }
        final ids = dataMap['completedContentIds'];
        if (ids is List) {
          completedContentIds =
              ids.map((e) => e.toString()).toSet();
        }
        update();
      }
    } catch (e) {
      appPrint('Details-progress load error: $e');
    }
  }

  /// Loads "students also bought" carousel. Fire-and-forget — failure is
  /// silent; the section simply doesn't render.
  Future<void> loadRelatedCourses() async {
    if (courseId.isEmpty) return;
    relatedStatus = RequestStatus.loading;
    update();
    try {
      final response = await relatedData.getRelated(
        courseId: courseId,
        userToken: userToken,
        limit: 6,
      );
      if (response.$1 == RequestStatus.success && response.$2 is Map) {
        final raw = response.$2 as Map<String, dynamic>;
        final inner = raw['data'];
        List<dynamic> list = [];
        if (inner is Map && inner['data'] is List) {
          list = inner['data'] as List;
        } else if (inner is List) {
          list = inner;
        }
        relatedCourses = list
            .whereType<Map>()
            .map((m) => DataData.fromJson(Map<String, dynamic>.from(m)))
            .toList();
        relatedStatus = RequestStatus.success;
      } else {
        relatedStatus = RequestStatus.failed;
      }
    } catch (_) {
      relatedStatus = RequestStatus.failed;
    }
    update();
  }

  /// Called when returning from the course player — re-pull progress so the
  /// banner on this screen stays fresh.
  Future<void> refreshProgress() => _loadProgress();

  Future<void> continueLearning() async {
    await Get.toNamed(
      AppRoutesNames.coursePlayerScreen,
      arguments: {
        'courseId': courseId,
        'courseTitle': courseDetails?.title ?? '',
        'purchaseType': purchaseType,
      },
    );
    // Refresh progress on return so the banner reflects latest state.
    await refreshProgress();
  }

  Future<void> addToBasket() async {
    if (courseId.isEmpty) return;
    final token =
        myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
            "";
    if (token.isEmpty) {
      Get.snackbar("Login", "Please login to add courses",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final response = await basketData.addToBasket(
      token: token,
      courseId: courseId,
    );
    final status = response.$1;
    if (status == RequestStatus.success) {
      if (Get.isRegistered<BasketController>()) {
        Get.find<BasketController>().refreshBasket();
      }
      Get.snackbar("Basket", "Added to basket",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("Basket", "Failed to add",
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
