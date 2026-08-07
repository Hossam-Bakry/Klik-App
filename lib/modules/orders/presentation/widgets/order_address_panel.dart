import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_details.dart';

/// The collapsible "Delivery Address" card at the top of the order details:
/// closed it's just the header, open it shows who's receiving and where.
class OrderAddressPanel extends StatelessWidget {
  const OrderAddressPanel({super.key, required this.address});

  final OrderAddress? address;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(10));
    final details = address;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // The default divider lines fight the card's own border.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: context.edgeSymmetric(horizontal: 14),
          childrenPadding: context.edge(left: 14, right: 14, bottom: 14),
          // Both are needed: the cross-axis one lines the rows up, the other
          // stops the whole block from being centred in the card.
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          expandedAlignment: AlignmentDirectional.centerStart,
          leading: Assets.icons.locationIcn.svg(
            width: context.r(22),
            height: context.r(22),
          ),
          title: Text(
            context.tr(LocaleKeys.deliveryAddress),
            style: context.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          children: [
            if (details == null)
              Text(
                context.tr(LocaleKeys.noAddressOnOrder),
                style: context.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else ...[
              if (details.name.isNotEmpty)
                _line(context, details.name, bold: true),
              if (details.type.isNotEmpty) _line(context, details.type),
              if (details.formatted.isNotEmpty)
                _line(context, details.formatted),
              if (details.phone.isNotEmpty) _line(context, details.phone),
            ],
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context, String text, {bool bold = false}) {
    return Padding(
      padding: context.edge(bottom: 4),
      child: Text(
        text,
        style: context.bodySmall?.copyWith(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: bold ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
