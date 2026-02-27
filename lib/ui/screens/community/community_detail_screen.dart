import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../database/database.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../services/community_service.dart';
import '../../widgets/app_snackbar.dart';

// ════════════════════════════════════════════
//  COMMUNITY DETAIL — View & Download
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final detail = await _community.getPublication(widget.publicationId);
    if (mounted) setState(() { _detail = detail; _loading = false; });
  }

  Future<void> _download() async {
    if (_downloading) return;
    setState(() => _downloading = true);

    try {
      final result = await _community.download(widget.publicationId);
      if (result == null || result.recipes.isEmpty) {
        if (mounted) AppSnackbar.error(context, 'Download failed');
        return;
      }

      // Create a new cookbook locally with the downloaded recipes
      final db = ref.read(databaseProvider);
      final cookbookId = 'community_${DateTime.now().millisecondsSinceEpoch}';

      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
        id: cookbookId,
        name: result.title,
        description: drift.Value(result.description),
      ));

      for (final recipe in result.recipes) {
        final recipeId = 'cr_${DateTime.now().microsecondsSinceEpoch}';

        await db.into(db.recipes).insert(RecipesCompanion.insert(
          id: recipeId,
          cookbookId: cookbookId,
          title: recipe.title,
          description: drift.Value(recipe.description),
          servings: drift.Value(recipe.servings),
          prepTimeMinutes: drift.Value(recipe.prepTimeMinutes),
          cookTimeMinutes: drift.Value(recipe.cookTimeMinutes),
          sourceUrl: drift.Value(recipe.sourceUrl),
          rating: drift.Value(recipe.rating),
          notes: drift.Value(recipe.notes),
          nutritionJson: drift.Value(recipe.nutritionJson),
        ));

        for (final ing in recipe.ingredients) {
          await db.into(db.ingredients).insert(IngredientsCompanion.insert(
            id: 'ci_${DateTime.now().microsecondsSinceEpoch}',
            recipeId: recipeId,
            sortOrder: ing.sortOrder,
            amount: drift.Value(ing.amount),
            unit: drift.Value(ing.unit),
            name: ing.name,
            notes: drift.Value(ing.notes),
          ));
        }

        for (final step in recipe.steps) {
          await db.into(db.steps).insert(StepsCompanion.insert(
            id: 'cs_${DateTime.now().microsecondsSinceEpoch}',
            recipeId: recipeId,
            sortOrder: step.sortOrder,
            instruction: step.instruction,
            durationMinutes: drift.Value(step.durationMinutes),
          ));
        }
      }

      // Invalidate cookbook provider to refresh list
      ref.invalidate(cookbooksProvider);

      if (mounted) {
        AppSnackbar.success(context, 'Downloaded "${result.title}" — ${result.recipes.length} recipes added!');
      }
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Download failed: $e');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _showReportSheet() {
    final reasons = [
      ('spam', 'Spam or low quality'),
      ('inappropriate', 'Inappropriate content'),
      ('stolen', 'Stolen / copied recipes'),
      ('other', 'Other'),
    ];

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
                child: Text('Report this cookbook', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              ...reasons.map((r) => ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(r.$2),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await _community.report(widget.publicationId, r.$1);
                  if (mounted) {
                    if (ok) {
                      AppSnackbar.success(context, 'Report submitted. Thank you!');
                    } else {
                      AppSnackbar.error(context, 'Sign in to report content');
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_detail == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Publication not found')),
      );
    }

    final d = _detail!;

    return Scaffold(
      appBar: AppBar(
        title: Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(icon: const Icon(Icons.flag_outlined), tooltip: 'Report', onPressed: _showReportSheet),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header card ──
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  if (d.description != null && d.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(d.description!, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: d.publisher.avatarUrl != null ? NetworkImage(d.publisher.avatarUrl!) : null,
                        child: d.publisher.avatarUrl == null
                            ? Text(d.publisher.displayName[0].toUpperCase(), style: const TextStyle(fontSize: 10))
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text('by ${d.publisher.displayName}', style: TextStyle(fontSize: 13, color: theme.colorScheme.outline)),
                      const Spacer(),
                      Text(timeago.format(d.createdAt), style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatBadge(icon: Icons.restaurant_menu, label: '${d.recipeCount} recipes'),
                      const SizedBox(width: 12),
                      _StatBadge(icon: Icons.download, label: '${d.downloadCount} downloads'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Download button ──
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _downloading ? null : _download,
              icon: _downloading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.download),
              label: Text(_downloading ? 'Downloading...' : 'Download to My Cookbooks'),
            ),
          ),

          const SizedBox(height: 24),

          // ── Recipe list preview ──
          Text('Recipes', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          ...d.recipes.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;
            return _RecipePreviewTile(index: i + 1, recipe: r);
          }),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  SUB-WIDGETS
// ════════════════════════════════════════════

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface)),
      ]),
    );
  }
}

class _RecipePreviewTile extends StatelessWidget {
  final int index;
  final CommunityRecipe recipe;
  const _RecipePreviewTile({required this.index, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = <String>[];
    if (recipe.prepTimeMinutes != null) parts.add('${recipe.prepTimeMinutes}m prep');
    if (recipe.cookTimeMinutes != null) parts.add('${recipe.cookTimeMinutes}m cook');
    if (recipe.servings != null) parts.add('${recipe.servings} servings');
    if (recipe.ingredients.isNotEmpty) parts.add('${recipe.ingredients.length} ingredients');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text('$index', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
      ),
      title: Text(recipe.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: parts.isNotEmpty ? Text(parts.join(' · '), style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)) : null,
    );
  }
}