import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/enums/notification_type.dart';
import 'package:new_graket_acadimy/core/functions/date_time_extensions.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/data/notifications_data/notifications_data.dart';
import 'package:new_graket_acadimy/model/notifications/get_notifications_model.dart';
import 'package:new_graket_acadimy/model/notifications/get_unread_notifications_count_model.dart';

class NotificationsController extends GetxController {
  final NotificationsData notificationsData = NotificationsData(Get.find());
  final MyServices myServices = Get.find();

  RequestStatus requestStatus = RequestStatus.loading;
  List<Map<String, dynamic>> elements = [];
  int unreadCount = 0;

  @override
  void onInit() {
    super.onInit();
    getNotifications();
    getUnreadCount();
  }

  String _token() =>
      myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
      '';

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }

  String _groupDate(DateTime? value) {
    if (value == null) return AppStrings.unknown.tr;
    final now = DateTime.now();
    if (_isSameDay(value, now)) return AppStrings.today.tr;
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(value, yesterday)) return AppStrings.yesterday.tr;
    return value.to_dd_MMM_yyyy;
  }

  String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final result = value is String ? value : value.toString();
    return result.isEmpty ? fallback : result;
  }

  bool _boolValue(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
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

  Future<void> getNotifications({bool silent = false}) async {
    final token = _token();
    if (token.isEmpty) {
      requestStatus = RequestStatus.failed;
      update();
      return;
    }

    // Show the skeleton only on a cold load. On a silent refresh (re-entering
    // the screen while data is already visible) keep the current list up.
    if (!silent || elements.isEmpty) {
      requestStatus = RequestStatus.loading;
      update();
    }

    final response = await notificationsData.getNotifications(token: token);
    requestStatus = response.$1;

    if (requestStatus == RequestStatus.success &&
        response.$2 is Map<String, dynamic>) {
      final raw = response.$2 as Map<String, dynamic>;
      List<Map<String, dynamic>> items = [];
      try {
        final model = GetNotificationsModel.fromJson(raw);
        items = _normalizeList(model.data?.data?.data);
      } catch (_) {
        items = [];
      }

      if (items.isEmpty) {
        final data = raw['data'];
        if (data is Map && data['data'] is List) {
          items = _normalizeList(data['data']);
        } else if (data is Map && data['data'] is Map) {
          final inner = (data['data'] as Map)['data'];
          if (inner is List) items = _normalizeList(inner);
        }
      }

      elements = items.map((item) {
        final header = _stringValue(
          item['title'] ?? item['header'] ?? item['subject'],
          fallback: 'Notification',
        );
        final subHeader = _stringValue(
          item['description'] ?? item['message'] ?? item['body'] ??
              item['content'],
          fallback: '',
        );
        final type = _stringValue(item['type'] ?? item['category']);
        final createdAt = _parseDate(item['createdAt'] ?? item['date']);
        return {
          'id': _stringValue(item['id']),
          'isRead': _boolValue(item['isRead']),
          'notificationType': notificationTypeFromString(type),
          'header': header,
          'subHeader': subHeader,
          'date': _groupDate(createdAt),
        };
      }).toList();
    }

    update();
  }

  Future<void> getUnreadCount() async {
    final token = _token();
    if (token.isEmpty) return;

    final response = await notificationsData.getUnreadCount(token: token);
    if (response.$1 == RequestStatus.success &&
        response.$2 is Map<String, dynamic>) {
      try {
        final model = GetUnreadNotificationsCountModel.fromJson(
          response.$2 as Map<String, dynamic>,
        );
        unreadCount = model.data?.data?.count ?? unreadCount;
      } catch (_) {
        // keep previous count on parse failure
      }
      update();
    }
  }

  /// Mark a single notification as read (optimistic).
  Future<void> markRead(String id) async {
    if (id.isEmpty) return;
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index == -1) return;
    // Already read → nothing to do.
    if (elements[index]['isRead'] == true) return;

    elements[index]['isRead'] = true;
    if (unreadCount > 0) unreadCount--;
    update();

    final token = _token();
    if (token.isEmpty) return;
    final response = await notificationsData.markAsRead(id: id, token: token);
    if (response.$1 != RequestStatus.success) {
      // revert + resync on failure
      await getNotifications();
      await getUnreadCount();
    }
  }

  /// Mark all notifications as read (optimistic).
  Future<void> markAllRead() async {
    if (unreadCount == 0) return;
    for (final e in elements) {
      e['isRead'] = true;
    }
    unreadCount = 0;
    update();

    final token = _token();
    if (token.isEmpty) return;
    final response = await notificationsData.markAllAsRead(token: token);
    if (response.$1 != RequestStatus.success) {
      await getNotifications();
      await getUnreadCount();
    }
  }

  /// Delete a single notification (optimistic).
  Future<void> deleteOne(String id) async {
    if (id.isEmpty) return;
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index == -1) return;

    final removed = elements[index];
    final wasUnread = removed['isRead'] != true;
    elements.removeAt(index);
    if (wasUnread && unreadCount > 0) unreadCount--;
    update();

    final token = _token();
    if (token.isEmpty) return;
    final response =
        await notificationsData.deleteNotification(id: id, token: token);
    if (response.$1 != RequestStatus.success) {
      await getNotifications();
      await getUnreadCount();
    }
  }

  /// Refresh both the list and the unread count.
  /// [silent] keeps the current list visible instead of showing the skeleton
  /// (used on screen re-entry and pull-to-refresh, which have their own
  /// progress indicators).
  Future<void> refreshAll({bool silent = true}) async {
    await getNotifications(silent: silent);
    await getUnreadCount();
  }

  /// Lightweight unread-count refresh, for the bell badge on other screens.
  Future<void> refreshUnreadCount() => getUnreadCount();
}
