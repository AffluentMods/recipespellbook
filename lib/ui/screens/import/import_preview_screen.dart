import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/imported_recipe.dart';
import '../../../providers/database_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/smart_import_button.dart';

/// Full-screen import preview — lets users review, select/deselect, and spot
/// duplicates before committing recipes to a cookbook.
class ImportPreviewScreen extends ConsumerStatefulWidget {
  final List<ImportedRecipe> recipes;
  final String cookbookId;
  final String? sourceText;
  final String? sourceUrl;

  const ImportPreviewScreen({
    super.key,
    required this.recipes,
    required this.cookbookId,
    this.sourceText,
    this.sourceUrl,
  });

  @override
  ConsumerState<ImportPreviewScreen> createState() => _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends ConsumerState<ImportPreviewScreen> {
  late List<ImportedRecipe> _recipes;
  late List<bool> _selected;
  late List<bool> _expanded;
  Set<String> _existingTitles = {};
  bool _loading = false;
  bool _checkedDuplicates = false;
  int _importedCount = 0;
  String? _lastImportedRecipeId;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _recipes = List.from(widget.recipes);
    _selected = List.filled(_recipes.length, true);
    _expanded = List.filled(_recipes.length, false);
    _checkForDuplicates();
  }

  Future<void> _checkForDuplicates() async {
    final recipeDao = ref.read(recipeDaoProvider);
    final existing = await recipeDao.getAllRecipes();
    setState(() {
      _existingTitles = existing.map((r) => r.title.toLowerCase().trim()).toSet();
      _checkedDuplicates = true;

      // Auto-deselect exact duplicates
      for (var i = 0; i < _recipes.length; i++) {
        if (_isDuplicate(_recipes[i].title)) {
          _selected[i] = false;
        }
      }
    });
  }

  bool _isDuplicate(String title) {
    return _existingTitles.contains(title.toLowerCase().trim());
  }

  int get _selectedCount => _selected.where((s) => s).length;
  int get _duplicateCount {
    if (!_checkedDuplicates) return 0;
    return _recipes.where((r) => _isDuplicate(r.title)).length;
  }

  void _toggleAll(bool value) {
    setState(() {
      for (var i = 0; i < _selected.length; i++) {
        _selected[i] = value;
      }
    });
  }

  void _selectNonDuplicates() {
    setState(() {
      for (var i = 0; i < _selected.length; i++) {
        _selected[i] = !_isDuplicate(_recipes[i].title);
      }
    });
  }

  Future<void> _importSelected() async {
    final l10n = AppLocalizations.of(context)!;
    final selectedRecipes = <ImportedRecipe>[];
    for (var i = 0; i < _recipes.length; i++) {
      if (_selected[i]) selectedRecipes.add(_recipes[i]);
    }
    if (selectedRecipes.isEmpty) return;

    setState(() {
      _loading = true;
      _progress = 0;
      _importedCount = 0;
      _lastImportedRecipeId = null;
    });

    final recipeDao = ref.read(recipeDaoProvider);

    for (var idx = 0; idx < selectedRecipes.length; idx++) {
      final recipe = selectedRecipes[idx];
      try {
        final recipeId = 'recipe_${DateTime.now().millisecondsSinceEpoch}_$idx';

        // Download recipe image if available
        String? localImagePath;
        if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
          localImagePath = await _downloadRecipeImage(recipe.imageUrl!);
        }

        await recipeDao.insertRecipe(RecipesCompanion.insert(
          id: recipeId,
          cookbookId: widget.cookbookId,
          title: recipe.title,
          description: drift.Value(recipe.description),
          servings: drift.Value(recipe.servings),
          prepTimeMinutes: drift.Value(recipe.prepTimeMinutes),
          cookTimeMinutes: drift.Value(recipe.cookTimeMinutes),
          sourceUrl: drift.Value(recipe.sourceUrl),
          courseId: drift.Value(recipe.suggestedCourse),
          categoryId: drift.Value(recipe.suggestedCategory),
          notes: drift.Value(recipe.notes),
          imagePath: drift.Value(localImagePath),
        ));

        for (var i = 0; i < recipe.ingredients.length; i++) {
          await recipeDao.insertIngredient(IngredientsCompanion.insert(
            id: '${recipeId}_ing_$i',
            recipeId: recipeId,
            sortOrder: i,
            name: recipe.ingredients[i],
          ));
        }

        for (var i = 0; i < recipe.instructions.length; i++) {
          await recipeDao.insertStep(StepsCompanion.insert(
            id: '${recipeId}_step_$i',
            recipeId: recipeId,
            sortOrder: i,
            instruction: recipe.instructions[i],
          ));
        }

        _importedCount++;
        _lastImportedRecipeId = recipeId;
      } catch (_) {}

      if (mounted) {
        setState(() => _progress = (idx + 1) / selectedRecipes.length);
      }
    }

