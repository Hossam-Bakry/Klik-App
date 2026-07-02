import '../../../home/domain/entities/shop_item.dart';

/// Parses `GET /api/shops` into [ShopItem]s.
///
/// PROVISIONAL: no sample response was available when this was written, so
/// field names are reused from the sibling `/api/home` shops shape
/// (`HomeFeedDto._shopFromJson`) — reconcile `_K` against the real payload.
class ShopDto {
  const ShopDto._();

  static List<ShopItem> listFromJson(Object? data) =>
      _asList(data, const ['shops', 'data']).map(_fromJson).toList();

  static ShopItem _fromJson(Map<String, dynamic> json) => ShopItem(
    id: _toInt(json[_K.id]),
    name: _str(json[_K.name]),
    logo: _str(json[_K.logo]),
    rating: _toDouble(json[_K.rating]),
    totalProducts: _toInt(json[_K.totalProducts]),
    isOnline: _str(json[_K.shopStatus]).toLowerCase() == 'online',
  );
}

/// Accepts a bare list or a map wrapping it under one of [keys].
List<Map<String, dynamic>> _asList(Object? data, List<String> keys) {
  if (data is List) return data.cast<Map<String, dynamic>>();
  if (data is Map<String, dynamic>) {
    for (final key in keys) {
      final inner = data[key];
      if (inner is List) return inner.cast<Map<String, dynamic>>();
    }
  }
  return const [];
}

String _str(Object? v) => v?.toString().trim() ?? '';

double _toDouble(Object? v) =>
    v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

int _toInt(Object? v) => switch (v) {
  num n => n.toInt(),
  String s => int.tryParse(s) ?? 0,
  _ => 0,
};

class _K {
  static const id = 'id';
  static const name = 'name';
  static const logo = 'logo';
  static const rating = 'rating';
  static const totalProducts = 'total_products';
  static const shopStatus = 'shop_status';
}
