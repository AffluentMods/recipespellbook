import 'package:flutter/material.dart';

/// Modern snackbar helper — shows at the TOP of the screen.
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

  static void success(BuildContext context, String message) =>
      _show(context, message, Icons.check_circle_rounded, const Color(0xFF2E7D32), const Color(0xFFE8F5E9));

  static void error(BuildContext context, String message) =>
      _show(context, message, Icons.error_rounded, const Color(0xFFC62828), const Color(0xFFFFEBEE));

  static void info(BuildContext context, String message) =>
      _show(context, message, Icons.info_rounded, const Color(0xFF1565C0), const Color(0xFFE3F2FD));

  static void warning(BuildContext context, String message) =>
      _show(context, message, Icons.warning_rounded, const Color(0xFFE65100), const Color(0xFFFFF3E0));

  static void custom(BuildContext context, String message, {required IconData icon, required Color color}) =>
      _show(context, message, icon, color, color.withValues(alpha: 0.08));

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
      Icons.check_circle_rounded, const Color(0xFF2E7D32), const Color(0xFFE8F5E9),
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Loading snackbar with spinner — stays until manually dismissed
  static void loading(BuildContext context, String message) {
    _show(
      context, message,
      null, null, null,
      isLoading: true,
      duration: const Duration(seconds: 30),
    );
  }

  /// Dismiss current snackbar
  static void dismiss(BuildContext context) {
    _dismissCurrent();
  }

  static void _dismissCurrent() {
    if (_currentController != null && _currentController!.isAnimating == false && _currentController!.value == 1.0) {
      _currentController?.reverse().then((_) {
        _currentEntry?.remove();
        _currentEntry = null;
        _currentController?.dispose();
        _currentController = null;
      });
    } else if (_currentEntry != null) {
      _currentEntry?.remove();
      _currentEntry = null;
      _currentController?.dispose();
      _currentController = null;
    }
  }

  static void _show(
      BuildContext context,
      String message,
      IconData? icon,
      Color? accent,
      Color? bgLight, {
        Duration duration = const Duration(seconds: 3),
        String? actionLabel,
        VoidCallback? onAction,
        bool isLoading = false,
      }) {
    // Dismiss any existing snackbar
    _dismissCurrent();
    // Also hide any legacy SnackBars
    ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();

    final overlay = Overlay.of(context, rootOverlay: true);

    final isDark = Theme.of(context).brightness == Brightness.dark;
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
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeIn));

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _TopSnackbarWidget(
        message: message,
        icon: icon,
        accent: accent,
        bgLight: bgLight,
        isDark: isDark,
        topPadding: topPadding,
        slideAnimation: slideAnimation,
        controller: controller,
        actionLabel: actionLabel,
        onAction: onAction != null ? () {
          _dismissCurrent();
          onAction();
        } : null,
        isLoading: isLoading,
        onDismiss: () {
          _dismissCurrent();
        },
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

class _TopSnackbarWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? accent;
  final Color? bgLight;
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
    this.bgLight,
    required this.isDark,
    required this.topPadding,
    required this.slideAnimation,
    required this.controller,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accent ?? (isDark ? Colors.white70 : Colors.grey.shade700);
    final effectiveBg = isDark
        ? Color.lerp(Colors.grey.shade900, effectiveAccent, 0.08)!
        : bgLight ?? Colors.grey.shade100;

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
              // Swipe up to dismiss
              if (details.velocity.pixelsPerSecond.dy < -100) {
                onDismiss();
              }
            },
            onTap: onDismiss,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.only(top: topPadding),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: effectiveBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon or spinner
                      if (isLoading)
                        SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? Colors.white70 : Colors.grey.shade700,
                          ),
                        )
                      else
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: isDark
                                ? effectiveAccent.withValues(alpha: 0.25)
                                : effectiveAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, size: 18, color: isDark
                              ? effectiveAccent.withValues(alpha: 0.9)
                              : effectiveAccent),
                        ),
                      const SizedBox(width: 12),
                      // Message
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.grey.shade900,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Action button
                      if (actionLabel != null && onAction != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onAction,
                          child: Text(
                            actionLabel!,
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF81C784)
                                  : effectiveAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
}