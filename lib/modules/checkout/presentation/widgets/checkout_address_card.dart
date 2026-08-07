import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../address/domain/entities/address.dart';

/// The delivery address on the checkout steps: who's receiving and where, with
/// the selected marker on the address step.
class CheckoutAddressCard extends StatelessWidget {
  const CheckoutAddressCard({
    super.key,
    required this.address,
    this.showSelectedMark = true,
  });

  final Address address;

  /// The address step marks the chosen one; the review step just shows it.
  final bool showSelectedMark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.edgeAll(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(10)),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: context.r(22),
            color: AppColors.primaryBronze,
          ),
          context.gapW(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.fullName,
                  style: context.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                context.gapH(4),
                Text(
                  '${address.countryCode}${address.phone}',
                  style: context.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                context.gapH(6),
                Text(
                  _lines(context),
                  style: context.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (showSelectedMark) ...[
            context.gapW(8),
            Icon(
              Icons.radio_button_checked_rounded,
              size: context.r(20),
              color: AppColors.primaryBronze,
            ),
          ],
        ],
      ),
    );
  }

  /// The address as one paragraph, skipping the parts left blank.
  String _lines(BuildContext context) {
    final parts = [
      address.flatNumber,
      address.line1,
      address.line2,
      address.area,
      address.city,
    ].where((part) => part != null && part.trim().isNotEmpty);

    return parts.isEmpty ? context.tr(LocaleKeys.noAddressOnOrder) : parts.join(', ');
  }
}
