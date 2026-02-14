import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../services/ingredient_resolver_service.dart';
import '../../../utils/ingredient_utils.dart';
import '../../../utils/default_recipe_images.dart';
import '../../../services/pantry_service.dart';

// ═══════════════════════════════════════════════════════════════════
// SHOPPING LIST GENERATOR SCREEN
//
// Full-screen multi-step flow for adding ingredients to shopping
// lists when linked recipes or multiple recipes are involved.
//
// Steps:
//   0 (conditional): Conflict resolution — pick which linked
//     recipes to include when an ingredient links to 2+ recipes
//
//   1: Recipe cards — collapsible per-recipe ingredient lists.
//     Linked ingredients are greyed out with a "see below" link.
//
//   2: Final review — combined checklist, shopping list picker,
//     create new list, confirm & add.
// ═══════════════════════════════════════════════════════════════════

class ShoppingListGeneratorScreen extends ConsumerStatefulWidget {
  final RecipeResolutionResult resolutionResult;

  const ShoppingListGeneratorScreen({
    super.key,
    required this.resolutionResult,
  });

  @override
  ConsumerState<ShoppingListGeneratorScreen> createState() =>
      _ShoppingListGeneratorScreenState();
}

class _ShoppingListGeneratorScreenState
    extends ConsumerState<ShoppingListGeneratorScreen> {
  late RecipeResolutionResult _result;
  late PageController _pageController;
  int _currentStep = 0;

  // Step 1: per-recipe ingredient selections
  // Map<recipeId, Set<ingredientId>>
  late Map<String, Set<String>> _selections;

  // Step 2: list destination
  List<ShoppingList>? _existingLists;
  String? _selectedListId;
  String _newListName = '';
  bool _isCreatingNewList = false;
  bool _isAdding = false;

  // Expanded recipe cards
  final Set<String> _expandedRecipes = {};

  // Per-recipe user scale multipliers (on top of link-resolved scale)
  final Map<String, double> _userScales = {};

  // Pantry items that should be unchecked by default
  Set<String> _pantryMatches = {};

  // For scrolling to a linked recipe card
  final Map<String, GlobalKey> _recipeKeys = {};

  // ScrollController for step 1 (needed for ensureVisible)
  final ScrollController _recipeListScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _result = widget.resolutionResult;
    _currentStep = _result.hasConflicts ? 0 : 1;
    _pageController = PageController(initialPage: _currentStep);
    _initSelections();
    _loadLists();
    _loadPantryAndFilter();
  }

  void _initSelections() {
    _selections = {};
    _recipeKeys.clear();
    for (final recipe in _result.recipes) {
      _selections[recipe.recipeId] =
          recipe.directIngredients.map((ri) => ri.ingredient.id).toSet();
      _recipeKeys[recipe.recipeId] = GlobalKey();
      _userScales.putIfAbsent(recipe.recipeId, () => 1.0);
    }
    // Auto-expand first recipe
    _expandedRecipes.clear();
    if (_result.recipes.isNotEmpty) {
      _expandedRecipes.add(_result.recipes.first.recipeId);
    }
  }

  /// Check all ingredients against pantry; uncheck matches by default.
  Future<void> _loadPantryAndFilter() async {
    final idToName = <String, String>{};
    for (final recipe in _result.recipes) {
      for (final ri in recipe.directIngredients) {
        idToName[ri.ingredient.id] = ri.ingredient.name;
      }
    }
    final matches = await PantryService.instance.filterPantryMatches(idToName);
    if (mounted && matches.isNotEmpty) {
      setState(() {
        _pantryMatches = matches;
        for (final recipe in _result.recipes) {
          _selections[recipe.recipeId]?.removeAll(matches);
        }
      });
    }
  }

  Future<void> _loadLists() async {
    final shoppingDao = ref.read(shoppingDaoProvider);
    final lists = await shoppingDao.getAllLists();
    if (mounted) {
      setState(() {
        _existingLists = lists;
        if (lists.isNotEmpty) _selectedListId = lists.first.id;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _recipeListScrollController.dispose();
    super.dispose();
  }

  int get _totalSelected =>
      _selections.values.fold(0, (sum, set) => sum + set.length);

  bool get _hasConflictStep => _result.hasConflicts;

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<bool> _onWillPop() async {
    // Navigate back a step first
    if (_currentStep > (_hasConflictStep ? 0 : 1)) {
      _goToStep(_currentStep - 1);
      return false;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Shopping List Generator?'),
        content: const Text(
          'Are you sure you wish to exit the shopping list generator? '
              'Unsaved changes will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shopping List Generator'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) Navigator.of(context).pop();
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: _buildStepIndicator(),
          ),
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Page 0: Conflict resolution (or empty placeholder)
            _hasConflictStep
                ? _buildConflictStep()
                : const SizedBox.shrink(),
            // Page 1: Recipe cards
            _buildRecipeCardsStep(),
            // Page 2: Final review + list picker
            _buildFinalStep(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP INDICATOR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStepIndicator() {
    final theme = Theme.of(context);
    final totalSteps = _hasConflictStep ? 3 : 2;
    final adjustedStep = _hasConflictStep ? _currentStep : _currentStep - 1;
    final progress = (adjustedStep + 1) / totalSteps;

    return LinearProgressIndicator(
      value: progress,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 0: CONFLICT RESOLUTION
  // ═══════════════════════════════════════════════════════════════

  Widget _buildConflictStep() {
    final theme = Theme.of(context);
    final allResolved =
    _result.conflicts.every((c) => c.selectedRecipeIds.isNotEmpty);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.call_split, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Choose Linked Recipes',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Some ingredients link to multiple recipes. '
                    'Select which ones to include.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),

        // Conflict cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _result.conflicts.length,
            itemBuilder: (context, index) {
              final conflict = _result.conflicts[index];
              return _ConflictCard(
                conflict: conflict,
                onChanged: () => setState(() {}),
              );
            },
          ),
        ),

        // Continue button
        _BottomActionBar(
          child: FilledButton.icon(
            onPressed: allResolved ? _onConflictsResolved : null,
            icon: const Icon(Icons.arrow_forward),
            label: Text(allResolved
                ? 'Continue'
                : 'Select recipes for all ingredients'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onConflictsResolved() async {
    final dao = ref.read(recipeDaoProvider);
    final updatedResult =
    await IngredientResolverService.resolveWithConflictChoices(
      _result,
      _result.conflicts,
      dao,
    );

    setState(() {
      _result = updatedResult;
      _initSelections();
    });

    _goToStep(1);
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 1: RECIPE CARDS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildRecipeCardsStep() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Icon(Icons.restaurant_menu, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Ingredients',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_result.recipes.length} recipes • '
                          '$_totalSelected ingredients selected',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Warnings
        if (_result.hitRecipeLimit || _result.hitDepthLimit)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _result.hitRecipeLimit
                            ? 'Reached maximum of ${ResolutionLimits.maxRecipes} recipes. Some linked recipes may not be shown.'
                            : 'Recipe links are very deep. Some nested recipes may not be shown.',
                        style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Recipe cards
        Expanded(
          child: ListView.builder(
            controller: _recipeListScrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: _result.recipes.length,
            itemBuilder: (context, index) {
              final recipe = _result.recipes[index];
              final isExpanded = _expandedRecipes.contains(recipe.recipeId);
              final selected = _selections[recipe.recipeId] ?? {};

              return _RecipeCard(
                key: _recipeKeys[recipe.recipeId],
                recipe: recipe,
                isExpanded: isExpanded,
                selectedCount: selected.length,
                totalCount: recipe.directIngredients.length,
                selectedIds: selected,
                allRecipes: _result.recipes,
                recipeKeys: _recipeKeys,
                userScale: _userScales[recipe.recipeId] ?? 1.0,
                pantryMatches: _pantryMatches,
                onToggleExpand: () => _toggleExpand(recipe.recipeId),
                onToggleIngredient: (ingId) =>
                    _toggleIngredient(recipe.recipeId, ingId),
                onSelectAll: () => _selectAllForRecipe(recipe.recipeId),
                onUnselectAll: () => _unselectAllForRecipe(recipe.recipeId),
                onScrollToRecipe: _scrollToAndExpandRecipe,
                onScaleChanged: (scale) {
                  setState(() => _userScales[recipe.recipeId] = scale);
                },
              );
            },
          ),
        ),

        // Next button
        _BottomActionBar(
          child: FilledButton.icon(
            onPressed: _totalSelected > 0 ? () => _goToStep(2) : null,
            icon: const Icon(Icons.arrow_forward),
            label: Text('Review & Add ($_totalSelected items)'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: const Color(0xFFE8A860),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleExpand(String recipeId) {
    setState(() {
      if (_expandedRecipes.contains(recipeId)) {
        _expandedRecipes.remove(recipeId);
      } else {
        _expandedRecipes.add(recipeId);
      }
    });
  }

  void _toggleIngredient(String recipeId, String ingredientId) {
    setState(() {
      final set = _selections[recipeId] ?? {};
      if (set.contains(ingredientId)) {
        set.remove(ingredientId);
      } else {
        set.add(ingredientId);
      }
      _selections[recipeId] = set;
    });
  }

  void _selectAllForRecipe(String recipeId) {
    setState(() {
      final recipe = _result.recipes.firstWhere((r) => r.recipeId == recipeId);
      _selections[recipeId] =
          recipe.directIngredients.map((ri) => ri.ingredient.id).toSet();
    });
  }

  void _unselectAllForRecipe(String recipeId) {
    setState(() {
      _selections[recipeId] = {};
    });
  }

  void _scrollToAndExpandRecipe(String recipeId) {
    // Expand the target card first
    if (!_expandedRecipes.contains(recipeId)) {
      setState(() => _expandedRecipes.add(recipeId));
    }

    // Wait a frame for expansion animation to start, then scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _recipeKeys[recipeId];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 2: FINAL REVIEW + LIST PICKER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFinalStep() {
    final theme = Theme.of(context);
    final allSelected = _getAllSelectedIngredients();

    // Group by source recipe
    final grouped = <String, List<ResolvedIngredient>>{};
    for (final item in allSelected) {
      grouped.putIfAbsent(item.sourceRecipeName, () => []).add(item);
    }

    final canConfirm = allSelected.isNotEmpty &&
        !_isAdding &&
        (_isCreatingNewList
            ? _newListName.trim().isNotEmpty
            : _selectedListId != null);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Icon(Icons.checklist, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review & Add',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${allSelected.length} items from '
                          '${grouped.length} recipes',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List destination picker
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _ListDestinationPicker(
            existingLists: _existingLists ?? [],
            selectedListId: _selectedListId,
            isCreatingNewList: _isCreatingNewList,
            newListName: _newListName,
            onListSelected: (id) => setState(() {
              _selectedListId = id;
              _isCreatingNewList = false;
            }),
            onCreateNewList: () => setState(() {
              _isCreatingNewList = true;
              _selectedListId = null;
            }),
            onNewListNameChanged: (name) =>
                setState(() => _newListName = name),
          ),
        ),

        const SizedBox(height: 8),
        Divider(color: theme.colorScheme.outline.withValues(alpha: 0.1)),

        // Combined ingredient list grouped by recipe
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe name header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 12),
                    child: Row(
                      children: [
                        Icon(Icons.restaurant_menu,
                            size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${entry.value.length} items',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                  ...entry.value.map((ri) {
                    // Find which recipe this ingredient belongs to for userScale
                    final recipeNode = _result.recipes.firstWhere(
                          (r) => r.directIngredients.any((i) => i.ingredient.id == ri.ingredient.id),
                      orElse: () => _result.recipes.first,
                    );
                    final userScale = _userScaleForRecipe(recipeNode.recipeId);
                    final amt = _scaleAmount(ri.scaledAmount, userScale);
                    final unit = ri.ingredient.unit ?? '';
                    final amountStr =
                    [amt, unit].where((s) => s.isNotEmpty).join(' ');

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 72,
                            child: amountStr.isNotEmpty
                                ? Text(
                              amountStr,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            )
                                : null,
                          ),
                          Expanded(
                            child: Text(ri.ingredient.name,
                                style: theme.textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          ),
        ),

        // Confirm button
        _BottomActionBar(
          child: FilledButton.icon(
            onPressed: canConfirm ? _addToShoppingList : null,
            icon: _isAdding
                ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.add_shopping_cart),
            label: Text(_isAdding
                ? 'Adding...'
                : 'Add ${allSelected.length} items to list'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: const Color(0xFFE8A860),
            ),
          ),
        ),
      ],
    );
  }

  List<ResolvedIngredient> _getAllSelectedIngredients() {
    final items = <ResolvedIngredient>[];
    for (final recipe in _result.recipes) {
      final selected = _selections[recipe.recipeId] ?? {};
      items.addAll(recipe.directIngredients
          .where((ri) => selected.contains(ri.ingredient.id)));
    }
    return items;
  }

  /// Apply user scale multiplier to a formatted amount string.
  String _scaleAmount(String amountStr, double userScale) {
    if (userScale == 1.0 || amountStr.isEmpty) return amountStr;
    const fracs = {
      '½': 0.5, '¼': 0.25, '¾': 0.75, '⅓': 0.333, '⅔': 0.666,
      '⅛': 0.125, '⅜': 0.375, '⅝': 0.625, '⅞': 0.875,
    };
    double? parsed = double.tryParse(amountStr);
    if (parsed == null) {
      for (final e in fracs.entries) {
        if (amountStr == e.key) { parsed = e.value; break; }
        if (amountStr.contains(e.key)) {
          final parts = amountStr.split(e.key);
          parsed = (double.tryParse(parts[0].trim()) ?? 0) + e.value;
          break;
        }
      }
    }
    if (parsed != null) return formatAmount(parsed * userScale);
    return amountStr;
  }

  /// Get the effective user scale for a recipe (by recipeId).
  double _userScaleForRecipe(String recipeId) =>
      _userScales[recipeId] ?? 1.0;

  Future<void> _addToShoppingList() async {
    setState(() => _isAdding = true);

    try {
      final shoppingDao = ref.read(shoppingDaoProvider);

      // Determine target list
      String listId;
      if (_isCreatingNewList && _newListName.trim().isNotEmpty) {
        listId = 'list_${DateTime.now().millisecondsSinceEpoch}';
        await shoppingDao.insertList(ShoppingListsCompanion.insert(
          id: listId,
          name: _newListName.trim(),
        ));
      } else if (_selectedListId != null) {
        listId = _selectedListId!;
      } else {
        listId = 'list_${DateTime.now().millisecondsSinceEpoch}';
        await shoppingDao.insertList(ShoppingListsCompanion.insert(
          id: listId,
          name: 'Shopping List',
        ));
      }

      // Add ingredients per recipe using smart stacking
      for (final recipe in _result.recipes) {
        final selected = _selections[recipe.recipeId] ?? {};
        if (selected.isEmpty) continue;

        final userScale = _userScaleForRecipe(recipe.recipeId);

        final ingredientMaps = recipe.directIngredients
            .where((ri) => selected.contains(ri.ingredient.id))
            .map((ri) {
          final categoryId = getShoppingCategory(ri.ingredient.name);
          return <String, String?>{
            'name': ri.ingredient.name,
            'amount': _scaleAmount(ri.scaledAmount, userScale),
            'unit': ri.ingredient.unit ?? '',
            'categoryId': categoryId,
          };
        }).toList();

        await shoppingDao.addItemsFromRecipeWithStacking(
          listId: listId,
          recipeId: recipe.recipeId,
          recipeName: recipe.title,
          ingredients: ingredientMaps,
        );
      }

      if (mounted) {
        final totalAdded = _totalSelected;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $totalAdded items to shopping list'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'View',
              onPressed: () => context.go('/shopping'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// SHARED LAYOUT WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _BottomActionBar extends StatelessWidget {
  final Widget child;
  const _BottomActionBar({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        ),
      ),
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CONFLICT CARD
// ═══════════════════════════════════════════════════════════════════

class _ConflictCard extends StatelessWidget {
  final MultiLinkConflict conflict;
  final VoidCallback onChanged;

  const _ConflictCard({required this.conflict, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ingredient header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.link,
                      size: 18,
                      color: theme.colorScheme.onTertiaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conflict.ingredient.name,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'in ${conflict.parentRecipeName}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Links to ${conflict.options.length} recipes — select which to include:',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 8),

            // Recipe options
            ...conflict.options.map((option) {
              final isSelected =
              conflict.selectedRecipeIds.contains(option.recipeId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      .withValues(alpha: 0.4)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (isSelected) {
                        conflict.selectedRecipeIds.remove(option.recipeId);
                      } else {
                        conflict.selectedRecipeIds.add(option.recipeId);
                      }
                      onChanged();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          _AnimatedCheckbox(isSelected: isSelected),
                          const SizedBox(width: 12),
                          _RecipeThumbnail(
                            imagePath: option.imagePath,
                            recipeId: option.recipeId,
                            size: 36,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option.recipeTitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (option.scale != 1.0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('${option.scale}x',
                                  style: theme.textTheme.labelSmall),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// RECIPE CARD (collapsible)
// ═══════════════════════════════════════════════════════════════════

class _RecipeCard extends StatelessWidget {
  final ResolvedRecipeNode recipe;
  final bool isExpanded;
  final int selectedCount;
  final int totalCount;
  final Set<String> selectedIds;
  final List<ResolvedRecipeNode> allRecipes;
  final Map<String, GlobalKey> recipeKeys;
  final double userScale;
  final Set<String> pantryMatches;
  final VoidCallback onToggleExpand;
  final void Function(String) onToggleIngredient;
  final VoidCallback onSelectAll;
  final VoidCallback onUnselectAll;
  final void Function(String) onScrollToRecipe;
  final void Function(double) onScaleChanged;

  const _RecipeCard({
    super.key,
    required this.recipe,
    required this.isExpanded,
    required this.selectedCount,
    required this.totalCount,
    required this.selectedIds,
    required this.allRecipes,
    required this.recipeKeys,
    required this.userScale,
    required this.pantryMatches,
    required this.onToggleExpand,
    required this.onToggleIngredient,
    required this.onSelectAll,
    required this.onUnselectAll,
    required this.onScrollToRecipe,
    required this.onScaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header (always visible, tappable)
          InkWell(
            onTap: onToggleExpand,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _RecipeThumbnail(
                    imagePath: recipe.imagePath,
                    recipeId: recipe.recipeId,
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '$selectedCount/$totalCount ingredients',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: theme.colorScheme.outline),
                            ),
                            if (!recipe.isRoot) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'linked',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color:
                                    theme.colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                            ],
                            if (recipe.scale != 1.0) ...[
                              const SizedBox(width: 6),
                              Text(
                                '${recipe.scale}x',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.tertiary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Selection badge
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: selectedCount > 0
                          ? const Color(0xFFE8A860).withValues(alpha: 0.2)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$selectedCount',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: selectedCount > 0
                            ? const Color(0xFFE8A860)
                            : theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Chevron
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more,
                        color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
          ),

          // Expanded: ingredient list
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              children: [
                Divider(
                    height: 1,
                    color:
                    theme.colorScheme.outline.withValues(alpha: 0.1)),

                // Select all / none + scale
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: onSelectAll,
                        icon:
                        const Icon(Icons.check_box_outlined, size: 16),
                        label: const Text('All'),
                        style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact),
                      ),
                      TextButton.icon(
                        onPressed: onUnselectAll,
                        icon: const Icon(Icons.check_box_outline_blank,
                            size: 16),
                        label: const Text('None'),
                        style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact),
                      ),
                      const Spacer(),
                      // Scale selector
                      _ScaleSelector(
                        scale: userScale,
                        onChanged: onScaleChanged,
                      ),
                    ],
                  ),
                ),

                // Direct ingredients (checkable)
                ...recipe.directIngredients.map((ri) {
                  final isSelected =
                  selectedIds.contains(ri.ingredient.id);
                  final isPantry =
                  pantryMatches.contains(ri.ingredient.id);
                  return _IngredientRow(
                    ingredient: ri,
                    isSelected: isSelected,
                    isPantryItem: isPantry,
                    userScale: userScale,
                    onToggle: () => onToggleIngredient(ri.ingredient.id),
                  );
                }),

                // Linked ingredients (greyed out with jump link)
                ...recipe.linkedIngredients.map((linkedRef) {
                  return _LinkedIngredientRow(
                    linkedRef: linkedRef,
                    onScrollToRecipe: onScrollToRecipe,
                  );
                }),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// INGREDIENT ROWS
// ═══════════════════════════════════════════════════════════════════

class _IngredientRow extends StatelessWidget {
  final ResolvedIngredient ingredient;
  final bool isSelected;
  final bool isPantryItem;
  final double userScale;
  final VoidCallback onToggle;

  const _IngredientRow({
    required this.ingredient,
    required this.isSelected,
    this.isPantryItem = false,
    this.userScale = 1.0,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rawAmt = ingredient.scaledAmount;
    final unit = ingredient.ingredient.unit ?? '';

    // Apply user scale to displayed amount
    String amt = rawAmt;
    if (userScale != 1.0 && rawAmt.isNotEmpty) {
      const fracs = {
        '½': 0.5, '¼': 0.25, '¾': 0.75, '⅓': 0.333, '⅔': 0.666,
        '⅛': 0.125, '⅜': 0.375, '⅝': 0.625, '⅞': 0.875,
      };
      double? parsed = double.tryParse(rawAmt);
      if (parsed == null) {
        for (final e in fracs.entries) {
          if (rawAmt == e.key) { parsed = e.value; break; }
          if (rawAmt.contains(e.key)) {
            final parts = rawAmt.split(e.key);
            parsed = (double.tryParse(parts[0].trim()) ?? 0) + e.value;
            break;
          }
        }
      }
      if (parsed != null) amt = formatAmount(parsed * userScale);
    }

    final amountStr = [amt, unit].where((s) => s.isNotEmpty).join(' ');

    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _AnimatedCheckbox(
              isSelected: isSelected,
              color: const Color(0xFFE8A860),
            ),
            const SizedBox(width: 12),
            // Always reserve space for amount column so names align
            SizedBox(
              width: 72,
              child: amountStr.isNotEmpty
                  ? Text(
                amountStr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? null : theme.colorScheme.outline,
                ),
              )
                  : null,
            ),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      ingredient.ingredient.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        decoration:
                        isSelected ? null : TextDecoration.lineThrough,
                        color: isSelected ? null : theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  if (isPantryItem) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'pantry',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScaleSelector extends StatelessWidget {
  final double scale;
  final void Function(double) onChanged;

  const _ScaleSelector({required this.scale, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const presets = [0.5, 1.0, 2.0, 3.0];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.straighten, size: 14, color: theme.colorScheme.outline),
        const SizedBox(width: 4),
        ...presets.map((p) {
          final isActive = (scale - p).abs() < 0.01;
          final label = p == 0.5 ? '½×' : '${p.round()}×';
          return Padding(
            padding: const EdgeInsets.only(left: 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onChanged(p),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE8A860).withValues(alpha: 0.25)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFFE8A860)
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive
                        ? const Color(0xFFE8A860)
                        : theme.colorScheme.outline,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _LinkedIngredientRow extends StatelessWidget {
  final LinkedIngredientRef linkedRef;
  final void Function(String) onScrollToRecipe;

  const _LinkedIngredientRow({
    required this.linkedRef,
    required this.onScrollToRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = linkedRef.ingredient.name;
    final linkedTitle = linkedRef.options.first.recipeTitle;
    final linkedId = linkedRef.options.first.recipeId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Greyed link icon
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.link,
                size: 14, color: theme.colorScheme.outline),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                GestureDetector(
                  onTap: () => onScrollToRecipe(linkedId),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.subdirectory_arrow_right,
                            size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'See "$linkedTitle" below',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// LIST DESTINATION PICKER
// ═══════════════════════════════════════════════════════════════════

class _ListDestinationPicker extends StatelessWidget {
  final List<ShoppingList> existingLists;
  final String? selectedListId;
  final bool isCreatingNewList;
  final String newListName;
  final void Function(String) onListSelected;
  final VoidCallback onCreateNewList;
  final void Function(String) onNewListNameChanged;

  const _ListDestinationPicker({
    required this.existingLists,
    required this.selectedListId,
    required this.isCreatingNewList,
    required this.newListName,
    required this.onListSelected,
    required this.onCreateNewList,
    required this.onNewListNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Add to list',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (existingLists.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  ...existingLists.map((list) {
                    final isSelected =
                        !isCreatingNewList && selectedListId == list.id;
                    return ChoiceChip(
                      label: Text(list.name),
                      selected: isSelected,
                      onSelected: (_) => onListSelected(list.id),
                      selectedColor:
                      const Color(0xFFE8A860).withValues(alpha: 0.3),
                    );
                  }),
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: const Text('New list'),
                    onPressed: onCreateNewList,
                    backgroundColor: isCreatingNewList
                        ? theme.colorScheme.primaryContainer
                        : null,
                  ),
                ],
              )
            else
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('Create new list'),
                onPressed: onCreateNewList,
                backgroundColor: isCreatingNewList
                    ? theme.colorScheme.primaryContainer
                    : null,
              ),

            if (isCreatingNewList) ...[
              const SizedBox(height: 12),
              TextField(
                autofocus: true,
                onChanged: onNewListNameChanged,
                decoration: InputDecoration(
                  hintText: 'List name',
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _AnimatedCheckbox extends StatelessWidget {
  final bool isSelected;
  final Color color;

  const _AnimatedCheckbox({
    required this.isSelected,
    this.color = const Color(0xFF6750A4), // default primary
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = color == const Color(0xFF6750A4)
        ? theme.colorScheme.primary
        : color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isSelected ? activeColor : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected
              ? activeColor
              : theme.colorScheme.outline.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _RecipeThumbnail extends StatelessWidget {
  final String? imagePath;
  final String recipeId;
  final double size;

  const _RecipeThumbnail({
    required this.imagePath,
    required this.recipeId,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imagePath != null &&
        imagePath!.isNotEmpty &&
        File(imagePath!).existsSync();
    final defaultAsset = defaultRecipeImageAsset(recipeId);

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.25),
      child: SizedBox(
        width: size,
        height: size,
        child: hasImage
            ? Image.file(File(imagePath!),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(theme))
            : defaultAsset != null
            ? Image.asset(defaultAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(theme))
            : _placeholder(theme),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(Icons.restaurant_menu,
          size: size * 0.5, color: theme.colorScheme.outline),
    );
  }
}