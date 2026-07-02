import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/favorites/presentation/favorites_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../../home/domain/entities/home_product.dart';
import '../../domain/entities/products_filter.dart';
import '../../domain/repositories/products_repository.dart';

part 'products_event.dart';
part 'products_state.dart';

/// Drives the reusable products list page: first-page load, pull-to-refresh,
/// infinite-scroll pagination, and re-querying when the search text or filter
/// sheet changes.
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc(this._repository, this._favorites, {int perPage = 20})
      : _perPage = perPage,
        super(const ProductsState()) {
    on<ProductsStarted>(_onStarted);
    on<ProductsRefreshed>(_onRefreshed);
    on<ProductsLoadMore>(_onLoadMore);
    on<ProductsFilterChanged>(_onFilterChanged);
  }

  final ProductsRepository _repository;
  final FavoritesCubit _favorites;
  final int _perPage;

  Future<void> _onStarted(
    ProductsStarted event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductsStatus.loading,
      filter: event.filter,
    ));
    await _loadFirstPage(emit);
  }

  Future<void> _onRefreshed(
    ProductsRefreshed event,
    Emitter<ProductsState> emit,
  ) async {
    await _loadFirstPage(emit);
  }

  /// Replace the active filter (from the search field or the filter sheet) and
  /// reload from page 1, showing the loader.
  Future<void> _onFilterChanged(
    ProductsFilterChanged event,
    Emitter<ProductsState> emit,
  ) async {
    if (event.filter == state.filter) return;
    emit(state.copyWith(status: ProductsStatus.loading, filter: event.filter));
    await _loadFirstPage(emit);
  }

  Future<void> _loadFirstPage(Emitter<ProductsState> emit) async {
    final result = await _repository.fetchProducts(
      state.filter,
      page: 1,
      perPage: _perPage,
    );
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(
          status: ProductsStatus.success,
          products: data.items,
          page: data.page,
          hasMore: data.hasMore,
        ));
        _seedFavorites(data.items);
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: ProductsStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  Future<void> _onLoadMore(
    ProductsLoadMore event,
    Emitter<ProductsState> emit,
  ) async {
    // Only paginate from a settled list that has a next page.
    if (state.status != ProductsStatus.success ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearLoadMoreError: true));
    final result = await _repository.fetchProducts(
      state.filter,
      page: state.page + 1,
      perPage: _perPage,
    );
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(
          products: [...state.products, ...data.items],
          page: data.page,
          hasMore: data.hasMore,
          isLoadingMore: false,
        ));
        _seedFavorites(data.items);
      case ApiFailure():
        // Keep the list; surface a retry affordance at the bottom.
        emit(state.copyWith(isLoadingMore: false, loadMoreError: true));
    }
  }

  void _seedFavorites(List<HomeProduct> items) {
    _favorites.seed(items.where((p) => p.isFavorite).map((p) => p.id));
  }
}
