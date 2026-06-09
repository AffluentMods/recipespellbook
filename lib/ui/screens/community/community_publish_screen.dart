import '../../../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/course_category_data.dart' as taxonomy;
import '../../../database/database.dart';
import '../../../database/daos/tags_dao.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/community_service.dart';
import '../../../services/image_service.dart';
import '../../widgets/app_snackbar.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/community_tag_picker.dart';
import '../../widgets/recipe_image.dart';
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

  const CommunityPublishScreen({
    super.key,
    this.singleRecipeId,
    this.republishPublicationId,
  });

  @override
  ConsumerState<CommunityPublishScreen> createState() => _CommunityPublishScreenState();
}

class _CommunityPublishScreenState extends ConsumerState<CommunityPublishScreen> {
  final _community = CommunityService.instance;

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

  // Step 3 state
  bool _isPublishing = false;
  bool _publishCancelled = false;

  bool get _isSingleRecipeMode => widget.singleRecipeId != null;

  @override
  void initState() {
    super.initState();
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
          _titleController.text = recipe.title;
          _descController.text = recipe.description ?? '';
          _step = 2;
        });
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
          child: _StepIndicator(currentStep: displayStep, totalSteps: totalSteps),
        ),
      ),
      body: Responsive.constrainWidth(context, child: _step == 1
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ValueListenableBuilder<PublishProgress?>(
          valueListenable: publishProgressNotifier,
          builder: (ctx, progress, _) {
            final status = progress?.status ?? 'preparing';

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status == 'done') ...[
                  Icon(Icons.check_circle, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(l10n.communityPublishDone, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  if ((progress?.skippedImages ?? 0) > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.communityPublishImagesSkipped(progress!.skippedImages),
                      style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(onPressed: () => context.pop(), child: Text(l10n.actionDone)),
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
                  if (status == 'uploading' && !_publishCancelled) ...[
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _publishCancelled = true;
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
                  if (_publishCancelled && status == 'uploading') ...[
                    const SizedBox(height: 16),
                    Text(l10n.communityCancelling, style: TextStyle(color: theme.colorScheme.outline)),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _startPublish() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    publishProgressNotifier.value = const PublishProgress(status: 'preparing');

    final recipeDao = ref.read(recipeDaoProvider);
    final tagsDao = TagsDao(ref.read(databaseProvider));
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
    final cookbookRecipeIds = recipes.map((r) => r.id).toSet();
    final externalSubRecipeIds = <String>{};
    if (!_isSingleRecipeMode) {
      for (final r in recipes) {
        final linked = await recipeDao.getLinkedRecipes(r.id);
        for (final sub in linked) {
          if (!cookbookRecipeIds.contains(sub.id)) {
            externalSubRecipeIds.add(sub.id);
          }
        }
      }
    }

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
          if (extRecipe != null) extrasToInclude.add(extRecipe);
        }
      }
      if (extrasToInclude.isNotEmpty) {
        recipes = [...recipes, ...extrasToInclude];
      }
    }

    setState(() { _isPublishing = true; _publishCancelled = false; _step = 3; });

    try {

      final recipeMaps = <Map<String, dynamic>>[];
      final localImagePaths = <String>[]; // Track all local paths for upload

      // Collect cookbook cover (only in cookbook mode — single-recipe
      // publications use the recipe's image as the cover).
      if (!_isSingleRecipeMode && _includeImages && _selectedCookbook!.imagePath != null) {
        localImagePaths.add(_selectedCookbook!.imagePath!);
      }

      // Build a map of recipe ID → index for recipe link references
      final recipeIdToIndex = <String, int>{};
      for (var i = 0; i < recipes.length; i++) {
        recipeIdToIndex[recipes[i].id] = i;
      }

      for (final r in recipes) {
        final ingredients = await recipeDao.getIngredientsForRecipe(r.id);
        final steps = await recipeDao.getStepsForRecipe(r.id);
        final tags = await tagsDao.getTagsForRecipe(r.id);

        // Track recipe image
        if (_includeImages && r.imagePath != null) {
          localImagePaths.add(r.imagePath!);
        }

        // Track step images
        for (final s in steps) {
          if (_includeImages && s.imagePath != null) {
            localImagePaths.add(s.imagePath!);
          }
        }

        // Gather recipe links (ingredient→sub-recipe references)
        final linksMap = await recipeDao.getIngredientLinksMap(r.id);
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
          'imagePath': r.imagePath, // Will be replaced with server path
          'categoryId': r.categoryId,
          'courseId': r.courseId,
          'rating': r.rating,
          'notes': r.notes,
          'nutritionJson': r.nutritionJson,
          'ingredients': ingredients.map((i) => {
            'sortOrder': i.sortOrder,
            'amount': i.amount,
            'unit': i.unit,
            'name': i.name,
            'notes': i.notes,
          }).toList(),
          'steps': steps.map((s) => {
            'sortOrder': s.sortOrder,
            'instruction': s.instruction,
            'durationMinutes': s.durationMinutes,
            'imagePath': s.imagePath, // Will be replaced with server path
          }).toList(),
          'tags': tags.map((t) => t.name).toList(),
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
      if (_selectedTags.isEmpty) {
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
          _selectedTags = sorted.take(5).map((e) => e.key).toList();
        }
      }

      // Enforce max 5 tags on cookbook level
      if (_selectedTags.length > 5) {
        _selectedTags = _selectedTags.take(5).toList();
      }

      // Enforce max 5 tags per recipe
      for (final rm in recipeMaps) {
        final recipeTags = rm['tags'] as List? ?? [];
        if (recipeTags.length > 5) {
          rm['tags'] = recipeTags.take(5).toList();
        }
      }

      // ── Upload images (if enabled) ──
      int totalImageBytes = 0;
      int skippedImages = 0;
      final pathMapping = <String, String>{}; // local path → server path

      if (_includeImages) {
        // Filter to unique existing local files
        final uniquePaths = localImagePaths.toSet().where((p) {
          return !ImageService.isServerPath(p) && FileExistsCache.exists(p);
        }).toList();

        publishProgressNotifier.value = PublishProgress(
          status: 'uploading',
          totalImages: uniquePaths.length,
        );

        const maxRetries = 3;
        for (int i = 0; i < uniquePaths.length; i++) {
          if (_publishCancelled) {
            publishProgressNotifier.value = PublishProgress(status: 'error', errorMessage: l10n.communityUploadCancelled);
            setState(() => _isPublishing = false);
            return;
          }
          final localPath = uniquePaths[i];

          // Retry up to maxRetries times for transient failures (e.g. app backgrounded)
          ImageUploadResult? result;
          for (int attempt = 1; attempt <= maxRetries; attempt++) {
            result = await ImageService.instance.communityUploadLocalPath(localPath);
            if (result != null) break;
            if (attempt < maxRetries) {
              debugPrint('[Publish] Image upload failed (attempt $attempt/$maxRetries), retrying in ${attempt * 2}s: $localPath');
              await Future.delayed(Duration(seconds: attempt * 2));
            }
          }

          if (result != null) {
            pathMapping[localPath] = result.path;
            totalImageBytes += File(localPath).lengthSync();
          } else {
            debugPrint('[Publish] Image skipped after $maxRetries attempts: $localPath');
            skippedImages++;
          }

          publishProgressNotifier.value = PublishProgress(
            status: 'uploading',
            uploadedImages: i + 1,
            totalImages: uniquePaths.length,
            skippedImages: skippedImages,
          );
        }
      }

      // ── Replace local paths with server paths ──
      // For cookbook mode use the cookbook cover; for single-recipe mode
      // fall back to the recipe's own image.
      String? cookbookImagePath = _isSingleRecipeMode
          ? _singleRecipe!.imagePath
          : _selectedCookbook!.imagePath;
      if (cookbookImagePath != null && pathMapping.containsKey(cookbookImagePath)) {
        cookbookImagePath = pathMapping[cookbookImagePath];
      } else if (_includeImages && cookbookImagePath != null && !ImageService.isServerPath(cookbookImagePath)) {
        cookbookImagePath = null; // Local path, not uploaded
      }

      for (final recipe in recipeMaps) {
        final rPath = recipe['imagePath'] as String?;
        if (rPath != null && pathMapping.containsKey(rPath)) {
          recipe['imagePath'] = pathMapping[rPath];
        } else if (_includeImages && rPath != null && !ImageService.isServerPath(rPath)) {
          recipe['imagePath'] = null;
        } else if (!_includeImages) {
          recipe['imagePath'] = null;
        }

        // Replace step image paths
        final steps = recipe['steps'] as List<Map<String, dynamic>>;
        for (final step in steps) {
          final sPath = step['imagePath'] as String?;
          if (sPath != null && pathMapping.containsKey(sPath)) {
            step['imagePath'] = pathMapping[sPath];
          } else if (!_includeImages || (sPath != null && !ImageService.isServerPath(sPath))) {
            step['imagePath'] = null;
          }
        }
      }

      // ── Publish ──
      publishProgressNotifier.value = PublishProgress(
        status: 'publishing',
        uploadedImages: pathMapping.length,
        totalImages: pathMapping.length,
        skippedImages: skippedImages,
      );

      // Republish-to-update branch: same upload pipeline, different
      // final API. Stats (downloads, ratings) stay attached to the
      // existing publication.
      if (widget.republishPublicationId != null) {
        final ok = await _community.replacePublicationRecipes(
          widget.republishPublicationId!,
          recipes: recipeMaps,
          imageCount: pathMapping.length,
          totalImageBytes: totalImageBytes,
          imagePath: cookbookImagePath,
        );
        if (ok) {
          publishProgressNotifier.value = PublishProgress(
            status: 'done',
            uploadedImages: pathMapping.length,
            totalImages: pathMapping.length,
            skippedImages: skippedImages,
            publicationId: widget.republishPublicationId,
          );
          if (mounted) {
            AppSnackbar.success(context, l10n.communityRepublishSuccess);
          }
        } else {
          publishProgressNotifier.value = PublishProgress(
            status: 'error',
            errorMessage: l10n.communityPublishingFailed,
          );
        }
        return;
      }

      final result = await _community.publish(
        title: title,
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        imagePath: cookbookImagePath,
        recipes: recipeMaps,
        imageCount: pathMapping.length,
        totalImageBytes: totalImageBytes,
        tags: _selectedTags.isNotEmpty ? _selectedTags.join(',') : null,
        kind: _isSingleRecipeMode ? 'recipe' : 'cookbook',
      );

      if (result.success) {
        publishProgressNotifier.value = PublishProgress(
          status: 'done',
          uploadedImages: pathMapping.length,
          totalImages: pathMapping.length,
          skippedImages: skippedImages,
          publicationId: result.publicationId,
        );

        // Show under-review notice if flagged
        if (result.status == 'pending_review' && mounted) {
          AppSnackbar.warning(context, 'Your cookbook is under review — it will be visible after approval.');
        }
      } else {
        publishProgressNotifier.value = PublishProgress(
          status: 'error',
          errorMessage: result.error ?? l10n.communityPublishingFailed,
        );
      }
    } catch (e) {
      publishProgressNotifier.value = PublishProgress(
        status: 'error',
        errorMessage: e.toString(),
      );
    }
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
