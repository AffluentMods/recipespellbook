import 'package:flutter/material.dart' hide Step;
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../database/database.dart';
import '../../providers/database_provider.dart';

/// Shows a sheet to manage linked recipes
void showLinkedRecipesSheet(
    BuildContext context,
    WidgetRef ref,
    String recipeId,
    String recipeTitle,
    ) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => _LinkedRecipesSheet(
        recipeId: recipeId,
        recipeTitle: recipeTitle,
        scrollController: scrollController,
      ),
    ),
  );
}

class _LinkedRecipesSheet extends ConsumerStatefulWidget {
  final String recipeId;
  final String recipeTitle;
  final ScrollController scrollController;

  const _LinkedRecipesSheet({
    required this.recipeId,
    required this.recipeTitle,
    required this.scrollController,
  });

  @override
  ConsumerState<_LinkedRecipesSheet> createState() => _LinkedRecipesSheetState();
}

class _LinkedRecipesSheetState extends ConsumerState<_LinkedRecipesSheet> {
  List<Recipe> _linkedRecipes = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  List<Recipe> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadLinkedRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLinkedRecipes() async {
    final dao = ref.read(recipeDaoProvider);
    final recipe = await dao.getRecipeById(widget.recipeId);
    if (recipe == null) return;

    final linkedIds = _extractLinkedIds(recipe.notes ?? '');
    final linked = <Recipe>[];

    for (final id in linkedIds) {
      final r = await dao.getRecipeById(id);
      if (r != null) linked.add(r);
    }

    setState(() {
      _linkedRecipes = linked;
      _isLoading = false;
    });
  }

  List<String> _extractLinkedIds(String text) {
    final regex = RegExp(r'\[\[([^\]]+)\]\]');
    return regex.allMatches(text).map((m) => m.group(1)!).toList();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final dao = ref.read(recipeDaoProvider);
    final results = await dao.searchRecipes(query);

    final filtered = results.where((r) {
      if (r.id == widget.recipeId) return false;
      if (_linkedRecipes.any((l) => l.id == r.id)) return false;
      return true;
    }).toList();

    setState(() => _searchResults = filtered.take(10).toList());
  }

  Future<void> _linkRecipe(Recipe recipe) async {
    final dao = ref.read(recipeDaoProvider);
    final current = await dao.getRecipeById(widget.recipeId);
    if (current == null) return;

    final newNotes = '${current.notes ?? ''}\n\nLinked: [[${recipe.id}]] ${recipe.title}'.trim();
    await dao.updateRecipeFields(widget.recipeId, RecipesCompanion(notes: drift.Value(newNotes)));

    final otherNotes = '${recipe.notes ?? ''}\n\nLinked: [[${widget.recipeId}]] ${widget.recipeTitle}'.trim();
    await dao.updateRecipeFields(recipe.id, RecipesCompanion(notes: drift.Value(otherNotes)));

    setState(() {
      _linkedRecipes.add(recipe);
      _searchResults.remove(recipe);
      _searchController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Linked "${recipe.title}"')));
    }
  }

  Future<void> _unlinkRecipe(Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unlink Recipe?'),
        content: Text('Remove link to "${recipe.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Unlink')),
        ],
      ),
    );

    if (confirmed != true) return;

    final dao = ref.read(recipeDaoProvider);
    final current = await dao.getRecipeById(widget.recipeId);
    if (current == null) return;

    final newNotes = (current.notes ?? '')
        .replaceAll(RegExp(r'\n*Linked: \[\[' + recipe.id + r'\]\][^\n]*'), '')
        .trim();
    await dao.updateRecipeFields(widget.recipeId, RecipesCompanion(notes: drift.Value(newNotes)));

    final other = await dao.getRecipeById(recipe.id);
    if (other != null) {
      final otherNotes = (other.notes ?? '')
          .replaceAll(RegExp(r'\n*Linked: \[\[' + widget.recipeId + r'\]\][^\n]*'), '')
          .trim();
      await dao.updateRecipeFields(recipe.id, RecipesCompanion(notes: drift.Value(otherNotes)));
    }

    setState(() => _linkedRecipes.removeWhere((r) => r.id == recipe.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
          decoration: BoxDecoration(color: theme.colorScheme.outline.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Icon(Icons.link, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Linked Recipes', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text('Connect related recipes together', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            ])),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search recipes to link...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _search(''); })
                  : null,
            ),
            onChanged: _search,
          ),
        ),
        const SizedBox(height: 8),
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text('Search Results', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
              ),
              ..._searchResults.map((r) => ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: IconButton(icon: const Icon(Icons.add_link), onPressed: () => _linkRecipe(r)),
              )),
            ]),
          ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _linkedRecipes.isEmpty
              ? _EmptyLinkedState()
              : ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _linkedRecipes.length,
            itemBuilder: (context, index) {
              final recipe = _linkedRecipes[index];
              return _LinkedRecipeCard(
                recipe: recipe,
                onTap: () { Navigator.pop(context); context.push('/recipe/${recipe.id}'); },
                onUnlink: () => _unlinkRecipe(recipe),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LinkedRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onUnlink;

  const _LinkedRecipeCard({required this.recipe, required this.onTap, required this.onUnlink});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.restaurant_menu, color: theme.colorScheme.onPrimaryContainer),
        ),
        title: Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: recipe.description != null ? Text(recipe.description!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
        trailing: IconButton(icon: const Icon(Icons.link_off), onPressed: onUnlink, tooltip: 'Unlink'),
      ),
    );
  }
}

class _EmptyLinkedState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.link_off, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('No Linked Recipes', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Link related recipes together!\nGreat for:\n• Side dishes\n• Sauces & marinades\n• Meal components',
              textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
        ]),
      ),
    );
  }
}

class LinkedRecipesSection extends ConsumerWidget {
  final String recipeId;
  final String? notes;

  const LinkedRecipesSection({super.key, required this.recipeId, this.notes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkedIds = _extractLinkedIds(notes ?? '');
    if (linkedIds.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.link, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text('Linked Recipes', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 12),
      ...linkedIds.map((id) => _LinkedRecipePreview(recipeId: id)),
    ]);
  }

  List<String> _extractLinkedIds(String text) {
    final regex = RegExp(r'\[\[([^\]]+)\]\]');
    return regex.allMatches(text).map((m) => m.group(1)!).toList();
  }
}

class _LinkedRecipePreview extends ConsumerWidget {
  final String recipeId;
  const _LinkedRecipePreview({required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return FutureBuilder<Recipe?>(
      future: ref.read(recipeDaoProvider).getRecipeById(recipeId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) return const SizedBox.shrink();
        final recipe = snapshot.data!;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: () => context.push('/recipe/${recipe.id}'),
            leading: Icon(Icons.restaurant_menu, color: theme.colorScheme.primary),
            title: Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}