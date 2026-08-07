import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/order_details.dart';
import '../../domain/repositories/orders_repository.dart';

part 'order_details_state.dart';

/// Page-scoped state for one order: loading it, cancelling it, and posting the
/// reviews its products earn.
class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit(this._repository, this.orderId)
    : super(const OrderDetailsState());

  final OrdersRepository _repository;
  final int orderId;

  Future<void> load() async {
    emit(state.copyWith(status: OrderDetailsStatus.loading, clearError: true));
    switch (await _repository.fetchOrderDetails(orderId)) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: OrderDetailsStatus.success, order: data));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: OrderDetailsStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  /// Cancels the order, then re-reads it so the timeline and the actions match
  /// the new status. Returns true when the cancellation landed.
  Future<bool> cancel() async {
    emit(state.copyWith(action: OrderAction.cancelling, clearError: true));
    switch (await _repository.cancelOrder(orderId)) {
      case ApiSuccess():
        emit(state.copyWith(action: OrderAction.none));
        await load();
        return true;
      case ApiFailure(:final failure):
        emit(state.copyWith(
          action: OrderAction.none,
          errorMessage: failure.message,
        ));
        return false;
    }
  }
}
