import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../widgets/placeholder_image.dart';
import '../../../data/nutrition_data.dart';
import '../../widgets/allergy_warning.dart';

class RecipeScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const RecipeScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen> with SingleTickerProviderStateMixin {
  Recipe? _recipe;
  List<Ingredient> _ingredients = [];
  List<Step> _steps = [];
  NutritionData? _nutrition;
  bool _isLoading = true;
  double _scaleFactor = 1.0;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3 tabs: Nutrition | Ingredients | Instructions
    // Start on Ingredients (index 1)
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _loadRecipe();
    _markAsViewed();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipe() async {
    final dao = ref.read(recipeDaoProvider);
    final recipe = await dao.getRecipeById(widget.recipeId);
    if (recipe == null) {
      if (mounted) context.pop();
      return;
    }

    final ingredients = await dao.getIngredientsForRecipe(widget.recipeId);
    final steps = await dao.getStepsForRecipe(widget.recipeId);

    // Load nutrition from recipe.nutritionJson
    NutritionData? nutrition;
    if (recipe.nutritionJson != null && recipe.nutritionJson!.isNotEmpty) {
      try {
        final json = jsonDecode(recipe.nutritionJson!) as Map<String, dynamic>;
        nutrition = NutritionData.fromJson(json);
      } catch (e) {
        // Ignore parse errors
      }
    }

    setState(() {
      _recipe = recipe;
      _ingredients = ingredients;
      _steps = steps;
      _nutrition = nutrition;
      _isLoading = false;
    });
  }

  Future<void> _markAsViewed() async {
    await ref.read(recipeDaoProvider).updateLastViewed(widget.recipeId);
  }