    if (mounted) {
      final router = GoRouter.of(context);
      final lastId = _lastImportedRecipeId;

      if (_importedCount == 1 && lastId != null) {
        AppSnackbar.successWithAction(
          context,
          '${_importedCount} recipe imported',
          actionLabel: l10n.actionView,
          onAction: () => router.push('/recipe/$lastId'),
        );
      } else {
        AppSnackbar.success(context, '$_importedCount recipes imported');
      }

      Navigator.of(context).pop();
    }
  }

  /// Downloads a recipe image from a URL and saves it to local app storage.
  /// Returns the local file path, or null on failure.
  static Future<String?> _downloadRecipeImage(String imageUrl) async {
    try {
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
          'Accept': 'image/*,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 || response.bodyBytes.isEmpty) return null;

      // Skip tiny images (likely tracking pixels or icons)
      if (response.bodyBytes.length < 1024) return null;

      final dir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${dir.path}/recipe_images');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      final ext = _guessImageExtension(
        response.headers['content-type'],
        imageUrl,
      );
      final filename = 'img_${DateTime.now().millisecondsSinceEpoch}$ext';
      final file = File('${imageDir.path}/$filename');
      await file.writeAsBytes(response.bodyBytes);

      debugPrint('[Import] Downloaded recipe image: ${file.path} (${response.bodyBytes.length} bytes)');
      return file.path;
    } catch (e) {
      debugPrint('[Import] Failed to download recipe image: $e');
      return null;
    }
  }

  static String _guessImageExtension(String? contentType, String url) {
    if (contentType != null) {
      if (contentType.contains('png')) return '.png';
      if (contentType.contains('webp')) return '.webp';
      if (contentType.contains('gif')) return '.gif';
    }
    final lower = url.toLowerCase().split('?').first;
    if (lower.endsWith('.png')) return '.png';
    if (lower.endsWith('.webp')) return '.webp';
    if (lower.endsWith('.gif')) return '.gif';
    return '.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importPreview),
        centerTitle: true,
        actions: [
          if (_duplicateCount > 0)
            TextButton.icon(
              onPressed: _selectNonDuplicates,
              icon: Icon(Icons.filter_alt_outlined, size: 18),
              label: Text(l10n.skipDuplicates),
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ── Summary bar ──
              _SummaryBar(
                total: _recipes.length,
                selected: _selectedCount,
                duplicates: _duplicateCount,
                checkedDuplicates: _checkedDuplicates,
                allSelected: _selectedCount == _recipes.length,
                onToggleAll: _toggleAll,
              ),

              // ── Recipe list ──
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    final isDupe = _checkedDuplicates && _isDuplicate(recipe.title);

                    return _RecipePreviewCard(
                      recipe: recipe,
                      index: index,
                      isSelected: _selected[index],
                      isExpanded: _expanded[index],
                      isDuplicate: isDupe,
                      sourceText: widget.sourceText,
                      sourceUrl: recipe.sourceUrl ?? widget.sourceUrl,
                      onSmartImportResult: (result) {
                        setState(() {
                          _recipes[index] = ImportedRecipe(
                            title: result['title'] as String? ?? _recipes[index].title,
                            description: result['description'] as String? ?? _recipes[index].description,
                            servings: result['servings']?.toString() ?? _recipes[index].servings,
                            prepTimeMinutes: result['prepTimeMinutes'] as int? ?? _recipes[index].prepTimeMinutes,
                            cookTimeMinutes: result['cookTimeMinutes'] as int? ?? _recipes[index].cookTimeMinutes,
                            ingredients: (result['ingredients'] as List?)?.cast<String>() ?? _recipes[index].ingredients,
                            instructions: (result['instructions'] as List?)?.cast<String>() ?? _recipes[index].instructions,
                            sourceUrl: _recipes[index].sourceUrl,
                            sourceApp: _recipes[index].sourceApp,
                            suggestedCourse: result['course'] as String? ?? _recipes[index].suggestedCourse,
                            suggestedCategory: result['category'] as String? ?? _recipes[index].suggestedCategory,
                            notes: result['notes'] as String? ?? _recipes[index].notes,
                            imageUrl: _recipes[index].imageUrl,
                            imageData: _recipes[index].imageData,
                            tags: _recipes[index].tags,
                            cuisine: result['cuisine'] as String? ?? _recipes[index].cuisine,
                            rating: _recipes[index].rating,
                          );
                        });
                      },
                      onSelectedChanged: (val) {
                        setState(() => _selected[index] = val);
                      },
                      onExpandToggle: () {
                        setState(() => _expanded[index] = !_expanded[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // ── Bottom action bar ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomActionBar(
              selectedCount: _selectedCount,
              onImport: _selectedCount > 0 ? _importSelected : null,
            ),
          ),

          // ── Loading overlay ──
          if (_loading) _LoadingOverlay(progress: _progress),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Summary Bar
// ═══════════════════════════════════════════════════════════════════

class _SummaryBar extends StatelessWidget {
  final int total;
  final int selected;
  final int duplicates;
  final bool checkedDuplicates;
  final bool allSelected;
  final ValueChanged<bool> onToggleAll;

  const _SummaryBar({
    required this.total,
    required this.selected,
    required this.duplicates,
    required this.checkedDuplicates,
    required this.allSelected,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total ${total == 1 ? 'recipe' : 'recipes'} found',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '$selected selected',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                    ),
                    if (checkedDuplicates && duplicates > 0) ...[
                      Text(' · ', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                      Icon(Icons.copy, size: 12, color: theme.colorScheme.tertiary),
                      const SizedBox(width: 2),
                      Text(
                        '$duplicates ${duplicates == 1 ? 'duplicate' : 'duplicates'}',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.tertiary),
                      ),
                    ],
                    if (!checkedDuplicates) ...[
                      Text(' · ', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: theme.colorScheme.outline),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'checking duplicates...',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Select all toggle
          TextButton(
            onPressed: () => onToggleAll(!allSelected),
            child: Text(allSelected ? l10n.deselectAll : l10n.selectAll),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Recipe Preview Card
// ═══════════════════════════════════════════════════════════════════

class _RecipePreviewCard extends StatelessWidget {
  final ImportedRecipe recipe;
  final int index;
  final bool isSelected;
  final bool isExpanded;
  final bool isDuplicate;
  final String? sourceText;
  final String? sourceUrl;
  final ValueChanged<Map<String, dynamic>>? onSmartImportResult;
  final ValueChanged<bool> onSelectedChanged;
  final VoidCallback onExpandToggle;

  const _RecipePreviewCard({
    required this.recipe,
    required this.index,
    required this.isSelected,
    required this.isExpanded,
    required this.isDuplicate,
    this.sourceText,
    this.sourceUrl,
    this.onSmartImportResult,
    required this.onSelectedChanged,
    required this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.surfaceContainerLowest
              : theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDuplicate
                ? theme.colorScheme.tertiary.withValues(alpha: 0.5)
                : isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: isDuplicate ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            // ── Header row ──
            InkWell(
              onTap: onExpandToggle,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
                child: Row(
                  children: [
                    // Checkbox
                    Checkbox(
                      value: isSelected,
                      onChanged: (val) => onSelectedChanged(val ?? false),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),

                    // Title + metadata
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  recipe.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? null : theme.colorScheme.outline,
                                    decoration: isSelected ? null : TextDecoration.lineThrough,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isDuplicate) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    l10n.duplicate,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onTertiaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _MetaChip(
                                icon: Icons.egg_outlined,
                                label: '${recipe.ingredients.length}',
                                theme: theme,
                              ),
                              const SizedBox(width: 8),
                              _MetaChip(
                                icon: Icons.format_list_numbered,
                                label: '${recipe.instructions.length}',
                                theme: theme,
                              ),
                              if (recipe.sourceApp != null) ...[
                                const SizedBox(width: 8),
                                _MetaChip(
                                  icon: Icons.apps,
                                  label: _appDisplayName(recipe.sourceApp!),
                                  theme: theme,
                                ),
                              ],
                              if (recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null) ...[
                                const SizedBox(width: 8),
                                _MetaChip(
                                  icon: Icons.timer_outlined,
                                  label: _formatTime(recipe.prepTimeMinutes, recipe.cookTimeMinutes),
                                  theme: theme,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Expand chevron
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more,
                        color: theme.colorScheme.outline,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Expanded content ──
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _ExpandedContent(
                recipe: recipe,
                sourceText: sourceText,
                sourceUrl: sourceUrl,
                onSmartImportResult: onSmartImportResult,
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  static String _appDisplayName(String app) {
    switch (app) {
      case 'recipekeeper': return 'RecipeKeeper';
      case 'copymeThat': return 'CopyMeThat';
      case 'crouton': return 'Crouton';
      case 'mealmaster': return 'MealMaster';
      case 'tandoor': return 'Tandoor';
      case 'mealie': return 'Mealie';
      case 'samsungfood': return 'Samsung Food';
      case 'paprika': return 'Paprika';
      default: return app;
    }
  }

  static String _formatTime(int? prep, int? cook) {
    final total = (prep ?? 0) + (cook ?? 0);
    if (total == 0) return '';
    if (total >= 60) return '${total ~/ 60}h ${total % 60}m';
    return '${total}m';
  }
}

// ═══════════════════════════════════════════════════════════════════
// Expanded Content (ingredients + instructions preview)
// ═══════════════════════════════════════════════════════════════════

class _ExpandedContent extends StatelessWidget {
  final ImportedRecipe recipe;
  final String? sourceText;
  final String? sourceUrl;
  final ValueChanged<Map<String, dynamic>>? onSmartImportResult;

  const _ExpandedContent({
    required this.recipe,
    this.sourceText,
    this.sourceUrl,
    this.onSmartImportResult,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 8),

          // Smart Import button (when source data is available)
          if (sourceText != null || sourceUrl != null)
            SmartImportButton(
              sourceText: sourceText,
              sourceUrl: sourceUrl,
              existingParse: {
                'title': recipe.title,
                if (recipe.description != null) 'description': recipe.description,
                if (recipe.servings != null) 'servings': recipe.servings,
                'ingredients': recipe.ingredients,
                'instructions': recipe.instructions,
              },
              onResult: (result) => onSmartImportResult?.call(result),
            ),

          // Description
          if (recipe.description != null && recipe.description!.isNotEmpty) ...[
            Text(
              recipe.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],

          // Ingredients
          if (recipe.ingredients.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.egg_outlined, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  l10n.ingredientsTitle,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...recipe.ingredients.take(10).map((ing) => Padding(
              padding: const EdgeInsets.only(left: 22, bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
                  Expanded(
                    child: Text(
                      ing,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            if (recipe.ingredients.length > 10)
              Padding(
                padding: const EdgeInsets.only(left: 22, top: 2),
                child: Text(
                  '+${recipe.ingredients.length - 10} more',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],

          // Instructions preview
          if (recipe.instructions.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.format_list_numbered, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  l10n.instructionsTitle,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...recipe.instructions.take(5).toList().asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(left: 22, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      '${entry.key + 1}.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
            if (recipe.instructions.length > 5)
              Padding(
                padding: const EdgeInsets.only(left: 22, top: 2),
                child: Text(
                  '+${recipe.instructions.length - 5} more steps',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],

          // Tags / source
          if (recipe.tags != null && recipe.tags!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: recipe.tags!.take(5).map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              )).toList(),
            ),
          ],

          if (recipe.sourceUrl != null && recipe.sourceUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.link, size: 12, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    recipe.sourceUrl!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Meta Chip (small icon + label)
// ═══════════════════════════════════════════════════════════════════

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _MetaChip({required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: theme.colorScheme.outline),
        const SizedBox(width: 3),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Bottom Action Bar
// ═══════════════════════════════════════════════════════════════════

class _BottomActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onImport;

  const _BottomActionBar({required this.selectedCount, this.onImport});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: onImport,
            icon: const Icon(Icons.download_rounded),
            label: Text(
              selectedCount == 0
                  ? 'Select recipes to import'
                  : 'Import $selectedCount ${selectedCount == 1 ? 'recipe' : 'recipes'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Loading Overlay
// ═══════════════════════════════════════════════════════════════════

class _LoadingOverlay extends StatelessWidget {
  final double progress;
  const _LoadingOverlay({required this.progress});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(40),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restaurant_menu, size: 40, color: theme.colorScheme.primary),
                const SizedBox(height: 20),
                Text(
                  l10n.importingRecipes,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}