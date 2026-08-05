import '../../network/api_result.dart';
import 'cart_merge_strategy.dart';

/// Server-side cart operations the app-wide [CartCountCubit] needs. The full
/// cart module (line items, checkout) will layer on top of this later; for now
/// it covers the guest-cart merge and reading the authenticated cart's count.
abstract interface class CartRepository {
  /// Hands the backend the guest [guestToken] so it can fold that cart into the
  /// now-authenticated user's cart, per [strategy]. Returns the resulting item
  /// count when the backend reports one, otherwise null.
  Future<ApiResult<int?>> mergeGuestCart({
    required String guestToken,
    required CartMergeStrategy strategy,
  });

  /// Total item count in the authenticated user's cart (for the badge).
  Future<ApiResult<int>> fetchCartCount();
}
