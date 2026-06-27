part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load of the home feed.
class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// Pull-to-refresh — re-fetches without dropping the current content.
class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}
