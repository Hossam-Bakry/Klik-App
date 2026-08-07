import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_date_range.dart';

/// The date-window picker beside the search field ("Today", "Last 3 Weeks", …).
///
/// Filters locally: the orders endpoint ignores date parameters, so this
/// narrows the rows already loaded.
class OrderDateDropdown extends StatelessWidget {
  const OrderDateDropdown({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final OrderDateRange selected;
  final ValueChanged<OrderDateRange> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<OrderDateRange>(
      initialValue: selected,
      onSelected: onSelected,
      offset: Offset(0, context.r(44)),
      color: AppColors.surface,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.r(10)),
      ),
      itemBuilder: (context) => [
        for (final range in OrderDateRange.values)
          PopupMenuItem(
            value: range,
            child: Text(
              context.tr(range.labelKey),
              style: context.bodySmall?.copyWith(
                fontWeight: range == selected
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: range == selected
                    ? AppColors.primaryBronze
                    : AppColors.textPrimary,
              ),
            ),
          ),
      ],
      child: Container(
        height: context.r(40),
        padding: context.edgeSymmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(context.r(10)),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                context.tr(selected.labelKey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            context.gapW(4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: context.r(20),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
