import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/order_date_range.dart';
import '../../domain/entities/order_details.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_summary.dart';
import '../../domain/repositories/orders_repository.dart';

part 'orders_event.dart';
part 'orders_state.dart';

/// Drives the Orders list.
///
/// `GET /api/orders` only understands `order_status` and paging — it ignores
/// every search and date parameter — so the screen loads the customer's orders
/// once and the chips, the search field and the date window all narrow that
/// list locally. Switching any of them never re-hits the network.
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc(this._repository) : super(const OrdersState()) {
    on<OrdersStarted>(_onStarted);
    on<OrdersRefreshed>(_onRefreshed);
    on<OrdersFilterChanged>(_onFilterChanged);
    on<OrdersSearchChanged>(_onSearchChanged);
    on<OrdersDateRangeChanged>(_onDateRangeChanged);
  }

  final OrdersRepository _repository;

  Future<void> _onStarted(OrdersStarted event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(status: OrdersStatus.loading));
    await _load(emit);
  }

  /// Pull-to-refresh, and what the details screen's cancel/review actions
  /// trigger on the way back — re-fetches without dropping to the skeleton.
  Future<void> _onRefreshed(
    OrdersRefreshed event,
    Emitter<OrdersState> emit,
  ) async {
    await _load(emit);
  }

  void _onFilterChanged(OrdersFilterChanged event, Emitter<OrdersState> emit) {
    emit(state.copyWith(filter: event.filter, clearFilter: event.filter == null));
  }

  void _onSearchChanged(OrdersSearchChanged event, Emitter<OrdersState> emit) {
    emit(state.copyWith(query: event.query));
  }

  void _onDateRangeChanged(
    OrdersDateRangeChanged event,
    Emitter<OrdersState> emit,
  ) {
    emit(state.copyWith(dateRange: event.range));
  }

  /// The order's product lines, fetched on demand.
  ///
  /// A list row carries none — they only come back from
  /// `GET /api/order-details` — and the rating flow needs a product to rate,
  /// so tapping a star on a card reads them here rather than sending the
  /// customer through the details screen first.
  ///
  /// Returns null when the read fails, so the caller can say so.
  Future<List<OrderLine>?> loadProducts(int orderId) async {
    return switch (await _repository.fetchOrderDetails(orderId)) {
      ApiSuccess(:final data) => data.products,
      ApiFailure() => null,
    };
  }

  Future<void> _load(Emitter<OrdersState> emit) async {
    switch (await _repository.fetchOrders()) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: OrdersStatus.success, orders: data));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: OrdersStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }
}
