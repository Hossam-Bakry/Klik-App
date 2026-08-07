import '../domain/entities/order_details.dart';

/// What the "Write a Review" route is opened with: the product being rated and
/// the order it came on (`POST /api/product-review` needs both).
class WriteReviewArgs {
  const WriteReviewArgs({
    required this.orderId,
    required this.product,
    this.initialRating,
  });

  final int orderId;
  final OrderLine product;

  /// A star already tapped on the order card, so the page opens on it.
  final int? initialRating;
}
