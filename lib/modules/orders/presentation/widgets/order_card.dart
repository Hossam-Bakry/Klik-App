import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_summary.dart';
import 'order_rating_stars.dart';
import 'order_status_pill.dart';

/// One row on the Orders list: the status and when it was placed, the order
/// itself (code, units, total), a "View all details" link, and — once it's
/// been delivered — the rating strip.
///
/// The design puts the shop's logo and name on this card. `GET /api/orders`
/// carries neither (nor any product thumbnail): both only come back from
/// `GET /api/order-details`, so the card leads with the order icon and code
/// instead of firing a details request per row.
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onRate,
  });

  final OrderSummary order;
  final VoidCallback? onTap;

  /// Tapped a star on a delivered order. Null hides the rating strip.
  final ValueChanged<int>? onRate;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(10));
    final rateable = order.status.isDelivered && onRate != null;

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Container(
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: context.edge(left: 12, right: 12, top: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      OrderStatusPill(status: order.status),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          order.placedLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  context.gapH(10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _leading(context),
                      context.gapW(12),
                      Expanded(child: _details(context)),
                    ],
                  ),
                  context.gapH(8),
                  Text(
                    context.tr(LocaleKeys.viewAllDetails),
                    style: context.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBronze,
                    ),
                  ),
                ],
              ),
            ),
            if (rateable) _rateStrip(context),
          ],
        ),
      ),
    );
  }

  /// Stands in for the design's product photo, which the list payload doesn't
  /// carry.
  Widget _leading(BuildContext context) {
    return Container(
      width: context.r(56),
      height: context.r(56),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaryBronze.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.r(8)),
      ),
      child: Assets.icons.orderIcn.svg(
        width: context.r(26),
        height: context.r(26),
        colorFilter: const ColorFilter.mode(
          AppColors.primaryBronze,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _details(BuildContext context) {
    final units = order.quantity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                order.code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            context.gapW(8),
            Text(
              '$units ${context.tr(units == 1 ? LocaleKeys.item : LocaleKeys.items)}',
              style: context.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        context.gapH(6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                order.paymentMethod,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            context.gapW(8),
            Text(
              '${order.amount.toStringAsFixed(2)} '
              '${context.tr(LocaleKeys.currencyKwd)}',
              style: context.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryGold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// "Rate ★★★★★" footer. Only delivered orders get it — the review endpoint
  /// rates something the customer actually received.
  Widget _rateStrip(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryBronze.withValues(alpha: 0.10),
      padding: context.edgeSymmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(
            context.tr(LocaleKeys.rate),
            style: context.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          OrderRatingStars(onRated: onRate),
        ],
      ),
    );
  }
}
