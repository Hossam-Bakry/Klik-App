import '../../network/api_endpoints.dart';
import '../../network/api_interface.dart';
import '../../network/api_result.dart';

/// Talks to `/api/favorite-add-or-remove`, which toggles server-side favorite
/// state from a single `product_id` — no response body is needed since the
/// cubit already applied the optimistic flip locally.
abstract interface class FavoritesRemoteDataSource {
  Future<ApiResult<Unit>> toggleFavorite(int productId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  FavoritesRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<Unit>> toggleFavorite(int productId) => _api.post(
    ApiEndpoints.favoriteToggle,
    body: {'product_id': productId},
    decoder: (_) => unit,
  );
}
