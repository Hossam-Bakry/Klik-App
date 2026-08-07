import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_details.dart';

/// "Order Summary": the order's status, what the lines came to, shipping, any
/// discount, and the total the customer pays.
class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key, required this.order});

  final OrderDetails order;

  @override
  Widget build(BuildContext context) {
    final currency = context.tr(LocaleKeys.currencyKwd);
    String money(double value) => '${value.toStringAsFixed(2)} $currency';

    final units = order.quantity;
    final itemsLabel = context.tr(units == 1 ? LocaleKeys.item : LocaleKeys.items);

    return Container(
      padding: context.edgeAll(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: context.r(8),
            offset: Offset(0, context.r(2)),
          ),
        ],
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
            label: context.tr(LocaleKeys.status),
            value: context.tr(order.status.labelKey),
          ),
          _Row(
            label: '${context.tr(LocaleKeys.subtotal)} ($units $itemsLabel)',
            value: money(order.subtotal),
          ),
          if (order.tax > 0)
            _Row(label: context.tr(LocaleKeys.tax), value: money(order.tax)),
          _Row(
            label: context.tr(LocaleKeys.shipping),
            value: money(order.deliveryCharge),
          ),
          if (order.totalDiscount > 0)
            _Row(
              label: context.tr(LocaleKeys.discount),
              value: '- ${money(order.totalDiscount)}',
              valueColor: AppColors.success,
            ),
          context.gapH(6),
          Divider(color: AppColors.border, height: context.r(20)),
          _Row(
            label: context.tr(LocaleKeys.total),
            value: money(order.payableAmount),
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
