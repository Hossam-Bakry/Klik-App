part of 'products_bloc.dart';

enum ProductsStatus { initial, loading, success, failure }

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.initial,
    this.filter = const ProductsFilter(),
    this.products = const [],
    this.categories = const [],
    this.brands = const [],
    this.page = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreError = false,
    this.errorMessage,
  });

  final ProductsStatus status;

  /// The active query (identity filters + search + sheet refinements).
  final ProductsFilter filter;

  final List<HomeProduct> products;

  /// Filter sheet options, loaded once after the first page.
  final List<Category> categories;
  final List<Brand> brands;

  /// Last successfully loaded page (0 before the first load).
  final int page;

  /// Whether another page can be requested.
  final bool hasMore;

  /// True while appending the next page (drives the bottom spinner).
  final bool isLoadingMore;

  /// True when the last load-more attempt failed (drives a bottom retry row).
  final bool loadMoreError;

  final String? errorMessage;

  bool get isLoading =>
      status == ProductsStatus.initial || status == ProductsStatus.loading;

  ProductsState copyWith({
    ProductsStatus? status,
    ProductsFilter? filter,
    List<HomeProduct>? products,
    List<Category>? categories,
    List<Brand>? brands,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreError,
    bool clearLoadMoreError = false,
    String? errorMessage,
  }) {
    return ProductsState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: clearLoadMoreError ? false : (loadMoreError ?? this.loadMoreError),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    filter,
    products,
    categories,
    brands,
    page,
    hasMore,
    isLoadingMore,
    loadMoreError,
    errorMessage,
  ];
}
