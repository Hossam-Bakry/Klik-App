import '../../../home/domain/entities/home_product.dart';
import '../../domain/entities/product_color_option.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/entities/product_review.dart';

/// Parses the `GET /api/product-details` `data` object into [ProductDetails].
///
/// The `data` envelope wraps the product under `product` alongside sibling
/// `related_products` (used as "Similar products") and `popular_products`.
///
/// Throwing on bad JSON is fine — DioApiClient catches decode errors and turns
/// them into a ParsingFailure.
class ProductDetailsDto {
  const ProductDetailsDto._();

  /// [data] is the unwrapped envelope `data` (i.e. `{ product, related_products,
  /// popular_products }`). Falls back to treating [data] itself as the product
  /// for resilience if the shape ever flattens.
  static ProductDetails fromJson(Map<String, dynamic> data) {
    final p = data[_K.product] is Map<String, dynamic>
        ? data[_K.product] as Map<String, dynamic>
        : data;
    final shop = p[_K.shop] as Map<String, dynamic>?;

    // Reviews aren't part of this payload (only `total_reviews` count); the list
    // comes from `/api/reviews`. Parse defensively in case it's ever inlined.
    final related = (data[_K.relatedProducts] as List?) ??
        (data[_K.popularProducts] as List?) ??
        const [];

    return ProductDetails(
      id: _toInt(p[_K.id]),
      name: _str(p[_K.name]),
      subtitle: _str(p[_K.shortDescription]),
      description: _stripHtml(_str(p[_K.description])),
      images: _images(p[_K.thumbnails]),
      price: _toDouble(p[_K.price]),
      discountPrice: _toDouble(p[_K.discountPrice]),
      discountPercentage: _toDouble(p[_K.discountPercentage]),
      rating: _toDouble(p[_K.rating]),
      totalSold: _toInt(p[_K.totalSold]),
      // The API returns this already-localized (e.g. "3 أيام"), so the UI shows
      // it verbatim — no number formatting or unit suffix added.
      estimatedDeliveryTime: _str(shop?[_K.estimatedDeliveryTime]),
      isFavorite: _toBool(p[_K.isFavorite]),
      isBidable: _toBool(p[_K.isBidable]),
      colors: _list(p[_K.colors], _colorFromJson),
      sizes: _sizes(p[_K.sizes]),
      reviews: _list(p[_K.reviews], _reviewFromJson),
      similarProducts: related
          .map((e) => _similarFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // --- Section parsers ---------------------------------------------------------

  /// Gallery from the `thumbnails` array of `{ thumbnail, url, type }` objects;
  /// uses `thumbnail` (falling back to `url`). Always yields at least the URLs
  /// that are present.
  static List<String> _images(Object? raw) => (raw as List? ?? const [])
      .map((e) => e is Map ? _str(e[_K.thumbnail] ?? e[_K.url]) : _str(e))
      .where((s) => s.isNotEmpty)
      .toList();

  static ProductColorOption _colorFromJson(Map<String, dynamic> json) =>
      ProductColorOption(
        name: _str(json[_K.colorName]),
        hex: _str(json[_K.colorCode]),
      );

  /// Sizes come as objects (shape not yet seen populated); accept a `name`/
  /// `label` field or a bare scalar.
  static List<String> _sizes(Object? raw) => (raw as List? ?? const [])
      .map((e) => e is Map ? _str(e[_K.sizeName] ?? e[_K.sizeLabel]) : _str(e))
      .where((s) => s.isNotEmpty)
      .toList();

  static ProductReview _reviewFromJson(Map<String, dynamic> json) {
    final user = json[_K.reviewUser] as Map<String, dynamic>?;
    return ProductReview(
      id: _toInt(json[_K.id]),
      authorName: _str(json[_K.reviewAuthor] ?? user?[_K.name]),
      avatar: _str(json[_K.reviewAvatar] ?? user?[_K.avatar]),
      rating: _toDouble(json[_K.rating]),
      comment: _str(json[_K.reviewComment]),
      date: _str(json[_K.reviewDate]),
    );
  }

  /// `related_products` / `popular_products` share the home feed's product
  /// shape (single `thumbnail`, nested `shop`).
  static HomeProduct _similarFromJson(Map<String, dynamic> json) {
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

  // --- Coercion helpers --------------------------------------------------------

  static List<T> _list<T>(Object? raw, T Function(Map<String, dynamic>) map) =>
      (raw as List? ?? const [])
          .map((e) => map(e as Map<String, dynamic>))
          .toList();

  static String _str(Object? v) => v?.toString().trim() ?? '';

  static double _toDouble(Object? v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  static int _toInt(Object? v) => switch (v) {
        num n => n.toInt(),
        String s => int.tryParse(s) ?? 0,
        _ => 0,
      };

  static bool _toBool(Object? v) =>
      v == true || v == 1 || v == '1' || v.toString().toLowerCase() == 'true';

  /// `description` arrives as HTML. Strip tags and decode the handful of common
  /// entities so it renders as readable plain text (no HTML-render dependency).
  static String _stripHtml(String html) {
    if (html.isEmpty) return html;
    final text = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    // Collapse the blank lines left behind by block tags.
    return text.replaceAll(RegExp(r'\n\s*\n+'), '\n\n').trim();
  }
}

/// Backend JSON keys, isolated so a schema change is a one-place edit.
class _K {
  // Envelope sections
  static const product = 'product';
  static const relatedProducts = 'related_products';
  static const popularProducts = 'popular_products';

  // Product
  static const id = 'id';
  static const name = 'name';
  static const shortDescription = 'short_description';
  static const description = 'description';
  static const thumbnails = 'thumbnails';
  static const thumbnail = 'thumbnail';
  static const url = 'url';
  static const price = 'price';
  static const discountPrice = 'discount_price';
  static const discountPercentage = 'discount_percentage';
  static const rating = 'rating';
  static const totalSold = 'total_sold';
  static const quantity = 'quantity';
  static const estimatedDeliveryTime = 'estimated_delivery_time';
  static const isFavorite = 'is_favorite';
  static const isBidable = 'is_bidable';
  static const shop = 'shop';

  // Colours
  static const colors = 'colors';
  static const colorName = 'name';
  static const colorCode = 'color_code';

  // Sizes / variants
  static const sizes = 'sizes';
  static const sizeName = 'name';
  static const sizeLabel = 'label';

  // Reviews (not in this payload; parsed defensively)
  static const reviews = 'reviews';
  static const reviewUser = 'user';
  static const reviewAuthor = 'author_name';
  static const reviewAvatar = 'avatar';
  static const reviewComment = 'comment';
  static const reviewDate = 'date';
  static const avatar = 'avatar';
}
