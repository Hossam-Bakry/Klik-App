import '../../../../core/cart/domain/cart_item.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../domain/entities/placed_order.dart';
import '../models/checkout_dto.dart';

abstract interface class CheckoutRemoteDataSource {
  Future<ApiResult<CheckoutSummary>> fetchSummary();

  Future<ApiResult<double>> applyCoupon({
    required String code,
    required List<CartItem> lines,
  });

  Future<ApiResult<PlacedOrder>> placeOrder({
    required List<int> shopIds,
    required int addressId,
  });
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  CheckoutRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<CheckoutSummary>> fetchSummary() => _api.post(
    ApiEndpoints.cartCheckout,
    body: const <String, dynamic>{},
    decoder: CheckoutDto.summaryFromJson,
  );

  /// The coupon endpoint wants each line as `{ id, quantity, shop_id }` — it
  /// rejects the payload outright without all three.
  @override
  Future<ApiResult<double>> applyCoupon({
    required String code,
    required List<CartItem> lines,
  }) => _api.post(
    ApiEndpoints.couponsApply,
    body: {
      'coupon_code': code,
      'products': [
        for (final line in lines)
          {
            'id': line.productId,
            'quantity': line.quantity,
            'shop_id': line.shopId,
          },
      ],
    },
    decoder: CheckoutDto.couponDiscountFromJson,
  );

  /// `shop_ids` + `address_id` are the only fields it requires — payment isn't
  /// part of the call.
  @override
  Future<ApiResult<PlacedOrder>> placeOrder({
    required List<int> shopIds,
    required int addressId,
  }) => _api.post(
    ApiEndpoints.placeOrder,
    body: {'shop_ids': shopIds, 'address_id': addressId},
    decoder: CheckoutDto.placedOrderFromJson,
  );
}
