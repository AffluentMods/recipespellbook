import 'package:flutter/material.dart';
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
        _showContextMenu(context, details.globalPosition);
      },
      child: child,
    );
  }

  void _showContextMenu(BuildContext context, Offset position) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<void>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: isDark
          ? theme.colorScheme.surfaceContainerHigh
          : theme.colorScheme.surface,
      elevation: 8,
      items: items.map((item) {
        final color = item.isDestructive
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface;
        return PopupMenuItem<void>(
          onTap: item.onTap,
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: color),
              const SizedBox(width: 10),
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
