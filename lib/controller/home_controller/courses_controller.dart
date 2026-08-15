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
  CoursesControllerImp({
    String? initialType,
    String? initialSearch,
    CoursesData? coursesData,
    MyServices? myServices,
  }) : _initialType = initialType,
       _initialSearch = initialSearch,
       coursesData = coursesData ?? CoursesData(Get.find()),
       myServices = myServices ?? Get.find();

  final String? _initialType;
  final String? _initialSearch;
  List<all_courses.Datum> courses = [];
  RequestStatus requestStatus = RequestStatus.loading;
  final CoursesData coursesData;
  final MyServices myServices;
  int currentPage = 1;
  final int limit = 10;
  bool hasNextPage = true;
  bool isLoadingMore = false;
  bool hasLoadMoreError = false;
  bool isSearching = false;
  String type = 'all';
  String searchQuery = '';
  int _requestGeneration = 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final routeType = args is Map ? args['type']?.toString() : null;
    final routeSearch = args is Map ? args['search']?.toString() : null;
    type = _normalizedType(_initialType ?? routeType ?? 'all');
    searchQuery = (_initialSearch ?? routeSearch ?? '').trim();
    fetchFirstPage();
  }

  @override
  void onClose() {
    // Any response completing after this controller is disposed is stale.
    _requestGeneration += 1;
    super.onClose();
  }

  String _normalizedType(String value) {
    return switch (value) {
      'popular' => 'popular',
      'recommended' => 'recommended',
      _ => 'all',
    };
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
      return DateTime.fromMillisecondsSinceEpoch(
        value.toInt(),
      ).toIso8601String();
    }
    return value.toString();
  }

  Map<String, dynamic> _normalizeCourseJson(Map<String, dynamic> raw) {
    final json = Map<String, dynamic>.from(raw);
    json['id'] = _toStringValue(json['id'] ?? json['_id']);
    json['title'] = _toStringValue(json['title'] ?? json['name']);
    json['slug'] = _toStringValue(json['slug']);
    json['description'] = _toStringValue(json['description']);
    json['thumbnail'] = _toStringValue(
      json['thumbnail'] ?? json['cover'] ?? json['image'],
    );
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
    json['averageRating'] = _toDoubleValue(
      json['averageRating'] ?? json['rating'],
    );
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
    Map<String, dynamic> raw,
  ) {
    final rawList = _extractRawCourseList(raw);
    if (rawList.isEmpty) return [];
    return rawList
        .map((item) => all_courses.Datum.fromJson(_normalizeCourseJson(item)))
        .toList();
  }

  bool _extractHasNext(Map<String, dynamic> raw, int fetchedCount) {
    final data = raw['data'];
    if (data is Map) {
      final meta =
          data['metadata'] ??
          (data['data'] is Map ? data['data']['metadata'] : null);
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

  Future<void> fetchFirstPage({bool preserveCourses = false}) async {
    final generation = ++_requestGeneration;
    currentPage = 1;
    hasNextPage = true;
    isLoadingMore = false;
    hasLoadMoreError = false;

    if (preserveCourses &&
        courses.isNotEmpty &&
        requestStatus == RequestStatus.success) {
      isSearching = true;
    } else {
      courses = [];
      isSearching = false;
      requestStatus = RequestStatus.loading;
    }
    update();
    await _fetchPage(page: 1, generation: generation);
  }

  Future<void> loadMore() async {
    if (!hasNextPage ||
        isLoadingMore ||
        hasLoadMoreError ||
        isSearching ||
        requestStatus != RequestStatus.success) {
      return;
    }

    await _loadNextPage();
  }

  Future<void> retryLoadMore() async {
    if (!hasLoadMoreError ||
        !hasNextPage ||
        isLoadingMore ||
        isSearching ||
        requestStatus != RequestStatus.success) {
      return;
    }

    hasLoadMoreError = false;
    await _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    final requestedPage = currentPage + 1;
    final generation = _requestGeneration;
    isLoadingMore = true;
    update();
    await _fetchPage(
      page: requestedPage,
      generation: generation,
      isLoadMore: true,
    );
  }

  Future<void> applySearch(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery == searchQuery) return;

    searchQuery = normalizedQuery;
    await fetchFirstPage(preserveCourses: true);
  }

  Future<void> _fetchPage({
    required int page,
    required int generation,
    bool isLoadMore = false,
  }) async {
    // Keep immutable request inputs so a later query/type cannot be confused
    // with this response when requests complete out of order.
    final requestedType = type;
    final requestedSearch = searchQuery;
    final token =
        myServices.sharedPreferences.getString(
          AppSharedPrefKeys.userTokenKey,
        ) ??
        "";

    late final dynamic response;
    if (requestedType == 'popular') {
      response = await coursesData.getPopularCourses(
        token: token,
        page: page,
        limit: limit,
        search: requestedSearch.isNotEmpty ? requestedSearch : null,
      );
    } else if (requestedType == 'recommended') {
      response = await coursesData.getRecommendedCourses(
        token: token,
        page: page,
        limit: limit,
        search: requestedSearch.isNotEmpty ? requestedSearch : null,
      );
    } else {
      response = await coursesData.getAllCourses(
        token: token,
        page: page,
        limit: limit,
        search: requestedSearch.isNotEmpty ? requestedSearch : null,
      );
    }

    if (generation != _requestGeneration ||
        requestedType != type ||
        requestedSearch != searchQuery) {
      return;
    }

    final responseStatus = response.$1 as RequestStatus;
    if (responseStatus == RequestStatus.success) {
      final raw = response.$2;
      if (raw is Map<String, dynamic>) {
        final pageCourses = _extractCoursesFromResponse(raw);
        if (isLoadMore) {
          courses.addAll(pageCourses);
          currentPage = page;
          hasLoadMoreError = false;
        } else {
          courses = pageCourses;
          currentPage = 1;
        }
        hasNextPage = _extractHasNext(raw, pageCourses.length);
        requestStatus = RequestStatus.success;
      } else {
        if (isLoadMore) {
          hasLoadMoreError = true;
        } else {
          courses = [];
          requestStatus = RequestStatus.failed;
        }
      }
    } else if (isLoadMore) {
      hasLoadMoreError = true;
    } else {
      requestStatus = responseStatus;
    }

    isSearching = false;
    isLoadingMore = false;
    update();
  }

  goToCourseDetailsScreen(String courseId) {
    Get.toNamed(
      AppRoutesNames.exploreCourseScreen,
      arguments: {"courseID": courseId},
    );
  }
}
