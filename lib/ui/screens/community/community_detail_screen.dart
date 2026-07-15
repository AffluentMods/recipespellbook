import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import '../../../data/community_tags_data.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/community_service.dart';
import '../../../services/image_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/community_image.dart';
import '../../widgets/community_tag_picker.dart';
import 'community_recipe_preview_dialog.dart';
import 'community_screen.dart'; // StarRating

// ════════════════════════════════════════════
//  COMMUNITY DETAIL — View, Rate & Download
// ════════════════════════════════════════════

class CommunityDetailScreen extends ConsumerStatefulWidget {
  final String publicationId;
  const CommunityDetailScreen({super.key, required this.publicationId});

  @override
  ConsumerState<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen> {
  final _community = CommunityService.instance;

  static String _resolveAvatarUrl(String avatarUrl) {
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) return avatarUrl;
    const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.recipespellbook.app');
    return '$apiUrl/v1/web/avatar/$avatarUrl';
  }

  CommunityDetail? _detail;
  bool _loading = true;
  bool _downloading = false;
  String _downloadStatus = '';

  // Selection mode
  bool _selectMode = false;
  final Set<int> _selectedIndices = {};

  // Rating
  int _myRating = 0;
  double _displayRating = 0;
  int _displayRatingCount = 0;
  bool _ratingLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final detail = await _community.getPublication(widget.publicationId);

    // Single-recipe publications skip the cookbook framing entirely:
    // open the recipe full-screen view instead of this detail screen.
    if (detail != null && detail.isSingleRecipe && detail.recipes.isNotEmpty && mounted) {
      // Use replace so back arrow returns to the feed, not this stub.
      context.pushReplacement('/community/${detail.id}/recipe/0');
      return;
    }

