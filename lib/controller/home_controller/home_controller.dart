import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/data/courses_data/courses_data.dart';
import 'package:new_graket_acadimy/model/courses/get_all_courses_model.dart' as all_courses;
import '../../core/class/request_status.dart';
import '../../core/debug_print.dart';
import '../../routing/app_routes.dart';

class HomeController extends GetxController {
  MyServices myServices = Get.find();
  List<all_courses.Datum> recommendedCourses = [];
  List<all_courses.Datum> popularCourses = [];
  List<all_courses.Datum> allCourses = [];
  final CoursesData coursesData = CoursesData(Get.find());
  RequestStatus requestStatus = RequestStatus.loading;
  String userName = "";
  @override
  void onInit() {
    super.onInit();
    getUserData();
    getHomeData();
  }

  getUserData() {
    userName = myServices.sharedPreferences.getString(AppSharedPrefKeys.userNameKey) ?? "User";
    update();
  }

  List<Map<String, dynamic>> _normalizeList(dynamic rawList) {
    if (rawList is List) {
      return rawList
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }

  String? _toStringValue(dynamic value) {
    if (value == null) return null;
    final result = value.toString();
    return result.isEmpty ? null : result;
  }

  double? _toDoubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? _toIntValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool? _toBoolValue(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  String? _toDateString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is DateTime) return value.toIso8601String();
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt())
          .toIso8601String();
    }
    return value.toString();
  }

  Map<String, dynamic> _normalizeCourseJson(Map<String, dynamic> raw) {
    final json = Map<String, dynamic>.from(raw);
    json['id'] = _toStringValue(json['id'] ?? json['_id']);
    json['title'] = _toStringValue(json['title'] ?? json['name']);
    json['slug'] = _toStringValue(json['slug']);
    json['description'] = _toStringValue(json['description']);
    json['thumbnail'] =
        _toStringValue(json['thumbnail'] ?? json['cover'] ?? json['image']);
    json['instructorId'] = _toStringValue(json['instructorId']);
    json['categoryId'] = _toStringValue(json['categoryId']);
    json['price'] = _toDoubleValue(json['price']);
    json['discountPrice'] = _toDoubleValue(json['discountPrice']);
    json['totalDuration'] = _toIntValue(json['totalDuration'] ?? json['hours']);
    json['totalVideos'] = _toIntValue(json['totalVideos']);
    json['totalQuizzes'] = _toIntValue(json['totalQuizzes']);
    json['isPublished'] = _toBoolValue(json['isPublished']);
    json['createdAt'] = _toDateString(json['createdAt']);
    json['updatedAt'] = _toDateString(json['updatedAt']);
    json['averageRating'] =
        _toDoubleValue(json['averageRating'] ?? json['rating']);
    json['totalReviews'] = _toIntValue(json['totalReviews']);
    return json;
  }

  List<Map<String, dynamic>> _extractRawCourseList(Map<String, dynamic> raw) {
    final data = raw['data'];
    if (data is List) {
      return _normalizeList(data);
    }
    if (data is Map) {
      final inner = data['data'];
      if (inner is List) {
        return _normalizeList(inner);
      }
      if (inner is Map) {
        final nested = inner['data'];
        if (nested is List) {
          return _normalizeList(nested);
        }
        if (inner['courses'] is List) {
          return _normalizeList(inner['courses']);
        }
        if (nested is Map && nested['data'] is List) {
          return _normalizeList(nested['data']);
        }
      }
      if (data['courses'] is List) {
        return _normalizeList(data['courses']);
      }
    }
    final courses = raw['courses'];
    if (courses is List) {
      return _normalizeList(courses);
    }
    return [];
  }

  List<all_courses.Datum> _extractCoursesFromResponse(
      Map<String, dynamic> raw) {
    final rawList = _extractRawCourseList(raw);
    if (rawList.isEmpty) return [];
    return rawList
        .map((item) =>
            all_courses.Datum.fromJson(_normalizeCourseJson(item)))
        .toList();
  }

  getHomeData() async {
    appPrint("start get home");
    if (recommendedCourses.isNotEmpty ||
        popularCourses.isNotEmpty ||
        allCourses.isNotEmpty) {
      requestStatus = RequestStatus.success;
      update();
      return;
    }

    final userToken =
        myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
            "";

    requestStatus = RequestStatus.loading;
    update();

    final allResponse =
        await coursesData.getAllCourses(token: userToken, page: 1, limit: 10);
    final recResponse = await coursesData.getRecommendedCourses(
        token: userToken, page: 1, limit: 10);
    final popResponse = await coursesData.getPopularCourses(
        token: userToken, page: 1, limit: 10);

    bool anySuccess = false;
    if (allResponse.$1 == RequestStatus.success &&
        allResponse.$2 is Map<String, dynamic>) {
      allCourses =
          _extractCoursesFromResponse(allResponse.$2 as Map<String, dynamic>);
      anySuccess = anySuccess || allCourses.isNotEmpty;
    }
    if (recResponse.$1 == RequestStatus.success &&
        recResponse.$2 is Map<String, dynamic>) {
      recommendedCourses =
          _extractCoursesFromResponse(recResponse.$2 as Map<String, dynamic>);
      anySuccess = anySuccess || recommendedCourses.isNotEmpty;
    }
    if (popResponse.$1 == RequestStatus.success &&
        popResponse.$2 is Map<String, dynamic>) {
      popularCourses =
          _extractCoursesFromResponse(popResponse.$2 as Map<String, dynamic>);
      anySuccess = anySuccess || popularCourses.isNotEmpty;
    }

    requestStatus = anySuccess ? RequestStatus.success : RequestStatus.failed;
    update();
  }

  goToCoursesScreen() {
    Get.toNamed(AppRoutesNames.coursesScreen,
        arguments: {'type': 'all'});
  }

  goToRecommendedScreen() {
    Get.toNamed(AppRoutesNames.coursesScreen, arguments: {'type': 'recommended'});
  }

  goToPopularScreen() {
    Get.toNamed(AppRoutesNames.coursesScreen, arguments: {'type': 'popular'});
  }


}
