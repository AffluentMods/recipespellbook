import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../data/course_category_data.dart';

/// Screen to manage custom courses
class ManageCoursesScreen extends ConsumerStatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  ConsumerState<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends ConsumerState<ManageCoursesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTaxonomyDao = ref.watch(customTaxonomyDaoProvider);
    final settings = ref.watch(settingsProvider);
    final cookbookId = settings.currentCookbookId ?? 'cookbook_default';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCourseDialog(context, cookbookId),
            tooltip: 'Add Course',
          ),
        ],
      ),
      body: StreamBuilder<List<CustomCourse>>(
        stream: customTaxonomyDao.watchCustomCourses(cookbookId),
        builder: (context, snapshot) {
          final customCourses = snapshot.data ?? [];

          // Get built-in courses
          final builtInCourses = CourseData.courses;

          return ListView(
            children: [
              // Built-in courses section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Built-in Courses',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...builtInCourses.map((course) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(course.emoji),
                ),
                title: Text(course.name),
                subtitle: const Text('Built-in'),
                trailing: const Icon(Icons.lock_outline, size: 18),
              )),

              if (customCourses.isNotEmpty) ...[
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'Custom Courses',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...customCourses.map((course) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Text(course.emoji, style: const TextStyle(fontSize: 18)),
                  ),
                  title: Text(course.name),
                  subtitle: const Text('Custom'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditCourseDialog(context, course),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDeleteCourse(context, course),
                      ),
                    ],
                  ),
                )),
              ],

              const SizedBox(height: 100),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCourseDialog(context, cookbookId),
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
    );
  }

  void _showAddCourseDialog(BuildContext context, String cookbookId) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Course'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Course Name',
            hintText: 'e.g., Brunch, Appetizer',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final dao = ref.read(customTaxonomyDaoProvider);
                final id = 'course_${DateTime.now().millisecondsSinceEpoch}';
                await dao.insertCustomCourse(CustomCoursesCompanion.insert(
                  id: id,
                  cookbookId: cookbookId,
                  name: controller.text.trim(),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(BuildContext context, CustomCourse course) {
    final controller = TextEditingController(text: course.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Course'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Course Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final dao = ref.read(customTaxonomyDaoProvider);
                await dao.updateCustomCourse(
                  course.id,
                  CustomCoursesCompanion(name: drift.Value(controller.text.trim())),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCourse(BuildContext context, CustomCourse course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Course?'),
        content: Text('Are you sure you want to delete "${course.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final dao = ref.read(customTaxonomyDaoProvider);
              await dao.deleteCustomCourse(course.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Screen to manage custom categories
class ManageCategoriesScreen extends ConsumerStatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  ConsumerState<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends ConsumerState<ManageCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTaxonomyDao = ref.watch(customTaxonomyDaoProvider);
    final settings = ref.watch(settingsProvider);
    final cookbookId = settings.currentCookbookId ?? 'cookbook_default';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context, cookbookId),
            tooltip: 'Add Category',
          ),
        ],
      ),
      body: StreamBuilder<List<CustomCategory>>(
        stream: customTaxonomyDao.watchCustomCategories(cookbookId),
        builder: (context, snapshot) {
          final customCategories = snapshot.data ?? [];

          // Get built-in categories
          final builtInCategories = CategoryData.categories;

          return ListView(
            children: [
              // Built-in categories section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Built-in Categories',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...builtInCategories.map((category) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(category.emoji),
                ),
                title: Text(category.name),
                subtitle: const Text('Built-in'),
                trailing: const Icon(Icons.lock_outline, size: 18),
              )),

              if (customCategories.isNotEmpty) ...[
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'Custom Categories',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...customCategories.map((category) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Text(category.emoji, style: const TextStyle(fontSize: 18)),
                  ),
                  title: Text(category.name),
                  subtitle: const Text('Custom'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditCategoryDialog(context, category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDeleteCategory(context, category),
                      ),
                    ],
                  ),
                )),
              ],

              const SizedBox(height: 100),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context, cookbookId),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, String cookbookId) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'e.g., Gluten-Free, Low-Carb',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final dao = ref.read(customTaxonomyDaoProvider);
                final id = 'category_${DateTime.now().millisecondsSinceEpoch}';
                await dao.insertCustomCategory(CustomCategoriesCompanion.insert(
                  id: id,
                  cookbookId: cookbookId,
                  name: controller.text.trim(),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, CustomCategory category) {
    final controller = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Category Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final dao = ref.read(customTaxonomyDaoProvider);
                await dao.updateCustomCategory(
                  category.id,
                  CustomCategoriesCompanion(name: drift.Value(controller.text.trim())),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, CustomCategory category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final dao = ref.read(customTaxonomyDaoProvider);
              await dao.deleteCustomCategory(category.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}