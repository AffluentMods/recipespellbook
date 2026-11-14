import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../database/daos/tags_dao.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/community_publish_pipeline.dart';
import '../../../services/community_service.dart';
import '../../../services/community_update_all.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/community/community_media.dart';
import '../../widgets/community_tag_picker.dart';

// ════════════════════════════════════════════
//  MY PUBLICATIONS — Manage published cookbooks
// ════════════════════════════════════════════

class CommunityMyPublicationsScreen extends ConsumerStatefulWidget {
  const CommunityMyPublicationsScreen({super.key});

  @override
  ConsumerState<CommunityMyPublicationsScreen> createState() => _CommunityMyPublicationsScreenState();
}

class _CommunityMyPublicationsScreenState extends ConsumerState<CommunityMyPublicationsScreen> {
  final _community = CommunityService.instance;
  final _scrollController = ScrollController();

  bool _loading = true;
  // The last load did not come through.
  bool _loadFailed = false;
  bool _fabVisible = true;
  List<MyPublication> _pubs = [];

  // Changed since published: filled in one publication at a time after
  // each load. A newer check (or an Update all) makes an older one stop.
  final Map<String, PublicationChange> _changes = {};
  int _checkGeneration = 0;
  bool _checking = false;
  int _checked = 0;
  int _checkTotal = 0;

  // The finished Update all this screen already reloaded for.
  UpdateAllSummary? _reloadedFor;

