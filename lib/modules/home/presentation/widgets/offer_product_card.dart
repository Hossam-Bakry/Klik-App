import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/home_product.dart';
import 'product_price.dart';

/// Wide "Open to offers" row: image + details + quantity stepper, with a
/// negotiate call-to-action footer. Matches the home "Open to offers" list.
class OfferProductCard extends StatelessWidget {
  const OfferProductCard({super.key, required this.product, this.onTap, this.onIncrement, this.onDecrement});

  final HomeProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(5));
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
                      Positioned(top: context.r(0), left: context.r(0), child: const NegotiateBadge()),
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
                  style: TextStyle(
                    fontSize: context.sp(10),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryGold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBronze
                ),
                child: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: context.r(20),
                  color: product.isFavorite ? AppColors.surface : AppColors.surface,
                ),
              ),
            ],
          ),
          context.gapH(4),
          Row(
            children: [
              Icon(Icons.star_rounded, size: context.r(13), color: AppColors.primaryBronze),
              context.gapW(1),
              Text(
                product.rating.toStringAsFixed(1),
                style: TextStyle(fontSize: context.sp(8), color: AppColors.textPrimary.withValues(alpha: 0.5)),
              ),
              context.gapW(8),
              Text(
                '${context.tr(LocaleKeys.sold)} (${product.totalSold})',
                style: TextStyle(fontSize: context.sp(8), color: AppColors.textPrimary.withValues(alpha: 0.5)),
              ),
            ],
          ),
          context.gapH(8),
          Row(
            children: [
              ProductPrice(product: product),
              if (product.estimatedDeliveryTime.isNotEmpty) _deliveryBadge(context),
              const Spacer(),
              _QuantityStepper(quantity: product.quantity, onIncrement: onIncrement, onDecrement: onDecrement),
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
          Assets.icons.truckIcn.svg(),
          context.gapW(4),
          Text(
            '${product.estimatedDeliveryTime} days',
            style: TextStyle(fontSize: context.sp(11), color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _negotiateFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.edgeSymmetric(horizontal: 12, vertical: 8),
      color: AppColors.primaryBronze.withValues(alpha: 0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.handshake_outlined, size: context.r(15), color: AppColors.primary),
          context.gapW(6),
          Text(
            context.tr(LocaleKeys.sellerAcceptsOffers),
            style: TextStyle(fontSize: context.sp(11), color: AppColors.primary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, this.onIncrement, this.onDecrement});

  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(icon: Icons.remove, filled: false, onTap: onDecrement),
        Padding(
          padding: context.edgeSymmetric(horizontal: 10),
          child: Text(
            '$quantity',
            style: TextStyle(fontSize: context.sp(14), fontWeight: FontWeight.w600),
          ),
        ),
        _StepButton(icon: Icons.add, filled: true, onTap: onIncrement),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.filled, this.onTap});

  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.r(18),
        height: context.r(18),
        decoration: BoxDecoration(
          color: filled ? AppColors.primaryBronze : Colors.transparent,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: AppColors.primaryBronze.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, size: context.r(12), color: filled ? Colors.white : AppColors.primaryBronze),
      ),
    );
  }
}
