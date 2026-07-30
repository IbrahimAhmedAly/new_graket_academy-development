/// Mirrors the backend `NotificationType` enum
/// (PROMO, REMINDER, NEW_COURSE, ACHIEVEMENT, SYSTEM).
enum NotificationType { promo, reminder, newCourse, achievement, system }

/// Maps a raw backend type string (e.g. "PROMO", "NEW_COURSE") to the enum.
/// Falls back to [NotificationType.system] for unknown values.
NotificationType notificationTypeFromString(String? value) {
  switch ((value ?? '').toUpperCase()) {
    case 'PROMO':
      return NotificationType.promo;
    case 'REMINDER':
      return NotificationType.reminder;
    case 'NEW_COURSE':
      return NotificationType.newCourse;
    case 'ACHIEVEMENT':
      return NotificationType.achievement;
    case 'SYSTEM':
    default:
      return NotificationType.system;
  }
}
