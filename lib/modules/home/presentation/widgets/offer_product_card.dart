import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/product_cart_controls.dart';
import '../../../../core/widgets/product_favorite_button.dart';
import '../../domain/entities/home_product.dart';
import 'product_price.dart';

/// Wide "Open to offers" row: image + details + quantity stepper, with a
/// negotiate call-to-action footer. Matches the home "Open to offers" list.
class OfferProductCard extends StatelessWidget {
  const OfferProductCard({super.key, required this.product, this.onTap});

  final HomeProduct product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: Radius.circular(context.r(5)),
      topRight: Radius.circular(context.r(5)),
      bottomLeft: Radius.circular(context.r(15)),
      bottomRight: Radius.circular(context.r(15)),
    );
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        // Clip the content, but let the shadow paint outside the bounds.
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AppNetworkImage(
                      url: product.thumbnail,
                      width: context.r(100),
                      height: context.r(100),
                      borderRadius: BorderRadius.circular(context.r(0)),
                    ),
                    if (product.isBidable)
                      Positioned(
                        top: context.r(0),
                        left: context.r(0),
                        child: const NegotiateBadge(),
                      ),
                  ],
                ),
                context.gapW(10),
                Expanded(child: _details(context)),
              ],
            ),
            if (product.isBidable) _negotiateFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _details(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryGold,
                  ),
                ),
              ),
              ProductFavoriteButton(productId: product.id),
            ],
          ),
          context.gapH(4),
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                size: context.r(15),
                color: AppColors.primaryBronze,
              ),
              context.gapW(1),
              Text(
                product.rating.toStringAsFixed(1),
                style: context.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary.withValues(alpha: 0.8),
                ),
              ),
              context.gapW(6),
              Text(
                '${context.tr(LocaleKeys.sold)} (${product.totalSold})',
                style: context.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          context.gapH(8),
          Row(
            children: [
              ProductPrice(product: product),
              if (product.estimatedDeliveryTime.isNotEmpty)
                _deliveryBadge(context),
              const Spacer(),
              // Steps the product's cart quantity — the row's own stock lives
              // in `product.quantity` and is only used for the sold-out state.
              ProductCartStepper(product: product),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deliveryBadge(BuildContext context) {
    return Container(
      padding: context.edgeSymmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        // color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.r(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.truckIcn.svg(
            width: context.r(15),
            height: context.r(15),
          ),
          context.gapW(4),
          Text(
            product.estimatedDeliveryTime,
            style: TextStyle(
              fontSize: context.sp(11),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _negotiateFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.edgeSymmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBronze.withValues(alpha: 0.18),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.r(15)),
          bottomRight: Radius.circular(context.r(15)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.icons.negotiationIcn.svg(
            width: context.r(20),
            height: context.r(20),
            colorFilter: ColorFilter.mode(
              AppColors.primaryBronze,
              BlendMode.srcIn,
            ),
          ),
          context.gapW(6),
          Text(
            context.tr(LocaleKeys.sellerAcceptsOffers),
            style: context.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
