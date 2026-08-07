import '../../../../core/localization/locale_keys.dart';

/// The date window in the list's dropdown.
///
/// Applied on the client: `GET /api/orders` ignores every date parameter we
/// tried, so the window filters the orders already loaded.
enum OrderDateRange {
  today(Duration(days: 1), LocaleKeys.today),
  lastWeek(Duration(days: 7), LocaleKeys.lastWeek),
  last3Weeks(Duration(days: 21), LocaleKeys.last3Weeks),
  lastMonth(Duration(days: 30), LocaleKeys.lastMonth),
  allTime(null, LocaleKeys.allTime);

  const OrderDateRange(this.window, this.labelKey);

  /// How far back the window reaches; null keeps everything.
  final Duration? window;

  final String labelKey;

  /// Whether an order placed at [placedAt] falls inside the window. Orders with
  /// no parseable date are kept — better a stray row than a hidden order.
  bool includes(DateTime? placedAt) {
    final span = window;
    if (span == null || placedAt == null) return true;
    return !placedAt.isBefore(DateTime.now().subtract(span));
  }
}
