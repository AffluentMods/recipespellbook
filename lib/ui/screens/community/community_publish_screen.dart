import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../database/database.dart';
import '../../../database/daos/tags_dao.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/community_service.dart';
import '../../../services/image_service.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/community_tag_picker.dart';

// ════════════════════════════════════════════
//  PUBLISH SCREEN — Select cookbook → Configure → Publish
// ════════════════════════════════════════════

class CommunityPublishScreen extends ConsumerStatefulWidget {
  const CommunityPublishScreen({super.key});

  @override
  ConsumerState<CommunityPublishScreen> createState() => _CommunityPublishScreenState();
}

class _CommunityPublishScreenState extends ConsumerState<CommunityPublishScreen> {
  final _community = CommunityService.instance;

  // Step 1: selected cookbook, Step 2: configure, Step 3: publishing
  int _step = 1;
  Cookbook? _selectedCookbook;
  int _recipeCount = 0;

  // Step 2 fields
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  List<String> _selectedTags = [];
  bool _includeImages = true;

  // Step 3 state
  bool _isPublishing = false;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 1 ? l10n.communityPublishCookbook : l10n.communityConfigurePublication),
        leading: _step > 1 && !_isPublishing
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _step = 1))
            : null,
      ),
      body: _step == 1
          ? _buildStep1CookbookSelection(theme, l10n)
          : _step == 2
          ? _buildStep2Configure(theme, l10n)
          : _buildStep3Publishing(theme, l10n),
    );
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

    if (count < 10) {
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
                  _SummaryRow(icon: Icons.tag, label: '${_selectedTags.length} tags'),
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
                  Text(progress?.errorMessage ?? 'Unknown error',
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
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _startPublish() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() { _isPublishing = true; _step = 3; });

    publishProgressNotifier.value = const PublishProgress(status: 'preparing');

    try {
      // Gather recipe data
      final recipeDao = ref.read(recipeDaoProvider);
      final tagsDao = TagsDao(ref.read(databaseProvider));
      final recipes = await recipeDao.getRecipesForCookbook(_selectedCookbook!.id);

      final recipeMaps = <Map<String, dynamic>>[];
      final localImagePaths = <String>[]; // Track all local paths for upload

      // Collect cookbook cover
      if (_includeImages && _selectedCookbook!.imagePath != null) {
        localImagePaths.add(_selectedCookbook!.imagePath!);
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
        });
      }

      // ── Upload images (if enabled) ──
      int totalImageBytes = 0;
      int skippedImages = 0;
      final pathMapping = <String, String>{}; // local path → server path

      if (_includeImages) {
        // Filter to unique existing local files
        final uniquePaths = localImagePaths.toSet().where((p) {
          return !ImageService.isServerPath(p) && File(p).existsSync();
        }).toList();

        publishProgressNotifier.value = PublishProgress(
          status: 'uploading',
          totalImages: uniquePaths.length,
        );

        for (int i = 0; i < uniquePaths.length; i++) {
          final localPath = uniquePaths[i];
          final result = await ImageService.instance.communityUploadLocalPath(localPath);

          if (result != null) {
            pathMapping[localPath] = result.path;
            // Estimate bytes from the path (we don't have exact server-side size)
            totalImageBytes += File(localPath).lengthSync();
          } else {
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
      String? cookbookImagePath = _selectedCookbook!.imagePath;
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

      final result = await _community.publish(
        title: title,
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        imagePath: cookbookImagePath,
        recipes: recipeMaps,
        imageCount: pathMapping.length,
        totalImageBytes: totalImageBytes,
        tags: _selectedTags.isNotEmpty ? _selectedTags.join(',') : null,
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
          errorMessage: result.error ?? 'Publishing failed',
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
        final canPublish = count >= 10;

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
