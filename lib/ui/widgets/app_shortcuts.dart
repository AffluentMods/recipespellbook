import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../router/router.dart';
import '../../utils/platform_utils.dart';
import '../shell/app_shell.dart';
import 'new_recipe_dialog.dart';

/// Wraps child in a [CallbackShortcuts] widget providing desktop keyboard
/// shortcuts. No-op on mobile (shortcuts are only registered on desktop/web).
///
/// Shortcuts:
///   Ctrl/Cmd + N — New recipe
///   Ctrl/Cmd + F — Search
///   Ctrl/Cmd + , — Settings
///   Ctrl/Cmd + 1–4 — Switch tabs
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

      // Ctrl/Cmd + 1 — Home
      shortcut(LogicalKeyboardKey.digit1): () {
        ref.read(currentNavIndexProvider.notifier).state = 0;
        final ctx = rootNavigatorKey.currentContext ?? context;
        ctx.go('/');
      },

      // Ctrl/Cmd + 2 — Cookbooks
      shortcut(LogicalKeyboardKey.digit2): () {
        ref.read(currentNavIndexProvider.notifier).state = 1;
        final ctx = rootNavigatorKey.currentContext ?? context;
        ctx.go('/cookbooks');
      },

      // Ctrl/Cmd + 3 — Planner
      shortcut(LogicalKeyboardKey.digit3): () {
        ref.read(currentNavIndexProvider.notifier).state = 2;
        final ctx = rootNavigatorKey.currentContext ?? context;
        ctx.go('/planner');
      },

      // Ctrl/Cmd + 4 — Shopping
      shortcut(LogicalKeyboardKey.digit4): () {
        ref.read(currentNavIndexProvider.notifier).state = 3;
        final ctx = rootNavigatorKey.currentContext ?? context;
        ctx.go('/shopping');
      },
    };
  }
}
