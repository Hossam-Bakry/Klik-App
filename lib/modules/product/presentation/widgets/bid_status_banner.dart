import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product_bid.dart';

/// Tinted strip above the negotiate card telling the customer where their last
/// offer stands: amber while the seller reviews it, red once declined, blue on a
/// counter offer, green when approved (with the deadline to buy at the agreed
/// price), grey once that deadline passes.
///
/// Only rendered when the product is bidable *and* an offer has been sent —
/// `ProductBid.status` being null means there's nothing to report. The full
/// picture lives in the "Price Negotiate" sheet.
class BidStatusBanner extends StatelessWidget {
  const BidStatusBanner({super.key, required this.bid});

  final ProductBid bid;

  @override
  Widget build(BuildContext context) {
    final status = bid.status;
    if (status == null) return const SizedBox.shrink();

    final (statusColor, icon, iconColor, message) = switch (status) {
      BidStatus.pending => (
        AppColors.pendingStatusColor.withValues(alpha: 0.5),
        Icons.access_time_rounded,
        AppColors.primaryBronze,
        context.tr(LocaleKeys.bidPending),
      ),
      BidStatus.declined => (
        AppColors.rejectStatusColor.withValues(alpha: 0.05),
        Icons.cancel_outlined,
        AppColors.rejectStatusColor,
        context.tr(LocaleKeys.bidDeclined),
      ),
      BidStatus.countered => (
        AppColors.counterStatusColor.withValues(alpha: 0.5),
        Icons.sell_outlined,
        AppColors.primaryBronze,
        context.tr(LocaleKeys.bidCountered),
      ),
      BidStatus.approved => (
        AppColors.approvedStatusColor.withValues(alpha: 0.2),
        Icons.check_circle_outline_rounded,
        AppColors.success,
        context.tr(LocaleKeys.bidApproved),
      ),
      BidStatus.expired => (
        AppColors.textSecondary,
        Icons.access_time_rounded,
        AppColors.textSecondary,
        context.tr(LocaleKeys.bidExpired),
      ),
    };

    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: context.edgeSymmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(context.r(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: context.r(16), color: iconColor),
          context.gapW(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: context.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                // An approved price holds only until it expires, so the deadline
                // is part of the message rather than a detail elsewhere.
                if (bid.isApproved && bid.expiresAt != null) ...[
                  context.gapH(2),
                  Text(
                    '${context.tr(LocaleKeys.bidExpiresAt)}: '
                    '${_formatExpiry(bid.expiresAt!)}',
                    style: context.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.2
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

  /// Local date + time down to the second, e.g. `6/24/2026, 6:22:18 PM` —
  /// an offer window can be short, so the seconds matter.
  String _formatExpiry(DateTime at) =>
      DateFormat('M/d/y, h:mm:ss a').format(at);
}
