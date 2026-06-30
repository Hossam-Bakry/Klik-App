import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// A bottom navigation bar with a smooth concave valley that cradles a floating
/// bronze circle (the active destination).
///
/// The five destinations map to indices 0..4 and sit in equal slots:
///   [Home, Category, Negotiation, Cart, Profile]
/// The valley and the floating circle slide to whichever tab is selected, with
/// the selected icon riding inside the circle. Switching tabs animates the
/// circle (and valley) across to the new slot.
class CurvedBottomNav extends StatelessWidget {
  const CurvedBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  // Design-px geometry (scaled responsively at paint time).
  static const double _barHeight = 55;
  static const double _circleRadius = 27.5;
  static const double _valleyHalfWidth = 64;
  static const double _valleyDepth = 34;

  // Order matches indices 0..4.
  static final List<SvgGenImage> _icons = [
    Assets.icons.homeIcn,
    Assets.icons.categoryIcn,
    Assets.icons.negotiationIcn,
    Assets.icons.cartIcn,
    Assets.icons.profileIcn,
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final barHeight = context.r(_barHeight);
    final circleR = context.r(_circleRadius);
    final overhang = circleR; // how far the circle floats above the bar top

    return SizedBox(
      height: overhang + barHeight + bottomInset,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slotWidth = constraints.maxWidth / _icons.length;
          // The icon Row mirrors in RTL, so logical index 0 sits in the
          // right-most physical slot. The valley + circle are positioned from
          // the physical left edge, so map the logical index to its physical
          // slot before computing centerX, otherwise they land on the mirror
          // slot in Arabic.
          final isRtl = Directionality.of(context) == TextDirection.rtl;

          // `position` interpolates between slot indices so the valley + circle
          // glide across when [currentIndex] changes.
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(end: currentIndex.toDouble()),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, position, _) {
              final slot = isRtl ? (_icons.length - 1 - position) : position;
              final centerX = (slot + 0.5) * slotWidth;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // The white bar with the painted valley (follows the circle).
                  Positioned(
                    top: overhang,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: CustomPaint(
                      painter: _NavBarPainter(
                        color: AppColors.surface,
                        centerX: centerX,
                        valleyHalfWidth: context.r(_valleyHalfWidth),
                        valleyDepth: context.r(_valleyDepth),
                      ),
                    ),
                  ),
                  // Five equal tab slots. The icon under the moving circle fades
                  // out, and reappears once the circle leaves it.
                  Positioned(
                    top: overhang,
                    left: 0,
                    right: 0,
                    height: barHeight,
                    child: Row(
                      children: [
                        for (var i = 0; i < _icons.length; i++)
                          _NavIcon(
                            icon: _icons[i],
                            opacity: (position - i).abs().clamp(0.0, 1.0),
                            onTap: () => onTap(i),
                          ),
                      ],
                    ),
                  ),
                  // Floating circle, nestled in the valley, carrying the
                  // selected destination's icon.
                  Positioned(
                    top: overhang - circleR,
                    left: centerX - circleR,
                    child: _CenterButton(
                      radius: circleR,
                      icon: _icons[currentIndex],
                      onTap: () => onTap(currentIndex),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.opacity, required this.onTap});

  final SvgGenImage icon;
  final double opacity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkResponse(
        onTap: onTap,
        radius: context.r(28),
        child: Center(
          child: Opacity(
            opacity: opacity,
            child: icon.svg(
              width: context.r(30),
              height: context.r(30),
              colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  const _CenterButton({required this.radius, required this.icon, required this.onTap});

  final double radius;
  final SvgGenImage icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.splashAccentLight, AppColors.splashAccentDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: Color(0x33905D1B), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Center(
          child: icon.svg(
            width: context.r(30),
            height: context.r(30),
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

/// Paints the white bar: a flat top that dips into a smooth symmetric valley
/// centred on [centerX], plus a soft drop shadow along the top edge.
class _NavBarPainter extends CustomPainter {
  const _NavBarPainter({
    required this.color,
    required this.centerX,
    required this.valleyHalfWidth,
    required this.valleyDepth,
  });

  final Color color;
  final double centerX;
  final double valleyHalfWidth;
  final double valleyDepth;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = centerX;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(cx - valleyHalfWidth, 0)
      // Down into the valley bottom at the centre…
      ..cubicTo(
        cx - valleyHalfWidth * 0.5, 0,
        cx - valleyHalfWidth * 0.55, valleyDepth,
        cx, valleyDepth,
      )
      // …and back up to the flat top on the other side.
      ..cubicTo(
        cx + valleyHalfWidth * 0.55, valleyDepth,
        cx + valleyHalfWidth * 0.5, 0,
        cx + valleyHalfWidth, 0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Soft shadow rising from the top edge: paint a blurred silhouette of the
    // bar first, then the opaque fill on top so only the fringe above the top
    // edge (and around the valley) shows through.
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_NavBarPainter old) =>
      old.color != color ||
      old.centerX != centerX ||
      old.valleyHalfWidth != valleyHalfWidth ||
      old.valleyDepth != valleyDepth;
}
