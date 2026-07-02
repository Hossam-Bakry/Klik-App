part of 'shops_bloc.dart';

sealed class ShopsEvent extends Equatable {
  const ShopsEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load of the shop list.
class ShopsStarted extends ShopsEvent {
  const ShopsStarted();
}

/// Pull-to-refresh — re-fetches without showing the full-screen loader.
class ShopsRefreshed extends ShopsEvent {
  const ShopsRefreshed();
}
