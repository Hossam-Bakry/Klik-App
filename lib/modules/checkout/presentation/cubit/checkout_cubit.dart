import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cart/presentation/cart_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/placed_order.dart';
import '../../domain/repositories/checkout_repository.dart';

part 'checkout_state.dart';

/// Drives the three checkout steps.
///
/// The cart stays the source of truth for what's being bought — the review step
/// edits quantities through [CartCubit], and this cubit re-reads the totals
/// whenever they change.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._repository, this._cart) : super(const CheckoutState());

  final CheckoutRepository _repository;
  final CartCubit _cart;

  Future<void> start() async {
    emit(state.copyWith(status: CheckoutStatus.loading));
    await _loadSummary();
  }

  void goTo(CheckoutStep step) => emit(state.copyWith(step: step));

  void next() {
    final steps = CheckoutStep.values;
    final at = steps.indexOf(state.step);
    if (at < steps.length - 1) emit(state.copyWith(step: steps[at + 1]));
  }

  /// Back a step. Returns false at the first one, so the screen knows to leave.
  bool back() {
    final steps = CheckoutStep.values;
    final at = steps.indexOf(state.step);
    if (at == 0) return false;
    emit(state.copyWith(step: steps[at - 1]));
    return true;
  }

  void selectMethod(PaymentMethod method) =>
      emit(state.copyWith(method: method, clearError: true));

  /// Stores the card the customer typed, as a masked label only. There's no
  /// endpoint to send card data to, and the app has no business keeping it.
  void setCard(String maskedNumber) => emit(
    state.copyWith(cardLabel: maskedNumber, method: PaymentMethod.card),
  );

  /// Re-reads the totals — the review step's steppers change what's owed.
  Future<void> refreshTotals() => _loadSummary();

  Future<void> applyCoupon(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return;

    emit(state.copyWith(couponStatus: CouponStatus.applying, clearError: true));

    switch (await _repository.applyCoupon(
      code: trimmed,
      lines: _cart.state.cart.items,
    )) {
      case ApiSuccess(:final data) when data > 0:
        emit(state.copyWith(
          couponStatus: CouponStatus.applied,
          couponCode: trimmed,
          couponDiscount: data,
        ));
      // A refused coupon still answers 200 with a zero discount; the reason
      // rides on the envelope's message.
      case ApiSuccess(:final message):
        emit(state.copyWith(
          couponStatus: CouponStatus.rejected,
          errorMessage: message,
          couponDiscount: 0,
        ));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          couponStatus: CouponStatus.rejected,
          errorMessage: failure.message,
          couponDiscount: 0,
        ));
    }
  }

  /// Places the cart. Returns the order on success so the screen can show the
  /// confirmation; null when it failed (the message is on the state).
  ///
  /// [paidTotal] is the total the customer was just shown — the confirmation
  /// falls back to it, because nothing in the order call is guaranteed to come
  /// back with a figure and "0.00" would be a lie.
  Future<PlacedOrder?> placeOrder({
    required int addressId,
    required double paidTotal,
  }) async {
    final shopIds = _cart.state.cart.shopIds;
    if (shopIds.isEmpty) return null;

    emit(state.copyWith(status: CheckoutStatus.placing, clearError: true));

    switch (await _repository.placeOrder(
      shopIds: shopIds,
      addressId: addressId,
    )) {
      case ApiSuccess(:final data):
        final order = await _confirmationFor(data, paidTotal: paidTotal);
        emit(state.copyWith(status: CheckoutStatus.placed));
        // The lines are the shop's problem now.
        await _cart.load();
        return order;
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: CheckoutStatus.ready,
          errorMessage: failure.message,
        ));
        return null;
    }
  }

  /// What the confirmation screen shows.
  ///
  /// `POST /api/place-order` answers without describing the order it raised, so
  /// when it comes back empty the newest row of `GET /api/orders` — the order
  /// that was just created — fills in the number, the stamp and the payment
  /// method. Whatever is still missing falls back to what the checkout knew.
  ///
  /// A cart spanning several shops raises an order per shop; the newest is the
  /// one shown, as the design has room for one.
  Future<PlacedOrder> _confirmationFor(
    PlacedOrder placed, {
    required double paidTotal,
  }) async {
    var order = placed;

    if (order.isEmpty || order.number.isEmpty) {
      if (await _repository.fetchLatestOrder() case ApiSuccess(data: final latest)) {
        order = PlacedOrder(
          number: order.number.isEmpty ? latest.number : order.number,
          placedLabel: order.placedLabel.isEmpty
              ? latest.placedLabel
              : order.placedLabel,
          paymentMethodLabel: order.paymentMethodLabel.isEmpty
              ? latest.paymentMethodLabel
              : order.paymentMethodLabel,
          total: order.total > 0 ? order.total : latest.total,
        );
      }
    }

    return order.total > 0 ? order : order.copyWith(total: paidTotal);
  }

  Future<void> _loadSummary() async {
    switch (await _repository.fetchSummary()) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: CheckoutStatus.ready, summary: data));
      // The screen can still total the cart itself, so a failed summary is a
      // message rather than a dead end.
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: CheckoutStatus.ready,
          errorMessage: failure.message,
        ));
    }
  }
}