    if (mounted) {
      setState(() {
        _detail = detail;
        _loading = false;
        _displayRating = detail?.averageRating ?? 0;
        _displayRatingCount = detail?.ratingCount ?? 0;
      });
    }
    // Load user's own rating
    if (detail != null) {
      final myRating = await _community.getMyRating(widget.publicationId);
      if (mounted && myRating != null) {
        setState(() => _myRating = myRating);
      }
    }
  }

  Future<void> _rate(int stars) async {
    final l10n = AppLocalizations.of(context)!;
    if (_ratingLoading) return;
    setState(() {
      _ratingLoading = true;
      _myRating = stars; // Optimistic
    });

    final result = await _community.rate(widget.publicationId, stars);
    debugPrint('[Community] rate($stars) result: $result');
    if (mounted) {
      if (result != null) {
        setState(() {
          _displayRating = result.averageRating;
          _displayRatingCount = result.ratingCount;
          _myRating = result.yourRating;
        });
      } else {
        // Rating failed — revert optimistic update
        setState(() => _myRating = 0);
        AppSnackbar.error(context, l10n.communityFailedToSaveRating);
      }
      setState(() => _ratingLoading = false);
    }
  }

  Future<void> _download({
    bool withImages = true,
    Set<int>? selectedIndices,
    String? targetCookbookId,
  }) async {
    if (_downloading) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() { _downloading = true; _downloadStatus = l10n.communityDownloadingCookbook; _selectMode = false; _selectedIndices.clear(); });
    const uuid = Uuid();

    try {
      final result = await _community.download(widget.publicationId);
      if (result == null || result.recipes.isEmpty) {
        if (mounted) AppSnackbar.error(context, l10n.communityDownloadFailed);
        return;
      }

      // Filter to selected recipes if partial download.
      // Auto-include any sub-recipes referenced by the user's selection so links don't break.
      var effectiveSelection = selectedIndices;
      if (selectedIndices != null) {
        final expanded = Set<int>.from(selectedIndices);
        bool added = true;
        while (added) {
          added = false;
          for (final idx in expanded.toList()) {
            if (idx < 0 || idx >= result.recipes.length) continue;
            for (final link in result.recipes[idx].recipeLinks) {
              final subIdx = link.linkedRecipeIndex;
              if (subIdx >= 0 && subIdx < result.recipes.length && !expanded.contains(subIdx)) {
                expanded.add(subIdx);
                added = true;
              }
            }
          }
        }
        final extraCount = expanded.length - selectedIndices.length;
        if (extraCount > 0 && mounted) {
          // Quick confirmation — sub-recipes auto-included so links don't break
          final include = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              icon: const Icon(Icons.account_tree_outlined, size: 32),
              title: Text(l10n.communityDownloadIncludeSubRecipesTitle),
              content: Text(l10n.communityDownloadIncludeSubRecipesBody(extraCount)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.communityDownloadSkipSubRecipes),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.communityDownloadIncludeSubRecipes),
                ),
              ],
            ),
          );
          if (include == true) {
            effectiveSelection = expanded;
          }
        }
      }
      final recipesToDownload = effectiveSelection != null
          ? (effectiveSelection.toList()..sort())
          : List.generate(result.recipes.length, (i) => i);

      final db = ref.read(databaseProvider);
      final cookbookId = targetCookbookId ?? 'community_${uuid.v4()}';
      final totalRecipes = recipesToDownload.length;

      // --- Phase 1: Download images (before DB writes) ---
      final Map<int, String?> coverImages = {};
      final Map<int, List<String?>> stepImages = {};

      for (int idx = 0; idx < totalRecipes; idx++) {
        final i = recipesToDownload[idx];
        final recipe = result.recipes[i];
        if (mounted) setState(() => _downloadStatus = l10n.communityDownloadingImages(idx + 1, totalRecipes));

        // Cover image
        String? coverPath;
        if (withImages && recipe.imagePath != null && recipe.imagePath!.isNotEmpty) {
          try {
            final url = CommunityService.communityImageUrl(widget.publicationId, recipe.imagePath!);
            final filename = 'community_${widget.publicationId}_${uuid.v4()}_cover.jpg';
            coverPath = await ImageService.instance.downloadAndSaveImage(url, filename);
          } catch (_) { /* image fail is non-fatal */ }
        }
        coverImages[i] = coverPath;

        // Step images
        final List<String?> sImgs = [];
        for (final step in recipe.steps) {
          String? stepPath;
          if (withImages && step.imagePath != null && step.imagePath!.isNotEmpty) {
            try {
              final url = CommunityService.communityImageUrl(widget.publicationId, step.imagePath!);
              final filename = 'community_${widget.publicationId}_${uuid.v4()}_step${step.sortOrder}.jpg';
              stepPath = await ImageService.instance.downloadAndSaveImage(url, filename);
            } catch (_) { /* image fail is non-fatal */ }
          }
          sImgs.add(stepPath);
        }
        stepImages[i] = sImgs;
      }

      // --- Phase 2: Insert everything in a single transaction ---
      if (mounted) setState(() => _downloadStatus = l10n.communitySavingRecipes);

      await db.transaction(() async {
        // Create cookbook only if no target was specified
        if (targetCookbookId == null) {
          await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
            id: cookbookId,
            name: result.title,
            description: drift.Value(result.description),
          ));
        }

        // Track generated IDs for recipe link restoration
        // Maps original recipe index → new local recipe ID
        final recipeIdByIndex = <int, String>{};
        // Maps (original recipe index, ingredient index) → new local ingredient ID
        final ingredientIdByIndex = <String, String>{};

        for (final i in recipesToDownload) {
          final recipe = result.recipes[i];
          final recipeId = 'cr_${uuid.v4()}';
          recipeIdByIndex[i] = recipeId;

          // Insert recipe
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
            imagePath: drift.Value(coverImages[i]),
            lastViewedAt: drift.Value(DateTime.now()),
          ));

          // Insert ingredients
          for (var ingIdx = 0; ingIdx < recipe.ingredients.length; ingIdx++) {
            final ing = recipe.ingredients[ingIdx];
            final ingId = 'ci_${uuid.v4()}';
            ingredientIdByIndex['${i}_$ingIdx'] = ingId;
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

          // Insert steps
          for (int s = 0; s < recipe.steps.length; s++) {
            final step = recipe.steps[s];
            await db.into(db.steps).insert(StepsCompanion.insert(
              id: 'cs_${uuid.v4()}',
              recipeId: recipeId,
              sortOrder: step.sortOrder,
              instruction: step.instruction,
              durationMinutes: drift.Value(step.durationMinutes),
              imagePath: drift.Value(stepImages[i]?[s]),
            ));
          }

          // Insert recipe tags
          for (final tag in recipe.tags) {
            final existing = await (db.select(db.tags)..where((t) => t.id.equals(tag))).getSingleOrNull();
            if (existing == null) {
              await db.into(db.tags).insertOnConflictUpdate(TagsCompanion.insert(
                id: tag,
                name: tag,
              ));
            }
            await db.into(db.recipeTags).insertOnConflictUpdate(RecipeTagsCompanion.insert(
              recipeId: recipeId,
              tagId: tag,
            ));
          }
        }

        // Restore recipe links (ingredient→sub-recipe references)
        for (final i in recipesToDownload) {
          final recipe = result.recipes[i];
          final sourceRecipeId = recipeIdByIndex[i];
          if (sourceRecipeId == null) continue;

          for (final link in recipe.recipeLinks) {
            final linkedRecipeId = recipeIdByIndex[link.linkedRecipeIndex];
            final ingredientId = ingredientIdByIndex['${i}_${link.ingredientIndex}'];
            if (linkedRecipeId == null || ingredientId == null) continue;

            await db.into(db.recipeLinks).insertOnConflictUpdate(
              RecipeLinksCompanion.insert(
                sourceRecipeId: sourceRecipeId,
                ingredientId: ingredientId,
                linkedRecipeId: linkedRecipeId,
                scale: drift.Value(link.scale),
              ),
            );
          }
        }
      });

      ref.invalidate(cookbooksProvider);

      if (mounted) {
        final count = recipesToDownload.length;
        final allCount = result.recipes.length;
        final msg = count == allCount
            ? l10n.communityDownloadSuccess(result.title, count)
            : l10n.communityPartialDownloadSuccess(count, result.title);
        AppSnackbar.success(context, msg);
      }
    } catch (e) {
      if (mounted) AppSnackbar.error(context, l10n.communityDownloadFailedError(e.toString()));
    } finally {
      if (mounted) setState(() { _downloading = false; _downloadStatus = ''; });
    }
  }

  void _showDownloadChoice({Set<int>? selectedIndices}) {
    final d = _detail!;
    final recipeCount = selectedIndices?.length ?? d.recipes.length;

    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final l10n = AppLocalizations.of(ctx)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              )),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  selectedIndices != null ? l10n.communitySaveRecipeCount(recipeCount) : l10n.communityDownloadOptions,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

              // Destination: new or existing cookbook
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l10n.communitySaveTo, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.outline)),
              ),
              const SizedBox(height: 4),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: Text(l10n.communityNewCookbook),
                subtitle: Text('"${d.title}"'),
                onTap: () { Navigator.pop(ctx); _showImageChoice(selectedIndices: selectedIndices, targetCookbookId: null); },
              ),
              ListTile(
                leading: const Icon(Icons.book_outlined),
                title: Text(l10n.communityExistingCookbook),
                subtitle: Text(l10n.communityAddToExistingCookbook),
                onTap: () { Navigator.pop(ctx); _showCookbookPicker(selectedIndices: selectedIndices); },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showImageChoice({Set<int>? selectedIndices, String? targetCookbookId}) {
    final d = _detail!;
    if (!d.hasImages) {
      _download(withImages: false, selectedIndices: selectedIndices, targetCookbookId: targetCookbookId);
      return;
    }

    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final l10n = AppLocalizations.of(ctx)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              )),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.communityDownloadOptions, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: Text(l10n.communityDownloadWithImages(d.downloadSizeLabel)),
                subtitle: Text(l10n.communityDownloadImagesIncluded(d.imageCount)),
                onTap: () { Navigator.pop(ctx); _download(withImages: true, selectedIndices: selectedIndices, targetCookbookId: targetCookbookId); },
              ),
              ListTile(
                leading: const Icon(Icons.text_snippet),
                title: Text(l10n.communityDownloadTextOnly),
                subtitle: Text(l10n.communityDownloadTextOnlySubtitle),
                onTap: () { Navigator.pop(ctx); _download(withImages: false, selectedIndices: selectedIndices, targetCookbookId: targetCookbookId); },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showCookbookPicker({Set<int>? selectedIndices}) {
    final l10n = AppLocalizations.of(context)!;
    final cookbooks = ref.read(cookbooksProvider).valueOrNull ?? [];

    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                )),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.communityChooseCookbook, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                if (cookbooks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.communityNoCookbooksYetSaveNew,
                        style: TextStyle(color: theme.colorScheme.outline)),
                  )
                else
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: cookbooks.map((c) => ListTile(
                        leading: const Icon(Icons.book),
                        title: Text(c.name),
                        onTap: () { Navigator.pop(ctx); _showImageChoice(selectedIndices: selectedIndices, targetCookbookId: c.id); },
                      )).toList(),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReportSheet() {
    final l10n = AppLocalizations.of(context)!;

    final reasons = [
      ('spam', l10n.communityReportSpam),
      ('inappropriate', l10n.communityReportInappropriate),
      ('stolen', l10n.communityReportStolen),
      ('other', l10n.communityReportOther),
    ];

    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final sl10n = AppLocalizations.of(ctx)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              )),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(sl10n.communityReportTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              ...reasons.map((r) => ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(r.$2),
                onTap: () async {
                  Navigator.pop(ctx);
                  // Can't report own publication
                  if (AuthService.instance.currentUser?.id == _detail?.publisher.id) {
                    if (mounted) AppSnackbar.info(context, l10n.communityCannotReportOwn);
                    return;
                  }
                  final ok = await _community.report(widget.publicationId, r.$1);
                  if (mounted) {
                    if (ok) {
                      AppSnackbar.success(context, l10n.communityReportSuccess);
                    } else {
                      AppSnackbar.error(context, l10n.communitySignInToReport);
                    }
                  }
                },
              )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showEditSheet() {
    final d = _detail!;
    final titleCtrl = TextEditingController(text: d.title);
    final descCtrl = TextEditingController(text: d.description ?? '');
    var editTags = List<String>.from(d.tagList);

    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final theme = Theme.of(ctx);
            final l10n = AppLocalizations.of(ctx)!;
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              expand: false,
              builder: (ctx, scrollController) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: 16, right: 16, top: 16,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Center(
                        child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      Text(l10n.communityEditCookbook, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.communityEditTitle,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: l10n.communityEditDescriptionLabel,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(l10n.communityEditTagsLabel, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      CommunityTagPicker(
                        selectedTags: editTags,
                        onChanged: (tags) => setSheetState(() => editTags = tags),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final newTitle = titleCtrl.text.trim();
                          final newDesc = descCtrl.text.trim();
                          final newTags = editTags.join(','); // empty string clears tags

                          final success = await _community.updatePublication(
                            d.id,
                            title: newTitle.isNotEmpty && newTitle != d.title ? newTitle : null,
                            description: newDesc != (d.description ?? '') ? newDesc : null,
                            tags: newTags,
                          );

                          if (mounted) {
                            if (success) {
                              AppSnackbar.success(context, l10n.communityCookbookUpdated);
                              _load(); // Refresh
                            } else {
                              AppSnackbar.error(context, l10n.communityFailedToUpdate);
                            }
                          }
                        },
                        child: Text(l10n.communitySaveChanges),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_detail == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.communityPublicationNotFound)),
      );
    }

    final d = _detail!;

    return Scaffold(
      body: Stack(children: [
      Responsive.constrainWidth(context, child: CustomScrollView(
        slivers: [
          // ── Cover image header ──
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
              ),
            ),
            actions: [
              if (AuthService.instance.currentUser?.id == d.publisher.id)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    tooltip: l10n.communityEditTooltip,
                    onPressed: () => _showEditSheet(),
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    padding: EdgeInsets.zero,
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.flag_outlined, color: Colors.white),
                  tooltip: l10n.communityReport,
                  onPressed: _showReportSheet,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CommunityImage(
                    publicationId: d.id,
                    imagePath: d.imagePath,
                    fit: BoxFit.cover,
                  ),
                  // Gradient at bottom
                  Positioned(
                    bottom: 0, left: 0, right: 0, height: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                        ),
                      ),
                    ),
                  ),
                  // Title + publisher
                  Positioned(
                    bottom: 50, left: 16, right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            shadows: [Shadow(blurRadius: 8, color: Colors.black87), Shadow(blurRadius: 4, color: Colors.black54)],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => context.push('/community/creator/${d.publisher.id}'),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: context.appColors.accent.withValues(alpha: 0.18),
                                backgroundImage: d.publisher.avatarUrl != null
                                    ? NetworkImage(_resolveAvatarUrl(d.publisher.avatarUrl!))
                                    : null,
                                onBackgroundImageError: (_, __) {},
                                child: d.publisher.avatarUrl == null
                                    ? Text(d.publisher.displayName[0].toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.appColors.accent))
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.publisher.displayName, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15, fontWeight: FontWeight.w500)),
                                  Text(timeago.format(d.createdAt), style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                                ],
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: SelectionArea(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Description ──
                  if (d.description != null && d.description!.isNotEmpty) ...[
                    Text(
                      d.description!,
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Tags ──
                  if (d.tagList.isNotEmpty) ...[
                    _DetailTagChips(tags: d.tagList),
                    const SizedBox(height: 12),
                  ],

                  // ── Stats row ──
                  _StatsRow(
                    recipeCount: d.recipeCount,
                    downloadCount: d.downloadCount,
                    imageCount: d.imageCount,
                  ),
                  const SizedBox(height: 16),

                  // ── Rating section ──
                  _RatingSection(
                    averageRating: _displayRating,
                    ratingCount: _displayRatingCount,
                    myRating: _myRating,
                    loading: _ratingLoading,
                    onRate: _rate,
                    isOwnPublication: AuthService.instance.currentUser?.id == d.publisher.id,
                  ),
                  const SizedBox(height: 12),

                  // ── Download section ──
                  if (!_selectMode) ...[
                    _DownloadSection(
                      detail: d,
                      downloading: _downloading,
                      downloadStatus: _downloadStatus,
                      onDownload: () => _showDownloadChoice(),
                      onDownloadChoice: () => _showDownloadChoice(),
                      onSelectRecipes: () => setState(() => _selectMode = true),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Recipe list header ──
                  Row(
                    children: [
                      Expanded(child: Text(
                        _selectMode
                            ? '${_selectedIndices.length} of ${d.recipes.length} selected'
                            : l10n.recipesTitle,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      )),
                      if (_selectMode) ...[
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (_selectedIndices.length == d.recipes.length) {
                                _selectedIndices.clear();
                              } else {
                                _selectedIndices.addAll(List.generate(d.recipes.length, (i) => i));
                              }
                            });
                          },
                          child: Text(_selectedIndices.length == d.recipes.length ? l10n.communityDeselectAllRecipes : l10n.communitySelectAllRecipes),
                        ),
                        TextButton(
                          onPressed: () => setState(() { _selectMode = false; _selectedIndices.clear(); }),
                          child: Text(l10n.actionCancel),
                        ),
                      ],
                    ],
                  ),
                  if (!_selectMode)
                    Text(
                      l10n.communityTapToPreview,
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            )),
          ),

          // ── Recipe grid (with sub-recipe hierarchy) ──
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, _selectMode ? 80 : 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _buildRecipeListWithHierarchy(d, l10n, theme),
              ),
            ),
          ),
        ],
      )),

      // ── Selection action bar ──
      if (_selectMode)
        Positioned(
          left: 16, right: 16, bottom: 16,
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _selectedIndices.isEmpty ? null : () => _showDownloadChoice(selectedIndices: Set.from(_selectedIndices)),
                icon: const Icon(Icons.download),
                label: Text(l10n.communityDownloadRecipes(_selectedIndices.length)),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  /// Builds a flat widget list with sub-recipes indented below their parent.
  List<Widget> _buildRecipeListWithHierarchy(CommunityDetail d, AppLocalizations l10n, ThemeData theme) {
    // Collect all indices that are linked as sub-recipes
    final childIndices = <int>{};
    final childrenOf = <int, List<int>>{}; // parent index → [child indices]
    for (int i = 0; i < d.recipes.length; i++) {
      for (final link in d.recipes[i].recipeLinks) {
        final childIdx = link.linkedRecipeIndex;
        if (childIdx >= 0 && childIdx < d.recipes.length && childIdx != i) {
          childIndices.add(childIdx);
          childrenOf.putIfAbsent(i, () => []).add(childIdx);
        }
      }
    }

    Widget buildCard(int i, {bool isSubRecipe = false}) {
      final recipe = d.recipes[i];
      return _RecipePreviewCard(
        index: i,
        recipe: recipe,
        publicationId: d.id,
        selectMode: _selectMode,
        isSelected: _selectedIndices.contains(i),
        isSubRecipe: isSubRecipe,
        hasSubRecipes: childrenOf.containsKey(i),
        onTap: () {
          if (_selectMode) {
            setState(() {
              if (_selectedIndices.contains(i)) {
                _selectedIndices.remove(i);
              } else {
                _selectedIndices.add(i);
              }
            });
          } else {
            _showRecipePreview(i);
          }
        },
      );
    }

    final widgets = <Widget>[];
    for (int i = 0; i < d.recipes.length; i++) {
      // Skip recipes that only appear as children
      if (childIndices.contains(i)) continue;

      widgets.add(buildCard(i));

      // Show sub-recipes indented below parent
      final children = childrenOf[i];
      if (children != null) {
        for (final childIdx in children) {
          widgets.add(buildCard(childIdx, isSubRecipe: true));
        }
      }
    }

    return widgets;
  }

  void _showRecipePreview(int index) {
    showDialog(
      context: context,
      builder: (_) => CommunityRecipePreviewDialog(
        recipe: _detail!.recipes[index],
        publicationId: _detail!.id,
        recipeIndex: index,
      ),
    );
  }
}

