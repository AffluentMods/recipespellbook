import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../data/course_category_data.dart';
import '../../../utils/taxonomy_translator.dart';
import '../../widgets/app_snackbar.dart';

class ManageCoursesScreen extends ConsumerStatefulWidget {
  const ManageCoursesScreen({super.key});
  @override
  ConsumerState<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends ConsumerState<ManageCoursesScreen> {
  List<_CourseItem> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final settings = ref.read(settingsProvider);
    final cookbookId = settings.currentCookbookId ?? 'cookbook_default';
    final dao = ref.read(customTaxonomyDaoProvider);
    final custom = await dao.getCustomCourses(cookbookId);

    final courses = <_CourseItem>[];
    // Add built-in courses (NOT editable)
    for (final c in CourseData.courses) {
      courses.add(_CourseItem(id: c.id, name: c.name, emoji: c.emoji, isBuiltIn: true));
    }
    // Add custom courses (editable) - use saved emoji
    for (final c in custom) {
      courses.add(_CourseItem(id: c.id, name: c.name, emoji: c.emoji ?? '🍽️', isBuiltIn: false));
    }
    setState(() { _courses = courses; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final translator = TaxonomyTranslator.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsManageCourses),
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
        itemCount: _courses.length,
        itemBuilder: (_, i) {
          final c = _courses[i];
          // Translate built-in course names
          final displayName = c.isBuiltIn
              ? translator.translateCourse(c.name)
              : c.name;

          return ListTile(
            leading: CircleAvatar(child: Text(c.emoji, style: const TextStyle(fontSize: 20))),
            title: Text(displayName),
            subtitle: Text(c.isBuiltIn ? l10n.taxonomyBuiltIn : l10n.taxonomyCustom),
            trailing: c.isBuiltIn
                ? const Icon(Icons.lock_outline, size: 18)
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _editCourse(c)),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCourse(c)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCourse,
        icon: const Icon(Icons.add),
        label: Text(l10n.taxonomyAddCourse),
      ),
    );
  }

  void _addCourse() {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final emojiController = TextEditingController(text: '🍽️');

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.taxonomyAddCourse),
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
                  labelText: l10n.taxonomyCourseName,
                  hintText: l10n.taxonomyCourseNameHint,
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
          await dao.insertCustomCourse(CustomCoursesCompanion.insert(
            id: 'course_${DateTime.now().millisecondsSinceEpoch}',
            cookbookId: settings.currentCookbookId ?? 'cookbook_default',
            name: nameController.text.trim(),
            emoji: drift.Value(emojiController.text.trim().isEmpty ? '🍽️' : emojiController.text.trim()),
          ));
          if (ctx.mounted) Navigator.pop(ctx);
          _loadCourses();
        }, child: Text(l10n.actionAdd)),
      ],
    ));
  }

  void _editCourse(_CourseItem c) {
    if (c.isBuiltIn) return;
    final l10n = AppLocalizations.of(context)!;

    final nameController = TextEditingController(text: c.name);
    final emojiController = TextEditingController(text: c.emoji);

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.taxonomyEditCourse),
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
                  labelText: l10n.taxonomyCourseName,
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
          await ref.read(customTaxonomyDaoProvider).updateCustomCourse(
            c.id,
            CustomCoursesCompanion(
              name: drift.Value(nameController.text.trim()),
              emoji: drift.Value(emojiController.text.trim().isEmpty ? '🍽️' : emojiController.text.trim()),
            ),
          );
          if (ctx.mounted) Navigator.pop(ctx);
          _loadCourses();
        }, child: Text(l10n.actionSave)),
      ],
    ));
  }

  void _deleteCourse(_CourseItem c) {
    if (c.isBuiltIn) return;
    final l10n = AppLocalizations.of(context)!;

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.taxonomyDeleteCourse),
      content: Text(l10n.taxonomyDeleteCourseMessage(c.name)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: () async {
          await ref.read(customTaxonomyDaoProvider).deleteCustomCourse(c.id);
          if (ctx.mounted) Navigator.pop(ctx);
          _loadCourses();
        }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: Text(l10n.actionDelete)),
      ],
    ));
  }

  void _restoreDefaults() async {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.read(settingsProvider);
    final cookbookId = settings.currentCookbookId ?? 'cookbook_default';
    final dao = ref.read(customTaxonomyDaoProvider);
    final custom = await dao.getCustomCourses(cookbookId);

    for (final c in custom) {
      await dao.deleteCustomCourse(c.id);
    }

    _loadCourses();
    if (mounted) {
      AppSnackbar.info(context, l10n.taxonomyDefaultsRestored);
    }
  }
}

class _CourseItem {
  final String id, name, emoji;
  final bool isBuiltIn;
  _CourseItem({required this.id, required this.name, required this.emoji, required this.isBuiltIn});
}