part of 'product_bloc.dart';

enum ProductStatus { initial, loading, success, failure }

/// Single state object with a [status] enum (same pattern as HomeBloc). The UI
/// switches on [status] and reads [product]/[errorMessage] as needed.
class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.initial,
    this.product,
    this.errorMessage,
  });

  final ProductStatus status;
  final ProductDetails? product;
  final String? errorMessage;

  bool get isLoading =>
      status == ProductStatus.initial || status == ProductStatus.loading;

  ProductState copyWith({
    ProductStatus? status,
    ProductDetails? product,
    String? errorMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      product: product ?? this.product,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, product, errorMessage];
}