// ════════════════════════════════════════════
//  STATS ROW
// ════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  final int recipeCount;
  final int downloadCount;
  final int imageCount;

  const _StatsRow({required this.recipeCount, required this.downloadCount, required this.imageCount});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        _StatBadge(icon: Icons.restaurant_menu, label: l10n.communityRecipeCount(recipeCount)),
        const SizedBox(width: 10),
        Opacity(
          opacity: downloadCount == 0 ? 0.6 : 1.0,
          child: _StatBadge(icon: Icons.download, label: l10n.communityDownloadCount(downloadCount)),
        ),
        if (imageCount > 0) ...[
          const SizedBox(width: 10),
          _StatBadge(icon: Icons.image, label: AppLocalizations.of(context)!.communityImageCountLabel(imageCount)),
        ],
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ════════════════════════════════════════════
//  INTERACTIVE RATING
// ════════════════════════════════════════════

class _RatingSection extends StatelessWidget {
  final double averageRating;
  final int ratingCount;
  final int myRating;
  final bool loading;
  final ValueChanged<int> onRate;
  final bool isOwnPublication;

  const _RatingSection({
    required this.averageRating,
    required this.ratingCount,
    required this.myRating,
    required this.loading,
    required this.onRate,
    this.isOwnPublication = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Own cookbook with no ratings — simple text, no stars
    if (isOwnPublication && ratingCount == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          l10n.communityNotCurrentlyRated,
          style: TextStyle(fontSize: 13, color: theme.colorScheme.outline, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Average rating display
          Row(
            children: [
              StarRating(rating: averageRating, count: ratingCount, size: 18),
              const Spacer(),
              if (averageRating > 0)
                Text(
                  averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // My rating — interactive (hidden for own cookbook)
          if (isOwnPublication)
            Text(
              l10n.communityCannotRateOwnCookbook,
              style: TextStyle(fontSize: 13, color: theme.colorScheme.outline, fontStyle: FontStyle.italic),
            )
          else
            Row(
              children: [
                Text(
                  myRating > 0 ? l10n.communityYourRating : l10n.communityRateThis,
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.outline),
                ),
                const SizedBox(width: 8),
                ...List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: loading ? null : () => onRate(star),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        star <= myRating ? Icons.star : Icons.star_border,
                        size: 28,
                        color: star <= myRating ? context.appColors.accent : theme.colorScheme.outline.withValues(alpha: 0.4),
                      ),
                    ),
                  );
                }),
                if (loading) ...[
                  const SizedBox(width: 8),
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  TAG CHIPS (detail)
// ════════════════════════════════════════════

class _DetailTagChips extends StatelessWidget {
  final List<String> tags;
  const _DetailTagChips({required this.tags});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags.map((tag) {
        // Find emoji from known tags
        String? emoji;
        String displayName = tag;
        try {
          final known = communityTags.firstWhere((t) => t.id == tag);
          emoji = known.emoji;
          displayName = known.name;
        } catch (_) {}

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            emoji != null ? '$emoji $displayName' : displayName,
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer),
          ),
        );
      }).toList(),
    );
  }
}

