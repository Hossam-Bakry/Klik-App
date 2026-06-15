import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../gen/assets.gen.dart';

/// Shared shell for the auth screens: the dotted brand background painted
/// full-screen behind a safe, scrollable content area.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.authBackgroundImag.provider(),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: SafeArea(
          child: SingleChildScrollView(padding: context.edgeSymmetric(horizontal: 24, vertical: 16), child: child),
        ),
      ),
    );
  }
}