  Future<void> _navigateToEdit() async {
    await context.push('/recipe/${widget.recipeId}/edit');
    if (mounted) {
      _loadRecipe();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final isNerdMode = settings.nerdMode;
    final useTabbed = settings.recipeLayoutMode == RecipeLayoutMode.tabbed;

    if (_isLoading || _recipe == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: useTabbed
          ? _buildTabbedLayout(theme, l10n, isNerdMode)
          : _buildStackedLayout(theme, l10n, isNerdMode),
    );
  }

  Widget _buildStackedLayout(ThemeData theme, AppLocalizations l10n, bool isNerdMode) {
    return CustomScrollView(
      slivers: [
        _RecipeAppBar(recipe: _recipe!, onEdit: _navigateToEdit, onDelete: () => _confirmDelete(context), onTogglePin: _togglePin),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(_recipe!.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
                    _FavoriteButton(isFavorite: _recipe!.isFavorite, onToggle: _toggleFavorite),
                  ],
                ),
                if (_recipe!.rating != null && _recipe!.rating! > 0) ...[
                  const SizedBox(height: 8),
                  RecipeRating(rating: _recipe!.rating!, nerdMode: isNerdMode),
                ],
                if (_recipe!.description != null && _recipe!.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_recipe!.description!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
                const SizedBox(height: 16),
                _QuickActionsRow(onAddToMealPlan: _showAddToMealPlanSheet, onAddToShopping: _showAddToShoppingSheet),
                const SizedBox(height: 20),
                _RecipeMetaInfo(recipe: _recipe!, scaleFactor: _scaleFactor, onScaleChanged: (scale) => setState(() => _scaleFactor = scale)),

                // Allergy warning banner
                const SizedBox(height: 16),
                AllergyWarningBanner(
                  ingredients: _ingredients.map((i) => i.name).toList(),
                ),

                const SizedBox(height: 24),
                _SectionHeader(title: l10n.ingredientsTitle, trailing: _scaleFactor != 1.0 ? Text('${_scaleFactor}x', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)) : null),
                const SizedBox(height: 12),
                ..._ingredients.map((ing) => _IngredientItem(ingredient: ing, scaleFactor: _scaleFactor)),
                const SizedBox(height: 32),
                _SectionHeader(title: l10n.instructionsTitle),
                const SizedBox(height: 12),
                ..._steps.asMap().entries.map((entry) => _InstructionStep(stepNumber: entry.key + 1, instruction: entry.value.instruction)),
                if (_recipe!.notes != null && _recipe!.notes!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _SectionHeader(title: l10n.recipeFieldNotes),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                    child: Text(_recipe!.notes!, style: theme.textTheme.bodyMedium),
                  ),
                ],
                // Nutrition section at bottom
                const SizedBox(height: 32),
                _SectionHeader(title: l10n.nutritionTitle),
                const SizedBox(height: 12),
                _NutritionDisplay(nutrition: _nutrition, scaleFactor: _scaleFactor, l10n: l10n, servings: _recipe!.servings),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabbedLayout(ThemeData theme, AppLocalizations l10n, bool isNerdMode) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _RecipeAppBar(recipe: _recipe!, onEdit: _navigateToEdit, onDelete: () => _confirmDelete(context), onTogglePin: _togglePin),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(_recipe!.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
                    _FavoriteButton(isFavorite: _recipe!.isFavorite, onToggle: _toggleFavorite),
                  ],
                ),
                if (_recipe!.rating != null && _recipe!.rating! > 0) ...[
                  const SizedBox(height: 8),
                  RecipeRating(rating: _recipe!.rating!, nerdMode: isNerdMode),
                ],
                if (_recipe!.description != null && _recipe!.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_recipe!.description!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
                const SizedBox(height: 16),
                _QuickActionsRow(onAddToMealPlan: _showAddToMealPlanSheet, onAddToShopping: _showAddToShoppingSheet),
                const SizedBox(height: 20),
                _RecipeMetaInfo(recipe: _recipe!, scaleFactor: _scaleFactor, onScaleChanged: (scale) => setState(() => _scaleFactor = scale)),

                // Allergy warning banner
                const SizedBox(height: 16),
                AllergyWarningBanner(
                  ingredients: _ingredients.map((i) => i.name).toList(),
                ),
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverTabBarDelegate(
            TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: theme.colorScheme.primary,
              tabs: [
                Tab(icon: Icon(Icons.local_fire_department, size: 20), text: l10n.nutritionTitle),
                Tab(icon: Icon(Icons.checklist, size: 20), text: l10n.ingredientsTitle),
                Tab(icon: Icon(Icons.format_list_numbered, size: 20), text: l10n.instructionsTitle),
              ],
            ),
            theme.colorScheme.surface,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _NutritionTab(nutrition: _nutrition, scaleFactor: _scaleFactor, l10n: l10n, servings: _recipe!.servings),
          _IngredientsTab(ingredients: _ingredients, scaleFactor: _scaleFactor, l10n: l10n),
          _InstructionsTab(steps: _steps, notes: _recipe!.notes, l10n: l10n),
        ],
      ),
    );
  }

  void _showAddToMealPlanSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _AddToMealPlanSheet(recipeId: widget.recipeId, recipeTitle: _recipe!.title, ref: ref),
    );
  }

  void _showAddToShoppingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _AddToShoppingSheet(ingredients: _ingredients, recipeId: widget.recipeId, recipeTitle: _recipe!.title, scaleFactor: _scaleFactor, ref: ref),
    );
  }

  void _toggleFavorite() async {
    await ref.read(recipeDaoProvider).toggleFavorite(widget.recipeId, !_recipe!.isFavorite);
    await _loadRecipe();
  }

  void _togglePin() async {
    final l10n = AppLocalizations.of(context)!;
    await ref.read(recipeDaoProvider).togglePin(widget.recipeId, !_recipe!.isPinned);
    await _loadRecipe();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_recipe!.isPinned ? l10n.recipePin : l10n.recipeUnpin), duration: const Duration(seconds: 2)));
    }
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.recipeDelete),
        content: Text(l10n.confirmDeleteMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(recipeDaoProvider).softDeleteRecipe(widget.recipeId);
              if (mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.successDeleted)));
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _backgroundColor;
  _SliverTabBarDelegate(this._tabBar, this._backgroundColor);
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: _backgroundColor, child: _tabBar);
  @override bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

