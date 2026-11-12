import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database.dart';
import 'auth_service.dart';
import 'community_cookbook_fingerprint.dart';
import 'community_cookbook_writer.dart';
import 'community_service.dart';

// ════════════════════════════════════════════
//  UPDATES TO DOWNLOADED COMMUNITY COOKBOOKS
// ════════════════════════════════════════════
//
// A cookbook downloaded whole from the Community remembers its publication
// and the version it is based on. The check asks the server, in one request
// for all of them, which publications moved on; for those it looks at the
// new version and works out what changed against this device's copy. Only
// a real change shows "Update available". Applying an update keeps the
// user's own edits unless they choose otherwise, adds new recipes, and only
// moves recipes the publisher took out to the trash when the user says so.

/// A recipe that is new in the publisher's version.
class CookbookUpdateAdded {
  final int index;
  final String key;
  final String title;
  const CookbookUpdateAdded(this.index, this.key, this.title);
}

/// A recipe the publisher changed that is still in the user's cookbook.
class CookbookUpdateChanged {
  final int index;
  final String key;
  final String title;
  final String recipeId;

  /// The user's copy differs from what was downloaded (or that can't be
  /// told): the user picks "keep mine" (the default) or the new version.
  final bool editedLocally;

  const CookbookUpdateChanged(this.index, this.key, this.title, this.recipeId, {required this.editedLocally});
}

/// A recipe the publisher took out that is still in the user's cookbook.
class CookbookUpdateRemoved {
  final String key;
  final String title;
  final String recipeId;
  const CookbookUpdateRemoved(this.key, this.title, this.recipeId);
}

/// What an update of one downloaded cookbook would do.
class CookbookUpdatePlan {
  final String cookbookId;
  final String publicationId;

  /// The version the update brings the cookbook to.
  final int? version;
  final CommunityDetail detail;
  final List<String> keys;

  /// What the cookbook was made from; null for a download from before
  /// sources were recorded.
  final CommunitySourceManifest? manifest;

  /// Publication recipes already in the cookbook: key to local recipe.
  final Map<String, String> present;

  /// Manifest entries that stay as they are (or, for an old download, are
  /// learned now): recipes that did not change and ones the user removed.
  final Map<String, CommunityManifestRecipe> baseline;

  final List<CookbookUpdateAdded> added;
  final List<CookbookUpdateChanged> changed;
  final List<CookbookUpdateRemoved> removed;

  /// The publisher's new title, when the user kept the old one.
  final String? newName;

  /// The publisher's description changed and the user kept the old one.
  final bool descriptionChanged;

  const CookbookUpdatePlan({
    required this.cookbookId,
    required this.publicationId,
    required this.version,
    required this.detail,
    required this.keys,
    required this.manifest,
    required this.present,
    required this.baseline,
    required this.added,
    required this.changed,
    required this.removed,
    required this.newName,
    required this.descriptionChanged,
  });

  bool get hasChanges =>
      added.isNotEmpty || changed.isNotEmpty || removed.isNotEmpty || newName != null || descriptionChanged;

  bool get withImages => manifest?.withImages ?? true;
}

/// How an update went.
class CookbookUpdateResult {
  final int added;
  final int updated;
  final int removed;
  final int failedPhotos;
  const CookbookUpdateResult({this.added = 0, this.updated = 0, this.removed = 0, this.failedPhotos = 0});
}

class CommunityCookbookUpdates {
  CommunityCookbookUpdates(
    this.db, {
    CommunityService? service,
    DateTime Function()? clock,
    Future<void> Function(CommunityPhotoPlan photos, void Function(int done)? onProgress)? fetchPhotos,
  })  : _service = service ?? CommunityService.instance,
        _clock = clock ?? DateTime.now,
        _fetchPhotos = fetchPhotos ?? ((photos, onProgress) => photos.fetch(onProgress: onProgress));

  final AppDatabase db;
  final CommunityService _service;
  final DateTime Function() _clock;
  final Future<void> Function(CommunityPhotoPlan, void Function(int)?) _fetchPhotos;

