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

/// Sent an offer from the "Price Negotiate" sheet — POSTs it to `/api/bid`,
/// then reloads the product so the new bid status shows.
class BidSubmitted extends ProductEvent {
  const BidSubmitted({required this.price, this.sizeId, this.colorId});

  final double price;

  /// Selected variant ids, when the product has them (optional on the endpoint).
  final int? sizeId;
  final int? colorId;

  @override
  List<Object?> get props => [price, sizeId, colorId];
}
