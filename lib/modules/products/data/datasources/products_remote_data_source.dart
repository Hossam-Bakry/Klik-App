import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/products_filter.dart';
import '../../domain/entities/products_page.dart';
import '../models/product_list_dto.dart';

abstract interface class ProductsRemoteDataSource {
  Future<ApiResult<ProductsPage>> fetchProducts(
    ProductsFilter filter, {
    required int page,
    required int perPage,
  });
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  ProductsRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<ProductsPage>> fetchProducts(
    ProductsFilter filter, {
    required int page,
    required int perPage,
  }) => _api.get(
    ApiEndpoints.products,
    query: {'page': page, 'per_page': perPage, ...filter.toQuery()},
    decoder: (data) =>
        ProductListDto.fromJson(data, requestedPage: page, perPage: perPage),
  );
}
