import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/favorites/presentation/favorites_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../../home/domain/entities/home_product.dart';
import '../../domain/repositories/categories_repository.dart';

part 'category_products_event.dart';
part 'category_products_state.dart';

/// Products for a single (leaf) category, reached when a tapped category has
/// no subcategories.
class CategoryProductsBloc
    extends Bloc<CategoryProductsEvent, CategoryProductsState> {
  CategoryProductsBloc(this._repository, this._favorites)
      : super(const CategoryProductsState()) {
    on<CategoryProductsRequested>(_onRequested);
    on<CategoryProductsRefreshed>(_onRefreshed);
  }

  final CategoriesRepository _repository;
  final FavoritesCubit _favorites;

  Future<void> _onRequested(
    CategoryProductsRequested event,
    Emitter<CategoryProductsState> emit,
  ) async {
    emit(state.copyWith(status: CategoryProductsStatus.loading));
    await _load(emit, event.categoryId);
  }

  Future<void> _onRefreshed(
    CategoryProductsRefreshed event,
    Emitter<CategoryProductsState> emit,
  ) async {
    await _load(emit, event.categoryId);
  }

  Future<void> _load(
    Emitter<CategoryProductsState> emit,
    int categoryId,
  ) async {
    final result = await _repository.fetchCategoryProducts(categoryId);
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(
          status: CategoryProductsStatus.success,
          products: data,
        ));
        _favorites.seed(
          data.where((p) => p.isFavorite).map((p) => p.id),
        );
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: CategoryProductsStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }
}
