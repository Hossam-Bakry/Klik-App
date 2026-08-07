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
  Future<bool> add(CartItem item) =>
      _mutate(item.productId, () => _repository.addItem(item));

  Future<bool> increment(CartItem item) =>
      _mutate(item.productId, () => _repository.increment(item));

  Future<bool> decrement(CartItem item) =>
      _mutate(item.productId, () => _repository.decrement(item));

  Future<bool> remove(CartItem item) =>
      _mutate(item.productId, () => _repository.removeItem(item));

  /// Units of a product in the cart, counting every variant of it — what a
  /// product card's stepper shows.
  int quantityOf(int productId) => state.cart.items
      .where((item) => item.productId == productId)
      .fold(0, (sum, item) => sum + item.quantity);

  /// A product card's "+". Cards carry no variant picker, so this tops up
  /// whichever line the product is already in and only starts a fresh
  /// (variant-less) line when it isn't in the cart at all — otherwise adding
  /// from a card would miss a line that went in with a size or colour.
  Future<bool> addOne(CartItem item) {
    final line = _lineFor(item.productId);
    return line == null ? add(item) : increment(line);
  }

  /// A product card's "−". Steps the product's line down, which drops it at
  /// zero. No-op when the product isn't in the cart.
  Future<bool> removeOne(int productId) {
    final line = _lineFor(productId);
    return line == null ? Future.value(false) : decrement(line);
  }

  /// The cart line holding [productId], whatever variant it went in as.
  CartItem? _lineFor(int productId) {
    for (final item in state.cart.items) {
      if (item.productId == productId) return item;
    }
    return null;
  }

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
  ///
  /// The product is marked pending for the duration so only its own stepper
  /// locks; a change to another product can run alongside it.
  Future<bool> _mutate(
    int productId,
    Future<ApiResult<Cart>> Function() action,
  ) async {
    emit(state.copyWith(
      pendingProductIds: {...state.pendingProductIds, productId},
      clearError: true,
    ));
    final ok = await _run(action());
    emit(state.copyWith(
      pendingProductIds: {...state.pendingProductIds}..remove(productId),
    ));
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
