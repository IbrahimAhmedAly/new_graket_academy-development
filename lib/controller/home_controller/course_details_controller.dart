import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/debug_print.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/controller/basket_controller.dart';
import 'package:new_graket_acadimy/data/basket_data/basket_data.dart';
import 'package:new_graket_acadimy/data/course_details_data/course_details_data.dart';
import 'package:new_graket_acadimy/data/progress_data/progress_data.dart';
import 'package:new_graket_acadimy/model/courses/get_course_by_id_model.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


abstract class CourseDetailsController extends GetxController {}


class CourseDetailsControllerImp extends CourseDetailsController {
  CourseDetailsData courseDetailsData = CourseDetailsData(Get.find());
  BasketData basketData = BasketData(Get.find());
  ProgressData progressData = ProgressData(Get.find());
  late YoutubePlayerController _playerController;
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

  initYoutubePlayer(String videoUrl) {
    String videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? "";
    _playerController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
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
        update();
      }
    } catch (e) {
      appPrint('Details-progress load error: $e');
    }
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
