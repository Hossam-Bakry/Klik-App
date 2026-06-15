import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Centered title + subtitle used at the top of each auth screen.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.sp(28),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        context.gapH(8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.sp(15),
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
