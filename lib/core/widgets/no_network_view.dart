import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../extensions/context_extensions.dart';
import '../localization/locale_keys.dart';
import '../theme/app_colors.dart';

/// Full-screen "no internet connection" state. Shown app-wide (overlaid on the
/// current route) whenever connectivity drops; it's removed automatically once
/// the connection returns.
class NoNetworkView extends StatelessWidget {
  const NoNetworkView({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Center(
        child: Padding(
          padding: context.edgeAll(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.images.noNetworkImg.image(width: context.r(220)),
              context.gapH(8),
              Text(
                context.tr(LocaleKeys.noInternetConnection),
                textAlign: TextAlign.center,
                style: context.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              context.gapH(6),
              Text(
                context.tr(LocaleKeys.checkConnectionRetry),
                textAlign: TextAlign.center,
                style: context.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
