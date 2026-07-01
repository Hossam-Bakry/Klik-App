import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/home_product.dart';
import 'product_price.dart';

/// Compact product card used by the "Best deals for you" carousel and the
/// see-all grid.
class HomeProductCard extends StatelessWidget {
  const HomeProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAdd,
  });

  final HomeProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

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
              clipBehavior: Clip.none,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AppNetworkImage(
                      url: product.thumbnail,
                      height: context.r(110),
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
                if (product.isBidable)
                  Positioned(
                    top: context.r(0),
                    left: context.r(0),
                    child: const NegotiateBadge(),
                  ),
                Positioned(
                  top: context.r(8),
                  right: context.r(8),
                  child: _CircleIcon(
                    icon: product.isFavorite
                        ? Assets.icons.selectedFavoriteIcn
                        : Assets.icons.unSelectedFavoriteIcn,
                    color: product.isFavorite
                        ? AppColors.error
                        : AppColors.surface,
                  ),
                ),
                Positioned(
                  bottom: context.r(-14),
                  right: context.r(6),
                  child: _AddButton(onTap: onAdd),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: context.edgeSymmetric(horizontal: 5, vertical: 10),
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

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.color});

  final SvgGenImage icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.r(26),
      height: context.r(26),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: icon.svg(),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.r(28),
        height: context.r(28),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, size: context.r(18), color: Colors.white),
      ),
    );
  }
}
