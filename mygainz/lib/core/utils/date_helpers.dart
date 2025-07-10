/// Utility functions for date formatting and manipulation
class DateHelpers {
  /// Returns the abbreviated month name for a given month number (1-12)
  static String getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Formats a DateTime into a short date string (DD-MMM-YYYY)
  static String formatShortDate(DateTime date) {
    return '${date.day}-${getMonthName(date.month)}-${date.year}';
  }
}
