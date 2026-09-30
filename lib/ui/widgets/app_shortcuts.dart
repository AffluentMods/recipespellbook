import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cookbook_provider.dart';
import '../../router/router.dart';
import '../../utils/platform_utils.dart';
import '../shell/app_shell.dart';
import '../shell/shell_navigation.dart';
import 'command_palette.dart';
import 'keycap.dart';
import 'shortcuts_cheat_sheet.dart';
import 'new_recipe_dialog.dart';

/// App-wide keyboard shortcuts (desktop + web; no-op on phones/tablets).
/// The primary modifier is ⌘ on macOS and Ctrl elsewhere.
///
///   ⌘K        Command palette          ⌘/   Keyboard shortcuts
///   ⌘N        New recipe (in the selected cookbook)
///   ⌘F        Search (native desktop only — on web the browser keeps ⌘F)
///   ⌘B        Toggle sidebar           ⌘,   Settings
///   ⌘1 … ⌘7   Sidebar destinations, in sidebar order
///             (Home, All recipes, Favorites, Cookbooks, Planner, Shopping,
///             Community — see [ShellDestination])
class AppShortcuts extends ConsumerWidget {
  final Widget child;
  const AppShortcuts({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On mobile, skip shortcuts entirely
    if (isMobile) return child;

    return CallbackShortcuts(
      bindings: _buildBindings(context, ref),
      child: Focus(autofocus: true, child: child),
    );
  }

  Map<ShortcutActivator, VoidCallback> _buildBindings(
    BuildContext context,
    WidgetRef ref,
  ) {
    BuildContext navContext() => rootNavigatorKey.currentContext ?? context;

    void go(ShellDestination d) {
      final tab = d.mobileTabIndex;
      if (tab != null) ref.read(currentNavIndexProvider.notifier).state = tab;
      goToDestination(ref, d);
    }

    return {
      primaryShortcut(LogicalKeyboardKey.keyK): () => openCommandPalette(ref),
      primaryShortcut(LogicalKeyboardKey.slash): () =>
          toggleShortcutsCheatSheet(ref),
      primaryShortcut(LogicalKeyboardKey.keyN): () {
        final cookbookId = ref.read(selectedCookbookIdProvider) ?? 'starter';
        showNewRecipeDialog(navContext(), cookbookId);
      },
      // Web: leave ⌘/Ctrl+F to the browser's find-in-page. The palette (⌘K)
      // covers quick search there.
      if (!isWeb)
        primaryShortcut(LogicalKeyboardKey.keyF): () =>
            guardedGo(ref, '/search'),
      primaryShortcut(LogicalKeyboardKey.keyB): () =>
          ref.read(sidebarCollapsedProvider.notifier).toggle(),
      primaryShortcut(LogicalKeyboardKey.comma): () =>
          go(ShellDestination.settings),
      // ⌘[ — back (desktop convention).
      primaryShortcut(LogicalKeyboardKey.bracketLeft): () {
        final ctx = navContext();
        if (ctx.canPop()) ctx.pop();
      },
      for (final d in ShellDestination.numbered)
        primaryShortcut(d.shortcutKey!): () => go(d),
    };
  }
}
