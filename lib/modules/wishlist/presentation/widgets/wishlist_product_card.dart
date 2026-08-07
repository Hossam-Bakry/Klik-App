import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/product_cart_controls.dart';
import '../../../../core/widgets/product_favorite_button.dart';
import '../../../home/domain/entities/home_product.dart';

/// Horizontal wishlist row: thumbnail, details, and a favorite + add-to-cart
/// column — the card used by the Wishlist page.
class WishlistProductCard extends StatelessWidget {
  const WishlistProductCard({super.key, required this.product, this.onTap});

  final HomeProduct product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(12));
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: context.r(10),
              offset: Offset(0, context.r(3)),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppNetworkImage(
                url: product.thumbnail,
                width: context.r(84),
                height: context.r(84),
              ),
              Expanded(
                child: Padding(
                  padding: context.edgeSymmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      context.gapH(6),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: context.r(15),
                            color: AppColors.primaryBronze,
                          ),
                          context.gapW(2),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: context.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          context.gapW(8),
                          Text(
                            '${context.tr(LocaleKeys.sold)} (${product.totalSold})',
                            style: context.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      context.gapH(6),
                      Text(
                        '${product.effectivePrice.toStringAsFixed(2)} '
                        '${context.tr(LocaleKeys.currencyKwd)}',
                        style: context.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: context.edgeSymmetric(horizontal: 10, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ProductFavoriteButton(productId: product.id),
                    ProductAddToCartButton(product: product),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