// ════════════════════════════════════════════
//  DOWNLOAD SECTION
// ════════════════════════════════════════════

class _DownloadSection extends StatelessWidget {
  final CommunityDetail detail;
  final bool downloading;
  final String downloadStatus;
  final VoidCallback onDownload;
  final VoidCallback onDownloadChoice;
  final VoidCallback onSelectRecipes;

  const _DownloadSection({
    required this.detail,
    required this.downloading,
    required this.downloadStatus,
    required this.onDownload,
    required this.onDownloadChoice,
    required this.onSelectRecipes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Size info
        if (detail.hasImages)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.storage, size: 14, color: theme.colorScheme.outline),
                const SizedBox(width: 6),
                Text(
                  l10n.communityWithImages(detail.downloadSizeLabel),
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),

        // Download button
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: downloading ? null : onDownload,
                  icon: downloading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.download),
                  label: Text(
                    downloading
                        ? downloadStatus
                        : l10n.communityDownloadToMyCookbooks,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            // Show choices button if many images
            if (detail.hasImages && !downloading) ...[
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: onDownloadChoice,
                  child: const Icon(Icons.expand_more),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Select individual recipes
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: downloading ? null : onSelectRecipes,
            icon: const Icon(Icons.checklist, size: 18),
            label: Text(l10n.communitySelectIndividualRecipes),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════
//  RECIPE PREVIEW CARD (tappable)
// ════════════════════════════════════════════

class _RecipePreviewCard extends StatelessWidget {
  final int index;
  final CommunityRecipe recipe;
  final String publicationId;
  final VoidCallback onTap;
  final bool selectMode;
  final bool isSelected;
  final bool isSubRecipe;
  final bool hasSubRecipes;

  const _RecipePreviewCard({
    required this.index,
    required this.recipe,
    required this.publicationId,
    required this.onTap,
    this.selectMode = false,
    this.isSelected = false,
    this.isSubRecipe = false,
    this.hasSubRecipes = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final parts = <String>[];
    if (recipe.prepTimeMinutes != null) parts.add(l10n.communityPrepTime(recipe.prepTimeMinutes!));
    if (recipe.cookTimeMinutes != null) parts.add(l10n.communityCookTime(recipe.cookTimeMinutes!));
    if (recipe.servings != null) {
      final s = int.tryParse(recipe.servings!);
      if (s != null) parts.add(l10n.communityServingsCount(s));
    }
    if (recipe.ingredients.isNotEmpty) parts.add(l10n.communityIngredientCount(recipe.ingredients.length));

    final hasImage = recipe.imagePath != null && recipe.imagePath!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(left: isSubRecipe ? 28 : 0),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        clipBehavior: Clip.antiAlias,
        color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Selection checkbox
                if (selectMode) ...[
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                ],

                // Sub-recipe link indicator
                if (isSubRecipe) ...[
                  Icon(Icons.subdirectory_arrow_right, size: 18, color: theme.colorScheme.outline),
                  const SizedBox(width: 6),
                ],

                // Thumbnail
                if (hasImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CommunityImage(
                      publicationId: publicationId,
                      imagePath: recipe.imagePath,
                      width: isSubRecipe ? 44 : 56,
                      height: isSubRecipe ? 44 : 56,
                      fit: BoxFit.cover,
                      memCacheWidth: 112,
                      memCacheHeight: 112,
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  CircleAvatar(
                    radius: isSubRecipe ? 12 : 16,
                    backgroundColor: isSubRecipe
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.primaryContainer,
                    child: Icon(
                      isSubRecipe ? Icons.link : Icons.restaurant,
                      size: isSubRecipe ? 12 : 14,
                      color: isSubRecipe ? theme.colorScheme.outline : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recipe.title,
                              style: TextStyle(
                                fontSize: isSubRecipe ? 13 : 14,
                                fontWeight: FontWeight.w500,
                                color: isSubRecipe ? theme.colorScheme.onSurfaceVariant : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasSubRecipes && !selectMode)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.account_tree_outlined, size: 14, color: theme.colorScheme.outline),
                            ),
                        ],
                      ),
                      if (isSubRecipe)
                        Text(
                          l10n.communitySubRecipe,
                          style: TextStyle(fontSize: 10, color: theme.colorScheme.outline),
                        )
                      else if (parts.isNotEmpty)
                        Text(
                          parts.join(' · '),
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (recipe.rating != null && recipe.rating! > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (i) {
                              final star = i + 1;
                              return Icon(
                                star <= recipe.rating! ? Icons.star : Icons.star_border,
                                size: 14,
                                color: star <= recipe.rating! ? context.appColors.accent : theme.colorScheme.outline.withValues(alpha: 0.3),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),

                // Chevron
                Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