class _NutritionTab extends StatelessWidget {
  final NutritionData? nutrition;
  final double scaleFactor;
  final AppLocalizations l10n;
  final String? servings;
  const _NutritionTab({required this.nutrition, required this.scaleFactor, required this.l10n, this.servings});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _NutritionDisplay(nutrition: nutrition, scaleFactor: scaleFactor, l10n: l10n, servings: servings),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _NutritionDisplay extends StatefulWidget {
  final NutritionData? nutrition;
  final double scaleFactor;
  final AppLocalizations l10n;
  final String? servings; // e.g., "4" or "4-6"

  const _NutritionDisplay({
    this.nutrition,
    this.scaleFactor = 1.0,
    required this.l10n,
    this.servings,
  });

  @override
  State<_NutritionDisplay> createState() => _NutritionDisplayState();
}

class _NutritionDisplayState extends State<_NutritionDisplay> {
  bool _showPerServing = true; // Default to per serving

  int? _parseServings() {
    if (widget.servings == null || widget.servings!.isEmpty) return null;
    // Handle ranges like "4-6" by taking first number
    final match = RegExp(r'(\d+)').firstMatch(widget.servings!);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = widget.l10n;

    if (widget.nutrition == null || widget.nutrition!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(Icons.local_fire_department_outlined, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(l10n.nutritionEmpty, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(l10n.nutritionEmptyHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    // Apply scale factor first
    var displayNutrition = widget.scaleFactor != 1.0 ? widget.nutrition!.scaled(widget.scaleFactor) : widget.nutrition!;

    // Then apply per-serving division if enabled
    final servingsCount = _parseServings();
    final canShowPerServing = servingsCount != null && servingsCount > 0;

    if (_showPerServing && canShowPerServing) {
      displayNutrition = displayNutrition.scaled(1.0 / servingsCount);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with calories
          Row(
            children: [
              Icon(Icons.local_fire_department, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.nutritionCalories, style: theme.textTheme.titleMedium),
              ),
              if (displayNutrition.calories != null)
                Text(
                  '${displayNutrition.calories!.round()}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),

          // Per serving toggle
          if (canShowPerServing) ...[
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: true,
                  label: Text(l10n.nutritionPerServing),
                  icon: const Icon(Icons.person, size: 16),
                ),
                ButtonSegment(
                  value: false,
                  label: Text(l10n.nutritionTotal),
                  icon: const Icon(Icons.summarize, size: 16),
                ),
              ],
              selected: {_showPerServing},
              onSelectionChanged: (selection) {
                setState(() => _showPerServing = selection.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(theme.textTheme.labelSmall),
              ),
            ),
          ],

          const Divider(height: 24),

          Row(children: [
            Expanded(child: _NutrientTile(label: l10n.nutritionProtein, value: displayNutrition.protein, unit: 'g', theme: theme)),
            Expanded(child: _NutrientTile(label: l10n.nutritionCarbs, value: displayNutrition.carbohydrates, unit: 'g', theme: theme)),
            Expanded(child: _NutrientTile(label: l10n.nutritionFat, value: displayNutrition.fat, unit: 'g', theme: theme)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _NutrientTile(label: l10n.nutritionFiber, value: displayNutrition.fiber, unit: 'g', theme: theme)),
            Expanded(child: _NutrientTile(label: l10n.nutritionSugar, value: displayNutrition.sugar, unit: 'g', theme: theme)),
            Expanded(child: _NutrientTile(label: l10n.nutritionSodium, value: displayNutrition.sodium, unit: 'mg', theme: theme)),
          ]),
          if (displayNutrition.calcium != null || displayNutrition.iron != null || displayNutrition.vitaminC != null) ...[
            const Divider(height: 24),
            Row(children: [
              Expanded(child: _NutrientTile(label: l10n.nutritionCalcium, value: displayNutrition.calcium, unit: 'mg', theme: theme)),
              Expanded(child: _NutrientTile(label: l10n.nutritionIron, value: displayNutrition.iron, unit: 'mg', theme: theme)),
              Expanded(child: _NutrientTile(label: l10n.nutritionVitaminC, value: displayNutrition.vitaminC, unit: 'mg', theme: theme)),
            ]),
          ],

          // Info labels
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (_showPerServing && canShowPerServing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    '1 of $servingsCount servings',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                  ),
                ),
              if (widget.scaleFactor != 1.0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    '${widget.scaleFactor}x ${l10n.scaled}',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NutrientTile extends StatelessWidget {
  final String label;
  final double? value;
  final String unit;
  final ThemeData theme;
  const _NutrientTile({required this.label, required this.value, required this.unit, required this.theme});

  @override
  Widget build(BuildContext context) {
    final displayValue = value == null ? '-' : value! < 1 ? value!.toStringAsFixed(1) : value!.round().toString();
    return Column(children: [
      Text(displayValue, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      if (value != null) Text(unit, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
      const SizedBox(height: 4),
      Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline), textAlign: TextAlign.center),
    ]);
  }
}

class _IngredientsTab extends ConsumerWidget {
  final List<Ingredient> ingredients;
  final double scaleFactor;
  final AppLocalizations l10n;
  const _IngredientsTab({required this.ingredients, required this.scaleFactor, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (ingredients.isEmpty) return Center(child: Text(l10n.ingredientsEmpty, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ingredients.length,
      itemBuilder: (context, index) => _IngredientItemWithAllergen(ingredient: ingredients[index], scaleFactor: scaleFactor),
    );
  }
}

class _InstructionsTab extends StatelessWidget {
  final List<Step> steps;
  final String? notes;
  final AppLocalizations l10n;
  const _InstructionsTab({required this.steps, this.notes, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (steps.isEmpty) return Center(child: Text(l10n.instructionsEmpty, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...steps.asMap().entries.map((entry) => _InstructionStep(stepNumber: entry.key + 1, instruction: entry.value.instruction)),
        if (notes != null && notes!.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.recipeFieldNotes),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: Text(notes!, style: theme.textTheme.bodyMedium)),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

class _AddToShoppingSheet extends StatefulWidget {
  final List<Ingredient> ingredients;
  final String recipeId;
  final String recipeTitle;
  final double scaleFactor;
  final WidgetRef ref;
  const _AddToShoppingSheet({required this.ingredients, required this.recipeId, required this.recipeTitle, required this.scaleFactor, required this.ref});
  @override State<_AddToShoppingSheet> createState() => _AddToShoppingSheetState();
}

class _AddToShoppingSheetState extends State<_AddToShoppingSheet> {
  late Set<String> _selectedIds;
  bool _isAdding = false;

  @override
  void initState() { super.initState(); _selectedIds = widget.ingredients.map((i) => i.id).toSet(); }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [Icon(Icons.shopping_cart, color: theme.colorScheme.primary), const SizedBox(width: 12), Expanded(child: Text(l10n.recipeAddToShoppingList, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
          const SizedBox(height: 16),
          Text('${_selectedIds.length} / ${widget.ingredients.length} ${l10n.ingredientsTitle.toLowerCase()}'),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _isAdding ? null : _addToList, icon: _isAdding ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add), label: Text(l10n.recipeAddToShoppingList))),
        ]),
      ),
    );
  }

  Future<void> _addToList() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isAdding = true);
    try {
      final shoppingDao = widget.ref.read(shoppingDaoProvider);
      final selectedIngredients = widget.ingredients.where((i) => _selectedIds.contains(i.id)).map((i) {
        final parts = <String>[];
        if (i.amount != null && i.amount!.isNotEmpty) parts.add(i.amount!);
        if (i.unit != null && i.unit!.isNotEmpty) parts.add(i.unit!);
        parts.add(i.name);
        return parts.join(' ');
      }).toList();
      await shoppingDao.addItemsFromRecipe(listId: 'list_default', recipeId: widget.recipeId, ingredients: selectedIngredients);
      if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.successAdded))); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.errorGeneric}: $e'))); }
    finally { if (mounted) setState(() => _isAdding = false); }
  }
}

class _AddToMealPlanSheet extends StatefulWidget {
  final String recipeId;
  final String recipeTitle;
  final WidgetRef ref;
  const _AddToMealPlanSheet({required this.recipeId, required this.recipeTitle, required this.ref});
  @override State<_AddToMealPlanSheet> createState() => _AddToMealPlanSheetState();
}

class _AddToMealPlanSheetState extends State<_AddToMealPlanSheet> {
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [Icon(Icons.calendar_month, color: theme.colorScheme.primary), const SizedBox(width: 12), Expanded(child: Text(l10n.recipeAddToMealPlan, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _isSaving ? null : _addToMealPlan, icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add), label: Text(l10n.recipeAddToMealPlan))),
        ]),
      ),
    );
  }

  Future<void> _addToMealPlan() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);
    try {
      final mealPlanDao = widget.ref.read(mealPlanDaoProvider);
      final id = 'meal_${DateTime.now().millisecondsSinceEpoch}';
      final date = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      await mealPlanDao.insertMealPlan(MealPlansCompanion.insert(id: id, date: date, recipeId: drift.Value(widget.recipeId)));
      if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.successSaved))); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.errorGeneric}: $e'))); }
    finally { if (mounted) setState(() => _isSaving = false); }
  }
}

