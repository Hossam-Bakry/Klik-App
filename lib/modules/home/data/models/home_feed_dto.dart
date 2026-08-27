import '../../domain/entities/banner_item.dart';
import '../../domain/entities/category_item.dart';
import '../../domain/entities/home_feed.dart';
import '../../domain/entities/home_product.dart';
import '../../domain/entities/shop_item.dart';

/// Parses the `GET /api/home` `data` object into a [HomeFeed]. All the home
/// section DTOs live here since they're decoded together in one pass.
///
/// Throwing on bad JSON is fine — DioApiClient catches decode errors and turns
/// them into a ParsingFailure.
class HomeFeedDto {
  const HomeFeedDto._();

  static HomeFeed fromJson(Map<String, dynamic> json) {
    List<T> list<T>(Object? raw, T Function(Map<String, dynamic>) map) =>
        (raw as List? ?? const [])
            .map((e) => map(e as Map<String, dynamic>))
            .toList();

    // `just_for_you` and `bidable_products` are wrapped: { total, products }.
    List<HomeProduct> products(Object? raw) {
      final node = raw is Map<String, dynamic> ? raw['products'] : raw;
      return list(node, _productFromJson);
    }

    return HomeFeed(
      banners: list(json['banners'], _bannerFromJson),
      categories: list(json['categories'], _categoryFromJson),
      justForYou: products(json['just_for_you']),
      shops: list(json['shops'], _shopFromJson),
      bidableProducts: products(json['bidable_products']),
    );
  }

  static BannerItem _bannerFromJson(Map<String, dynamic> json) => BannerItem(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String?,
        thumbnail: json['thumbnail'] as String? ?? '',
      );

  static CategoryItem _categoryFromJson(Map<String, dynamic> json) => CategoryItem(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        thumbnail: json['thumbnail'] as String? ?? '',
      );

  static ShopItem _shopFromJson(Map<String, dynamic> json) => ShopItem(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        logo: json['logo'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        totalProducts: (json['total_products'] as num?)?.toInt() ?? 0,
        isOnline: (json['shop_status'] as String?)?.toLowerCase() == 'online',
      );

  static HomeProduct _productFromJson(Map<String, dynamic> json) {
    final shop = json['shop'] as Map<String, dynamic>?;
    return HomeProduct(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPrice: (json['discount_price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      // The API sends these counters as strings ("113"); parse defensively.
      totalSold: _toInt(json['total_sold']),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      isFavorite: json['is_favorite'] as bool? ?? false,
      isBidable: json['is_bidable'] as bool? ?? false,
      shopName: shop?['name'] as String? ?? '',
      estimatedDeliveryTime: '${shop?['estimated_delivery_time'] ?? ''}',
      hasVariants: _hasVariants(json),
    );
  }

  /// A product varies when the payload carries a non-empty `colors`/`sizes`
  /// array; absent, null or empty means a simple product.
  static bool _hasVariants(Map<String, dynamic> json) =>
      _isNonEmptyList(json['colors']) || _isNonEmptyList(json['sizes']);

  static bool _isNonEmptyList(Object? v) => v is List && v.isNotEmpty;

  static int _toInt(Object? v) => switch (v) {
        num n => n.toInt(),
        String s => int.tryParse(s) ?? 0,
        _ => 0,
      };
}
