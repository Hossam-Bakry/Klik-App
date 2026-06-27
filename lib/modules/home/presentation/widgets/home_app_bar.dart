import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

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
              Row(
                spacing: 10,
                children: [
                  Text(
                    context.tr(LocaleKeys.deliverTo),
                    style: TextStyle(fontSize: context.sp(18), color: AppColors.textPrimary.withValues(alpha: 0.7)),
                  ),
                  Icon(Icons.arrow_forward_ios_outlined, size: 14, color: AppColors.textPrimary.withValues(alpha: 0.7)),
                ],
              ),
              context.gapH(2),
              Text(
                "87 kings road ",
                style: TextStyle(
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        _NotificationButton(hasNew: true, onTap: () {}),
      ],
    );
  }
}

/// Notification bell with a small red dot on the top-right corner that marks
/// unread notifications when [hasNew] is true.
class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onTap, this.hasNew = false});

  final VoidCallback onTap;
  final bool hasNew;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: context.r(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Assets.icons.notificationIcn.svg(width: context.w(30)),
          if (hasNew)
            Positioned(
              top: -context.r(-2),
              right: -context.r(-2),
              child: Container(
                width: context.r(10),
                height: context.r(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  // A ring in the surface color so the dot reads clearly.
                  // border: Border.all(color: AppColors.surface, width: context.r(1.5)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
