import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../router/router.dart';
import '../../providers/cookbook_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import '../../utils/recipe_title.dart';
import '../shell/shell_navigation.dart';
import 'keycap.dart';
import 'new_recipe_dialog.dart';
import 'shortcuts_cheat_sheet.dart';

/// Whether the Ctrl/Cmd+K command palette is showing.
final commandPaletteOpenProvider = StateProvider<bool>((ref) => false);

void openCommandPalette(WidgetRef ref) =>
    ref.read(commandPaletteOpenProvider.notifier).state = true;

/// Mounts the command-palette overlay above [child]. Place once near the app
/// root. Renders nothing until the palette is opened (Ctrl/Cmd+K or the
/// sidebar search entry).
class CommandPaletteHost extends ConsumerWidget {
  final Widget child;
  const CommandPaletteHost({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(commandPaletteOpenProvider);
    return Stack(children: [child, if (open) const _CommandPaletteOverlay()]);
  }
}

enum _Section { recent, goTo, actions, recipes, search }

/// A single actionable row in the palette.
class _PaletteItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? shortcut;
  final _Section section;

  /// Extra words that should match (not displayed).
  final String keywords;
  final VoidCallback run;
  const _PaletteItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.shortcut,
    required this.section,
    this.keywords = '',
    required this.run,
  });
}

class _CommandPaletteOverlay extends ConsumerStatefulWidget {
  const _CommandPaletteOverlay();

  @override
  ConsumerState<_CommandPaletteOverlay> createState() =>
      _CommandPaletteOverlayState();
}

