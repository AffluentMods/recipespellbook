import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  CommunityDetail? _detail;
  bool _loading = true;
  bool _downloading = false;
  String _downloadStatus = '';

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
        AppSnackbar.error(context, 'Failed to save rating. Please try again.');
      }
      setState(() => _ratingLoading = false);
    }
  }

  Future<void> _download({bool withImages = true}) async {
    if (_downloading) return;
    setState(() { _downloading = true; _downloadStatus = 'Downloading cookbook...'; });
    final l10n = AppLocalizations.of(context)!;
    const uuid = Uuid();

    try {
      final result = await _community.download(widget.publicationId);
      if (result == null || result.recipes.isEmpty) {
        if (mounted) AppSnackbar.error(context, l10n.communityDownloadFailed);
        return;
      }

      final db = ref.read(databaseProvider);
      final cookbookId = 'community_${uuid.v4()}';

      // --- Phase 1: Download images (before DB writes) ---
      final totalRecipes = result.recipes.length;
      final List<String?> coverImages = [];
      final List<List<String?>> stepImages = [];

      for (int i = 0; i < totalRecipes; i++) {
        final recipe = result.recipes[i];
        if (mounted) setState(() => _downloadStatus = 'Downloading images... (${i + 1}/$totalRecipes)');

        // Cover image
        String? coverPath;
        if (withImages && recipe.imagePath != null && recipe.imagePath!.isNotEmpty) {
          try {
            final url = CommunityService.communityImageUrl(widget.publicationId, recipe.imagePath!);
            final filename = 'community_${widget.publicationId}_${uuid.v4()}_cover.jpg';
            coverPath = await ImageService.instance.downloadAndSaveImage(url, filename);
          } catch (_) { /* image fail is non-fatal */ }
        }
        coverImages.add(coverPath);

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
        stepImages.add(sImgs);
      }

      // --- Phase 2: Insert everything in a single transaction ---
      if (mounted) setState(() => _downloadStatus = 'Saving recipes...');

      await db.transaction(() async {
        // Create cookbook
        await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
          id: cookbookId,
          name: result.title,
          description: drift.Value(result.description),
        ));

        for (int i = 0; i < totalRecipes; i++) {
          final recipe = result.recipes[i];
          final recipeId = 'cr_${uuid.v4()}';

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
          for (final ing in recipe.ingredients) {
            await db.into(db.ingredients).insert(IngredientsCompanion.insert(
              id: 'ci_${uuid.v4()}',
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
              imagePath: drift.Value(stepImages[i][s]),
            ));
          }

          // Insert recipe tags
          for (final tag in recipe.tags) {
            // Ensure the tag exists locally
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
      });

      ref.invalidate(cookbooksProvider);

      if (mounted) {
        AppSnackbar.success(context, l10n.communityDownloadSuccess(result.title, result.recipes.length));
      }
    } catch (e) {
      if (mounted) AppSnackbar.error(context, l10n.communityDownloadFailedError(e.toString()));
    } finally {
      if (mounted) setState(() { _downloading = false; _downloadStatus = ''; });
    }
  }

  void _showDownloadChoice() {
    final d = _detail!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
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
                child: Text(AppLocalizations.of(ctx)!.communityDownloadOptions, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: Text(AppLocalizations.of(ctx)!.communityDownloadWithImages(d.downloadSizeLabel)),
                subtitle: Text(AppLocalizations.of(ctx)!.communityDownloadImagesIncluded(d.imageCount)),
                onTap: () { Navigator.pop(ctx); _download(withImages: true); },
              ),
              ListTile(
                leading: const Icon(Icons.text_snippet),
                title: Text(AppLocalizations.of(ctx)!.communityDownloadTextOnly),
                subtitle: Text(AppLocalizations.of(ctx)!.communityDownloadTextOnlySubtitle),
                onTap: () { Navigator.pop(ctx); _download(withImages: false); },
              ),
              const SizedBox(height: 16),
            ],
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

    showModalBottomSheet(
      context: context,
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final theme = Theme.of(ctx);
            return Padding(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                  ),
                  Text('Edit Cookbook', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Tags', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
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
                          AppSnackbar.success(context, 'Cookbook updated');
                          _load(); // Refresh
                        } else {
                          AppSnackbar.error(context, 'Failed to update');
                        }
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
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
      body: CustomScrollView(
        slivers: [
          // ── Cover image header ──
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            actions: [
              if (AuthService.instance.currentUser?.id == d.publisher.id)
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit',
                  onPressed: () => _showEditSheet(),
                ),
              IconButton(
                icon: const Icon(Icons.flag_outlined),
                tooltip: l10n.communityReport,
                onPressed: _showReportSheet,
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (d.publisher.avatarUrl != null)
                              CircleAvatar(
                                radius: 10,
                                backgroundImage: NetworkImage(d.publisher.avatarUrl!),
                              )
                            else
                              CircleAvatar(
                                radius: 10,
                                child: Text(d.publisher.displayName[0].toUpperCase(), style: const TextStyle(fontSize: 8)),
                              ),
                            const SizedBox(width: 6),
                            Text(
                              d.publisher.displayName,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '·  ${timeago.format(d.createdAt)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
                              ),
                            ),
                          ],
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
            child: Padding(
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

                  // ── Download section (hidden for own cookbook) ──
                  if (AuthService.instance.currentUser?.id != d.publisher.id) ...[
                    _DownloadSection(
                      detail: d,
                      downloading: _downloading,
                      downloadStatus: _downloadStatus,
                      onDownload: () {
                        if (d.imageCount > 30) {
                          _showDownloadChoice();
                        } else if (d.hasImages) {
                          _download(withImages: true);
                        } else {
                          _download(withImages: false);
                        }
                      },
                      onDownloadChoice: _showDownloadChoice,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Recipe list header ──
                  Text(
                    l10n.recipesTitle,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.communityTapToPreview,
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ── Recipe grid ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final recipe = d.recipes[i];
                  return _RecipePreviewCard(
                    index: i,
                    recipe: recipe,
                    publicationId: d.id,
                    onTap: () => _showRecipePreview(i),
                  );
                },
                childCount: d.recipes.length,
              ),
            ),
          ),
        ],
      ),
    );
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
        _StatBadge(icon: Icons.download, label: l10n.communityDownloadCount(downloadCount)),
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
        Icon(icon, size: 14, color: theme.colorScheme.primary),
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
              'You cannot rate your own cookbook',
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
                        color: star <= myRating ? Colors.amber : theme.colorScheme.outline.withValues(alpha: 0.4),
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

  const _DownloadSection({
    required this.detail,
    required this.downloading,
    required this.downloadStatus,
    required this.onDownload,
    required this.onDownloadChoice,
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
                  '${detail.downloadSizeLabel} with images',
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

  const _RecipePreviewCard({
    required this.index,
    required this.recipe,
    required this.publicationId,
    required this.onTap,
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Thumbnail
              if (hasImage) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CommunityImage(
                    publicationId: publicationId,
                    imagePath: recipe.imagePath,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    memCacheWidth: 112,
                    memCacheHeight: 112,
                  ),
                ),
                const SizedBox(width: 12),
              ] else ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text('${index + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                ),
                const SizedBox(width: 12),
              ],

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (parts.isNotEmpty)
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
                              color: star <= recipe.rating! ? Colors.amber : theme.colorScheme.outline.withValues(alpha: 0.3),
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
    );
  }
}
