import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/data/my_courses_data/my_courses_data.dart';
import 'package:new_graket_acadimy/model/my_courses/get_my_courses_model.dart';

class MyCoursesController extends GetxController {
  final MyCoursesData myCoursesData = MyCoursesData(Get.find());
  final MyServices myServices = Get.find();

  // Main request status
  RequestStatus requestStatus = RequestStatus.loading;

  // Separate lists for each tab
  List<Datum> ongoingCourses = [];
  List<Datum> completedCourses = [];
  List<Datum> savedCourses = [];

  // Pagination state for each tab
  final Map<String, int> _currentPage = {
    'ONGOING': 1,
    'COMPLETED': 1,
    'SAVED': 1,
  };

  final Map<String, bool> _hasMore = {
    'ONGOING': true,
    'COMPLETED': true,
    'SAVED': true,
  };

  final Map<String, bool> _isLoadingMore = {
    'ONGOING': false,
    'COMPLETED': false,
    'SAVED': false,
  };

  // Scroll controllers for each tab
  ScrollController ongoingScrollController = ScrollController();
  ScrollController completedScrollController = ScrollController();
  ScrollController savedScrollController = ScrollController();

  // Items per page
  final int _itemsPerPage = 10;

  @override
  void onInit() {
    super.onInit();
    _initializeScrollListeners();
    loadInitialData();
  }

  @override
  void onClose() {
    ongoingScrollController.dispose();
    completedScrollController.dispose();
    savedScrollController.dispose();
    super.onClose();
  }

  /// Initialize scroll listeners for pagination
  void _initializeScrollListeners() {
    ongoingScrollController.addListener(() {
      if (_shouldLoadMore(ongoingScrollController, 'ONGOING')) {
        loadMoreCourses('ONGOING');
      }
    });

    completedScrollController.addListener(() {
      if (_shouldLoadMore(completedScrollController, 'COMPLETED')) {
        loadMoreCourses('COMPLETED');
      }
    });

    savedScrollController.addListener(() {
      if (_shouldLoadMore(savedScrollController, 'SAVED')) {
        loadMoreCourses('SAVED');
      }
    });
  }

  /// Check if we should load more items
  bool _shouldLoadMore(ScrollController controller, String status) {
    if (!controller.hasClients) return false;
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    final delta = 200.0; // Load more when 200px from bottom

    return currentScroll >= (maxScroll - delta) &&
        _hasMore[status] == true &&
        _isLoadingMore[status] == false;
  }

  /// Load initial data for all tabs
  Future<void> loadInitialData() async {
    requestStatus = RequestStatus.loading;
    update();

    // Load first page for each status in parallel
    await Future.wait([
      _fetchCourses('ONGOING', isRefresh: true),
      _fetchCourses('COMPLETED', isRefresh: true),
      _fetchCourses('SAVED', isRefresh: true),
    ]);

    // Update status based on results
    if (ongoingCourses.isEmpty && completedCourses.isEmpty && savedCourses.isEmpty) {
      requestStatus = RequestStatus.failed;
    } else {
      requestStatus = RequestStatus.success;
    }
    update();
  }

  /// Pull-to-refresh handler
  Future<void> onRefresh() async {
    // Reset pagination state
    _currentPage['ONGOING'] = 1;
    _currentPage['COMPLETED'] = 1;
    _currentPage['SAVED'] = 1;
    _hasMore['ONGOING'] = true;
    _hasMore['COMPLETED'] = true;
    _hasMore['SAVED'] = true;

    await loadInitialData();
  }

  /// Load more courses for a specific status
  Future<void> loadMoreCourses(String status) async {
    if (_isLoadingMore[status] == true || _hasMore[status] == false) return;

    _isLoadingMore[status] = true;
    update();

    await _fetchCourses(status, isRefresh: false);

    _isLoadingMore[status] = false;
    update();
  }

  /// Fetch courses from API
  Future<void> _fetchCourses(String status, {required bool isRefresh}) async {
    final token = myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ?? "";
    if (token.isEmpty) return;

    if (isRefresh) {
      _currentPage[status] = 1;
      _hasMore[status] = true;
    }

    final page = _currentPage[status] ?? 1;

    final response = await myCoursesData.getMyCourses(
      token: token,
      page: page,
      limit: _itemsPerPage,
      status: status,
    );

    final responseStatus = response.$1;

    if (responseStatus == RequestStatus.success && response.$2 is Map<String, dynamic>) {
      final raw = response.$2 as Map<String, dynamic>;
      final List<Datum> newCourses = [];

      try {
        final model = GetMyCoursesModel.fromJson(raw);
        newCourses.addAll(model.data?.data?.data ?? []);
      } catch (_) {
        // Fallback parsing
        final data = raw['data'];
        if (data is Map && data['data'] is List) {
          final list = data['data'] as List;
          newCourses.addAll(
            list
                .whereType<Map>()
                .map((item) => Datum.fromJson(Map<String, dynamic>.from(item)))
                .toList(),
          );
        }
      }

      // Update the appropriate list
      if (isRefresh) {
        _setCourseList(status, newCourses);
      } else {
        _appendCourseList(status, newCourses);
      }

      // Update pagination state
      if (newCourses.length < _itemsPerPage) {
        _hasMore[status] = false;
      } else {
        _currentPage[status] = page + 1;
      }
    } else {
      _hasMore[status] = false;
    }
  }

  /// Set course list for a status
  void _setCourseList(String status, List<Datum> courses) {
    switch (status) {
      case 'ONGOING':
        ongoingCourses = courses;
        break;
      case 'COMPLETED':
        completedCourses = courses;
        break;
      case 'SAVED':
        savedCourses = courses;
        break;
    }
  }

  /// Append to course list for a status
  void _appendCourseList(String status, List<Datum> courses) {
    switch (status) {
      case 'ONGOING':
        ongoingCourses.addAll(courses);
        break;
      case 'COMPLETED':
        completedCourses.addAll(courses);
        break;
      case 'SAVED':
        savedCourses.addAll(courses);
        break;
    }
  }

  /// Check if loading more for a status
  bool isLoadingMore(String status) => _isLoadingMore[status] ?? false;

  /// Check if has more for a status
  bool hasMore(String status) => _hasMore[status] ?? false;
}
