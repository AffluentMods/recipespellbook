import 'package:flutter/foundation.dart';

import '../database/database.dart';
import '../l10n/app_localizations.dart';
import 'community_photo_uploader.dart';
import 'community_publish_pipeline.dart';
import 'community_service.dart';

// ════════════════════════════════════════════
//  CHANGED SINCE PUBLISHED + UPDATE ALL
// ════════════════════════════════════════════

enum PublicationChange {
  /// The local cookbook matches what was last sent.
  unchanged,

  /// The local cookbook changed since it was last sent.
  changed,

  /// Not published from a cookbook on this device (or the cookbook is gone),
  /// or a single recipe: only the per-row update can handle it.
  noSource,
}

/// Where one publication stands against its local cookbook.
class PublicationCheck {
  final MyPublication publication;
  final PublicationChange change;

  /// What an update would send, when the source cookbook is here.
  final PreparedPublish? job;

  /// The cookbook has fewer recipes than a publication needs.
  final int? tooFewRecipes;

  const PublicationCheck(this.publication, this.change, {this.job, this.tooFewRecipes});

  bool get isChanged => change == PublicationChange.changed;
}

/// How an "Update all changed" run went.
class UpdateAllSummary {
  /// Titles of the publications that were updated.
  final List<String> updated;

  /// Already up to date, so left alone.
  final int unchanged;

  /// Not linked to a cookbook on this device: update them one by one.
  final int noSource;

  /// Title and reason for each one that did not update.
  final List<({String title, String reason})> failed;

  /// Changed ones that were not tried because the run stopped.
  final List<String> notRun;

  /// The person stopped it.
  final bool stopped;

  /// Why the run stopped early on its own (rate limit, today's limit).
  final String? stopReason;

  const UpdateAllSummary({
    this.updated = const [],
    this.unchanged = 0,
    this.noSource = 0,
    this.failed = const [],
    this.notRun = const [],
    this.stopped = false,
    this.stopReason,
  });
}

/// Progress of an "Update all changed" run, for the progress panel.
class UpdateAllProgress {
  /// True while checking which publications changed.
  final bool checking;

  /// Checking: publications looked at so far, of [total].
  /// Updating: the one in progress (from 1), of [total] changed ones.
  final int current;
  final int total;

  /// The publication being updated.
  final String? title;

  /// Its photo upload and publish progress.
  final PublishProgress? publish;

  /// Stop was pressed; the run ends before the next cookbook.
  final bool stopping;

  /// Set once the run is over.
  final UpdateAllSummary? summary;

  const UpdateAllProgress({
    this.checking = false,
    this.current = 0,
    this.total = 0,
    this.title,
    this.publish,
    this.stopping = false,
    this.summary,
  });

  bool get finished => summary != null;

  /// 0..1 across the whole run (null while checking).
  double? get fraction {
    if (checking || total == 0) return null;
    if (finished) return 1;
    var part = 0.0;
    final p = publish;
    if (p != null) {
      if (p.status == 'publishing' || p.status == 'done') {
        part = 0.95;
      } else if (p.status == 'uploading' && p.totalImages > 0) {
        part = 0.9 * (p.uploadedImages / p.totalImages);
      }
    }
    return ((current - 1 + part) / total).clamp(0.0, 1.0);
  }

  UpdateAllProgress copyWith({bool? stopping}) => UpdateAllProgress(
        checking: checking,
        current: current,
        total: total,
        title: title,
        publish: publish,
        stopping: stopping ?? this.stopping,
        summary: summary,
      );
}

/// Stops a running "Update all". A cookbook whose photos are still going up
/// stops before anything of it is published; one already being published
/// finishes. Either way none is left half updated.
class UpdateAllControl {
  bool _stopRequested = false;
  PublishRunToken? _current;

  bool get stopRequested => _stopRequested;

  void stop() {
    _stopRequested = true;
    _current?.cancel();
  }
}

/// The running (or last finished) "Update all", kept outside the screen so
/// it carries on, and shows again, when the person leaves and comes back.
final updateAllProgressNotifier = ValueNotifier<UpdateAllProgress?>(null);

