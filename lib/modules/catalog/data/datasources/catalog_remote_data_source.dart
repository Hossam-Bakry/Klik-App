import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/product_dto.dart';

/// Talks to the network via [ApiInterface] and returns DTOs wrapped in an
/// [ApiResult]. No try/catch here — envelope unwrapping and error mapping live
/// in the API client.
abstract class CatalogRemoteDataSource {
  Future<ApiResult<List<ProductDto>>> fetchProducts();
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  CatalogRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<List<ProductDto>>> fetchProducts() => _api.get(
        ApiEndpoints.products,
        // Demo endpoint returns a bare array (not the { message, data }
        // envelope). Switch to the default once pointed at the real API.
        unwrapEnvelope: false,
        decoder: (data) => (data as List)
            .map((e) => ProductDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
