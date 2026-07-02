import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../../home/domain/entities/home_product.dart';
import '../models/favorite_products_dto.dart';

abstract interface class WishlistRemoteDataSource {
  Future<ApiResult<List<HomeProduct>>> fetchFavorites();
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  WishlistRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<List<HomeProduct>>> fetchFavorites() => _api.get(
    ApiEndpoints.favoriteProducts,
    // Envelope `data` wraps the list under `products`.
    decoder: (data) => FavoriteProductsDto.listFromJson(data),
  );
}
