import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/payment_method.dart';

/// One row in the payment-method list. The card row carries a "change ›" link
/// through to the card form; the rest are plain selectable rows.
class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
    this.trailingLabel,
    this.onTrailingTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  /// The "change" affordance on the card row (and the masked card once set).
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(10));

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Container(
        padding: context.edgeSymmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
          border: Border.all(
            color: selected ? AppColors.primaryBronze : AppColors.border,
            width: selected ? context.r(1.4) : 1,
          ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: context.r(14),
                offset: Offset(0, context.r(2)),
              ),
            ]
        ),
        child: Row(
          children: [
            _logo(context),
            context.gapW(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr(method.labelKey),
                    style: context.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (method.subtitleKey != null) ...[
                    context.gapH(2),
                    Text(
                      context.tr(method.subtitleKey!),
                      style: context.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingLabel != null)
              GestureDetector(
                onTap: onTrailingTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trailingLabel!,
                      style: context.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBronze,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: context.r(18),
                      color: AppColors.primaryBronze,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Brand marks: the app only ships Apple's and Google's (from social
  /// sign-in). Knet and Tabby fall back to a generic card glyph until their
  /// logos are added to `assets/icons`.
  Widget _logo(BuildContext context) {
    final size = context.r(26);

    return SizedBox(
      width: size,
      height: size,
      child: switch (method) {
        PaymentMethod.applePay => Assets.icons.appleIcn.svg(),
        PaymentMethod.googlePay => Assets.icons.googleIcn.svg(),
        PaymentMethod.cash => Icon(
          Icons.payments_outlined,
          size: size,
          color: AppColors.primaryBronze,
        ),
        _ => Icon(
          Icons.credit_card_rounded,
          size: size,
          color: AppColors.textSecondary,
        ),
      },
    );
  }
}
