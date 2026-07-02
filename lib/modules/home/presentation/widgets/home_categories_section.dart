import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/category_item.dart';
import 'section_header.dart';

/// Horizontal strip of category thumbnails, fed by the home feed.
class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({
    super.key,
    required this.categories,
    this.onSeeAll,
    this.onCategoryTap,
  });

  final List<CategoryItem> categories;
  final VoidCallback? onSeeAll;

  /// Tapped a category thumbnail — opens the Categories tab with this
  /// category selected, as if it had been tapped there directly.
  final ValueChanged<CategoryItem>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.edgeHorizontal(16),
          child: SectionHeader(title: context.tr(LocaleKeys.categories), onSeeAll: onSeeAll),
        ),
        context.gapH(12),
        SizedBox(
          height: context.r(96),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: context.edgeHorizontal(16),
            itemCount: categories.length,
            separatorBuilder: (_, _) => context.gapW(16),
            itemBuilder: (context, i) => _CategoryChip(
              category: categories[i],
              onTap: onCategoryTap == null ? null : () => onCategoryTap!(categories[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, this.onTap});

  final CategoryItem category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(30)),
      child: SizedBox(
        width: context.r(72),
        child: Column(
          children: [
            AppNetworkImage(
              url: category.thumbnail,
              width: context.r(60),
              height: context.r(60),
              borderRadius: BorderRadius.circular(context.r(30)),
            ),
            context.gapH(8),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.bodySmall
            ),
          ],
        ),
      ),
    );
  }
}
