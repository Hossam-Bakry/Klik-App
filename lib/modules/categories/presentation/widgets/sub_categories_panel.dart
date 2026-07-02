import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/sub_category.dart';

/// Inline panel of subcategories shown under the tapped category's row.
class SubCategoriesPanel extends StatelessWidget {
  const SubCategoriesPanel({
    super.key,
    required this.loading,
    required this.subCategories,
    required this.onTap,
  });

  final bool loading;
  final List<SubCategory> subCategories;
  final ValueChanged<SubCategory> onTap;

  @override
  Widget build(BuildContext context) {
    if (!loading && subCategories.isEmpty) return const SizedBox.shrink();

    final items = loading ? SubCategory.placeholder() : subCategories;

    return Skeletonizer(
      enabled: loading,
      child: Container(
        margin: EdgeInsets.only(bottom: context.r(12)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(context.r(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: context.r(8),
              offset: Offset(0, context.r(2)),
            ),
          ],
          // border: Border.all(color: const Color(0xFFE6E0D4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.dark.withValues(alpha: 0.1),
                  endIndent: 40,
                  indent: 40,
                ),
              _SubCategoryTile(
                subCategory: items[i],
                onTap: loading ? () {} : () => onTap(items[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubCategoryTile extends StatelessWidget {
  const _SubCategoryTile({required this.subCategory, required this.onTap});

  final SubCategory subCategory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: context.edgeSymmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            AppNetworkImage(
              url: subCategory.thumbnail,
              width: context.r(36),
              height: context.r(36),
              borderRadius: BorderRadius.circular(context.r(6)),
            ),
            context.gapW(12),
            Expanded(child: Text(subCategory.name, style: context.bodyMedium)),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: context.r(20),
            ),
          ],
        ),
      ),
    );
  }
}
