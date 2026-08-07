part of 'order_details_cubit.dart';

enum OrderDetailsStatus { initial, loading, success, failure }

/// A write the screen is waiting on. The order stays on screen throughout —
/// only the footer buttons lock.
enum OrderAction { none, cancelling, reviewing }

class OrderDetailsState extends Equatable {
  const OrderDetailsState({
    this.status = OrderDetailsStatus.initial,
    this.order,
    this.action = OrderAction.none,
    this.errorMessage,
  });

  final OrderDetailsStatus status;
  final OrderDetails? order;
  final OrderAction action;
  final String? errorMessage;

  bool get isLoading =>
      order == null &&
      (status == OrderDetailsStatus.initial ||
          status == OrderDetailsStatus.loading);

  bool get isBusy => action != OrderAction.none;

  OrderDetailsState copyWith({
    OrderDetailsStatus? status,
    OrderDetails? order,
    OrderAction? action,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrderDetailsState(
      status: status ?? this.status,
      order: order ?? this.order,
      action: action ?? this.action,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, order, action, errorMessage];
}
