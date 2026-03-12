import 'package:flutter/material.dart';

/// Modern snackbar helper — shows at the TOP of the screen.
///
/// Theme-aware: blends semantic colors with the active theme's surface
/// so it feels native regardless of which of the 12+ themes is active.
///
/// Usage:
///   AppSnackbar.success(context, 'Recipe saved!');
///   AppSnackbar.error(context, 'Something went wrong');
///   AppSnackbar.info(context, 'Signed out');
///   AppSnackbar.warning(context, 'Low storage');
///   AppSnackbar.successWithAction(context, 'Added 5 items', actionLabel: 'View', onAction: () => ...);

class AppSnackbar {
  AppSnackbar._();

  static OverlayEntry? _currentEntry;
  static AnimationController? _currentController;

  // ─── Semantic colours (icon accent) ───

  static const _successAccent = Color(0xFF2E7D32);
  static const _errorAccent = Color(0xFFC62828);
  static const _infoAccent = Color(0xFF1565C0);
  static const _warningAccent = Color(0xFFE65100);

  // ─── Public API ───

  static void success(BuildContext context, String message) =>
      _show(context, message, Icons.check_circle_rounded, _successAccent);

  static void error(BuildContext context, String message) =>
      _show(context, message, Icons.error_rounded, _errorAccent);

  static void info(BuildContext context, String message) =>
      _show(context, message, Icons.info_rounded, _infoAccent);

  static void warning(BuildContext context, String message) =>
      _show(context, message, Icons.warning_rounded, _warningAccent);

  static void custom(BuildContext context, String message,
          {required IconData icon, required Color color}) =>
      _show(context, message, icon, color);

  /// Success snackbar with an action button
  static void successWithAction(
    BuildContext context,
    String message, {
    required String actionLabel,
    required VoidCallback onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context, message,
      Icons.check_circle_rounded, _successAccent,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Error snackbar with an action button
  static void errorWithAction(
    BuildContext context,
    String message, {
    required String actionLabel,
    required VoidCallback onAction,
    Duration duration = const Duration(seconds: 5),
  }) {
    _show(
      context, message,
      Icons.error_rounded, _errorAccent,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Loading snackbar with spinner — stays until manually dismissed
  static void loading(BuildContext context, String message) {
    _show(
      context, message,
      null, null,
      isLoading: true,
      duration: const Duration(seconds: 30),
    );
  }

  /// Dismiss current snackbar
  static void dismiss(BuildContext context) {
    _dismissCurrent();
  }

  // ─── Internal ───

  static void _dismissCurrent() {
    final ctrl = _currentController;
    final entry = _currentEntry;
    if (ctrl != null && !ctrl.isAnimating && ctrl.value == 1.0) {
      _currentController = null;
      _currentEntry = null;
      ctrl.reverse().then((_) {
        entry?.remove();
        ctrl.dispose();
      });
    } else if (entry != null) {
      _currentEntry = null;
      _currentController = null;
      entry.remove();
      ctrl?.dispose();
    }
  }

  static void _show(
    BuildContext context,
    String message,
    IconData? icon,
    Color? accent, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    bool isLoading = false,
  }) {
    _dismissCurrent();
    ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();

    final overlay = Overlay.of(context, rootOverlay: true);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;

    final controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: overlay,
    );
    _currentController = controller;

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeIn,
    ));

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _TopSnackbarWidget(
        message: message,
        icon: icon,
        accent: accent,
        surface: cs.surface,
        onSurface: cs.onSurface,
        outline: cs.outline,
        isDark: theme.brightness == Brightness.dark,
        topPadding: topPadding,
        slideAnimation: slideAnimation,
        controller: controller,
        actionLabel: actionLabel,
        onAction: onAction != null
            ? () {
                _dismissCurrent();
                onAction();
              }
            : null,
        isLoading: isLoading,
        onDismiss: _dismissCurrent,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
    controller.forward();

    // Auto-dismiss
    if (!isLoading || duration.inSeconds < 30) {
      Future.delayed(duration, () {
        if (_currentEntry == entry) {
          _dismissCurrent();
        }
      });
    }
  }
}

// ─── Widget ──────────────────────────────────────────────────────────────────

class _TopSnackbarWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? accent;
  final Color surface;
  final Color onSurface;
  final Color outline;
  final bool isDark;
  final double topPadding;
  final Animation<Offset> slideAnimation;
  final AnimationController controller;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;
  final VoidCallback onDismiss;

  const _TopSnackbarWidget({
    required this.message,
    this.icon,
    this.accent,
    required this.surface,
    required this.onSurface,
    required this.outline,
    required this.isDark,
    required this.topPadding,
    required this.slideAnimation,
    required this.controller,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
    required this.onDismiss,
  });

  static const _maxWidth = 480.0;

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accent ?? onSurface.withValues(alpha: 0.7);

    // Blend semantic accent with theme surface — feels native to any theme
    final bg = isDark
        ? Color.lerp(surface, effectiveAccent, 0.10)!
        : Color.lerp(surface, effectiveAccent, 0.07)!;

    // Subtle border so the snackbar never melts into the background
    final borderColor = isDark
        ? effectiveAccent.withValues(alpha: 0.20)
        : effectiveAccent.withValues(alpha: 0.15);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: controller,
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy < -100) onDismiss();
            },
            onTap: onDismiss,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.only(top: topPadding),
                alignment: Alignment.topCenter,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: _maxWidth),
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                            alpha: isDark ? 0.35 : 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(
                            alpha: isDark ? 0.15 : 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLeading(effectiveAccent),
                      const SizedBox(width: 12),
                      Flexible(child: _buildMessage()),
                      if (actionLabel != null && onAction != null) ...[
                        const SizedBox(width: 10),
                        _buildAction(effectiveAccent),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Icon or spinner ───

  Widget _buildLeading(Color effectiveAccent) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: onSurface.withValues(alpha: 0.6),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: effectiveAccent.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(
        icon,
        size: 18,
        color: isDark
            ? effectiveAccent.withValues(alpha: 0.9)
            : effectiveAccent,
      ),
    );
  }

  // ─── Message text ───

  Widget _buildMessage() {
    return Text(
      message,
      style: TextStyle(
        color: onSurface.withValues(alpha: 0.9),
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
    );
  }

  // ─── Action button with ripple ───

  Widget _buildAction(Color effectiveAccent) {
    final actionColor = isDark
        ? Color.lerp(effectiveAccent, Colors.white, 0.35)!
        : effectiveAccent;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onAction,
        borderRadius: BorderRadius.circular(8),
        splashColor: actionColor.withValues(alpha: 0.12),
        highlightColor: actionColor.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            actionLabel!,
            style: TextStyle(
              color: actionColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
