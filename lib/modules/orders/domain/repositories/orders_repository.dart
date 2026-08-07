import 'dart:io';

import '../../../../core/network/api_result.dart';
import '../entities/order_details.dart';
import '../entities/order_summary.dart';

abstract interface class OrdersRepository {
  /// The signed-in customer's orders, newest first (`GET /api/orders`).
  Future<ApiResult<List<OrderSummary>>> fetchOrders();

  /// One order in full (`GET /api/order-details?order_id=`).
  Future<ApiResult<OrderDetails>> fetchOrderDetails(int orderId);

  /// Cancels an order the shop hasn't handed over yet
  /// (`POST /api/orders/cancel`).
  Future<ApiResult<Unit>> cancelOrder(int orderId);

  /// Rates one product from a delivered order (`POST /api/product-review`).
  /// The endpoint requires a comment, so [description] is not optional;
  /// [photos] are sent only when the customer attached any.
  Future<ApiResult<Unit>> submitReview({
    required int orderId,
    required int productId,
    required int rating,
    required String description,
    List<File> photos,
  });
}
