import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/navigation_guard_provider.dart';
import '../../router/router.dart';

/// Top-level places in the desktop sidebar, in sidebar order. The order is
/// also the ⌘/Ctrl+1…7 shortcut order, so the two can never disagree.
enum ShellDestination {
  home(
    '/',
    Icons.home_outlined,
    Icons.home_rounded,
    LogicalKeyboardKey.digit1,
    '1',
  ),
  allRecipes(
    '/recipes',
    Icons.restaurant_menu_outlined,
    Icons.restaurant_menu_rounded,
    LogicalKeyboardKey.digit2,
    '2',
  ),
  favorites(
    '/recipes/favorites',
    Icons.favorite_border_rounded,
    Icons.favorite_rounded,
    LogicalKeyboardKey.digit3,
    '3',
  ),
  cookbooks(
    '/cookbooks',
    Icons.menu_book_outlined,
    Icons.menu_book_rounded,
    LogicalKeyboardKey.digit4,
    '4',
  ),
  planner(
    '/planner',
    Icons.calendar_today_outlined,
    Icons.calendar_today_rounded,
    LogicalKeyboardKey.digit5,
    '5',
  ),
  shopping(
    '/shopping',
    Icons.shopping_basket_outlined,
    Icons.shopping_basket_rounded,
    LogicalKeyboardKey.digit6,
    '6',
  ),
  community(
    '/community',
    Icons.people_outline_rounded,
    Icons.people_rounded,
    LogicalKeyboardKey.digit7,
    '7',
  ),
  // Not numbered — reached from the sidebar footer / ⌘, / the palette.
  help('/help', Icons.help_outline_rounded, Icons.help_rounded, null, null),
  settings(
    '/settings',
    Icons.settings_outlined,
    Icons.settings_rounded,
    LogicalKeyboardKey.comma,
    ',',
  ),
  account(
    '/settings/account',
    Icons.person_outline_rounded,
    Icons.person_rounded,
    null,
    null,
  );

  const ShellDestination(
    this.path,
    this.icon,
    this.selectedIcon,
    this.shortcutKey,
    this.shortcutLabel,
  );

  final String path;
  final IconData icon;
  final IconData selectedIcon;

  /// Key used with the primary modifier (⌘ / Ctrl), if any.
  final LogicalKeyboardKey? shortcutKey;

  /// Printed form of [shortcutKey] for tooltips and the palette.
  final String? shortcutLabel;

  String label(AppLocalizations l10n) => switch (this) {
    ShellDestination.home => l10n.navHome,
    ShellDestination.allRecipes => l10n.sidebarAllRecipes,
    ShellDestination.favorites => l10n.favoritesTitle,
    ShellDestination.cookbooks => l10n.navCookbooks,
    ShellDestination.planner => l10n.navPlanner,
    ShellDestination.shopping => l10n.navShopping,
    ShellDestination.community => l10n.navCommunity,
    ShellDestination.help => l10n.helpTitle,
    ShellDestination.settings => l10n.settingsTitle,
    ShellDestination.account => l10n.accountTitle,
  };

  /// Index of the matching phone bottom-nav tab, so switching on desktop keeps
  /// the mobile tab state coherent if the window is narrowed.
  int? get mobileTabIndex => switch (this) {
    ShellDestination.home => MobileTab.home.index,
    ShellDestination.planner => MobileTab.planner.index,
    ShellDestination.shopping => MobileTab.shopping.index,
    ShellDestination.community => MobileTab.community.index,
    ShellDestination.help ||
    ShellDestination.settings ||
    ShellDestination.account => MobileTab.more.index,
    _ => null,
  };

  /// Numbered destinations (⌘1…⌘7), in sidebar order.
  static List<ShellDestination> get numbered =>
      values.where((d) => d.shortcutKey != null && d != settings).toList();
}

/// The phone tab bar / tablet rail, in order. Everything that isn't a tab
/// (library, cookbooks, import, sharing, settings, help) lives on the More
/// page, and the library is also one tap from Home.
enum MobileTab {
  home('/', Icons.home_outlined, Icons.home_rounded),
  planner('/planner', Icons.calendar_today_outlined, Icons.calendar_today_rounded),
  shopping('/shopping', Icons.shopping_basket_outlined, Icons.shopping_basket_rounded),
  community('/community', Icons.people_outline_rounded, Icons.people_rounded),
  more('/more', Icons.more_horiz_rounded, Icons.more_horiz_rounded);

