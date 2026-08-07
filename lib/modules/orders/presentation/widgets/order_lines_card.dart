import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/order_details.dart';

/// The card listing what the order holds: thumbnail, name (with its variant),
/// how many, and what the line came to.
class OrderLinesCard extends StatelessWidget {
  const OrderLinesCard({super.key, required this.lines, this.onLineTap});

  final List<OrderLine> lines;
  final ValueChanged<OrderLine>? onLineTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.edgeAll(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: context.r(8),
            offset: Offset(0, context.r(2)),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) Divider(color: AppColors.border, height: context.r(20)),
            _Line(line: lines[i], onTap: onLineTap),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.line, this.onTap});

  final OrderLine line;
  final ValueChanged<OrderLine>? onTap;

  @override
  Widget build(BuildContext context) {
    final currency = context.tr(LocaleKeys.currencyKwd);

    return InkWell(
      onTap: onTap == null ? null : () => onTap!(line),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppNetworkImage(
            url: line.thumbnail,
            width: context.r(64),
            height: context.r(64),
            borderRadius: BorderRadius.circular(context.r(8)),
          ),
          context.gapW(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (line.variantLabel.isNotEmpty) ...[
                  context.gapH(2),
                  Text(
                    line.variantLabel,
                    style: context.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                context.gapH(6),
                Row(
                  children: [
                    Text(
                      '${line.effectivePrice.toStringAsFixed(2)} $currency',
                      style: context.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryGold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '×${line.quantity}',
                      style: context.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
