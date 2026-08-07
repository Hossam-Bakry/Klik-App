import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/order_details.dart';

/// Asks which product to review when an order holds more than one — the review
/// screen rates a single product, and `POST /api/product-review` takes one
/// `product_id`.
///
/// Resolves to the chosen line, or null if dismissed.
Future<OrderLine?> showReviewProductPicker(
  BuildContext context, {
  required List<OrderLine> products,
}) {
  return showModalBottomSheet<OrderLine>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ReviewProductPicker(products: products),
  );
}

class _ReviewProductPicker extends StatelessWidget {
  const _ReviewProductPicker({required this.products});

  final List<OrderLine> products;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.edge(left: 20, right: 20, top: 12, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: context.r(44),
              height: context.r(4),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(context.r(4)),
              ),
            ),
          ),
          context.gapH(16),
          Text(
            context.tr(LocaleKeys.whichProductToReview),
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          context.gapH(12),
          for (final product in products)
            InkWell(
              onTap: () => Navigator.of(context).pop(product),
              child: Padding(
                padding: context.edgeSymmetric(vertical: 8),
                child: Row(
                  children: [
                    AppNetworkImage(
                      url: product.thumbnail,
                      width: context.r(48),
                      height: context.r(48),
                      borderRadius: BorderRadius.circular(context.r(8)),
                    ),
                    context.gapW(12),
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: context.r(22),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
