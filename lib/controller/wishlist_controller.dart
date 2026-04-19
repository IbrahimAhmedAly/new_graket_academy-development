import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/debug_print.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/data/my_courses_data/my_courses_data.dart';
import 'package:new_graket_acadimy/data/wishlist_data/wishlist_data.dart';
import 'package:new_graket_acadimy/model/my_courses/get_my_courses_model.dart';

/// Controller for the wishlist tab.
///
/// "Saved" courses are modelled as Enrollment rows with status=SAVED on
/// the backend. This controller pages through GET /my-courses?status=SAVED,
/// and supports optimistic removal via DELETE /my-courses/:id/save.
class WishlistController extends GetxController {
  final MyCoursesData _myCoursesData = MyCoursesData(Get.find());
  final WishlistData _wishlistData = WishlistData(Get.find());
  final MyServices _services = Get.find();

  static const int _pageSize = 10;

  RequestStatus requestStatus = RequestStatus.loading;

  List<Datum> items = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  final ScrollController scrollController = ScrollController();

  /// Optimistically-removed course IDs kept in a set so we can roll back
  /// if the API call fails.
  final Set<String> _pendingRemovals = {};

  /// Count of saved courses as reported by the last successful fetch's
  /// metadata. Used for the tab badge.
  int totalCount = 0;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadInitial();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final max = scrollController.position.maxScrollExtent;
    final pos = scrollController.position.pixels;
    if (pos >= max - 200 && _hasMore && !_isLoadingMore) {
      _loadNextPage();
    }
  }

  String get _token =>
      _services.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
      '';

  Future<void> loadInitial() async {
    requestStatus = RequestStatus.loading;
    _currentPage = 1;
    _hasMore = true;
    update();
    await _fetchPage(reset: true);
    if (requestStatus == RequestStatus.loading) {
      requestStatus = RequestStatus.success;
    }
    update();
  }

  Future<void> onRefresh() async {
    await loadInitial();
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    update();
    await _fetchPage(reset: false);
    _isLoadingMore = false;
    update();
  }

  Future<void> _fetchPage({required bool reset}) async {
    final token = _token;
    if (token.isEmpty) {
      requestStatus = RequestStatus.failed;
      return;
    }

    try {
      final response = await _myCoursesData.getMyCourses(
        token: token,
        page: _currentPage,
        limit: _pageSize,
        status: 'SAVED',
      );
      final status = response.$1;
      final raw = response.$2;
      if (status == RequestStatus.success && raw is Map<String, dynamic>) {
        List<Datum> newItems = [];
        int meta = totalCount;
        try {
          final model = GetMyCoursesModel.fromJson(raw);
          newItems = model.data?.data?.data ?? [];
          meta = model.data?.data?.metadata?.totalItems ?? newItems.length;
        } catch (_) {
          // Fallback — raw nested parse
          final outer = raw['data'];
          if (outer is Map && outer['data'] is Map) {
            final inner = outer['data'] as Map;
            if (inner['data'] is List) {
              newItems = (inner['data'] as List)
                  .whereType<Map>()
                  .map(
                      (m) => Datum.fromJson(Map<String, dynamic>.from(m)))
                  .toList();
            }
            if (inner['metadata'] is Map) {
              meta = ((inner['metadata'] as Map)['totalItems'] as num?)
                      ?.toInt() ??
                  meta;
            }
          }
        }

        if (reset) {
          items = newItems;
        } else {
          items.addAll(newItems);
        }
        totalCount = meta;

        if (newItems.length < _pageSize) {
          _hasMore = false;
        } else {
          _currentPage += 1;
        }

        requestStatus = RequestStatus.success;
      } else if (reset) {
        requestStatus = RequestStatus.failed;
        _hasMore = false;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      appPrint('Wishlist fetch error: $e');
      if (reset) requestStatus = RequestStatus.failed;
      _hasMore = false;
    }
  }

  /// Remove a course from the wishlist. Optimistic: drop locally first,
  /// restore on API failure.
  Future<void> removeFromWishlist(Datum item) async {
    final id = item.course?.id;
    if (id == null || id.isEmpty) return;
    if (_pendingRemovals.contains(id)) return;

    // Optimistic remove
    _pendingRemovals.add(id);
    final prevIndex = items.indexOf(item);
    items.remove(item);
    if (totalCount > 0) totalCount -= 1;
    update();

    try {
      final response = await _wishlistData.unsaveCourse(
        courseId: id,
        userToken: _token,
      );
      if (response.$1 != RequestStatus.success) {
        // Roll back
        if (prevIndex >= 0) {
          items.insert(
              prevIndex.clamp(0, items.length), item);
        } else {
          items.add(item);
        }
        totalCount += 1;
        final msg = response.$2 is Map
            ? (response.$2 as Map)['message']?.toString()
            : null;
        Get.snackbar(
          'Wishlist',
          msg?.isNotEmpty == true ? msg! : 'Could not remove',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Wishlist',
          'Removed from saved',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      appPrint('Unsave error: $e');
      // Roll back
      if (prevIndex >= 0) {
        items.insert(prevIndex.clamp(0, items.length), item);
      } else {
        items.add(item);
      }
      totalCount += 1;
    } finally {
      _pendingRemovals.remove(id);
      update();
    }
  }
}