class _RecipeAppBar extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  const _RecipeAppBar({required this.recipe, required this.onEdit, required this.onDelete, required this.onTogglePin});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasImage = recipe.imagePath != null && File(recipe.imagePath!).existsSync();
    return SliverAppBar(
      expandedHeight: 300, pinned: true,
      leading: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop())),
      flexibleSpace: FlexibleSpaceBar(background: hasImage ? Stack(fit: StackFit.expand, children: [Image.file(File(recipe.imagePath!), fit: BoxFit.cover), Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.5), Colors.transparent, Colors.black.withOpacity(0.5)])))]) : const RecipePlaceholderImage(height: 300, width: double.infinity)),
      actions: [
        Container(margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: onEdit, tooltip: l10n.actionEdit)),
        Container(
          margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) { if (value == 'pin') onTogglePin(); else if (value == 'delete') onDelete(); },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'pin', child: Row(children: [Icon(recipe.isPinned ? Icons.push_pin : Icons.push_pin_outlined), const SizedBox(width: 12), Text(recipe.isPinned ? l10n.recipeUnpin : l10n.recipePin)])),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete, color: Colors.red), const SizedBox(width: 12), Text(l10n.actionDelete, style: const TextStyle(color: Colors.red))])),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onAddToMealPlan;
  final VoidCallback onAddToShopping;
  const _QuickActionsRow({required this.onAddToMealPlan, required this.onAddToShopping});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
      ActionChip(avatar: const Icon(Icons.calendar_month, size: 18), label: Text(l10n.plannerTitle), onPressed: onAddToMealPlan),
      const SizedBox(width: 8),
      ActionChip(avatar: const Icon(Icons.shopping_cart, size: 18), label: Text(l10n.shoppingTitle), onPressed: onAddToShopping),
    ]));
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  const _FavoriteButton({required this.isFavorite, required this.onToggle});
  @override Widget build(BuildContext context) => IconButton(icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : null), onPressed: onToggle);
}

