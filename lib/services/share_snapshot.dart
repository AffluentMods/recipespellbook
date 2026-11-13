import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

import '../database/daos/tags_dao.dart';
import '../database/database.dart';
import 'community_publish_pipeline.dart';
import 'family_service.dart';
import 'image_service.dart';

// ════════════════════════════════════════════
//  ONE-TIME SHARE LINK SNAPSHOTS
// ════════════════════════════════════════════
//
// A one-time share link (24 hours) carries a frozen copy of a recipe or a
// whole cookbook, so it works for any account, synced or not, and shows
// exactly what was shared. Photos go up through the Community upload (the
// moderation scan and the metadata strip; photos only in the cloud are
// fetched first), a few at a time. A photo that is not up in time is left
// out: a slow connection costs photos, never the link.

/// The copy behind a share link, ready to send with it.
class ShareSnapshot {
  final Map<String, dynamic> data;

  /// Photos it carries.
  final int photos;

  /// Photos left out because they did not go up in time (or at all).
  final int photosLeftOut;

  const ShareSnapshot(this.data, {this.photos = 0, this.photosLeftOut = 0});
}

/// The cookbook is more than one share link can carry.
class ShareSnapshotTooLarge implements Exception {
  const ShareSnapshotTooLarge();
}

class ShareSnapshotBuilder {
  ShareSnapshotBuilder(
    this.db, {
    Future<CommunityUploadOutcome> Function(String localPath)? upload,
    Future<String?> Function(String remotePhoto)? fetchRemotePhoto,
    this.concurrency = 3,
    this.photoDeadline = const Duration(seconds: 25),
  })  : _upload = upload ?? ImageService.instance.communityUploadLocalPath,
        _fetchRemotePhoto = fetchRemotePhoto ?? ImageService.instance.localCopyOfRemotePhoto;

  final AppDatabase db;
  final Future<CommunityUploadOutcome> Function(String) _upload;
  final Future<String?> Function(String) _fetchRemotePhoto;

  /// Photos going up at once.
  final int concurrency;

  /// Photos not up by then are left out of the link.
  final Duration photoDeadline;

  /// The most a snapshot may be (the server's limit, in JSON characters).
  static const maxSnapshotChars = 512 * 1024;

  /// Sub-recipes a recipe link carries along with the recipe.
  static const maxLinkedRecipes = 6;

  /// [recipe] with its sub-recipes (up to [maxLinkedRecipes]), linked by
  /// ingredient.
  Future<ShareSnapshot> recipe(Recipe recipe) async {
    final photos = _Photos();
    final snapshot = await _recipeMap(recipe, photos);

    final dao = db.recipeDao;
    final ingredients = await dao.getIngredientsForRecipe(recipe.id);
    final nameOf = {for (final i in ingredients) i.id: i.name};
    final linkMap = await dao.getIngredientLinksMap(recipe.id);
    final subs = <String, Recipe>{};
    final links = <Map<String, dynamic>>[];
    for (final entry in linkMap.entries) {
      for (final info in entry.value) {
        subs[info.recipe.id] = info.recipe;
        links.add({'ingredientName': nameOf[entry.key], 'title': info.recipe.title, 'subId': info.recipe.id});
      }
    }
    final carried = subs.values.take(maxLinkedRecipes).toList();
    if (carried.isNotEmpty) {
      final ids = carried.map((r) => r.id).toSet();
      snapshot['linkedRecipes'] = [for (final sub in carried) await _recipeMap(sub, photos)];
      snapshot['links'] = links.where((l) => ids.contains(l['subId'])).toList();
    }
    return _withPhotos(snapshot, photos);
  }

  /// Every recipe of [cookbook], each with its links to the others, and the
  /// cover. Throws [ShareSnapshotTooLarge] before any photo goes up when the
  /// cookbook is more than a link can carry.
  Future<ShareSnapshot> cookbook(Cookbook cookbook) async {
    final photos = _Photos();
    final dao = db.recipeDao;
    final recipes = await dao.getRecipesForCookbook(cookbook.id);
    final inCookbook = recipes.map((r) => r.id).toSet();
    final maps = <Map<String, dynamic>>[];
    for (final r in recipes) {
      final map = await _recipeMap(r, photos);
      // Links to other recipes of the cookbook; a shared recipe saved on
      // its own brings those along.
      final ingredients = await dao.getIngredientsForRecipe(r.id);
      final nameOf = {for (final i in ingredients) i.id: i.name};
      final links = [
        for (final entry in (await dao.getIngredientLinksMap(r.id)).entries)
          for (final info in entry.value)
            if (inCookbook.contains(info.recipe.id))
              {'ingredientName': nameOf[entry.key], 'title': info.recipe.title, 'subId': info.recipe.id},
      ];
      if (links.isNotEmpty) map['links'] = links;
      maps.add(map);
    }
    final cover = <String, dynamic>{
      'id': cookbook.id,
      'name': cookbook.name,
      'description': cookbook.description,
      'imagePath': null,
    };
    photos.want(cover, 'imagePath', CommunityPublishPipeline.photoToSend(cookbook.imagePath, cookbook.imageServerPath));
    return _withPhotos({'cookbook': cover, 'recipes': maps}, photos);
  }

