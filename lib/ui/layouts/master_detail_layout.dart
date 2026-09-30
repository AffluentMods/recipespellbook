import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import '../../utils/responsive_utils.dart';

/// Responsive two-pane layout for desktop screens.
///
/// When the shell's CONTENT area is wide enough ([Responsive.useTwoPane]) it
/// shows master + detail side by side with a draggable splitter between them
/// (double-click resets; the width persists under [persistKey]). Otherwise it
/// shows the master only and the detail is pushed as its own route.
///
/// Usage:
/// ```dart
/// MasterDetailLayout(
///   persistKey: 'recipes',
///   master: RecipeList(...),
///   detail: selectedId != null ? RecipeDetailView(id: selectedId) : null,
/// )
/// ```
class MasterDetailLayout extends StatefulWidget {
  /// The list/grid pane (left side on desktop).
  final Widget master;

  /// The detail pane (right side on desktop). Null shows placeholder.
  final Widget? detail;

  /// Placeholder shown when no detail is selected.
  final Widget? detailPlaceholder;

  /// Default width of the master pane.
  final double masterWidth;
  final double minMasterWidth;
  final double maxMasterWidth;

  /// The detail pane never gets narrower than this; the master yields first.
  final double minDetailWidth;

  /// SharedPreferences key suffix for remembering the user's split.
  final String? persistKey;

  const MasterDetailLayout({
    super.key,
    required this.master,
    this.detail,
    this.detailPlaceholder,
    this.masterWidth = 340,
    this.minMasterWidth = 260,
    this.maxMasterWidth = 560,
    this.minDetailWidth = 440,
    this.persistKey,
  });

  @override
  State<MasterDetailLayout> createState() => _MasterDetailLayoutState();
}

class _MasterDetailLayoutState extends State<MasterDetailLayout> {
  double? _width;

  String? get _prefsKey =>
      widget.persistKey == null ? null : 'master_detail_width_${widget.persistKey}';

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final key = _prefsKey;
    if (key == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getDouble(key);
      if (saved != null && mounted) setState(() => _width = saved);
    } catch (_) {}
  }

  void _persist() {
    final key = _prefsKey;
    final w = _width;
    if (key == null || w == null) return;
    SharedPreferences.getInstance().then((p) => p.setDouble(key, w)).catchError((_) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Two-pane only when the CONTENT area (after the sidebar) is wide enough
    // for a readable detail column — not merely the window.
    if (!Responsive.useTwoPane(context)) {
      return widget.master;
    }

    return LayoutBuilder(builder: (context, constraints) {
      final total = constraints.maxWidth;
      final maxAllowed = (total - widget.minDetailWidth)
          .clamp(widget.minMasterWidth, widget.maxMasterWidth);
      final width = (_width ?? widget.masterWidth).clamp(widget.minMasterWidth, maxAllowed);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: width, child: widget.master),
          PaneSplitter(
            onDrag: (dx) => setState(() {
              _width = (width + dx).clamp(widget.minMasterWidth, maxAllowed);
            }),
            onDragEnd: _persist,
            onReset: () {
              setState(() => _width = widget.masterWidth);
              _persist();
            },
          ),
          Expanded(
            child: widget.detail ?? widget.detailPlaceholder ?? const _DefaultPlaceholder(),
          ),
        ],
      );
    });
  }
}

/// A vertical pane divider you can drag: 1 px hairline inside an 8 px hit zone,
/// resize cursor, accent highlight while hovered/dragged, double-click to reset.
class PaneSplitter extends StatefulWidget {
  final ValueChanged<double> onDrag;
  final VoidCallback? onDragEnd;
  final VoidCallback? onReset;

  const PaneSplitter({super.key, required this.onDrag, this.onDragEnd, this.onReset});

  @override
  State<PaneSplitter> createState() => _PaneSplitterState();
}

class _PaneSplitterState extends State<PaneSplitter> {
  bool _hovered = false;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final active = _hovered || _dragging;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => setState(() => _dragging = true),
        onHorizontalDragUpdate: (d) => widget.onDrag(d.delta.dx),
        onHorizontalDragEnd: (_) {
          setState(() => _dragging = false);
          widget.onDragEnd?.call();
        },
        onDoubleTap: widget.onReset,
        child: SizedBox(
          width: 9,
          child: Center(
            child: AnimatedContainer(
              duration: Motion.fast,
              width: active ? 2 : 1,
              color: active ? c.accent.withValues(alpha: 0.55) : c.hairline,
            ),
          ),
        ),
      ),
    );
  }
}

/// Warm editorial placeholder shown in the detail pane before a recipe is
/// picked — reads like an open cookbook waiting on a page.
class _DefaultPlaceholder extends StatelessWidget {
  const _DefaultPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
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
              border: Border.all(color: c.hairline),
            ),
            child: Icon(Icons.auto_stories_outlined, size: 40, color: c.accent),
          ),
          const SizedBox(height: Space.xl),
          Text(
            l10n.detailChooseRecipe,
            style: theme.textTheme.titleLarge?.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Space.xs + 2),
          Text(
            l10n.detailChooseRecipeHint,
            style: theme.textTheme.bodyMedium?.copyWith(color: c.textTertiary),
          ),
        ],
      ),
    );
  }
}
