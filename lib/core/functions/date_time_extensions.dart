// ignore_for_file: public_member_api_docs
import 'package:intl/intl.dart';

// convert from DateTime to (05 Sep 2025)
extension DateTimeExtensions on DateTime {
  String get to_dd_MMM_yyyy => DateFormat('dd MMM yyyy').format(this);

  String get toDaysMinHours {
    final days = difference(DateTime.now()).inDays;
    final hours = difference(DateTime.now()).inHours.remainder(24);
    final minutes = difference(DateTime.now()).inMinutes.remainder(60);

    if (days > 0) {
      return '$days d $hours h';
    }

    if (hours > 0 && minutes > 0) {
      return '~ $hours h';
    }

    if (hours > 0) {
      return '$hours h';
    }

    return 'less than 1 h';
  }

  // make from 10 m ago or 10 hour ago or 3 days ago
  String get toTimeAgo {
    final diff = DateTime.now().difference(this);

    if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    }

    if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    }

    if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minutes ago';
    }

    return 'Just now';
  }

  // make 12 Oct 2024 at 12:30 PM
  String get toDateTimeDetails {
    return '${DateFormat('dd MMM yyyy').format(this)} at ${DateFormat('hh:mm a').format(this)}';
  }
}
