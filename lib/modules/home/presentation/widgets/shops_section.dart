import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/shop_item.dart';
import 'section_header.dart';

/// Horizontal strip of shop logos.
class ShopsSection extends StatelessWidget {
  const ShopsSection({
    super.key,
    required this.shops,
    this.onSeeAll,
    this.onShopTap,
  });

  final List<ShopItem> shops;
  final VoidCallback? onSeeAll;

  /// Tapped a shop logo — opens that shop's product list.
  final ValueChanged<ShopItem>? onShopTap;

  @override
  Widget build(BuildContext context) {
    if (shops.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.edgeHorizontal(16),
          child: SectionHeader(title: context.tr(LocaleKeys.shops), onSeeAll: onSeeAll),
        ),
        context.gapH(12),
        SizedBox(
          height: context.r(72),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: context.edgeHorizontal(16),
            itemCount: shops.length,
            separatorBuilder: (_, _) => context.gapW(12),
            itemBuilder: (context, i) => _ShopLogo(
              shop: shops[i],
              onTap: onShopTap == null ? null : () => onShopTap!(shops[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShopLogo extends StatelessWidget {
  const _ShopLogo({required this.shop, this.onTap});

  final ShopItem shop;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: context.r(72),
        height: context.r(72),
        // padding: context.edgeAll(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          // borderRadius: BorderRadius.circular(context.r(14)),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.r(50)),
          child: AppNetworkImage(
            url: shop.logo,
            fit: BoxFit.contain,
            borderRadius: BorderRadius.circular(context.r(8)),
          ),
        ),
      ),
    );
  }
}
