import 'package:flutter/widgets.dart';

/// Responsive sizing based on the Figma design width (393px).
///
/// Everything scales by a single **width-derived factor** (no aspect-ratio
/// distortion across tall/short phones). Use [hf]/[wf] for true screen
/// fractions (hero images, full-bleed sections).
extension ResponsiveSize on BuildContext {
  /// Design frame width the values are authored against.
  static const double _baseWidth = 393.0;

  static const double _minScale = 0.85;
  static const double _maxScale = 1.15;

  static const double _minTextScale = 0.90;
  static const double _maxTextScale = 1.10;

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// The single, uniform scale factor.
  double get scaleFactor =>
      (screenWidth / _baseWidth).clamp(_minScale, _maxScale);

  /// Scale a design dimension (size, spacing, padding, radius) uniformly.
  double r(double value) => value * scaleFactor;

  /// Aliases kept for familiarity; both use the SAME factor, so they never
  /// distort — `w(64)` and `h(64)` are identical.
  double w(double value) => r(value);
  double h(double value) => r(value);

  /// Responsive font size (tighter clamp than [r]).
  double sp(double value) =>
      value * (screenWidth / _baseWidth).clamp(_minTextScale, _maxTextScale);

  /// A fraction (0–1) of the screen width.
  double wf(double fraction) => screenWidth * fraction;

  /// A fraction (0–1) of the screen height — e.g. a hero image at `hf(0.54)`.
  double hf(double fraction) => screenHeight * fraction;
}
