part of 'wishlist_bloc.dart';

sealed class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load of the favorite products.
class WishlistStarted extends WishlistEvent {
  const WishlistStarted();
}

/// Pull-to-refresh — re-fetches without the full-screen loader.
class WishlistRefreshed extends WishlistEvent {
  const WishlistRefreshed();
}
