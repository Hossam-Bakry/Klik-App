part of 'product_bloc.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the details for [productId].
class ProductDetailsRequested extends ProductEvent {
  const ProductDetailsRequested(this.productId);

  final int productId;

  @override
  List<Object?> get props => [productId];
}
