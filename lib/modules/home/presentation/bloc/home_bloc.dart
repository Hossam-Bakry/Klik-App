import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/favorites/presentation/favorites_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/home_feed.dart';
import '../../domain/repositories/home_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._repository, this._favorites) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onRefreshed);
  }

  final HomeRepository _repository;
  final FavoritesCubit _favorites;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    await _load(emit);
  }

  Future<void> _onRefreshed(HomeRefreshed event, Emitter<HomeState> emit) async {
    // Keep showing current content while refreshing in the background.
    await _load(emit);
  }

  Future<void> _load(Emitter<HomeState> emit) async {
    final result = await _repository.getHomeFeed();
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: HomeStatus.success, feed: data));
        _favorites.seed(
          [...data.justForYou, ...data.bidableProducts]
              .where((p) => p.isFavorite)
              .map((p) => p.id),
        );
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }
}
