import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../database/database.dart';
import '../../../database/daos/tags_dao.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../services/community_photo_uploader.dart';
import '../../../services/community_publish_pipeline.dart';
import '../../../services/community_service.dart';
import '../../widgets/app_snackbar.dart';
import '../../../utils/platform_utils.dart' show supportsFirebaseMessaging;
import '../../../utils/responsive_utils.dart';
import '../../widgets/community_tag_picker.dart';
import '../../widgets/sub_recipe_selection_sheet.dart';

// ════════════════════════════════════════════
//  PUBLISH SCREEN — Select cookbook → Configure → Publish
// ════════════════════════════════════════════

class CommunityPublishScreen extends ConsumerStatefulWidget {
  /// When non-null, the publish flow runs in single-recipe mode: the
  /// cookbook picker is skipped, the recipe is loaded by ID, and the
  /// resulting publication is created with kind='recipe'.
  final String? singleRecipeId;

  /// When non-null, the flow runs in *republish* mode: the user picks
  /// a cookbook (or had a single recipe selected) and on submit we
  /// call PUT /community/:id/recipes instead of POST /community.
  /// Stats stay intact; only recipe content changes.
  final String? republishPublicationId;

  /// When republishing a *cookbook* whose source is known, the cookbook
  /// to pre-select (skips the picker). Ignored unless
  /// [republishPublicationId] is also set.
  final String? republishCookbookId;

  /// A cookbook to start a new publish on (skips the picker), as when
  /// publishing from the cookbook's own menu.
  final String? cookbookId;

  const CommunityPublishScreen({
    super.key,
    this.singleRecipeId,
    this.republishPublicationId,
    this.republishCookbookId,
    this.cookbookId,
  });

  @override
  ConsumerState<CommunityPublishScreen> createState() => _CommunityPublishScreenState();
}

class _CommunityPublishScreenState extends ConsumerState<CommunityPublishScreen> {
  // Step 1: selected cookbook, Step 2: configure, Step 3: publishing.
  // Single-recipe mode skips Step 1.
  int _step = 1;
  Cookbook? _selectedCookbook;
  int _recipeCount = 0;
  // Set when widget.singleRecipeId is provided. Loaded in initState.
  Recipe? _singleRecipe;

  // Step 2 fields
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  List<String> _selectedTags = [];
  bool _includeImages = true;
  // The person's own notes on each recipe stay private unless they say so.
  bool _includeNotes = false;

  // Step 3 state
  bool _isPublishing = false;
  // The publish that is running. Cancel marks only this token, and every
  // run checks its own, so an older run can never publish after a cancel.
  PublishRunToken? _run;
  // What the last run was publishing, kept for "Retry failed photos".
  PreparedPublish? _prepared;

  bool get _isSingleRecipeMode => widget.singleRecipeId != null;

