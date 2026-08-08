import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/app_notification.dart';

/// One notification card: a bronze glyph for what happened, the headline and
/// its detail line, and — on the trailing side — when it arrived, with a dot
/// under it while it's unread.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(10));
    final unread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Container(
        padding: context.edge(left: 12, right: 12, top: 14, bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: context.r(6),
              offset: Offset(0, context.r(2)),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _icon.svg(
              width: context.r(26),
              height: context.r(26),
              colorFilter: const ColorFilter.mode(
                AppColors.primaryBronze,
                BlendMode.srcIn,
              ),
            ),
            context.gapW(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: context.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (notification.message.isNotEmpty) ...[
                    context.gapH(4),
                    Text(
                      notification.message,
                      style: context.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            context.gapW(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  notification.timeLabel,
                  style: context.labelSmall?.copyWith(
                    fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                    color: unread
                        ? AppColors.primaryBronze
                        : AppColors.textSecondary,
                  ),
                ),
                if (unread) ...[
                  context.gapH(8),
                  Container(
                    width: context.r(9),
                    height: context.r(9),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBronze,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The glyph the design pairs with each kind. Everything the API sends today
  /// is an order event, so most rows land on the first three.
  SvgGenImage get _icon => switch (notification.kind) {
    NotificationKind.orderPlaced => Assets.icons.cartIcn,
    NotificationKind.orderDelivery => Assets.icons.orederDeliveryIcn,
    NotificationKind.orderCancelled => Assets.icons.orederCancelIcn,
    NotificationKind.returnApproved => Assets.icons.orderIcn,
    NotificationKind.offer => Assets.icons.moneyDollarIcn,
    NotificationKind.general => Assets.icons.notificationIcn,
  };
}
