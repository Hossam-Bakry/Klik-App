import '../../network/api_result.dart';
import 'cart.dart';
import 'cart_item.dart';

/// Cart operations, independent of where the cart lives.
///
/// The implementation routes each call by session: a guest's cart is kept on
/// the device and never hits the network, while a signed-in user's cart is the
/// server's (`/api/carts`, `/api/cart/store`, …). [mergeGuestCart] is the one
/// bridge between the two, run once at sign-in.
abstract interface class CartRepository {
  /// The current cart — local for a guest, `GET /api/carts` once signed in.
  Future<ApiResult<Cart>> fetchCart();

  /// Adds [item], or bumps its quantity when the same product+variant is
  /// already in the cart. Returns the resulting cart.
  Future<ApiResult<Cart>> addItem(CartItem item);

  Future<ApiResult<Cart>> increment(CartItem item);

  Future<ApiResult<Cart>> decrement(CartItem item);

  Future<ApiResult<Cart>> removeItem(CartItem item);

  /// `POST /api/cart/merge` — hands the locally-held guest lines to the backend
  /// right after sign-in. Returns the account's resulting cart.
  Future<ApiResult<Cart>> mergeGuestCart(List<CartItem> items);

  /// The guest lines currently on the device (empty once merged, or while
  /// signed in).
  List<CartItem> get localItems;

  /// Wipes the device-side cart. Called once the server has taken ownership.
  Future<void> clearLocal();
}
