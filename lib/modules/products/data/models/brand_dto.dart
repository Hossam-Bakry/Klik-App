import '../../domain/entities/brand.dart';

/// Parses `GET /api/brands` into [Brand]s.
///
/// PROVISIONAL: no sample response nor a confirmed endpoint was available when
/// this was written. Field names (`id`, `name`, `products_count`) and the
/// endpoint are best-guesses — reconcile `_K` and [ApiEndpoints.brands] against
/// the backend. The Brand filter section hides itself when this returns empty.
class BrandDto {
  const BrandDto._();

  static List<Brand> listFromJson(Object? data) =>
      _asList(data, const ['brands', 'data']).map(_fromJson).toList();

  static Brand _fromJson(Map<String, dynamic> json) => Brand(
    id: _toInt(json[_K.id]),
    name: _str(json[_K.name]),
    productsCount: _toInt(json[_K.productsCount]),
  );
}

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

int _toInt(Object? v) => switch (v) {
  num n => n.toInt(),
  String s => int.tryParse(s) ?? 0,
  _ => 0,
};

class _K {
  static const id = 'id';
  static const name = 'name';
  static const productsCount = 'products_count';
}
