import '../domain/cart.dart';
import '../domain/cart_item.dart';

/// Parses the authenticated cart payload into a [Cart].
///
/// Every cart endpoint — `GET /api/carts` and the `/cart/store` ·
/// `increment` · `decrement` · `delete` writes — answers with the same
/// (unwrapped) body:
///
/// ```json
/// { "total": 5,
///   "cart_items": [
///     { "shop_id": 1, "shop_name": "…", "shop_logo": "…", "shop_rating": 0.0,
///       "products": [
///         { "id": 108, "quantity": 3, "stock": 97, "name": "…",
///           "thumbnail": "…", "price": 10.0, "discount_price": 0.0,
///           "color": { "id": 4, … } | null, "size": { "id": 3, … } | null,
///           "unit": null } ] } ] }
/// ```
///
/// Two things to know about it: the lines are grouped by shop (the cart screen
/// renders one flat list, so they're flattened here), and `total` counts lines
/// rather than money — the cart adds up its own lines instead.
class CartDto {
  const CartDto._();

  static Cart fromJson(Object? data) {
    final groups = data is Map ? data['cart_items'] : null;
    if (groups is! List) return Cart.empty;

    return Cart(
      items: [
        for (final group in groups.whereType<Map>())
          if (group[_K.products] case final List lines)
            for (final line in lines.whereType<Map>())
              _itemFromJson(line.cast<String, dynamic>()),
      ],
    );
  }

  /// One cart line. `id` on it is the *product's* id — the cart has no row id
  /// of its own, and every write endpoint keys on `product_id`.
  static CartItem _itemFromJson(Map<String, dynamic> json) {
    final price = _toDouble(json[_K.price]);
    final discount = _toDouble(json[_K.discountPrice]);
    // Same rule as the product screen: a discount counts only when it's a real
    // reduction, and then it's the price actually charged.
    final discounted = discount > 0 && discount < price;

    return CartItem(
      productId: _toInt(json[_K.id]),
      name: _str(json[_K.name]),
      thumbnail: _str(json[_K.thumbnail]),
      price: discounted ? discount : price,
      originalPrice: discounted ? price : 0,
      // A line always has at least one unit; don't let a missing quantity
      // silently drop it out of the badge count.
      quantity: _toInt(json[_K.quantity]).clamp(1, 1 << 31),
      sizeId: _variantId(json[_K.size]),
      colorId: _variantId(json[_K.color]),
      unit: _str(json[_K.unit]),
    );
  }

  /// `size` / `color` come back as objects (`{ id, name, … }`), null on a
  /// product that doesn't vary by that axis.
  static int? _variantId(Object? value) =>
      value is Map ? _toNullableInt(value[_K.id]) : _toNullableInt(value);

  static String _str(Object? v) => v?.toString().trim() ?? '';

  static double _toDouble(Object? v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  static int _toInt(Object? v) => switch (v) {
    num n => n.toInt(),
    String s => int.tryParse(s) ?? 0,
    _ => 0,
  };

  static int? _toNullableInt(Object? v) => switch (v) {
    num n => n.toInt(),
    String s => int.tryParse(s),
    _ => null,
  };
}

class _K {
  static const products = 'products';
  static const id = 'id';
  static const name = 'name';
  static const thumbnail = 'thumbnail';
  static const price = 'price';
  static const discountPrice = 'discount_price';
  static const quantity = 'quantity';
  static const size = 'size';
  static const color = 'color';
  static const unit = 'unit';
}
