import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../gen/assets.gen.dart';
import '../cubit/onboarding_cubit.dart';

/// Onboarding carousel built from the Klik design. Completing it (Get Started
/// or Skip) marks onboarding done; the router guard then routes to login.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  // Localized at build time (needs BuildContext); images/icons are static.
  List<_SlideData> _slidesFor(BuildContext context) => [
    _SlideData(
      image: Assets.images.onBoardingOneImg,
      icon: Assets.icons.cartIcn,
      title: context.tr(LocaleKeys.onboardingWelcomeTitle),
      subtitle: context.tr(LocaleKeys.onboardingWelcomeSubtitle),
    ),
    _SlideData(
      image: Assets.images.onBoardingTwoImg,
      icon: Assets.icons.deliveryIcn,
      title: context.tr(LocaleKeys.onboardingDeliveryTitle),
      subtitle: context.tr(LocaleKeys.onboardingDeliverySubtitle),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() => sl<OnboardingCubit>().complete();

  void _next() => _controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    final slides = _slidesFor(context);
    final isLast = _index == slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: slides.length,
                  itemBuilder: (context, i) => _Slide(data: slides[i]),
                ),
              ),
              _Controls(isLast: isLast, index: _index, count: slides.length, onNext: _next, onGetStarted: _finish),
            ],
          ),
          // Skip — overlays the artwork, top-right.
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: context.edge(right: 16, top: 8),
                child: AppButton.text(label: context.tr(LocaleKeys.skip), onPressed: _finish),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  _SlideData({required this.image, required this.icon, required this.title, required this.subtitle});

  final AssetGenImage image;
  final SvgGenImage icon;
  final String title;
  final String subtitle;
}

class _Slide extends StatelessWidget {
  const _Slide({required this.data});

  final _SlideData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            ClipPath(
              clipper: _CurvedBottomClipper(context.r(32)),
              child: data.image.image(
                width: context.wf(1),
                height: context.hf(0.66),
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              bottom: -context.r(32),
              child: _IconBadge(icon: data.icon),
            ),
          ],
        ),
        context.gapH(48),
        Padding(
          padding: context.edgeHorizontal(32),
          child: Column(
            children: [
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.sp(26),
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: AppColors.textPrimary,
                ),
              ),
              context.gapH(14),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: context.sp(14), height: 1.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final SvgGenImage icon;

  @override
  Widget build(BuildContext context) {
    final size = context.r(64);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: context.r(16),
            offset: Offset(0, context.r(6)),
          ),
        ],
      ),
      child: icon.svg(width: context.r(30), height: context.r(30)),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.isLast,
    required this.index,
    required this.count,
    required this.onNext,
    required this.onGetStarted,
  });

  final bool isLast;
  final int index;
  final int count;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: context.edge(left: 24, top: 8, right: 24, bottom: 24),
        child: isLast
            ? AppButton.gradient(
                label: context.tr(LocaleKeys.getStarted),
                trailing: const Icon(Icons.arrow_forward),
                onPressed: onGetStarted,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Dots(count: count, index: index),
                  AppButton.circle(icon: const Icon(Icons.arrow_forward), onPressed: onNext),
                ],
              ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: EdgeInsets.only(right: context.r(6)),
          height: context.r(8),
          width: active ? context.r(22) : context.r(8),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.primary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(context.r(4)),
          ),
        );
      }),
    );
  }
}

/// Clips the artwork with a gentle convex bottom edge (center dips lower than
/// the sides) so the icon badge nests into the curve.
class _CurvedBottomClipper extends CustomClipper<Path> {
  const _CurvedBottomClipper(this.dip);

  final double dip;

  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - dip)
      ..quadraticBezierTo(size.width / 2, size.height + dip, size.width, size.height - dip)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _CurvedBottomClipper oldClipper) => oldClipper.dip != dip;
}
