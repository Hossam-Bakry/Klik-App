import 'dart:async';

import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';

/// Semantic categories for [AppToast] — each maps to a default icon + color.
enum AppToastKind { success, info, warning, error }

/// App-wide toast notifications: a small floating card with a colored icon
/// badge, a message, and a close button — the one component every screen
/// should use instead of a bare [SnackBar].
///
/// Rendered via the root [Overlay] (not [ScaffoldMessenger]) so it floats
/// at the *top* of the screen, below the status bar, with a slide + fade
/// entrance; only one toast is shown at a time (a new one replaces the
/// current one immediately, mirroring `hideCurrentSnackBar()` semantics).
///
/// Use the named constructors for the common cases; pass [icon] to swap the
/// glyph for a domain-specific event (e.g. cart, order, notification, trash)
/// while keeping the semantic color — e.g.
/// `AppToast.success(context, 'Item added to wishlist.', icon: Icons.favorite)`.
class AppToast {
  const AppToast._();

  static const _defaultDuration = Duration(seconds: 3);

  static OverlayEntry? _activeEntry;

  static void success(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration duration = _defaultDuration,
  }) => _show(
    context,
    message: message,
    kind: AppToastKind.success,
    icon: icon,
    duration: duration,
  );

  static void info(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration duration = _defaultDuration,
  }) => _show(
    context,
    message: message,
    kind: AppToastKind.info,
    icon: icon,
    duration: duration,
  );

  static void warning(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration duration = _defaultDuration,
  }) => _show(
    context,
    message: message,
    kind: AppToastKind.warning,
    icon: icon,
    duration: duration,
  );

  static void error(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration duration = _defaultDuration,
  }) => _show(
    context,
    message: message,
    kind: AppToastKind.error,
    icon: icon,
    duration: duration,
  );

  /// Solid brand-color card for a stronger confirmation than [success] (e.g.
  /// "Changes saved successfully").
  static void emphasis(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle,
    Duration duration = _defaultDuration,
  }) {
    _present(
      context,
      duration: duration,
      cardBuilder: (dismiss) => _ToastCard(
        message: message,
        icon: icon,
        iconColor: AppColors.surface,
        iconBackground: Colors.transparent,
        backgroundColor: AppColors.primary,
        textColor: AppColors.surface,
        closeColor: AppColors.surface,
        onClose: dismiss,
      ),
    );
  }

  /// Solid dark banner for a connectivity/offline notice.
  static void offline(
    BuildContext context,
    String message, {
    IconData icon = Icons.info,
    Duration duration = _defaultDuration,
  }) {
    _present(
      context,
      duration: duration,
      cardBuilder: (dismiss) => _ToastCard(
        message: message,
        icon: icon,
        iconColor: AppColors.surface,
        iconBackground: Colors.transparent,
        backgroundColor: AppColors.dark,
        textColor: AppColors.surface,
        closeColor: AppColors.surface,
        onClose: dismiss,
      ),
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required AppToastKind kind,
    IconData? icon,
    required Duration duration,
  }) {
    final (defaultIcon, color) = switch (kind) {
      AppToastKind.success => (Icons.check_circle, AppColors.success),
      AppToastKind.info => (Icons.info, AppColors.info),
      AppToastKind.warning => (Icons.warning_amber_rounded, AppColors.warning),
      AppToastKind.error => (Icons.cancel, AppColors.error),
    };
    _present(
      context,
      duration: duration,
      cardBuilder: (dismiss) => _ToastCard(
        message: message,
        icon: icon ?? defaultIcon,
        iconColor: color,
        iconBackground: color.withValues(alpha: 0.12),
        backgroundColor: AppColors.surface,
        textColor: AppColors.textPrimary,
        closeColor: AppColors.textSecondary,
        onClose: dismiss,
      ),
    );
  }

  static void _present(
    BuildContext context, {
    required Duration duration,
    required Widget Function(VoidCallback dismiss) cardBuilder,
  }) {
    // Only one toast on screen at a time.
    if (_activeEntry?.mounted ?? false) _activeEntry!.remove();
    _activeEntry = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastOverlayItem(
        duration: duration,
        cardBuilder: cardBuilder,
        onRemoved: () {
          entry.remove();
          if (identical(_activeEntry, entry)) _activeEntry = null;
        },
      ),
    );
    _activeEntry = entry;
    overlay.insert(entry);
  }
}

/// Positions the card at the top of the screen (under the status bar) and
/// drives its slide-down + fade entrance/exit and auto-dismiss timer.
class _ToastOverlayItem extends StatefulWidget {
  const _ToastOverlayItem({
    required this.duration,
    required this.cardBuilder,
    required this.onRemoved,
  });

  final Duration duration;
  final Widget Function(VoidCallback dismiss) cardBuilder;
  final VoidCallback onRemoved;

  @override
  State<_ToastOverlayItem> createState() => _ToastOverlayItemState();
}

class _ToastOverlayItemState extends State<_ToastOverlayItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final Animation<Offset> _offset = Tween(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  Timer? _timer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _timer?.cancel();
    await _controller.reverse();
    widget.onRemoved();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: SlideTransition(
          position: _offset,
          child: FadeTransition(
            opacity: _controller,
            child: Padding(
              padding: context.edgeSymmetric(horizontal: 16, vertical: 12),
              child: widget.cardBuilder(_dismiss),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.backgroundColor,
    required this.textColor,
    required this.closeColor,
    required this.onClose,
  });

  final String message;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color backgroundColor;
  final Color textColor;
  final Color closeColor;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: context.edgeSymmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(context.r(14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: context.r(12),
              offset: Offset(0, context.r(4)),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: context.r(28),
              height: context.r(28),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: context.r(18), color: iconColor),
            ),
            context.gapW(10),
            Expanded(
              child: Text(
                message,
                style: context.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            context.gapW(8),
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(context.r(20)),
              child: Padding(
                padding: EdgeInsets.all(context.r(2)),
                child: Icon(
                  Icons.close_rounded,
                  size: context.r(16),
                  color: closeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
