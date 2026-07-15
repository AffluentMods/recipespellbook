import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';

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

  const SelectionActionBar({
    super.key,
    required this.actions,
    required this.destructive,
    this.maxInlineActions = 4,
    this.moreActions = const [],
  });

  /// Approximate rendered height (used by screens for bottom scroll padding).
  static const double height = 76;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;

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
    showModalBottomSheet(
      context: context,
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
