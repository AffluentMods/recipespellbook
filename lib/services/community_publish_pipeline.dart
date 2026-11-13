import 'dart:convert';

import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../data/course_category_data.dart' as taxonomy;
import '../database/daos/tags_dao.dart';
import '../database/database.dart';
import '../l10n/app_localizations.dart';
import '../utils/platform_utils.dart' show supportsLocalFileSystem;
import 'auth_service.dart';
import 'community_photo_uploader.dart';
import 'community_service.dart';
import 'image_service.dart';

// ════════════════════════════════════════════
//  PUBLISH PIPELINE
// ════════════════════════════════════════════
//
// Builds what a Community publish sends from the local cookbook (or
// recipe), uploads its photos and publishes it, or replaces the recipes of
// an existing publication. Used by the publish screen and by "Update all
// changed" in My Publications, so both send exactly the same thing.

/// Everything a publish sends, built once from the local cookbook. Image
/// paths in [recipeMaps] stay local; each run swaps in server paths on a
/// copy, so a retry starts from the same data.
class PreparedPublish {
  final String title;
  final String? description;
  final String? tags;

  /// [tags] as a list (auto-suggested when none were picked, at most 5).
  final List<String> tagList;
  final List<Map<String, dynamic>> recipeMaps;

  /// Every photo to send, each once, in order: local files, and photos only
  /// in the cloud (a cloud path or an https address) that are fetched first.
  /// All of them go through the Community upload; nothing is published by
  /// its own path.
  final List<String> photoPaths;

  /// Photo → titles of the recipes (or the cookbook) that use it.
  final Map<String, List<String>> photoRecipes;
  final String? coverPath;

  /// 'cookbook' or 'recipe'.
  final String kind;

  /// The local cookbook or recipe id.
  final String sourceId;

  /// The cookbook's name when this was built (cookbooks only).
  final String? sourceName;
  final bool includeImages;

  /// Whether the person's own notes on each recipe go out. Off unless they
  /// switched it on; their star rating never does.
  final bool includeNotes;

  /// Sub-recipes from other cookbooks that were offered, and the ones that
  /// went in (cookbooks only).
  final List<String> externalRecipeIds;
  final List<String> includedExternalIds;

  /// Fingerprint of what this sends: the recipes, the photos (by name, size
  /// and modified time) and the cover. Equal hashes mean nothing changed.
  final String contentHash;

  const PreparedPublish({
    required this.title,
    required this.description,
    required this.tags,
    required this.tagList,
    required this.recipeMaps,
    required this.photoPaths,
    required this.photoRecipes,
    required this.coverPath,
    required this.kind,
    required this.sourceId,
    required this.sourceName,
    required this.includeImages,
    this.includeNotes = false,
    required this.externalRecipeIds,
    required this.includedExternalIds,
    required this.contentHash,
  });

  /// `cookbook:<id>` or `recipe:<id>`, for the publish key.
  String get sourceKey => '$kind:$sourceId';

  bool get isSingleRecipe => kind == 'recipe';

  /// Titles that use any of [photos], each once, in publish order.
  List<String> recipesFor(Iterable<String> photos) {
    final titles = <String>{};
    for (final photo in photos) {
      titles.addAll(photoRecipes[photo] ?? const []);
    }
    return titles.toList();
  }
}

/// How a [CommunityPublishPipeline.run] ended.
class PublishRunResult {
  /// The publication is live with this content.
  final bool success;

  /// Stopped before anything was published.
  final bool cancelled;

  /// The publication (new or updated).
  final String? publicationId;

  /// The server's status for a new publication ('pending_review' when held).
  final String? status;

  /// Why it failed, ready to show.
  final String? error;

  /// Photos did not upload; nothing was published.
  final bool photosFailed;

  /// Stopped before any photo went up: today's limit, or another upload
  /// still being processed.
  final bool blocked;

  /// Ended on the server's rate limit (after waiting it out a few times).
  final bool rateLimited;

  /// For an update whose cookbook was renamed: false when the recipes went
  /// in but the new name did not.
  final bool renamed;

