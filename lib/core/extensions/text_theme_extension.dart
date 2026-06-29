import 'package:flutter/material.dart';

/// Quick access to the app's [TextTheme] (and [ColorScheme]) from `context`,
/// so screens read styles straight off [AppTheme] instead of hand-rolling
/// [TextStyle]s.
///
/// ```dart
/// import 'package:klik_app/core/extensions/context_extensions.dart';
///
/// Text('Title', style: context.titleLarge);
/// Text('Body', style: context.bodyMedium?.copyWith(color: context.colors.primary));
/// ```
extension TextThemeX on BuildContext {
  /// The active [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The app-wide [TextTheme] (defined in `AppTheme.light`).
  TextTheme get textTheme => theme.textTheme;

  /// The active [ColorScheme].
  ColorScheme get colors => theme.colorScheme;

  // --- Title ---
  TextStyle? get titleLarge => textTheme.titleLarge;
  TextStyle? get titleMedium => textTheme.titleMedium;
  TextStyle? get titleSmall => textTheme.titleSmall;

  // --- Body ---
  TextStyle? get bodyLarge => textTheme.bodyLarge;
  TextStyle? get bodyMedium => textTheme.bodyMedium;
  TextStyle? get bodySmall => textTheme.bodySmall;

  // --- Label ---
  TextStyle? get labelLarge => textTheme.labelLarge;
  TextStyle? get labelMedium => textTheme.labelMedium;
  TextStyle? get labelSmall => textTheme.labelSmall;

  // --- Headline ---
  TextStyle? get headlineLarge => textTheme.headlineLarge;
  TextStyle? get headlineMedium => textTheme.headlineMedium;
  TextStyle? get headlineSmall => textTheme.headlineSmall;

  // --- Display ---
  TextStyle? get displayLarge => textTheme.displayLarge;
  TextStyle? get displayMedium => textTheme.displayMedium;
  TextStyle? get displaySmall => textTheme.displaySmall;
}
