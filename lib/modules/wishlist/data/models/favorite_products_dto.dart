import '../../../home/domain/entities/home_product.dart';

/// Parses `GET /api/favorite-products` (`data.products[]`) into [HomeProduct]s.
/// Field names are the confirmed product shape shared with `/api/home` and
/// `/api/products` (single `thumbnail`, nested `shop`, string counters).
class FavoriteProductsDto {
  const FavoriteProductsDto._();

  static List<HomeProduct> listFromJson(Object? data) =>
      _extractList(data).map(_fromJson).toList();

  static List<Map<String, dynamic>> _extractList(Object? data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map<String, dynamic>) {
      for (final key in const ['products', 'data', 'items']) {
        final inner = data[key];
        if (inner is List) return inner.cast<Map<String, dynamic>>();
      }
    }
    return const [];
  }

  static HomeProduct _fromJson(Map<String, dynamic> json) {
    final shop = json[_K.shop] as Map<String, dynamic>?;
    return HomeProduct(
      id: _toInt(json[_K.id]),
      name: _str(json[_K.name]),
      thumbnail: _str(json[_K.thumbnail]),
      price: _toDouble(json[_K.price]),
      discountPrice: _toDouble(json[_K.discountPrice]),
      discountPercentage: _toDouble(json[_K.discountPercentage]),
      rating: _toDouble(json[_K.rating]),
      totalSold: _toInt(json[_K.totalSold]),
      quantity: _toInt(json[_K.quantity]),
      isFavorite: _toBool(json[_K.isFavorite]),
      isBidable: _toBool(json[_K.isBidable]),
      shopName: _str(shop?[_K.name]),
      estimatedDeliveryTime: _str(shop?[_K.estimatedDeliveryTime]),
      hasVariants: _hasVariants(json),
    );
  }

  /// A product varies when the payload carries a non-empty `colors`/`sizes`
  /// array; absent, null or empty means a simple product.
  static bool _hasVariants(Map<String, dynamic> json) =>
      _isNonEmptyList(json[_K.colors]) || _isNonEmptyList(json[_K.sizes]);

  static bool _isNonEmptyList(Object? v) => v is List && v.isNotEmpty;
}

String _str(Object? v) => v?.toString().trim() ?? '';

double _toDouble(Object? v) =>
    v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

int _toInt(Object? v) => switch (v) {
  num n => n.toInt(),
  String s => int.tryParse(s) ?? 0,
  _ => 0,
};

bool _toBool(Object? v) =>
    v == true || v == 1 || v == '1' || v.toString().toLowerCase() == 'true';

class _K {
  static const id = 'id';
  static const name = 'name';
  static const thumbnail = 'thumbnail';
  static const price = 'price';
  static const discountPrice = 'discount_price';
  static const discountPercentage = 'discount_percentage';
  static const rating = 'rating';
  static const totalSold = 'total_sold';
  static const quantity = 'quantity';
  static const isFavorite = 'is_favorite';
  static const isBidable = 'is_bidable';
  static const shop = 'shop';
  static const estimatedDeliveryTime = 'estimated_delivery_time';
  static const colors = 'colors';
  static const sizes = 'sizes';
}
