import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../router/router.dart';
import '../../utils/platform_utils.dart';
import '../../providers/navigation_guard_provider.dart';
import '../shell/app_shell.dart';
import 'command_palette.dart';
import 'shortcuts_cheat_sheet.dart';
import 'new_recipe_dialog.dart';

/// Wraps child in a [CallbackShortcuts] widget providing desktop keyboard
/// shortcuts. No-op on mobile (shortcuts are only registered on desktop/web).
///
/// Shortcuts:
///   Ctrl/Cmd + N — New recipe
///   Ctrl/Cmd + F — Search
///   Ctrl/Cmd + , — Settings
///   Ctrl/Cmd + 1–5 — Switch tabs (1=Home, 2=Cookbooks, 3=Planner, 4=Shopping, 5=Community)
class AppShortcuts extends ConsumerWidget {
  final Widget child;
  const AppShortcuts({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On mobile, skip shortcuts entirely
    if (isMobile) return child;

    return CallbackShortcuts(
      bindings: _buildBindings(context, ref),
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }

  Map<ShortcutActivator, VoidCallback> _buildBindings(
    BuildContext context,
    WidgetRef ref,
  ) {
    // Use Meta on macOS, Control everywhere else
    final bool useMeta = defaultTargetPlatform == TargetPlatform.macOS;

    SingleActivator shortcut(LogicalKeyboardKey key) =>
        SingleActivator(key, meta: useMeta, control: !useMeta);

    return {
      // Ctrl/Cmd + K — Command palette
      shortcut(LogicalKeyboardKey.keyK): () => openCommandPalette(ref),

      // Ctrl/Cmd + / — Keyboard shortcuts cheat sheet
      shortcut(LogicalKeyboardKey.slash): () => toggleShortcutsCheatSheet(ref),

      // Ctrl/Cmd + N — New recipe
      shortcut(LogicalKeyboardKey.keyN): () {
        final ctx = rootNavigatorKey.currentContext ?? context;
        showNewRecipeDialog(ctx, 'starter');
      },

      // Ctrl/Cmd + F — Search
      shortcut(LogicalKeyboardKey.keyF): () {
        final ctx = rootNavigatorKey.currentContext ?? context;
        ctx.push('/search');
      },

      // Ctrl/Cmd + , — Settings
      shortcut(LogicalKeyboardKey.comma): () {
        final ctx = rootNavigatorKey.currentContext ?? context;
        ctx.push('/settings');
      },

      // Ctrl/Cmd + 1 — Home (guarded: .go unmounts an in-shell editor)
      shortcut(LogicalKeyboardKey.digit1): () async {
        if (!await confirmDiscardBeforeLeaving(ref)) return;
        ref.read(currentNavIndexProvider.notifier).state = 0;
        (rootNavigatorKey.currentContext ?? context).go('/');
      },

      // Ctrl/Cmd + 2 — Cookbooks
      shortcut(LogicalKeyboardKey.digit2): () async {
        if (!await confirmDiscardBeforeLeaving(ref)) return;
        ref.read(currentNavIndexProvider.notifier).state = 1;
        (rootNavigatorKey.currentContext ?? context).go('/cookbooks');
      },

      // Ctrl/Cmd + 3 — Planner
      shortcut(LogicalKeyboardKey.digit3): () async {
        if (!await confirmDiscardBeforeLeaving(ref)) return;
        ref.read(currentNavIndexProvider.notifier).state = 2;
        (rootNavigatorKey.currentContext ?? context).go('/planner');
      },

      // Ctrl/Cmd + 4 — Shopping
      shortcut(LogicalKeyboardKey.digit4): () async {
        if (!await confirmDiscardBeforeLeaving(ref)) return;
        ref.read(currentNavIndexProvider.notifier).state = 3;
        (rootNavigatorKey.currentContext ?? context).go('/shopping');
      },

      // Ctrl/Cmd + 5 — Community
      shortcut(LogicalKeyboardKey.digit5): () async {
        if (!await confirmDiscardBeforeLeaving(ref)) return;
        (rootNavigatorKey.currentContext ?? context).go('/community');
      },
    };
  }
}