  @override
  void initState() {
    super.initState();
    _reloadedFor = updateAllProgressNotifier.value?.summary;
    _load();
    publishProgressNotifier.addListener(_onProgressChange);
    updateAllProgressNotifier.addListener(_onUpdateAllChange);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _checkGeneration++;
    publishProgressNotifier.removeListener(_onProgressChange);
    updateAllProgressNotifier.removeListener(_onUpdateAllChange);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _fabVisible) {
      setState(() => _fabVisible = false);
    } else if (direction == ScrollDirection.forward && !_fabVisible) {
      setState(() => _fabVisible = true);
    }
  }

  void _onProgressChange() {
    // Refresh when a publish completes
    final p = publishProgressNotifier.value;
    if (p != null && (p.status == 'done' || p.status == 'error')) {
      _load();
    }
    if (mounted) setState(() {});
  }

  void _onUpdateAllChange() {
    // Reload once a run is over: the updated ones are no longer changed.
    final summary = updateAllProgressNotifier.value?.summary;
    if (summary != null && !identical(summary, _reloadedFor)) {
      _reloadedFor = summary;
      _changes.clear(); // stale now; checked again after the reload
      _load();
    }
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    // Signed out there is nothing to load (the screen asks to sign in).
    final pubs = AuthService.instance.isSignedIn ? await _community.fetchMyPublications() : <MyPublication>[];
    if (!mounted) return;
    if (pubs == null) {
      // Not loaded: keep what is shown, and never show "No publications
      // yet" for a list that just did not come.
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
      if (_pubs.isNotEmpty) AppSnackbar.error(context, AppLocalizations.of(context)!.communityLoadFailed);
      return;
    }
    setState(() { _pubs = pubs; _loading = false; _loadFailed = false; });
    _checkChanges();
  }

  CommunityPublicationUpdater _updater() {
    final recipeDao = ref.read(recipeDaoProvider);
    return CommunityPublicationUpdater(
      recipeDao: recipeDao,
      cookbookDao: ref.read(cookbookDaoProvider),
      pipeline: CommunityPublishPipeline(
        recipeDao: recipeDao,
        tagsDao: TagsDao(ref.read(databaseProvider)),
      ),
    );
  }

  /// Compares each cookbook publication with its local cookbook, one at a
  /// time, and marks the ones that changed since they were published.
  Future<void> _checkChanges() async {
    final generation = ++_checkGeneration;
    // A running Update all checks for itself; this runs again when it ends.
    if (activeUpdateAll != null) return;
    final pubs = _pubs.where((p) => !p.isSingleRecipe).toList();
    final ids = _pubs.map((p) => p.id).toSet();
    final updater = _updater();
    setState(() {
      _changes.removeWhere((id, _) => !ids.contains(id));
      _checking = pubs.isNotEmpty;
      _checked = 0;
      _checkTotal = pubs.length;
    });
    for (final pub in pubs) {
      PublicationChange? change;
      try {
        change = (await updater.check(pub)).change;
      } catch (e) {
        debugPrint('[Community] Change check failed for ${pub.id}: $e');
      }
      if (!mounted || generation != _checkGeneration) return;
      setState(() {
        if (change != null) _changes[pub.id] = change;
        _checked++;
      });
    }
    if (mounted && generation == _checkGeneration) setState(() => _checking = false);
  }

  int get _changedCount =>
      _pubs.where((p) => _changes[p.id] == PublicationChange.changed).length;

  /// "Update all changed": every changed cookbook publication whose
  /// cookbook is on this device, one after another, without the publish
  /// screen. Progress and the summary show at the top of this screen.
  Future<void> _updateAllChanged() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.publicationsUpdateAllConfirmTitle(_changedCount)),
        content: Text(l10n.publicationsUpdateAllConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.communityRepublishRecipesAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted || activeUpdateAll != null) return;

    final control = UpdateAllControl();
    activeUpdateAll = control;
    _checkGeneration++; // the run checks again itself
    setState(() => _checking = false);
    final updater = _updater();
    final pubs = List<MyPublication>.of(_pubs);
    updateAllProgressNotifier.value = const UpdateAllProgress(checking: true);

    UpdateAllSummary summary;
    try {
      summary = await updater.updateAll(
        pubs,
        l10n: l10n,
        control: control,
        onProgress: (p) => updateAllProgressNotifier.value = p.copyWith(stopping: control.stopRequested),
      );
    } catch (e) {
      debugPrint('[Community] Update all failed: $e');
      summary = UpdateAllSummary(stopped: true, stopReason: l10n.communityUnknownError);
    } finally {
      activeUpdateAll = null;
    }
    updateAllProgressNotifier.value = UpdateAllProgress(summary: summary);
  }

  void _stopUpdateAll() {
    activeUpdateAll?.stop();
    final current = updateAllProgressNotifier.value;
    if (current != null && !current.finished) {
      updateAllProgressNotifier.value = current.copyWith(stopping: true);
    }
  }

  Future<void> _unpublish(String publicationId) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await _community.unpublish(publicationId);
    if (ok) {
      // Drop the local source mapping — the publication no longer exists.
      await CommunityService.removePublishSource(publicationId);
    }
    if (mounted) {
      if (ok) {
        AppSnackbar.success(context, l10n.communityUnpublishSuccess(
          _pubs.firstWhere((p) => p.id == publicationId).title,
        ));
        _load();
      } else {
        AppSnackbar.error(context, l10n.communityUnpublishFailed);
      }
    }
  }

  Future<void> _republish(MyPublication pub) async {
    final l10n = AppLocalizations.of(context)!;
    // Confirm — replacement is destructive on the recipe content side
    // (server deletes old recipe rows in the same transaction). Stats
    // are preserved.
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.communityRepublishRecipes),
        content: Text(l10n.communityRepublishRecipesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.communityRepublishRecipesAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    // Resolve which local recipe/cookbook this publication came from.
    // Recorded at publish time on this device; may be absent if the
    // publication was created on another device or after a data wipe.
    final source = await CommunityService.lookupPublishSource(pub.id);
    if (!mounted) return;

    if (pub.isSingleRecipe) {
      // A single-recipe publication can ONLY be updated from its source
      // recipe — there's no cookbook to pick from. If we can't locate
      // it, bail with a clear message rather than silently doing the
      // wrong thing (the old behaviour fell through to the cookbook
      // picker and would replace the recipe with a whole cookbook).
      if (source != null && source.kind == 'recipe') {
        // Deleted-recipe case is handled by the publish screen (it pops
        // with an error if the id no longer resolves).
        context.push('/community/publish?republish=${pub.id}&recipe=${source.sourceId}');
      } else {
        AppSnackbar.error(context, l10n.communityRepublishSourceMissing);
      }
      return;
    }

    // Cookbook publication. With a known source we pre-select it (no
    // re-picking, no risk of overwriting with the wrong cookbook).
    // Without one, fall back to the cookbook picker.
    if (source != null && source.kind == 'cookbook') {
      context.push('/community/publish?republish=${pub.id}&cookbook=${source.sourceId}');
    } else {
      context.push('/community/publish?republish=${pub.id}');
    }
  }

  void _confirmUnpublish(MyPublication pub) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.communityUnpublishDialogTitle),
        content: Text(l10n.communityUnpublishDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
            onPressed: () {
              Navigator.pop(ctx);
              _unpublish(pub.id);
            },
            child: Text(l10n.communityUnpublish),
          ),
        ],
      ),
    );
  }

  Future<void> _editPublication(MyPublication pub) async {
    final l10n = AppLocalizations.of(context)!;
    final descController = TextEditingController(text: pub.description ?? '');
    final currentTags = pub.tags?.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList() ?? <String>[];
    List<String> selectedTags = List.from(currentTags);

    final result = await showDialog<bool>(
      context: context,
      useSafeArea: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final theme = Theme.of(ctx);
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(ctx, false),
              ),
              title: Text(l10n.communityEditPublication),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.actionSave),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Responsive.constrainWidth(ctx, child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.communityEditDescription, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: l10n.communityEditDescriptionHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(l10n.communityEditTags, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                CommunityTagPicker(
                  selectedTags: selectedTags,
                  onChanged: (tags) => setDialogState(() => selectedTags = tags),
                ),
              ],
            )),
          );
        },
      ),
    );

    // Capture text before disposal — the bottom sheet dismiss animation
    // may still reference the controller for one more frame.
    final descText = descController.text.trim();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      descController.dispose();
    });

    if (result != true) return;

    final ok = await _community.updatePublication(
      pub.id,
      description: descText,
      tags: selectedTags.join(','),
    );

    if (mounted) {
      if (ok) {
        AppSnackbar.success(context, l10n.communityEditSuccess);
        _load();
      } else {
        AppSnackbar.error(context, l10n.communityEditFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final progress = publishProgressNotifier.value;

    final isUploading = progress != null && progress.status != 'done' && progress.status != 'error';
    final updateAll = updateAllProgressNotifier.value;
    final updatingAll = activeUpdateAll != null;
    final busy = isUploading || updatingAll;
    final changedCount = _changedCount;

    // Desktop: "Publish" is a header action, not a floating button.
    final desktop = Responsive.isDesktopLayout(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.communityMyPublications),
        actions: [
          if (desktop)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                onPressed: busy ? null : () => context.push('/community/publish').then((_) { if (mounted) _load(); }),
                icon: Icon(isUploading ? Icons.hourglass_top : Icons.publish, size: 18),
                label: Text(isUploading ? l10n.communityUploading : l10n.communityPublish),
              ),
            ),
        ],
      ),
      floatingActionButton: _fabVisible && !desktop
          ? FloatingActionButton.extended(
              onPressed: busy ? null : () => context.push('/community/publish').then((_) { if (mounted) _load(); }),
              icon: Icon(isUploading ? Icons.hourglass_top : Icons.publish),
              label: Text(isUploading ? l10n.communityUploading : l10n.communityPublish),
              backgroundColor: busy ? theme.colorScheme.surfaceContainerHighest : null,
              foregroundColor: busy ? theme.colorScheme.outline : null,
            )
          : null,
      body: Responsive.constrainWidth(context, child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Active upload progress banner
          if (progress != null && progress.status != 'done' && progress.status != 'error')
            _UploadProgressBanner(progress: progress),

          // Update all: its progress or summary, else the offer to run it.
          if (updateAll != null)
            _UpdateAllPanel(
              progress: updateAll,
              onStop: _stopUpdateAll,
              onClose: () => updateAllProgressNotifier.value = null,
            )
          else if (changedCount > 0)
            _UpdateAllBar(
              count: changedCount,
              // Ready once every publication was looked at, so the count
              // the confirmation shows is the whole of it.
              onPressed: busy || _checking ? null : _updateAllChanged,
            )
          else if (_checking && _checkTotal > 1)
            _CheckingLine(checked: _checked, total: _checkTotal),

          Expanded(
            child: _pubs.isEmpty && _loadFailed
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_rounded, size: 48, color: theme.colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      l10n.communityLoadFailed,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.actionRetry),
                    ),
                  ],
                ),
              ),
            )
                : _pubs.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AuthService.instance.isSignedIn ? Icons.upload_outlined : Icons.login,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AuthService.instance.isSignedIn
                        ? l10n.communityNoPublicationsYet
                        : l10n.communitySignInToPublish,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      AuthService.instance.isSignedIn
                          ? l10n.communityNoPublicationsMessage
                          : l10n.communitySignInToPublishMessage,
                      style: TextStyle(color: theme.colorScheme.outline),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: () async => _load(),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: _pubs.length + (_pubs.length < 5 ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if (i < _pubs.length) {
                    return _PublicationCard(
                      pub: _pubs[i],
                      changed: _changes[_pubs[i].id] == PublicationChange.changed,
                      onUnpublish: () => _confirmUnpublish(_pubs[i]),
                      onEdit: () => _editPublication(_pubs[i]),
                      onRepublish: updatingAll ? null : () => _republish(_pubs[i]),
                    );
                  }
                  // "Publish another" nudge
                  return GestureDetector(
                    onTap: () => context.push('/community/publish'),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.communityPublishAnotherCookbook,
                                    style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                                const SizedBox(height: 4),
                                Text(l10n.communityShareMoreWithCommunity,
                                    style: TextStyle(fontSize: 13, color: theme.colorScheme.outline)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.amber.shade600),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      )),
    );
  }
}

