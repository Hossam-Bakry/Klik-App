import 'package:flutter_bloc/flutter_bloc.dart';

import '../../network/api_result.dart';
import '../data/guest_cart_store.dart';
import '../domain/cart_merge_strategy.dart';
import '../domain/cart_repository.dart';

/// App-wide source of the cart badge count, shared like [FavoritesCubit] so the
/// bottom-nav badge stays in sync everywhere.
///
/// The count's source depends on who's signed in:
///   * guest  → the locally cached [GuestCartStore.count] (no cart object is
///     cached, only this integer + the guest token),
///   * account → the server, read via [refreshFromServer].
///
/// Initial state is seeded from the guest store so a returning guest sees their
/// badge immediately, before any network call.
class CartCountCubit extends Cubit<int> {
  CartCountCubit(this._repository, GuestCartStore store)
      : _store = store,
        super(store.count);

  final CartRepository _repository;
  final GuestCartStore _store;

  /// Persist and reflect a new guest cart count (called by the guest
  /// add/increment/decrement flow, which owns the server write + guest token).
  Future<void> setGuestCount(int value) async {
    final next = value < 0 ? 0 : value;
    await _store.setCount(next);
    emit(next);
  }

  /// Runs when a session becomes authenticated. If the user built a cart as a
  /// guest, fold it into their account cart, then drop the guest token so it's
  /// never reused. Finally sync the badge from the server. A returning user with
  /// no guest token skips the merge and just refreshes.
  Future<void> onSignedIn({
    CartMergeStrategy strategy = CartMergeStrategy.merge,
  }) async {
    final guestToken = _store.token;
    if (guestToken != null && guestToken.isNotEmpty) {
      final result = await _repository.mergeGuestCart(
        guestToken: guestToken,
        strategy: strategy,
      );
      // Only discard the local guest cart once the server has taken ownership;
      // on failure we keep the token so a later retry can still merge it.
      if (result.isSuccess) {
        await _store.clear();
        final merged = result.dataOrNull;
        if (merged != null) {
          emit(merged);
          return;
        }
      }
    }
    await refreshFromServer();
  }

  /// Pull the authenticated cart's item count and update the badge.
  Future<void> refreshFromServer() async {
    final result = await _repository.fetchCartCount();
    final count = result.dataOrNull;
    if (count != null) emit(count);
  }

  /// Reset the badge on sign-out. The guest store is already empty (cleared at
  /// merge time), so a fresh guest cart only starts on the next add-to-cart.
  void clear() => emit(0);
}
