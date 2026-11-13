import 'dart:io' show File;

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import 'community_cookbook_fingerprint.dart';
import 'community_service.dart';
import 'image_service.dart';

// ════════════════════════════════════════════
//  WRITING COMMUNITY RECIPES INTO THE LIBRARY
// ════════════════════════════════════════════
//
// One place that turns Community recipes into local rows, so a download and
// an update of a downloaded cookbook write recipes, ingredients, steps,
// tags, photos and sub-recipe links exactly the same way.

/// The photos of some Community recipes: what to fetch, and where each one
/// ended up. A photo with the same server path is fetched once.
class CommunityPhotoPlan {
  CommunityPhotoPlan._();

  /// Nothing to fetch (a text-only download or update).
  factory CommunityPhotoPlan.none() => CommunityPhotoPlan._();

  /// The cover and step photos of [indexes] in [recipes]. A photo already in
  /// [onDevice] (server path to a local file that still exists) is used as
  /// it is instead of being fetched again. Photos come from the publication
  /// unless [urlFor] says where (a share link's photos); files are named
  /// after [filePrefix], by default `community_<publicationId>`.
  factory CommunityPhotoPlan.forRecipes(
    String publicationId,
    List<CommunityRecipe> recipes,
    Iterable<int> indexes, {
    Map<String, String> onDevice = const {},
    Uuid uuid = const Uuid(),
    String Function(String serverPath)? urlFor,
    String? filePrefix,
  }) {
    final plan = CommunityPhotoPlan._();
    final prefix = filePrefix ?? 'community_$publicationId';
    void want(String key, String? serverPath, String suffix) {
      if (serverPath == null || serverPath.isEmpty) return;
      plan._slot[key] = serverPath;
      if (plan._jobOf.containsKey(serverPath) || plan._reused.containsKey(serverPath)) return;
      final local = onDevice[serverPath];
      if (local != null && _fileExists(local)) {
        plan._reused[serverPath] = local;
        return;
      }
      plan._jobOf[serverPath] = plan.jobs.length;
      plan.jobs.add((
        url: urlFor?.call(serverPath) ?? CommunityService.communityImageUrl(publicationId, serverPath),
        filename: '${prefix}_${uuid.v4()}_$suffix.jpg',
      ));
    }

    for (final i in indexes) {
      if (i < 0 || i >= recipes.length) continue;
      final recipe = recipes[i];
      want('$i', recipe.imagePath, 'cover');
      for (var s = 0; s < recipe.steps.length; s++) {
        want('${i}_$s', recipe.steps[s].imagePath, 'step${recipe.steps[s].sortOrder}');
      }
    }
    return plan;
  }

  /// Downloads to run, in order; hand the results to [complete].
  final jobs = <({String url, String filename})>[];

  final _slot = <String, String>{}; // "i" or "i_s" → server path
  final _jobOf = <String, int>{}; // server path → job
  final _reused = <String, String>{}; // server path → local file
  List<String?> _saved = const [];

  /// The local files [jobs] produced (null where one failed).
  void complete(List<String?> saved) => _saved = saved;

  /// Fetches every job (four at a time, each with a timeout and one retry).
  Future<void> fetch({void Function(int done)? onProgress}) async {
    complete(await ImageService.instance.downloadAndSaveImages(jobs, onProgress: onProgress));
  }

  String? _local(String? serverPath) {
    if (serverPath == null) return null;
    final reused = _reused[serverPath];
    if (reused != null) return reused;
    final job = _jobOf[serverPath];
    return job == null || job >= _saved.length ? null : _saved[job];
  }

  /// The local file for recipe [i]'s photo, or null.
  String? cover(int i) => _local(_slot['$i']);

  /// The local file for step [s] of recipe [i], or null.
  String? step(int i, int s) => _local(_slot['${i}_$s']);

  /// How many photos could not be fetched.
  int get failed => _saved.where((p) => p == null).length;

