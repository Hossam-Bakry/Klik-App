import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Circular white social sign-in button with a soft shadow.
///
/// Logos are simple placeholders (a colored "G" and the Apple glyph) — drop in
/// real brand SVGs under assets/icons and swap the [child] when available.
class SocialButton extends StatelessWidget {
  const SocialButton._({super.key, required this.onPressed, required this.child});

  SocialButton.google({Key? key, required VoidCallback onPressed})
    : this._(key: key, onPressed: onPressed, child: Assets.icons.googleIcn.svg());

  /// Apple glyph.
  SocialButton.apple({Key? key, required VoidCallback onPressed})
    : this._(key: key, onPressed: onPressed, child: Assets.icons.appleIcn.svg());

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = context.r(60);
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}
