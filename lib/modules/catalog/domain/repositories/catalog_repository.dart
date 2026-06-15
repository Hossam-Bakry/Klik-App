import '../../../../core/network/api_result.dart';
import '../entities/product.dart';

/// Contract the presentation layer depends on. Returns an [ApiResult] so the
/// BLoC switches over success/failure instead of try/catch.
abstract class CatalogRepository {
  Future<ApiResult<List<Product>>> getProducts();
}