  /// Server path to local file for every photo of this plan now on the device.
  Map<String, String> get onDevice => {
        ..._reused,
        for (final e in _jobOf.entries)
          if (e.value < _saved.length && _saved[e.value] != null) e.key: _saved[e.value]!,
      };

  static bool _fileExists(String path) {
    if (kIsWeb) return false;
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }
}

/// Writes Community recipes into the local database. Call inside a
/// transaction.
class CommunityRecipeWriter {
  CommunityRecipeWriter(this.db, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  final AppDatabase db;
  final Uuid _uuid;

  /// Adds [recipe] (number [index] of the publication) to [cookbookId] as a
  /// new recipe. Returns its id and its ingredient ids in list order.
  Future<({String id, List<String> ingredientIds})> insert(
    String cookbookId,
    CommunityRecipe recipe,
    int index,
    CommunityPhotoPlan photos,
  ) async {
    final recipeId = 'cr_${_uuid.v4()}';
    await db.into(db.recipes).insert(RecipesCompanion.insert(
          id: recipeId,
          cookbookId: cookbookId,
          title: recipe.title,
          description: drift.Value(recipe.description),
          servings: drift.Value(recipe.servings),
          prepTimeMinutes: drift.Value(recipe.prepTimeMinutes),
          cookTimeMinutes: drift.Value(recipe.cookTimeMinutes),
          sourceUrl: drift.Value(recipe.sourceUrl),
          categoryId: drift.Value(recipe.categoryId),
          courseId: drift.Value(recipe.courseId),
          rating: drift.Value(recipe.rating),
          notes: drift.Value(recipe.notes),
          nutritionJson: drift.Value(recipe.nutritionJson),
          imagePath: drift.Value(photos.cover(index)),
          lastViewedAt: drift.Value(DateTime.now()),
        ));
    final ingredientIds = await _writeBody(recipeId, recipe, index, photos);
    return (id: recipeId, ingredientIds: ingredientIds);
  }

  /// Rewrites the existing local recipe [recipeId] from [recipe]: its text,
  /// photo, ingredients, steps, tags, and drops its own sub-recipe links
  /// (put back with [writeLinks]). Keeps its id, cookbook, rating,
  /// favourite and pin, so meal plans and links to it keep working. A photo
  /// the new version does not change stays as it is on the device.
  Future<List<String>> replace(
    String recipeId,
    CommunityRecipe recipe,
    int index,
    CommunityPhotoPlan photos, {
    required bool keepPhoto,
  }) async {
    await (db.update(db.recipes)..where((r) => r.id.equals(recipeId))).write(RecipesCompanion(
          title: drift.Value(recipe.title),
          description: drift.Value(recipe.description),
          servings: drift.Value(recipe.servings),
          prepTimeMinutes: drift.Value(recipe.prepTimeMinutes),
          cookTimeMinutes: drift.Value(recipe.cookTimeMinutes),
          sourceUrl: drift.Value(recipe.sourceUrl),
          categoryId: drift.Value(recipe.categoryId),
          courseId: drift.Value(recipe.courseId),
          notes: drift.Value(recipe.notes),
          nutritionJson: drift.Value(recipe.nutritionJson),
          imagePath: keepPhoto ? const drift.Value.absent() : drift.Value(photos.cover(index)),
          imageServerPath: keepPhoto ? const drift.Value.absent() : const drift.Value(null),
          updatedAt: drift.Value(DateTime.now()),
        ));
    await (db.delete(db.recipeLinks)..where((l) => l.sourceRecipeId.equals(recipeId))).go();
    await (db.delete(db.recipeTags)..where((t) => t.recipeId.equals(recipeId))).go();
    await (db.delete(db.ingredients)..where((i) => i.recipeId.equals(recipeId))).go();
    await (db.delete(db.steps)..where((s) => s.recipeId.equals(recipeId))).go();
    return _writeBody(recipeId, recipe, index, photos);
  }

  /// Ingredients, steps (with their photos and section headers) and tags.
  Future<List<String>> _writeBody(String recipeId, CommunityRecipe recipe, int index, CommunityPhotoPlan photos) async {
    final ingredientIds = <String>[];
    for (final ing in recipe.ingredients) {
      final ingId = 'ci_${_uuid.v4()}';
      ingredientIds.add(ingId);
      await db.into(db.ingredients).insert(IngredientsCompanion.insert(
            id: ingId,
            recipeId: recipeId,
            sortOrder: ing.sortOrder,
            amount: drift.Value(ing.amount),
            unit: drift.Value(ing.unit),
            name: ing.name,
            notes: drift.Value(ing.notes),
          ));
    }

    // notes too: '__header__' marks a section header
    for (var s = 0; s < recipe.steps.length; s++) {
      final step = recipe.steps[s];
      await db.into(db.steps).insert(StepsCompanion.insert(
            id: 'cs_${_uuid.v4()}',
            recipeId: recipeId,
            sortOrder: step.sortOrder,
            instruction: step.instruction,
            durationMinutes: drift.Value(step.durationMinutes),
            notes: drift.Value(step.notes),
            imagePath: drift.Value(photos.step(index, s)),
          ));
    }

    for (final tag in recipe.tags) {
      final existing = await (db.select(db.tags)..where((t) => t.id.equals(tag))).getSingleOrNull();
      if (existing == null) {
        await db.into(db.tags).insertOnConflictUpdate(TagsCompanion.insert(id: tag, name: tag));
      }
      await db.into(db.recipeTags).insertOnConflictUpdate(RecipeTagsCompanion.insert(recipeId: recipeId, tagId: tag));
    }
    return ingredientIds;
  }

  /// [recipe]'s sub-recipe links (ingredient to recipe), for the local
  /// recipe [sourceRecipeId] whose ingredients are [ingredientIds].
  /// [recipeIdAt] gives the local recipe for a publication index; a link to
  /// a recipe that is not here is left out.
  Future<void> writeLinks(
    CommunityRecipe recipe,
    String sourceRecipeId,
    List<String> ingredientIds,
    String? Function(int index) recipeIdAt,
  ) async {
    for (final link in recipe.recipeLinks) {
      final linkedRecipeId = recipeIdAt(link.linkedRecipeIndex);
      final i = link.ingredientIndex;
      if (linkedRecipeId == null || linkedRecipeId == sourceRecipeId || i < 0 || i >= ingredientIds.length) continue;
      await db.into(db.recipeLinks).insertOnConflictUpdate(RecipeLinksCompanion.insert(
            sourceRecipeId: sourceRecipeId,
            ingredientId: ingredientIds[i],
            linkedRecipeId: linkedRecipeId,
            scale: drift.Value(link.scale),
          ));
    }
  }
}

/// Phase 2 of a Community download: the recipes at [indexes] of [detail]
/// into [cookbookId] (made first, named after the publication, when
/// [newCookbook]), all in one transaction. A whole cookbook downloaded as a
/// new cookbook remembers where it came from ([CommunitySourceManifest]),
/// so later updates by the publisher can reach it; partial downloads and
/// downloads into an existing cookbook do not. Returns the local recipe id
/// for each downloaded index.
Future<Map<int, String>> saveCommunityDownload({
  required AppDatabase db,
  required String publicationId,
  required CommunityDetail detail,
  required List<int> indexes,
  required String cookbookId,
  required bool newCookbook,
  required CommunityPhotoPlan photos,
  required bool withImages,
  String? currentUserId,
  Uuid uuid = const Uuid(),
}) {
  final whole = indexes.toSet().length == detail.recipes.length;
  // Someone downloading their own publication keeps a plain copy: they
  // publish it, they don't take updates to it.
  final ownPublication = currentUserId != null && detail.publisher.id == currentUserId;
  final recordSource = newCookbook && whole && !ownPublication;

  return db.transaction(() async {
    if (newCookbook) {
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
            id: cookbookId,
            name: detail.title,
            description: drift.Value(detail.description),
          ));
    }

    final recipeIdByIndex = await _writeRecipes(db, uuid, cookbookId, detail.recipes, indexes, photos);

    if (recordSource) {
      final keys = communityRecipeKeys(detail.recipes);
      final manifest = CommunitySourceManifest(
        title: detail.title,
        description: detail.description,
        withImages: withImages,
        recipes: {
          for (final i in indexes)
            keys[i]: CommunityManifestRecipe(
              recipeId: recipeIdByIndex[i],
              upstream: communityRecipeFingerprint(detail.recipes[i], keys),
              local: await localRecipeFingerprint(db, recipeIdByIndex[i]!),
            ),
        },
        photos: photos.onDevice,
      );
      await (db.update(db.cookbooks)..where((c) => c.id.equals(cookbookId))).write(CookbooksCompanion(
            communitySourceId: drift.Value(publicationId),
            communitySourceVersion: drift.Value(detail.version),
            communityUpdateVersion: const drift.Value(null),
            communityManifest: drift.Value(manifest.encode()),
          ));
    }
    return recipeIdByIndex;
  });
}

