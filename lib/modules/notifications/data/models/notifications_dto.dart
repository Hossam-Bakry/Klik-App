import '../../domain/entities/app_notification.dart';

/// Parses `GET /api/notifications`. Confirmed against the live API 2026-08-07:
///
/// ```json
/// { "unread_count": 3, "total": 4,
///   "notification": [ { "id": 306, "title": "Order cancelled",
///                       "message": "Your order RC000173 has been cancelled.",
///                       "type": "order", "url": "173",
///                       "created_at": "منذ 22 ساعة", "is_read": false } ] }
/// ```
///
/// Note `notification` is singular and `url` holds a bare id, not a link.
class NotificationsDto {
  const NotificationsDto._();

  static List<AppNotification> listFromJson(Object? data) {
    final rows = data is Map ? data['notification'] : null;
    if (rows is! List) return const [];

    return rows
        .whereType<Map>()
        .map((row) => _fromJson(row.cast<String, dynamic>()))
        .toList();
  }

  /// The server's own unread tally — trusted over counting the rows, since the
  /// list is paginated.
  static int unreadFromJson(Object? data) =>
      data is Map ? _int(data['unread_count']) : 0;

  static AppNotification _fromJson(Map<String, dynamic> json) {
    final title = _str(json['title']);
    final message = _str(json['message']);

    return AppNotification(
      id: _int(json['id']),
      title: title,
      message: message,
      kind: NotificationKind.parse(_str(json['type']), title, message),
      reference: _str(json['url']),
      timeLabel: _str(json['created_at']),
      isRead: json['is_read'] == true,
    );
  }

  static String _str(Object? v) => v == null ? '' : v.toString().trim();

  static int _int(Object? v) => switch (v) {
    num n => n.toInt(),
    String s => int.tryParse(s) ?? 0,
    _ => 0,
  };
}
