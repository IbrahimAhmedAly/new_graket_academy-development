

import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/data/courses_data/courses_data.dart';
import 'package:new_graket_acadimy/model/courses/get_all_courses_model.dart'
    as all_courses;

import '../../routing/app_routes.dart';

class CoursesController extends GetxController {}

class CoursesControllerImp extends CoursesController {
  List<all_courses.Datum> courses = [];
  RequestStatus requestStatus = RequestStatus.loading;
  final CoursesData coursesData = CoursesData(Get.find());
  final MyServices myServices = Get.find();
  int currentPage = 1;
  final int limit = 10;
  bool hasNextPage = true;
  bool isLoadingMore = false;
  String type = 'all';
  String searchQuery = '';

  @override
  void onInit() {
    final args = Get.arguments;
    if (args is Map) {
      type = (args['type'] ?? 'all').toString();
      searchQuery = (args['search'] ?? '').toString();
    }
    fetchFirstPage();
    super.onInit();
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
    final directCourses = raw['courses'];
    if (directCourses is List) {
      return _normalizeList(directCourses);
    }

    final data = raw['data'];
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

    if (data is List) {
      return _normalizeList(data);
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

  bool _extractHasNext(Map<String, dynamic> raw, int fetchedCount) {
    final data = raw['data'];
    if (data is Map) {
      final meta = data['metadata'] ?? (data['data'] is Map ? data['data']['metadata'] : null);
      if (meta is Map) {
        final hasNext = meta['hasNextPage'];
        if (hasNext is bool) return hasNext;
        final current = meta['currentPage'];
        final total = meta['totalPages'];
        if (current is num && total is num) {
          return current.toInt() < total.toInt();
        }
      }
    }
    return fetchedCount >= limit;
  }

  Future<void> fetchFirstPage() async {
    currentPage = 1;
    hasNextPage = true;
    courses = [];
    requestStatus = RequestStatus.loading;
    update();
    await _fetchPage();
  }

  Future<void> loadMore() async {
    if (!hasNextPage || isLoadingMore || requestStatus == RequestStatus.loading) return;
    isLoadingMore = true;
    currentPage += 1;
    await _fetchPage(isLoadMore: true);
    isLoadingMore = false;
    update();
  }

  Future<void> applySearch(String query) async {
    searchQuery = query;
    await fetchFirstPage();
  }

  Future<void> _fetchPage({bool isLoadMore = false}) async {
    final token = myServices.sharedPreferences
            .getString(AppSharedPrefKeys.userTokenKey) ??
        "";
    if (!isLoadMore) {
      requestStatus = RequestStatus.loading;
      update();
    }

    late final response;
    if (type == 'popular') {
      response = await coursesData.getPopularCourses(
          token: token,
          page: currentPage,
          limit: limit,
          search: searchQuery.isNotEmpty ? searchQuery : null);
    } else if (type == 'recommended') {
      response = await coursesData.getRecommendedCourses(
          token: token,
          page: currentPage,
          limit: limit,
          search: searchQuery.isNotEmpty ? searchQuery : null);
    } else {
      response = await coursesData.getAllCourses(
          token: token,
          page: currentPage,
          limit: limit,
          search: searchQuery.isNotEmpty ? searchQuery : null);
    }

    requestStatus = response.$1;
    if (requestStatus == RequestStatus.success) {
      final raw = response.$2;
      if (raw is Map<String, dynamic>) {
        final pageCourses = _extractCoursesFromResponse(raw);
        if (isLoadMore) {
          courses.addAll(pageCourses);
        } else {
          courses = pageCourses;
        }
        hasNextPage = _extractHasNext(raw, pageCourses.length);
      } else {
        courses = [];
      }
      if (courses.isEmpty) {
        requestStatus = RequestStatus.failed;
      }
    }
    update();
  }

  goToCourseDetailsScreen(String courseId) {
    Get.toNamed(AppRoutesNames.exploreCourseScreen, arguments: {"courseID":courseId });
  }

}
