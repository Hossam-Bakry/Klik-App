part of 'category_products_bloc.dart';

enum CategoryProductsStatus { initial, loading, success, failure }

class CategoryProductsState extends Equatable {
  const CategoryProductsState({
    this.status = CategoryProductsStatus.initial,
    this.products = const [],
    this.errorMessage,
  });

  final CategoryProductsStatus status;
  final List<HomeProduct> products;
  final String? errorMessage;

  CategoryProductsState copyWith({
    CategoryProductsStatus? status,
    List<HomeProduct>? products,
    String? errorMessage,
  }) {
    return CategoryProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, products, errorMessage];
}
