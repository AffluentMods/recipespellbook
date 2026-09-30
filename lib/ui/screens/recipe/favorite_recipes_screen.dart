import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_controls.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/recipe_cards.dart';

/// Provider for favorite recipes
final favoriteRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final dao = ref.watch(recipeDaoProvider);
  return dao.watchFavoriteRecipes();
});

class FavoriteRecipesScreen extends ConsumerWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(favoriteRecipesProvider);
    final l10n = AppLocalizations.of(context)!;

    if (Responsive.isDesktopLayout(context)) {
      final recipes = recipesAsync.valueOrNull ?? const <Recipe>[];
      return Scaffold(
        backgroundColor: context.appColors.surface,
        appBar: PageHeader(
          title: l10n.favoritesTitle,
          subtitle: recipesAsync.hasValue ? l10n.countRecipes(recipes.length) : null,
        ),
        body: recipesAsync.isLoading && !recipesAsync.hasValue
            ? const Center(child: CircularProgressIndicator())
            : recipes.isEmpty
                ? EmptyState(
                    icon: Icons.favorite_border,
                    title: l10n.favoritesEmpty,
                    message: l10n.favoritesEmptySubtitle,
                  )
                : RecipeCardGrid(
                    storageKey: 'favorites_grid',
                    recipes: recipes,
                    onTap: (r) {
                      ref.read(recipeDaoProvider).updateLastViewed(r.id);
                      context.pushNamed('recipe', pathParameters: {'id': r.id});
                    },
                    onToggleFavorite: (r) =>
                        ref.read(recipeDaoProvider).toggleFavorite(r.id, !r.isFavorite),
                  ),
      );
    }

    final c = context.appColors;
    final wide = Responsive.useNavRail(context);
    final side = wide ? Space.xxl : Space.lg;
    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        backgroundColor: c.surface,
        centerTitle: false,
        titleSpacing: Navigator.of(context).canPop() ? 0 : Space.xl,
        title: TouchPageTitle(l10n.favoritesTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: c.textSecondary),
            tooltip: l10n.searchTitle,
            onPressed: () => context.push('/search'),
          ),
          const SizedBox(width: Space.xs),
        ],
      ),
      body: recipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (recipes) {
          if (recipes.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: l10n.favoritesEmpty,
              message: l10n.favoritesEmptySubtitle,
            );
          }
          return RecipeCardGrid(
            storageKey: 'favorites_grid_touch',
            recipes: recipes,
            physics: const AlwaysScrollableScrollPhysics(),
            maxTileWidth: wide ? 230 : 250,
            gap: wide ? Space.lg : Space.md,
            padding: EdgeInsets.fromLTRB(side, Space.xs, side, 104),
            onTap: (r) {
              ref.read(recipeDaoProvider).updateLastViewed(r.id);
              context.pushNamed('recipe', pathParameters: {'id': r.id});
            },
            onToggleFavorite: (r) {
              final dao = ref.read(recipeDaoProvider);
              dao.toggleFavorite(r.id, false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.favoritesRemoved),
                  action: SnackBarAction(
                    label: l10n.actionUndo,
                    onPressed: () => dao.toggleFavorite(r.id, true),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
