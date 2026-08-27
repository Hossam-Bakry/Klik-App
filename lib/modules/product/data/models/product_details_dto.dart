import '../../../home/domain/entities/home_product.dart';
import '../../domain/entities/product_bid.dart';
import '../../domain/entities/product_color_option.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/entities/product_review.dart';
import '../../domain/entities/product_size_option.dart';

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

    // `bidding` is what the API actually sends; `bid`/`my_bid` are kept as
    // fallbacks so an older/renamed payload still parses.
    final bidding = _biddingFromJson(
      p[_K.bidding] ??
          p[_K.bid] ??
          p[_K.myBid] ??
          data[_K.bidding] ??
          data[_K.bid] ??
          data[_K.myBid],
    );

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
      quantity: _toInt(p[_K.quantity]),
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
      bid: bidding.selected,
      bidVariants: bidding.variants,
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
        // Kept for the bid body's optional `color`.
        id: _toNullableInt(json[_K.id]),
        name: _str(json[_K.colorName]),
        hex: _str(json[_K.colorCode]),
      );

  /// Sizes come as objects (shape not yet seen populated); accept a `name`/
  /// `label` field or a bare scalar. The id, when present, is what the bid body
  /// sends as `size`.
  static List<ProductSizeOption> _sizes(Object? raw) =>
      (raw as List? ?? const [])
          .map(
            (e) => e is Map
                ? ProductSizeOption(
                    id: _toNullableInt(e[_K.id]),
                    label: _str(e[_K.sizeName] ?? e[_K.sizeLabel]),
                  )
                : ProductSizeOption(label: _str(e)),
          )
          .where((s) => s.label.isNotEmpty)
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

  /// The customer's negotiation on this product, when the payload carries one.
  ///
  /// The `bid` object is variant-based: an attempt allowance under
  /// `rules.attempts` plus a `variants` array keyed `size_id:color_id`. We flat-
  /// ten *every* variant into a [ProductBid] — so the UI can re-resolve the bid
  /// from the customer's size/colour pick (see [ProductDetails.bidForVariant]) —
  /// and mark the server's `selected_variant_key` (falling back to the first) as
  /// the default. Returns an empty result when bidding is disabled or carries no
  /// usable variant, so the UI hides the bid section.
  static ({ProductBid? selected, List<ProductBid> variants}) _biddingFromJson(
    Object? raw,
  ) {
    const empty = (selected: null, variants: <ProductBid>[]);
    if (raw is! Map) return empty;
    final json = raw.cast<String, dynamic>();
    // `enabled: false` means this product isn't open to offers.
    if (json.containsKey(_K.bidEnabled) && !_toBool(json[_K.bidEnabled])) {
      return empty;
    }

    final rawVariants = (json[_K.bidVariants] as List?)
        ?.whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
    if (rawVariants == null || rawVariants.isEmpty) return empty;

    // Attempts are product-wide (the product-per-day bucket { max, used,
    // remaining }), so they're shared across every variant.
    final rules = json[_K.bidRules] as Map?;
    final attempts = rules?[_K.bidAttempts] as Map?;
    final perDay = attempts?[_K.attemptsProductPerDay] as Map?;
    // The floor as a share of the listed price — also product-wide.
    final minPercent = _toNullableDouble(rules?[_K.minimumBidPercentage]);
    final dailyLimit = perDay?[_K.attemptMax] == null
        ? 3
        : _toInt(perDay![_K.attemptMax]);

    final variants = rawVariants
        .map((v) => _variantBid(v, perDay, dailyLimit, minPercent))
        .toList();

    final key = _str(json[_K.selectedVariantKey]);
    final selected = key.isEmpty
        ? variants.first
        : variants.firstWhere(
            (v) => v.variantKey == key,
            orElse: () => variants.first,
          );

    return (selected: selected, variants: variants);
  }

  /// Flattens one `variants[]` entry into a [ProductBid], folding in the shared
  /// [perDay] attempt bucket, [dailyLimit] and [minPercent] floor rule.
  static ProductBid _variantBid(
    Map<String, dynamic> variant,
    Map? perDay,
    int dailyLimit,
    double? minPercent,
  ) {
    // The customer's last offer and its state.
    final lastBid = variant[_K.lastBid] as Map?;
    final state = _str(lastBid?[_K.bidState]).toLowerCase();

    // The variant's `price` is the seller's price on the table: a counter while
    // the bid is still pending, a standing offer after a decline, or the agreed
    // price once accepted. An expired price trumps the bid's own state.
    final price = variant[_K.variantPrice] as Map?;
    final priceAmount = _toNullableDouble(price?[_K.priceAmount]);
    // An explicit `countered` state puts the seller's price on the table even if
    // the `active` flag lags behind it.
    final hasSellerPrice = priceAmount != null &&
        (_toBool(price?[_K.priceActive]) || state == _S.countered);
    final priceExpired = _toBool(price?[_K.priceExpired]);

    final status = _bidStatus(
      state,
      hasSellerPrice: hasSellerPrice,
      priceExpired: priceExpired,
    );

    final key = _str(variant[_K.variantKey]);

    return ProductBid(
      variantKey: key.isEmpty ? null : key,
      sizeId: _toNullableInt(variant[_K.variantSizeId]),
      colorId: _toNullableInt(variant[_K.variantColorId]),
      listedPrice: _toNullableDouble(variant[_K.variantListedPrice]),
      status: status,
      attemptsUsed: perDay?[_K.attemptUsed] == null
          ? 0
          : _toInt(perDay![_K.attemptUsed]),
      dailyLimit: dailyLimit,
      offeredPrice: _toNullableDouble(lastBid?[_K.bidAmount]),
      // The seller's price, shown while countered or beside a decline.
      counteredPrice: hasSellerPrice &&
              (status == BidStatus.countered || status == BidStatus.declined)
          ? priceAmount
          : null,
      suggestedPrice: _toNullableDouble(variant[_K.recommendedBid]),
      acceptedPrice: status == BidStatus.approved ? priceAmount : null,
      minimumOffer: _toNullableDouble(variant[_K.minimumBidAmount]),
      minimumOfferPercent: minPercent,
      expiresAt: DateTime.tryParse(_str(price?[_K.priceExpiresAt]))?.toLocal(),
      canSubmit: variant[_K.canSubmit] == null
          ? true
          : _toBool(variant[_K.canSubmit]),
    );
  }

  /// Maps `last_bid.state` + the seller's `price` to a [BidStatus]:
  /// - an expired seller price → [BidStatus.expired] (a fresh bid is needed);
  /// - `countered` → [BidStatus.countered], the seller's own price to accept or
  ///   negotiate against;
  /// - `pending` with an active seller price is also a counter, otherwise still
  ///   [BidStatus.pending];
  /// - `rejected` → [BidStatus.declined] (a standing price may sit alongside it);
  /// - `accepted`/`approved` → [BidStatus.approved]; `none`/unknown → null.
  static BidStatus? _bidStatus(
    String state, {
    required bool hasSellerPrice,
    required bool priceExpired,
  }) {
    if (priceExpired) return BidStatus.expired;
    return switch (state) {
      _S.countered => BidStatus.countered,
      _S.pending => hasSellerPrice ? BidStatus.countered : BidStatus.pending,
      _S.rejected => BidStatus.declined,
      _S.accepted || _S.approved => BidStatus.approved,
      _ => null,
    };
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
      // A related product that varies by colour/size can't be added from its
      // card — the rail's "+" sends the customer to its own page to pick.
      hasVariants:
          _isNonEmptyList(json[_K.colors]) || _isNonEmptyList(json[_K.sizes]),
    );
  }

  // --- Coercion helpers --------------------------------------------------------

  static bool _isNonEmptyList(Object? v) => v is List && v.isNotEmpty;

  static List<T> _list<T>(Object? raw, T Function(Map<String, dynamic>) map) =>
      (raw as List? ?? const [])
          .map((e) => map(e as Map<String, dynamic>))
          .toList();

  static String _str(Object? v) => v?.toString().trim() ?? '';

  static double _toDouble(Object? v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  /// Like [_toInt] but keeps "absent" distinct from 0, so a missing variant id
  /// isn't sent as `0`.
  static int? _toNullableInt(Object? v) => switch (v) {
    num n => n.toInt(),
    String s => int.tryParse(s),
    _ => null,
  };

  /// Like [_toDouble] but keeps "absent" distinct from 0 — an accepted offer of
  /// 0 KWD is meaningless, a missing one just isn't shown.
  static double? _toNullableDouble(Object? v) =>
      v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));

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

