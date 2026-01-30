import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/cookbook_provider.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';

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
  return Recipe(
    id: row.data['id'] as String,
    cookbookId: row.data['cookbook_id'] as String,
    title: row.data['title'] as String,
    description: row.data['description'] as String?,
    servings: row.data['servings'] as String?,
    prepTimeMinutes: row.data['prep_time_minutes'] as int?,
    cookTimeMinutes: row.data['cook_time_minutes'] as int?,
    imagePath: row.data['image_path'] as String?,
    sourceUrl: row.data['source_url'] as String?,
    courseId: row.data['course_id'] as String?,
    categoryId: row.data['category_id'] as String?,
    rating: row.data['rating'] as int?,
    notes: row.data['notes'] as String?,
    isFavorite: (row.data['is_favorite'] as int?) == 1,
    isPinned: (row.data['is_pinned'] as int?) == 1,
    lastViewedAt: row.data['last_viewed_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(row.data['last_viewed_at'] as int)
        : null,
    // FIX: Handle potentially null created_at with fallback to DateTime.now()
    createdAt: row.data['created_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(row.data['created_at'] as int)
        : DateTime.now(),
    updatedAt: row.data['updated_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(row.data['updated_at'] as int)
        : DateTime.now(),
    deletedAt: row.data['deleted_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(row.data['deleted_at'] as int)
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: recipe.imagePath != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(recipe.imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.restaurant,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                )
                    : Icon(Icons.restaurant, color: theme.colorScheme.outline),
              ),
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

  String _formatTime(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours hr';
    return '$hours hr $mins min';
  }
}