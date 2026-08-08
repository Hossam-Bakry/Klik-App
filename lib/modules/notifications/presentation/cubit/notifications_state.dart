part of 'notifications_cubit.dart';

enum NotificationsStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.items = const [],
    this.unread = 0,
    this.errorMessage,
  });

  final NotificationsStatus status;
  final List<AppNotification> items;

  /// The server's unread tally — it counts the whole history, not just the
  /// page on screen, so the bell's dot stays honest.
  final int unread;

  final String? errorMessage;

  bool get isLoading =>
      items.isEmpty &&
      (status == NotificationsStatus.initial ||
          status == NotificationsStatus.loading);

  bool get hasUnread => unread > 0;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? items,
    int? unread,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      unread: unread ?? this.unread,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, unread, errorMessage];
}
