import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import '../../utils/platform_utils.dart';
import '../shell/shell_navigation.dart';
import 'command_palette.dart';
import 'keycap.dart';

/// Whether the keyboard-shortcuts cheat sheet is showing (Ctrl/Cmd+/).
final shortcutsCheatSheetOpenProvider = StateProvider<bool>((ref) => false);

/// Toggle the cheat sheet, closing the command palette first so the two never
/// stack.
void toggleShortcutsCheatSheet(WidgetRef ref) {
  ref.read(commandPaletteOpenProvider.notifier).state = false;
  final n = ref.read(shortcutsCheatSheetOpenProvider.notifier);
  n.state = !n.state;
}

/// Mounts the cheat-sheet overlay above [child]; renders nothing until opened.
class ShortcutsCheatSheetHost extends ConsumerWidget {
  final Widget child;
  const ShortcutsCheatSheetHost({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(shortcutsCheatSheetOpenProvider);
    return Stack(children: [child, if (open) const _CheatSheetOverlay()]);
  }
}

class _ShortcutGroup {
  final String title;
  final List<(String, String)> rows; // (label, keys)
  const _ShortcutGroup(this.title, this.rows);
}

class _CheatSheetOverlay extends ConsumerStatefulWidget {
  const _CheatSheetOverlay();

  @override
  ConsumerState<_CheatSheetOverlay> createState() => _CheatSheetOverlayState();
}

class _CheatSheetOverlayState extends ConsumerState<_CheatSheetOverlay>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focus = FocusNode(onKeyEvent: _onKey);
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
  )..forward();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _close() {
    if (mounted)
      ref.read(shortcutsCheatSheetOpenProvider.notifier).state = false;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.escape) {
      _close();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    String sc(String key, {bool shift = false}) =>
        shortcutLabel(context, key, shift: shift);
    final clickMod = usesCommandKey ? '⌘' : l10n.keyCtrl;
    final groups = <_ShortcutGroup>[
      _ShortcutGroup(l10n.shortcutsGeneral, [
        (l10n.shortcutCommandPalette, sc('K')),
        if (!isWeb) (l10n.searchTitle, sc('F')),
        (l10n.shortcutNewRecipe, sc('N')),
        (l10n.shortcutToggleSidebar, sc('B')),
        (l10n.settingsTitle, sc(',')),
        (l10n.shortcutGoBack, sc('[')),
        (l10n.shortcutsTitle, sc('/')),
        (l10n.shortcutDismiss, l10n.keyEsc),
      ]),
      _ShortcutGroup(l10n.shortcutsNavigation, [
        for (final d in ShellDestination.numbered)
          (d.label(l10n), sc(d.shortcutLabel!)),
      ]),
      _ShortcutGroup(l10n.shortcutsRecipes, [
        (l10n.shortcutMoveSelection, '↑  ↓'),
        (l10n.shortcutOpenRecipe, l10n.keyEnter),
        (l10n.shortcutAddToSelection, '$clickMod + ${l10n.shortcutClick}'),
        (l10n.shortcutRangeSelect, '${l10n.keyShift} + ${l10n.shortcutClick}'),
        (l10n.shortcutTrash, l10n.keyDelete),
      ]),
      _ShortcutGroup(l10n.shortcutsShopping, [
        (l10n.shortcutAddItem, l10n.keyEnter),
        (l10n.shortcutToggleItem, l10n.keySpace),
      ]),
      _ShortcutGroup(l10n.shortcutsEditor, [
        (l10n.shortcutSaveRecipe, sc('S')),
      ]),
    ];

    return Positioned.fill(
      child: FadeTransition(
        opacity: _anim,
        child: Material(
          type: MaterialType.transparency,
          child: Focus(
            focusNode: _focus,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _close,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: ColoredBox(
                        color: Theme.of(
                          context,
                        ).colorScheme.scrim.withValues(alpha: 0.32),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.35),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.97, end: 1).animate(
                      CurvedAnimation(
                        parent: _anim,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 720,
                        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: Space.xxl,
                        ),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: Radii.xlAll,
                          border: Border.all(
                            color: c.textPrimary.withValues(alpha: 0.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.shadow.withValues(alpha: 0.28),
                              blurRadius: 48,
                              offset: const Offset(0, 24),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                Space.xl,
                                Space.lg,
                                Space.lg,
                                Space.md,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.keyboard_outlined,
                                    size: 20,
                                    color: c.textTertiary,
                                  ),
                                  const SizedBox(width: Space.md),
                                  Expanded(
                                    child: Text(
                                      l10n.shortcutsTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: c.textPrimary,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Keycap(l10n.keyEsc),
                                ],
                              ),
                            ),
                            Divider(height: 1, thickness: 1, color: c.hairline),
                            Flexible(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  Space.xl,
                                  Space.sm,
                                  Space.xl,
                                  Space.lg,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final twoCol = constraints.maxWidth >= 560;
                                    final colWidth = twoCol
                                        ? (constraints.maxWidth - Space.xxxl) /
                                              2
                                        : constraints.maxWidth;
                                    Widget groupWidget(
                                      _ShortcutGroup g,
                                    ) => SizedBox(
                                      width: colWidth,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              0,
                                              Space.md,
                                              0,
                                              Space.xs + 2,
                                            ),
                                            child: Text(
                                              g.title.toUpperCase(),
                                              style: TextStyle(
                                                color: c.textTertiary,
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ),
                                          for (final row in g.rows)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      row.$1,
                                                      style: TextStyle(
                                                        color: c.textSecondary,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                  Keycap(row.$2),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                    if (!twoCol) {
                                      return Column(
                                        children: [
                                          for (final g in groups)
                                            groupWidget(g),
                                        ],
                                      );
                                    }
                                    // Balance: first two groups left, the rest right.
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            for (final g in groups.take(2))
                                              groupWidget(g),
                                          ],
                                        ),
                                        const SizedBox(width: Space.xxxl),
                                        Column(
                                          children: [
                                            for (final g in groups.skip(2))
                                              groupWidget(g),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
