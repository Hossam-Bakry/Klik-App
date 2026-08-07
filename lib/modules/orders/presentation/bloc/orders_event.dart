part of 'orders_bloc.dart';

sealed class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load of the customer's orders.
class OrdersStarted extends OrdersEvent {
  const OrdersStarted();
}

/// Pull-to-refresh — re-fetches without the skeleton.
class OrdersRefreshed extends OrdersEvent {
  const OrdersRefreshed();
}

/// Tapped a status chip. `null` is the "All" chip.
class OrdersFilterChanged extends OrdersEvent {
  const OrdersFilterChanged(this.filter);

  final OrderListFilter? filter;

  @override
  List<Object?> get props => [filter];
}

/// Typed in the search field.
class OrdersSearchChanged extends OrdersEvent {
  const OrdersSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Picked a window in the date dropdown.
class OrdersDateRangeChanged extends OrdersEvent {
  const OrdersDateRangeChanged(this.range);

  final OrderDateRange range;

  @override
  List<Object?> get props => [range];
}