  /// The automatic check (app start) runs at most this often.
  static const checkEvery = Duration(days: 1);

  /// Pull to refresh checks again, but not more often than this.
  static const minForcedGap = Duration(seconds: 30);

  /// At most this many publications are looked at in full per check
  /// (one GET each); the rest wait for the next check. The API allows
  /// 1,000 requests per 15 minutes per address.
  static const maxDetailsPerCheck = 20;

  static const lastCheckKey = 'communityCookbookUpdatesCheckedAt';

  static Future<int?>? _running;

  @visibleForTesting
  static void debugReset() => _running = null;

  // ────────────────────────────────────
  //  Checking
  // ────────────────────────────────────

  /// Looks for updates to every downloaded Community cookbook and marks the
  /// ones with a real change. Runs at most once a day unless [force] (pull
  /// to refresh), and never twice at once. Returns how many cookbooks have
  /// an update waiting, or null when it did not run (too soon, offline, or a
  /// server without update checks yet; the cookbooks are left as they are).
  Future<int?> checkAll({bool force = false}) {
    return _running ??= _check(force).whenComplete(() => _running = null);
  }

  Future<int?> _check(bool force) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = _clock();
      final last = prefs.getInt(lastCheckKey);
      if (last != null) {
        final since = now.difference(DateTime.fromMillisecondsSinceEpoch(last));
        if (since < (force ? minForcedGap : checkEvery) && !since.isNegative) return null;
      }

      final candidates = await _candidates();
      if (candidates.isEmpty) {
        await prefs.setInt(lastCheckKey, now.millisecondsSinceEpoch);
        return 0;
      }

      final versions = await _service.getVersions([for (final c in candidates) c.communitySourceId!]);
      if (versions == null) return null;

      final me = AuthService.instance.currentUser?.id;
      var looked = 0;
      var deferred = false;
      for (final cookbook in candidates) {
        final v = versions[cookbook.communitySourceId];
        // Gone, unpublished or under review: the copy stays as it is.
        if (v == null) continue;
        // The user's own publication: they publish it, it is not updated.
        if (me != null && v.publisherId == me) continue;

        final base = cookbook.communitySourceVersion;
        if (base != null && v.version <= base) {
          if (cookbook.communityUpdateVersion != null) {
            await _setUpdateVersion(cookbook, null);
          }
          continue;
        }
        final waiting = cookbook.communityUpdateVersion;
        if (waiting != null && waiting >= v.version) continue;

        if (looked >= maxDetailsPerCheck) {
          deferred = true;
          continue;
        }
        looked++;
        final detail = await _service.getPublication(cookbook.communitySourceId!);
        if (detail == null) continue;
        final plan = await buildPlan(cookbook, detail, version: detail.version ?? v.version);
        if (plan.hasChanges) {
          await _setUpdateVersion(cookbook, plan.version ?? v.version);
        } else {
          await _adopt(plan, cookbook);
        }
      }
      // A check cut short by the per-check limit carries on next time.
      if (!deferred) await prefs.setInt(lastCheckKey, now.millisecondsSinceEpoch);

