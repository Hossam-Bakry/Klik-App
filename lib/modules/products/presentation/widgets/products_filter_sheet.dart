import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/product_sort.dart';
import '../../domain/entities/products_filter.dart';

/// Full filter sheet (matches the app's Filter design): selected-filter chips,
/// a category strip, review-rating chips, a sort dropdown, a price-range
/// slider and a brand list. Returns the edited [ProductsFilter] on apply, or
/// null if dismissed.
///
/// [categories] and [brands] are the option lists loaded by [ProductsBloc];
/// a section hides itself when its list is empty.
///
/// NOTE: color/size selectors are still omitted (no list endpoints yet).
Future<ProductsFilter?> showProductsFilterSheet(
  BuildContext context, {
  required ProductsFilter filter,
  required List<Category> categories,
  required List<Brand> brands,
}) {
  return showModalBottomSheet<ProductsFilter>(
    context: context,
    backgroundColor: AppColors.border,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ProductsFilterSheet(
      filter: filter,
      categories: categories,
      brands: brands,
    ),
  );
}

/// The catalogue's price bounds for the range slider.
/// PROVISIONAL: no "catalog max price" endpoint exists — reconcile if needed.
const double _priceMin = 0;
const double _priceMax = 1000;

class _ProductsFilterSheet extends StatefulWidget {
  const _ProductsFilterSheet({
    required this.filter,
    required this.categories,
    required this.brands,
  });

  final ProductsFilter filter;
  final List<Category> categories;
  final List<Brand> brands;

  @override
  State<_ProductsFilterSheet> createState() => _ProductsFilterSheetState();
}

class _ProductsFilterSheetState extends State<_ProductsFilterSheet> {
  late int? _categoryId = widget.filter.categoryId;
  late int? _rating = widget.filter.rating;
  late ProductSort? _sort = widget.filter.sort;
  late int? _brandId = widget.filter.brandId;
  late RangeValues _price = RangeValues(
    (widget.filter.minPrice ?? _priceMin).toDouble().clamp(_priceMin, _priceMax),
    (widget.filter.maxPrice ?? _priceMax).toDouble().clamp(_priceMin, _priceMax),
  );
  bool _sortExpanded = false;
  bool _brandsExpanded = false;

  bool get _priceActive => _price.start > _priceMin || _price.end < _priceMax;

  void _clear() {
    setState(() {
      _categoryId = null;
      _rating = null;
      _sort = null;
      _brandId = null;
      _price = const RangeValues(_priceMin, _priceMax);
    });
  }

