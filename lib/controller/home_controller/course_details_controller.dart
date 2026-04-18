import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/debug_print.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/controller/basket_controller.dart';
import 'package:new_graket_acadimy/data/basket_data/basket_data.dart';
import 'package:new_graket_acadimy/data/course_details_data/course_details_data.dart';
import 'package:new_graket_acadimy/model/courses/get_course_by_id_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


abstract class CourseDetailsController extends GetxController {}


class CourseDetailsControllerImp extends CourseDetailsController {
  CourseDetailsData courseDetailsData = CourseDetailsData(Get.find());
  BasketData basketData = BasketData(Get.find());
  late YoutubePlayerController _playerController;
  MyServices myServices = Get.find();
  String userToken = "";
  String courseId = "";
  DataData? courseDetails;
  RequestStatus requestStatus = RequestStatus.loading;
  bool isSubscriber = false;
  String previewVideoUrl = "";

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
