import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

/// Profile header shown to guests (no session): a generic avatar, a sign-in
/// nudge, and Log In / Sign Up actions that enter the auth flow.
class ProfileGuestHeader extends StatelessWidget {
  const ProfileGuestHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: context.r(72),
              height: context.r(72),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                color: AppColors.inputLabel,
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: context.r(36),
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            context.gapW(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(LocaleKeys.guestGreeting),
                    style: context.titleLarge,
                  ),
                  context.gapH(4),
                  Text(
                    context.tr(LocaleKeys.guestSubtitle),
                    style: context.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        context.gapH(16),
        Row(
          children: [
            Expanded(
              child: AppButton.filled(
                label: context.tr(LocaleKeys.logIn),
                onPressed: () => context.push(AppRoutes.login),
              ),
            ),
            context.gapW(12),
            Expanded(
              child: AppButton.outline(
                label: context.tr(LocaleKeys.signUp),
                onPressed: () => context.push(AppRoutes.register),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
