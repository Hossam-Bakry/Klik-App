import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product_size_option.dart';

/// Row of variant chips (e.g. storage sizes); the selected one fills with the
/// brand colour, the rest are outlined.
class ProductSizeSelector extends StatelessWidget {
  const ProductSizeSelector({
    super.key,
    required this.sizes,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ProductSizeOption> sizes;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.r(12),
      runSpacing: context.r(12),
      children: [
        for (var i = 0; i < sizes.length; i++)
          _Chip(
            label: sizes[i].label,
            selected: i == selectedIndex,
            onTap: () => onSelected(i),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: context.edgeSymmetric(horizontal: 22, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(context.r(6)),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.surface : AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: context.sp(13),
          ),
        ),
      ),
    );
  }
}
