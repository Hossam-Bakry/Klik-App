import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_details.dart';
import '../../domain/entities/order_status.dart';

/// The four-step progress rail on the order-details screen: Pending →
/// Processing → On Delivery → Delivered, each with a state chip.
///
/// Only two of the four timestamps exist in the API — `placed_at` for the first
/// step and `estimated_delivery_date` for the last — so the middle steps carry
/// no time rather than a made-up one. A cancelled order leaves the happy path,
/// so it gets a single banner instead of the rail.
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.order});

  final OrderDetails order;

  @override
  Widget build(BuildContext context) {
    if (order.status.isCancelled) return _cancelledBanner(context);

    final reached = order.status.stage?.index ?? 0;
    // A delivered order has finished the rail, so its last step reads Complete
    // rather than sitting there "in progress".
    final finished = order.status.isDelivered;
    const stages = OrderStage.values;

    return Column(
      children: [
        for (var i = 0; i < stages.length; i++)
          _Step(
            stage: stages[i],
            // Everything before the current step is done; the current one is
            // live; the rest haven't started.
            state: i < reached || finished
                ? _StepState.complete
                : (i == reached ? _StepState.active : _StepState.upcoming),
            timestamp: switch (stages[i]) {
              OrderStage.placed => order.placedLabel,
              OrderStage.delivered => order.estimatedDelivery.isEmpty
                  ? ''
                  : '${context.tr(LocaleKeys.expected)} '
                        '${order.estimatedDelivery}',
              _ => '',
            },
            isLast: i == stages.length - 1,
          ),
      ],
    );
  }

  Widget _cancelledBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.edgeAll(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.r(10)),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cancel_outlined,
            size: context.r(22),
            color: AppColors.error,
          ),
          context.gapW(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(LocaleKeys.orderCancelled),
                  style: context.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                if (order.placedLabel.isNotEmpty) ...[
                  context.gapH(2),
                  Text(
                    order.placedLabel,
                    style: context.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepState { complete, active, upcoming }

class _Step extends StatelessWidget {
  const _Step({
    required this.stage,
    required this.state,
    required this.timestamp,
    required this.isLast,
  });

  final OrderStage stage;
  final _StepState state;
  final String timestamp;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final done = state != _StepState.upcoming;
    final accent = done ? AppColors.primaryBronze : AppColors.textSecondary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The rail: a circled icon with the connector running to the next one.
          Column(
            children: [
              Container(
                width: context.r(28),
                height: context.r(28),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.10),
                  border: Border.all(color: accent.withValues(alpha: 0.6)),
                ),
                child: Icon(_icon, size: context.r(15), color: accent),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: context.r(1.5),
                    color: accent.withValues(alpha: 0.45),
                  ),
                ),
            ],
          ),
          context.gapW(12),
          Expanded(
            child: Padding(
              padding: context.edge(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(stage.labelKey),
                    style: context.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: done
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (timestamp.isNotEmpty) ...[
                    context.gapH(2),
                    Text(
                      timestamp,
                      style: context.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          context.gapW(8),
          _StateChip(state: state),
        ],
      ),
    );
  }

  IconData get _icon => switch (stage) {
    OrderStage.placed => Icons.check_circle_outline_rounded,
    OrderStage.processing => Icons.more_horiz_rounded,
    OrderStage.onDelivery => Icons.local_shipping_outlined,
    OrderStage.delivered => Icons.inventory_2_outlined,
  };
}

/// "Complete" / "Delivering" / "Pending" beside a step.
class _StateChip extends StatelessWidget {
  const _StateChip({required this.state});

  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final (color, key) = switch (state) {
      _StepState.complete => (AppColors.success, LocaleKeys.complete),
      _StepState.active => (AppColors.primaryBronze, LocaleKeys.inProgress),
      _StepState.upcoming => (AppColors.textSecondary, LocaleKeys.pending),
    };

    return Container(
      // Fixed height: a Container that centres its child grows to whatever the
      // row allows, and the rows here are as tall as their two lines of text.
      height: context.r(26),
      constraints: BoxConstraints(minWidth: context.r(84)),
      alignment: Alignment.center,
      padding: context.edgeSymmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(context.r(6)),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        context.tr(key),
        style: context.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
