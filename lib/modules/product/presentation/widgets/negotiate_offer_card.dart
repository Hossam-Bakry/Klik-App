import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product_bid.dart';

/// "Negotiate Offer" panel on bidable products: the customer's remaining offers
/// and a chevron that opens the "Price Negotiate" sheet, where the actual
/// bidding happens (see `showPriceNegotiateSheet`).
class NegotiateOfferCard extends StatelessWidget {
  const NegotiateOfferCard({super.key, required this.bid, this.onTap});

  /// `null` when the API reported no negotiation data — the card still explains
  /// that offers are private, just without a count.
  final ProductBid? bid;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(25));
    return Material(
      color: AppColors.primaryBronze.withValues(alpha: 0.2),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: context.edgeAll(16),
          child: Row(
            children: [
              _icon(context),
              context.gapW(12),
              Expanded(child: _text(context)),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primaryBronze,
                size: context.r(26),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon(BuildContext context) {
    return Container(
      width: context.r(44),
      height: context.r(44),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primaryBronze,
        shape: BoxShape.circle,
      ),
      child: Assets.icons.negotiationIcn.svg(
        width: context.r(24),
        height: context.r(24),
        colorFilter: const ColorFilter.mode(AppColors.surface, BlendMode.srcIn),
      ),
    );
  }

  Widget _text(BuildContext context) {
    final attemptsLeft = bid?.attemptsLeft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(LocaleKeys.negotiateOffer),
          style: context.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBronze,
          ),
        ),
        if (attemptsLeft != null) ...[
          context.gapH(4),
          Text(
            context
                .tr(LocaleKeys.offersLeft)
                .replaceFirst('{count}', '$attemptsLeft'),
            style: context.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
        Text(
          context.tr(LocaleKeys.onlyYouSeeOffers),
          style: context.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
