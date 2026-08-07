import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../network/api_result.dart';
import '../domain/cart.dart';
import '../domain/cart_item.dart';
import '../domain/cart_repository.dart';

part 'cart_state.dart';

/// App-wide cart, shared like `FavoritesCubit` so the screen and the bottom-nav
/// badge read one source.
///
/// While the user is a guest the cart is device-only — every mutation here is a
/// local write with no network call. `main.dart` drives the session hand-off:
/// [onSignedIn] merges the guest lines into the account exactly once, and
/// [onSignedOut] drops the account's cart.
///
/// Seeded synchronously from the device so a returning guest sees their badge
/// before anything is awaited.
class CartCubit extends Cubit<CartState> {
  CartCubit(this._repository)
    : super(CartState(cart: Cart(items: _repository.localItems)));

  final CartRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: CartStatus.loading));
    await _run(_repository.fetchCart());
  }

  /// Adds a line. Returns true when it landed, so the caller can toast the
  /// outcome.
  Future<bool> add(CartItem item) => _mutate(_repository.addItem(item));

  Future<bool> increment(CartItem item) =>
      _mutate(_repository.increment(item));

  Future<bool> decrement(CartItem item) =>
      _mutate(_repository.decrement(item));

  Future<bool> remove(CartItem item) => _mutate(_repository.removeItem(item));

  /// Runs when a session becomes authenticated. Any cart built as a guest is
  /// handed to the account via `POST /api/cart/merge` and dropped from the
  /// device once that succeeds; from there on the server's cart is the live
  /// one and every action goes through the cart API.
  ///
  /// On failure the guest lines stay on the device *and* on screen, so the
  /// user doesn't lose the cart they built and the next sign-in can retry.
  Future<void> onSignedIn() async {
    final guestItems = _repository.localItems;
    if (guestItems.isEmpty) {
      await load();
      return;
    }

    emit(state.copyWith(status: CartStatus.loading));
    final merged = await _repository.mergeGuestCart(guestItems);
    if (merged.isFailure) {
      emit(state.copyWith(
        status: CartStatus.success,
        cart: Cart(items: guestItems),
        errorMessage: merged.failureOrNull?.message,
      ));
      return;
    }

    await _repository.clearLocal();
    // The merge response isn't documented to echo the cart back, so read the
    // account's cart from the endpoint that definitely holds it. This is also
    // what refreshes the nav badge.
    await load();
  }

  /// Drop the account's cart on sign-out. The device store is already empty
  /// (cleared at merge time), so the next guest cart starts fresh.
  void onSignedOut() => emit(const CartState(status: CartStatus.success));

  /// Mutations keep the current cart on screen and surface failure through
  /// [CartState.errorMessage] rather than blanking the list.
  Future<bool> _mutate(Future<ApiResult<Cart>> action) async {
    emit(state.copyWith(isMutating: true, clearError: true));
    final ok = await _run(action);
    emit(state.copyWith(isMutating: false));
    return ok;
  }

  Future<bool> _run(Future<ApiResult<Cart>> action) async {
    switch (await action) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: CartStatus.success, cart: data));
        return true;
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: state.cart.isEmpty ? CartStatus.failure : state.status,
          errorMessage: failure.message,
        ));
        return false;
    }
  }
}