      final waitingNow = await (db.select(db.cookbooks)
            ..where((c) => c.communityUpdateVersion.isNotNull() & c.deletedAt.isNull()))
          .get();
      return waitingNow.length;
    } catch (e) {
      debugPrint('[CommunityUpdates] check failed: $e');
      return null;
    }
  }

  /// Marks or clears "Update available", unless the cookbook moved to
  /// another version meanwhile (an update was applied while checking).
  Future<void> _setUpdateVersion(Cookbook cookbook, int? version) async {
    final base = cookbook.communitySourceVersion;
    await (db.update(db.cookbooks)
          ..where((c) =>
              c.id.equals(cookbook.id) &
              (base == null ? c.communitySourceVersion.isNull() : c.communitySourceVersion.equals(base))))
        .write(CookbooksCompanion(communityUpdateVersion: Value(version)));
  }

  /// Downloaded cookbooks to check. A cookbook downloaded before sources
  /// were recorded is recognised by its photos, whose file names carry the
  /// publication id; one without photos can't be told and is left alone.
  /// Cookbooks this device published from are never included.
  Future<List<Cookbook>> _candidates() async {
    final published = await CommunityService.publishSourceCookbookIds();
    final cookbooks = await (db.select(db.cookbooks)
          ..where((c) => c.deletedAt.isNull() & c.sharedOwnerId.isNull()))
        .get();
    final out = <Cookbook>[];
    for (final c in cookbooks) {
      if (published.contains(c.id)) continue;
      if (c.communitySourceId != null) {
        out.add(c);
        continue;
      }
      if (!c.id.startsWith('community_')) continue;
      final publicationId = await legacyPublicationOf(c.id);
      if (publicationId == null) continue;
      await (db.update(db.cookbooks)..where((t) => t.id.equals(c.id)))
          .write(CookbooksCompanion(communitySourceId: Value(publicationId)));
      out.add(c.copyWith(communitySourceId: Value(publicationId)));
    }
    return out;
  }

  static final _photoName = RegExp(r'community_([A-Za-z0-9]{6,64})_[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-');

  /// The publication an old download came from, read off its photo file
  /// names (`community_PUBLICATION_UUID_cover.jpg`). Null when it has none,
  /// or photos from more than one publication.
  @visibleForTesting
  Future<String?> legacyPublicationOf(String cookbookId) async {
    final rows = await db.customSelect(
      'SELECT image_path AS p FROM recipes WHERE cookbook_id = ?1 AND image_path IS NOT NULL '
      'UNION ALL '
      'SELECT s.image_path AS p FROM steps s JOIN recipes r ON r.id = s.recipe_id '
      'WHERE r.cookbook_id = ?1 AND s.image_path IS NOT NULL',
      variables: [Variable.withString(cookbookId)],
      readsFrom: {db.recipes, db.steps},
    ).get();
    final ids = <String>{};
    for (final row in rows) {
      final path = row.read<String>('p');
      final name = path.substring(path.lastIndexOf(RegExp(r'[/\\]')) + 1);
      final m = _photoName.firstMatch(name);
      if (m != null && name.startsWith('community_')) ids.add(m.group(1)!);
    }
    return ids.length == 1 ? ids.first : null;
  }

  // ────────────────────────────────────
  //  Working out what changed
  // ────────────────────────────────────

  /// Fetches the publication behind [cookbookId] and works out the update.
  /// Null when the cookbook has no source, is one this device published
  /// from, or the publication can't be fetched.
  Future<CookbookUpdatePlan?> planFor(String cookbookId) async {
    final cookbook = await (db.select(db.cookbooks)..where((c) => c.id.equals(cookbookId))).getSingleOrNull();
    final publicationId = cookbook?.communitySourceId;
    if (cookbook == null || publicationId == null) return null;
    if ((await CommunityService.publishSourceCookbookIds()).contains(cookbookId)) return null;
    final detail = await _service.getPublication(publicationId);
    if (detail == null) return null;
    final me = AuthService.instance.currentUser?.id;
    if (me != null && detail.publisher.id == me) return null;
    return buildPlan(cookbook, detail, version: detail.version ?? cookbook.communityUpdateVersion);
  }

  /// Compares [detail] (the publisher's current version) with [cookbook].
  Future<CookbookUpdatePlan> buildPlan(Cookbook cookbook, CommunityDetail detail, {int? version}) async {
    final keys = communityRecipeKeys(detail.recipes);
    final manifest = CommunitySourceManifest.decode(cookbook.communityManifest);
    final local = await (db.select(db.recipes)
          ..where((r) => r.cookbookId.equals(cookbook.id))
          ..orderBy([(r) => OrderingTerm.asc(r.rowId)]))
        .get();
    final byId = {for (final r in local) r.id: r};
    bool alive(String? id) => id != null && byId[id]?.deletedAt == null && byId.containsKey(id);

    final present = <String, String>{};
    final baseline = <String, CommunityManifestRecipe>{};
    final added = <CookbookUpdateAdded>[];
    final changed = <CookbookUpdateChanged>[];
    final removed = <CookbookUpdateRemoved>[];

    if (manifest != null) {
      for (var i = 0; i < keys.length; i++) {
        final key = keys[i];
        final recipe = detail.recipes[i];
        final entry = manifest.recipes[key];
        if (entry == null) {
          added.add(CookbookUpdateAdded(i, key, recipe.title));
          continue;
        }
        // Deleted, moved to another cookbook, or never taken: leave it out.
        if (!alive(entry.recipeId)) {
          baseline[key] = entry;
          continue;
        }
        present[key] = entry.recipeId!;
        if (entry.upstream == communityRecipeFingerprint(recipe, keys)) {
          baseline[key] = entry;
          continue;
        }
        final now = await localRecipeFingerprint(db, entry.recipeId!);
        changed.add(CookbookUpdateChanged(i, key, recipe.title, entry.recipeId!,
            editedLocally: entry.local == null || now != entry.local));
      }
      final upstreamKeys = keys.toSet();
      for (final e in manifest.recipes.entries) {
        if (upstreamKeys.contains(e.key) || !alive(e.value.recipeId)) continue;
        removed.add(CookbookUpdateRemoved(e.key, byId[e.value.recipeId]!.title, e.value.recipeId!));
      }
    } else {
      // A download from before sources were recorded: there is no record of
      // what it took, so the first check offers nothing. It notes what the
      // cookbook has as the starting point and real changes after that are
      // offered as for any download. A recipe it lacks was left out, deleted
      // or renamed by the user, not added by the publisher; a copy that
      // differs may be the user's own edit, so it counts as edited
      // ("keep mine" unless they choose) when it changes later.
      final unmatched = [...local]..sort((a, b) => (a.deletedAt == null ? 0 : 1) - (b.deletedAt == null ? 0 : 1));
      for (var i = 0; i < keys.length; i++) {
        final key = keys[i];
        final recipe = detail.recipes[i];
        final upstream = communityRecipeFingerprint(recipe, keys);
        final title = recipe.title.trim().toLowerCase();
        final match = unmatched.where((r) => r.title.trim().toLowerCase() == title).firstOrNull;
        if (match == null) {
          baseline[key] = CommunityManifestRecipe(recipeId: null, upstream: upstream, local: null);
          continue;
        }
        unmatched.remove(match);
        if (match.deletedAt != null) {
          baseline[key] = CommunityManifestRecipe(recipeId: match.id, upstream: upstream, local: null);
          continue;
        }
        present[key] = match.id;
        final same = await comparableLocalFingerprint(db, match.id) == comparableFingerprint(recipe);
        baseline[key] = CommunityManifestRecipe(
          recipeId: match.id,
          upstream: upstream,
          local: same ? await localRecipeFingerprint(db, match.id) : null,
        );
      }
    }

    String? newName;
    var descriptionChanged = false;
    if (manifest != null) {
      String t(String? s) => (s ?? '').trim();
      if (t(detail.title).isNotEmpty && t(detail.title) != t(manifest.title) && t(cookbook.name) == t(manifest.title)) {
        newName = detail.title.trim();
      }
      descriptionChanged = t(detail.description) != t(manifest.description) &&
          t(cookbook.description) == t(manifest.description);
    }

    return CookbookUpdatePlan(
      cookbookId: cookbook.id,
      publicationId: cookbook.communitySourceId ?? detail.id,
      version: version,
      detail: detail,
      keys: keys,
      manifest: manifest,
      present: present,
      baseline: baseline,
      added: added,
      changed: changed,
      removed: removed,
      newName: newName,
      descriptionChanged: descriptionChanged,
    );
  }

  /// Nothing to bring in: the cookbook simply moves to the new version.
  Future<void> _adopt(CookbookUpdatePlan plan, Cookbook cookbook) async {
    final manifest = CommunitySourceManifest(
      title: plan.detail.title,
      description: plan.detail.description,
      withImages: plan.withImages,
      recipes: plan.baseline,
      photos: plan.manifest?.photos ?? const {},
    );
    final base = cookbook.communitySourceVersion;
    await (db.update(db.cookbooks)
          ..where((c) =>
              c.id.equals(cookbook.id) &
              (base == null ? c.communitySourceVersion.isNull() : c.communitySourceVersion.equals(base))))
        .write(CookbooksCompanion(
      communitySourceVersion: Value(plan.version),
      communityUpdateVersion: const Value(null),
      communityManifest: Value(manifest.encode()),
    ));
  }

  // ────────────────────────────────────
  //  Applying
  // ────────────────────────────────────

  /// Applies [plan]. New recipes go in (except [skipAdded]); changed ones the
  /// user did not edit take the new version, edited ones only when listed in
  /// [useNew]; recipes the publisher took out move to the trash only when
  /// listed in [remove]. Photos and sub-recipe links come along as in a
  /// download. With [skipAll] nothing in the cookbook changes, but this
  /// version's changes are not offered again. Nothing outside the cookbook
  /// is touched. Null when the cookbook is gone.
  Future<CookbookUpdateResult?> apply(
    CookbookUpdatePlan plan, {
    Set<String> useNew = const {},
    Set<String> remove = const {},
    Set<String> skipAdded = const {},
    bool skipAll = false,
    void Function(int done, int total)? onPhotoProgress,
  }) async {
    final recipes = plan.detail.recipes;
    final toInsert = skipAll ? <int>[] : [for (final a in plan.added) if (!skipAdded.contains(a.key)) a.index];
    final toReplace = skipAll
        ? <CookbookUpdateChanged>[]
        : [for (final c in plan.changed) if (!c.editedLocally || useNew.contains(c.key)) c];
    final toRemove = skipAll ? <CookbookUpdateRemoved>[] : [for (final r in plan.removed) if (remove.contains(r.key)) r];

    final photos = plan.withImages && (toInsert.isNotEmpty || toReplace.isNotEmpty)
        ? CommunityPhotoPlan.forRecipes(
            plan.publicationId,
            recipes,
            [...toInsert, for (final c in toReplace) c.index],
            onDevice: plan.manifest?.photos ?? const {},
          )
        : CommunityPhotoPlan.none();
    if (photos.jobs.isNotEmpty) {
      onPhotoProgress?.call(0, photos.jobs.length);
      await _fetchPhotos(photos, (done) => onPhotoProgress?.call(done, photos.jobs.length));
    }

    final writer = CommunityRecipeWriter(db);
    return db.transaction(() async {
      final cookbook = await (db.select(db.cookbooks)..where((c) => c.id.equals(plan.cookbookId))).getSingleOrNull();
      if (cookbook == null || cookbook.deletedAt != null) return null;

      final indexOf = {for (var i = 0; i < plan.keys.length; i++) plan.keys[i]: i};
      final recipeIdAt = <int, String>{
        for (final e in plan.present.entries)
          if (indexOf[e.key] != null) indexOf[e.key]!: e.value,
      };
      final ingredientIds = <int, List<String>>{};
      final written = <int>{};

      for (final i in toInsert) {
        final w = await writer.insert(plan.cookbookId, recipes[i], i, photos);
        recipeIdAt[i] = w.id;
        ingredientIds[i] = w.ingredientIds;
        written.add(i);
      }
      var updated = 0;
      for (final c in toReplace) {
        final current = await (db.select(db.recipes)..where((r) => r.id.equals(c.recipeId))).getSingleOrNull();
        if (current == null || current.deletedAt != null || current.cookbookId != plan.cookbookId) continue;
        final recipe = recipes[c.index];
        final newCover = photos.cover(c.index);
        final hasCover = recipe.imagePath != null && recipe.imagePath!.isNotEmpty;
        // Text-only copies keep whatever photo they have; a new photo that
        // failed to download leaves the old one in place.
        final keepPhoto = !plan.withImages || newCover == current.imagePath || (hasCover && newCover == null);
        ingredientIds[c.index] = await writer.replace(c.recipeId, recipe, c.index, photos, keepPhoto: keepPhoto);
        written.add(c.index);
        updated++;
      }
      for (final i in written) {
        await writer.writeLinks(recipes[i], recipeIdAt[i]!, ingredientIds[i]!, (j) => recipeIdAt[j]);
      }

      var removedCount = 0;
      for (final r in toRemove) {
        final count = await (db.update(db.recipes)
              ..where((t) => t.id.equals(r.recipeId) & t.cookbookId.equals(plan.cookbookId) & t.deletedAt.isNull()))
            .write(RecipesCompanion(deletedAt: Value(DateTime.now()), updatedAt: Value(DateTime.now())));
        removedCount += count;
      }

      // What the cookbook is now made from.
      final old = plan.manifest?.recipes ?? const <String, CommunityManifestRecipe>{};
      final changedByKey = {for (final c in plan.changed) c.key: c};
      final manifestRecipes = <String, CommunityManifestRecipe>{};
      for (var i = 0; i < plan.keys.length; i++) {
        final key = plan.keys[i];
        final upstream = communityRecipeFingerprint(recipes[i], plan.keys);
        if (written.contains(i)) {
          manifestRecipes[key] = CommunityManifestRecipe(
            recipeId: recipeIdAt[i],
            upstream: upstream,
            local: await localRecipeFingerprint(db, recipeIdAt[i]!),
          );
        } else if (changedByKey.containsKey(key)) {
          // Kept their own version: this version is not offered again, and
          // it still counts as edited next time.
          manifestRecipes[key] = CommunityManifestRecipe(
            recipeId: changedByKey[key]!.recipeId,
            upstream: upstream,
            local: old[key]?.local,
          );
        } else if (plan.baseline.containsKey(key)) {
          manifestRecipes[key] = plan.baseline[key]!;
        } else {
          // A new recipe left out: not offered again.
          manifestRecipes[key] = CommunityManifestRecipe(recipeId: null, upstream: upstream, local: null);
        }
      }
      final stillUsed = <String>{
        for (final r in recipes) ...[
          if (r.imagePath != null) r.imagePath!,
          for (final s in r.steps)
            if (s.imagePath != null) s.imagePath!,
        ],
      };
      final photosOnDevice = {...?plan.manifest?.photos, ...photos.onDevice}
        ..removeWhere((serverPath, _) => !stillUsed.contains(serverPath));

      String t(String? s) => (s ?? '').trim();
      final keptTitle = plan.manifest?.title ?? '';
      final keptDescription = plan.manifest?.description;
      final rename = !skipAll && plan.newName != null && t(cookbook.name) == t(keptTitle);
      final redescribe = !skipAll && plan.descriptionChanged && t(cookbook.description) == t(keptDescription);
      await (db.update(db.cookbooks)..where((c) => c.id.equals(plan.cookbookId))).write(CookbooksCompanion(
            name: rename ? Value(plan.newName!) : const Value.absent(),
            description: redescribe ? Value(plan.detail.description) : const Value.absent(),
            updatedAt: rename || redescribe ? Value(DateTime.now()) : const Value.absent(),
            communitySourceVersion: Value(plan.version ?? cookbook.communityUpdateVersion ?? cookbook.communitySourceVersion),
            communityUpdateVersion: const Value(null),
            communityManifest: Value(CommunitySourceManifest(
              title: plan.detail.title,
              description: plan.detail.description,
              withImages: plan.withImages,
              recipes: manifestRecipes,
              photos: photosOnDevice,
            ).encode()),
          ));

      return CookbookUpdateResult(
        added: toInsert.length,
        updated: updated,
        removed: removedCount,
        failedPhotos: photos.failed,
      );
    });
  }
}