  ProductsFilter _build() {
    return widget.filter.copyWith(
      categoryId: _categoryId,
      clearCategoryId: _categoryId == null,
      brandId: _brandId,
      clearBrandId: _brandId == null,
      rating: _rating,
      clearRating: _rating == null,
      sort: _sort,
      clearSort: _sort == null,
      minPrice: _priceActive ? _price.start.round() : null,
      clearMinPrice: !_priceActive,
      maxPrice: _priceActive ? _price.end.round() : null,
      clearMaxPrice: !_priceActive,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(context),
          Flexible(
            child: SingleChildScrollView(
              padding: context.edge(left: 16, right: 16, top: 4, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _selectedFilters(context),
                  if (widget.categories.isNotEmpty) _categoriesCard(context),
                  _reviewsCard(context),
                  _sortCard(context),
                  _priceCard(context),
                  if (widget.brands.isNotEmpty) _brandCard(context),
                ],
              ),
            ),
          ),
          _footer(context),
        ],
      ),
    );
  }

  // ---- Header -------------------------------------------------------------

  Widget _header(BuildContext context) {
    return Padding(
      padding: context.edge(left: 8, right: 16, top: 8, bottom: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
          ),
          Expanded(
            child: Text(
              context.tr(LocaleKeys.filter),
              textAlign: TextAlign.center,
              style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: _clear,
            child: Padding(
              padding: context.edgeSymmetric(horizontal: 8, vertical: 8),
              child: Text(
                context.tr(LocaleKeys.reset),
                style: context.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Selected filters ---------------------------------------------------

  Widget _selectedFilters(BuildContext context) {
    final chips = <Widget>[];

    if (_categoryId != null) {
      chips.add(_SelectedChip(
        label: _categoryName(_categoryId!),
        onRemove: () => setState(() => _categoryId = null),
      ));
    }
    if (_brandId != null) {
      chips.add(_SelectedChip(
        label: _brandName(_brandId!),
        onRemove: () => setState(() => _brandId = null),
      ));
    }
    if (_priceActive) {
      chips.add(_SelectedChip(
        label: '${_price.start.round()}-${_price.end.round()} '
            '${context.tr(LocaleKeys.currencyKwd)}',
        onRemove: () =>
            setState(() => _price = const RangeValues(_priceMin, _priceMax)),
      ));
    }
    if (_rating != null) {
      chips.add(_SelectedChip(
        label: '${_rating!.toStringAsFixed(1)} ${context.tr(LocaleKeys.ratingAndUp)}',
        onRemove: () => setState(() => _rating = null),
      ));
    }
    if (_sort != null) {
      chips.add(_SelectedChip(
        label: context.tr(_sort!.labelKey),
        onRemove: () => setState(() => _sort = null),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: context.r(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(LocaleKeys.selectedFilters),
            style: context.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          context.gapH(10),
          Wrap(spacing: context.r(8), runSpacing: context.r(8), children: chips),
          context.gapH(12),
        ],
      ),
    );
  }

  // ---- Categories ---------------------------------------------------------

  Widget _categoriesCard(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: context.tr(LocaleKeys.categories)),
          context.gapH(12),
          SizedBox(
            height: context.r(96),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.categories.length,
              separatorBuilder: (_, _) => context.gapW(14),
              itemBuilder: (context, i) {
                final category = widget.categories[i];
                final selected = _categoryId == category.id;
                return _CategoryItem(
                  category: category,
                  selected: selected,
                  onTap: () => setState(
                    () => _categoryId = selected ? null : category.id,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---- Reviews ------------------------------------------------------------

  Widget _reviewsCard(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: context.tr(LocaleKeys.reviews)),
          context.gapH(12),
          Wrap(
            spacing: context.r(10),
            runSpacing: context.r(10),
            children: [
              for (final value in const [5, 4, 3, 2, 1])
                _RatingChip(
                  value: value,
                  selected: _rating == value,
                  onTap: () => setState(
                    () => _rating = _rating == value ? null : value,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Sort ---------------------------------------------------------------

  Widget _sortCard(BuildContext context) {
    final label = _sort == null
        ? context.tr(LocaleKeys.defaultSorting)
        : context.tr(_sort!.labelKey);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(LocaleKeys.sortedBy),
            style: context.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          context.gapH(12),
          InkWell(
            onTap: () => setState(() => _sortExpanded = !_sortExpanded),
            borderRadius: BorderRadius.circular(context.r(10)),
            child: Container(
              padding: context.edgeSymmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.r(10)),
                border: Border.all(color: AppColors.dark.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: context.bodyMedium?.copyWith(
                        color: _sort == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _sortExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_sortExpanded) ...[
            context.gapH(8),
            _SortOption(
              icon: Icons.star_outline_rounded,
              label: context.tr(LocaleKeys.defaultSorting),
              selected: _sort == null,
              onTap: () => setState(() {
                _sort = null;
                _sortExpanded = false;
              }),
            ),
            for (final sort in ProductSort.values)
              _SortOption(
                icon: sort.icon,
                label: context.tr(sort.labelKey),
                selected: _sort == sort,
                onTap: () => setState(() {
                  _sort = sort;
                  _sortExpanded = false;
                }),
              ),
          ],
        ],
      ),
    );
  }

  // ---- Price --------------------------------------------------------------

  Widget _priceCard(BuildContext context) {
    final currency = context.tr(LocaleKeys.currencyKwd);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(LocaleKeys.priceRange),
            style: context.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          context.gapH(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_price.start.round()} $currency',
                style: context.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${_price.end.round()} $currency',
                style: context.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.dark.withValues(alpha: 0.12),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: RangeSlider(
              min: _priceMin,
              max: _priceMax,
              divisions: 100,
              values: _price,
              labels: RangeLabels(
                '${_price.start.round()}',
                '${_price.end.round()}',
              ),
              onChanged: (values) => setState(() => _price = values),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Brand --------------------------------------------------------------

  Widget _brandCard(BuildContext context) {
    final brands = _brandsExpanded || widget.brands.length <= 4
        ? widget.brands
        : widget.brands.take(4).toList();
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: context.tr(LocaleKeys.brand),
            onSeeAll: widget.brands.length > 4
                ? () => setState(() => _brandsExpanded = !_brandsExpanded)
                : null,
          ),
          context.gapH(4),
          for (final brand in brands)
            _BrandRow(
              brand: brand,
              selected: _brandId == brand.id,
              onTap: () => setState(
                () => _brandId = _brandId == brand.id ? null : brand.id,
              ),
            ),
        ],
      ),
    );
  }

  // ---- Footer -------------------------------------------------------------

  Widget _footer(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(
        context.r(16),
        context.r(12),
        context.r(16),
        context.r(12) + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: AppButton.filled(
              label: context.tr(LocaleKeys.applyFilters),
              onPressed: () => Navigator.of(context).pop(_build()),
            ),
          ),
          context.gapW(12),
          Expanded(
            flex: 2,
            child: AppButton.outline(
              label: context.tr(LocaleKeys.clearAll),
              onPressed: () {
                _clear();
                Navigator.of(context).pop(_build());
              },
            ),
          ),
        ],
      ),
    );
  }

  String _categoryName(int id) => widget.categories
      .firstWhere(
        (c) => c.id == id,
        orElse: () => const Category(id: 0, name: '', thumbnail: ''),
      )
      .name;

  String _brandName(int id) => widget.brands
      .firstWhere(
        (b) => b.id == id,
        orElse: () => const Brand(id: 0, name: ''),
      )
      .name;
}

// ---------------------------------------------------------------------------
// Pieces
// ---------------------------------------------------------------------------

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: context.r(12)),
      padding: context.edgeAll(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(16)),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: context.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              context.tr(LocaleKeys.seeAll),
              style: context.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }
}

class _SelectedChip extends StatelessWidget {
  const _SelectedChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.edge(left: 12, right: 8, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(context.r(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          context.gapW(6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: context.r(16), color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: context.r(64),
        child: Column(
          children: [
            Container(
              width: context.r(56),
              height: context.r(56),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(context.r(2)),
                child: ClipOval(
                  child: AppNetworkImage(
                    url: category.thumbnail,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            context.gapH(6),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.labelSmall?.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(10)),
      child: Container(
        padding: context.edgeSymmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBronze : AppColors.surface,
          borderRadius: BorderRadius.circular(context.r(10)),
          border: Border.all(
            color: selected
                ? AppColors.primaryBronze
                : AppColors.dark.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              size: context.r(16),
              color: selected ? AppColors.surface : AppColors.primaryBronze,
            ),
            context.gapW(4),
            Text(
              value.toStringAsFixed(1),
              style: context.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.surface : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(8)),
      child: Container(
        padding: context.edgeSymmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(context.r(8)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: context.r(20),
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            context.gapW(12),
            Expanded(
              child: Text(
                label,
                style: context.bodyMedium?.copyWith(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, size: context.r(20), color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({
    required this.brand,
    required this.selected,
    required this.onTap,
  });

  final Brand brand;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: context.edgeSymmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: context.r(22),
            ),
            context.gapW(10),
            Expanded(
              child: Text(brand.name, style: context.bodyMedium),
            ),
            Text(
              '(${brand.productsCount})',
              style: context.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
