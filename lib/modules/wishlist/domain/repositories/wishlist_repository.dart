import '../../../../core/network/api_result.dart';
import '../../../home/domain/entities/home_product.dart';

abstract interface class WishlistRepository {
  /// The signed-in user's favorite products (`GET /api/favorite-products`).
  Future<ApiResult<List<HomeProduct>>> fetchFavorites();
}
