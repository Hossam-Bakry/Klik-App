import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/product_details.dart';
import '../models/product_details_dto.dart';

/// Talks to `/api/product-details` via [ApiInterface]. No try/catch here —
/// envelope unwrapping and error mapping live in the API client.
abstract interface class ProductRemoteDataSource {
  Future<ApiResult<ProductDetails>> fetchProductDetails(int productId);
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
}
