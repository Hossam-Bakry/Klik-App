import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../home/domain/entities/shop_item.dart';

/// Grid-cell aspect ratio the [ShopGridTile] expects: slightly taller than wide
/// so the square-ish logo card and the name label both fit without overflowing.
const double shopTileAspectRatio = 0.82;

/// One tile in the Shops grid: the shop's logo card with its name underneath.
///
/// The logo card takes whatever height the grid cell leaves after the label
/// (via [Expanded]) rather than forcing a square, so the cell's aspect ratio —
/// see `shopTileAspectRatio` — decides how square the logo ends up.
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
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
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
          context.gapH(6),
          Text(
            shop.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
