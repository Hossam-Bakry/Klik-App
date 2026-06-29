part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

/// Single state object with a [status] enum (same pattern as CatalogBloc). The
/// UI switches on [status] and reads [feed]/[errorMessage] as needed.
class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.feed,
    this.errorMessage,
  });

  final HomeStatus status;
  final HomeFeed? feed;
  final String? errorMessage;

  bool get isLoading => status == HomeStatus.initial || status == HomeStatus.loading;

  HomeState copyWith({
    HomeStatus? status,
    HomeFeed? feed,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      feed: feed ?? this.feed,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, feed, errorMessage];
}
