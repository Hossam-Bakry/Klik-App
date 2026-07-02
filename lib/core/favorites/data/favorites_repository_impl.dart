import '../../network/api_result.dart';
import '../domain/favorites_repository.dart';
import 'favorites_remote_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._remote);

  final FavoritesRemoteDataSource _remote;

  @override
  Future<ApiResult<Unit>> toggle(int productId) =>
      _remote.toggleFavorite(productId);
}
