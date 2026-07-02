import '../../../../core/network/api_result.dart';
import '../../../home/domain/entities/home_product.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_data_source.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl(this._remote);

  final WishlistRemoteDataSource _remote;

  @override
  Future<ApiResult<List<HomeProduct>>> fetchFavorites() =>
      _remote.fetchFavorites();
}
