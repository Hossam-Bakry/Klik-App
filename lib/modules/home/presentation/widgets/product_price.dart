import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/home_product.dart';

/// Effective price + struck-through original + discount badge — the price block
/// shared by the home product cards.
class ProductPrice extends StatelessWidget {
  const ProductPrice({super.key, required this.product});

  final HomeProduct product;

  @override
  Widget build(BuildContext context) {
    final currency = context.tr(LocaleKeys.currencyKwd);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${product.effectivePrice.toStringAsFixed(2)} $currency',
          style: TextStyle(fontSize: context.sp(10), fontWeight: FontWeight.w500, color: AppColors.textPrimaryGold),
        ),
        context.gapW(6),
        if (product.hasDiscount) ...[
          Row(
            children: [
              Text(
                '${product.price.toStringAsFixed(2)} $currency',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.sp(8),
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              context.gapW(4),
              Text(
                '${product.discountPercentage.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: context.sp(8), fontWeight: FontWeight.w700, color: AppColors.success),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Small "Negotiate" pill overlaid on a bidable product's image.
class NegotiateBadge extends StatelessWidget {
  const NegotiateBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.edgeSymmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryBronze,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.r(5)),
          bottomRight: Radius.circular(context.r(5)),
        ),
      ),
      child: Text(
        context.tr(LocaleKeys.negotiate),
        style: TextStyle(fontSize: context.sp(9), fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }
}
