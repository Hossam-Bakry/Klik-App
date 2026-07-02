import '../../network/api_result.dart';

/// Persists the favorite toggle server-side. The cubit owns the optimistic
/// local state — this only talks to the endpoint.
abstract interface class FavoritesRepository {
  Future<ApiResult<Unit>> toggle(int productId);
}
