import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';

part 'notifications_state.dart';

/// App-wide notifications, shared like `CartCubit` so the home bell's dot, the
/// profile tile and the list screen all read one source.
///
/// `main.dart` drives the session hand-off: [load] on sign-in, [clear] on
/// sign-out — notifications belong to an account and a guest has none.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState());

  final NotificationsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    await _fetch();
  }

  /// Pull-to-refresh, and what a push would call once FCM is wired — the REST
  /// list stays the source of truth rather than the message payload.
  Future<void> refresh() => _fetch();

  /// Drops everything on sign-out.
  void clear() => emit(const NotificationsState());

  /// Marks one read, moving the row and the badge straight away and asking the
  /// server after. A failure puts the row back rather than lying about it.
  Future<void> markRead(AppNotification notification) async {
    if (notification.isRead) return;

    final before = state;
    emit(state.copyWith(
      items: [
        for (final item in state.items)
          item.id == notification.id ? item.copyWith(isRead: true) : item,
      ],
      unread: (state.unread - 1).clamp(0, state.unread),
    ));

    if (await _repository.markRead(notification.id) case ApiFailure()) {
      emit(before);
    }
  }

  Future<void> _fetch() async {
    switch (await _repository.fetchNotifications()) {
      case ApiSuccess(:final data):
        emit(state.copyWith(
          status: NotificationsStatus.success,
          items: data.items,
          unread: data.unread,
        ));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }
}
