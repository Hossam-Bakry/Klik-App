import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../gen/assets.gen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Profile destination (tab index 4). Hosts the sign-out action in its app bar.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(LocaleKeys.profileTitle)),
        actions: [
          IconButton(
            tooltip: context.tr(LocaleKeys.signOut),
            icon: const Icon(Icons.logout),
            // Logging out flips AuthStatus → unauthenticated, and the router
            // guard automatically redirects to /login.
            onPressed: () => sl<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icons.profileIcn.svg(
              width: context.r(56),
              height: context.r(56),
              colorFilter: ColorFilter.mode(
                AppColors.primary.withValues(alpha: 0.4),
                BlendMode.srcIn,
              ),
            ),
            context.gapH(16),
            Text(
              context.tr(LocaleKeys.comingSoon),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.sp(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