class RecipeRating extends StatelessWidget {
  final int rating;
  final bool nerdMode;
  const RecipeRating({super.key, required this.rating, this.nerdMode = false});
  @override Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (nerdMode) return _RpgRating(rating: rating, l10n: l10n);
    return Row(children: List.generate(5, (index) => Icon(index < rating ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.amber, size: 20)));
  }
}

class _RpgRating extends StatelessWidget {
  final int rating;
  final AppLocalizations l10n;
  const _RpgRating({required this.rating, required this.l10n});
  @override Widget build(BuildContext context) {
    final (label, color, icon) = _getRarityInfo(rating);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.5))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: color), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13))]));
  }
  (String, Color, IconData) _getRarityInfo(int rating) {
    switch (rating) {
      case 1: return (l10n.ratingCommon, const Color(0xFF9E9E9E), Icons.circle_outlined);
      case 2: return (l10n.ratingUncommon, const Color(0xFF4CAF50), Icons.eco);
      case 3: return (l10n.ratingRare, const Color(0xFF2196F3), Icons.diamond_outlined);
      case 4: return (l10n.ratingEpic, const Color(0xFF9C27B0), Icons.auto_awesome);
      case 5: return (l10n.ratingLegendary, const Color(0xFFFF9800), Icons.local_fire_department);
      default: return (l10n.ratingUnrated, Colors.grey, Icons.help_outline);
    }
  }
}

class _RecipeMetaInfo extends StatelessWidget {
  final Recipe recipe;
  final double scaleFactor;
  final ValueChanged<double> onScaleChanged;
  const _RecipeMetaInfo({required this.recipe, required this.scaleFactor, required this.onScaleChanged});

