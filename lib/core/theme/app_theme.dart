import 'package:flutter/material.dart';

import '../../gen/fonts.gen.dart';
import 'app_colors.dart';
import '../extensions/context_extensions.dart';

/// Centralized [ThemeData]. Build screens against `Theme.of(context)` so the
/// whole app restyles from this one file.
///
/// Takes a [BuildContext] so radii, padding, and font sizes scale responsively
/// (via [ResponsiveSize]) from the device width.
///
/// Fonts: [FontFamily.inter] is the app-wide default (set via [fontFamily]).
/// [FontFamily.roboto] is bundled too — apply it per-widget with
/// `TextStyle(fontFamily: FontFamily.roboto)` where the design calls for it.
class AppTheme {
  const AppTheme._();

  static ThemeData light(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.surface,
    );

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.r(12)),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Default font for the whole app — every TextStyle inherits Inter unless
      // it overrides fontFamily.
      fontFamily: FontFamily.inter,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.r(16)),
        ),
      ),
      // Primary buttons are the dark (near-black) brand control.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dark,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.dark.withValues(alpha: 0.4),
          textStyle: TextStyle(
            fontFamily: FontFamily.inter,
            fontSize: context.sp(16),
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.r(12)),
          ),
          padding: EdgeInsets.symmetric(vertical: context.r(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          overlayColor: Colors.transparent,
        ),
      ),
      // Inputs: filled with the light label tone, subtle border that turns to
      // the brand color on focus.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputLabel,
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.r(16),
          vertical: context.r(16),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: border(AppColors.border),
        focusedBorder: border(AppColors.primary, 1.5),
        errorBorder: border(AppColors.error),
        focusedErrorBorder: border(AppColors.error, 1.5),
      ),
    );
  }
}