/// Saves the recipes at [indexes] of [recipes] into the existing cookbook
/// [cookbookId], in one transaction, exactly as a download writes them:
/// text, nutrition, notes, source, tags, photos from [photos] and the
/// sub-recipe links between the recipes saved. Every Community save goes
/// through here (one recipe from the feed or its page, a shared recipe).
/// Returns the local recipe id for each index.
Future<Map<int, String>> saveCommunityRecipes({
  required AppDatabase db,
  required List<CommunityRecipe> recipes,
  required Iterable<int> indexes,
  required String cookbookId,
  required CommunityPhotoPlan photos,
  Uuid uuid = const Uuid(),
}) {
  final wanted = [for (final i in indexes.toSet()) if (i >= 0 && i < recipes.length) i]..sort();
  return db.transaction(() => _writeRecipes(db, uuid, cookbookId, recipes, wanted, photos));
}

/// [indexes] with every recipe they use as a sub-recipe, at any depth, so
/// saving them keeps their links whole.
Set<int> withSubRecipes(List<CommunityRecipe> recipes, Iterable<int> indexes) {
  final out = <int>{};
  final queue = [...indexes];
  while (queue.isNotEmpty) {
    final i = queue.removeLast();
    if (i < 0 || i >= recipes.length || !out.add(i)) continue;
    for (final link in recipes[i].recipeLinks) {
      queue.add(link.linkedRecipeIndex);
    }
  }
  return out;
}

/// The recipes at [indexes] into [cookbookId], then their links to one
/// another. Call inside a transaction.
Future<Map<int, String>> _writeRecipes(
  AppDatabase db,
  Uuid uuid,
  String cookbookId,
  List<CommunityRecipe> recipes,
  Iterable<int> indexes,
  CommunityPhotoPlan photos,
) async {
  final writer = CommunityRecipeWriter(db, uuid: uuid);
  final recipeIdByIndex = <int, String>{};
  final ingredientIdsByIndex = <int, List<String>>{};
  for (final i in indexes) {
    final written = await writer.insert(cookbookId, recipes[i], i, photos);
    recipeIdByIndex[i] = written.id;
    ingredientIdsByIndex[i] = written.ingredientIds;
  }

  // Restore recipe links (ingredient→sub-recipe references)
  for (final i in indexes) {
    final sourceRecipeId = recipeIdByIndex[i];
    if (sourceRecipeId == null) continue;
    await writer.writeLinks(recipes[i], sourceRecipeId, ingredientIdsByIndex[i]!, (j) => recipeIdByIndex[j]);
  }
  return recipeIdByIndex;
}
