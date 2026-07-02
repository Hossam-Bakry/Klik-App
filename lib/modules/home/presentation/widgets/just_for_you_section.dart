import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/product_card_item.dart';
import '../../domain/entities/home_product.dart';
import 'section_header.dart';

/// "Best deals for you" — a horizontal carousel showing the first few products,
/// with a "See all" that opens the full list.
class JustForYouSection extends StatelessWidget {
  const JustForYouSection({super.key, required this.products, this.onSeeAll, this.previewCount = 5});

  final List<HomeProduct> products;
  final VoidCallback? onSeeAll;
  final int previewCount;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    final preview = products.take(previewCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.edgeHorizontal(16),
          child: SectionHeader(title: context.tr(LocaleKeys.bestDealsForYou), onSeeAll: onSeeAll),
        ),
        context.gapH(12),
        SizedBox(
          height: context.r(240),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: context.edgeSymmetric(horizontal: 16, vertical: 8),
            itemCount: preview.length,
            separatorBuilder: (_, _) => context.gapW(12),
            itemBuilder: (context, i) => SizedBox(
              width: context.r(140),
              child: ProductCardItem(
                product: preview[i],
                onTap: () => context.push(AppRoutes.productDetails, extra: preview[i].id),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
