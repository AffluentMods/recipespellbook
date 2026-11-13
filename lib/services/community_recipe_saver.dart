import '../database/database.dart';
import 'community_cookbook_writer.dart';
import 'community_service.dart';

// ════════════════════════════════════════════
//  SAVING ONE COMMUNITY RECIPE
// ════════════════════════════════════════════
//
// The feed only carries a preview of each recipe (no nutrition, notes,
// source, photos of the steps, sub-recipes). Saving one fetches the whole
// publication and writes the recipe the way a cookbook download does.

/// How saving one Community recipe went.
class CommunityRecipeSaveResult {
  /// The local id of the saved recipe, or null when nothing was saved.
  final String? recipeId;

  /// Sub-recipes it uses that came along with it.
  final int subRecipes;

  /// Photos that could not be fetched (the recipe was saved without them).
  final int failedPhotos;

  /// The recipe is no longer in the publication (or the publication is
  /// gone), as opposed to the publication not loading at all.
  final bool notFound;

  const CommunityRecipeSaveResult._({this.recipeId, this.subRecipes = 0, this.failedPhotos = 0, this.notFound = false});

  bool get saved => recipeId != null;
}

class CommunityRecipeSaver {
  CommunityRecipeSaver(
    this.db, {
    CommunityService? service,
    Future<void> Function(CommunityPhotoPlan photos)? fetchPhotos,
  })  : _service = service ?? CommunityService.instance,
        _fetchPhotos = fetchPhotos ?? ((photos) => photos.fetch());

  final AppDatabase db;
  final CommunityService _service;
  final Future<void> Function(CommunityPhotoPlan) _fetchPhotos;

  /// Saves the recipe [recipeId] (or, without an id, the first one titled
  /// [title]) of publication [publicationId] into [cookbookId], with its
  /// photos, tags, nutrition, notes, source and the sub-recipes it uses,
  /// linked as in the publication.
  Future<CommunityRecipeSaveResult> save({
    required String publicationId,
    String? recipeId,
    String? title,
    required String cookbookId,
  }) async {
    final fetched = await _service.fetchPublication(publicationId);
    final detail = fetched.detail;
    if (detail == null) return CommunityRecipeSaveResult._(notFound: fetched.notFound);

    final index = indexOfCommunityRecipe(detail.recipes, recipeId: recipeId, title: title);
    if (index == null) return const CommunityRecipeSaveResult._(notFound: true);

    final indexes = withSubRecipes(detail.recipes, [index]);
    final photos = CommunityPhotoPlan.forRecipes(publicationId, detail.recipes, indexes);
    if (photos.jobs.isNotEmpty) await _fetchPhotos(photos);

    final saved = await saveCommunityRecipes(
      db: db,
      recipes: detail.recipes,
      indexes: indexes,
      cookbookId: cookbookId,
      photos: photos,
    );

    final serverId = detail.recipes[index].id;
    if (serverId != null) {
      // Counts the download (it never throws); it does not hold up the save.
      _service.trackRecipeDownload(serverId);
    }
    return CommunityRecipeSaveResult._(
      recipeId: saved[index],
      subRecipes: indexes.length - 1,
      failedPhotos: photos.failed,
    );
  }
}

/// The index of the recipe [recipeId] in [recipes], else of the first one
/// titled [title] (case and spacing aside). Null when neither is there.
int? indexOfCommunityRecipe(List<CommunityRecipe> recipes, {String? recipeId, String? title}) {
  if (recipeId != null) {
    final i = recipes.indexWhere((r) => r.id == recipeId);
    if (i >= 0) return i;
  }
  final wanted = title?.trim().toLowerCase();
  if (wanted == null || wanted.isEmpty) return null;
  final i = recipes.indexWhere((r) => r.title.trim().toLowerCase() == wanted);
  return i >= 0 ? i : null;
}

/// A shared recipe (the snapshot behind a one-time share link) as Community
/// recipes, so it saves through the same writer: the recipe first, then the
/// sub-recipes that travel with it, its ingredients linked to them.
List<CommunityRecipe> sharedRecipeAsCommunity(Map<String, dynamic> snapshot) {
  Map<String, dynamic> asMap(Object? v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
  final main = CommunityRecipe.fromJson(asMap(snapshot));
  final linkedMaps = [for (final raw in (snapshot['linkedRecipes'] as List?) ?? const []) asMap(raw)];
  final linked = [for (final m in linkedMaps) CommunityRecipe.fromJson(m)];

  // Links name the ingredient and the sub-recipe's id in the snapshot.
  final indexOfSub = <String, int>{
    for (var i = 0; i < linkedMaps.length; i++)
      if (linkedMaps[i]['id'] is String) linkedMaps[i]['id'] as String: i + 1,
  };
  final links = <CommunityRecipeLink>[];
  for (final raw in (snapshot['links'] as List?) ?? const []) {
    final link = asMap(raw);
    final name = (link['ingredientName'] as String?)?.trim().toLowerCase();
    final sub = indexOfSub[link['subId']];
    if (name == null || name.isEmpty || sub == null) continue;
    final ingredient = main.ingredients.indexWhere((i) => i.name.trim().toLowerCase() == name);
    if (ingredient < 0) continue;
    links.add(CommunityRecipeLink(ingredientIndex: ingredient, linkedRecipeIndex: sub));
  }

  return [
    CommunityRecipe(
      id: main.id,
      title: main.title,
      description: main.description,
      servings: main.servings,
      prepTimeMinutes: main.prepTimeMinutes,
      cookTimeMinutes: main.cookTimeMinutes,
      sourceUrl: main.sourceUrl,
      imagePath: main.imagePath,
      categoryId: main.categoryId,
      courseId: main.courseId,
      rating: main.rating,
      notes: main.notes,
      nutritionJson: main.nutritionJson,
      ingredients: main.ingredients,
      steps: main.steps,
      tags: main.tags,
      recipeLinks: [...main.recipeLinks, ...links],
    ),
    ...linked,
  ];
}