/// The control of the run in progress, if any.
UpdateAllControl? activeUpdateAll;

class CommunityPublicationUpdater {
  CommunityPublicationUpdater({
    required RecipeDao recipeDao,
    required CookbookDao cookbookDao,
    required CommunityPublishPipeline pipeline,
    Future<({String kind, String sourceId})?> Function(String publicationId)? lookupSource,
  })  : _recipeDao = recipeDao,
        _cookbookDao = cookbookDao,
        _pipeline = pipeline,
        _lookupSource = lookupSource ?? CommunityService.lookupPublishSource;

  final RecipeDao _recipeDao;
  final CookbookDao _cookbookDao;
  final CommunityPublishPipeline _pipeline;
  final Future<({String kind, String sourceId})?> Function(String) _lookupSource;

  /// Whether [pub]'s local cookbook changed since it was last sent.
  ///
  /// With a [PublishSnapshot] (saved by every publish and update from now
  /// on) the cookbook is rebuilt as an update would send it and compared by
  /// fingerprint, plus the cookbook's name. Publications from before that
  /// have none: they count as changed when the cookbook or any of its
  /// recipes was edited after the publication was last changed on the
  /// server, or the recipe count differs. One that looks unchanged gets a
  /// snapshot of its current state, so later edits are caught exactly.
  Future<PublicationCheck> check(MyPublication pub) async {
    if (pub.isSingleRecipe) return PublicationCheck(pub, PublicationChange.noSource);
    final source = await _lookupSource(pub.id);
    if (source == null || source.kind != 'cookbook') {
      return PublicationCheck(pub, PublicationChange.noSource);
    }
    final cookbook = await _cookbookDao.getCookbookById(source.sourceId);
    if (cookbook == null) return PublicationCheck(pub, PublicationChange.noSource);

    final snapshot = await PublishSnapshot.lookup(pub.id);
    final recipes = await _recipeDao.getRecipesForCookbook(cookbook.id);

    // Sub-recipes from other cookbooks: the earlier choice for ones offered
    // before, and in (the publish sheet's default) for any linked since.
    final external = await _pipeline.externalSubRecipeIds(recipes);
    final included = [
      for (final id in external)
        if (snapshot == null ||
            !snapshot.externalRecipeIds.contains(id) ||
            snapshot.includedExternalIds.contains(id))
          id,
    ];
    final extras = <Recipe>[];
    for (final id in included) {
      final recipe = await _recipeDao.getRecipeById(id);
      if (recipe != null) extras.add(recipe);
    }

    final job = await _pipeline.prepare(
      recipes: [...recipes, ...extras],
      title: pub.title,
      // What it was published with. One from before snapshots has photos
      // only if the server counts some: a text-only cookbook stays text only.
      includeImages: snapshot?.includeImages ?? pub.imageCount > 0,
      // The choice made when publishing; off when it was never made.
      includeNotes: snapshot?.includeNotes ?? false,
      kind: 'cookbook',
      sourceId: cookbook.id,
      coverPath: cookbook.imagePath,
      coverCloudPath: cookbook.imageServerPath,
      sourceName: cookbook.name,
      externalRecipeIds: external.toList(),
      includedExternalIds: included,
    );

    final bool changed;
    if (snapshot != null) {
      changed = snapshot.hash != job.contentHash ||
          (snapshot.name != null && snapshot.name != cookbook.name);
    } else {
      final since = pub.updatedAt ?? pub.createdAt;
      changed = (cookbook.updatedAt?.isAfter(since) ?? false) ||
          recipes.any((r) => r.updatedAt.isAfter(since)) ||
          extras.any((r) => r.updatedAt.isAfter(since)) ||
          job.recipeMaps.length != pub.recipeCount;
      if (!changed) {
        await PublishSnapshot.save(
          pub.id,
          PublishSnapshot(
            hash: job.contentHash,
            name: cookbook.name,
            includeImages: job.includeImages,
            externalRecipeIds: job.externalRecipeIds,
            includedExternalIds: job.includedExternalIds,
            at: DateTime.now(),
          ),
        );
      }
    }

    return PublicationCheck(
      pub,
      changed ? PublicationChange.changed : PublicationChange.unchanged,
      job: job,
      tooFewRecipes: recipes.length < kMinPublishRecipes ? recipes.length : null,
    );
  }

