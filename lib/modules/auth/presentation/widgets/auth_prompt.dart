import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';

/// Auth gating from any `BuildContext`. Reads the app-level [AuthBloc] (provided
/// at the root), so it works on any screen under the router.
extension AuthGuard on BuildContext {
  /// Whether a real session is active (guests are `false`).
  bool get isAuthenticated => read<AuthBloc>().state.isAuthenticated;

  /// Runs [onAuthenticated] when signed in; otherwise shows the sign-in prompt
  /// so a guest can log in or register before continuing.
  Future<void> requireAuth(VoidCallback onAuthenticated) async {
    if (isAuthenticated) {
      onAuthenticated();
    } else {
      await showAuthRequiredSheet(this);
    }
  }
}

/// Bottom sheet that nudges a guest to sign in or create an account. Tapping a
/// button routes into the auth flow and closes the sheet.
Future<void> showAuthRequiredSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => const _AuthRequiredSheet(),
  );
}

class _AuthRequiredSheet extends StatelessWidget {
  const _AuthRequiredSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.edge(left: 24, right: 24, top: 20, bottom: 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.r(40),
              height: context.r(4),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            context.gapH(20),
            Container(
              padding: context.edgeAll(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: context.r(28),
                color: AppColors.primary,
              ),
            ),
            context.gapH(16),
            Text(
              context.tr(LocaleKeys.signInRequiredTitle),
              style: context.titleMedium,
            ),
            context.gapH(8),
            Text(
              context.tr(LocaleKeys.signInRequiredMessage),
              textAlign: TextAlign.center,
              style: context.bodyMedium,
            ),
            context.gapH(24),
            AppButton.filled(
              label: context.tr(LocaleKeys.logIn),
              onPressed: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.login);
              },
            ),
            context.gapH(12),
            AppButton.outline(
              label: context.tr(LocaleKeys.signUp),
              onPressed: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.register);
              },
            ),
          ],
        ),
      ),
    );
  }
}
