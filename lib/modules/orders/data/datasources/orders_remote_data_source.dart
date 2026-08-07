import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/order_details.dart';
import '../../domain/entities/order_summary.dart';
import '../models/orders_dto.dart';

abstract interface class OrdersRemoteDataSource {
  Future<ApiResult<List<OrderSummary>>> fetchOrders();

  Future<ApiResult<OrderDetails>> fetchOrderDetails(int orderId);

  Future<ApiResult<Unit>> cancelOrder(int orderId);

  Future<ApiResult<Unit>> submitReview({
    required int orderId,
    required int productId,
    required int rating,
    required String description,
    List<File> photos,
  });
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  OrdersRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  /// One page big enough to hold a customer's history, because the screen's
  /// status chips, search and date window all filter client-side — a second
  /// page would leave those looking at a partial list. Wire real pagination
  /// here (`page`) if order counts ever outgrow it.
  static const int _pageSize = 100;

  @override
  Future<ApiResult<List<OrderSummary>>> fetchOrders() => _api.get(
    ApiEndpoints.orders,
    query: const {'page': 1, 'per_page': _pageSize},
    decoder: OrdersDto.listFromJson,
  );

  @override
  Future<ApiResult<OrderDetails>> fetchOrderDetails(int orderId) => _api.get(
    ApiEndpoints.orderDetails,
    query: {'order_id': orderId},
    decoder: OrdersDto.detailsFromJson,
  );

  @override
  Future<ApiResult<Unit>> cancelOrder(int orderId) => _api.post(
    ApiEndpoints.cancelOrder,
    body: {'order_id': orderId},
    decoder: (_) => unit,
  );

  /// The four text fields are all required. Photos are sent as multipart
  /// `images[]` only when the customer attached some — the endpoint parses
  /// multipart fine and ignores unknown fields, so a review still posts even if
  /// the backend doesn't take images yet.
  ///
  /// PROVISIONAL: `images[]` is a guess. Nothing in the API documents a photo
  /// field, and the endpoint neither validates nor echoes one back, so there's
  /// no way to confirm the name from the client. Reconcile with the backend.
  @override
  Future<ApiResult<Unit>> submitReview({
    required int orderId,
    required int productId,
    required int rating,
    required String description,
    List<File> photos = const [],
  }) async {
    final fields = <String, dynamic>{
      'order_id': orderId,
      'product_id': productId,
      'rating': rating,
      'description': description,
    };

    final Object body = photos.isEmpty
        ? fields
        : FormData.fromMap({
            ...fields,
            'images[]': [
              for (final photo in photos)
                await MultipartFile.fromFile(
                  photo.path,
                  filename: photo.uri.pathSegments.last,
                ),
            ],
          });

    return _api.post(
      ApiEndpoints.productReview,
      body: body,
      decoder: (_) => unit,
    );
  }
}
