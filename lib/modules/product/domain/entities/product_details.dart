import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/home_product.dart';
import 'product_bid.dart';
import 'product_color_option.dart';
import 'product_review.dart';
import 'product_size_option.dart';

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
    this.bid,
    this.bidVariants = const [],
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

  /// Variant chips (e.g. storage sizes "128GB").
  final List<ProductSizeOption> sizes;

  final List<ProductReview> reviews;
  final List<HomeProduct> similarProducts;

  /// The customer's own negotiation on the server-selected variant (the default
  /// shown before any pick), when [isBidable] and the API reported one.
  final ProductBid? bid;

  /// Every bidable variant, so the bid state (suggested offer, floor, status)
  /// can follow the customer's size/colour pick — see [bidForVariant]. Empty
  /// when the product carries no negotiation data.
  final List<ProductBid> bidVariants;

  /// A dummy product used to lay out skeleton bones while the real one loads
  /// (same trick as `HomeFeed.placeholder`). Every optional section is filled
  /// in so the bones cover the whole page.
  factory ProductDetails.placeholder() {
    return ProductDetails(
      id: 0,
      name: 'Samsung washing machine',
      subtitle: 'Wireless Noise Canceling headphone',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
          'eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim '
          'ad minim veniam, quis nostrud exercitation ullamco laboris.',
      images: const [''],
      price: 22,
      discountPrice: 19,
      discountPercentage: 20,
      rating: 4.5,
      totalSold: 113,
      quantity: 1,
      estimatedDeliveryTime: '2 days',
      isFavorite: false,
      isBidable: false,
      colors: List.generate(
        4,
        (i) => const ProductColorOption(name: 'Color', hex: '#CCCCCC'),
      ),
      sizes: List.generate(
        3,
        (i) => const ProductSizeOption(label: '128GB'),
      ),
      reviews: List.generate(
        2,
        (i) => const ProductReview(
          id: 0,
          authorName: 'Customer name',
          avatar: '',
          rating: 4.5,
          comment: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          date: '2024-06-30',
        ),
      ),
      similarProducts: List.generate(
        4,
        (i) => const HomeProduct(
          id: 0,
          name: 'Samsung washing machine',
          thumbnail: '',
          price: 22,
          discountPrice: 19,
          discountPercentage: 20,
          rating: 4.5,
          totalSold: 113,
          quantity: 1,
          isFavorite: false,
          isBidable: false,
          shopName: 'Klik Store',
          estimatedDeliveryTime: '2',
        ),
      ),
    );
  }

  /// Whether a discount is active — drives the struck-through original price and
  /// the percentage badge.
  bool get hasDiscount => discountPercentage > 0 && discountPrice > 0;

  /// The price the customer actually pays. An accepted offer wins over the
  /// listed (discounted) price while it holds.
  double get effectivePrice {
    final accepted = bid?.isApproved == true ? bid!.acceptedPrice : null;
    if (accepted != null && accepted > 0) return accepted;
    return hasDiscount ? discountPrice : price;
  }

  /// No units available — the CTAs are replaced by an "Out of Stock" banner.
  bool get isOutOfStock => quantity <= 0;

  /// The bid for the variant matching the customer's [sizeId]/[colorId] pick
  /// (variants are keyed `size_id:color_id`), so the suggested offer, floor and
  /// status track the selection. Falls back to the server-selected [bid] when
  /// there are no variants or the exact combination isn't bidable.
  ProductBid? bidForVariant({int? sizeId, int? colorId}) {
    if (bidVariants.isEmpty) return bid;
    for (final v in bidVariants) {
      if (v.sizeId == sizeId && v.colorId == colorId) return v;
    }
    return bid;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    discountPrice,
    isFavorite,
    isBidable,
    bid,
    bidVariants,
  ];
}
