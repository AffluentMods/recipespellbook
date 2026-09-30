import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import '../../utils/responsive_utils.dart';
import 'keycap.dart';

/// The multi-select action bar for the screen that is currently selecting, or
/// null when nothing is selecting. A screen publishes its bar on entering
/// select mode; the app shell swaps it in for the bottom nav (so the two never
/// stack). Only one screen is ever selecting at a time.
final selectionBarProvider =
    StateProvider<SelectionActionBar?>((ref) => null);

/// One cell in a [SelectionActionBar].
class SelectionAction {
  final IconData icon;

  /// Already-resolved (localised) label.
  final String label;
  final VoidCallback onTap;

  /// Destructive actions render in the destructive role and are pinned last.
  final bool destructive;

  const SelectionAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });
}

/// The single shared contextual action bar used by every multi-select screen
/// (recipe grid, shopping list, …). One rounded, inset row of icon-over-label
/// cells in a single outline icon weight — no accent, no circled glyphs. The
/// destructive action is always the last cell, after a divider. Constructive
/// actions beyond [maxInlineActions] collapse into a "More" cell.
class SelectionActionBar extends StatelessWidget {
  /// Constructive actions, in order.
  final List<SelectionAction> actions;

  /// The single destructive action (e.g. Delete) — always rendered last.
  final SelectionAction destructive;

  /// Max cells before constructive actions overflow into "More".
  final int maxInlineActions;

  /// Extra actions always surfaced under "More".
  final List<SelectionAction> moreActions;

  /// Number of selected items — shown by the floating desktop toolbar.
  final int? count;

  /// Clears the selection — the desktop toolbar's close button (and Esc).
  final VoidCallback? onClear;

  const SelectionActionBar({
    super.key,
    required this.actions,
    required this.destructive,
    this.maxInlineActions = 4,
    this.moreActions = const [],
    this.count,
    this.onClear,
  });

  /// Approximate rendered height (used by screens for bottom scroll padding).
  static const double height = 76;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    // Desktop: a compact floating toolbar over the content panel instead of a
    // full-width bottom bar (the shell floats it; see _DesktopShellLayout).
    if (Responsive.isDesktopLayout(context)) {
      return _DesktopSelectionToolbar(bar: this);
    }

    List<SelectionAction> inline;
    List<SelectionAction> overflow;
    if (actions.length > maxInlineActions) {
      final keep = maxInlineActions - 1;
      inline = actions.take(keep).toList();
      overflow = [...actions.skip(keep), ...moreActions];
    } else {
      inline = actions;
      overflow = [...moreActions];
    }

    final cells = <Widget>[
      for (final a in inline) _cell(colors, a),
      if (overflow.isNotEmpty)
        _cell(
          colors,
          SelectionAction(
            icon: Icons.more_horiz,
            label: l10n.moreLabel,
            onTap: () => _showMore(context, colors, overflow),
          ),
        ),
      // Thin divider, then the pinned destructive action.
      Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        color: colors.outline.withValues(alpha: 0.5),
      ),
      _cell(colors, destructive),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Material(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.outline.withValues(alpha: 0.4)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(children: cells),
          ),
        ),
      ),
    );
  }

  Widget _cell(AppColors colors, SelectionAction a) {
    final fg = a.destructive ? colors.destructive : colors.textPrimary;
    final labelColor =
        a.destructive ? colors.destructive : colors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: a.onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(a.icon, size: 21, color: fg),
              const SizedBox(height: 4),
              Text(
                a.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.1,
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMore(
      BuildContext context, AppColors colors, List<SelectionAction> items) {
    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            for (final a in items)
              ListTile(
                leading: Icon(a.icon,
                    color:
                        a.destructive ? colors.destructive : colors.textPrimary),
                title: Text(a.label,
                    style: TextStyle(
                        color: a.destructive
                            ? colors.destructive
                            : colors.textPrimary)),
                onTap: () {
                  Navigator.pop(ctx);
                  a.onTap();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}


/// Floating selection toolbar for pointer UIs: "3 selected · actions · ✕".
/// Every action is visible (icon + label), so nothing hides behind "More";
/// the destructive action sits last after a divider.
class _DesktopSelectionToolbar extends StatelessWidget {
  final SelectionActionBar bar;
  const _DesktopSelectionToolbar({required this.bar});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final all = [...bar.actions, ...bar.moreActions];

    Widget action(SelectionAction a) {
      final fg = a.destructive ? c.destructive : c.textPrimary;
      return Tooltip(
        message: a.label,
        waitDuration: const Duration(milliseconds: 700),
        child: TextButton.icon(
          onPressed: a.onTap,
          icon: Icon(a.icon, size: 17, color: fg),
          label: Text(a.label, maxLines: 1, overflow: TextOverflow.ellipsis),
          style: TextButton.styleFrom(
            foregroundColor: fg,
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: Space.md - 2),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
          ),
        ),
      );
    }

    Widget divider() => Container(
          width: 1,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: Space.xs),
          color: c.hairline,
        );

    return Material(
      color: c.surface,
      elevation: 0,
      borderRadius: Radii.lgAll,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.xs + 2, vertical: Space.xs + 1),
        decoration: BoxDecoration(
          borderRadius: Radii.lgAll,
          border: Border.all(color: c.textPrimary.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.16),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (bar.count != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.sm + 2),
                  child: Text(
                    l10n.selectionCount(bar.count!),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.accent,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              if (bar.count != null) divider(),
              for (final a in all) action(a),
              divider(),
              action(bar.destructive),
              if (bar.onClear != null) ...[
                divider(),
                Tooltip(
                  message: withShortcut(l10n.selectionClear, l10n.keyEsc),
                  child: IconButton(
                    onPressed: bar.onClear,
                    icon: Icon(Icons.close_rounded, size: 18, color: c.textSecondary),
                    constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
