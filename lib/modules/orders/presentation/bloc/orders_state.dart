part of 'orders_bloc.dart';

enum OrdersStatus { initial, loading, success, failure }

class OrdersState extends Equatable {
  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.filter,
    this.query = '',
    this.dateRange = OrderDateRange.last3Weeks,
    this.errorMessage,
  });

  final OrdersStatus status;

  /// Everything the API returned, before any of the local filters.
  final List<OrderSummary> orders;

  /// The selected chip; `null` is "All".
  final OrderListFilter? filter;

  /// What's typed in the search field.
  final String query;

  /// The dropdown's window. Starts at "Last 3 Weeks", as the design shows.
  final OrderDateRange dateRange;

  final String? errorMessage;

  bool get isLoading =>
      status == OrdersStatus.initial || status == OrdersStatus.loading;

  /// The rows the list should render: the chip, the date window and the search
  /// term applied in turn.
  ///
  /// Search only matches the order code — a row carries no shop or product
  /// names to match against (they live on `GET /api/order-details`).
  List<OrderSummary> get visible {
    final term = query.trim().replaceAll('#', '').toLowerCase();

    return orders.where((order) {
      if (filter != null && !filter!.matches(order.status)) return false;
      if (!dateRange.includes(order.placedAt)) return false;
      if (term.isEmpty) return true;
      return order.code.replaceAll('#', '').toLowerCase().contains(term);
    }).toList();
  }

  /// Whether anything is narrowing the list — tells an empty result "nothing
  /// matches" apart from "you haven't ordered yet".
  bool get isFiltered =>
      filter != null ||
      query.trim().isNotEmpty ||
      dateRange != OrderDateRange.allTime;

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderSummary>? orders,
    OrderListFilter? filter,
    bool clearFilter = false,
    String? query,
    OrderDateRange? dateRange,
    String? errorMessage,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      // `filter` is nullable, so "back to All" needs its own flag.
      filter: clearFilter ? null : (filter ?? this.filter),
      query: query ?? this.query,
      dateRange: dateRange ?? this.dateRange,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    orders,
    filter,
    query,
    dateRange,
    errorMessage,
  ];
}
