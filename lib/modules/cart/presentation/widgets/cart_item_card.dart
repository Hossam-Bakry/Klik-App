import 'package:flutter/material.dart';

import '../../../../core/cart/domain/cart_item.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';

/// One cart line: thumbnail, name, price over the struck-through original, a
/// quantity stepper, and the delete action in the corner.
class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
  });

  final CartItem item;

  /// Null while a change is in flight — the stepper locks so a double-tap
  /// can't race itself.
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(10));
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: context.r(8),
            offset: Offset(0, context.r(2)),
          ),
        ],
      ),
      padding: context.edgeAll(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppNetworkImage(
            url: item.thumbnail,
            width: context.r(90),
            height: context.r(90),
            borderRadius: BorderRadius.circular(context.r(8)),
          ),
          context.gapW(12),
          Expanded(child: _details(context)),
        ],
      ),
    );
  }

  Widget _details(BuildContext context) {
    final currency = context.tr(LocaleKeys.currencyKwd);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            context.gapW(8),
            _RemoveButton(onTap: onRemove),
          ],
        ),
        context.gapH(6),
        Text(
          '${item.price.toStringAsFixed(2)} $currency',
          style: context.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBronze,
          ),
        ),
        if (item.hasDiscount) ...[
          context.gapH(2),
          Text(
            '${item.originalPrice.toStringAsFixed(2)} $currency',
            style: context.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
        context.gapH(8),
        _Stepper(
          quantity: item.quantity,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
        ),
      ],
    );
  }
}

/// Bronze trash icon in the card's top-right corner.
class _RemoveButton extends StatelessWidget {
  const _RemoveButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: context.r(20),
      child: Icon(
        Icons.delete_outline_rounded,
        size: context.r(20),
        color: AppColors.primaryBronze,
      ),
    );
  }
}

/// "− 1 +" quantity control: an outlined minus, the count, a filled plus.
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
  });

  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Round(
          icon: Icons.remove,
          filled: false,
          onTap: onDecrement,
        ),
        SizedBox(
          width: context.r(40),
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: context.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        _Round(icon: Icons.add, filled: true, onTap: onIncrement),
      ],
    );
  }
}

class _Round extends StatelessWidget {
  const _Round({required this.icon, required this.filled, this.onTap});

  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = context.r(24);
    final enabled = onTap != null;
    final tint = enabled
        ? AppColors.primaryBronze
        : AppColors.primaryBronze.withValues(alpha: 0.4);

    return InkResponse(
      onTap: onTap,
      radius: size,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? tint : Colors.transparent,
          border: filled
              ? null
              : Border.all(color: AppColors.textSecondary.withValues(alpha: .3)),
        ),
        child: Icon(
          icon,
          size: context.r(15),
          color: filled ? AppColors.surface : tint,
        ),
      ),
    );
  }
}
