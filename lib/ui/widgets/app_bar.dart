import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Shared app bar with search, overflow menu, and settings
class RecipeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<PopupMenuEntry<String>>? menuItems;
  final void Function(String)? onMenuSelected;
  final VoidCallback? onSearchTap;
  final bool showSearch;
  final bool showSettings;
  final List<Widget>? extraActions;

  const RecipeAppBar({
    super.key,
    required this.title,
    this.menuItems,
    this.onMenuSelected,
    this.onSearchTap,
    this.showSearch = true,
    this.showSettings = true,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        if (extraActions != null) ...extraActions!,
        if (showSearch)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: onSearchTap ?? () {
              // Default search action - can be overridden
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search coming soon')),
              );
            },
          ),
        if (menuItems != null && menuItems!.isNotEmpty)
          PopupMenuButton<String>(
            onSelected: onMenuSelected,
            itemBuilder: (context) => menuItems!,
          ),
        if (showSettings)
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Helper to create standard menu items
class MenuItems {
  static PopupMenuItem<String> item({
    required String value,
    required IconData icon,
    required String label,
    Color? iconColor,
    Color? textColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(label, style: TextStyle(color: textColor)),
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  static PopupMenuItem<String> delete() {
    return item(
      value: 'delete',
      icon: Icons.delete_outlined,
      label: 'Delete',
      iconColor: Colors.red,
      textColor: Colors.red,
    );
  }

  static PopupMenuItem<String> edit() {
    return item(
      value: 'edit',
      icon: Icons.edit_outlined,
      label: 'Edit',
    );
  }

  static PopupMenuItem<String> share() {
    return item(
      value: 'share',
      icon: Icons.share_outlined,
      label: 'Share',
    );
  }

  static PopupMenuItem<String> export() {
    return item(
      value: 'export',
      icon: Icons.file_download_outlined,
      label: 'Export',
    );
  }
}