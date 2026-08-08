import '../../../../core/network/api_result.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

/// Thin pass-through — the payload is already mapped by `NotificationsDto`.
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDataSource _remote;

  @override
  Future<ApiResult<NotificationFeed>> fetchNotifications() =>
      _remote.fetchNotifications();

  @override
  Future<ApiResult<Unit>> markRead(int id) => _remote.markRead(id);
}
