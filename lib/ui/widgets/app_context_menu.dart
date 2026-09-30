import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import '../../utils/platform_utils.dart';

/// Data class for a context menu item.
class ContextMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const ContextMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// Wraps a child widget with right-click (secondary tap) context menu support.
///
/// On desktop/web: right-click shows a popup menu with the provided items.
/// On mobile: no-op (pass-through), long-press is handled elsewhere.
///
/// Usage:
/// ```dart
/// ContextMenuRegion(
///   items: [
///     ContextMenuItem(icon: Icons.edit, label: 'Edit', onTap: () => ...),
///     ContextMenuItem(icon: Icons.delete, label: 'Delete', onTap: () => ..., isDestructive: true),
///   ],
///   child: RecipeCard(...),
/// )
/// ```
class ContextMenuRegion extends StatelessWidget {
  final Widget child;
  final List<ContextMenuItem> items;

  const ContextMenuRegion({
    super.key,
    required this.child,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Only add context menu on desktop/web
    if (isMobile || items.isEmpty) return child;

    return GestureDetector(
      onSecondaryTapDown: (details) {
        showAppContextMenu(context, details.globalPosition, items);
      },
      child: child,
    );
  }
}

/// Shows the app's context menu with [items] at the global pointer [position]
/// (for widgets that detect the secondary click themselves).
void showAppContextMenu(BuildContext context, Offset position, List<ContextMenuItem> items) {
  _AppContextMenu(items).show(context, position);
}

class _AppContextMenu {
  final List<ContextMenuItem> items;
  const _AppContextMenu(this.items);

  void show(BuildContext context, Offset position) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    // The overlay may be a nested navigator's (e.g. inside the desktop shell's
    // content panel), so convert the global pointer position into its space.
    final local = overlay.globalToLocal(position);

    showMenu<void>(
      context: context,
      position: RelativeRect.fromLTRB(
        local.dx,
        local.dy,
        overlay.size.width - local.dx,
        overlay.size.height - local.dy,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: Radii.lgAll,
        side: BorderSide(color: c.hairline),
      ),
      color: c.surface,
      elevation: 8,
      menuPadding: const EdgeInsets.all(Space.xs),
      constraints: const BoxConstraints(minWidth: 200),
      items: items.map((item) {
        final color = item.isDestructive
            ? theme.colorScheme.error
            : c.textPrimary;
        return PopupMenuItem<void>(
          onTap: item.onTap,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
          child: Row(
            children: [
              Icon(item.icon, size: 17, color: item.isDestructive ? color : c.textTertiary),
              const SizedBox(width: Space.md),
              Text(
                item.label,
                style: TextStyle(color: color, fontSize: 13.5),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
