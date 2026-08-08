import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';

/// "Have a Coupon Code?" — the field and its Apply button.
class CouponCard extends StatelessWidget {
  const CouponCard({
    super.key,
    required this.controller,
    required this.onApply,
    this.applying = false,
    this.appliedCode = '',
  });

  final TextEditingController controller;
  final VoidCallback onApply;
  final bool applying;

  /// Set once a coupon stuck, so the card can say which one.
  final String appliedCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.edgeAll(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(10)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: context.r(14),
            offset: Offset(0, context.r(2)),
          ),
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: context.r(28),
            color: AppColors.primaryBronze,
          ),
          context.gapW(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(LocaleKeys.haveACouponCode),
                  style: context.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                context.gapH(10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: context.r(44),
                        child: TextField(
                          controller: controller,
                          // textCapitalization: TextCapitalization.characters,
                          style: context.bodySmall,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: AppColors.surface,
                            hintText: context.tr(LocaleKeys.enterCouponCode),
                            hintStyle: context.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            // contentPadding: context.edgeSymmetric(
                            //   horizontal: 12,
                            //   vertical: 24
                            // ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(context.r(8)),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(context.r(8)),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(context.r(8)),
                              borderSide: const BorderSide(
                                color: AppColors.primaryBronze,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    context.gapW(10),
                    _ApplyButton(applying: applying, onTap: onApply),
                  ],
                ),
                if (appliedCode.isNotEmpty) ...[
                  context.gapH(8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: context.r(16),
                        color: AppColors.success,
                      ),
                      context.gapW(6),
                      Expanded(
                        child: Text(
                          '${context.tr(LocaleKeys.couponApplied)} '
                          '($appliedCode)',
                          style: context.labelSmall?.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  const _ApplyButton({required this.applying, required this.onTap});

  final bool applying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: applying ? null : onTap,
      child: Container(
        height: context.r(44),
        padding: context.edgeSymmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryBronze,
          borderRadius: BorderRadius.circular(context.r(8)),
        ),
        child: applying
            ? SizedBox(
                width: context.r(18),
                height: context.r(18),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                context.tr(LocaleKeys.apply),
                style: context.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.surface,
                ),
              ),
      ),
    );
  }
}
