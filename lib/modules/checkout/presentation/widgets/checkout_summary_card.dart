import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/checkout_summary.dart';

/// "Order Summary": what the lines come to, shipping, any discount, and the
/// total. Shown on all three steps, as the design has it.
class CheckoutSummaryCard extends StatelessWidget {
  const CheckoutSummaryCard({
    super.key,
    required this.summary,
    required this.itemCount,
  });

  final CheckoutSummary summary;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final currency = context.tr(LocaleKeys.currencyKwd);
    String money(double value) => '${value.toStringAsFixed(2)} $currency';

    final itemsLabel = context.tr(
      itemCount == 1 ? LocaleKeys.item : LocaleKeys.items,
    );

    return Container(
      padding: context.edgeAll(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(10)),
        border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: context.r(14),
              offset: Offset(0, context.r(2)),
            ),
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(LocaleKeys.orderSummary),
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          context.gapH(12),
          _Row(
            label: '${context.tr(LocaleKeys.subtotal)} '
                '($itemCount $itemsLabel)',
            value: money(summary.subtotal),
          ),
          _Row(
            label: context.tr(LocaleKeys.shipping),
            value: money(summary.shipping),
          ),
          if (summary.tax > 0)
            _Row(label: context.tr(LocaleKeys.tax), value: money(summary.tax)),
          if (summary.discount > 0)
            _Row(
              label: context.tr(LocaleKeys.discount),
              value: '- ${money(summary.discount)}',
              valueColor: AppColors.success,
            ),
          context.gapH(4),
          Divider(color: AppColors.border, height: context.r(20)),
          _Row(
            label: context.tr(LocaleKeys.total),
            value: money(summary.total),
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final labelStyle = emphasized
        ? context.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          )
        : context.bodySmall?.copyWith(color: AppColors.textSecondary);

    final valueStyle = emphasized
        ? context.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryGold,
          )
        : context.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          );

    return Padding(
      padding: context.edge(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          context.gapW(12),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}
