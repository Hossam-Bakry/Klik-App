import '../../network/api_endpoints.dart';
import '../../network/api_interface.dart';
import '../../network/api_result.dart';
import '../domain/cart_merge_strategy.dart';

/// Talks to the cart endpoints needed for the guest-cart merge flow.
///
/// PROVISIONAL: the merge endpoint + payload and the `/carts` count shape were
/// not pinned down against the backend when this was written (cart endpoints
/// are all 🔒 in the Postman collection). [_countFrom] parses defensively so a
/// shape change degrades to a 0/absent count rather than a crash. Reconcile
/// once the backend contract is confirmed.
abstract interface class CartRemoteDataSource {
  Future<ApiResult<int?>> mergeGuestCart({
    required String guestToken,
    required CartMergeStrategy strategy,
  });

  Future<ApiResult<int>> fetchCartCount();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  CartRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<int?>> mergeGuestCart({
    required String guestToken,
    required CartMergeStrategy strategy,
  }) =>
      _api.post(
        ApiEndpoints.cartMerge,
        body: {'guest_token': guestToken, 'strategy': strategy.apiValue},
        decoder: _countFrom,
      );

  @override
  Future<ApiResult<int>> fetchCartCount() => _api.get(
        ApiEndpoints.carts,
        decoder: (data) => _countFrom(data) ?? 0,
      );

  /// Best-effort item count from a variety of plausible payload shapes:
  /// a bare list of items, `{ count | cart_count | total_quantity: n }`, or a
  /// `{ items: [...] }` wrapper. Returns null when none match.
  static int? _countFrom(dynamic data) {
    if (data is List) return data.length;
    if (data is Map) {
      for (final key in ['count', 'cart_count', 'total_quantity', 'quantity']) {
        final value = data[key];
        if (value is num) return value.toInt();
      }
      final items = data['items'] ?? data['carts'] ?? data['data'];
      if (items is List) return items.length;
    }
    return null;
  }
}
