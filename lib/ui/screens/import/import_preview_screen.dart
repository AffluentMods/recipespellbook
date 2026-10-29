import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/imported_recipe.dart';
import '../../../providers/database_provider.dart';
import '../../../services/imported_recipe_saver.dart';
import '../../../utils/recipe_similarity.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/taxonomy_translator.dart';
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
  /// How many recipes have their pictures fetched at the same time.
  static const _batchSize = 5;

  late List<ImportedRecipe> _recipes;
  late List<bool> _selected;
  late List<bool> _expanded;
  late List<DuplicateStatus> _dupStatus;
  bool _loading = false;
  bool _stopRequested = false;
  bool _checkedDuplicates = false;
  bool _checkingDuplicates = true;

  /// The latest duplicate check could not be run, so nothing is flagged.
  bool _duplicateCheckFailed = false;
  double _progress = 0;
  String _progressStatus = '';

  /// Only the answer of the latest duplicate check counts. A rename starts a
  /// new one while an older one may still be running.
  int _duplicateRun = 0;

  /// Rows the duplicate check unticked. A row the user ticks or unticks
  /// leaves this set: from then on the choice is theirs.
  final Set<int> _leftOut = {};

  /// What the library has, so each card can show the course, category and
  /// tags its recipe will be saved with.
  ImportLibrary? _library;

  /// How many of the recipes handed over had nothing in them and are not
  /// listed.
  late final int _emptyCount;

  @override
  void initState() {
    super.initState();
    // Whichever way a recipe comes in, one with no ingredient and no step is
    // not offered: a title alone is not a recipe.
    _recipes = widget.recipes.where(hasRecipeContent).toList();
    _emptyCount = widget.recipes.length - _recipes.length;
    _selected = List.filled(_recipes.length, true);
    _expanded = List.filled(_recipes.length, false);
    _dupStatus = List.filled(_recipes.length, DuplicateStatus.none);
    _checkForDuplicates();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    try {
      final library = await ImportLibrary.load(ref.read(databaseProvider));
      if (mounted) setState(() => _library = library);
    } catch (e) {
      // The cards then show no course, category or tags. The import looks
      // them up again when it saves.
      debugPrint('[Import] Could not load the library: $e');
    }
  }

  /// Flags the recipes the library already has, and the same recipe twice in
  /// this import. Runs when the screen opens and again after a rename.
  Future<void> _checkForDuplicates() async {
    final run = ++_duplicateRun;
    if (!_checkingDuplicates) setState(() => _checkingDuplicates = true);

    var dupStatus = List.filled(_recipes.length, DuplicateStatus.none);
    var failed = false;
    try {
      final db = ref.read(databaseProvider);
      final existing = await ref.read(recipeDaoProvider).getAllRecipes();

      // Ingredient names of every existing recipe (needed for near-dup
      // scoring), in one query grouped here. A query per recipe took most of
      // a second on a library of 1,500.
      final existingIds = {for (final r in existing) r.id};
      final existingIngredients = <String, List<String>>{};
      final rows = await (db.selectOnly(db.ingredients)
            ..addColumns([db.ingredients.recipeId, db.ingredients.name]))
          .get();
      for (final row in rows) {
        final recipeId = row.read(db.ingredients.recipeId);
        final name = row.read(db.ingredients.name);
        if (recipeId == null || name == null || !existingIds.contains(recipeId)) continue;
        existingIngredients.putIfAbsent(recipeId, () => []).add(name);
      }

      // Comparing every import with every recipe takes seconds on a large
      // library, so it runs on another isolate and the screen stays usable.
      // Everything handed over is copied there: titles and ingredient lines
      // go, photos and the long text columns do not.
      dupStatus = await compute(
        _findDuplicates,
        _DuplicateSearch(
          imports: [
            for (final r in _recipes) ImportedRecipe(title: r.title, ingredients: r.ingredients, instructions: const []),
          ],
          existing: [
            for (final r in existing)
              r.copyWith(
                description: const drift.Value(null),
                notes: const drift.Value(null),
                nutritionJson: const drift.Value(null),
              ),
          ],
          existingIngredients: existingIngredients,
        ),
      );
    } catch (e) {
      // Without the check nothing is flagged. The import itself still works,
      // and the summary says that duplicates were not looked for.
      failed = true;
      debugPrint('[Import] Duplicate check failed: $e');
    }
    if (!mounted || run != _duplicateRun) return;

    setState(() {
      final firstAnswer = !_checkedDuplicates;
      _dupStatus = dupStatus;
      _duplicateCheckFailed = failed;
      _checkedDuplicates = true;
      _checkingDuplicates = false;

      for (var i = 0; i < _recipes.length; i++) {
        final exact = _dupStatus[i] == DuplicateStatus.exactExisting;
        if (exact && firstAnswer) {
          // Auto-deselect exact duplicates only. Near-duplicates stay checked
          // but visually flagged so the user can decide.
          _selected[i] = false;
          _leftOut.add(i);
        } else if (!exact && _leftOut.remove(i)) {
          // Renamed to a title the library does not have: the recipe the
          // check left out is wanted again. One renamed INTO a duplicate is
          // flagged but keeps its tick, the user has just had a say in it.
          _selected[i] = true;
        }
      }
    });
  }

  int get _selectedCount => _selected.where((s) => s).length;
  int get _duplicateCount {
    if (!_checkedDuplicates) return 0;
    return _dupStatus.where((s) => s != DuplicateStatus.none).length;
  }

  void _toggleAll(bool value) {
    setState(() {
      _leftOut.clear();
      for (var i = 0; i < _selected.length; i++) {
        _selected[i] = value;
      }
    });
  }

  void _selectNonDuplicates() {
    setState(() {
      _leftOut.clear();
      for (var i = 0; i < _selected.length; i++) {
        _selected[i] = _dupStatus[i] == DuplicateStatus.none;
      }
    });
  }

  Future<void> _importSelected() async {
    // The button is off while an import runs, but a key press can still
    // reach it on its way out. One import at a time.
    if (_loading) return;
    final l10n = AppLocalizations.of(context)!;
    // Should this screen be closed under the import (a notification opening
    // another page), the result is still told, on whatever is shown then.
    final navigator = Navigator.of(context, rootNavigator: true);
    final selectedRecipes = <ImportedRecipe>[];
    for (var i = 0; i < _recipes.length; i++) {
      if (_selected[i]) selectedRecipes.add(_recipes[i]);
    }
    if (selectedRecipes.isEmpty) return;

    setState(() {
      _loading = true;
      _stopRequested = false;
      _progress = 0;
      _progressStatus = '';
    });

    var closing = false;
    try {
      final result = await _saveAll(selectedRecipes, l10n);
      if (!mounted) {
        final below = _contextOnTop(navigator);
        if (below != null && below.mounted && (result.imported > 0 || result.errors.isNotEmpty)) {
          _showResult(below, result, selectedRecipes.length, l10n);
        }
        return;
      }
      // Stopped before anything was saved: the preview is as it was.
      if (result.stopped && result.imported == 0 && result.errors.isEmpty) return;

      _showResult(context, result, selectedRecipes.length, l10n);
      closing = true;
      // Now close the import screen. The root-overlay snackbar persists.
      // Another screen may have opened over this one while it was importing
      // (a link shared into the app): then this one is taken out from under
      // it, because pop would close the one on top and leave this one locked.
      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) {
        Navigator.of(context).removeRoute(route);
      } else {
        Navigator.of(context).pop();
      }
    } finally {
      // Whatever went wrong, the screen must not stay locked behind the
      // overlay with the way back closed.
      if (mounted && !closing) setState(() => _loading = false);
    }
  }

  /// Saves [recipes] one after the other. Never throws: what went wrong is in
  /// the result.
  Future<_ImportResult> _saveAll(List<ImportedRecipe> recipes, AppLocalizations l10n) async {
    final result = _ImportResult();
    final db = ref.read(databaseProvider);
    final client = http.Client();
    try {
      final library = await ImportLibrary.load(db);
      final documentsDir = await _documentsDir();

      // Pictures are fetched a few at a time, because a download can take
      // seconds, and the recipes they belong to are saved straight after.
      for (var start = 0; start < recipes.length; start += _batchSize) {
        // Cancel, or the screen going away, stops the import here, between
        // batches, so every picture stored belongs to a saved recipe.
        if (!mounted || _stopRequested) {
          result.stopped = true;
          break;
        }
        final end = (start + _batchSize).clamp(0, recipes.length);
        final batch = recipes.sublist(start, end);
        final images = await Future.wait([
          for (final recipe in batch)
            documentsDir != null && _hasImage(recipe)
                ? ImportedRecipeSaver.storeImage(recipe, documentsDir: documentsDir, client: client)
                : Future<String?>.value(),
        ]);

        for (var i = 0; i < batch.length; i++) {
          final recipe = batch[i];
          var stepImages = const <String?>[];
          try {
            if (documentsDir != null) {
              stepImages = await ImportedRecipeSaver.storeStepImages(recipe, documentsDir: documentsDir);
            }
            result.lastId = await ImportedRecipeSaver.save(
              db,
              cookbookId: widget.cookbookId,
              recipe: recipe,
              imagePath: images[i],
              stepImagePaths: stepImages,
              sectionHeadings: true,
              dashedHeadings: true,
              // One recipe is something the user will want to open next. A
              // batch would push everything else out of the recents.
              markViewed: recipes.length == 1,
              library: library,
            );
            result.imported++;
            if (images[i] == null && _hasImage(recipe)) result.imagesMissing++;
            result.imagesMissing += _stepPhotoCount(recipe) - stepImages.whereType<String>().length;
          } catch (e) {
            result.errors.add('${recipe.title}: ${_sanitizeError(e)}');
            debugPrint('[Import] Failed to import "${recipe.title}": $e');
            // The pictures stored for it belong to no recipe now.
            if (documentsDir != null) {
              await ImportedRecipeSaver.discardImages(
                [if (images[i] != recipe.imagePath) images[i], ...stepImages],
                documentsDir: documentsDir,
              );
            }
          }
        }

        if (mounted) {
          setState(() {
            _progress = end / recipes.length;
            _progressStatus = l10n.importingCount(end, recipes.length);
          });
        }
      }

      // Recipes of the app's own export can use each other as an ingredient.
      // They are all in by now, so those links can be made again. Should
      // that fail, every recipe is still whole without them.
      try {
        await ImportedRecipeSaver.saveLinks(db, library);
      } catch (e) {
        result.linksMissing = true;
        debugPrint('[Import] Failed to link the imported recipes: $e');
      }
    } catch (e) {
      result.errors.add(_sanitizeError(e));
    } finally {
      client.close();
    }
    return result;
  }

  /// Tells the user how the import went.
  ///
  /// The snackbar is shown on THIS screen's context, which sits below the
  /// root Overlay, BEFORE the screen is popped. AppSnackbar inserts its entry
  /// into the root overlay (rootOverlay: true), so the message survives the
  /// pop and stays visible on the screen underneath. The root navigator's own
  /// context has no Overlay ancestor (the Overlay is the navigator's child):
  /// showing the message there after the pop threw "No Overlay widget found"
  /// and the user got no feedback at all.
  void _showResult(BuildContext context, _ImportResult result, int wanted, AppLocalizations l10n) {
    final router = GoRouter.maybeOf(context);
    final lastId = result.lastId;
    final notes = [
      if (result.imagesMissing > 0) l10n.importImagesNotSaved(result.imagesMissing),
      if (result.linksMissing) l10n.importLinksNotSaved,
    ];
    final imagesNote = notes.isEmpty ? '' : ' (${notes.join(', ')})';

    if (result.imported == 0) {
      // Nothing was saved, so the failure has to be LOUD. The progress bar
      // reaching 100% only means the loop finished, NOT that a recipe was
      // persisted. Without this branch a total failure closed the screen
      // silently and the recipe "vanished".
      AppSnackbar.error(
        context,
        result.errors.isNotEmpty ? l10n.failedToImport(result.errors.first) : l10n.importNothingSaved,
      );
    } else if (result.errors.isNotEmpty && result.stopped) {
      // Some were never tried, and the message has to say so as well.
      AppSnackbar.error(
        context,
        '${l10n.importStoppedSomeFailed(result.imported, wanted, result.errors.length)}$imagesNote',
      );
    } else if (result.errors.isNotEmpty) {
      AppSnackbar.error(context, '${l10n.importSomeFailed(result.imported, result.errors.length)}$imagesNote');
    } else if (result.stopped) {
      AppSnackbar.info(context, '${l10n.importStoppedCount(result.imported, wanted)}$imagesNote');
    } else if (result.imported == 1 && lastId != null && router != null) {
      AppSnackbar.successWithAction(
        context,
        '${l10n.recipesImported(1)}$imagesNote',
        actionLabel: l10n.actionView,
        onAction: () => router.push('/recipe/$lastId'),
      );
    } else {
      AppSnackbar.success(context, '${l10n.recipesImported(result.imported)}$imagesNote');
    }
  }

  /// The context of the page [navigator] shows on top, for a message after
  /// this screen is gone. Null when there is none.
  static BuildContext? _contextOnTop(NavigatorState navigator) {
    if (!navigator.mounted) return null;
    Route<dynamic>? top;
    // Asks for the top route only: the first one asked about stops it, so
    // nothing is popped.
    navigator.popUntil((route) {
      top = route;
      return true;
    });
    final route = top;
    return route is ModalRoute ? route.subtreeContext : null;
  }

  static bool _hasImage(ImportedRecipe r) =>
      (r.imagePath ?? '').trim().isNotEmpty ||
      (r.imageData ?? '').trim().isNotEmpty ||
      (r.imageUrl ?? '').trim().isNotEmpty;

  /// How many steps of [r] come with a photo.
  static int _stepPhotoCount(ImportedRecipe r) =>
      r.stepRows?.where((step) => (step.imageData ?? '').trim().isNotEmpty).length ?? 0;

  /// Where imported pictures are kept, or null where the app has no folder
  /// of its own (the web build). Recipes are then saved without one.
  static Future<String?> _documentsDir() async {
    try {
      return (await getApplicationDocumentsDirectory()).path;
    } catch (_) {
      return null;
    }
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

  @override
  Widget build(BuildContext context) {
    // An import that is running is not left by accident: the way back is
    // closed until it is done. The overlay has a Cancel button for stopping it.
    return PopScope(
      canPop: !_loading,
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !_loading,
        title: Text(l10n.importPreview),
        centerTitle: true,
        actions: [
          if (_duplicateCount > 0)
            TextButton.icon(
              onPressed: _loading ? null : _selectNonDuplicates,
              icon: Icon(Icons.filter_alt_outlined, size: 18),
              label: Text(l10n.skipDuplicates),
            ),
        ],
      ),
      body: _recipes.isEmpty ? const _NothingToImport() : Responsive.constrainWidth(context, child: Stack(
        children: [
          // While the import runs only the overlay is there to use, for the
          // keyboard and a screen reader as much as for a tap.
          _OutOfReach(
            when: _loading,
            child: Column(
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
                  leftOut: _emptyCount,
                  checkedDuplicates: !_checkingDuplicates,
                  duplicateCheckFailed: _duplicateCheckFailed,
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
                        cookbookId: widget.cookbookId,
                        library: _library,
                        isSelected: _selected[index],
                        isExpanded: _expanded[index],
                        isDuplicate: isDupe,
                        duplicateStatus: dupStatus,
                        onSelectedChanged: (val) {
                          setState(() {
                            _selected[index] = val;
                            _leftOut.remove(index);
                          });
                        },
                        onExpandToggle: () {
                          setState(() => _expanded[index] = !_expanded[index]);
                        },
                        onRenameTitle: (newTitle) {
                          if (!mounted) return;
                          setState(() => _recipes[index].title = newTitle);
                          // The flag and the tick belonged to the old title.
                          _checkForDuplicates();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom action bar ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _OutOfReach(
              when: _loading,
              child: _BottomActionBar(
                selectedCount: _selectedCount,
                // The duplicate check may still untick recipes, so the import
                // waits for it.
                onImport: _selectedCount > 0 && !_checkingDuplicates && !_loading ? _importSelected : null,
              ),
            ),
          ),

          // ── Loading overlay ──
          if (_loading)
            _LoadingOverlay(
              progress: _progress,
              status: _stopRequested ? l10n.importStopping : _progressStatus,
              onCancel: _stopRequested ? null : () => setState(() => _stopRequested = true),
            ),
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

  /// Entries that had no ingredients and no steps and are not in the list.
  final int leftOut;
  final bool checkedDuplicates;
  final bool duplicateCheckFailed;
  final bool allSelected;
  final ValueChanged<bool> onToggleAll;

  const _SummaryBar({
    required this.total,
    required this.selected,
    required this.duplicates,
    required this.leftOut,
    required this.checkedDuplicates,
    this.duplicateCheckFailed = false,
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
                  l10n.importRecipesFound(total),
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      l10n.countSelected(selected),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                    ),
                    if (checkedDuplicates && duplicates > 0) ...[
                      Text(' · ', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                      Icon(Icons.copy, size: 12, color: theme.colorScheme.tertiary),
                      const SizedBox(width: 2),
                      Text(
                        l10n.importDuplicatesCount(duplicates),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.tertiary),
                      ),
                    ],
                    if (checkedDuplicates && duplicateCheckFailed) ...[
                      Text(' · ', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                      Flexible(
                        child: Text(
                          l10n.importDuplicateCheckFailed,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        ),
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
                        l10n.importCheckingDuplicates,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ],
                ),
                if (leftOut > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.importEntriesLeftOut(leftOut),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
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
// Nothing To Import (what was handed over holds no recipe)
// ═══════════════════════════════════════════════════════════════════

class _NothingToImport extends StatelessWidget {
  const _NothingToImport();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              l10n.importNothingToImport,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
  final String cookbookId;
  final ImportLibrary? library;
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
    required this.cookbookId,
    required this.library,
    required this.isSelected,
    required this.isExpanded,
    required this.isDuplicate,
    this.duplicateStatus = DuplicateStatus.none,
    required this.onSelectedChanged,
    required this.onExpandToggle,
    this.onRenameTitle,
  });

  Future<void> _showRenameDialog(BuildContext context) async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(title: recipe.title),
    );
    if (title != null) onRenameTitle?.call(title);
  }

  /// A scan or pasted text the parser could not make full sense of: it said
  /// so itself, or it found no ingredients or no steps at all.
  bool get _needsReview =>
      recipe.parseConfidence != null &&
      (recipe.parseConfidence! < 0.5 ||
          _itemCount(_ingredientLines(recipe)) == 0 ||
          _itemCount(_stepLines(recipe)) == 0);

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
                                label: '${_itemCount(_ingredientLines(recipe))}',
                                theme: theme,
                              ),
                              const SizedBox(width: 8),
                              _MetaChip(
                                icon: Icons.format_list_numbered,
                                label: '${_itemCount(_stepLines(recipe))}',
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
            if (_needsReview)
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
                        l10n.importNeedsReview,
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
                cookbookId: cookbookId,
                library: library,
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
      case OwnExport.sourceApp: return 'Recipe Spellbook';
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
  final String cookbookId;
  final ImportLibrary? library;

  const _ExpandedContent({
    required this.recipe,
    required this.cookbookId,
    required this.library,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Shown as they will be saved: a guessed course the app does not have, or
    // a keyword that is not one of the user's tags, would be gone after the
    // import and is not shown here either.
    final library = this.library;
    final translator = TaxonomyTranslator(l10n);
    final course = library?.courseIdFor(recipe, cookbookId: cookbookId);
    final categories = library?.categoryIdFor(recipe, cookbookId: cookbookId)?.split(',') ?? const <String>[];
    final tags = library?.tagsFor(recipe, cookbookId: cookbookId) ?? const [];

    final ingredients = _ingredientLines(recipe).toList();
    final steps = _stepLines(recipe).toList();

    // The first steps as they will be numbered: a section heading among them
    // takes no number.
    final firstSteps = <({int? number, String text})>[];
    var stepNumber = 0;
    for (final line in steps.take(5)) {
      firstSteps.add((number: line.heading ? null : ++stepNumber, text: line.text));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 8),

          // Course / Category chips
          if (library != null && (course != null || categories.isNotEmpty)) ...[
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (course != null)
                  _CategoryChip(
                    icon: Icons.restaurant_menu,
                    label: library.customCourseName(course) ?? translator.translateCourse(course),
                    theme: theme,
                  ),
                for (final category in categories)
                  _CategoryChip(
                    icon: Icons.category,
                    label: library.customCategoryName(category) ?? translator.translateCategory(category),
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
          if (ingredients.isNotEmpty) ...[
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
            ...ingredients.take(10).map((ing) {
              if (ing.heading) return _SectionHeading(title: ing.text, theme: theme);
              return Padding(
                padding: const EdgeInsets.only(left: 22, bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
                    Expanded(
                      child: Text(
                        ing.text,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (ingredients.length > 10)
              Padding(
                padding: const EdgeInsets.only(left: 22, top: 2),
                child: Text(
                  l10n.homeAndMore(ingredients.length - 10),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],

          // Instructions preview
          if (steps.isNotEmpty) ...[
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
            ...firstSteps.map((step) {
              if (step.number == null) return _SectionHeading(title: step.text, theme: theme);
              return Padding(
                padding: const EdgeInsets.only(left: 22, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        '${step.number}.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        step.text,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (steps.length > 5)
              Padding(
                padding: const EdgeInsets.only(left: 22, top: 2),
                child: Text(
                  l10n.importMoreSteps(steps.length - 5),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],

          // Tags / source
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tags.take(5).map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag.name,
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
// Lines of a recipe (what is listed, counted and offered)
// ═══════════════════════════════════════════════════════════════════

/// A line of a recipe as the preview lists it: an ingredient or a step, or
/// the title of a section heading among them.
typedef _Line = ({String text, bool heading});

/// The ingredients of [recipe], line by line. A recipe out of the app's own
/// export says which of its rows are headings. Anywhere else a heading is a
/// line written like one ("For the sauce:", or a line an importer wrapped in
/// dashes). The import saves by the same rule, so the preview shows a heading
/// as one and leaves it out of the counts.
Iterable<_Line> _ingredientLines(ImportedRecipe recipe) =>
    recipe.ingredientRows?.map((row) => (text: row.line, heading: row.isHeading)) ??
    recipe.ingredients.map(_lineOf);

/// The steps of [recipe], line by line, by the same rule.
Iterable<_Line> _stepLines(ImportedRecipe recipe) =>
    recipe.stepRows?.map((row) => (text: row.instruction, heading: row.isHeading)) ??
    recipe.instructions.map(_lineOf);

_Line _lineOf(String line) {
  final heading = ImportedRecipeSaver.headingTitle(
    line,
    sectionHeadings: true,
    dashedHeadings: true,
    stepsEndInColons: true,
  );
  return (text: heading ?? line, heading: heading != null);
}

/// How many of [lines] are ingredients or steps, not headings or blanks.
int _itemCount(Iterable<_Line> lines) => lines.where((line) => !line.heading && line.text.trim().isNotEmpty).length;

/// Whether [recipe] has anything to import: an ingredient or a step.
///
/// A title alone is not a recipe. Neither is a title that comes back as its
/// own only ingredient or step, which is what the text reader makes of a
/// single line it found nothing in. Nutrition facts count: a scanned product
/// is worth keeping for them when nobody listed its ingredients.
///
/// A recipe out of another recipe app is the user's own, kept there on
/// purpose: a card kept as a photo with its title, a recipe typed into the
/// notes, a bookmark. A picture, notes, a description or a link count for
/// those.
///
/// One sentence with no title is a recipe only when it holds a quantity:
/// "Whisk 2 eggs with 1 cup milk, then fry" is one, "Check out this recipe
/// I found!" is not.
bool hasRecipeContent(ImportedRecipe recipe) {
  if ((recipe.nutritionJson ?? '').trim().isNotEmpty) return true;
  if (recipe.sourceApp != null &&
      [recipe.imageData, recipe.imagePath, recipe.imageUrl, recipe.notes, recipe.description, recipe.sourceUrl]
          .any((field) => (field ?? '').trim().isNotEmpty)) {
    return true;
  }

  String? title;
  bool counts(_Line line) {
    if (line.heading) return false;
    final text = line.text.trim();
    // A line much longer than the title cannot be the title again. Taking it
    // apart letter by letter would cost time on a long text.
    if (text.length > recipe.title.length + 8) return _nameCharacter.hasMatch(text);
    final letters = _lettersOf(text);
    return letters.isNotEmpty && letters != (title ??= _lettersOf(recipe.title));
  }

  final ingredients = _ingredientLines(recipe).where(counts).length;
  final steps = _stepLines(recipe).where(counts).take(2).toList();
  if (ingredients == 0 && steps.length == 1 && recipe.sourceApp == null && _untitled.contains(recipe.title.trim().toLowerCase())) {
    return _quantity.hasMatch(steps.single.text);
  }
  return ingredients > 0 || steps.isNotEmpty;
}

/// The titles the readers give a recipe they found no title for.
const _untitled = {'', 'untitled recipe', 'imported recipe'};
final _quantity = RegExp('[0-9½¼¾⅓⅔⅛⅜⅝⅞⅙⅚⅕⅖⅗⅘]');

String _lettersOf(String text) => text.toLowerCase().replaceAll(_notLetters, '');
final _notLetters = RegExp(r'[^\p{L}\p{N}]+', unicode: true);
final _nameCharacter = RegExp(r'[\p{L}\p{N}]', unicode: true);

// ═══════════════════════════════════════════════════════════════════
// Section Heading (a heading among the ingredients or the steps)
// ═══════════════════════════════════════════════════════════════════

class _SectionHeading extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionHeading({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, top: 2, bottom: 4),
      child: Text(
        title,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
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
              selectedCount == 0 ? l10n.importSelectRecipes : l10n.importCountRecipes(selectedCount),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

/// [child], out of reach of taps, the keyboard and a screen reader [when]
/// asked to be.
class _OutOfReach extends StatelessWidget {
  final bool when;
  final Widget child;

  const _OutOfReach({required this.when, required this.child});

  @override
  Widget build(BuildContext context) => ExcludeFocus(
        excluding: when,
        child: ExcludeSemantics(
          excluding: when,
          child: AbsorbPointer(absorbing: when, child: child),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
// Loading Overlay
// ═══════════════════════════════════════════════════════════════════

class _LoadingOverlay extends StatelessWidget {
  final double progress;
  final String status;

  /// Stops the import after the recipes being saved right now. Null once
  /// that has been asked for.
  final VoidCallback? onCancel;
  const _LoadingOverlay({required this.progress, this.status = '', this.onCancel});

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
                const SizedBox(height: 12),
                TextButton(onPressed: onCancel, child: Text(l10n.actionCancel)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Rename Dialog
// ═══════════════════════════════════════════════════════════════════

/// Asks for a new title and closes with it, or with nothing when cancelled.
class _RenameDialog extends StatefulWidget {
  final String title;
  const _RenameDialog({required this.title});

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  // Owned by the dialog, so it lives exactly as long as the text field does,
  // the closing animation included.
  late final _controller = TextEditingController(text: widget.title);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) Navigator.pop(context, title);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.importRenameRecipe),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.recipeFieldTitle,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.rename)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Import result and duplicate search
// ═══════════════════════════════════════════════════════════════════

/// What an import run did, for the message shown when it ends.
class _ImportResult {
  int imported = 0;
  int imagesMissing = 0;
  bool linksMissing = false;
  String? lastId;
  bool stopped = false;
  final errors = <String>[];
}

/// What the duplicate search compares. It is sent to another isolate, so it
/// holds plain data only.
class _DuplicateSearch {
  final List<ImportedRecipe> imports;
  final List<Recipe> existing;
  final Map<String, List<String>> existingIngredients;

  const _DuplicateSearch({
    required this.imports,
    required this.existing,
    required this.existingIngredients,
  });
}

List<DuplicateStatus> _findDuplicates(_DuplicateSearch search) => ImportDuplicateChecker.check(
      imports: search.imports,
      existing: search.existing,
      existingIngredients: search.existingIngredients,
    );
