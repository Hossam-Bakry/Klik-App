import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';

/// Bronze gradient promo card — the hero banner of the home feed.
class HomePromoBanner extends StatelessWidget {
  const HomePromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.r(140),
      padding: context.edgeAll(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(20)),
        gradient: const LinearGradient(
          colors: [AppColors.splashAccentLight, AppColors.splashAccentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.tr(LocaleKeys.promoTitle),
                style: TextStyle(
                  fontSize: context.sp(22),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              context.gapH(6),
              Text(
                context.tr(LocaleKeys.promoSubtitle),
                style: TextStyle(fontSize: context.sp(14), color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
          Positioned(
            right: -context.r(10),
            bottom: -context.r(10),
            child: Icon(
              Icons.local_offer_rounded,
              size: context.r(96),
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}
