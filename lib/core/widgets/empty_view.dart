import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';

/// Centered placeholder for empty / idle list states: an illustration (or a
/// fallback icon), a message, and an optional action button. Shared app-wide
/// for "no results", search prompts and empty lists (products, wishlist, ...).
///
/// For a full-screen "no internet" state use `NoNetworkView`; for a
/// failure-with-retry state use [ErrorView], which builds on this.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.message,
    this.image,
    this.icon,
    this.actionLabel,
    this.onAction,
  }) : assert(
         actionLabel == null || onAction != null,
         'Provide onAction when actionLabel is set',
       );

  /// Message shown under the illustration.
  final String message;

  /// Illustration widget, e.g. `Assets.images.x.image(...)`. Takes precedence
  /// over [icon] when both are supplied.
  final Widget? image;

  /// Fallback icon shown when no [image] is provided.
  final IconData? icon;

  /// When set, renders a text button under the message (needs [onAction]).
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final leading =
        image ??
        (icon == null
            ? null
            : Icon(icon, size: context.r(48), color: AppColors.textSecondary));

    return Center(
      child: Padding(
        padding: context.edgeAll(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading, context.gapH(12)],
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.sp(14),
              ),
            ),
            if (actionLabel != null) ...[
              context.gapH(16),
              AppButton.text(
                label: actionLabel!,
                foregroundColor: AppColors.primary,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
