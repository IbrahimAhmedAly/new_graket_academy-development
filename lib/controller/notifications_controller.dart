import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/enums/notification_type.dart';
import 'package:new_graket_acadimy/core/functions/date_time_extensions.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/data/notifications_data/notifications_data.dart';
import 'package:new_graket_acadimy/model/notifications/get_notifications_model.dart';

class NotificationsController extends GetxController {
  final NotificationsData notificationsData = NotificationsData(Get.find());
  final MyServices myServices = Get.find();

  RequestStatus requestStatus = RequestStatus.loading;
  List<Map<String, dynamic>> elements = [];

  @override
  void onInit() {
    super.onInit();
    getNotifications();
  }

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
    if (value == null) return 'Unknown';
    final now = DateTime.now();
    if (_isSameDay(value, now)) return 'Today';
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(value, yesterday)) return 'Yesterday';
    return value.to_dd_MMM_yyyy;
  }

  String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final result = value is String ? value : value.toString();
    return result.isEmpty ? fallback : result;
  }

  NotificationType _mapType(String type, String header) {
    final normalized = type.toLowerCase();
    if (normalized.contains('discount')) return NotificationType.discount;
    if (normalized.contains('finish') || normalized.contains('complete')) {
      return NotificationType.finishCourses;
    }
    if (normalized.contains('warn') || normalized.contains('alert')) {
      return NotificationType.worning;
    }
    final headerLower = header.toLowerCase();
    if (headerLower.contains('discount')) return NotificationType.discount;
    if (headerLower.contains('finish') || headerLower.contains('complete')) {
      return NotificationType.finishCourses;
    }
    if (headerLower.contains('warn') || headerLower.contains('alert')) {
      return NotificationType.worning;
    }
    return NotificationType.newCourses;
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

  Future<void> getNotifications() async {
    final token =
        myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
            '';
    if (token.isEmpty) {
      requestStatus = RequestStatus.failed;
      update();
      return;
    }

    requestStatus = RequestStatus.loading;
    update();

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
        }
      }

      elements = items.map((item) {
        final header = _stringValue(
            item['title'] ?? item['header'] ?? item['subject'],
            fallback: 'Notification');
        final subHeader = _stringValue(
            item['message'] ?? item['body'] ?? item['content'],
            fallback: '');
        final type = _stringValue(item['type'] ?? item['category']);
        final createdAt = _parseDate(item['createdAt'] ?? item['date']);
        return {
          'notificationType': _mapType(type, header),
          'header': header,
          'subHeader': subHeader,
          'date': _groupDate(createdAt),
        };
      }).toList();
    }

    // Use static demo data when API returns nothing
    if (elements.isEmpty) {
      elements = _staticNotifications();
    }

    requestStatus = RequestStatus.success;
    update();
  }

  /// Static placeholder data — remove once real API integration is done.
  List<Map<String, dynamic>> _staticNotifications() {
    return [
      {
        'notificationType': NotificationType.newCourses,
        'header': 'New course available!',
        'subHeader': 'UI/UX Design Fundamentals has been added. Check it out now.',
        'date': 'Today',
      },
      {
        'notificationType': NotificationType.discount,
        'header': '30% off this week only',
        'subHeader': 'Mobile App Development course is on sale. Don\'t miss it!',
        'date': 'Today',
      },
      {
        'notificationType': NotificationType.finishCourses,
        'header': 'Congratulations!',
        'subHeader': 'You completed the Flutter Basics course. Your certificate is ready.',
        'date': 'Today',
      },
      {
        'notificationType': NotificationType.worning,
        'header': 'Your subscription expires soon',
        'subHeader': 'Renew before April 15 to keep access to all your courses.',
        'date': 'Yesterday',
      },
      {
        'notificationType': NotificationType.newCourses,
        'header': 'Recommended for you',
        'subHeader': 'Based on your interests: Advanced React Patterns course.',
        'date': 'Yesterday',
      },
      {
        'notificationType': NotificationType.discount,
        'header': 'Flash sale ended',
        'subHeader': 'Thanks for shopping! Your order for 2 courses is confirmed.',
        'date': 'Yesterday',
      },
      {
        'notificationType': NotificationType.finishCourses,
        'header': 'Keep it up!',
        'subHeader': 'You\'re 80% through the Data Science course. Almost there!',
        'date': '03 Apr 2026',
      },
    ];
  }
}
