import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// A single tappable row inside a [ProfileSectionCard]: a bronze leading icon,
/// a title, and an optional trailing widget (chevron / dropdown caret).
///
/// Pass [danger] for destructive actions (e.g. Logout) to tint the icon and
/// text red and drop the trailing affordance.
class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.danger = false,
  });

  final SvgGenImage icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.primaryBronze;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(12)),
      child: Padding(
        padding: context.edgeSymmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            icon.svg(width: context.r(22), color: color),
            context.gapW(12),
            Expanded(
              child: Text(
                title,
                style: context.bodyLarge?.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// Trailing chevron used by most navigation rows.
class ProfileTileChevron extends StatelessWidget {
  const ProfileTileChevron({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      size: context.r(24),
      color: AppColors.primaryBronze,
    );
  }
}
