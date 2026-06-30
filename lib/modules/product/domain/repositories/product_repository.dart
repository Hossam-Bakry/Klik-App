import '../../../../core/network/api_result.dart';
import '../entities/product_details.dart';

/// Contract the presentation layer depends on. Returns an [ApiResult] so the
/// BLoC switches over success/failure instead of try/catch.
abstract interface class ProductRepository {
  Future<ApiResult<ProductDetails>> getProductDetails(int productId);
}
