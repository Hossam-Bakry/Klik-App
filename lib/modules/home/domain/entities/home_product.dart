import 'package:equatable/equatable.dart';

/// A product as it appears on the home feed (Just-for-you, Open-to-offers,
/// popular …). Pure domain — no JSON. Mapped from the API's product shape.
class HomeProduct extends Equatable {
  const HomeProduct({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.price,
    required this.discountPrice,
    required this.discountPercentage,
    required this.rating,
    required this.totalSold,
    required this.quantity,
    required this.isFavorite,
    required this.isBidable,
    required this.shopName,
    required this.estimatedDeliveryTime,
  });

  final int id;
  final String name;
  final String thumbnail;

  /// Original price.
  final double price;

  /// Final price after discount; `0` when there's no discount.
  final double discountPrice;
  final double discountPercentage;

  final double rating;
  final int totalSold;
  final int quantity;
  final bool isFavorite;

  /// Whether the seller accepts offers (drives the "Negotiate" affordance).
  final bool isBidable;

  final String shopName;

  /// Estimated delivery time in days (as the API returns it), e.g. "2".
  final String estimatedDeliveryTime;

  /// Whether a discount is active — used by the UI to show the struck-through
  /// original price and the percentage badge.
  bool get hasDiscount => discountPercentage > 0 && discountPrice > 0;

  /// The price the customer actually pays.
  double get effectivePrice => hasDiscount ? discountPrice : price;

  @override
  List<Object?> get props => [id, name, price, discountPrice, isBidable];
}
