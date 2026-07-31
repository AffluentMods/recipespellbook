import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
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
    // Two-pane only when the CONTENT area (after the sidebar) is wide enough
    // for a readable detail column — not merely the window.
    if (!Responsive.useTwoPane(context)) {
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

/// Warm editorial placeholder shown in the detail pane before a recipe is
/// picked — reads like an open cookbook waiting on a page.
class _DefaultPlaceholder extends StatelessWidget {
  final ThemeData theme;
  const _DefaultPlaceholder({required this.theme});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      color: c.surface,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: c.surfaceRaised,
              shape: BoxShape.circle,
              border: Border.all(color: c.outline.withValues(alpha: 0.4)),
            ),
            child: Icon(Icons.auto_stories_outlined, size: 40, color: c.accent),
          ),
          const SizedBox(height: 20),
          Text(
            'Choose a recipe',
            style: theme.textTheme.titleMedium?.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick one from the list to read it here.',
            style: theme.textTheme.bodyMedium?.copyWith(color: c.textTertiary),
          ),
        ],
      ),
    );
  }
}
