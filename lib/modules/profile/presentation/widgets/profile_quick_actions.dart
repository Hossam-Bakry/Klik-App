import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../gen/assets.gen.dart';

/// The three shortcut tiles (Orders, My Negotiation, Wishlist) shown in a
/// single card just below the profile header.
class ProfileQuickActions extends StatelessWidget {
  const ProfileQuickActions({
    super.key,
    this.onOrders,
    this.onNegotiation,
    this.onWishlist,
  });

  final VoidCallback? onOrders;
  final VoidCallback? onNegotiation;
  final VoidCallback? onWishlist;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Assets.icons.orderIcn,
            label: context.tr(LocaleKeys.orders),
            onTap: onOrders,
          ),
        ),
        Expanded(
          child: _QuickAction(
            icon: Assets.icons.negotiationIcn,
            label: context.tr(LocaleKeys.myNegotiation),
            onTap: onNegotiation,
          ),
        ),
        Expanded(
          child: _QuickAction(
            icon: Assets.icons.wishlistIcn,
            label: context.tr(LocaleKeys.wishlist),
            onTap: onWishlist,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, this.onTap});

  final SvgGenImage icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(12)),
      child: Padding(
        padding: context.edgeSymmetric(vertical: 4),
        child: Column(
          children: [
            icon.svg(
              width: context.r(26),
              height: context.r(26),
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            context.gapH(8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: context.bodyMedium?.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
