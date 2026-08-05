import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/widgets/product_card_item.dart';
import '../../../home/domain/entities/home_product.dart';

/// Horizontal "Similar Products" rail. Reuses the shared [ProductCardItem] so
/// cards stay visually consistent across the app.
class SimilarProductsSection extends StatelessWidget {
  const SimilarProductsSection({super.key, required this.products, this.onProductTap});

  final List<HomeProduct> products;
  final ValueChanged<HomeProduct>? onProductTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(LocaleKeys.similarProducts),
          style: context.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        context.gapH(12),
        SizedBox(
          height: context.r(225),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: context.edgeSymmetric(vertical: 8),
            itemCount: products.length,
            separatorBuilder: (_, _) => context.gapW(12),
            itemBuilder: (context, i) => SizedBox(
              width: context.r(125),
              child: ProductCardItem(
                product: products[i],
                onTap: onProductTap == null ? null : () => onProductTap!(products[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
