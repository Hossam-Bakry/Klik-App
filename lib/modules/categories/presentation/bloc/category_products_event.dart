part of 'category_products_bloc.dart';

sealed class CategoryProductsEvent extends Equatable {
  const CategoryProductsEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load of the category's products.
class CategoryProductsRequested extends CategoryProductsEvent {
  const CategoryProductsRequested(this.categoryId);

  final int categoryId;

  @override
  List<Object?> get props => [categoryId];
}

/// Pull-to-refresh — re-fetches without showing the full-screen loader.
class CategoryProductsRefreshed extends CategoryProductsEvent {
  const CategoryProductsRefreshed(this.categoryId);

  final int categoryId;

  @override
  List<Object?> get props => [categoryId];
}
