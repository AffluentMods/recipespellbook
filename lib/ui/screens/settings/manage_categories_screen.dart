import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/course_category_data.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/taxonomy_translator.dart';
import '../../widgets/app_snackbar.dart';

class ManageCategoriesScreen extends ConsumerStatefulWidget {
  const ManageCategoriesScreen({super.key});
  @override
  ConsumerState<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends ConsumerState<ManageCategoriesScreen> {
  List<_CategoryItem> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final settings = ref.read(settingsProvider);
    final cookbookId = settings.currentCookbookId ?? 'cookbook_default';
    final dao = ref.read(customTaxonomyDaoProvider);
    final custom = await dao.getCustomCategories(cookbookId);

    final cats = <_CategoryItem>[];
    for (final c in CategoryData.categories) {
      cats.add(_CategoryItem(id: c.id, name: c.name, emoji: c.emoji, isBuiltIn: true));
    }
    for (final c in custom) {
      cats.add(_CategoryItem(id: c.id, name: c.name, emoji: c.emoji ?? '📁', isBuiltIn: false));
    }
    setState(() { _categories = cats; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final translator = TaxonomyTranslator.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsManageCategories),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) { if (v == 'restore') _restoreDefaults(); },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'restore', child: Text(l10n.taxonomyRestoreDefaults)),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final c = _categories[i];
          final displayName = c.isBuiltIn ? translator.translateCategory(c.name) : c.name;

          return ListTile(
            leading: CircleAvatar(child: Text(c.emoji, style: const TextStyle(fontSize: 20))),
            title: Text(displayName),
            subtitle: Text(c.isBuiltIn ? l10n.taxonomyBuiltIn : l10n.taxonomyCustom),
            trailing: c.isBuiltIn
                ? const Icon(Icons.lock_outline, size: 18)
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _editCategory(c)),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCategory(c)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCategory,
        icon: const Icon(Icons.add),
        label: Text(l10n.taxonomyAddCategory),
      ),
    );
  }

  void _addCategory() {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final emojiController = TextEditingController(text: '📁');

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.taxonomyAddCategory),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            SizedBox(
              width: 70,
              child: TextField(
                controller: emojiController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.taxonomyCategoryName,
                  hintText: l10n.taxonomyCategoryNameHint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Text(
            l10n.taxonomyEmojiHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: () async {
          if (nameController.text.trim().isEmpty) return;
          final settings = ref.read(settingsProvider);
          final dao = ref.read(customTaxonomyDaoProvider);
          await dao.insertCustomCategory(CustomCategoriesCompanion.insert(
            id: 'category_${DateTime.now().millisecondsSinceEpoch}',
            cookbookId: settings.currentCookbookId ?? 'cookbook_default',
            name: nameController.text.trim(),
            emoji: drift.Value(emojiController.text.trim().isEmpty ? '📁' : emojiController.text.trim()),
          ));
          if (ctx.mounted) Navigator.pop(ctx);
          _loadCategories();
        }, child: Text(l10n.actionAdd)),
      ],
    ));
  }

  void _editCategory(_CategoryItem c) {
    if (c.isBuiltIn) return;
    final l10n = AppLocalizations.of(context)!;

    final nameController = TextEditingController(text: c.name);
    final emojiController = TextEditingController(text: c.emoji);

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.taxonomyEditCategory),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            SizedBox(
              width: 70,
              child: TextField(
                controller: emojiController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.taxonomyCategoryName,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ]),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: () async {
          if (nameController.text.trim().isEmpty) return;
          await ref.read(customTaxonomyDaoProvider).updateCustomCategory(
            c.id,
            CustomCategoriesCompanion(
              name: drift.Value(nameController.text.trim()),
              emoji: drift.Value(emojiController.text.trim().isEmpty ? '📁' : emojiController.text.trim()),
            ),
          );
          if (ctx.mounted) Navigator.pop(ctx);
          _loadCategories();
        }, child: Text(l10n.actionSave)),
      ],
    ));
  }

  void _deleteCategory(_CategoryItem c) {
    if (c.isBuiltIn) return;
    final l10n = AppLocalizations.of(context)!;

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.taxonomyDeleteCategory),
      content: Text(l10n.taxonomyDeleteCategoryMessage(c.name)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: () async {
          await ref.read(customTaxonomyDaoProvider).deleteCustomCategory(c.id);
          if (ctx.mounted) Navigator.pop(ctx);
          _loadCategories();
        }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: Text(l10n.actionDelete)),
      ],
    ));
  }

  void _restoreDefaults() async {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.read(settingsProvider);
    final cookbookId = settings.currentCookbookId ?? 'cookbook_default';
    final dao = ref.read(customTaxonomyDaoProvider);
    final custom = await dao.getCustomCategories(cookbookId);

    for (final c in custom) {
      await dao.deleteCustomCategory(c.id);
    }

    _loadCategories();
    if (mounted) {
      AppSnackbar.info(context, l10n.taxonomyDefaultsRestored);
    }
  }
}

class _CategoryItem {
  final String id, name, emoji;
  final bool isBuiltIn;
  _CategoryItem({required this.id, required this.name, required this.emoji, required this.isBuiltIn});
}