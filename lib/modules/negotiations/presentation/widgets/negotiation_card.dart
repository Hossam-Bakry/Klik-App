import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/negotiation.dart';

/// One offer on the "My Negotiations" list: the product thumbnail (badged with
/// the saving), the product name and negotiated price against the struck-through
/// listed price, a status pill, and the deadline / date on the right.
class NegotiationCard extends StatelessWidget {
  const NegotiationCard({super.key, required this.negotiation, this.onTap});

  final Negotiation negotiation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(10));
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _thumbnail(context),
              Expanded(
                child: Padding(
                  padding: context.edgeSymmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              negotiation.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          context.gapW(8),
                          _StatusPill(status: negotiation.status),
                        ],
                      ),
                      context.gapH(6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: _prices(context)),
                          context.gapW(8),
                          _timing(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbnail(BuildContext context) {
    final percent = negotiation.discountPercent;
    return SizedBox(
      width: context.r(88),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(url: negotiation.thumbnail),
          if (percent > 0)
            PositionedDirectional(
              start: context.r(6),
              bottom: context.r(6),
              child: Container(
                padding: context.edgeSymmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBronze,
                  borderRadius: BorderRadius.circular(context.r(10)),
                ),
                child: Text(
                  '$percent%',
                  style: context.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// The negotiated price, with the listed price struck through beneath it.
  Widget _prices(BuildContext context) {
    final currency = context.tr(LocaleKeys.currencyKwd);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${negotiation.effectivePrice.toStringAsFixed(2)} $currency',
          style: context.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBronze,
          ),
        ),
        if (negotiation.listedPrice > 0) ...[
          context.gapH(2),
          Text(
            '${negotiation.listedPrice.toStringAsFixed(2)} $currency',
            style: context.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }

  /// Right column: the countdown while a deal is live, then the date the offer
  /// was sent.
  Widget _timing(BuildContext context) {
    final left = negotiation.timeLeft;
    final submitted = negotiation.submittedAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (left != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: context.r(13),
                color: AppColors.primaryBronze,
              ),
              context.gapW(4),
              Text(
                _remaining(left),
                style: context.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBronze,
                ),
              ),
            ],
          ),
          context.gapH(6),
        ],
        if (submitted != null)
          Text(
            DateFormat('d MMM yyyy').format(submitted),
            style: context.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  /// "04:50 h" — hours and minutes left on the deal.
  String _remaining(Duration left) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(left.inHours)}:${two(left.inMinutes.remainder(60))} h';
  }
}

/// Outlined status pill: green approved, amber pending, red rejected, blue
/// expired.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final NegotiationStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, key) = switch (status) {
      NegotiationStatus.approved => (AppColors.success, LocaleKeys.approved),
      NegotiationStatus.pending => (AppColors.warning, LocaleKeys.pending),
      NegotiationStatus.rejected => (AppColors.error, LocaleKeys.rejected),
      NegotiationStatus.expired => (AppColors.info, LocaleKeys.expired),
    };

    return Container(
      padding: context.edgeSymmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: color.withValues(alpha: 0.60)),
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
