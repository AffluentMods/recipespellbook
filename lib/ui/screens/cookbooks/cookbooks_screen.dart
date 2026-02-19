import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/database.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../data/rpg/rpg_text.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../shell/app_shell.dart';
import '../../widgets/placeholder_image.dart';

class CookbooksScreen extends ConsumerWidget {
  const CookbooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cookbooksAsync = ref.watch(cookbooksProvider);
    final selectedId = ref.watch(selectedCookbookIdProvider);
    final nerdMode = ref.watch(settingsProvider).nerdMode;
    final rpg = RpgText.of(l10n, nerdMode);

    return Scaffold(
      appBar: AppBar(
        title: Text(rpg.cookbooksTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: cookbooksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${l10n.errorGeneric}: $e')),
        data: (cookbooks) => _CookbookGrid(
          cookbooks: cookbooks,
          selectedId: selectedId,
          onCookbookSelected: (id) {
            ref.read(selectedCookbookIdProvider.notifier).state = id;
            ref.read(currentNavIndexProvider.notifier).state = 0;
            context.go('/');
          },
        ),
      ),
      floatingActionButton: _ModernFAB(
        onPressed: () => _showNewCookbookDialog(context, ref),
        label: l10n.cookbookAdd,
      ),
    );
  }

  void _showNewCookbookDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cookbookAdd),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.recipeFieldTitle,
            hintText: l10n.cookbookNameHint,
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final dao = ref.read(cookbookDaoProvider);
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                dao.insertCookbook(CookbooksCompanion.insert(
                  id: id,
                  name: controller.text.trim(),
                ));
                Navigator.pop(context);
              }
            },
            child: Text(l10n.actionAdd),
          ),
        ],
      ),
    );
  }
}

class _CookbookGrid extends ConsumerWidget {
  final List<Cookbook> cookbooks;
  final String? selectedId;
  final ValueChanged<String> onCookbookSelected;

  const _CookbookGrid({
    required this.cookbooks,
    required this.selectedId,
    required this.onCookbookSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Hint text at top - FIXED: Using Expanded + overflow handling
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.touch_app, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.cookbookHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),

        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: cookbooks.length,
            itemBuilder: (context, index) {
              final cookbook = cookbooks[index];
              final isSelected = cookbook.id == selectedId;

              return _CookbookCard(
                cookbook: cookbook,
                isSelected: isSelected,
                onTap: () => onCookbookSelected(cookbook.id),
                onLongPress: () => _showEditSheet(context, ref, cookbook),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, Cookbook cookbook) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.rename),
              onTap: () {
                Navigator.pop(ctx);
                _showRenameDialog(context, ref, cookbook);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: Text(l10n.actionDelete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteConfirmation(context, ref, cookbook);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, Cookbook cookbook) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: cookbook.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renameCookbook),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.recipeFieldTitle),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                // Use proper Drift companion for update
                ref.read(cookbookDaoProvider).updateCookbookName(
                  cookbook.id,
                  controller.text.trim(),
                );
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Cookbook cookbook) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cookbookDelete),
        content: Text(l10n.cookbookDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () {
              ref.read(cookbookDaoProvider).deleteCookbook(cookbook.id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }
}

class _CookbookCard extends StatelessWidget {
  final Cookbook cookbook;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _CookbookCard({
    required this.cookbook,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: theme.colorScheme.primary, width: 3)
              : BorderSide.none,
        ),
        child: Stack(
          children: [
            // Cover image or placeholder
            // Note: Cookbook may use 'imagePath' field - adjust as needed
            Positioned.fill(
              child: const CookbookPlaceholderImage(height: double.infinity),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Name and count
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cookbook.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Selected indicator
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            // Edit button (top-left)
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () => context.push('/cookbook/${cookbook.id}/edit'),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════════
// MODERN FAB
// ═══════════════════════════════════════════════════════════════════

class _ModernFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;
  final IconData icon;
  const _ModernFAB({required this.onPressed, this.label, this.icon = Icons.add});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.primary;
    final fg = theme.colorScheme.onPrimary;

    if (label != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: bg.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: FloatingActionButton.extended(
          onPressed: onPressed,
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: Icon(icon, size: 22),
          label: Text(label!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: bg.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, size: 26),
      ),
    );
  }
}