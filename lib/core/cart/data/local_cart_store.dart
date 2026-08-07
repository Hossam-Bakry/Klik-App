import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/cart_item.dart';

/// The guest cart, kept entirely on the device.
///
/// While signed out there are no cart API calls at all, so the lines have to
/// carry their own display data (name, thumbnail, price) — the cart screen has
/// nothing else to render from. Stored as a JSON array in [SharedPreferences]
/// so it survives a restart and can be read synchronously.
///
/// Cleared once `POST /api/cart/merge` has handed the lines to the account.
class LocalCartStore {
  LocalCartStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _itemsKey = 'guest_cart_items';

  /// The stored lines, oldest first. Returns empty on anything unreadable
  /// rather than throwing — a corrupt cart shouldn't brick the app.
  List<CartItem> get items {
    final raw = _prefs.getString(_itemsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => _fromJson(e.cast<String, dynamic>()))
          .toList();
    } on FormatException {
      return const [];
    }
  }

  Future<void> save(List<CartItem> items) => items.isEmpty
      ? _prefs.remove(_itemsKey)
      : _prefs.setString(
          _itemsKey,
          jsonEncode(items.map(_toJson).toList()),
        );

  Future<void> clear() => _prefs.remove(_itemsKey);

  static Map<String, dynamic> _toJson(CartItem item) => {
    'product_id': item.productId,
    'shop_id': item.shopId,
    'name': item.name,
    'thumbnail': item.thumbnail,
    'price': item.price,
    'original_price': item.originalPrice,
    'quantity': item.quantity,
    'size': item.sizeId,
    'color': item.colorId,
    'unit': item.unit,
  };

  static CartItem _fromJson(Map<String, dynamic> json) => CartItem(
    productId: _toInt(json['product_id']),
    shopId: _toInt(json['shop_id']),
    name: json['name']?.toString() ?? '',
    thumbnail: json['thumbnail']?.toString() ?? '',
    price: _toDouble(json['price']),
    originalPrice: _toDouble(json['original_price']),
    quantity: _toInt(json['quantity']),
    sizeId: _toNullableInt(json['size']),
    colorId: _toNullableInt(json['color']),
    unit: json['unit']?.toString() ?? '',
  );

  static int _toInt(Object? v) => v is num ? v.toInt() : 0;

  static int? _toNullableInt(Object? v) => v is num ? v.toInt() : null;

  static double _toDouble(Object? v) => v is num ? v.toDouble() : 0;
}
