import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../catalog/presentation/bloc/catalog_bloc.dart';
import 'section_header.dart';

/// Horizontal strip of category chips. Categories are derived from the unique
/// [Product.category] values currently loaded in [CatalogBloc].
class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({super.key});

  static const _icons = {
    'electronics': Icons.devices_other_rounded,
    'jewelery': Icons.diamond_outlined,
    "men's clothing": Icons.checkroom_rounded,
    "women's clothing": Icons.woman_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogBloc, CatalogState>(
      buildWhen: (p, c) => p.products != c.products,
      builder: (context, state) {
        final categories = <String>{for (final p in state.products) p.category}.toList();
        if (categories.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: context.edgeHorizontal(16),
              child: SectionHeader(title: context.tr(LocaleKeys.categories)),
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
                  label: categories[i],
                  icon: _icons[categories[i].toLowerCase()] ?? Icons.category_outlined,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.r(72),
      child: Column(
        children: [
          Container(
            width: context.r(60),
            height: context.r(60),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: context.r(28)),
          ),
          context.gapH(8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: context.sp(11), color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
