import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import 'profile_section_card.dart';

/// Bottom card: a "Sell With Us" call-to-action, social links, and the app
/// version / copyright line.
class ProfileFooter extends StatelessWidget {
  const ProfileFooter({
    super.key,
    this.onSellWithUs,
    this.onTikTok,
    this.onInstagram,
    this.onFacebook,
  });

  final VoidCallback? onSellWithUs;
  final VoidCallback? onTikTok;
  final VoidCallback? onInstagram;
  final VoidCallback? onFacebook;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      padding: context.edgeSymmetric(horizontal: 16, vertical: 18),
      child: Column(
        children: [
          InkWell(
            onTap: onSellWithUs,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.tr(LocaleKeys.sellWithUs),
                  style: context.bodyLarge?.copyWith(color: AppColors.primary),
                ),
                context.gapW(8),
                Icon(
                  Icons.open_in_new_rounded,
                  size: context.r(18),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          context.gapH(16),
          Divider(color: AppColors.border, height: 1),
          context.gapH(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SocialButton(icon: Assets.icons.tiktokIcn, onTap: onTikTok),
              _SocialButton(
                icon: Assets.icons.instagramIcn,
                onTap: onInstagram,
              ),
              _SocialButton(icon: Assets.icons.facebookIcn, onTap: onFacebook),
            ],
          ),
          context.gapH(16),
          Text(
            context.tr(LocaleKeys.appVersion),
            style: context.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          context.gapH(2),
          Text(
            context.tr(LocaleKeys.allRightsReserved),
            style: context.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, this.onTap});

  final SvgGenImage icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: context.r(24),
      child: icon.svg(
        width: context.r(28),
        height: context.r(28),
        color: AppColors.textPrimary,
      ),
    );
  }
}