  @override Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        if (recipe.prepTimeMinutes != null) _MetaItem(icon: Icons.timer_outlined, label: l10n.recipeFieldPrepTime, value: '${recipe.prepTimeMinutes} ${l10n.minutesAbbrev}'),
        if (recipe.cookTimeMinutes != null) _MetaItem(icon: Icons.local_fire_department, label: l10n.recipeFieldCookTime, value: '${recipe.cookTimeMinutes} ${l10n.minutesAbbrev}'),
        if (recipe.servings != null) GestureDetector(onTap: () => _showScaleDialog(context), child: _MetaItem(icon: Icons.restaurant, label: l10n.recipeFieldServings, value: _getScaledServings(), highlight: scaleFactor != 1.0)),
      ]),
    );
  }
  String _getScaledServings() { if (recipe.servings == null) return '-'; final original = int.tryParse(recipe.servings!) ?? 0; if (scaleFactor == 1.0) return recipe.servings!; return (original * scaleFactor).round().toString(); }
  void _showScaleDialog(BuildContext context) { showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Scale'), content: Wrap(spacing: 8, runSpacing: 8, children: [0.5, 1.0, 1.5, 2.0, 3.0, 4.0].map((scale) => ChoiceChip(label: Text('${scale}x'), selected: scaleFactor == scale, onSelected: (_) { Navigator.pop(ctx); onScaleChanged(scale); })).toList()))); }
}

class _MetaItem extends StatelessWidget {
  final IconData icon; final String label; final String value; final bool highlight;
  const _MetaItem({required this.icon, required this.label, required this.value, this.highlight = false});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(children: [Icon(icon, color: highlight ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant), const SizedBox(height: 4), Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: highlight ? theme.colorScheme.primary : null)), Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline))]);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title; final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(children: [Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), if (trailing != null) ...[const Spacer(), trailing!]]);
  }
}

class _IngredientItem extends StatelessWidget {
  final Ingredient ingredient; final double scaleFactor;
  const _IngredientItem({required this.ingredient, required this.scaleFactor});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String amount = ingredient.amount ?? '';
    if (scaleFactor != 1.0 && amount.isNotEmpty) { final num = double.tryParse(amount.replaceAll(RegExp(r'[^\d.]'), '')); if (num != null) { final scaled = num * scaleFactor; amount = scaled == scaled.roundToDouble() ? scaled.round().toString() : scaled.toStringAsFixed(1); } }
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(margin: const EdgeInsets.only(top: 6), width: 8, height: 8, decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle)),
      const SizedBox(width: 12),
      if (amount.isNotEmpty) ...[Text(amount, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)), const SizedBox(width: 4)],
      if (ingredient.unit != null && ingredient.unit!.isNotEmpty) ...[Text(ingredient.unit!, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)), const SizedBox(width: 4)],
      Expanded(child: Text(ingredient.name, style: theme.textTheme.bodyLarge)),
    ]));
  }
}

/// Ingredient item with allergen indicator
class _IngredientItemWithAllergen extends StatelessWidget {
  final Ingredient ingredient;
  final double scaleFactor;
  const _IngredientItemWithAllergen({required this.ingredient, required this.scaleFactor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String amount = ingredient.amount ?? '';
    if (scaleFactor != 1.0 && amount.isNotEmpty) {
      final num = double.tryParse(amount.replaceAll(RegExp(r'[^\d.]'), ''));
      if (num != null) {
        final scaled = num * scaleFactor;
        amount = scaled == scaled.roundToDouble() ? scaled.round().toString() : scaled.toStringAsFixed(1);
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin: const EdgeInsets.only(top: 6), width: 8, height: 8, decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          if (amount.isNotEmpty) ...[Text(amount, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)), const SizedBox(width: 4)],
          if (ingredient.unit != null && ingredient.unit!.isNotEmpty) ...[Text(ingredient.unit!, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)), const SizedBox(width: 4)],
          Expanded(child: Text(ingredient.name, style: theme.textTheme.bodyLarge)),
          // Allergen indicator
          AllergenIndicator(ingredientText: ingredient.name),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int stepNumber; final String instruction;
  const _InstructionStep({required this.stepNumber, required this.instruction});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 28, height: 28, decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle), child: Center(child: Text('$stepNumber', style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)))),
      const SizedBox(width: 12),
      Expanded(child: Text(instruction, style: theme.textTheme.bodyLarge)),
    ]));
  }
}