// ════════════════════════════════════════════
//  UPLOAD PROGRESS BANNER
// ════════════════════════════════════════════

class _UploadProgressBanner extends StatelessWidget {
  final PublishProgress progress;
  const _UploadProgressBanner({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    String message;
    switch (progress.status) {
      case 'preparing':
        message = l10n.communityPublishPreparing;
        break;
      case 'uploading':
        message = l10n.communityPublishUploading(progress.uploadedImages, progress.totalImages);
        break;
      case 'publishing':
        message = l10n.communityPublishPublishing;
        break;
      default:
        message = l10n.communityPublishPreparing;
    }

    final progressValue = progress.totalImages > 0
        ? progress.uploadedImages / progress.totalImages
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Row(
        children: [
          SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: progressValue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(l10n.communityPublishBackground, style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  PUBLICATION CARD (vertical layout)
// ════════════════════════════════════════════

class _PublicationCard extends StatelessWidget {
  final MyPublication pub;
  final VoidCallback onUnpublish;
  final VoidCallback onEdit;

  /// Null while an Update all runs (the button shows, disabled).
  final VoidCallback? onRepublish;

  /// The local cookbook changed since this was published.
  final bool changed;

  const _PublicationCard({
    required this.pub,
    required this.onUnpublish,
    required this.onEdit,
    this.onRepublish,
    this.changed = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outline.withValues(alpha: 0.35), width: 1),
      ),
      color: colors.surfaceRaised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Cover: 16:9, scrim, no text on it (community handoff) ──
          CommunityMedia.banner(
            publicationId: pub.id,
            imagePath: pub.imagePath,
            memCacheWidth: 900,
            overlays: [
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xA80B0B0C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        pub.isSingleRecipe ? Icons.restaurant_menu : Icons.menu_book,
                        size: 12, color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pub.isSingleRecipe ? l10n.communityKindRecipe : l10n.communityKindCookbook,
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Content below cover ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title + state chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        pub.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17, height: 1.25,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _StateChip(status: pub.status),
                  ],
                ),
                const SizedBox(height: 4),

                // Subtitle: last-updated relative time, and a marker when the
                // local cookbook changed since it was published.
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        l10n.publicationUpdatedAgo(timeago.format(pub.createdAt)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: colors.textTertiary),
                      ),
                    ),
                    if (changed) ...[
                      const SizedBox(width: 8),
                      const _ChangedChip(),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Stats strip: recipes / saves / rating (Not rated when none).
                _StatsStrip(pub: pub),
                const SizedBox(height: 12),

                // Edit (secondary) + Push update (primary), stroked icons only.
                // Distinct outcomes: Edit changes cookbook details; Push update
                // republishes the recipe content while keeping stats stable.
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: Text(l10n.actionEdit),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.textPrimary,
                            side: BorderSide(color: colors.outline),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                    ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: FilledButton.icon(
                            onPressed: onRepublish,
                            icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                            label: Text(l10n.publicationPushUpdate),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Unpublish: the only destructive control, the only red thing,
                // and the only one that opens a confirmation.
                SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: onUnpublish,
                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                    label: Text(l10n.communityUnpublish),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.destructive,
                      side: BorderSide(color: colors.destructive.withValues(alpha: 0.38)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),

                // Moderation notice (informational text, not a control)
                if (pub.status == 'pending_review' || pub.status == 'removed') ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.destructive.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pub.status == 'pending_review'
                          ? l10n.communityUnderReview
                          : l10n.communityRemovedByModerator,
                      style: TextStyle(fontSize: 12, color: colors.destructive),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ════════════════════════════════════════════
//  STATS STRIP (recipes / saves / rating)
// ════════════════════════════════════════════

/// Three cells in a bordered box (community handoff). A missing rating reads
/// "Not rated", never a dash or a zero.
class _StatsStrip extends StatelessWidget {
  final MyPublication pub;
  const _StatsStrip({required this.pub});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            _cell('${pub.recipeCount}', l10n.publicationStatRecipes),
            _divider(colors),
            _cell('${pub.downloadCount}', l10n.publicationStatSaves),
            _divider(colors),
            pub.ratingCount > 0
                ? _cell(pub.averageRating.toStringAsFixed(1), l10n.publicationStatRating)
                : _cell(l10n.publicationNotRated, '', small: true),
          ],
        ),
      ),
    );
  }

  Widget _divider(AppColors colors) =>
      VerticalDivider(width: 1, color: colors.outline.withValues(alpha: 0.35));

  Widget _cell(String value, String label, {bool small = false}) {
    return Expanded(
      child: Builder(builder: (context) {
        final colors = context.appColors;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: small ? 13 : 17,
                  fontWeight: FontWeight.w600,
                  color: small ? colors.textSecondary : colors.textPrimary,
                ),
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(label, style: TextStyle(fontSize: 11, color: colors.textTertiary)),
              ],
            ],
          ),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════
//  STATE CHIP (status ramp: green live, grey pending/draft)
// ════════════════════════════════════════════

/// Status gets its own ramp (community handoff): green means live, grey means
/// pending. Orange is never a status. Fixed colours across themes so a status
/// reads the same everywhere.
class _StateChip extends StatelessWidget {
  final String status;
  const _StateChip({required this.status});

  static const _liveBg = Color(0x295F8F5C);
  static const _liveBorder = Color(0x575F8F5C);
  static const _liveText = Color(0xFF8FC98B);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    late final Color bg, border, text;
    late final String label;
    switch (status) {
      case 'published':
        bg = _liveBg; border = _liveBorder; text = _liveText;
        label = l10n.publicationStateLive;
        break;
      case 'removed':
        bg = colors.destructive.withValues(alpha: 0.14);
        border = colors.destructive.withValues(alpha: 0.34);
        text = colors.destructive;
        label = l10n.communityStatusRemoved;
        break;
      default:
        bg = colors.surfaceHigh;
        border = colors.outline.withValues(alpha: 0.4);
        text = colors.textSecondary;
        label = l10n.publicationStatePending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6,
              decoration: BoxDecoration(color: text, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(fontSize: 11, height: 1.5, fontWeight: FontWeight.w600,
                  color: text, letterSpacing: 0.3)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  CHANGED SINCE PUBLISHED
// ════════════════════════════════════════════

/// Small marker on a row whose local cookbook changed since it was published.
/// Neutral like the pending chip; the accent dot ties it to Push update.
class _ChangedChip extends StatelessWidget {
  const _ChangedChip();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        border: Border.all(color: colors.outline.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6,
              decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(
            l10n.publicationChanged,
            style: TextStyle(fontSize: 11, height: 1.4, fontWeight: FontWeight.w600, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Shown while the publications are compared with their cookbooks.
class _CheckingLine extends StatelessWidget {
  final int checked;
  final int total;
  const _CheckingLine({required this.checked, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          SizedBox(
            width: 14, height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: colors.textTertiary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.publicationsUpdateAllChecking(checked, total),
              style: TextStyle(fontSize: 12, color: colors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

/// "N cookbooks changed" with the Update all changed button. One row on
/// desktop; the button goes full width under the text on a phone.
class _UpdateAllBar extends StatelessWidget {
  final int count;
  final VoidCallback? onPressed;
  const _UpdateAllBar({required this.count, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final desktop = Responsive.isDesktopLayout(context);

    final text = Row(
      children: [
        Icon(Icons.edit_note, size: 20, color: colors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            l10n.publicationsChangedCount(count),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary),
          ),
        ),
      ],
    );
    final button = FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.cloud_upload_outlined, size: 18),
      label: Text(l10n.publicationsUpdateAllChanged),
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        border: Border.all(color: colors.outline.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: desktop
          ? Row(
              children: [
                Expanded(child: text),
                const SizedBox(width: 12),
                SizedBox(height: 40, child: button),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                text,
                const SizedBox(height: 10),
                SizedBox(height: 44, child: button),
              ],
            ),
    );
  }
}

/// An Update all in progress (cookbook n of N, its photos, Stop), or how it
/// went once it is over (Close).
class _UpdateAllPanel extends StatelessWidget {
  final UpdateAllProgress progress;
  final VoidCallback onStop;
  final VoidCallback onClose;
  const _UpdateAllPanel({required this.progress, required this.onStop, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        border: Border.all(color: colors.outline.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: progress.finished ? _summary(context) : _running(context),
    );
  }

  Widget _running(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final publish = progress.publish;

    String? step;
    if (publish != null) {
      if (publish.waitSeconds > 0) {
        step = l10n.communityPublishRateLimitWait(publish.waitSeconds);
      } else {
        switch (publish.status) {
          case 'uploading':
            step = publish.totalImages > 0
                ? l10n.communityPublishUploading(publish.uploadedImages, publish.totalImages)
                : l10n.communityPublishPreparing;
          case 'publishing':
          case 'done':
            step = l10n.communityPublishPublishing;
          case 'error':
            step = publish.errorMessage;
          default:
            step = l10n.communityPublishPreparing;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: colors.accent),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.publicationsUpdateAllTitle,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    progress.checking
                        ? l10n.publicationsUpdateAllChecking(progress.current, progress.total)
                        : l10n.publicationsUpdateAllCurrent(progress.current, progress.total),
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                  if (!progress.checking && progress.title != null)
                    Text(
                      progress.title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary),
                    ),
                  if (step != null)
                    Text(step, style: TextStyle(fontSize: 12, color: colors.textTertiary)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: progress.stopping ? null : onStop,
              style: TextButton.styleFrom(foregroundColor: colors.destructive),
              child: Text(progress.stopping ? l10n.publicationsUpdateAllStopping : l10n.publicationsUpdateAllStop),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: progress.fraction, minHeight: 4),
        ),
      ],
    );
  }

  Widget _summary(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final s = progress.summary!;
    final lineStyle = TextStyle(fontSize: 13, color: colors.textSecondary);
    final nothingToDo = s.updated.isEmpty && s.failed.isEmpty && s.notRun.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              s.stopped || s.stopReason != null ? Icons.info_outline : Icons.check_circle_outline,
              size: 20,
              color: s.failed.isEmpty ? colors.accent : colors.destructive,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                s.stopped || s.stopReason != null ? l10n.publicationsUpdateAllStopped : l10n.publicationsUpdateAllDone,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
              ),
            ),
            TextButton(onPressed: onClose, child: Text(l10n.actionClose)),
          ],
        ),
        if (s.stopReason != null) ...[
          const SizedBox(height: 4),
          Text(s.stopReason!, style: TextStyle(fontSize: 13, color: colors.destructive)),
        ],
        const SizedBox(height: 6),
        if (s.updated.isNotEmpty) Text(l10n.publicationsUpdateAllUpdated(s.updated.length), style: lineStyle),
        if (s.unchanged > 0) Text(l10n.publicationsUpdateAllUnchanged(s.unchanged), style: lineStyle),
        if (nothingToDo && !s.stopped) Text(l10n.publicationsUpdateAllNothing, style: lineStyle),
        if (s.noSource > 0) ...[
          const SizedBox(height: 4),
          Text(l10n.publicationsUpdateAllNoSource(s.noSource), style: lineStyle),
        ],
        if (s.failed.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.publicationsUpdateAllFailed(s.failed.length),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.destructive),
          ),
          const SizedBox(height: 2),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final f in s.failed)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: f.title,
                            style: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
                          ),
                          TextSpan(text: '\n${f.reason}'),
                        ]),
                        style: lineStyle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        if (s.notRun.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(l10n.publicationsUpdateAllNotRun(s.notRun.length), style: lineStyle),
        ],
      ],
    );
  }
}
