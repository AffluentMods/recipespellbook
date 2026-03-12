import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';

/// Responsive two-pane layout for desktop screens.
///
/// On desktop (≥900dp): shows master + detail side-by-side.
/// On compact/tablet: shows master only (detail pushed as full-screen route).
///
/// Usage:
/// ```dart
/// MasterDetailLayout(
///   master: RecipeListGrid(...),
///   detail: selectedId != null
///       ? RecipeDetailView(id: selectedId)
///       : null,
///   detailPlaceholder: EmptyState('Select a recipe'),
/// )
/// ```
class MasterDetailLayout extends StatelessWidget {
  /// The list/grid pane (left side on desktop).
  final Widget master;

  /// The detail pane (right side on desktop). Null shows placeholder.
  final Widget? detail;

  /// Placeholder shown when no detail is selected.
  final Widget? detailPlaceholder;

  /// Width of the master pane. Defaults to 380dp.
  final double masterWidth;

  const MasterDetailLayout({
    super.key,
    required this.master,
    this.detail,
    this.detailPlaceholder,
    this.masterWidth = 380,
  });

  @override
  Widget build(BuildContext context) {
    // Only show side-by-side on desktop-class widths
    if (!Responsive.isDesktopLayout(context)) {
      return master;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // ── Master pane ──
        SizedBox(
          width: masterWidth,
          child: master,
        ),

        // ── Divider ──
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.2 : 0.15),
        ),

        // ── Detail pane ──
        Expanded(
          child: detail ?? detailPlaceholder ?? _DefaultPlaceholder(theme: theme),
        ),
      ],
    );
  }
}

/// Default "select an item" placeholder for the detail pane.
class _DefaultPlaceholder extends StatelessWidget {
  final ThemeData theme;
  const _DefaultPlaceholder({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 48,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Select an item to view details',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
