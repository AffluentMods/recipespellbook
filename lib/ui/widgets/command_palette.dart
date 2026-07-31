import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/router.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/navigation_guard_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/recipe_title.dart';
import 'new_recipe_dialog.dart';

/// Whether the Ctrl/Cmd+K command palette is showing.
final commandPaletteOpenProvider = StateProvider<bool>((ref) => false);

void openCommandPalette(WidgetRef ref) =>
    ref.read(commandPaletteOpenProvider.notifier).state = true;

/// Mounts the command-palette overlay above [child]. Place once near the app
/// root. Renders nothing until the palette is opened (Ctrl/Cmd+K or the title
/// bar search pill).
class CommandPaletteHost extends ConsumerWidget {
  final Widget child;
  const CommandPaletteHost({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(commandPaletteOpenProvider);
    return Stack(
      children: [
        child,
        if (open) const _CommandPaletteOverlay(),
      ],
    );
  }
}

/// A single actionable row in the palette.
class _PaletteItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? shortcut;
  final bool isRecipe;
  final String? section; // 'Recent' | 'Commands' | 'Recipes'
  final VoidCallback run;
  const _PaletteItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.shortcut,
    this.isRecipe = false,
    this.section,
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
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 170),
  )..forward();
  String _query = '';
  int _selected = 0;

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _close() {
    if (mounted) ref.read(commandPaletteOpenProvider.notifier).state = false;
  }

  // Navigation runs against the root navigator context (matches AppShortcuts).
  BuildContext get _navContext => rootNavigatorKey.currentContext ?? context;

  Future<void> _go(String location) async {
    // Guard an in-shell editor from being unmounted with unsaved changes.
    if (!await confirmDiscardBeforeLeaving(ref)) return;
    _close();
    _navContext.go(location);
  }

  void _push(String location) {
    _close();
    _navContext.push(location);
  }

  List<_PaletteItem> _commands() {
    return [
      _PaletteItem(
        icon: Icons.home_outlined,
        label: 'Home',
        subtitle: 'Go to home',
        shortcut: 'Ctrl 1',
        section: 'Commands',
        run: () => _go('/'),
      ),
      _PaletteItem(
        icon: Icons.menu_book_outlined,
        label: 'Cookbooks',
        subtitle: 'Browse cookbooks',
        shortcut: 'Ctrl 2',
        section: 'Commands',
        run: () => _go('/cookbooks'),
      ),
      _PaletteItem(
        icon: Icons.calendar_today_outlined,
        label: 'Planner',
        subtitle: 'Meal planner',
        shortcut: 'Ctrl 3',
        section: 'Commands',
        run: () => _go('/planner'),
      ),
      _PaletteItem(
        icon: Icons.shopping_cart_outlined,
        label: 'Shopping',
        subtitle: 'Shopping lists',
        shortcut: 'Ctrl 4',
        section: 'Commands',
        run: () => _go('/shopping'),
      ),
      _PaletteItem(
        icon: Icons.groups_outlined,
        label: 'Community',
        subtitle: 'Discover recipes',
        shortcut: 'Ctrl 5',
        section: 'Commands',
        run: () => _go('/community'),
      ),
      _PaletteItem(
        icon: Icons.add_circle_outline,
        label: 'New recipe',
        subtitle: 'Create a recipe',
        shortcut: 'Ctrl N',
        section: 'Commands',
        run: () {
          _close();
          showNewRecipeDialog(_navContext, 'starter');
        },
      ),
      _PaletteItem(
        icon: Icons.download_outlined,
        label: 'Import recipe',
        subtitle: 'From a link, photo, or file',
        section: 'Commands',
        run: () {
          _close();
          showImportDialog(_navContext, 'starter');
        },
      ),
      _PaletteItem(
        icon: Icons.search,
        label: 'Search',
        subtitle: 'Full search',
        shortcut: 'Ctrl F',
        section: 'Commands',
        run: () => _push('/search'),
      ),
      _PaletteItem(
        icon: Icons.brightness_6_outlined,
        label: 'Toggle light / dark',
        subtitle: 'Switch theme mode',
        section: 'Commands',
        run: () {
          _close();
          final current = ref.read(settingsProvider).themeMode;
          final isDark = current == ThemeMode.dark ||
              (current == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(_navContext) == Brightness.dark);
          ref.read(settingsProvider.notifier)
              .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
        },
      ),
      _PaletteItem(
        icon: Icons.palette_outlined,
        label: 'Appearance',
        subtitle: 'Theme & colors',
        section: 'Commands',
        run: () => _push('/settings/appearance'),
      ),
      _PaletteItem(
        icon: Icons.swap_horiz,
        label: 'Transfer data',
        subtitle: 'Move recipes to another device',
        section: 'Commands',
        run: () => _push('/transfer'),
      ),
      _PaletteItem(
        icon: Icons.settings_outlined,
        label: 'Settings',
        subtitle: 'Preferences',
        shortcut: 'Ctrl ,',
        section: 'Commands',
        run: () => _push('/settings'),
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

  List<_PaletteItem> _results() {
    final q = _query.trim().toLowerCase();

    // Empty query: Recent recipes first, then all commands (deterministic order).
    if (q.isEmpty) {
      final recent = ref.read(recentRecipesProvider).valueOrNull ?? const [];
      final recentItems = recent.take(6).map((r) => _PaletteItem(
            icon: Icons.history,
            label: normalizeTitle(r.title).title,
            subtitle: 'Recently viewed',
            isRecipe: true,
            section: 'Recent',
            run: () => _push('/recipe/${r.id}'),
          ));
      return [...recentItems, ..._commands()];
    }

    final items = <(_PaletteItem, int)>[];
    for (final c in _commands()) {
      final s = _score(c.label, q) +
          (c.subtitle != null ? _score(c.subtitle!, q) ~/ 4 : 0);
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
      recipeItems.add(_PaletteItem(
        icon: Icons.restaurant_menu,
        label: normalizeTitle(r.title).title,
        subtitle: 'Open recipe',
        isRecipe: true,
        section: 'Recipes',
        run: () => _push('/recipe/${r.id}'),
      ));
    }

    return [...commandItems, ...recipeItems];
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final results = _results();
    switch (e.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        setState(() => _selected =
            results.isEmpty ? 0 : (_selected + 1) % results.length);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        setState(() => _selected = results.isEmpty
            ? 0
            : (_selected - 1 + results.length) % results.length);
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
    ref.watch(recentRecipesProvider); // repaint when Recent loads on empty query
    final results = _results();
    if (_selected >= results.length) _selected = results.isEmpty ? 0 : results.length - 1;

    return Positioned.fill(
      child: FadeTransition(
        opacity: _anim,
        child: Stack(
          children: [
            // Dim + blur backdrop; click to dismiss.
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(color: Colors.black.withValues(alpha: 0.42)),
                ),
              ),
            ),
            // Palette panel, top-center.
            Align(
              alignment: const Alignment(0, -0.55),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.97, end: 1).animate(
                  CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 640,
                    maxHeight: MediaQuery.sizeOf(context).height * 0.7,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: c.surfaceHigh,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.outline.withValues(alpha: 0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Search field
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                          child: Row(
                            children: [
                              Icon(Icons.search, size: 20, color: c.textTertiary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  focusNode: _focus,
                                  controller: _controller,
                                  autofocus: true,
                                  style: TextStyle(color: c.textPrimary, fontSize: 16),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    hintText: 'Search recipes and commands…',
                                    hintStyle: TextStyle(color: c.textTertiary),
                                  ),
                                  onChanged: (v) => setState(() {
                                    _query = v;
                                    _selected = 0;
                                  }),
                                ),
                              ),
                              _Kbd(text: 'Esc', c: c),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: c.outline.withValues(alpha: 0.3)),
                        // Results
                        Flexible(
                          child: results.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 28),
                                  child: Text('No matches',
                                      style: TextStyle(color: c.textTertiary)),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(6),
                                  itemCount: results.length,
                                  itemBuilder: (context, i) {
                                    final item = results[i];
                                    final sel = i == _selected;
                                    final row = _PaletteRow(
                                      item: item,
                                      selected: sel,
                                      colors: c,
                                      onHover: () => setState(() => _selected = i),
                                      onTap: item.run,
                                    );
                                    final showHeader = item.section != null &&
                                        (i == 0 || results[i - 1].section != item.section);
                                    if (!showHeader) return row;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(12, i == 0 ? 4 : 10, 12, 4),
                                          child: Text(
                                            item.section!.toUpperCase(),
                                            style: TextStyle(
                                              color: c.textTertiary,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ),
                                        row,
                                      ],
                                    );
                                  },
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
    );
  }
}

class _PaletteRow extends StatelessWidget {
  final _PaletteItem item;
  final bool selected;
  final AppColors colors;
  final VoidCallback onHover;
  final VoidCallback onTap;

  const _PaletteRow({
    required this.item,
    required this.selected,
    required this.colors,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? colors.accent.withValues(alpha: 0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(item.icon,
                  size: 18,
                  color: selected ? colors.accent : colors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.textTertiary, fontSize: 11.5),
                      ),
                  ],
                ),
              ),
              if (item.shortcut != null) ...[
                const SizedBox(width: 10),
                _Kbd(text: item.shortcut!, c: colors),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A small keycap chip (e.g. "Ctrl K", "Esc").
class _Kbd extends StatelessWidget {
  final String text;
  final AppColors c;
  const _Kbd({required this.text, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: c.outline.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: c.textTertiary,
          fontSize: 10.5,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
