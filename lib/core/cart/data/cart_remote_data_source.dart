import '../../network/api_endpoints.dart';
import '../../network/api_interface.dart';
import '../../network/api_result.dart';
import '../domain/cart.dart';
import '../domain/cart_item.dart';
import 'cart_dto.dart';

/// The authenticated cart endpoints. Only reached once the user is signed in —
/// a guest's cart never leaves the device.
abstract interface class CartRemoteDataSource {
  Future<ApiResult<Cart>> fetchCart();

  Future<ApiResult<Cart>> store(CartItem item);

  Future<ApiResult<Cart>> increment(CartItem item);

  Future<ApiResult<Cart>> decrement(CartItem item);

  Future<ApiResult<Cart>> delete(CartItem item);

  Future<ApiResult<Cart>> merge(List<CartItem> items);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  CartRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<Cart>> fetchCart() =>
      _api.get(ApiEndpoints.carts, decoder: CartDto.fromJson);

  @override
  Future<ApiResult<Cart>> store(CartItem item) => _api.post(
    ApiEndpoints.cartStore,
    body: _lineBody(item),
    decoder: CartDto.fromJson,
  );

  @override
  Future<ApiResult<Cart>> increment(CartItem item) => _api.post(
    ApiEndpoints.cartIncrement,
    body: _rowBody(item),
    decoder: CartDto.fromJson,
  );

  @override
  Future<ApiResult<Cart>> decrement(CartItem item) => _api.post(
    ApiEndpoints.cartDecrement,
    body: _rowBody(item),
    decoder: CartDto.fromJson,
  );

  @override
  Future<ApiResult<Cart>> delete(CartItem item) => _api.post(
    ApiEndpoints.cartDelete,
    body: _rowBody(item),
    decoder: CartDto.fromJson,
  );

  /// `POST /api/cart/merge` — body is `{ items: [ { product_id, quantity,
  /// size, color, unit } ] }`, exactly the guest lines held on the device.
  @override
  Future<ApiResult<Cart>> merge(List<CartItem> items) => _api.post(
    ApiEndpoints.cartMerge,
    body: {'items': items.map(_lineBody).toList()},
    decoder: CartDto.fromJson,
  );

  /// A cart line as the store/merge payloads describe it. Null-aware entries
  /// keep `size`/`color` out of the body on products without variants.
  static Map<String, dynamic> _lineBody(CartItem item) => {
    'product_id': item.productId,
    'quantity': item.quantity,
    'size': ?item.sizeId,
    'color': ?item.colorId,
    if (item.unit.isNotEmpty) 'unit': item.unit,
  };

  /// Identifies an existing line for increment/decrement/delete. All three
  /// resolve it by `product_id` (they reject a body without one); the variant
  /// rides along so the backend can pick the exact line on a product that has
  /// several. Decrementing the last unit removes the line server-side, same as
  /// the local store does.
  static Map<String, dynamic> _rowBody(CartItem item) => {
    'product_id': item.productId,
    'size': ?item.sizeId,
    'color': ?item.colorId,
  };
}
