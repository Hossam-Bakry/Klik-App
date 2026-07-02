import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_card_item.dart';
import '../../domain/entities/home_product.dart';

/// Full "Best deals for you" listing, reached from the section's "See all".
/// Receives the already-loaded products from the home feed.
class JustForYouPage extends StatelessWidget {
  const JustForYouPage({super.key, required this.products});

  final List<HomeProduct> products;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: Text(context.tr(LocaleKeys.bestDealsForYou))),
      body: products.isEmpty
          ? Center(child: Text(context.tr(LocaleKeys.noItemsYet)))
          : GridView.builder(
              padding: context.edgeAll(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: context.r(12),
                crossAxisSpacing: context.r(12),
                childAspectRatio: 0.62,
              ),
              itemCount: products.length,
              itemBuilder: (context, i) => ProductCardItem(
                product: products[i],
                onTap: () => context.push(AppRoutes.productDetails, extra: products[i].id),
              ),
            ),
    );
  }
}
