import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../home/domain/entities/shop_item.dart';

/// One tile in the Shops grid: just the shop's logo, matching the shops list
/// design (logos double as the shop's brand identity — no name label needed).
class ShopGridTile extends StatelessWidget {
  const ShopGridTile({super.key, required this.shop, this.onTap});

  final ShopItem shop;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(16));
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: context.r(8),
                offset: Offset(0, context.r(2)),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: AppNetworkImage(
            url: shop.logo,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