  /// Updates every changed cookbook publication in [pubs] whose cookbook is
  /// on this device, one after another, through the same pipeline as the
  /// per-row update. Unchanged ones and ones without a local cookbook are
  /// counted and left alone. Stops early on [control], on a rate limit that
  /// waiting did not clear, and on today's upload limit.
  Future<UpdateAllSummary> updateAll(
    List<MyPublication> pubs, {
    required AppLocalizations l10n,
    required UpdateAllControl control,
    void Function(UpdateAllProgress)? onProgress,
  }) async {
    final candidates = pubs.where((p) => !p.isSingleRecipe).toList();
    final todo = <PublicationCheck>[];
    var unchanged = 0;
    var noSource = 0;
    final updated = <String>[];
    final failed = <({String title, String reason})>[];
    final notRun = <String>[];
    String? stopReason;

    // ── Which ones changed ──
    for (var i = 0; i < candidates.length; i++) {
      if (control.stopRequested) {
        return UpdateAllSummary(unchanged: unchanged, noSource: noSource, failed: failed, stopped: true);
      }
      onProgress?.call(UpdateAllProgress(checking: true, current: i, total: candidates.length));
      final PublicationCheck check;
      try {
        check = await this.check(candidates[i]);
      } catch (e) {
        debugPrint('[Community] Update all: check failed for ${candidates[i].id}: $e');
        failed.add((title: candidates[i].title, reason: l10n.communityUnknownError));
        continue;
      }
      switch (check.change) {
        case PublicationChange.unchanged:
          unchanged++;
        case PublicationChange.noSource:
          noSource++;
        case PublicationChange.changed:
          todo.add(check);
      }
    }

    // ── Update them, one at a time ──

    for (var i = 0; i < todo.length; i++) {
      final check = todo[i];
      final title = check.publication.title;
      if (control.stopRequested) {
        notRun.addAll(todo.skip(i).map((c) => c.publication.title));
        break;
      }
      final tooFew = check.tooFewRecipes;
      if (tooFew != null) {
        failed.add((title: title, reason: l10n.communityNeedMinRecipes(tooFew)));
        continue;
      }

      void progress(PublishProgress? publish) => onProgress?.call(UpdateAllProgress(
            current: i + 1,
            total: todo.length,
            title: title,
            publish: publish,
            stopping: control.stopRequested,
          ));
      progress(const PublishProgress(status: 'preparing'));

      final token = PublishRunToken();
      control._current = token;
      final result = await _pipeline.run(
        check.job!,
        token: token,
        l10n: l10n,
        republishPublicationId: check.publication.id,
        onProgress: progress,
      );
      control._current = null;

      if (result.success) {
        if (result.renamed) {
          updated.add(title);
        } else {
          failed.add((title: title, reason: l10n.publicationsUpdateAllNameNotSaved));
        }
        continue;
      }
      if (result.cancelled) {
        notRun.addAll(todo.skip(i).map((c) => c.publication.title));
        break;
      }
      final error = result.error ?? l10n.communityPublishingFailed;
      failed.add((
        title: title,
        // Name the recipes whose photos did not go up.
        reason: result.failedRecipes.isEmpty ? error : '$error: ${result.failedRecipes.join(', ')}',
      ));
      // The rest would hit the same wall: stop with a clear reason.
      if (result.rateLimited || result.blocked) {
        stopReason = result.rateLimited ? l10n.publicationsUpdateAllRateLimited : result.error;
        notRun.addAll(todo.skip(i + 1).map((c) => c.publication.title));
        break;
      }
    }

    return UpdateAllSummary(
      updated: updated,
      unchanged: unchanged,
      noSource: noSource,
      failed: failed,
      notRun: notRun,
      stopped: control.stopRequested,
      stopReason: stopReason,
    );
  }
}
