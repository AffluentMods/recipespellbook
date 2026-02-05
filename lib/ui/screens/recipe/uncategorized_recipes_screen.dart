import 'dart:io';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';

class UncategorizedRecipesScreen extends ConsumerWidget {
  const UncategorizedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final cookbookId = settings.currentCookbookId ?? 'starter';
    final recipeDao = ref.watch(recipeDaoProvider);

    // Get query params
    final uri = GoRouterState.of(context).uri;
    final type = uri.queryParameters['type'] ?? 'category'; // 'course' or 'category'
    final isCourse = type == 'course';

    return Scaffold(
      appBar: AppBar(
        title: Text(isCourse ? 'No Course Assigned' : 'Uncategorized'),
      ),
      body: StreamBuilder<List<Recipe>>(
        stream: recipeDao.watchRecipesForCookbook(cookbookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allRecipes = snapshot.data ?? [];

          // Filter to uncategorized based on type
          final uncategorized = allRecipes.where((r) {
            if (isCourse) {
              return r.courseId == null || r.courseId!.isEmpty;
            } else {
              return r.categoryId == null || r.categoryId!.isEmpty;
            }
          }).toList();

          if (uncategorized.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      isCourse ? 'All recipes have a course!' : 'All recipes are categorized!',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Great job organizing your recipes.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: uncategorized.length,
            itemBuilder: (context, index) {
              final recipe = uncategorized[index];
              return _RecipeListTile(recipe: recipe, isCourse: isCourse);
            },
          );
        },
      ),
    );
  }
}

class _RecipeListTile extends StatelessWidget {
  final Recipe recipe;
  final bool isCourse;

  const _RecipeListTile({required this.recipe, required this.isCourse});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = recipe.imagePath != null && File(recipe.imagePath!).existsSync();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasImage
              ? Image.file(File(recipe.imagePath!), fit: BoxFit.cover)
              : Center(
            child: Icon(
              Icons.restaurant_menu,
              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
            ),
          ),
        ),
        title: Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          isCourse
              ? 'Tap to assign a course'
              : 'Tap to assign a category',
          style: TextStyle(color: theme.colorScheme.outline),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/recipe/${recipe.id}'),
      ),
    );
  }
}