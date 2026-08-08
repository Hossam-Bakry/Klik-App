import '../../../../core/network/api_result.dart';
import '../entities/app_notification.dart';

/// The customer's notifications, plus the server's unread tally — they come
/// back in one call, so they travel together.
typedef NotificationFeed = ({List<AppNotification> items, int unread});

abstract interface class NotificationsRepository {
  /// `GET /api/notifications`.
  Future<ApiResult<NotificationFeed>> fetchNotifications();

  /// Marks one read (`POST /api/notifications/{id}`).
  Future<ApiResult<Unit>> markRead(int id);
}
