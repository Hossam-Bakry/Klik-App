import '../../../home/domain/entities/home_product.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/sub_category.dart';

/// Parses `GET /api/categories`, `GET /api/sub-categories`, and
/// `GET /api/category-products` into domain entities directly (same
/// thin-DTO style as `HomeFeedDto`).
///
/// PROVISIONAL: no sample response was available when this was written, so
/// `_K` guesses field names from the sibling `/api/home` categories shape
/// (id, name, thumbnail). Reconcile `_K` against the real payloads — only
/// this file should need editing.
class CategoryDto {
  const CategoryDto._();

  static List<Category> listFromJson(Object? data) =>
      _asList(data, const ['categories', 'data']).map(_fromJson).toList();

  static Category _fromJson(Map<String, dynamic> json) => Category(
        id: _toInt(json[_K.id]),
        name: _str(json[_K.name]),
        thumbnail: _str(json[_K.thumbnail]),
      );
}

class SubCategoryDto {
  const SubCategoryDto._();

  static List<SubCategory> listFromJson(Object? data, int categoryId) =>
      _asList(data, const ['sub_categories', 'data'])
          .map((json) => _fromJson(json, categoryId))
          .toList();

  static SubCategory _fromJson(Map<String, dynamic> json, int categoryId) =>
      SubCategory(
        id: _toInt(json[_K.id]),
        name: _str(json[_K.name]),
        thumbnail: _str(json[_K.thumbnail]),
        categoryId: _toInt(json[_K.categoryId] ?? categoryId),
      );
}

/// `category-products` shares the home feed's product shape (single
/// `thumbnail`, nested `shop`) — see `ProductDetailsDto._similarFromJson`.
class CategoryProductDto {
  const CategoryProductDto._();

  static List<HomeProduct> listFromJson(Object? data) =>
      _asList(data, const ['products', 'data']).map(_fromJson).toList();

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
    );
  }
}

/// Accepts a bare list or a map wrapping it under one of [keys] — the demo
/// endpoints so far have gone either way (see [ProductDetailsDto]).
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

bool _toBool(Object? v) =>
    v == true || v == 1 || v == '1' || v.toString().toLowerCase() == 'true';

/// Backend JSON keys, isolated so a schema change is a one-place edit.
class _K {
  static const id = 'id';
  static const name = 'name';
  static const thumbnail = 'thumbnail';
  static const categoryId = 'category_id';
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
}
