import '../../../../core/network/api_result.dart';
import '../entities/product_details.dart';

/// Contract the presentation layer depends on. Returns an [ApiResult] so the
/// BLoC switches over success/failure instead of try/catch.
abstract interface class ProductRepository {
  Future<ApiResult<ProductDetails>> getProductDetails(int productId);

  /// Places a negotiation offer on a bidable product (`POST /api/bid`).
  Future<ApiResult<Unit>> placeBid({
    required int productId,
    required double price,
    int? sizeId,
    int? colorId,
  });
}
