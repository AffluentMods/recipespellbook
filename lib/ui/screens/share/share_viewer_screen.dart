import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../services/image_service.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';

const _shareApiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.recipespellbook.app');

/// Displays shared content from a `/s/:code` link.
/// Fetches the data from the backend and shows recipes with an import option.
class ShareViewerScreen extends ConsumerStatefulWidget {
  final String code;
  const ShareViewerScreen({super.key, required this.code});

  @override
  ConsumerState<ShareViewerScreen> createState() => _ShareViewerScreenState();
}

class _ShareViewerScreenState extends ConsumerState<ShareViewerScreen> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;
  bool _saving = false;

  String _shareImageUrl(String serverPath) =>
      '$_shareApiUrl/v1/web/images/share/${widget.code}/$serverPath';

  @override
  void initState() {
    super.initState();
    _fetchShareData();
  }

  Future<void> _fetchShareData() async {
    try {
      const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.recipespellbook.app');
      final uri = Uri.parse('$apiUrl/v1/share/${widget.code}');
      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _data = jsonDecode(response.body);
          _loading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _error = 'expired';
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'failed';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'no_connection';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _data?['cookbook']?['name']
            ?? _data?['recipe']?['title']
            ?? l10n.shareViewerSharedRecipe,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Responsive.constrainWidth(context, child: _buildBody(theme)),
    );
  }

  Widget _buildBody(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      String errorText;
      switch (_error) {
        case 'expired': errorText = l10n.shareViewerExpired; break;
        case 'no_connection': errorText = l10n.shareViewerNoConnection; break;
        default: errorText = l10n.shareViewerFailed;
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link_off, size: 64, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text(errorText, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/'),
                child: Text(l10n.shareViewerGoHome),
              ),
            ],
          ),
        ),
      );
    }

    // Single-recipe shares return `recipe`, cookbook shares return `recipes` array.
    // Normalize both shapes into a unified `recipes` list for rendering.
    final List recipes;
    if (_data?['recipe'] != null) {
      recipes = [_data!['recipe']];
    } else {
      recipes = (_data?['recipes'] as List?) ?? [];
    }
    final sharedBy = _data?['sharedBy']?['name'] ?? 'Someone';
    final expiresAt = _data?['expiresAt'] != null
        ? DateTime.tryParse(_data!['expiresAt'])
        : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.share, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.shareViewerSharedBy(sharedBy),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                if (expiresAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.shareViewerExpires(_formatExpiry(expiresAt, l10n)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  l10n.shareViewerRecipeCount(recipes.length),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Recipe list
        ...recipes.map((r) => _RecipeCard(
              recipe: r,
              theme: theme,
              imageUrlFn: _shareImageUrl,
              saving: _saving,
              onSave: () => _promptSave(r as Map<String, dynamic>),
              expandedByDefault: recipes.length == 1,
            )),
      ],
    );
  }

  String _formatExpiry(DateTime expiry, AppLocalizations l10n) {
    final diff = expiry.difference(DateTime.now());
    if (diff.inHours > 0) return l10n.shareViewerHoursRemaining(diff.inHours);
    if (diff.inMinutes > 0) return l10n.shareViewerMinutesRemaining(diff.inMinutes);
    return l10n.shareViewerExpiredLabel;
  }

  /// Let the user choose which cookbook to save the shared recipe into.
  Future<void> _promptSave(Map<String, dynamic> recipe) async {
    final l10n = AppLocalizations.of(context)!;
    final cookbooks = ref.read(cookbooksProvider).valueOrNull ?? const [];
    if (cookbooks.length <= 1) {
      await _saveRecipe(recipe, cookbooks.isNotEmpty ? cookbooks.first.id : 'starter');
      return;
    }
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.communitySaveRecipeTo((recipe['title'] as String?) ?? ''),
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: cookbooks
                    .map((c) => ListTile(
                          leading: const Icon(Icons.book_outlined),
                          title: Text(c.name),
                          onTap: () => Navigator.pop(ctx, c.id),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (chosen != null) await _saveRecipe(recipe, chosen);
  }

  /// Import a shared recipe into [cookbookId], downloading its photos from the
  /// share so the saved copy keeps them.
  Future<void> _saveRecipe(Map<String, dynamic> recipe, String cookbookId) async {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(databaseProvider);
    final id = 'shr_${DateTime.now().millisecondsSinceEpoch}';
    final images = ImageService.instance;
    setState(() => _saving = true);
    try {
      // Download images first (outside the DB transaction).
      String? coverLocal;
      final coverServer = recipe['imagePath'] as String?;
      if (coverServer != null && coverServer.isNotEmpty) {
        coverLocal = await images.downloadAndSaveImage(_shareImageUrl(coverServer), '${id}_cover.jpg');
      }
      final steps = (recipe['steps'] as List?) ?? [];
      final stepLocal = <int, String?>{};
      for (var i = 0; i < steps.length; i++) {
        final sp = steps[i]['imagePath'] as String?;
        if (sp != null && sp.isNotEmpty) {
          stepLocal[i] = await images.downloadAndSaveImage(_shareImageUrl(sp), '${id}_step_$i.jpg');
        }
      }

      final ings = (recipe['ingredients'] as List?) ?? [];
      await db.transaction(() async {
        await db.into(db.recipes).insert(RecipesCompanion.insert(
          id: id,
          cookbookId: cookbookId,
          title: (recipe['title'] as String?) ?? l10n.shareViewerUntitled,
          description: drift.Value(recipe['description'] as String?),
          servings: drift.Value(recipe['servings'] as String?),
          prepTimeMinutes: drift.Value((recipe['prepTimeMinutes'] as num?)?.toInt()),
          cookTimeMinutes: drift.Value((recipe['cookTimeMinutes'] as num?)?.toInt()),
          sourceUrl: drift.Value(recipe['sourceUrl'] as String?),
          courseId: drift.Value(recipe['courseId'] as String?),
          categoryId: drift.Value(recipe['categoryId'] as String?),
          rating: drift.Value((recipe['rating'] as num?)?.toInt()),
          notes: drift.Value(recipe['notes'] as String?),
          nutritionJson: drift.Value(recipe['nutritionJson'] as String?),
          imagePath: drift.Value(coverLocal),
          lastViewedAt: drift.Value(DateTime.now()),
        ));
        for (var i = 0; i < ings.length; i++) {
          await db.into(db.ingredients).insert(IngredientsCompanion.insert(
            id: '${id}_ing_$i',
            recipeId: id,
            sortOrder: (ings[i]['sortOrder'] as num?)?.toInt() ?? i,
            name: (ings[i]['name'] as String?) ?? '',
            amount: drift.Value(ings[i]['amount'] as String?),
            unit: drift.Value(ings[i]['unit'] as String?),
            notes: drift.Value(ings[i]['notes'] as String?),
          ));
        }
        for (var i = 0; i < steps.length; i++) {
          await db.into(db.steps).insert(StepsCompanion.insert(
            id: '${id}_step_$i',
            recipeId: id,
            sortOrder: (steps[i]['sortOrder'] as num?)?.toInt() ?? i,
            instruction: (steps[i]['instruction'] as String?) ?? '',
            durationMinutes: drift.Value((steps[i]['durationMinutes'] as num?)?.toInt()),
            imagePath: drift.Value(stepLocal[i]),
          ));
        }
      });

      if (mounted) {
        AppSnackbar.success(context,
            l10n.communityRecipeSaved((recipe['title'] as String?) ?? ''));
      }
    } catch (e) {
      if (mounted) AppSnackbar.error(context, l10n.communityFailedToSave(e.toString()));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final ThemeData theme;
  final String Function(String) imageUrlFn;
  final VoidCallback onSave;
  final bool saving;
  final bool expandedByDefault;

  const _RecipeCard({
    required this.recipe,
    required this.theme,
    required this.imageUrlFn,
    required this.onSave,
    required this.saving,
    required this.expandedByDefault,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = recipe['title'] ?? l10n.shareViewerUntitled;
    final description = recipe['description'] as String?;
    final ingredients = (recipe['ingredients'] as List?) ?? [];
    final steps = (recipe['steps'] as List?) ?? [];
    final coverPath = recipe['imagePath'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (coverPath != null && coverPath.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrlFn(coverPath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ExpansionTile(
            initiallyExpanded: expandedByDefault,
            leading: Icon(Icons.restaurant, color: theme.colorScheme.primary),
            title: Text(title, style: theme.textTheme.titleMedium),
            subtitle: description != null && description.isNotEmpty
                ? Text(description, maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ingredients.isNotEmpty) ...[
                      Text(l10n.ingredientsTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ...ingredients.map((ing) {
                        final amount = ing['amount']?.toString() ?? '';
                        final unit = ing['unit']?.toString() ?? '';
                        final name = ing['name']?.toString() ?? '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('• $amount $unit $name'.trim()),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],
                    if (steps.isNotEmpty) ...[
                      Text(l10n.instructionsTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ...steps.asMap().entries.map((entry) {
                        final instruction = entry.value['instruction']?.toString() ?? '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('${entry.key + 1}. $instruction'),
                        );
                      }),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: saving ? null : onSave,
                icon: saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.download_rounded),
                label: Text(l10n.communitySaveRecipe),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
