import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_button.dart';

/// Log In / Sign Up row shown on the guest Profile tab, entering the auth flow.
class GuestAuthButtons extends StatelessWidget {
  const GuestAuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
