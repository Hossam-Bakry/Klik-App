part of 'products_bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load with the entry-point [filter] (shop/category/best-for-you).
class ProductsStarted extends ProductsEvent {
  const ProductsStarted(this.filter);

  final ProductsFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Pull-to-refresh — reloads page 1 with the current filter.
class ProductsRefreshed extends ProductsEvent {
  const ProductsRefreshed();
}

/// Reached the end of the list — append the next page.
class ProductsLoadMore extends ProductsEvent {
  const ProductsLoadMore();
}

/// The search text or filter-sheet selections changed — re-query from page 1.
class ProductsFilterChanged extends ProductsEvent {
  const ProductsFilterChanged(this.filter);

  final ProductsFilter filter;

  @override
  List<Object?> get props => [filter];
}
