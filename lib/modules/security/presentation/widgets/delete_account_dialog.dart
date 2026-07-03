import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';

/// Shows the "Are you sure you want to delete your account?" dialog and
/// resolves to `true` when the user taps Yes, `false` otherwise.
Future<bool> showDeleteAccountDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => const _DeleteAccountDialog(),
  );
  return result ?? false;
}

class _DeleteAccountDialog extends StatelessWidget {
  const _DeleteAccountDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: context.edgeSymmetric(horizontal: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Padding(
        padding: context.edgeSymmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.images.deleteAccountImg.image(
              width: context.w(150),
              height: context.h(95),
            ),
            context.gapH(12),
            Text(
              context.tr(LocaleKeys.deleteAccountConfirm),
              textAlign: TextAlign.center,
              style: context.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
            ),
            context.gapH(20),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: context.tr(LocaleKeys.yes),
                    filled: true,
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
                context.gapW(12),
                Expanded(
                  child: _DialogButton(
                    label: context.tr(LocaleKeys.no),
                    filled: false,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
              ],
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
      borderRadius: BorderRadius.circular(context.r(12)),
      child: Container(
        height: context.r(48),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.transparent,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(context.r(12)),
        ),
        child: Text(
          label,
          style: context.bodyLarge?.copyWith(
            color: filled ? AppColors.surface : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