  /// Photos sent this time, and photos already on the server that were not.
  final int photosSent;
  final int photosReused;

  /// Recipes whose photos moderation turned down (left out).
  final List<String> rejectedRecipes;

  /// With [photosFailed]: the recipes whose photos did not upload.
  final List<String> failedRecipes;

  /// Recipes whose photos are in a format this device cannot read (left out).
  final List<String> unsupportedRecipes;

  /// For an update with new [PublicationDetails]: false when the recipes
  /// went in but the title, description or tags did not.
  final bool detailsSaved;

  const PublishRunResult._({
    this.success = false,
    this.cancelled = false,
    this.publicationId,
    this.status,
    this.error,
    this.photosFailed = false,
    this.blocked = false,
    this.rateLimited = false,
    this.renamed = true,
    this.photosSent = 0,
    this.photosReused = 0,
    this.rejectedRecipes = const [],
    this.failedRecipes = const [],
    this.unsupportedRecipes = const [],
    this.detailsSaved = true,
  });

  static const _cancelled = PublishRunResult._(cancelled: true);
}

/// A publication's public title, description and tags as the person set
/// them on the publish screen, saved with an update.
class PublicationDetails {
  final String title;
  final String? description;

  /// Comma-separated; null or empty for none.
  final String? tags;

  const PublicationDetails({required this.title, this.description, this.tags});
}

class CommunityPublishPipeline {
  CommunityPublishPipeline({
    required RecipeDao recipeDao,
    required TagsDao tagsDao,
    CommunityService? community,
    CommunityPhotoUploader Function()? uploader,
    Future<void> Function(Duration)? wait,
    Future<String?> Function(String remotePhoto)? fetchRemotePhoto,
  })  : _recipeDao = recipeDao,
        _tagsDao = tagsDao,
        _community = community ?? CommunityService.instance,
        _uploader = uploader ?? CommunityPhotoUploader.new,
        _wait = wait ?? Future<void>.delayed,
        _fetchRemotePhoto = fetchRemotePhoto ?? ImageService.instance.localCopyOfRemotePhoto;

  final RecipeDao _recipeDao;
  final TagsDao _tagsDao;
  final CommunityService _community;
  final CommunityPhotoUploader Function() _uploader;
  final Future<void> Function(Duration) _wait;
  final Future<String?> Function(String) _fetchRemotePhoto;

  /// Fetches photos only in the cloud this many at a time.
  static const _fetchConcurrency = 4;

