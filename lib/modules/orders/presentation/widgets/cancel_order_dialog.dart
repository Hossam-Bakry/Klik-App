import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';

/// What the customer chose in [showCancelOrderDialog].
enum CancelOrderChoice {
  /// Confirmed — go ahead and cancel.
  confirm,

  /// Backed out (No, or dismissed).
  dismiss,

  /// Tapped the "Return Policy" link under the buttons.
  returnPolicy,
}

/// Asks before cancelling an order — it can't be undone from the app.
Future<CancelOrderChoice> showCancelOrderDialog(BuildContext context) async {
  final result = await showDialog<CancelOrderChoice>(
    context: context,
    builder: (_) => const _CancelOrderDialog(),
  );
  return result ?? CancelOrderChoice.dismiss;
}

class _CancelOrderDialog extends StatelessWidget {
  const _CancelOrderDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: context.edgeSymmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Padding(
        padding: context.edgeSymmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stand-in illustration: the empty-orders art already carries the
            // parcel + cross the design draws here. Swap it for the dedicated
            // asset when one lands.
            Assets.images.emptyOrderImg.image(width: context.w(150)),
            context.gapH(12),
            Text(
              context.tr(LocaleKeys.cancelOrderConfirm),
              textAlign: TextAlign.center,
              style: context.titleSmall,
            ),
            context.gapH(18),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: context.tr(LocaleKeys.yes),
                    filled: true,
                    onTap: () =>
                        Navigator.of(context).pop(CancelOrderChoice.confirm),
                  ),
                ),
                context.gapW(12),
                Expanded(
                  child: _DialogButton(
                    label: context.tr(LocaleKeys.no),
                    filled: false,
                    onTap: () =>
                        Navigator.of(context).pop(CancelOrderChoice.dismiss),
                  ),
                ),
              ],
            ),
            context.gapH(12),
            GestureDetector(
              onTap: () =>
                  Navigator.of(context).pop(CancelOrderChoice.returnPolicy),
              child: Text(
                context.tr(LocaleKeys.returnPolicy),
                style: context.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBronze,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact bronze dialog button — solid when [filled], else outlined.
class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(10)),
      child: Container(
        height: context.r(46),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.primaryBronze : Colors.transparent,
          border: Border.all(color: AppColors.primaryBronze),
          borderRadius: BorderRadius.circular(context.r(10)),
        ),
        child: Text(
          label,
          style: context.bodyLarge?.copyWith(
            color: filled ? AppColors.surface : AppColors.primaryBronze,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
