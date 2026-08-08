import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../models/notifications_dto.dart';

abstract interface class NotificationsRemoteDataSource {
  Future<ApiResult<NotificationFeed>> fetchNotifications();

  Future<ApiResult<Unit>> markRead(int id);
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  /// One generous page — the screen has no paging UI, and a customer's
  /// notification history is short. Wire `page` here if that stops holding.
  static const int _pageSize = 50;

  @override
  Future<ApiResult<NotificationFeed>> fetchNotifications() => _api.get(
    ApiEndpoints.notifications,
    query: const {'page': 1, 'per_page': _pageSize},
    decoder: (data) => (
      items: NotificationsDto.listFromJson(data),
      unread: NotificationsDto.unreadFromJson(data),
    ),
  );

  /// The endpoint answers with the notification it just read; nothing here
  /// needs it, so the screen keeps its own optimistic copy.
  @override
  Future<ApiResult<Unit>> markRead(int id) => _api.post(
    ApiEndpoints.notification(id),
    decoder: (_) => unit,
  );
}
