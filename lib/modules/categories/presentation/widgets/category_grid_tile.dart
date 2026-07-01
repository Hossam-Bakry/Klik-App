import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/category.dart';

/// One tile in the Categories grid: a thumbnail with its name below.
class CategoryGridTile extends StatelessWidget {
  const CategoryGridTile({
    super.key,
    required this.category,
    required this.onTap,
    this.selected = false,
  });

  final Category category;
  final VoidCallback onTap;

  /// Whether this tile's subcategories panel is currently expanded.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(12));
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Padding(
        padding: context.edgeAll(6),
        child: Column(
          children: [
            AppNetworkImage(
              url: category.thumbnail,
              width: double.infinity,
              height: context.r(90),
              borderRadius: radius,
            ),
            context.gapH(8),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.bodySmall?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
