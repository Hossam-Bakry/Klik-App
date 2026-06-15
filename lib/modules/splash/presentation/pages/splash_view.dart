import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../gen/assets.gen.dart';

/// Branded splash, shown while [AuthBloc] + [OnboardingCubit] resolve their
/// startup state (AuthStatus.unknown / OnboardingStatus.unknown). Navigation
/// away is handled by the router's redirect guard, not this widget.
///
/// The artwork is the full-screen design export; the Scaffold uses the same
/// cream as the image so it blends on every aspect ratio.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: SizedBox.expand(
        child: Assets.images.splashImg.image(
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
