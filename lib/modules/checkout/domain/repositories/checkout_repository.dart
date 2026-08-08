import '../../../../core/cart/domain/cart_item.dart';
import '../../../../core/network/api_result.dart';
import '../entities/checkout_summary.dart';
import '../entities/placed_order.dart';

abstract interface class CheckoutRepository {
  /// What the cart comes to (`POST /api/cart/checkout`).
  Future<ApiResult<CheckoutSummary>> fetchSummary();

  /// Tries a coupon against the cart's lines (`POST /api/coupons/apply`).
  /// Answers with the discount it earned — zero when the coupon was refused,
  /// with the server's reason as the failure message.
  Future<ApiResult<double>> applyCoupon({
    required String code,
    required List<CartItem> lines,
  });

  /// Places the cart (`POST /api/place-order`). One order per shop, so the
  /// whole cart's [shopIds] go in one call.
  Future<ApiResult<PlacedOrder>> placeOrder({
    required List<int> shopIds,
    required int addressId,
  });

  /// The newest order on the account (`GET /api/orders`), used to fill in the
  /// confirmation that `place-order` leaves blank.
  Future<ApiResult<PlacedOrder>> fetchLatestOrder();
}