/// `last_bid.state` values, lower-cased before matching.
class _S {
  const _S._();

  static const pending = 'pending';

  /// The seller answered with a price of their own.
  static const countered = 'countered';
  static const rejected = 'rejected';

  /// The seller took the customer's offer — `accepted` and `approved` are the
  /// same outcome.
  static const accepted = 'accepted';
  static const approved = 'approved';
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

  // Negotiation — the variant-based `bidding` object from product-details.
  static const bidding = 'bidding';
  static const bid = 'bid';
  static const myBid = 'my_bid';
  static const bidEnabled = 'enabled';
  static const selectedVariantKey = 'selected_variant_key';
  static const bidVariants = 'variants';
  static const bidRules = 'rules';
  static const minimumBidPercentage = 'minimum_bid_percentage';
  static const bidAttempts = 'attempts';
  static const attemptsProductPerDay = 'product_per_day';
  static const attemptMax = 'max';
  static const attemptUsed = 'used';
  // Per-variant fields.
  static const variantKey = 'key';
  static const variantSizeId = 'size_id';
  static const variantColorId = 'color_id';
  static const variantListedPrice = 'listed_price';
  static const minimumBidAmount = 'minimum_bid_amount';
  static const recommendedBid = 'recommended_bid';
  static const canSubmit = 'can_submit';
  static const variantPrice = 'price';
  static const priceActive = 'active';
  static const priceAmount = 'amount';
  static const priceExpiresAt = 'expires_at';
  static const priceExpired = 'expired';
  static const lastBid = 'last_bid';
  static const bidState = 'state';
  static const bidAmount = 'amount';

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
