import '../../network/api_result.dart';
import '../domain/cart.dart';
import '../domain/cart_item.dart';
import '../domain/cart_repository.dart';
import 'cart_remote_data_source.dart';
import 'local_cart_store.dart';

/// Tells the repository whether there's a session right now — supplied from DI
/// so the cart layer stays decoupled from the auth module.
typedef IsAuthenticated = bool Function();

/// Routes every cart operation by session: a guest's cart is read and written
/// on the device only (no cart API calls at all), a signed-in user's is the
/// server's.
///
/// Either way an operation answers with the whole cart, so the cubit never has
/// to follow a write with a read: the write endpoints echo the same body as
/// `GET /api/carts`, and a local write re-reads the device store.
class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._remote, this._local, this._isAuthenticated);

  final CartRemoteDataSource _remote;
  final LocalCartStore _local;
  final IsAuthenticated _isAuthenticated;

  @override
  List<CartItem> get localItems => _local.items;

  @override
  Future<void> clearLocal() => _local.clear();

  @override
  Future<ApiResult<Cart>> fetchCart() async =>
      _isAuthenticated() ? _remote.fetchCart() : _localCart();

  @override
  Future<ApiResult<Cart>> addItem(CartItem item) async {
    if (_isAuthenticated()) return _remote.store(item);

    final items = [..._local.items];
    final i = items.indexWhere((e) => e.sameLineAs(item));
    if (i >= 0) {
      // Same product and variant: top up the existing line rather than adding a
      // second row for it.
      items[i] = items[i].copyWith(quantity: items[i].quantity + item.quantity);
    } else {
      items.add(item);
    }
    return _saveLocal(items);
  }

  @override
  Future<ApiResult<Cart>> increment(CartItem item) async =>
      _isAuthenticated()
      ? _remote.increment(item)
      : _updateLocalQuantity(item, (q) => q + 1);

  @override
  Future<ApiResult<Cart>> decrement(CartItem item) async =>
      _isAuthenticated()
      ? _remote.decrement(item)
      // Stepping below 1 drops the line — the design has no zero-quantity row.
      : _updateLocalQuantity(item, (q) => q - 1);

  @override
  Future<ApiResult<Cart>> removeItem(CartItem item) async {
    if (_isAuthenticated()) return _remote.delete(item);
    return _saveLocal(_local.items.where((e) => !e.sameLineAs(item)).toList());
  }

  @override
  Future<ApiResult<Cart>> mergeGuestCart(List<CartItem> items) =>
      _remote.merge(items);

  Future<ApiResult<Cart>> _updateLocalQuantity(
    CartItem item,
    int Function(int quantity) next,
  ) async {
    final items = [..._local.items];
    final i = items.indexWhere((e) => e.sameLineAs(item));
    if (i < 0) return _localCart();

    final quantity = next(items[i].quantity);
    if (quantity <= 0) {
      items.removeAt(i);
    } else {
      items[i] = items[i].copyWith(quantity: quantity);
    }
    return _saveLocal(items);
  }

  Future<ApiResult<Cart>> _saveLocal(List<CartItem> items) async {
    await _local.save(items);
    return _localCart();
  }

  /// Local writes can't fail the way a request can, so they always come back as
  /// a success carrying the new cart.
  ApiResult<Cart> _localCart() => ApiSuccess(Cart(items: _local.items));
}
