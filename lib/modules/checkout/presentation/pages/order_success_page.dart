import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/placed_order.dart';

/// The confirmation after an order goes in: what it was, and the way back to
/// shopping.
class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key, required this.order});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(
          color: AppColors.textPrimary,
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: Text(
          context.tr(LocaleKeys.checkOut),
          style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: context.edge(left: 16, right: 16, top: 16, bottom: 24),
        children: [
          Center(
            child: Assets.images.emptyCheckOutImg.image(width: context.w(200)),
          ),
          context.gapH(16),
          Text(
            context.tr(LocaleKeys.orderPlacedSuccessfully),
            textAlign: TextAlign.center,
            style: context.bodyMedium?.copyWith(color: AppColors.textPrimary),
          ),
          context.gapH(8),
          Text(
            context.tr(LocaleKeys.orderConfirmationEmail),
            textAlign: TextAlign.center,
            style: context.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          context.gapH(20),
          _details(context),
          context.gapH(20),
          Center(
            child: GestureDetector(
              // Home, not pop: the cart and checkout behind this are done with.
              onTap: () => context.go(AppRoutes.home),
              child: Text(
                context.tr(LocaleKeys.continueShopping),
                style: context.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBronze,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Order number, when it was placed, how it's being paid and for how much.
  /// Each row is dropped when the response didn't carry it — the shape of
  /// `place-order` isn't documented.
  Widget _details(BuildContext context) {
    final rows = <(IconData, String, String)>[
      if (order.number.isNotEmpty)
        (Icons.tag_rounded, context.tr(LocaleKeys.orderNumber), order.number),
      if (order.placedLabel.isNotEmpty)
        (
          Icons.access_time_rounded,
          context.tr(LocaleKeys.dateAndTime),
          order.placedLabel,
        ),
      if (order.paymentMethodLabel.isNotEmpty)
        (
          Icons.credit_card_rounded,
          context.tr(LocaleKeys.paymentMethod),
          order.paymentMethodLabel,
        ),
    ];

    return Container(
      padding: context.edgeAll(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(10)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (final (icon, label, value) in rows) ...[
            Row(
              children: [
                Icon(icon, size: context.r(18), color: AppColors.primaryBronze),
                context.gapW(10),
                Expanded(
                  child: Text(
                    label,
                    style: context.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: context.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Divider(color: AppColors.border, height: context.r(24)),
          ],
          Row(
            children: [
              SizedBox(width: context.r(28)),
              Expanded(
                child: Text(
                  context.tr(LocaleKeys.totalPaid),
                  style: context.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                '${order.total.toStringAsFixed(2)} '
                '${context.tr(LocaleKeys.currencyKwd)}',
                style: context.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
