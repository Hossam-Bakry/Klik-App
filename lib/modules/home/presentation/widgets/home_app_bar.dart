import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';

/// Top greeting row: a two-line welcome on the leading side and a notification
/// bell on the trailing side.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(LocaleKeys.homeGreeting),
                style: TextStyle(fontSize: context.sp(14), color: AppColors.textSecondary),
              ),
              context.gapH(2),
              Text(
                context.tr(LocaleKeys.homeWelcome),
                style: TextStyle(
                  fontSize: context.sp(20),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        _IconBadge(
          icon: Icons.notifications_none_rounded,
          onTap: () {},
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: context.edgeAll(10),
          child: Icon(icon, size: context.r(24), color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