  /// Asks the file system each time: what a publish sends must not depend
  /// on a cache made for drawing thumbnails.
  static bool _fileExists(String path) {
    if (!supportsLocalFileSystem) return false;
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  /// The photo a publish sends for a picture shown from [path] whose cloud
  /// copy is [cloudPath]: the local file while it is there, else the cloud
  /// copy (or [path] itself when that is a cloud path or an https address).
  /// Null when there is none to send.
  static String? photoToSend(String? path, String? cloudPath) {
    if (path != null && path.isNotEmpty) {
      if (ImageService.isRemotePhoto(path)) return path;
      if (!path.startsWith('http') && _fileExists(path)) return path;
    }
    return ImageService.isServerPath(cloudPath) ? cloudPath : null;
  }

  /// Sub-recipes the [recipes] link to that are not among them (they live
  /// in other cookbooks). Without them those links break once published.
  Future<Set<String>> externalSubRecipeIds(List<Recipe> recipes) async {
    final ids = recipes.map((r) => r.id).toSet();
    final external = <String>{};
    for (final r in recipes) {
      final linked = await _recipeDao.getLinkedRecipes(r.id);
      for (final sub in linked) {
        if (!ids.contains(sub.id)) external.add(sub.id);
      }
    }
    return external;
  }

  /// Builds the publish from [recipes] (the cookbook's, then any included
  /// sub-recipes from other cookbooks, or the single recipe).
  Future<PreparedPublish> prepare({
    required List<Recipe> recipes,
    required String title,
    String? description,
    List<String> tags = const [],
    required bool includeImages,
    bool includeNotes = false,
    required String kind,
    required String sourceId,
    String? coverPath,
    String? coverCloudPath,
    String? sourceName,
    List<String> externalRecipeIds = const [],
    List<String> includedExternalIds = const [],
  }) async {
    final singleRecipe = kind == 'recipe';
    final recipeMaps = <Map<String, dynamic>>[];
    // Photo → titles of the recipes that use it, for telling the person
    // which recipes a failed or rejected photo belongs to.
    final photoRecipes = <String, List<String>>{};
    void trackPhoto(String? path, String owner) {
      if (!includeImages || path == null || path.isEmpty) return;
      final owners = photoRecipes.putIfAbsent(path, () => []);
      if (!owners.contains(owner)) owners.add(owner);
    }

    // Collect cookbook cover (only in cookbook mode: single-recipe
    // publications use the recipe's image as the cover). A photo whose
    // file is not on this device is sent from its cloud copy.
    final cookbookCover = singleRecipe ? null : photoToSend(coverPath, coverCloudPath);
    trackPhoto(cookbookCover, title);

    // Build a map of recipe ID → index for recipe link references
    final recipeIdToIndex = <String, int>{};
    for (var i = 0; i < recipes.length; i++) {
      recipeIdToIndex[recipes[i].id] = i;
    }

    for (final r in recipes) {
      final ingredients = await _recipeDao.getIngredientsForRecipe(r.id);
      final steps = await _recipeDao.getStepsForRecipe(r.id);
      final recipeTagRows = await _tagsDao.getTagsForRecipe(r.id);

      // Track recipe and step images
      final photo = photoToSend(r.imagePath, r.imageServerPath);
      final stepPhotos = [for (final s in steps) photoToSend(s.imagePath, s.imageServerPath)];
      trackPhoto(photo, r.title);
      for (final stepPhoto in stepPhotos) {
        trackPhoto(stepPhoto, r.title);
      }

      // Gather recipe links (ingredient→sub-recipe references)
      final linksMap = await _recipeDao.getIngredientLinksMap(r.id);
      final recipeLinksData = <Map<String, dynamic>>[];
      for (var ingIdx = 0; ingIdx < ingredients.length; ingIdx++) {
        final ing = ingredients[ingIdx];
        final ingLinks = linksMap[ing.id];
        if (ingLinks != null) {
          for (final link in ingLinks) {
            final linkedIndex = recipeIdToIndex[link.recipe.id];
            if (linkedIndex != null) {
              recipeLinksData.add({
                'ingredientIndex': ingIdx,
                'linkedRecipeIndex': linkedIndex,
                'scale': link.scale,
              });
            }
          }
        }
      }

      recipeMaps.add({
        'title': r.title,
        'description': r.description,
        'servings': r.servings,
        'prepTimeMinutes': r.prepTimeMinutes,
        'cookTimeMinutes': r.cookTimeMinutes,
        'sourceUrl': r.sourceUrl,
        'imagePath': photo, // Replaced with the server path per run
        'categoryId': r.categoryId,
        'courseId': r.courseId,
        // The person's own star rating is theirs: it is never published.
        // Their notes only go out when they chose to include them.
        'notes': includeNotes ? r.notes : null,
        'nutritionJson': r.nutritionJson,
        'ingredients': ingredients.map((i) => {
          'sortOrder': i.sortOrder,
          'amount': i.amount,
          'unit': i.unit,
          'name': i.name,
          'notes': i.notes,
        }).toList(),
        'steps': <Map<String, dynamic>>[
          for (var i = 0; i < steps.length; i++)
            {
              'sortOrder': steps[i].sortOrder,
              'instruction': steps[i].instruction,
              'durationMinutes': steps[i].durationMinutes,
              'notes': steps[i].notes,
              'imagePath': stepPhotos[i], // Replaced with the server path per run
            },
        ],
        'tags': recipeTagRows.map((t) => t.name).toList(),
        if (recipeLinksData.isNotEmpty) 'recipeLinks': recipeLinksData,
      });

      // Auto-add course/category display names as tags if recipe has no tags
      final recipeTags = recipeMaps.last['tags'] as List;
      if (recipeTags.isEmpty) {
        if (r.courseId != null && r.courseId!.isNotEmpty) {
          // Look up display name from CourseData, fallback to ID
          final course = taxonomy.CourseData.courses.where((c) => c.id == r.courseId).firstOrNull;
          final courseName = course?.name ?? r.courseId!;
          // Skip custom IDs that look like database IDs
          if (!courseName.contains('_')) {
            recipeTags.add(courseName.toLowerCase());
          }
        }
        if (r.categoryId != null && r.categoryId!.isNotEmpty && r.categoryId != r.courseId) {
          final category = taxonomy.CategoryData.categories.where((c) => c.id == r.categoryId).firstOrNull;
          final categoryName = category?.name ?? r.categoryId!;
          if (!categoryName.contains('_')) {
            final normalized = categoryName.toLowerCase();
            if (!recipeTags.contains(normalized)) {
              recipeTags.add(normalized);
            }
          }
        }
      }
    }

    // ── Auto-suggest cookbook tags from recipe tags (top 5 most common) ──
    var selectedTags = List<String>.from(tags);
    if (selectedTags.isEmpty) {
      final tagCounts = <String, int>{};
      for (final rm in recipeMaps) {
        final recipeTags = rm['tags'] as List? ?? [];
        for (final t in recipeTags) {
          final tag = t.toString().toLowerCase().trim();
          if (tag.isNotEmpty) tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
      }
      if (tagCounts.isNotEmpty) {
        final sorted = tagCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        selectedTags = sorted.take(5).map((e) => e.key).toList();
      }
    }

    // Enforce max 5 tags on cookbook level
    if (selectedTags.length > 5) {
      selectedTags = selectedTags.take(5).toList();
    }

    // Enforce max 5 tags per recipe
    for (final rm in recipeMaps) {
      final recipeTags = rm['tags'] as List? ?? [];
      if (recipeTags.length > 5) {
        rm['tags'] = recipeTags.take(5).toList();
      }
    }

    final desc = description?.trim() ?? '';
    final cover = singleRecipe
        ? (recipes.isEmpty ? null : photoToSend(recipes.first.imagePath, recipes.first.imageServerPath))
        : cookbookCover;
    return PreparedPublish(
      title: title,
      description: desc.isNotEmpty ? desc : null,
      tags: selectedTags.isNotEmpty ? selectedTags.join(',') : null,
      tagList: selectedTags,
      recipeMaps: recipeMaps,
      photoPaths: photoRecipes.keys.toList(),
      photoRecipes: photoRecipes,
      // For cookbook mode use the cookbook cover; for single-recipe mode
      // fall back to the recipe's own image.
      coverPath: cover,
      kind: kind,
      sourceId: sourceId,
      sourceName: singleRecipe ? null : sourceName,
      includeImages: includeImages,
      includeNotes: includeNotes,
      externalRecipeIds: externalRecipeIds,
      includedExternalIds: includedExternalIds,
      contentHash: await fingerprint(
        recipeMaps: recipeMaps,
        coverPath: cookbookCover,
        includeImages: includeImages,
      ),
    );
  }

  /// A hash of what a publish sends. Photos count by file name, size and
  /// modified time (a server path counts as itself), so an edited or
  /// replaced photo changes it and an untouched one does not.
  static Future<String> fingerprint({
    required List<Map<String, dynamic>> recipeMaps,
    required String? coverPath,
    required bool includeImages,
  }) async {
    final tokens = <String, String>{};
    Future<String?> photo(Object? path) async {
      if (!includeImages || path is! String || path.isEmpty) return null;
      final known = tokens[path];
      if (known != null) return known;
      String token;
      if (ImageService.isServerPath(path)) {
        token = 'server:$path';
      } else {
        try {
          final file = File(path);
          final size = await file.length();
          final modified = await file.lastModified();
          token = 'file:${p.basename(path)}|$size|${modified.millisecondsSinceEpoch}';
        } catch (_) {
          token = 'missing:${p.basename(path)}';
        }
      }
      return tokens[path] = token;
    }

    final recipes = <Map<String, dynamic>>[];
    for (final recipe in recipeMaps) {
      final steps = <Map<String, dynamic>>[];
      for (final step in (recipe['steps'] as List).cast<Map<String, dynamic>>()) {
        steps.add({...step, 'imagePath': await photo(step['imagePath'])});
      }
      recipes.add({...recipe, 'imagePath': await photo(recipe['imagePath']), 'steps': steps});
    }
    final payload = jsonEncode({
      'v': 1,
      'cover': await photo(coverPath),
      'recipes': recipes,
    });
    return sha256.convert(utf8.encode(payload)).toString();
  }

  /// Photos still to upload are counted at most this big. Re-encoded photos
  /// are at most 1920 px and nearly always smaller; the real total goes in
  /// the publish, which the server checks again.
  static const _estimatedPhotoBytes = 1024 * 1024;

  /// Before any photo goes up: is another upload still being processed, or
  /// would this one pass today's limit? Returns the message to stop with, or
  /// null to go on (also when the status can't be read).
  Future<String?> _uploadBlockedReason(
    List<String> photoPaths,
    CommunityUploadedPhotos store,
    Map<String, ({String serverPath, int bytes})> reuse,
    AppLocalizations l10n,
  ) async {
    var estimate = 0;
    var pending = 0;
    for (final path in photoPaths) {
      final key = await store.keyFor(path);
      final known = key == null ? null : (store.lookup(key) ?? reuse[key]);
      if (known != null) {
        estimate += known.bytes;
        continue;
      }
      pending++;
      try {
        final size = File(path).lengthSync();
        estimate += size < _estimatedPhotoBytes ? size : _estimatedPhotoBytes;
      } catch (_) {
        estimate += _estimatedPhotoBytes;
      }
    }
    if (pending == 0) return null;

    final status = await _community.getUploadStatus();
    if (status == null) return null;
    if (status.locked) return l10n.communityPublishServerBusy;
    if (!status.canUpload || status.bytesToday + estimate > status.dailyLimitBytes) {
      return l10n.communityPublishDailyLimit;
    }
    return null;
  }

  /// Each of [photos] as a file on this device: a local one as it is, one
  /// only in the cloud fetched first, a few at a time. Null for a photo that
  /// could not be fetched.
  Future<Map<String, String?>> _localFiles(List<String> photos, PublishRunToken token) async {
    final out = <String, String?>{};
    final remote = <String>[];
    for (final photo in photos) {
      if (ImageService.isRemotePhoto(photo)) {
        remote.add(photo);
      } else {
        out[photo] = photo;
      }
    }
    var next = 0;
    Future<void> worker() async {
      while (next < remote.length && !token.cancelled) {
        final photo = remote[next++];
        out[photo] = await _fetchRemotePhoto(photo);
      }
    }

    await Future.wait([for (var w = 0; w < _fetchConcurrency && w < remote.length; w++) worker()]);
    return out;
  }

  /// Uploads [job]'s photos (skipping ones already on the server) and
  /// publishes it, or with [republishPublicationId] replaces that
  /// publication's recipes (downloads and ratings stay). Runs again as-is
  /// for "Retry failed photos". [onProgress] gets every step, ending in
  /// 'done' or 'error', until [token] is cancelled.
  ///
  /// For an update, [details] are the title, description and tags the
  /// person set on the publish screen, saved along with the recipes; without
  /// them those stay as they are. [publishedTitle] is the publication's
  /// title now: a cookbook renamed since the last publish passes its new
  /// name on only while the public title is still the old name, so a title
  /// the person chose for the Community is never overwritten.
  Future<PublishRunResult> run(
    PreparedPublish job, {
    required PublishRunToken token,
    required AppLocalizations l10n,
    String? republishPublicationId,
    PublicationDetails? details,
    String? publishedTitle,
    void Function(PublishProgress)? onProgress,
  }) async {
    bool live() => !token.cancelled;
    void report(PublishProgress p) {
      if (live()) onProgress?.call(p);
    }

    try {
      // ── Upload images (if enabled) ──
      var pathMapping = <String, String>{}; // photo → server path
      var totalImageBytes = 0;
      var rejected = <String>[];
      var unsupported = <String>[];
      var storeKeys = <String>[];
      var photoKeys = <String, ({String serverPath, int bytes})>{};
      var reused = 0;
      CommunityUploadedPhotos? store;

      if (job.includeImages && job.photoPaths.isNotEmpty) {
        report(PublishProgress(status: 'uploading', totalImages: job.photoPaths.length));

        // Photos only in the cloud (taken on another device) come down
        // first and then go up like the rest, through the Community upload:
        // the moderation scan, the metadata strip and the publisher's own
        // copy. A cloud path is never published as it is.
        final fileOf = await _localFiles(job.photoPaths, token);
        if (!live()) return PublishRunResult._cancelled;
        final unreachable = [
          for (final photo in job.photoPaths)
            if (fileOf[photo] == null) photo,
        ];
        final files = [
          for (final photo in job.photoPaths)
            if (fileOf[photo] != null) fileOf[photo]!,
        ];
        final photoOf = {
          for (final e in fileOf.entries)
            if (e.value != null) e.value!: e.key,
        };
        List<String> photosFor(List<String> uploaded) => [for (final file in uploaded) photoOf[file] ?? file];

        store = await CommunityUploadedPhotos.load(AuthService.instance.currentUser?.id ?? '');
        // An update reuses the photos the publication already shows.
        final reuse = republishPublicationId != null
            ? await PublishedPhotos.load(republishPublicationId)
            : const <String, ({String serverPath, int bytes})>{};
        final blocked = await _uploadBlockedReason(files, store, reuse, l10n);
        if (!live()) return PublishRunResult._cancelled;
        if (blocked != null) {
          report(PublishProgress(status: 'error', errorMessage: blocked));
          return PublishRunResult._(error: blocked, blocked: true);
        }

        final photos = await _uploader().run(
          files,
          token: token,
          store: store,
          reuse: reuse,
          onProgress: (p) => report(PublishProgress(
            status: 'uploading',
            uploadedImages: p.done,
            totalImages: p.total,
            skippedImages: p.rejected + p.failed,
            waitSeconds: p.waitSeconds,
          )),
        );
        if (!live()) return PublishRunResult._cancelled;

        // A photo that did not upload (or could not be fetched) must not
        // quietly drop out of the publication: stop here and let the person
        // retry just those.
        final failed = [...unreachable, ...photosFor(photos.failed)];
        if (failed.isNotEmpty) {
          report(PublishProgress(
            status: 'error',
            errorMessage: l10n.communityPublishPhotosFailedTitle,
            uploadedImages: photos.uploaded.length,
            totalImages: job.photoPaths.length,
            skippedImages: photos.rejected.length + photos.unsupported.length + failed.length,
            failedRecipes: job.recipesFor(failed),
            rejectedRecipes: job.recipesFor(photosFor(photos.rejected)),
            unsupportedRecipes: job.recipesFor(photosFor(photos.unsupported)),
          ));
          return PublishRunResult._(
            error: l10n.communityPublishPhotosFailedTitle,
            photosFailed: true,
            rateLimited: photos.rateLimited.isNotEmpty,
            failedRecipes: job.recipesFor(failed),
          );
        }
        pathMapping = {
          for (final e in photos.uploaded.entries) photoOf[e.key] ?? e.key: e.value,
        };
        totalImageBytes = photos.bytesSent;
        rejected = photosFor(photos.rejected);
        unsupported = photosFor(photos.unsupported);
        storeKeys = photos.storeKeys;
        photoKeys = photos.photoKeys;
        reused = photos.reused;
      }

      // ── Replace photos with their Community upload (on a copy) ──
      // Only a photo that went up through the Community upload is sent;
      // one moderation turned down, or nothing here can read, is left out.
      String? serverPath(String? path) => job.includeImages && path != null ? pathMapping[path] : null;

      final recipeMaps = [
        for (final recipe in job.recipeMaps)
          {
            ...recipe,
            'imagePath': serverPath(recipe['imagePath'] as String?),
            'steps': [
              for (final step in recipe['steps'] as List<Map<String, dynamic>>)
                {...step, 'imagePath': serverPath(step['imagePath'] as String?)},
            ],
          },
      ];
      final cookbookImagePath = serverPath(job.coverPath);
      final rejectedRecipes = job.recipesFor(rejected);
      final unsupportedRecipes = job.recipesFor(unsupported);
      final photosSent = pathMapping.length - reused;

      Future<void> forgetUploadedPhotos() async {
        store?.removeAll(storeKeys);
        await store?.save();
      }

      // ── Publish ──
      // Last check before anything is published: a cancelled run stops here.
      if (!live()) return PublishRunResult._cancelled;
      report(PublishProgress(
        status: 'publishing',
        uploadedImages: pathMapping.length,
        totalImages: pathMapping.length,
        skippedImages: rejected.length,
      ));

      // Republish-to-update branch: same upload pipeline, different
      // final API. Stats (downloads, ratings) stay attached to the
      // existing publication.
      if (republishPublicationId != null) {
        // A 429 is the server's rate limit: wait it out a few times. The
        // replacement is the same every time, so a retry is safe.
        Future<({bool ok, Duration? retryAfter})> replaceOnce() => _community.replacePublicationRecipesResult(
              republishPublicationId,
              recipes: recipeMaps,
              imageCount: pathMapping.length,
              totalImageBytes: totalImageBytes,
              imagePath: cookbookImagePath,
            );
        var result = await replaceOnce();
        for (var tries = 0; !result.ok && result.retryAfter != null && tries < 5; tries++) {
          await _wait(Duration(seconds: result.retryAfter!.inSeconds.clamp(1, 60)));
          if (!live()) return PublishRunResult._cancelled;
          result = await replaceOnce();
        }
        if (!result.ok) {
          report(PublishProgress(
            status: 'error',
            errorMessage: l10n.communityPublishingFailed,
          ));
          return PublishRunResult._(
            error: l10n.communityPublishingFailed,
            rateLimited: result.retryAfter != null,
            publicationId: republishPublicationId,
          );
        }

        await forgetUploadedPhotos();
        // The title, description and tags edited on the publish screen.
        final detailsSaved = details == null ||
            await _community.updatePublication(
              republishPublicationId,
              title: details.title,
              description: details.description ?? '',
              tags: details.tags ?? '',
            );
        final renamed = await _remember(
          republishPublicationId,
          job,
          photoKeys,
          update: true,
          // A title just set by the person is theirs, not the cookbook's.
          publishedTitle: details == null ? publishedTitle : null,
        );
        report(PublishProgress(
          status: 'done',
          uploadedImages: pathMapping.length,
          totalImages: pathMapping.length,
          skippedImages: rejected.length,
          rejectedRecipes: rejectedRecipes,
          unsupportedRecipes: unsupportedRecipes,
          publicationId: republishPublicationId,
        ));
        return PublishRunResult._(
          success: true,
          publicationId: republishPublicationId,
          renamed: renamed,
          detailsSaved: detailsSaved,
          photosSent: photosSent,
          photosReused: reused,
          rejectedRecipes: rejectedRecipes,
          unsupportedRecipes: unsupportedRecipes,
        );
      }

      // Same key on every try for this cookbook until one succeeds, so a
      // retry after a timeout cannot publish it twice.
      final publishKey = await CommunityService.publishKeyFor(job.sourceKey);
      if (!live()) return PublishRunResult._cancelled;

      Future<({bool success, String? error, String? publicationId, String? status, Duration? retryAfter})>
          publishOnce() => _community.publish(
                title: job.title,
                description: job.description,
                imagePath: cookbookImagePath,
                recipes: recipeMaps,
                imageCount: pathMapping.length,
                totalImageBytes: totalImageBytes,
                tags: job.tags,
                kind: job.kind,
                publishKey: publishKey,
              );

      // A 429 with Retry-After is the account's upload lock (an earlier try
      // may still be processing): wait it out a few times. The same key
      // makes the retry safe. The daily limit has no Retry-After and stops.
      var result = await publishOnce();
      for (var tries = 0; !result.success && result.retryAfter != null && tries < 5; tries++) {
        await _wait(Duration(seconds: result.retryAfter!.inSeconds.clamp(1, 60)));
        if (!live()) return PublishRunResult._cancelled;
        result = await publishOnce();
      }

      if (result.success) {
        await CommunityService.clearPublishKey(job.sourceKey);
        await forgetUploadedPhotos();

        // Remember which local recipe/cookbook this publication came
        // from so "Update published version" can push the right content
        // later without making the user re-pick, and what was sent so
        // My Publications can tell when it changed.
        if (result.publicationId != null) {
          if (job.sourceId.isNotEmpty) {
            await CommunityService.recordPublishSource(
              result.publicationId!,
              kind: job.kind,
              sourceId: job.sourceId,
            );
          }
          await _remember(result.publicationId!, job, photoKeys, update: false);
        }

        report(PublishProgress(
          status: 'done',
          uploadedImages: pathMapping.length,
          totalImages: pathMapping.length,
          skippedImages: rejected.length,
          rejectedRecipes: rejectedRecipes,
          unsupportedRecipes: unsupportedRecipes,
          publicationId: result.publicationId,
        ));
        return PublishRunResult._(
          success: true,
          publicationId: result.publicationId,
          status: result.status,
          photosSent: photosSent,
          photosReused: reused,
          rejectedRecipes: rejectedRecipes,
          unsupportedRecipes: unsupportedRecipes,
        );
      }

      final error = result.error ?? l10n.communityPublishingFailed;
      report(PublishProgress(status: 'error', errorMessage: error));
      return PublishRunResult._(error: error, rateLimited: result.retryAfter != null);
    } catch (e) {
      report(PublishProgress(
        status: 'error',
        errorMessage: e.toString(),
      ));
      return PublishRunResult._(error: e.toString());
    }
  }

  /// After a publish or update went through: keep the photos it used for
  /// the next update and a [PublishSnapshot] (what was sent, and the
  /// person's choices for photos and notes). An update of a cookbook renamed
  /// since the last snapshot also takes the new name over as the
  /// publication's title, but only while that title is still the old name
  /// ([publishedTitle]): a title of its own stays. Returns false when the
  /// rename failed (the old name stays in the snapshot, so it still shows as
  /// changed).
  Future<bool> _remember(
    String publicationId,
    PreparedPublish job,
    Map<String, ({String serverPath, int bytes})> photoKeys, {
    required bool update,
    String? publishedTitle,
  }) async {
    await PublishedPhotos.save(publicationId, photoKeys);

    var name = job.sourceName;
    var renamed = true;
    if (update && name != null && !job.isSingleRecipe) {
      final previous = await PublishSnapshot.lookup(publicationId);
      final oldName = previous?.name;
      final titleFollowsName = oldName != null && publishedTitle != null && publishedTitle.trim() == oldName.trim();
      if (oldName != null && oldName != name && titleFollowsName) {
        renamed = await _community.updatePublication(publicationId, title: name);
        if (!renamed) name = oldName;
      }
    }
    await PublishSnapshot.save(
      publicationId,
      PublishSnapshot(
        hash: job.contentHash,
        name: name,
        includeImages: job.includeImages,
        includeNotes: job.includeNotes,
        externalRecipeIds: job.externalRecipeIds,
        includedExternalIds: job.includedExternalIds,
        at: DateTime.now(),
      ),
    );
    return renamed;
  }
}
