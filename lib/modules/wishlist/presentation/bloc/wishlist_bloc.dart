import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/favorites/presentation/favorites_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../../home/domain/entities/home_product.dart';
import '../../domain/repositories/wishlist_repository.dart';

part 'wishlist_event.dart';
part 'wishlist_state.dart';

/// Loads the user's favorite products. Seeds the global [FavoritesCubit] with
/// the returned ids so every heart (here and elsewhere) shows selected; the
/// page filters the list by that cubit so unfavoriting removes items live.
class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  WishlistBloc(this._repository, this._favorites)
      : super(const WishlistState()) {
    on<WishlistStarted>(_onStarted);
    on<WishlistRefreshed>(_onRefreshed);
  }

  final WishlistRepository _repository;
  final FavoritesCubit _favorites;

  Future<void> _onStarted(
    WishlistStarted event,
    Emitter<WishlistState> emit,
  ) async {
    emit(state.copyWith(status: WishlistStatus.loading));
    await _load(emit);
  }

  Future<void> _onRefreshed(
    WishlistRefreshed event,
    Emitter<WishlistState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<WishlistState> emit) async {
    final result = await _repository.fetchFavorites();
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: WishlistStatus.success, products: data));
        _favorites.seed(data.map((p) => p.id));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: WishlistStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }
}
