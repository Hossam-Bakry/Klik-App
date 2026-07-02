import '../../../../core/network/api_result.dart';
import '../entities/products_filter.dart';
import '../entities/products_page.dart';

abstract interface class ProductsRepository {
  /// Fetches one page of products matching [filter].
  Future<ApiResult<ProductsPage>> fetchProducts(
    ProductsFilter filter, {
    required int page,
    required int perPage,
  });
}
