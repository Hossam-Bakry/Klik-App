import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product_color_option.dart';

/// Row of colour swatches; the selected one is ringed with the brand colour.
class ProductColorSelector extends StatelessWidget {
  const ProductColorSelector({
    super.key,
    required this.colors,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ProductColorOption> colors;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.r(14),
      runSpacing: context.r(12),
      children: [
        for (var i = 0; i < colors.length; i++)
          _Swatch(
            color: _parseHex(colors[i].hex),
            selected: i == selectedIndex,
            onTap: () => onSelected(i),
          ),
      ],
    );
  }

  /// Parses `#RRGGBB` / `RRGGBB` / `#AARRGGBB` into a [Color]; falls back to a
  /// neutral grey when the value is missing or malformed.
  static Color _parseHex(String hex) {
    var value = hex.replaceAll('#', '').trim();
    if (value.length == 6) value = 'FF$value';
    final parsed = int.tryParse(value, radix: 16);
    return parsed == null ? const Color(0xFFD9D9D9) : Color(parsed);
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.selected, required this.onTap});

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = context.r(34);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(context.r(1)),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}
