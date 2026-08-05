import 'package:flutter/material.dart';

/// Single source of truth for brand colors, from the Klik design system.
/// Reference these from [AppTheme] rather than hard-coding `Color(0x...)`.
class AppColors {
  const AppColors._();

  // ---- Surfaces ----
  /// App background (warm off-white).
  static const Color background = Color(0xFFFAF7F2);
  static const Color surface = Color(0xFFFFFFFF);

  /// Fill behind input fields / labels.
  static const Color inputLabel = Color(0xFFF3F0EB);

  /// Default border / divider.
  static const Color border = Color(0xFFF5F5F5);

  // ---- Brand accents (bronze → gold) ----
  /// Primary brand color (bronze) — notification icon, links, accents.
  static const Color primary = Color(0xFF905D1B);
  static const Color primaryBronze = Color(0xFFA9762E);

  /// Secondary brand color (gold) — splash accent / highlights.
  static const Color secondary = Color(0xFFD2A04E);

  static const Color notificationIcon = Color(0xFF905D1B);

  // ---- Controls ----
  /// Dark (near-black) used for primary buttons.
  static const Color dark = Color(0xFF080808);

  // ---- Text ----
  static const Color textPrimary = Color(0xFF080808);
  static const Color textPrimaryGold = Color(0xFF816142);
  static const Color textSecondary = Color(0xFF6B7280);

  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ---- Splash ----
  /// Warm cream behind the splash artwork (matches the exported PNG edges so
  /// the full-bleed image blends on any aspect ratio).
  static const Color splashBackground = Color(0xFFFFF8EA);

  /// Splash gradient/accent pair (bronze → gold).
  static const Color splashAccentDark = Color(0xFF905D1B);
  static const Color splashAccentLight = Color(0xFFD2A04E);

  /// Status Product Details Info Card
  static const Color pendingStatusColor = Color(0xFFFDE68A);
  static const Color rejectStatusColor = Color(0xFFD3212D);
  static const Color counterStatusColor = Color(0xFFBFDBFE);
  static const Color approvedStatusColor = Color(0xFF34C759);
  static const Color expiredStatusColor = Color(0xFFF8FAFC);
}
