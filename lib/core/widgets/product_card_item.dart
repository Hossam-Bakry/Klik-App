import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../modules/home/domain/entities/home_product.dart';
import '../../modules/home/presentation/widgets/product_price.dart';
import '../extensions/context_extensions.dart';
import '../localization/locale_keys.dart';
import '../theme/app_colors.dart';
import 'app_network_image.dart';
import 'product_cart_controls.dart';
import 'product_favorite_button.dart';

/// Compact product card shared across the app — the "Best deals for you"
/// carousel/see-all grid, the Categories product grid, and the product
/// details "Similar products" rail all render the same card.
class ProductCardItem extends StatelessWidget {
  const ProductCardItem({super.key, required this.product, this.onTap});

  final HomeProduct product;
  final VoidCallback? onTap;

  /// How far the cart button drops below the image, in design px.
  static const double _addButtonOverhang = 14;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(8));
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: context.r(8),
              offset: Offset(0, context.r(2)),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // The cart button straddles the image's bottom edge, so the
                // stack reserves that overhang as padding under the image
                // rather than letting the button hang outside its box: a child
                // painted outside its parent doesn't get hit-tested, and the
                // half below the edge was falling through to the card's own tap
                // (opening the product instead of adding it).
                Padding(
                  padding: context.edge(bottom: _addButtonOverhang),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      AppNetworkImage(
                        url: product.thumbnail,
                        height: context.r(135),
                        width: double.infinity,
                      ),
                      if (product.isOutOfStock)
                        Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: context.r(25),
                          color: AppColors.textSecondary.withValues(alpha: 0.08),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Assets.icons.lockIcn.svg(
                                width: context.r(16),
                                height: context.r(16),
                              ),
                              context.gapW(4),
                              Text(
                                context.tr(LocaleKeys.outOfStock),
                                style: context.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimaryGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (product.isBidable)
                  Positioned(
                    top: context.r(0),
                    left: context.r(0),
                    child: const NegotiateBadge(),
                  ),
                Positioned(
                  top: context.r(8),
                  right: context.r(8),
                  child: ProductFavoriteButton(productId: product.id),
                ),
                Positioned(
                  bottom: 0,
                  right: context.r(6),
                  child: ProductAddToCartButton(product: product),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: context.edge(left:5,right:5, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    context.gapH(4),
                    Text(
                      '${context.tr(LocaleKeys.sold)} (${product.totalSold})',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: context.sp(11),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    context.gapH(6),
                    ProductPrice(product: product),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
