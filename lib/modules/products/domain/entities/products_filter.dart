import 'package:equatable/equatable.dart';

import 'product_sort.dart';

/// Everything that parameterizes a `GET /api/products` listing, plus the
/// display [title] for the page's app bar.
///
/// One reusable products page is driven by this object; each entry point builds
/// the variant it needs:
///   • from a shop      → `ProductsFilter(shopId: ...)`
///   • from a category  → `ProductsFilter(categoryId: ...)`
///   • "Best deals"     → `ProductsFilter(sort: ProductSort.popular)`
///
/// The identity fields set by the entry point (shopId/categoryId/…) are kept
/// intact when the user tweaks the in-page filter sheet — the sheet only edits
/// [search], [sort], price range, [rating] and [isBidable].
class ProductsFilter extends Equatable {
  const ProductsFilter({
    this.title,
    this.search,
    this.shopId,
    this.categoryId,
    this.subCategoryId,
    this.brandId,
    this.colorId,
    this.sizeId,
    this.minPrice,
    this.maxPrice,
    this.rating,
    this.sort,
    this.isBidable,
  });

  /// App-bar title (e.g. the shop or category name). Not sent to the API.
  final String? title;

  final String? search;

  // Identity filters — set by the entry point.
  final int? shopId;
  final int? categoryId;
  final int? subCategoryId;

  // Refinements — editable in the filter sheet.
  final int? brandId;
  final int? colorId;
  final int? sizeId;
  final num? minPrice;
  final num? maxPrice;
  final int? rating;
  final ProductSort? sort;
  final bool? isBidable;

  /// Query params for one page. `page`/`per_page` are supplied by the repo.
  /// Only set keys are included, so an omitted filter isn't sent at all.
  Map<String, dynamic> toQuery() => {
    if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
    if (shopId != null) 'shop_id': shopId,
    if (categoryId != null) 'category_id': categoryId,
    if (subCategoryId != null) 'sub_category_id': subCategoryId,
    if (brandId != null) 'brand_id': brandId,
    if (colorId != null) 'color_id': colorId,
    if (sizeId != null) 'size_id': sizeId,
    if (minPrice != null) 'min_price': minPrice,
    if (maxPrice != null) 'max_price': maxPrice,
    if (rating != null) 'rating': rating,
    if (sort != null) 'sort_type': sort!.apiValue,
    if (isBidable != null) 'is_bidable': isBidable! ? 1 : 0,
  };

  ProductsFilter copyWith({
    String? title,
    String? search,
    bool clearSearch = false,
    int? categoryId,
    bool clearCategoryId = false,
    int? brandId,
    bool clearBrandId = false,
    int? colorId,
    bool clearColorId = false,
    int? sizeId,
    bool clearSizeId = false,
    num? minPrice,
    bool clearMinPrice = false,
    num? maxPrice,
    bool clearMaxPrice = false,
    int? rating,
    bool clearRating = false,
    ProductSort? sort,
    bool clearSort = false,
    bool? isBidable,
    bool clearIsBidable = false,
  }) {
    return ProductsFilter(
      title: title ?? this.title,
      search: clearSearch ? null : (search ?? this.search),
      shopId: shopId,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      subCategoryId: subCategoryId,
      brandId: clearBrandId ? null : (brandId ?? this.brandId),
      colorId: clearColorId ? null : (colorId ?? this.colorId),
      sizeId: clearSizeId ? null : (sizeId ?? this.sizeId),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      rating: clearRating ? null : (rating ?? this.rating),
      sort: clearSort ? null : (sort ?? this.sort),
      isBidable: clearIsBidable ? null : (isBidable ?? this.isBidable),
    );
  }

  /// True when any sheet-editable refinement is active (drives the filter
  /// button's "active" dot).
  bool get hasActiveRefinements =>
      brandId != null ||
      colorId != null ||
      sizeId != null ||
      minPrice != null ||
      maxPrice != null ||
      rating != null ||
      sort != null ||
      isBidable != null;

  @override
  List<Object?> get props => [
    title,
    search,
    shopId,
    categoryId,
    subCategoryId,
    brandId,
    colorId,
    sizeId,
    minPrice,
    maxPrice,
    rating,
    sort,
    isBidable,
  ];
}
