import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';

/// Sticky footer with the two product CTAs: an outlined "Add to Cart" (with the
/// cart glyph) and a filled bronze "Buy Now".
class ProductBottomBar extends StatelessWidget {
  const ProductBottomBar({super.key, this.onAddToCart, this.onBuyNow});

  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.r(16),
        context.r(12),
        context.r(16),
        context.r(12) + MediaQuery.viewPaddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _CtaButton(
              label: context.tr(LocaleKeys.addToCart),
              filled: false,
              leading: Assets.icons.cartIcn.svg(
                width: context.r(20),
                height: context.r(20),
              ),
              onTap: onAddToCart,
            ),
          ),
          context.gapW(12),
          Expanded(
            child: _CtaButton(
              label: context.tr(LocaleKeys.buyNow),
              filled: true,
              onTap: onBuyNow,
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({required this.label, required this.filled, this.leading, this.onTap});

  final String label;
  final bool filled;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(14));
    return Material(
      color: filled ? AppColors.primary : AppColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: context.r(52),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: filled ? null : Border.all(color: AppColors.primary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, context.gapW(8)],
              Text(
                label,
                style: context.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: filled ? AppColors.surface : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