  /// One recipe as a share link carries it. Its photos are asked of [photos]
  /// and filled in once they are up.
  Future<Map<String, dynamic>> _recipeMap(Recipe r, _Photos photos) async {
    final dao = db.recipeDao;
    final ingredients = await dao.getIngredientsForRecipe(r.id);
    final steps = await dao.getStepsForRecipe(r.id);
    final tags = await TagsDao(db).getTagsForRecipe(r.id);
    final map = <String, dynamic>{
      'id': r.id,
      'title': r.title,
      'description': r.description,
      'servings': r.servings,
      'prepTimeMinutes': r.prepTimeMinutes,
      'cookTimeMinutes': r.cookTimeMinutes,
      'sourceUrl': r.sourceUrl,
      'imagePath': null,
      'courseId': r.courseId,
      'categoryId': r.categoryId,
      'rating': r.rating,
      'notes': r.notes,
      'nutritionJson': r.nutritionJson,
      'tags': [for (final t in tags) t.name],
      'ingredients': [
        for (final i in ingredients)
          {'sortOrder': i.sortOrder, 'amount': i.amount, 'unit': i.unit, 'name': i.name, 'notes': i.notes},
      ],
      'steps': [
        for (final s in steps)
          {
            'sortOrder': s.sortOrder,
            'instruction': s.instruction,
            'durationMinutes': s.durationMinutes,
            'notes': s.notes,
            'imagePath': null,
          },
      ],
    };
    photos.want(map, 'imagePath', CommunityPublishPipeline.photoToSend(r.imagePath, r.imageServerPath));
    final stepMaps = (map['steps'] as List).cast<Map<String, dynamic>>();
    for (var i = 0; i < steps.length; i++) {
      photos.want(stepMaps[i], 'imagePath', CommunityPublishPipeline.photoToSend(steps[i].imagePath, steps[i].imageServerPath));
    }
    return map;
  }

  /// Checks the size, then puts the photos up and in their places.
  Future<ShareSnapshot> _withPhotos(Map<String, dynamic> data, _Photos photos) async {
    // A photo's server path is about this long once it is in.
    const photoPathChars = 64;
    if (jsonEncode(data).length + photos.slots.length * photoPathChars > maxSnapshotChars) {
      throw const ShareSnapshotTooLarge();
    }
    final uploaded = await _uploadAll(photos.sources);
    var carried = 0;
    for (final slot in photos.slots) {
      final path = uploaded[slot.source];
      slot.map[slot.key] = path;
      if (path != null) carried++;
    }
    return ShareSnapshot(data, photos: carried, photosLeftOut: photos.slots.length - carried);
  }

  /// Each photo of [sources] up through the Community upload, [concurrency]
  /// at a time, until [photoDeadline]. Source to server path for the ones
  /// that went up.
  Future<Map<String, String>> _uploadAll(List<String> sources) async {
    final out = <String, String>{};
    if (sources.isEmpty) return out;
    final deadline = DateTime.now().add(photoDeadline);
    var next = 0;

    Future<void> one(String source) async {
      var file = source;
      if (ImageService.isRemotePhoto(source)) {
        final fetched = await _fetchRemotePhoto(source);
        if (fetched == null) return;
        file = fetched;
      }
      final outcome = await _upload(file);
      final path = outcome.result?.path;
      if (path != null) out[source] = path;
    }

    Future<void> worker() async {
      while (next < sources.length) {
        final left = deadline.difference(DateTime.now());
        if (left <= Duration.zero) return;
        final source = sources[next++];
        try {
          await one(source).timeout(left);
        } on TimeoutException {
          return; // out of time: the rest are left out
        } catch (e) {
          debugPrint('[Share] photo skipped: $e');
        }
      }
    }

    await Future.wait([for (var w = 0; w < concurrency && w < sources.length; w++) worker()]);
    // A photo that finished after its time ran out is not in the link.
    return Map.of(out);
  }
}

/// How making a one-time link to a cookbook went.
class CookbookShareLinkResult {
  final ShareLinkInfo? link;

  /// The cookbook is more than a link can carry (nothing was sent).
  final bool tooLarge;

  /// Photos left out because they did not go up in time.
  final int photosLeftOut;

  const CookbookShareLinkResult({this.link, this.tooLarge = false, this.photosLeftOut = 0});
}

/// A one-time link to [cookbook] carrying a copy of it (its recipes and
/// photos), so it works for anyone, synced or not, and shows the cookbook as
/// it is now rather than as it was last synced.
Future<CookbookShareLinkResult> createCookbookShareLink(
  AppDatabase db,
  Cookbook cookbook, {
  ShareSnapshotBuilder? builder,
  FamilyService? family,
}) async {
  final ShareSnapshot snapshot;
  try {
    snapshot = await (builder ?? ShareSnapshotBuilder(db)).cookbook(cookbook);
  } on ShareSnapshotTooLarge {
    return const CookbookShareLinkResult(tooLarge: true);
  }
  ShareLinkInfo? link;
  try {
    link = await (family ?? FamilyService.instance)
        .createShareLink('cookbook', cookbook.id, snapshot: snapshot.data)
        .timeout(const Duration(seconds: 20));
  } catch (e) {
    debugPrint('[Share] cookbook link failed: $e');
  }
  return CookbookShareLinkResult(link: link, photosLeftOut: snapshot.photosLeftOut);
}

/// The photos of a snapshot: where each goes, and each source once.
class _Photos {
  final slots = <({Map<String, dynamic> map, String key, String source})>[];
  final sources = <String>[];

  void want(Map<String, dynamic> map, String key, String? source) {
    if (source == null || source.isEmpty) return;
    slots.add((map: map, key: key, source: source));
    if (!sources.contains(source)) sources.add(source);
  }
}
