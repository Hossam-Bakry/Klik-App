import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// A bottom navigation bar with a smooth concave valley in the centre that
/// cradles a floating bronze circle (the primary "Negotiation" action).
///
/// Two tabs sit on each side of the centre circle:
///   [Home, Category] · (Negotiation) · [Cart, Profile]
/// The five destinations map to indices 0..4 (centre = 2) so they line up with
/// the host layout's [IndexedStack].
class CurvedBottomNav extends StatelessWidget {
  const CurvedBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  // Design-px geometry (scaled responsively at paint time).
  static const double _barHeight = 55;
  static const double _circleRadius = 27.5;
  static const double _valleyHalfWidth = 64;
  static const double _valleyDepth = 34;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final barHeight = context.r(_barHeight);
    final circleR = context.r(_circleRadius);
    final overhang = circleR; // how far the circle floats above the bar top

    return SizedBox(
      height: overhang + barHeight + bottomInset,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The white bar with the painted central valley + soft shadow.
          Positioned(
            top: overhang,
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(
              painter: _NavBarPainter(
                color: AppColors.surface,
                valleyHalfWidth: context.r(_valleyHalfWidth),
                valleyDepth: context.r(_valleyDepth),
              ),
            ),
          ),
          // Tab icons: two on each side, with a gap reserved for the circle.
          Positioned(
            top: overhang,
            left: 0,
            right: 0,
            height: barHeight,
            child: Row(
              children: [
                _NavIcon(
                  icon: Assets.icons.homeIcn,
                  selected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavIcon(
                  icon: Assets.icons.categoryIcn,
                  selected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                SizedBox(width: context.r(_valleyHalfWidth * 2)),
                _NavIcon(
                  icon: Assets.icons.cartIcn,
                  selected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                _NavIcon(
                  icon: Assets.icons.profileIcn,
                  selected: currentIndex == 4,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ),
          // Floating centre circle (Negotiation), nestled in the valley.
          Positioned(
            top: overhang - circleR,
            left: 0,
            right: 0,
            child: Center(
              child: _CenterButton(
                radius: circleR,
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.selected, required this.onTap});

  final SvgGenImage icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkResponse(
        onTap: onTap,
        radius: context.r(28),
        child: Center(
          child: icon.svg(
            width: context.r(30),
            height: context.r(30),
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  const _CenterButton({required this.radius, required this.selected, required this.onTap});

  final double radius;
  final bool selected;
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
          child: Assets.icons.negotiationIcn.svg(
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
/// in the centre, plus a soft drop shadow along the top edge.
class _NavBarPainter extends CustomPainter {
  const _NavBarPainter({required this.color, required this.valleyHalfWidth, required this.valleyDepth});

  final Color color;
  final double valleyHalfWidth;
  final double valleyDepth;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
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
      old.color != color || old.valleyHalfWidth != valleyHalfWidth || old.valleyDepth != valleyDepth;
}
