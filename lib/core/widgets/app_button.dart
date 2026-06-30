import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';

enum _AppButtonShape { stadium, circle }

/// One reusable button for the whole app. Each visual case is a named
/// constructor that redirects to the private generative constructor with the
/// right styling — add a new design case by adding another named constructor
/// (e.g. `AppButton.danger`) rather than branching on flags at call sites.
///
/// All dimensions (height, padding, radius, font, icon) are responsive: the
/// numbers are design-px and scale uniformly via [ResponsiveSize].
///
/// Cases:
///   - [AppButton.primary]  — solid dark (near-black) CTA (the app default)
///   - [AppButton.gradient] — bronze→gold gradient pill (prominent CTA)
///   - [AppButton.circle]   — circular icon button (e.g. onboarding "next")
///   - [AppButton.outline]  — transparent with a border
///   - [AppButton.text]     — text-only (e.g. inline links)
///   - [AppButton.chip]     — compact light pill over imagery (e.g. "Skip")
class AppButton extends StatelessWidget {
  const AppButton._({
    super.key,
    required this.onPressed,
    this.label,
    this.leading,
    this.trailing,
    this.gradient,
    this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.borderColor,
    this.isLoading = false,
    this.expanded = true,
    this.height = 56,
    this.horizontalPadding,
    this.fontSize = 16,
    this.cornerRadius,
    _AppButtonShape shape = _AppButtonShape.stadium,
    bool inkEffect = true,
  }) : _shape = shape,
       _inkEffect = inkEffect;

  /// Solid filled button with a custom [color] and rounded-rectangle corners
  /// (not a full pill) — the bronze auth CTAs (Log In, Sign up, Send OTP, …).
  const AppButton.filled({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    Color color = AppColors.primary,
    bool isLoading = false,
    bool expanded = true,
    double cornerRadius = 14,
  }) : this._(
         key: key,
         onPressed: onPressed,
         label: label,
         backgroundColor: color,
         isLoading: isLoading,
         expanded: expanded,
         cornerRadius: cornerRadius,
       );

  /// Solid dark (near-black) primary button — the default app CTA.
  const AppButton.primary({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    Widget? leading,
    Widget? trailing,
    bool isLoading = false,
    bool expanded = true,
  }) : this._(
         key: key,
         onPressed: onPressed,
         label: label,
         leading: leading,
         trailing: trailing,
         backgroundColor: AppColors.dark,
         isLoading: isLoading,
         expanded: expanded,
       );

  /// Bronze→gold gradient pill — prominent CTA (e.g. onboarding "Get Started").
  const AppButton.gradient({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    Widget? trailing,
    bool isLoading = false,
    bool expanded = true,
  }) : this._(
         key: key,
         onPressed: onPressed,
         label: label,
         trailing: trailing,
         gradient: const [AppColors.splashAccentLight, AppColors.splashAccentDark],
         isLoading: isLoading,
         expanded: expanded,
       );

  /// Circular icon button with the bronze→gold gradient.
  const AppButton.circle({Key? key, required VoidCallback? onPressed, required Widget icon, double size = 56})
    : this._(
        key: key,
        onPressed: onPressed,
        trailing: icon,
        gradient: const [AppColors.splashAccentLight, AppColors.splashAccentDark],
        shape: _AppButtonShape.circle,
        expanded: false,
        height: size,
      );

  /// Transparent button with a border.
  const AppButton.outline({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    Widget? trailing,
    bool expanded = true,
  }) : this._(
         key: key,
         onPressed: onPressed,
         label: label,
         trailing: trailing,
         backgroundColor: Colors.transparent,
         foregroundColor: AppColors.dark,
         borderColor: AppColors.dark,
         expanded: expanded,
       );

  /// Text-only button (no background), e.g. inline links.
  const AppButton.text({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    Color foregroundColor = AppColors.textPrimary,
  }) : this._(
         key: key,
         onPressed: onPressed,
         label: label,
         backgroundColor: Colors.transparent,
         foregroundColor: foregroundColor,
         expanded: false,
         height: 40,
         horizontalPadding: 0,
         inkEffect: false,
       );

  /// Compact light pill that reads over imagery, e.g. onboarding "Skip".
  const AppButton.chip({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    Color backgroundColor = const Color(0xCCFFFFFF),
    Color foregroundColor = AppColors.textPrimary,
  }) : this._(
         key: key,
         onPressed: onPressed,
         label: label,
         backgroundColor: backgroundColor,
         foregroundColor: foregroundColor,
         expanded: false,
         height: 38,
         horizontalPadding: 18,
         fontSize: 14,
       );

  final VoidCallback? onPressed;
  final String? label;
  final Widget? leading;
  final Widget? trailing;
  final List<Color>? gradient;
  final Color? backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final bool isLoading;
  final bool expanded;

  /// Design-px values; scaled responsively in [build].
  final double height;
  final double? horizontalPadding;
  final double fontSize;

  /// When set, the corner radius (design-px). Null = full pill (height/2).
  final double? cornerRadius;
  final _AppButtonShape _shape;

  /// Whether tapping shows the Material ripple/hover overlay. Off for [text].
  final bool _inkEffect;

  bool get _isCircle => _shape == _AppButtonShape.circle;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final h = context.r(height);
    final radius = BorderRadius.circular(_isCircle ? h : (cornerRadius != null ? context.r(cornerRadius!) : h / 2));

    final decoration = BoxDecoration(
      color: gradient == null ? (backgroundColor ?? AppColors.dark) : null,
      gradient: gradient == null
          ? null
          : LinearGradient(colors: gradient!, begin: Alignment.centerLeft, end: Alignment.centerRight),
      borderRadius: radius,
      border: borderColor == null ? null : Border.all(color: borderColor!),
    );

    final button = Opacity(
      opacity: disabled && !isLoading ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (disabled || isLoading) ? null : onPressed,
          borderRadius: radius,
          splashColor: _inkEffect ? null : Colors.transparent,
          highlightColor: _inkEffect ? null : Colors.transparent,
          hoverColor: _inkEffect ? null : Colors.transparent,
          focusColor: _inkEffect ? null : Colors.transparent,
          child: Container(
            height: h,
            width: _isCircle ? h : null,
            padding: _isCircle ? null : EdgeInsets.symmetric(horizontal: context.r(horizontalPadding ?? 24)),
            decoration: decoration,
            // Always center the child vertically (and horizontally). When not
            // expanded the surrounding IntrinsicWidth keeps the button hugging
            // its content width instead of stretching to the parent's width.
            alignment: Alignment.center,
            child: _buildChild(context),
          ),
        ),
      ),
    );

    if (_isCircle) return button;
    if (!expanded) return IntrinsicWidth(child: button);
    return SizedBox(width: double.infinity, child: button);
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      final size = context.r(22);
      return SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(foregroundColor)),
      );
    }

    final icons = IconThemeData(color: foregroundColor, size: context.r(22));

    if (_isCircle) {
      return IconTheme(data: icons, child: trailing ?? const SizedBox.shrink());
    }

    final text = Text(
      label ?? '',
      style: context.bodySmall?.copyWith(
        color: foregroundColor,
      )
    );

    if (leading == null && trailing == null) return text;

    // Label centered, leading/trailing pinned to the edges.
    return Stack(
      alignment: Alignment.center,
      children: [
        text,
        if (leading != null)
          Align(
            alignment: Alignment.centerLeft,
            child: IconTheme(data: icons, child: leading!),
          ),
        if (trailing != null)
          Align(
            alignment: Alignment.centerRight,
            child: IconTheme(data: icons, child: trailing!),
          ),
      ],
    );
  }
}
