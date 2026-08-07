import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_status.dart';

/// The status filter above the Orders list: "All" plus one chip per bucket.
/// The selected chip is solid bronze, like the negotiations screen.
class OrderFilterChips extends StatelessWidget {
  const OrderFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// `null` is the "All" chip.
  final OrderListFilter? selected;
  final ValueChanged<OrderListFilter?> onSelected;

  @override
  Widget build(BuildContext context) {
    const filters = <OrderListFilter?>[
      null,
      OrderListFilter.inProgress,
      OrderListFilter.delivered,
      OrderListFilter.cancelled,
    ];

    return SizedBox(
      height: context.r(40),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: context.edgeSymmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, _) => context.gapW(8),
        itemBuilder: (context, i) {
          final filter = filters[i];
          return _Chip(
            label: context.tr(filter?.labelKey ?? LocaleKeys.all),
            icon: _icon(filter),
            selected: filter == selected,
            onTap: () => onSelected(filter),
          );
        },
      ),
    );
  }

  SvgGenImage? _icon(OrderListFilter? filter) => switch (filter) {
    null => null,
    OrderListFilter.inProgress => Assets.icons.pendingIcn,
    OrderListFilter.delivered => Assets.icons.orederDeliveryIcn,
    OrderListFilter.cancelled => Assets.icons.orederCancelIcn,
  };
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final SvgGenImage? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(20));
    final foreground = selected ? AppColors.surface : AppColors.primaryBronze;

    return Material(
      color: selected
          ? AppColors.primaryBronze
          : AppColors.dark.withValues(alpha: 0.05),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: context.edgeSymmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!.svg(
                  width: context.r(15),
                  height: context.r(15),
                  colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                ),
                context.gapW(6),
              ],
              Text(
                label,
                style: context.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
