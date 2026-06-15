import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Placeholder hero illustration for forgot-password / OTP screens — a soft
/// bronze-tinted disc with an icon. Swap for the real artwork (drop an asset in
/// assets/images and render it here) when available.
class AuthIllustration extends StatelessWidget {
  const AuthIllustration({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = context.r(250);
    return SizedBox(
      width: size,
      height: size,
      child: child,
    );
  }
}
