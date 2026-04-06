import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../../database/database.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/recipe_image.dart';

/// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search results provider
final searchResultsProvider = FutureProvider<List<Recipe>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];

  final cookbookId = ref.watch(selectedCookbookIdProvider) ?? 'starter';
  final db = ref.watch(databaseProvider);

  final searchTerm = '%${query.toLowerCase()}%';

  // Search in title and description using custom query
  final results = await db.customSelect(
    '''
    SELECT * FROM recipes 
    WHERE cookbook_id = ? 
    AND deleted_at IS NULL
    AND (LOWER(title) LIKE ? OR LOWER(description) LIKE ?)
    ORDER BY title
    ''',
    variables: [
      Variable.withString(cookbookId),
      Variable.withString(searchTerm),
      Variable.withString(searchTerm),
    ],
    readsFrom: {db.recipes},
  ).get();

  // Also search ingredients
  final ingredientMatches = await db.customSelect(
    '''
    SELECT DISTINCT r.* FROM recipes r
    INNER JOIN ingredients i ON i.recipe_id = r.id
    WHERE r.cookbook_id = ? 
    AND r.deleted_at IS NULL
    AND LOWER(i.name) LIKE ?
    ''',
    variables: [
      Variable.withString(cookbookId),
      Variable.withString(searchTerm),
    ],
    readsFrom: {db.recipes, db.ingredients},
  ).get();

  // Combine and dedupe
  final allIds = <String>{};
  final recipes = <Recipe>[];

  for (final row in results) {
    final id = row.data['id'] as String;
    if (allIds.add(id)) {
      recipes.add(_rowToRecipe(row));
    }
  }

  for (final row in ingredientMatches) {
    final id = row.data['id'] as String;
    if (allIds.add(id)) {
      recipes.add(_rowToRecipe(row));
    }
  }

  return recipes;
});

Recipe _rowToRecipe(QueryRow row) {
  final data = row.data;
  return Recipe(
    id: data['id'] as String? ?? '',
    cookbookId: data['cookbook_id'] as String? ?? '',
    title: data['title'] as String? ?? '',
    description: data['description'] as String?,
    servings: data['servings'] as String?,
    prepTimeMinutes: data['prep_time_minutes'] as int?,
    cookTimeMinutes: data['cook_time_minutes'] as int?,
    imagePath: data['image_path'] as String?,
    sourceUrl: data['source_url'] as String?,
    courseId: data['course_id'] as String?,
    categoryId: data['category_id'] as String?,
    rating: data['rating'] as int?,
    notes: data['notes'] as String?,
    isFavorite: (data['is_favorite'] as int?) == 1,
    isPinned: (data['is_pinned'] as int?) == 1,
    lastViewedAt: data['last_viewed_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['last_viewed_at'] as int)
        : null,
    createdAt: data['created_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['created_at'] as int)
        : DateTime.now(),
    updatedAt: data['updated_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['updated_at'] as int)
        : DateTime.now(),
    deletedAt: data['deleted_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['deleted_at'] as int)
        : null,
  );
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final resultsAsync = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          style: theme.textTheme.titleMedium,
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: query.isEmpty
          ? _EmptySearchState()
          : resultsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.errorGeneric}: $e')),
        data: (results) => results.isEmpty
            ? _NoResultsState(query: query)
            : _SearchResults(results: results),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            l10n.searchHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  final String query;
  const _NoResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            l10n.searchNoResults,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final List<Recipe> results;
  const _SearchResults({required this.results});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final recipe = results[index];
        return _SearchResultCard(recipe: recipe);
      },
    );
  }
}

