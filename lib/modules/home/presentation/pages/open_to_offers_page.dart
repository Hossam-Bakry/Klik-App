import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/home_product.dart';
import '../widgets/offer_product_card.dart';

/// Full "Open to offers" listing, reached from the section's "See all".
/// Receives the already-loaded bidable products from the home feed.
class OpenToOffersPage extends StatelessWidget {
  const OpenToOffersPage({super.key, required this.products});

  final List<HomeProduct> products;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: Text(context.tr(LocaleKeys.openToOffers))),
      body: products.isEmpty
          ? Center(child: Text(context.tr(LocaleKeys.noItemsYet)))
          : ListView.separated(
              padding: context.edgeAll(16),
              itemCount: products.length,
              separatorBuilder: (_, _) => context.gapH(12),
              itemBuilder: (context, i) => OfferProductCard(product: products[i]),
            ),
    );
  }
}