class _CommandPaletteOverlayState extends ConsumerState<_CommandPaletteOverlay>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focus = FocusNode(onKeyEvent: _onKey);
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: Motion.base,
  )..forward();
  String _query = '';
  int _selected = 0;

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    _scroll.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _close() {
    if (mounted) ref.read(commandPaletteOpenProvider.notifier).state = false;
  }

  // Navigation runs against the root navigator context (matches AppShortcuts).
  BuildContext get _navContext => rootNavigatorKey.currentContext ?? context;

  String get _cookbookId => ref.read(selectedCookbookIdProvider) ?? 'starter';

  void _goTo(ShellDestination d) {
    _close();
    goToDestination(ref, d);
  }

  void _push(String location) {
    _close();
    _navContext.push(location);
  }

  String _sectionLabel(AppLocalizations l10n, _Section s) => switch (s) {
    _Section.recent => l10n.paletteSectionRecent,
    _Section.goTo => l10n.paletteSectionGoTo,
    _Section.actions => l10n.paletteSectionActions,
    _Section.recipes => l10n.paletteSectionRecipes,
    _Section.search => l10n.searchTitle,
  };

  List<_PaletteItem> _commands(AppLocalizations l10n) {
    String sc(String key, {bool shift = false}) =>
        shortcutLabel(context, key, shift: shift);
    return [
      // ── Go to (sidebar order, same shortcuts) ──
      for (final d in [
        ...ShellDestination.numbered,
        ShellDestination.settings,
        ShellDestination.help,
      ])
        _PaletteItem(
          icon: d.icon,
          label: d.label(l10n),
          shortcut: d.shortcutLabel == null ? null : sc(d.shortcutLabel!),
          section: _Section.goTo,
          run: () => _goTo(d),
        ),
      // ── Actions ──
      _PaletteItem(
        icon: Icons.add_rounded,
        label: l10n.shortcutNewRecipe,
        shortcut: sc('N'),
        section: _Section.actions,
        run: () {
          _close();
          showNewRecipeDialog(_navContext, _cookbookId);
        },
      ),
      _PaletteItem(
        icon: Icons.download_outlined,
        label: l10n.importRecipe,
        subtitle: l10n.paletteImportSubtitle,
        section: _Section.actions,
        keywords: 'url link photo file paste',
        run: () {
          _close();
          showImportDialog(_navContext, _cookbookId);
        },
      ),
      _PaletteItem(
        icon: Icons.manage_search_rounded,
        label: l10n.paletteAdvancedSearch,
        shortcut: sc('F'),
        section: _Section.actions,
        keywords: 'find filter ingredient',
        run: () {
          _close();
          guardedGo(ref, '/search');
        },
      ),
      _PaletteItem(
        icon: Icons.brightness_6_outlined,
        label: l10n.paletteToggleTheme,
        section: _Section.actions,
        keywords: 'dark light mode appearance',
        run: () {
          _close();
          final current = ref.read(settingsProvider).themeMode;
          final isDark =
              current == ThemeMode.dark ||
              (current == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(_navContext) ==
                      Brightness.dark);
          ref
              .read(settingsProvider.notifier)
              .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
        },
      ),
      _PaletteItem(
        icon: Icons.palette_outlined,
        label: l10n.paletteAppearance,
        section: _Section.actions,
        keywords: 'theme colors palette',
        run: () => _push('/settings/appearance'),
      ),
      _PaletteItem(
        icon: Icons.view_sidebar_outlined,
        label: l10n.shortcutToggleSidebar,
        shortcut: sc('B'),
        section: _Section.actions,
        run: () {
          _close();
          ref.read(sidebarCollapsedProvider.notifier).toggle();
        },
      ),
      _PaletteItem(
        icon: Icons.keyboard_outlined,
        label: l10n.shortcutsTitle,
        shortcut: sc('/'),
        section: _Section.actions,
        keywords: 'keys hotkeys',
        run: () => toggleShortcutsCheatSheet(ref),
      ),
      _PaletteItem(
        icon: Icons.swap_horiz_rounded,
        label: l10n.transferTitle,
        section: _Section.actions,
        keywords: 'move device export',
        run: () => _push('/transfer'),
      ),
      _PaletteItem(
        icon: Icons.menu_book_outlined,
        label: l10n.importGuides,
        section: _Section.actions,
        keywords: 'help import',
        run: () {
          _close();
          guardedGo(ref, '/import-guides');
        },
      ),
    ];
  }

  /// Rank: exact > startsWith > word-start > contains. 0 = no match.
  int _score(String haystack, String q) {
    if (q.isEmpty) return 1;
    final h = haystack.toLowerCase();
    if (h == q) return 100;
    if (h.startsWith(q)) return 70;
    if (h.split(RegExp(r'[\s\-]+')).any((w) => w.startsWith(q))) return 50;
    if (h.contains(q)) return 30;
    return 0;
  }

  List<_PaletteItem> _results(AppLocalizations l10n) {
    final q = _query.trim().toLowerCase();

    // Empty query: Recent recipes first, then all commands (deterministic order).
    if (q.isEmpty) {
      final recent = ref.read(recentRecipesProvider).valueOrNull ?? const [];
      final recentItems = recent
          .take(5)
          .map(
            (r) => _PaletteItem(
              icon: Icons.history_rounded,
              label: normalizeTitle(r.title).title,
              section: _Section.recent,
              run: () => _push('/recipe/${r.id}'),
            ),
          );
      return [...recentItems, ..._commands(l10n)];
    }

    final items = <(_PaletteItem, int)>[];
    for (final c in _commands(l10n)) {
      final s =
          _score(c.label, q) +
          (c.subtitle != null ? _score(c.subtitle!, q) ~/ 4 : 0) +
          (c.keywords.isNotEmpty ? _score(c.keywords, q) ~/ 3 : 0);
      if (s > 0) items.add((c, s));
    }
    items.sort((a, b) => b.$2.compareTo(a.$2));
    final commandItems = items.map((e) => e.$1).toList();

    final recipeItems = <_PaletteItem>[];
    final recipes = ref.read(allRecipesProvider).valueOrNull ?? const [];
    final scored = <(dynamic, int)>[];
    for (final r in recipes) {
      final s = _score(r.title, q);
      if (s > 0) scored.add((r, s));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    for (final e in scored.take(8)) {
      final r = e.$1;
      recipeItems.add(
        _PaletteItem(
          icon: Icons.restaurant_menu_rounded,
          label: normalizeTitle(r.title).title,
          section: _Section.recipes,
          run: () => _push('/recipe/${r.id}'),
        ),
      );
    }

    final searchAll = _PaletteItem(
      icon: Icons.search_rounded,
      label: l10n.paletteSearchAll(_query.trim()),
      section: _Section.search,
      run: () {
        _close();
        guardedGo(
          ref,
          Uri(
            path: '/search',
            queryParameters: {'q': _query.trim()},
          ).toString(),
        );
      },
    );

    // Recipes lead when the query looks like a recipe search.
    return recipeItems.isNotEmpty &&
            (commandItems.isEmpty || _score(commandItems.first.label, q) < 70)
        ? [...recipeItems, ...commandItems, searchAll]
        : [...commandItems, ...recipeItems, searchAll];
  }

  void _moveSelection(int delta, int count) {
    if (count == 0) return;
    setState(() => _selected = (_selected + delta + count) % count);
    // Keep the highlighted row in view (rows are ~40px).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final target = (_selected * 40.0) - 120;
      _scroll.animateTo(
        target.clamp(0, _scroll.position.maxScrollExtent),
        duration: Motion.fast,
        curve: Motion.standard,
      );
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final results = _results(AppLocalizations.of(context)!);
    switch (e.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        _moveSelection(1, results.length);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _moveSelection(-1, results.length);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
        if (_selected >= 0 && _selected < results.length) {
          results[_selected].run();
        }
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        _close();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    ref.watch(
      recentRecipesProvider,
    ); // repaint when Recent loads on empty query
    final results = _results(l10n);
    if (_selected >= results.length) {
      _selected = results.isEmpty ? 0 : results.length - 1;
    }
    final curved = CurvedAnimation(parent: _anim, curve: Motion.emphasized);

    return Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: FadeTransition(
          opacity: curved,
          child: Stack(
            children: [
              // Dim + blur backdrop; click to dismiss.
              Positioned.fill(
                child: GestureDetector(
                  onTap: _close,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: ColoredBox(
                      color: Theme.of(
                        context,
                      ).colorScheme.scrim.withValues(alpha: 0.32),
                    ),
                  ),
                ),
              ),
              // Palette panel, top-centre.
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 96),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 640,
                        maxHeight: MediaQuery.sizeOf(context).height * 0.66,
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
                            // Search field
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                Space.lg + 2,
                                Space.md,
                                Space.md,
                                Space.md,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    size: 20,
                                    color: c.textTertiary,
                                  ),
                                  const SizedBox(width: Space.md),
                                  Expanded(
                                    child: TextField(
                                      focusNode: _focus,
                                      controller: _controller,
                                      autofocus: true,
                                      style: TextStyle(
                                        color: c.textPrimary,
                                        fontSize: 16.5,
                                      ),
                                      cursorColor: c.accent,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: false,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: Space.sm,
                                            ),
                                        hintText: l10n.paletteHint,
                                        hintStyle: TextStyle(
                                          color: c.textTertiary,
                                          fontSize: 16.5,
                                        ),
                                      ),
                                      onChanged: (v) => setState(() {
                                        _query = v;
                                        _selected = 0;
                                      }),
                                    ),
                                  ),
                                  Keycap(l10n.keyEsc),
                                ],
                              ),
                            ),
                            Divider(height: 1, thickness: 1, color: c.hairline),
                            // Results
                            Flexible(
                              child: results.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: Space.xxxl - 4,
                                      ),
                                      child: Text(
                                        l10n.paletteNoMatches,
                                        style: TextStyle(color: c.textTertiary),
                                      ),
                                    )
                                  : ListView.builder(
                                      controller: _scroll,
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.all(
                                        Space.xs + 2,
                                      ),
                                      itemCount: results.length,
                                      itemBuilder: (context, i) {
                                        final item = results[i];
                                        final row = _PaletteRow(
                                          item: item,
                                          selected: i == _selected,
                                          onHover: () {
                                            if (_selected != i) {
                                              setState(() => _selected = i);
                                            }
                                          },
                                          onTap: item.run,
                                        );
                                        final showHeader =
                                            item.section != _Section.search &&
                                            (i == 0 ||
                                                results[i - 1].section !=
                                                    item.section);
                                        if (!showHeader) return row;
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                Space.md,
                                                i == 0 ? Space.xs : Space.md,
                                                Space.md,
                                                Space.xs,
                                              ),
                                              child: Text(
                                                _sectionLabel(
                                                  l10n,
                                                  item.section,
                                                ).toUpperCase(),
                                                style: TextStyle(
                                                  color: c.textTertiary,
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.7,
                                                ),
                                              ),
                                            ),
                                            row,
                                          ],
                                        );
                                      },
                                    ),
                            ),
                            // Footer hint row
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Space.lg,
                                vertical: Space.sm,
                              ),
                              decoration: BoxDecoration(
                                color: c.textPrimary.withValues(alpha: 0.025),
                                border: Border(
                                  top: BorderSide(color: c.hairline),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Keycap('↑↓', dense: true),
                                  const SizedBox(width: Space.xs + 2),
                                  Text(
                                    l10n.paletteNavigateHint,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: c.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(width: Space.lg),
                                  Keycap(l10n.keyEnter, dense: true),
                                  const SizedBox(width: Space.xs + 2),
                                  Text(
                                    l10n.paletteOpenHint,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: c.textTertiary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Keycap(
                                    shortcutLabel(context, '/'),
                                    dense: true,
                                  ),
                                  const SizedBox(width: Space.xs + 2),
                                  Text(
                                    l10n.shortcutsTitle,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: c.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  final _PaletteItem item;
  final bool selected;
  final VoidCallback onHover;
  final VoidCallback onTap;

  const _PaletteRow({
    required this.item,
    required this.selected,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: item.subtitle != null ? 46 : 38,
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
          decoration: BoxDecoration(
            color: selected ? colors.selectedFill : Colors.transparent,
            borderRadius: Radii.mdAll,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 17,
                color: selected ? colors.accent : colors.textTertiary,
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 13.5,
                      ),
                    ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: 11.5,
                        ),
                      ),
                  ],
                ),
              ),
              if (item.shortcut != null) ...[
                const SizedBox(width: Space.sm + 2),
                Keycap(item.shortcut!, dense: true),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
