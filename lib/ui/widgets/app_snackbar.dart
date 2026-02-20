import 'package:flutter/material.dart';

/// Modern snackbar helper — use throughout the app.
///
/// Usage:
///   AppSnackbar.success(context, 'Recipe saved!');
///   AppSnackbar.error(context, 'Something went wrong');
///   AppSnackbar.info(context, 'Signed out');
///   AppSnackbar.warning(context, 'Low storage');

class AppSnackbar {
  AppSnackbar._();

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

  /// Loading snackbar with spinner — stays until manually dismissed
  static void loading(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(message,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.grey.shade900,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        elevation: isDark ? 8 : 2,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        duration: const Duration(seconds: 30),
      ),
    );
  }

  /// Dismiss current snackbar
  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  static void _show(BuildContext context, String message, IconData icon, Color accent, Color bgLight) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: isDark ? accent.withValues(alpha: 0.25) : accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: isDark ? accent.withValues(alpha: 0.9) : accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.grey.shade900,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isDark
            ? Color.lerp(Colors.grey.shade900, accent, 0.08)
            : bgLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        elevation: isDark ? 8 : 2,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        duration: const Duration(seconds: 3),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}