import 'dart:io';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/order_details.dart';
import '../../domain/entities/order_summary.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

/// The payloads are already mapped to domain entities by `OrdersDto`, so this
/// is a thin pass-through — kept as a seam for caching later.
class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._remote);

  final OrdersRemoteDataSource _remote;

  @override
  Future<ApiResult<List<OrderSummary>>> fetchOrders() => _remote.fetchOrders();

  @override
  Future<ApiResult<OrderDetails>> fetchOrderDetails(int orderId) =>
      _remote.fetchOrderDetails(orderId);

  @override
  Future<ApiResult<Unit>> cancelOrder(int orderId) =>
      _remote.cancelOrder(orderId);

  @override
  Future<ApiResult<Unit>> submitReview({
    required int orderId,
    required int productId,
    required int rating,
    required String description,
    List<File> photos = const [],
  }) => _remote.submitReview(
    orderId: orderId,
    productId: productId,
    rating: rating,
    description: description,
    photos: photos,
  );
}