  const MobileTab(this.path, this.icon, this.selectedIcon);

  final String path;
  final IconData icon;
  final IconData selectedIcon;

  String label(AppLocalizations l10n) => switch (this) {
    MobileTab.home => l10n.navHome,
    MobileTab.planner => l10n.navPlanner,
    MobileTab.shopping => l10n.navShopping,
    MobileTab.community => l10n.navCommunity,
    MobileTab.more => l10n.navMore,
  };

  /// The tab a location belongs to, or null for pages reachable from several
  /// tabs (a recipe, search, the library, cookbooks…), which keep the tab the
  /// user came from lit.
  static MobileTab? forLocation(String location) {
    final path = Uri.parse(location).path;
    if (path == '/' || path.startsWith('/categories') || path.startsWith('/courses')) {
      return MobileTab.home;
    }
    if (path.startsWith('/planner')) return MobileTab.planner;
    if (path.startsWith('/shopping')) return MobileTab.shopping;
    if (path.startsWith('/community')) return MobileTab.community;
    if (path == '/more' || path.startsWith('/settings') || path == '/help' || path == '/about') {
      return MobileTab.more;
    }
    return null;
  }
}

/// Which sidebar destination a location belongs to, or null for detail routes
/// (recipe view/editor, substitutions, search…) that keep whichever section
/// the user came from lit.
ShellDestination? destinationForLocation(String location) {
  final path = Uri.parse(location).path;
  if (path == '/' ||
      path.startsWith('/categories') ||
      path.startsWith('/courses') ||
      path == '/recipes/recent' ||
      path == '/recipes/quick-access' ||
      path == '/recipes/uncategorized') {
    return ShellDestination.home;
  }
  if (path == '/recipes/favorites') return ShellDestination.favorites;
  if (path == '/recipes' || path == '/recipes/all' || path == '/recipes/list') {
    return ShellDestination.allRecipes;
  }
  if (path == '/cookbooks' ||
      (path.startsWith('/cookbook/') && path.endsWith('/edit'))) {
    return ShellDestination.cookbooks;
  }
  if (path.startsWith('/planner')) return ShellDestination.planner;
  if (path.startsWith('/shopping')) return ShellDestination.shopping;
  if (path.startsWith('/community')) return ShellDestination.community;
  if (path == '/settings/account') return ShellDestination.account;
  if (path.startsWith('/settings') || path == '/about') {
    return ShellDestination.settings;
  }
  if (path == '/help' || path == '/import-guides') return ShellDestination.help;
  return null;
}

/// The destination lit for detail routes: the last top-level section visited.
final lastShellDestinationProvider = StateProvider<ShellDestination>(
  (ref) => ShellDestination.home,
);

/// Navigate to a top-level destination from anywhere (sidebar, shortcut,
/// palette). Uses `go` so repeated presses never stack pages, and asks an
/// in-shell editor to confirm discarding unsaved changes first.
Future<void> goToDestination(
  WidgetRef ref,
  ShellDestination destination,
) async {
  if (!await confirmDiscardBeforeLeaving(ref)) return;
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null || !ctx.mounted) return;
  ctx.go(destination.path);
}

/// `go` to an arbitrary in-shell location with the unsaved-editor guard.
Future<void> guardedGo(WidgetRef ref, String location) async {
  if (!await confirmDiscardBeforeLeaving(ref)) return;
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null || !ctx.mounted) return;
  ctx.go(location);
}

// ── Sidebar collapse (⌘/Ctrl+B), persisted ──

class SidebarCollapsedNotifier extends StateNotifier<bool> {
  SidebarCollapsedNotifier() : super(false) {
    _restore();
  }

  static const _key = 'desktop_sidebar_collapsed';

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_key);
      if (saved != null && mounted) state = saved;
    } catch (_) {}
  }

  void toggle() => set(!state);

  void set(bool collapsed) {
    state = collapsed;
    SharedPreferences.getInstance()
        .then((p) => p.setBool(_key, collapsed))
        .catchError((_) => false);
  }
}

final sidebarCollapsedProvider =
    StateNotifierProvider<SidebarCollapsedNotifier, bool>(
      (ref) => SidebarCollapsedNotifier(),
    );
