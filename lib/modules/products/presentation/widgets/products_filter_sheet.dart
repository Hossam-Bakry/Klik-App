import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/product_sort.dart';
import '../../domain/entities/products_filter.dart';

/// Bottom sheet that edits the self-contained refinements of a [ProductsFilter]
/// — sort, price range, rating and negotiable-only. Identity filters
/// (shop/category/…) and search text are preserved untouched.
///
/// Returns the edited [ProductsFilter] on apply, or null if dismissed.
///
/// NOTE: brand/color/size selectors are intentionally omitted until their
/// list endpoints exist (see [ProductsFilter] — those fields are carried
/// through but not editable here yet).
Future<ProductsFilter?> showProductsFilterSheet(
  BuildContext context,
  ProductsFilter filter,
) {
  return showModalBottomSheet<ProductsFilter>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ProductsFilterSheet(filter: filter),
  );
}

class _ProductsFilterSheet extends StatefulWidget {
  const _ProductsFilterSheet({required this.filter});

  final ProductsFilter filter;

  @override
  State<_ProductsFilterSheet> createState() => _ProductsFilterSheetState();
}

class _ProductsFilterSheetState extends State<_ProductsFilterSheet> {
  late ProductSort? _sort = widget.filter.sort;
  late int? _rating = widget.filter.rating;
  late bool _negotiableOnly = widget.filter.isBidable ?? false;
  late final TextEditingController _minController = TextEditingController(
    text: widget.filter.minPrice?.toString() ?? '',
  );
  late final TextEditingController _maxController = TextEditingController(
    text: widget.filter.maxPrice?.toString() ?? '',
  );

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _sort = null;
      _rating = null;
      _negotiableOnly = false;
      _minController.clear();
      _maxController.clear();
    });
  }

  void _apply() {
    final min = num.tryParse(_minController.text.trim());
    final max = num.tryParse(_maxController.text.trim());
    final applied = widget.filter.copyWith(
      sort: _sort,
      clearSort: _sort == null,
      rating: _rating,
      clearRating: _rating == null,
      isBidable: _negotiableOnly ? true : null,
      clearIsBidable: !_negotiableOnly,
      minPrice: min,
      clearMinPrice: min == null,
      maxPrice: max,
      clearMaxPrice: max == null,
    );
    Navigator.of(context).pop(applied);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.edge(left: 20, right: 20, top: 12, bottom: 16),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: context.r(40),
                  height: context.r(4),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              context.gapH(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr(LocaleKeys.filters),
                    style: context.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppButton.text(
                    label: context.tr(LocaleKeys.clearAll),
                    foregroundColor: AppColors.primary,
                    onPressed: _clearAll,
                  ),
                ],
              ),
              context.gapH(8),
              _SectionTitle(context.tr(LocaleKeys.sortBy)),
              context.gapH(10),
              Wrap(
                spacing: context.r(8),
                runSpacing: context.r(8),
                children: [
                  for (final sort in ProductSort.values)
                    _ChoiceChip(
                      label: context.tr(_sortLabel(sort)),
                      selected: _sort == sort,
                      onTap: () => setState(
                        () => _sort = _sort == sort ? null : sort,
                      ),
                    ),
                ],
              ),
              context.gapH(20),
              _SectionTitle(context.tr(LocaleKeys.priceRange)),
              context.gapH(10),
              Row(
                children: [
                  Expanded(
                    child: _PriceField(
                      controller: _minController,
                      hint: context.tr(LocaleKeys.minPrice),
                    ),
                  ),
                  context.gapW(12),
                  Expanded(
                    child: _PriceField(
                      controller: _maxController,
                      hint: context.tr(LocaleKeys.maxPrice),
                    ),
                  ),
                ],
              ),
              context.gapH(20),
              _SectionTitle(context.tr(LocaleKeys.rating)),
              context.gapH(10),
              Wrap(
                spacing: context.r(8),
                runSpacing: context.r(8),
                children: [
                  for (final value in const [5, 4, 3, 2, 1])
                    _ChoiceChip(
                      label: '$value ${context.tr(LocaleKeys.ratingAndUp)}',
                      leading: Icon(
                        Icons.star_rounded,
                        size: context.r(15),
                        color: _rating == value
                            ? AppColors.surface
                            : AppColors.primaryBronze,
                      ),
                      selected: _rating == value,
                      onTap: () => setState(
                        () => _rating = _rating == value ? null : value,
                      ),
                    ),
                ],
              ),
              context.gapH(12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
                title: Text(
                  context.tr(LocaleKeys.negotiableOnly),
                  style: context.bodyMedium,
                ),
                value: _negotiableOnly,
                onChanged: (v) => setState(() => _negotiableOnly = v),
              ),
              context.gapH(12),
              AppButton.filled(
                label: context.tr(LocaleKeys.applyFilters),
                onPressed: _apply,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _sortLabel(ProductSort sort) => switch (sort) {
    ProductSort.popular => LocaleKeys.sortPopular,
    ProductSort.newest => LocaleKeys.sortNewest,
    ProductSort.priceLowToHigh => LocaleKeys.sortPriceLowToHigh,
    ProductSort.priceHighToLow => LocaleKeys.sortPriceHighToLow,
    ProductSort.topRated => LocaleKeys.sortTopRated,
  };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.titleSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(24)),
      child: Container(
        padding: context.edgeSymmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(context.r(24)),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.dark.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, context.gapW(4)],
            Text(
              label,
              style: context.bodySmall?.copyWith(
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

class _PriceField extends StatelessWidget {
  const _PriceField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: context.edgeSymmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.r(12)),
          borderSide: BorderSide(color: AppColors.dark.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.r(12)),
          borderSide: BorderSide(color: AppColors.dark.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.r(12)),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
