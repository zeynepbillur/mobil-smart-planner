import 'package:intl/intl.dart';

class DateHelper {
  // Format date to string
  static String formatDate(DateTime date, {String format = 'dd.MM.yyyy'}) {
    try {
      return DateFormat(format, 'tr').format(date);
    } catch (e) {
      return DateFormat(format).format(date);
    }
  }

  // Format datetime to string
  static String formatDateTime(DateTime dateTime,
      {String format = 'dd.MM.yyyy HH:mm'}) {
    try {
      return DateFormat(format, 'tr').format(dateTime);
    } catch (e) {
      return DateFormat(format).format(dateTime);
    }
  }

  // Format time to string
  static String formatTime(DateTime time, {String format = 'HH:mm'}) {
    return DateFormat(format).format(time);
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  // Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  // Get relative date string (e.g., "Bugün", "Yarın", "2 gün önce")
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return 'Bugün';
    } else if (isTomorrow(date)) {
      return 'Yarın';
    } else if (isYesterday(date)) {
      return 'Dün';
    }

    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0 && difference.inDays < 7) {
      return '${difference.inDays} gün sonra';
    } else if (difference.inDays < 0 && difference.inDays > -7) {
      return '${-difference.inDays} gün önce';
    }

    return formatDate(date);
  }

  // Get days until date
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  // Get days since date
  static int daysSince(DateTime date) {
    final now = DateTime.now();
    final difference = DateTime(now.year, now.month, now.day).difference(date);
    return difference.inDays;
  }

  // Start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // End of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  // Start of week
  static DateTime startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // End of week
  static DateTime endOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  // Start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // End of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
}
