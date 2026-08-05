import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/product_details.dart';
import '../models/product_details_dto.dart';

/// Talks to `/api/product-details` and `/api/bid` via [ApiInterface]. No
/// try/catch here — envelope unwrapping and error mapping live in the API
/// client.
abstract interface class ProductRemoteDataSource {
  Future<ApiResult<ProductDetails>> fetchProductDetails(int productId);

  /// Places a negotiation offer. [sizeId]/[colorId] are the selected variant
  /// ids and are optional per the endpoint.
  Future<ApiResult<Unit>> createBid({
    required int productId,
    required double price,
    int? sizeId,
    int? colorId,
  });
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<ProductDetails>> fetchProductDetails(
    int productId,
  ) => _api.get(
    ApiEndpoints.productDetails,
    query: {'product_id': productId},
    // Standard { message, data } envelope; client unwraps `data`. The `data`
    // object wraps the product under `product` alongside sibling
    // `related_products`/`popular_products`, so hand the whole object to the
    // DTO rather than narrowing to `product`.
    decoder: (data) => ProductDetailsDto.fromJson(data as Map<String, dynamic>),
  );

  @override
  Future<ApiResult<Unit>> createBid({
    required int productId,
    required double price,
    int? sizeId,
    int? colorId,
  }) => _api.post(
    ApiEndpoints.bids,
    body: {
      'product_id': productId,
      // Whole amounts go up as integers so the body reads 750, not 750.0.
      'bid_price_customer': price % 1 == 0 ? price.toInt() : price,
      // Null-aware entries: only sent when a variant is selected.
      'size': ?sizeId,
      'color': ?colorId,
    },
    // The created bid isn't consumed: the page refetches product-details to
    // pick up the new status, so only success/failure matters here.
    decoder: (_) => unit,
  );
}
