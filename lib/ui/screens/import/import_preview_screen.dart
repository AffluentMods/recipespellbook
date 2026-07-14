import 'dart:convert';
import '../../../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/imported_recipe.dart';
import '../../../providers/database_provider.dart';
import '../../../utils/ingredient_utils.dart';
import '../../../utils/recipe_similarity.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/platform_brand.dart';

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
  late List<DuplicateStatus> _dupStatus;
  bool _loading = false;
  bool _checkedDuplicates = false;
  int _importedCount = 0;
  String? _lastImportedRecipeId;
  double _progress = 0;
  String _progressStatus = '';

  @override
  void initState() {
    super.initState();
    _recipes = List.from(widget.recipes);
    _selected = List.filled(_recipes.length, true);
    _expanded = List.filled(_recipes.length, false);
    _dupStatus = List.filled(_recipes.length, DuplicateStatus.none);
    _checkForDuplicates();
  }

  Future<void> _checkForDuplicates() async {
    final recipeDao = ref.read(recipeDaoProvider);
    final existing = await recipeDao.getAllRecipes();

    // Pre-fetch ingredient names for each existing recipe (needed for near-dup scoring)
    final existingIngredients = <String, List<String>>{};
    for (final r in existing) {
      final ings = await recipeDao.getIngredientsForRecipe(r.id);
      existingIngredients[r.id] = ings.map((i) => i.name).toList();
    }

    final dupStatus = ImportDuplicateChecker.check(
      imports: _recipes,
      existing: existing,
      existingIngredients: existingIngredients,
    );

    setState(() {
      _dupStatus = dupStatus;
      _checkedDuplicates = true;

      // Auto-deselect exact duplicates only — leave near-duplicates checked
      // but visually flagged so the user can decide.
      for (var i = 0; i < _recipes.length; i++) {
        if (_dupStatus[i] == DuplicateStatus.exactExisting) {
          _selected[i] = false;
        }
      }
    });
  }

  bool _isDuplicate(String title) {
    // Compatibility shim — checks any kind of duplicate flag for the recipe.
    final idx = _recipes.indexWhere((r) => r.title == title);
    return idx >= 0 && _dupStatus[idx] != DuplicateStatus.none;
  }

  int get _selectedCount => _selected.where((s) => s).length;
  int get _duplicateCount {
    if (!_checkedDuplicates) return 0;
    return _dupStatus.where((s) => s != DuplicateStatus.none).length;
  }
  int get _exactDupCount =>
      _dupStatus.where((s) => s == DuplicateStatus.exactExisting).length;
  int get _nearDupCount =>
      _dupStatus.where((s) =>
          s == DuplicateStatus.nearExisting ||
          s == DuplicateStatus.nearInternal).length;

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
        _selected[i] = _dupStatus[i] == DuplicateStatus.none;
      }
    });
  }

  Future<void> _importSelected() async {
    final l10n = AppLocalizations.of(context)!;
    const uuid = Uuid();
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

    final db = ref.read(databaseProvider);
    final errors = <String>[];
    final imageFailures = <String>[];

    // Phase 1: Download all images in parallel (max 5 concurrent)
    final imageResults = <int, String?>{};
    final imageIndices = <int>[];
    for (var i = 0; i < selectedRecipes.length; i++) {
      final r = selectedRecipes[i];
      final hasAny = (r.imageUrl != null && r.imageUrl!.isNotEmpty) ||
          (r.imageData != null && r.imageData!.isNotEmpty) ||
          (r.imagePath != null && r.imagePath!.isNotEmpty);
      if (hasAny) imageIndices.add(i);
    }

    // Download in batches of 5
    for (var batch = 0; batch < imageIndices.length; batch += 5) {
      final end = (batch + 5).clamp(0, imageIndices.length);
      final batchIndices = imageIndices.sublist(batch, end);
      final futures = batchIndices.map((i) async {
        final r = selectedRecipes[i];
        // Local file path takes priority (from PDF page extraction)
        if (r.imagePath != null && r.imagePath!.isNotEmpty) {
          return MapEntry(i, r.imagePath);
        }
        if (r.imageUrl != null && r.imageUrl!.isNotEmpty) {
          return MapEntry(i, await _downloadRecipeImage(r.imageUrl!));
        } else if (r.imageData != null && r.imageData!.isNotEmpty) {
          return MapEntry(i, await _saveBase64Image(r.imageData!));
        }
        return MapEntry(i, null as String?);
      });
      final results = await Future.wait(futures);
      for (final entry in results) {
        imageResults[entry.key] = entry.value;
        // Track failed image downloads for recipes that had an image source
        if (entry.value == null) {
          imageFailures.add(selectedRecipes[entry.key].title);
        }
      }
      if (mounted) {
        final done = batch + batchIndices.length;
        setState(() {
          _progress = done / (selectedRecipes.length * 2);
          _progressStatus = 'Downloading images ($done/${selectedRecipes.length})...';
        });
      }
    }

    // Phase 2: Insert all recipes in DB with transactions
    for (var idx = 0; idx < selectedRecipes.length; idx++) {
      final recipe = selectedRecipes[idx];
      final recipeId = 'recipe_${uuid.v4()}';

      try {
        await db.transaction(() async {
          await db.into(db.recipes).insert(RecipesCompanion.insert(
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
            imagePath: drift.Value(imageResults[idx]),
            lastViewedAt: drift.Value(DateTime.now()),
          ));

          // Batch insert ingredients (parse amount/unit from raw strings)
          await db.batch((batch) {
            for (var i = 0; i < recipe.ingredients.length; i++) {
              final parsed = parseIngredient(recipe.ingredients[i]);
              // Guard the name against the column constraints (min 1,
              // max 200). Recipe-site parsers sometimes capture a tip
              // paragraph as an "ingredient" — without clamping, that one
              // over-long line throws InvalidDataException and rolls back
              // the ENTIRE recipe insert (the "imported 100% but the
              // recipe vanished" bug). Clamp instead of losing everything.
              var name = parsed.name.trim();
              if (name.isEmpty) continue; // skip blank lines (violate min:1)
              if (name.length > 200) name = '${name.substring(0, 197)}…';
              batch.insert(db.ingredients, IngredientsCompanion.insert(
                id: 'ing_${uuid.v4()}',
                recipeId: recipeId,
                sortOrder: i,
                name: name,
                amount: parsed.amount != null
                    ? drift.Value(formatAmount(parsed.amount!))
                    : const drift.Value.absent(),
                unit: parsed.unit != null
                    ? drift.Value(parsed.unit)
                    : const drift.Value.absent(),
              ));
            }
          });

          // Batch insert steps
          await db.batch((batch) {
            for (var i = 0; i < recipe.instructions.length; i++) {
              batch.insert(db.steps, StepsCompanion.insert(
                id: 'step_${uuid.v4()}',
                recipeId: recipeId,
                sortOrder: i,
                instruction: recipe.instructions[i],
              ));
            }
          });
        });

        _importedCount++;
        _lastImportedRecipeId = recipeId;
      } catch (e) {
        final message = _sanitizeError(e);
        errors.add('${recipe.title}: $message');
        debugPrint('[Import] Failed to import "${recipe.title}": $e');
      }

      if (mounted) {
        setState(() {
          _progress = 0.5 + ((idx + 1) / selectedRecipes.length) * 0.5;
          _progressStatus = 'Importing ${idx + 1}/${selectedRecipes.length}...';
        });
      }
    }

    if (mounted) {
      final router = GoRouter.of(context);
      final lastId = _lastImportedRecipeId;
      final imgFailSuffix = imageFailures.isNotEmpty
          ? ' (${imageFailures.length} image${imageFailures.length == 1 ? '' : 's'} failed to download)'
          : '';

      // Show the result snackbar on THIS screen's context — which sits
      // below the root Overlay — BEFORE popping. AppSnackbar inserts its
      // entry into the root overlay (rootOverlay: true), so the message
      // survives the pop and stays visible on the screen underneath.
      //
      // The previous approach showed it on the root navigator's OWN
      // context after popping, which has no Overlay ancestor (the
      // Overlay is the navigator's child) — that threw "No Overlay
      // widget found" and the user got no feedback at all.
      if (_importedCount == 0) {
        // Nothing was saved — make the failure LOUD. The progress bar
        // reaching 100% only means the loop finished, NOT that a recipe
        // was persisted. Without this branch a total failure closed the
        // screen silently and the recipe "vanished".
        AppSnackbar.error(
          context,
          errors.isNotEmpty
              ? l10n.failedToImport(errors.first)
              : l10n.importNothingSaved,
        );
      } else if (errors.isNotEmpty) {
        AppSnackbar.error(context, '$_importedCount imported, ${errors.length} failed$imgFailSuffix');
      } else if (_importedCount == 1 && lastId != null) {
        AppSnackbar.successWithAction(
          context,
          '$_importedCount recipe imported$imgFailSuffix',
          actionLabel: l10n.actionView,
          onAction: () => router.push('/recipe/$lastId'),
        );
      } else {
        AppSnackbar.success(context, '$_importedCount recipes imported$imgFailSuffix');
      }

      // Now pop the import screen. The root-overlay snackbar persists.
      Navigator.of(context).pop();
    }
  }

  /// Decodes a base64-encoded image and saves it to local storage.
  static Future<String?> _saveBase64Image(String base64Data) async {
    try {
      // Strip data URI prefix if present (data:image/jpeg;base64,...)
      var data = base64Data;
      if (data.contains(',')) {
        data = data.split(',').last;
      }

      final bytes = base64Decode(data);
      if (bytes.length < 1024) return null; // Skip tiny images

      final dir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${dir.path}/recipe_images');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      final filename = 'img_${const Uuid().v4()}.jpg';
      final file = File('${imageDir.path}/$filename');
      await file.writeAsBytes(bytes);

      debugPrint('[Import] Saved base64 image: ${file.path} (${bytes.length} bytes)');
      return file.path;
    } catch (e) {
      debugPrint('[Import] Failed to save base64 image: $e');
      return null;
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
      final filename = 'img_${const Uuid().v4()}$ext';
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

  /// Extracts a user-friendly message from a raw exception.
  static String _sanitizeError(Object e) {
    var msg = e.toString();
    // Strip Dart exception class prefixes
    for (final prefix in [
      'SqliteException',
      'DriftRemoteException',
      'FormatException',
      'Exception: ',
      'StateError: ',
    ]) {
      final idx = msg.indexOf(prefix);
      if (idx >= 0) {
        msg = msg.substring(idx);
        break;
      }
    }
    // Truncate overly long messages
    if (msg.length > 120) {
      msg = '${msg.substring(0, 117)}...';
    }
    return msg;
  }

  void _showErrorDetails(List<String> errors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber[700]),
            const SizedBox(width: 8),
            const Text('Import Issues'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: errors.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, size: 16, color: Colors.red[400]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errors[i],
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: Responsive.constrainWidth(context, child: Stack(
        children: [
          Column(
            children: [
              // ── Branded source header ("Imported from Instagram") ──
              if (detectPlatform(widget.sourceUrl) != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: PlatformBadge(detectPlatform(widget.sourceUrl)!),
                  ),
                ),

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
                    final dupStatus = _checkedDuplicates ? _dupStatus[index] : DuplicateStatus.none;
                    final isDupe = dupStatus != DuplicateStatus.none;

                    return _RecipePreviewCard(
                      recipe: recipe,
                      index: index,
                      isSelected: _selected[index],
                      isExpanded: _expanded[index],
                      isDuplicate: isDupe,
                      duplicateStatus: dupStatus,
                      onSelectedChanged: (val) {
                        setState(() => _selected[index] = val);
                      },
                      onExpandToggle: () {
                        setState(() => _expanded[index] = !_expanded[index]);
                      },
                      onRenameTitle: (newTitle) {
                        setState(() => _recipes[index].title = newTitle);
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
          if (_loading) _LoadingOverlay(progress: _progress, status: _progressStatus),
        ],
      )),
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
  final DuplicateStatus duplicateStatus;
  final ValueChanged<bool> onSelectedChanged;
  final VoidCallback onExpandToggle;
  final ValueChanged<String>? onRenameTitle;

  const _RecipePreviewCard({
    required this.recipe,
    required this.index,
    required this.isSelected,
    required this.isExpanded,
    required this.isDuplicate,
    this.duplicateStatus = DuplicateStatus.none,
    required this.onSelectedChanged,
    required this.onExpandToggle,
    this.onRenameTitle,
  });

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: recipe.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Recipe'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              onRenameTitle?.call(val.trim());
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                onRenameTitle?.call(val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

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
                              if (onRenameTitle != null)
                                GestureDetector(
                                  onTap: () => _showRenameDialog(context),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(Icons.edit, size: 16, color: theme.colorScheme.outline),
                                  ),
                                ),
                              if (isDuplicate) ...[
                                const SizedBox(width: 8),
                                _DuplicateBadge(
                                  status: duplicateStatus,
                                  l10n: l10n,
                                  theme: theme,
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

            // Low confidence warning
            if (recipe.parseConfidence != null && recipe.parseConfidence! < 0.5)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 18, color: Colors.amber[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'OCR quality is low — tap "Fix with AI" for better results',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.amber[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Expanded content ──
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _ExpandedContent(
                recipe: recipe,
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

  const _ExpandedContent({
    required this.recipe,
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

          // Course / Category / Cuisine chips
          if (recipe.suggestedCourse != null ||
              recipe.suggestedCategory != null ||
              recipe.cuisine != null) ...[
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (recipe.suggestedCourse != null)
                  _CategoryChip(
                    icon: Icons.restaurant_menu,
                    label: recipe.suggestedCourse!,
                    theme: theme,
                  ),
                if (recipe.suggestedCategory != null)
                  _CategoryChip(
                    icon: Icons.category,
                    label: recipe.suggestedCategory!,
                    theme: theme,
                  ),
                if (recipe.cuisine != null)
                  _CategoryChip(
                    icon: Icons.public,
                    label: recipe.cuisine!,
                    theme: theme,
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],

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
// Duplicate Badge — color/label by exact vs near, internal vs existing
// ═══════════════════════════════════════════════════════════════════

class _DuplicateBadge extends StatelessWidget {
  final DuplicateStatus status;
  final AppLocalizations l10n;
  final ThemeData theme;
  const _DuplicateBadge({required this.status, required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;
    final IconData icon;

    switch (status) {
      case DuplicateStatus.exactExisting:
        bg = theme.colorScheme.errorContainer;
        fg = theme.colorScheme.onErrorContainer;
        label = l10n.duplicate;
        icon = Icons.error_outline;
      case DuplicateStatus.nearExisting:
        bg = theme.colorScheme.tertiaryContainer;
        fg = theme.colorScheme.onTertiaryContainer;
        label = l10n.importNearDuplicateExisting;
        icon = Icons.copy_all_outlined;
      case DuplicateStatus.nearInternal:
        bg = theme.colorScheme.secondaryContainer;
        fg = theme.colorScheme.onSecondaryContainer;
        label = l10n.importNearDuplicateInternal;
        icon = Icons.compare_arrows;
      case DuplicateStatus.none:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
            ),
          ),
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
// Category Chip (icon + label with background)
// ═══════════════════════════════════════════════════════════════════

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _CategoryChip({required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
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
  final String status;
  const _LoadingOverlay({required this.progress, this.status = ''});

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
                  status.isNotEmpty ? status : '${(progress * 100).toInt()}%',
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