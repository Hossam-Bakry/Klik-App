import 'package:flutter/material.dart';

import '../../../../core/cart/domain/cart_item.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';

/// The review step's basket: each line with a live quantity stepper, so the
/// order can still be adjusted on the last screen before it's placed.
class CheckoutItemsCard extends StatelessWidget {
  const CheckoutItemsCard({
    super.key,
    required this.items,
    required this.isPending,
    required this.onIncrement,
    required this.onDecrement,
  });

  final List<CartItem> items;

  /// Whether this line has a change in flight — its stepper locks.
  final bool Function(CartItem) isPending;

  final ValueChanged<CartItem> onIncrement;
  final ValueChanged<CartItem> onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.edgeAll(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(10)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(color: AppColors.border, height: context.r(20)),
            _Line(
              item: items[i],
              busy: isPending(items[i]),
              onIncrement: () => onIncrement(items[i]),
              onDecrement: () => onDecrement(items[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.item,
    required this.busy,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartItem item;
  final bool busy;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppNetworkImage(
          url: item.thumbnail,
          width: context.r(56),
          height: context.r(56),
          borderRadius: BorderRadius.circular(context.r(8)),
        ),
        context.gapW(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              context.gapH(6),
              _Stepper(
                quantity: item.quantity,
                onIncrement: busy ? null : onIncrement,
                onDecrement: busy ? null : onDecrement,
              ),
            ],
          ),
        ),
        context.gapW(8),
        Text(
          '${item.lineTotal.toStringAsFixed(2)} '
          '${context.tr(LocaleKeys.currencyKwd)}',
          style: context.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryGold,
          ),
        ),
      ],
    );
  }
}

/// "− 1 +", the compact variant the review card uses.
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
      mainAxisSize: MainAxisSize.min,
      children: [
        _Round(icon: Icons.remove, filled: false, onTap: onDecrement),
        SizedBox(
          width: context.r(32),
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
    final size = context.r(22);
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
          size: context.r(14),
          color: filled ? AppColors.surface : tint,
        ),
      ),
    );
  }
}
