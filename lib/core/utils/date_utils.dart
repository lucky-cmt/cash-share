/// Date normalization and formatting helpers.
class AppDateUtils {
  AppDateUtils._();

  /// Normalizes a [DateTime] to midnight UTC/local date-only string (`YYYY-MM-DD`).
  static String toIsoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Strips the time component from [date].
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
