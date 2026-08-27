import '../../../home/domain/entities/home_product.dart';
import '../../domain/entities/products_page.dart';

/// Parses `GET /api/products` into a [ProductsPage].
///
/// The unwrapped envelope `data` can arrive in a few shapes, so this reads
/// defensively:
///   • Laravel paginator:  { current_page, last_page, total, data: [ … ] }
///   • wrapped list:       { products: [ … ] }  (with optional meta/pagination)
///   • bare list:          [ … ]
///
/// [requestedPage]/[perPage] are used to compute [ProductsPage.hasMore] when
/// the payload carries no paginator metadata (fallback: a full page implies
/// there may be more).
///
/// PROVISIONAL: product field names reuse the confirmed `/api/home` product
/// shape (`HomeFeedDto._productFromJson`); reconcile `_K` if the list endpoint
/// differs.
class ProductListDto {
  const ProductListDto._();

  static ProductsPage fromJson(
    Object? data, {
    required int requestedPage,
    required int perPage,
  }) {
    final list = _extractList(data);
    final meta = _extractMeta(data);

    final items = list.map(_productFromJson).toList();

    final bool hasMore;
    final currentPage = _toInt(meta?[_K.currentPage]);
    final lastPage = _toInt(meta?[_K.lastPage]);
    if (currentPage != null && lastPage != null) {
      hasMore = currentPage < lastPage;
    } else {
      final total = _toInt(meta?[_K.total]);
      if (total != null) {
        hasMore = requestedPage * perPage < total;
      } else {
        // No paginator info — assume more pages while we keep getting full ones.
        hasMore = items.length >= perPage;
      }
    }

    return ProductsPage(items: items, page: requestedPage, hasMore: hasMore);
  }

  /// Finds the product array, whether `data` is a bare list, a paginator
  /// (`data.data`), or a wrapper (`data.products`).
  static List<Map<String, dynamic>> _extractList(Object? data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map<String, dynamic>) {
      for (final key in const ['data', 'products', 'items']) {
        final inner = data[key];
        if (inner is List) return inner.cast<Map<String, dynamic>>();
      }
    }
    return const [];
  }

  /// Pagination metadata sits either alongside the list (Laravel paginator) or
  /// under a `meta`/`pagination` node.
  static Map<String, dynamic>? _extractMeta(Object? data) {
    if (data is! Map<String, dynamic>) return null;
    for (final key in const ['meta', 'pagination']) {
      final node = data[key];
      if (node is Map<String, dynamic>) return node;
    }
    return data;
  }

  static HomeProduct _productFromJson(Map<String, dynamic> json) {
    final shop = json[_K.shop] as Map<String, dynamic>?;
    return HomeProduct(
      id: _toInt(json[_K.id]) ?? 0,
      name: _str(json[_K.name]),
      thumbnail: _str(json[_K.thumbnail]),
      price: _toDouble(json[_K.price]),
      discountPrice: _toDouble(json[_K.discountPrice]),
      discountPercentage: _toDouble(json[_K.discountPercentage]),
      rating: _toDouble(json[_K.rating]),
      totalSold: _toInt(json[_K.totalSold]) ?? 0,
      quantity: _toInt(json[_K.quantity]) ?? 0,
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

int? _toInt(Object? v) => switch (v) {
  num n => n.toInt(),
  String s => int.tryParse(s),
  _ => null,
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

  static const currentPage = 'current_page';
  static const lastPage = 'last_page';
  static const total = 'total';
}
