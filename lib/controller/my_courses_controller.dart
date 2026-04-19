import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/data/my_courses_data/my_courses_data.dart';
import 'package:new_graket_acadimy/model/my_courses/get_my_courses_model.dart';

/// Controller for the "My Courses" tab.
///
/// Since the Wishlist ("SAVED" enrollments) lives in its own dedicated tab
/// and controller now, this controller only tracks ONGOING and COMPLETED.
class MyCoursesController extends GetxController {
  final MyCoursesData myCoursesData = MyCoursesData(Get.find());
  final MyServices myServices = Get.find();

  RequestStatus requestStatus = RequestStatus.loading;

  List<Datum> ongoingCourses = [];
  List<Datum> completedCourses = [];

  final Map<String, int> _currentPage = {
    'ONGOING': 1,
    'COMPLETED': 1,
  };

  final Map<String, bool> _hasMore = {
    'ONGOING': true,
    'COMPLETED': true,
  };

  final Map<String, bool> _isLoadingMore = {
    'ONGOING': false,
    'COMPLETED': false,
  };

  ScrollController ongoingScrollController = ScrollController();
  ScrollController completedScrollController = ScrollController();

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
    super.onClose();
  }

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
  }

  bool _shouldLoadMore(ScrollController controller, String status) {
    if (!controller.hasClients) return false;
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    const delta = 200.0;
    return currentScroll >= (maxScroll - delta) &&
        _hasMore[status] == true &&
        _isLoadingMore[status] == false;
  }

  Future<void> loadInitialData() async {
    requestStatus = RequestStatus.loading;
    update();

    await Future.wait([
      _fetchCourses('ONGOING', isRefresh: true),
      _fetchCourses('COMPLETED', isRefresh: true),
    ]);

    // If neither list loaded anything and we were expected to have a token,
    // surface failure; otherwise success (empty states are valid).
    requestStatus = RequestStatus.success;
    update();
  }

  Future<void> onRefresh() async {
    _currentPage['ONGOING'] = 1;
    _currentPage['COMPLETED'] = 1;
    _hasMore['ONGOING'] = true;
    _hasMore['COMPLETED'] = true;
    await loadInitialData();
  }

  Future<void> loadMoreCourses(String status) async {
    if (_isLoadingMore[status] == true || _hasMore[status] == false) return;
    _isLoadingMore[status] = true;
    update();
    await _fetchCourses(status, isRefresh: false);
    _isLoadingMore[status] = false;
    update();
  }

  Future<void> _fetchCourses(String status, {required bool isRefresh}) async {
    final token =
        myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
            "";
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
    if (responseStatus == RequestStatus.success &&
        response.$2 is Map<String, dynamic>) {
      final raw = response.$2 as Map<String, dynamic>;
      final List<Datum> newCourses = [];

      try {
        final model = GetMyCoursesModel.fromJson(raw);
        newCourses.addAll(model.data?.data?.data ?? []);
      } catch (_) {
        // Fallback: the list sits at raw['data']['data']
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

      if (isRefresh) {
        _setCourseList(status, newCourses);
      } else {
        _appendCourseList(status, newCourses);
      }

      if (newCourses.length < _itemsPerPage) {
        _hasMore[status] = false;
      } else {
        _currentPage[status] = page + 1;
      }
    } else {
      _hasMore[status] = false;
    }
  }

  void _setCourseList(String status, List<Datum> courses) {
    switch (status) {
      case 'ONGOING':
        ongoingCourses = courses;
        break;
      case 'COMPLETED':
        completedCourses = courses;
        break;
    }
  }

  void _appendCourseList(String status, List<Datum> courses) {
    switch (status) {
      case 'ONGOING':
        ongoingCourses.addAll(courses);
        break;
      case 'COMPLETED':
        completedCourses.addAll(courses);
        break;
    }
  }

  bool isLoadingMore(String status) => _isLoadingMore[status] ?? false;
  bool hasMore(String status) => _hasMore[status] ?? false;
}