class _SearchResultCard extends ConsumerWidget {
  final Recipe recipe;
  const _SearchResultCard({required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasTime = recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null;
    final totalTime = (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          ref.read(recipeDaoProvider).updateLastViewed(recipe.id);
          context.pushNamed('recipe', pathParameters: {'id': recipe.id});
        },
        onLongPress: () => _showRecipeActions(context, ref, recipe),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _SearchResultImage(recipe: recipe, size: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (recipe.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        recipe.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (hasTime) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 14, color: theme.colorScheme.outline),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(totalTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (recipe.isFavorite)
                const Icon(Icons.star, color: Colors.amber, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecipeActions(BuildContext context, WidgetRef ref, Recipe recipe) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            )),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                recipe.title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ListTile(
              leading: Icon(recipe.isFavorite ? Icons.star_outline : Icons.star, color: Colors.amber),
              title: Text(recipe.isFavorite ? l10n.recipeUnfavorite : l10n.recipeFavorite),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(recipeDaoProvider).updateRecipeFields(
                  recipe.id,
                  RecipesCompanion(isFavorite: Value(!recipe.isFavorite)),
                );
                ref.invalidate(searchResultsProvider);
                if (context.mounted) {
                  AppSnackbar.success(context, recipe.isFavorite ? l10n.favoritesRemoved : l10n.recipeFavorite);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(l10n.copyToCookbook),
              onTap: () {
                Navigator.pop(ctx);
                _showCookbookPicker(context, ref, recipe, move: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move_outlined),
              title: Text(l10n.moveToCookbook),
              onTap: () {
                Navigator.pop(ctx);
                _showCookbookPicker(context, ref, recipe, move: true);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              title: Text(l10n.deleteRecipeTitle, style: TextStyle(color: theme.colorScheme.error)),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(recipeDaoProvider).softDeleteRecipe(recipe.id);
                ref.invalidate(searchResultsProvider);
                if (context.mounted) {
                  AppSnackbar.info(context, l10n.recipeDeleted);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showCookbookPicker(BuildContext context, WidgetRef ref, Recipe recipe, {required bool move}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cookbooks = ref.read(cookbooksProvider);

    cookbooks.whenData((list) {
      final others = list.where((c) => c.id != recipe.cookbookId).toList();

      Responsive.showAdaptiveSheet(
        context,
        builder: (ctx) {
          final newNameCtrl = TextEditingController();

          createAndAction(String name) async {
            final dao = ref.read(cookbookDaoProvider);
            final newId = 'cb_${DateTime.now().millisecondsSinceEpoch}';
            await dao.insertCookbook(CookbooksCompanion.insert(id: newId, name: name));
            ref.invalidate(cookbooksProvider);
            final cb = Cookbook(id: newId, name: name, createdAt: DateTime.now());
            if (context.mounted) {
              Navigator.pop(ctx);
              await _performCookbookAction(context, ref, recipe, cb, move: move);
            }
          }

          return StatefulBuilder(
            builder: (ctx, setSheetState) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(width: 40, height: 4, decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  )),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(move ? l10n.moveToCookbook : l10n.copyToCookbook, style: theme.textTheme.titleMedium),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: newNameCtrl,
                            decoration: InputDecoration(
                              hintText: l10n.newCookbook,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (val) { if (val.trim().isNotEmpty) createAndAction(val.trim()); },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          icon: const Icon(Icons.add),
                          onPressed: () { final n = newNameCtrl.text.trim(); if (n.isNotEmpty) createAndAction(n); },
                        ),
                      ],
                    ),
                  ),
                  if (others.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    ...others.map((cookbook) => ListTile(
                      leading: const Icon(Icons.book_outlined),
                      title: Text(cookbook.name),
                      onTap: () async {
                        Navigator.pop(ctx);
                        await _performCookbookAction(context, ref, recipe, cookbook, move: move);
                      },
                    )),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Future<void> _performCookbookAction(BuildContext context, WidgetRef ref, Recipe recipe, Cookbook target, {required bool move}) async {
    final l10n = AppLocalizations.of(context)!;
    final recipeDao = ref.read(recipeDaoProvider);
    try {
      if (move) {
        await recipeDao.updateRecipeFields(recipe.id, RecipesCompanion(cookbookId: Value(target.id)));
        ref.invalidate(searchResultsProvider);
        if (context.mounted) AppSnackbar.success(context, '${l10n.moveToCookbook}: "${target.name}"');
      } else {
        await recipeDao.duplicateRecipe(recipe.id, targetCookbookId: target.id);
        if (context.mounted) AppSnackbar.success(context, '${l10n.copyToCookbook}: "${target.name}"');
      }
    } catch (e) {
      if (context.mounted) AppSnackbar.error(context, '${l10n.errorGeneric}: $e');
    }
  }

  String _formatTime(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours hr';
    return '$hours hr $mins min';
  }
}

class _SearchResultImage extends StatelessWidget {
  final Recipe recipe;
  final double size;

  const _SearchResultImage({required this.recipe, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: RecipeImage.thumbnail(
        imagePath: recipe.imagePath,
        recipeId: recipe.id,
        width: size,
        height: size,
      ),
    );
  }
}