  @override
  void initState() {
    super.initState();
    final republishing = widget.republishPublicationId;
    if (republishing != null) {
      // An update starts from the choices the last publish made.
      PublishSnapshot.lookup(republishing).then((snapshot) {
        if (!mounted || snapshot == null) return;
        setState(() {
          _includeImages = snapshot.includeImages;
          _includeNotes = snapshot.includeNotes;
        });
      });
    }
    if (_isSingleRecipeMode) {
      // Load the recipe and jump straight to step 2.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final recipe = await ref.read(recipeDaoProvider).getRecipeById(widget.singleRecipeId!);
        if (!mounted) return;
        if (recipe == null) {
          AppSnackbar.error(context, AppLocalizations.of(context)!.errorGeneric);
          Navigator.pop(context);
          return;
        }
        setState(() {
          _singleRecipe = recipe;
          _recipeCount = 1; // single-recipe mode — summary would show 0 otherwise
          _titleController.text = recipe.title;
          _descController.text = recipe.description ?? '';
          _step = 2;
        });
      });
    } else if ((widget.cookbookId ?? widget.republishCookbookId) != null) {
      // Republishing a cookbook with a known source — pre-select it so
      // the user doesn't re-pick (and can't pick the wrong one). If the
      // cookbook was deleted since publishing, silently fall back to the
      // picker (we just stay on step 1).
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final cb = await ref.read(cookbookDaoProvider).getCookbookById((widget.cookbookId ?? widget.republishCookbookId)!);
        if (!mounted || cb == null) return;
        _selectCookbook(cb);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);

    if (!auth.isSignedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.communityPublishCookbook)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.login, size: 48, color: theme.colorScheme.outline),
                const SizedBox(height: 16),
                Text(l10n.communitySignInToPublish, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(l10n.communitySignInToPublishMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.outline)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.push('/settings'),
                  child: Text(l10n.communityGoToSettings),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // In single-recipe mode there's no cookbook-picker step, so the
    // step indicator is simpler (configure → publish).
    final totalSteps = _isSingleRecipeMode ? 2 : 3;
    final displayStep = _isSingleRecipeMode ? (_step - 1).clamp(1, 2) : _step;

    return PopScope(
      canPop: true,
      child: Scaffold(
      appBar: AppBar(
        title: Text(_step == 1
            ? l10n.communityPublishCookbook
            : (_isSingleRecipeMode ? l10n.publishSingleRecipeTitle : l10n.communityConfigurePublication)),
        // Back: only show if we can return to step 1 (NOT in single-recipe mode).
        leading: _step > 1 && !_isPublishing && !_isSingleRecipeMode
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _step = 1))
            : null,
        bottom: _isPublishing ? null : PreferredSize(
          preferredSize: const Size.fromHeight(48),
          // On desktop the steps line up with the form column below.
          child: Responsive.isDesktopLayout(context)
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: Responsive.kReadingMaxWidth),
                    child: _StepIndicator(currentStep: displayStep, totalSteps: totalSteps),
                  ),
                )
              : _StepIndicator(currentStep: displayStep, totalSteps: totalSteps),
        ),
      ),
      body: Responsive.constrainWidth(context, maxWidth: Responsive.isDesktopLayout(context) ? Responsive.kReadingMaxWidth : null, child: _step == 1
          ? _buildStep1CookbookSelection(theme, l10n)
          : _step == 2
          ? _buildStep2Configure(theme, l10n)
          : _buildStep3Publishing(theme, l10n)),
    ));
  }

  // ── Step 1: Select cookbook ──

  Widget _buildStep1CookbookSelection(ThemeData theme, AppLocalizations l10n) {
    final cookbooksAsync = ref.watch(cookbooksProvider);

    return cookbooksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.errorWithMessage(e.toString()))),
      data: (cookbooks) {
        if (cookbooks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_outlined, size: 48, color: theme.colorScheme.outline),
                const SizedBox(height: 16),
                Text(l10n.communityNoCookbooksToPublish, style: theme.textTheme.titleMedium),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    l10n.communityPublishInfo,
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                  )),
                ],
              ),
            ),

            // Active upload warning
            ValueListenableBuilder<PublishProgress?>(
              valueListenable: publishProgressNotifier,
              builder: (ctx, progress, _) {
                if (progress != null && (progress.status == 'uploading' || progress.status == 'publishing')) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(
                          l10n.communityPublishUploadInProgress(progress.uploadedImages, progress.totalImages),
                          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                        )),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            Text(l10n.communitySelectCookbook, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ...cookbooks.map((cb) => _CookbookSelectTile(
              cookbook: cb,
              onSelect: () => _selectCookbook(cb),
            )),
          ],
        );
      },
    );
  }

  Future<void> _selectCookbook(Cookbook cookbook) async {
    final l10n = AppLocalizations.of(context)!;
    final count = await ref.read(recipeDaoProvider).getRecipeCountForCookbook(cookbook.id);

    if (count < kMinPublishRecipes) {
      if (mounted) AppSnackbar.error(context, l10n.communityNeedMinRecipes(count));
      return;
    }

    _titleController.text = cookbook.name;
    _descController.text = cookbook.description ?? '';

    setState(() {
      _selectedCookbook = cookbook;
      _recipeCount = count;
      _step = 2;
    });
  }

  // ── Step 2: Configure ──

  Widget _buildStep2Configure(ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Title
        Text(l10n.communityPublishTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: l10n.communityPublishTitleHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 16),

        // Description
        Text(l10n.communityPublishDescription, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _descController,
          maxLines: 3,
          maxLength: 2000,
          decoration: InputDecoration(
            hintText: l10n.communityPublishDescriptionHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 16),

        // Tags
        Text(l10n.communityPublishTags, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        CommunityTagPicker(
          selectedTags: _selectedTags,
          onChanged: (tags) => setState(() => _selectedTags = tags),
        ),

        const SizedBox(height: 16),

        // Include images toggle
        Card(
          child: SwitchListTile(
            title: Text(l10n.communityPublishIncludeImages, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
              l10n.communityPublishIncludeImagesSubtitle,
              style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
            ),
            value: _includeImages,
            onChanged: (v) => setState(() => _includeImages = v),
            secondary: const Icon(Icons.image_outlined),
          ),
        ),

        // Include my notes (off unless the person turns it on)
        Card(
          child: SwitchListTile(
            title: Text(l10n.communityPublishIncludeNotes, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
              l10n.communityPublishIncludeNotesSubtitle,
              style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
            ),
            value: _includeNotes,
            onChanged: (v) => setState(() => _includeNotes = v),
            secondary: const Icon(Icons.sticky_note_2_outlined),
          ),
        ),

        const SizedBox(height: 8),

        // Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.communityPublishSummary, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _SummaryRow(icon: Icons.restaurant_menu, label: l10n.communityPublishRecipesSummary(_recipeCount)),
                if (_selectedTags.isNotEmpty)
                  _SummaryRow(icon: Icons.tag, label: l10n.communityTagsSummary(_selectedTags.length)),
                _SummaryRow(
                  icon: Icons.image,
                  label: _includeImages ? l10n.communityPublishImagesWillUpload : l10n.communityPublishTextOnlyNoImages,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Publish button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: _isPublishing ? null : _startPublish,
            icon: const Icon(Icons.publish),
            label: Text(l10n.communityPublish),
          ),
        ),
      ],
    );
  }

  // ── Step 3: Publishing (progress) ──

  Widget _buildStep3Publishing(ThemeData theme, AppLocalizations l10n) {
    // Once it is out, offer download notifications (push is mobile only).
    final offerNotifications = supportsFirebaseMessaging &&
        !ref.watch(notificationPrefsProvider).communityUpdates;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ValueListenableBuilder<PublishProgress?>(
          valueListenable: publishProgressNotifier,
          builder: (ctx, progress, _) {
            final status = progress?.status ?? 'preparing';
            final rejected = progress?.rejectedRecipes ?? const <String>[];
            final unsupported = progress?.unsupportedRecipes ?? const <String>[];
            final failed = progress?.failedRecipes ?? const <String>[];
            final waitSeconds = progress?.waitSeconds ?? 0;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status == 'done') ...[
                  Icon(Icons.check_circle, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(l10n.communityPublishDone, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  if (rejected.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.communityPublishPhotosRejected(progress!.skippedImages),
                      style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    _RecipeTitleList(titles: rejected),
                  ],
                  if (unsupported.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.communityPublishPhotosUnsupported,
                      style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    _RecipeTitleList(titles: unsupported),
                  ],
                  if (offerNotifications) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _turnOnDownloadNotifications,
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: Text(l10n.notifDownloadsOffer),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(onPressed: () => context.pop(), child: Text(l10n.actionDone)),
                ] else if (status == 'error' && failed.isNotEmpty) ...[
                  // Photos that did not upload: nothing was published, and
                  // a retry only sends what is not on the server yet.
                  Icon(Icons.cloud_off_outlined, size: 64, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(l10n.communityPublishPhotosFailedTitle,
                      style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(l10n.communityPublishPhotosFailedBody,
                      style: TextStyle(color: theme.colorScheme.outline), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  _RecipeTitleList(titles: failed),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _prepared == null ? null : () => _runPublish(_prepared!),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.communityRetryFailedPhotos),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: () => setState(() { _step = 2; _isPublishing = false; }), child: Text(l10n.communityPublishTryAgain)),
                ] else if (status == 'error') ...[
                  Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(l10n.communityPublishFailed, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(progress?.errorMessage ?? l10n.communityUnknownError,
                      style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton(onPressed: () => setState(() { _step = 2; _isPublishing = false; }), child: Text(l10n.communityPublishTryAgain)),
                ] else ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    status == 'preparing'
                        ? l10n.communityPublishPreparing
                        : status == 'uploading'
                        ? l10n.communityPublishUploading(progress?.uploadedImages ?? 0, progress?.totalImages ?? 0)
                        : l10n.communityPublishPublishing,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (status == 'uploading' && (progress?.totalImages ?? 0) > 0) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (progress?.uploadedImages ?? 0) / (progress?.totalImages ?? 1),
                    ),
                    const SizedBox(height: 8),
                    if (waitSeconds > 0)
                      Text(
                        l10n.communityPublishRateLimitWait(waitSeconds),
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                        textAlign: TextAlign.center,
                      ),
                    if ((progress?.skippedImages ?? 0) > 0)
                      Text(
                        l10n.communityPublishRejected(progress!.skippedImages),
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.error),
                      ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    l10n.communityPublishBackground,
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                    textAlign: TextAlign.center,
                  ),
                  if (status == 'uploading' && _run != null) ...[
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        _run?.cancel();
                        setState(() {
                          _run = null;
                          _isPublishing = false;
                        });
                        publishProgressNotifier.value = PublishProgress(
                          status: 'error',
                          errorMessage: l10n.communityUploadCancelled,
                        );
                        AppSnackbar.info(context, l10n.communityUploadCancelled);
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: Text(l10n.communityCancelUpload),
                      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                    ),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  /// Asked only when the user taps the offer: the system prompt (Android 13+,
  /// iOS) then registers this device for download notifications.
  Future<void> _turnOnDownloadNotifications() async {
    final l10n = AppLocalizations.of(context)!;
    var ok = false;
    try {
      ok = await ref.read(notificationPrefsProvider.notifier).setCommunityUpdates(true);
    } catch (e) {
      debugPrint('[Publish] Could not turn on notifications: $e');
    }
    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, l10n.notifDownloadsOn);
    } else {
      AppSnackbar.info(context, l10n.notifPermissionDenied);
    }
  }

  CommunityPublishPipeline _pipeline() => CommunityPublishPipeline(
        recipeDao: ref.read(recipeDaoProvider),
        tagsDao: TagsDao(ref.read(databaseProvider)),
      );

  Future<void> _startPublish() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    publishProgressNotifier.value = const PublishProgress(status: 'preparing');

    final recipeDao = ref.read(recipeDaoProvider);
    final pipeline = _pipeline();
    var recipes = _isSingleRecipeMode
        ? <Recipe>[_singleRecipe!]
        : await recipeDao.getRecipesForCookbook(_selectedCookbook!.id);

    // ── Cross-cookbook sub-recipe detection ──
    // Find any sub-recipes that live in OTHER cookbooks. Without including
    // them, those links will break in the published version.
    // (Skipped in single-recipe mode — sub-recipe handling there is too
    // confusing for the streamlined UX. The recipe gets published with
    // any cross-cookbook links broken; user can re-publish as a cookbook
    // if they need full link integrity.)
    final externalSubRecipeIds = _isSingleRecipeMode
        ? <String>{}
        : await pipeline.externalSubRecipeIds(recipes);
    // The ones the person kept, remembered for later updates.
    final includedExternalIds = <String>[];

    // If there are cross-cookbook sub-recipes, ask the user which to include
    if (externalSubRecipeIds.isNotEmpty && mounted) {
      final selection = await showSubRecipeSelectionSheetMulti(
        context: context,
        ref: ref,
        // Use the cookbook's recipes as the "parents" — the sheet will surface
        // their cross-cookbook sub-recipes as the unchecked-by-default extras.
        parentRecipeIds: recipes.map((r) => r.id).toList(),
        action: SubRecipeAction.publish,
      );
      if (selection == null || !selection.confirmed) {
        // User cancelled — abort publish
        return;
      }

      // Add any external sub-recipes the user kept selected to the publish list.
      // Recipes already in the cookbook are always included regardless.
      final extrasToInclude = <Recipe>[];
      for (final extId in externalSubRecipeIds) {
        if (selection.selectedIds.contains(extId)) {
          final extRecipe = await recipeDao.getRecipeById(extId);
          if (extRecipe != null) {
            extrasToInclude.add(extRecipe);
            includedExternalIds.add(extId);
          }
        }
      }
      if (extrasToInclude.isNotEmpty) {
        recipes = [...recipes, ...extrasToInclude];
      }
    }

    if (!mounted) return;
    setState(() { _isPublishing = true; _step = 3; });

    final PreparedPublish job;
    try {
      job = await pipeline.prepare(
        recipes: recipes,
        title: title,
        description: _descController.text.trim(),
        tags: _selectedTags,
        includeImages: _includeImages,
        includeNotes: _includeNotes,
        kind: _isSingleRecipeMode ? 'recipe' : 'cookbook',
        sourceId: _isSingleRecipeMode ? _singleRecipe!.id : _selectedCookbook!.id,
        // For cookbook mode use the cookbook cover; for single-recipe mode
        // the recipe's own image.
        coverPath: _isSingleRecipeMode ? _singleRecipe!.imagePath : _selectedCookbook!.imagePath,
        coverCloudPath: _isSingleRecipeMode ? null : _selectedCookbook!.imageServerPath,
        sourceName: _isSingleRecipeMode ? null : _selectedCookbook!.name,
        externalRecipeIds: externalSubRecipeIds.toList(),
        includedExternalIds: includedExternalIds,
      );
      // Auto-suggested (or trimmed to 5) tags show if the person goes back.
      _selectedTags = job.tagList;
    } catch (e) {
      publishProgressNotifier.value = PublishProgress(status: 'error', errorMessage: e.toString());
      return;
    }

    _prepared = job;
    await _runPublish(job);
  }

  /// Uploads [job]'s photos (skipping ones already on the server) and
  /// publishes. Runs again as-is for "Retry failed photos".
  Future<void> _runPublish(PreparedPublish job) async {
    final l10n = AppLocalizations.of(context)!;
    _run?.cancel();
    final run = PublishRunToken();
    _run = run;

    if (mounted) setState(() { _isPublishing = true; _step = 3; });

    final result = await _pipeline().run(
      job,
      token: run,
      l10n: l10n,
      republishPublicationId: widget.republishPublicationId,
      onProgress: (p) {
        if (identical(_run, run)) publishProgressNotifier.value = p;
      },
    );
    if (!result.success || !mounted) return;

    if (widget.republishPublicationId != null) {
      AppSnackbar.success(context, l10n.communityRepublishSuccess);
    } else if (result.status == 'pending_review') {
      // Show under-review notice if flagged
      AppSnackbar.warning(context, l10n.communityPublishUnderReview);
    }
  }
}

/// A short scrollable list of recipe titles on the result screen.
class _RecipeTitleList extends StatelessWidget {
  final List<String> titles;
  const _RecipeTitleList({required this.titles});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 180),
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (final t in titles)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(t, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  SUB-WIDGETS
// ════════════════════════════════════════════

class _CookbookSelectTile extends ConsumerWidget {
  final Cookbook cookbook;
  final VoidCallback onSelect;

  const _CookbookSelectTile({required this.cookbook, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<int>(
      future: ref.read(recipeDaoProvider).getRecipeCountForCookbook(cookbook.id),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        final canPublish = count >= kMinPublishRecipes;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              Icons.menu_book,
              color: canPublish ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
            title: Text(cookbook.name, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
              canPublish ? l10n.communityRecipeCount(count) : l10n.communityRecipeCountNeedMore(count),
              style: TextStyle(
                fontSize: 12,
                color: canPublish ? theme.colorScheme.outline : theme.colorScheme.error,
              ),
            ),
            trailing: Icon(
              canPublish ? Icons.chevron_right : null,
              color: theme.colorScheme.outline,
            ),
            onTap: canPublish ? onSelect : null,
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.outline),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  STEP INDICATOR
// ════════════════════════════════════════════

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (i) {
          if (i.isEven) {
            final step = i ~/ 2 + 1;
            final isActive = step <= currentStep;
            final isCurrent = step == currentStep;
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isActive ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: isCurrent ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.outline,
                  ),
                ),
              ),
            );
          } else {
            final beforeStep = i ~/ 2 + 1;
            final isActive = beforeStep < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: isActive ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
              ),
            );
          }
        }),
      ),
    );
  }
}
