import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/home_product.dart';
import 'product_color_option.dart';
import 'product_review.dart';

/// Full product detail shown on the product page (image gallery, variants,
/// description, reviews and a "Similar products" rail). Pure domain — mapped
/// from the `GET /api/product-details` response by `ProductDetailsDto`.
///
/// Similar products reuse [HomeProduct] since they render with the same card
/// as the home feed.
class ProductDetails extends Equatable {
  const ProductDetails({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.images,
    required this.price,
    required this.discountPrice,
    required this.discountPercentage,
    required this.rating,
    required this.totalSold,
    required this.quantity,
    required this.estimatedDeliveryTime,
    required this.isFavorite,
    required this.isBidable,
    required this.colors,
    required this.sizes,
    required this.reviews,
    required this.similarProducts,
  });

  final int id;
  final String name;

  /// Short tagline under the title, e.g. "Wireless Noise Canceling headphone".
  final String subtitle;

  /// Long "About product" copy.
  final String description;

  /// Gallery image URLs (first one is the primary thumbnail).
  final List<String> images;

  /// Original price.
  final double price;

  /// Final price after discount; `0` when there's no discount.
  final double discountPrice;
  final double discountPercentage;

  final double rating;
  final int totalSold;

  /// Units in stock. `0` (or less) means the product can't be ordered.
  final int quantity;

  /// Estimated delivery time in days, as the API returns it (e.g. "2").
  final String estimatedDeliveryTime;

  final bool isFavorite;

  /// Whether the seller accepts offers (drives the "Negotiate" affordance).
  final bool isBidable;

  final List<ProductColorOption> colors;

  /// Variant labels (e.g. storage sizes "128GB").
  final List<String> sizes;

  final List<ProductReview> reviews;
  final List<HomeProduct> similarProducts;

  /// Whether a discount is active — drives the struck-through original price and
  /// the percentage badge.
  bool get hasDiscount => discountPercentage > 0 && discountPrice > 0;

  /// The price the customer actually pays.
  double get effectivePrice => hasDiscount ? discountPrice : price;

  /// No units available — the CTAs are replaced by an "Out of Stock" banner.
  bool get isOutOfStock => quantity <= 0;

  @override
  List<Object?> get props => [id, name, price, discountPrice, isFavorite, isBidable];
}
