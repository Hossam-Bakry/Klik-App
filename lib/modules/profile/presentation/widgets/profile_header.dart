import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Avatar + name + email row at the top of the profile screen. The avatar
/// carries a small bronze edit badge on its bottom-right corner.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.onEdit,
  });

  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final size = context.r(72);

    return Row(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size,
                height: size,
                padding: context.edgeAll(context.r(10)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryBronze, width: 2),
                  color: AppColors.inputLabel,
                  image: avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: avatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: context.r(36),
                        color: AppColors.primary.withValues(alpha: 0.5),
                      )
                    : null,
              ),
              Positioned(
                right: -context.r(2),
                bottom: -context.r(2),
                child: InkWell(
                  onTap: onEdit,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: context.edgeAll(5),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBronze,
                      shape: BoxShape.circle,
                    ),
                    child: Assets.icons.editIcn.svg(
                      width: context.r(15),
                      height: context.r(15),
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        context.gapW(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.titleLarge,
              ),
              context.gapH(4),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
