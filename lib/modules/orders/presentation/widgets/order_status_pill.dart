import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_status.dart';

/// Outlined status pill on an order card: green delivered, red cancelled, blue
/// while it's still on its way.
class OrderStatusPill extends StatelessWidget {
  const OrderStatusPill({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OrderStatus.delivered => AppColors.success,
      OrderStatus.cancelled => AppColors.error,
      _ => AppColors.info,
    };

    return Container(
      padding: context.edgeSymmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(context.r(6)),
        border: Border.all(color: color.withValues(alpha: 0.60)),
      ),
      child: Text(
        context.tr(status.labelKey),
        style: context.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
