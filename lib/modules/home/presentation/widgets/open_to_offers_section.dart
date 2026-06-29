import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../domain/entities/home_product.dart';
import 'offer_product_card.dart';
import 'section_header.dart';

/// "Open to offers" — a vertical list of the first few bidable products, with a
/// "See all" that opens the full list.
class OpenToOffersSection extends StatelessWidget {
  const OpenToOffersSection({super.key, required this.products, this.onSeeAll, this.previewCount = 5});

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
          child: SectionHeader(title: context.tr(LocaleKeys.openToOffers), onSeeAll: onSeeAll),
        ),
        context.gapH(12),
        Padding(
          padding: context.edgeHorizontal(16),
          child: Column(
            children: [
              for (var i = 0; i < preview.length; i++) ...[
                OfferProductCard(product: preview[i]),
                if (i != preview.length - 1) context.gapH(12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
