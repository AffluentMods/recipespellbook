import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../widgets/placeholder_image.dart';
import '../../../data/nutrition_data.dart';
import '../../../data/allergen_data.dart';
import '../../widgets/recipe_tags_display.dart';

// ============ DISMISSED ALLERGY WARNINGS PROVIDER ============

final dismissedAllergyWarningsProvider = StateNotifierProvider<DismissedAllergyWarningsNotifier, Set<String>>((ref) {
  return DismissedAllergyWarningsNotifier();
});

class DismissedAllergyWarningsNotifier extends StateNotifier<Set<String>> {
  DismissedAllergyWarningsNotifier() : super({}) {
    _load();
  }

  static const _prefsKey = 'dismissed_allergy_warnings';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    state = list.toSet();
  }

  Future<void> dismiss(String recipeId) async {
    state = {...state, recipeId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, state.toList());
  }

  Future<void> restore(String recipeId) async {
    state = {...state}..remove(recipeId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, state.toList());
  }

  bool isDismissed(String recipeId) => state.contains(recipeId);
}

// ============ MAIN SCREEN ============

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
  bool _showNutritionPerServing = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
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

    // Parse nutrition from nutritionJson field
    NutritionData? nutrition;
    if (recipe.nutritionJson != null && recipe.nutritionJson!.isNotEmpty) {
      try {
        final json = jsonDecode(recipe.nutritionJson!) as Map<String, dynamic>;
        nutrition = NutritionData.fromJson(json);
      } catch (e) {
        debugPrint('Failed to parse nutrition JSON: $e');
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
        _RecipeAppBar(
          recipe: _recipe!,
          ref: ref,
          onEdit: _navigateToEdit,
          onReload: _loadRecipe,
        ),
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
                // Rating/Rarity badge
                if (_recipe!.rating != null && _recipe!.rating! > 0) ...[
                  const SizedBox(height: 8),
                  RecipeRating(rating: _recipe!.rating!, nerdMode: isNerdMode),
                ],
                // Tags display
                const SizedBox(height: 12),
                RecipeTagsDisplay(recipeId: widget.recipeId),

                if (_recipe!.description != null && _recipe!.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_recipe!.description!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
                const SizedBox(height: 16),
                _QuickActionsRow(onAddToMealPlan: _showAddToMealPlanSheet, onAddToShopping: _showAddToShoppingSheet),
                const SizedBox(height: 20),

                // Recipe meta info with custom scale picker
                _RecipeMetaInfoWithScale(
                  recipe: _recipe!,
                  scaleFactor: _scaleFactor,
                  onScaleChanged: (scale) => setState(() => _scaleFactor = scale),
                ),

                // Dismissible Allergy warning banner
                const SizedBox(height: 16),
                _DismissibleAllergyWarning(
                  recipeId: widget.recipeId,
                  ingredientTexts: _ingredients.map((i) => i.name).toList(),
                ),

                const SizedBox(height: 24),
                _SectionHeader(title: l10n.ingredientsTitle, trailing: _scaleFactor != 1.0 ? Text('${_scaleFactor}x', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)) : null),
                const SizedBox(height: 12),
                ..._ingredients.map((ing) => _IngredientItemWithAllergen(ingredient: ing, scaleFactor: _scaleFactor)),
                const SizedBox(height: 32),
                _SectionHeader(title: l10n.instructionsTitle),
                const SizedBox(height: 12),
                ..._steps.asMap().entries.map((entry) => _InstructionStep(
                  stepNumber: entry.key + 1,
                  step: entry.value,
                )),
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
                // Nutrition section - using proper nutritionJson data
                const SizedBox(height: 32),
                _SectionHeader(title: l10n.nutritionTitle),
                const SizedBox(height: 12),
                _ModernNutritionCard(
                  nutrition: _nutrition,
                  scaleFactor: _scaleFactor,
                  l10n: l10n,
                  servings: _recipe!.servings,
                  showPerServing: _showNutritionPerServing,
                  onTogglePerServing: (value) => setState(() => _showNutritionPerServing = value),
                ),
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
        _RecipeAppBar(
          recipe: _recipe!,
          ref: ref,
          onEdit: _navigateToEdit,
          onReload: _loadRecipe,
        ),
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
                const SizedBox(height: 12),
                RecipeTagsDisplay(recipeId: widget.recipeId),

                if (_recipe!.description != null && _recipe!.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_recipe!.description!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
                const SizedBox(height: 16),
                _QuickActionsRow(onAddToMealPlan: _showAddToMealPlanSheet, onAddToShopping: _showAddToShoppingSheet),
                const SizedBox(height: 20),
                _RecipeMetaInfoWithScale(
                  recipe: _recipe!,
                  scaleFactor: _scaleFactor,
                  onScaleChanged: (scale) => setState(() => _scaleFactor = scale),
                ),

                const SizedBox(height: 16),
                _DismissibleAllergyWarning(
                  recipeId: widget.recipeId,
                  ingredientTexts: _ingredients.map((i) => i.name).toList(),
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
          _NutritionTab(
            nutrition: _nutrition,
            scaleFactor: _scaleFactor,
            l10n: l10n,
            servings: _recipe!.servings,
            showPerServing: _showNutritionPerServing,
            onTogglePerServing: (value) => setState(() => _showNutritionPerServing = value),
          ),
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
}

// ============ DISMISSIBLE ALLERGY WARNING ============

class _DismissibleAllergyWarning extends ConsumerWidget {
  final String recipeId;
  final List<String> ingredientTexts;

  const _DismissibleAllergyWarning({
    required this.recipeId,
    required this.ingredientTexts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final dismissedWarnings = ref.watch(dismissedAllergyWarningsProvider);

    // Check if user has any allergies set
    final userAllergies = settings.allergens;
    if (userAllergies.isEmpty) return const SizedBox.shrink();

    // Check if this recipe's warning was dismissed
    if (dismissedWarnings.contains(recipeId)) return const SizedBox.shrink();

    // Check ingredients for allergens
    final detectedAllergens = <String>[];
    for (final ingredientText in ingredientTexts) {
      final allergens = AllergenData.detectAllergens(ingredientText);
      for (final allergen in allergens) {
        if (userAllergies.contains(allergen) && !detectedAllergens.contains(allergen)) {
          detectedAllergens.add(allergen);
        }
      }
    }

    if (detectedAllergens.isEmpty) return const SizedBox.shrink();

    // Get localized allergen names
    final allergenNames = detectedAllergens.map((a) => AllergenData.getLocalizedName(a, l10n)).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.allergyWarningTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.allergyWarningContains} ${allergenNames.join(", ")}',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.red.shade900),
                      ),
                    ],
                  ),
                ),
                // Dismiss button
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red.shade700, size: 20),
                  tooltip: 'Dismiss for this recipe',
                  onPressed: () {
                    ref.read(dismissedAllergyWarningsProvider.notifier).dismiss(recipeId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Warning dismissed for this recipe'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            ref.read(dismissedAllergyWarningsProvider.notifier).restore(recipeId);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Manage allergies link
          InkWell(
            onTap: () => context.push('/settings/allergies'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, size: 16, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Text(
                    l10n.allergyManageSettings,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ RECIPE META INFO WITH CUSTOM SCALE ============

class _RecipeMetaInfoWithScale extends StatelessWidget {
  final Recipe recipe;
  final double scaleFactor;
  final ValueChanged<double> onScaleChanged;

  const _RecipeMetaInfoWithScale({
    required this.recipe,
    required this.scaleFactor,
    required this.onScaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Time and servings row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (recipe.prepTimeMinutes != null)
                _MetaItem(icon: Icons.timer_outlined, label: l10n.recipeFieldPrepTime, value: '${recipe.prepTimeMinutes} ${l10n.minutesAbbrev}'),
              if (recipe.cookTimeMinutes != null)
                _MetaItem(icon: Icons.local_fire_department, label: l10n.recipeFieldCookTime, value: '${recipe.cookTimeMinutes} ${l10n.minutesAbbrev}'),
              if (recipe.servings != null)
                _MetaItem(
                  icon: Icons.restaurant,
                  label: l10n.recipeFieldServings,
                  value: _getScaledServings(),
                  highlight: scaleFactor != 1.0,
                ),
            ],
          ),

          // Scale picker
          if (recipe.servings != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _CustomScalePicker(
              currentScale: scaleFactor,
              servings: recipe.servings,
              onScaleChanged: onScaleChanged,
            ),
          ],
        ],
      ),
    );
  }

  String _getScaledServings() {
    if (recipe.servings == null) return '-';
    final match = RegExp(r'\d+').firstMatch(recipe.servings!);
    if (match == null) return recipe.servings!;
    final original = int.tryParse(match.group(0)!) ?? 0;
    if (scaleFactor == 1.0) return recipe.servings!;
    return (original * scaleFactor).round().toString();
  }
}

// ============ CUSTOM SCALE PICKER ============

class _CustomScalePicker extends StatelessWidget {
  final double currentScale;
  final String? servings;
  final ValueChanged<double> onScaleChanged;

  const _CustomScalePicker({
    required this.currentScale,
    this.servings,
    required this.onScaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presets = [0.5, 1.0, 1.5, 2.0, 3.0, 4.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Scale recipe', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final preset in presets)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _ScaleChip(
                    label: preset == 1.0 ? '1x' : '${preset}x',
                    isSelected: currentScale == preset,
                    onTap: () => onScaleChanged(preset),
                  ),
                ),
              // Custom button
              _ScaleChip(
                label: 'Custom',
                isSelected: !presets.contains(currentScale),
                onTap: () => _showCustomDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCustomDialog(BuildContext context) {
    final controller = TextEditingController(text: currentScale.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Custom Scale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Scale factor',
                hintText: 'e.g., 2.5',
                suffixText: 'x',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter any number (e.g., 0.75 for ¾, 2.5 for 2½)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0 && value <= 100) {
                onScaleChanged(value);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _ScaleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScaleChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8A860) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ============ SLIVER TAB BAR ============

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _backgroundColor;
  _SliverTabBarDelegate(this._tabBar, this._backgroundColor);
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: _backgroundColor, child: _tabBar);
  @override bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

// ============ MODERN NUTRITION CARD ============

class _DailyValues {
  static const double fat = 78;
  static const double saturatedFat = 20;
  static const double carbohydrates = 275;
  static const double fiber = 28;
  static const double sugar = 50;
  static const double protein = 50;
  static const double sodium = 2300;
  static const double cholesterol = 300;
  static const double potassium = 4700;
  static const double calcium = 1300;
  static const double iron = 18;
  static const double vitaminA = 900;
  static const double vitaminC = 90;
  static const double vitaminD = 20;
}

class _ModernNutritionCard extends StatelessWidget {
  final NutritionData? nutrition;
  final double scaleFactor;
  final AppLocalizations l10n;
  final String? servings;
  final bool showPerServing;
  final ValueChanged<bool>? onTogglePerServing;

  const _ModernNutritionCard({
    this.nutrition,
    this.scaleFactor = 1.0,
    required this.l10n,
    this.servings,
    this.showPerServing = true,
    this.onTogglePerServing,
  });

  int? _parseServings() {
    if (servings == null || servings!.isEmpty) return null;
    final match = RegExp(r'(\d+)').firstMatch(servings!);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Empty state
    if (nutrition == null || nutrition!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.local_fire_department_outlined, size: 28, color: theme.colorScheme.outline),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.nutritionEmpty, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline)),
                  const SizedBox(height: 4),
                  Text(l10n.nutritionEmptyHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Calculate display nutrition
    var displayNutrition = scaleFactor != 1.0 ? nutrition!.scaled(scaleFactor) : nutrition!;
    final servingsCount = _parseServings();
    final canShowPerServing = servingsCount != null && servingsCount > 0;

    if (showPerServing && canShowPerServing) {
      displayNutrition = displayNutrition.scaled(1.0 / servingsCount);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          Row(
            children: [
              Icon(Icons.local_fire_department, color: const Color(0xFFE8A860)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  showPerServing && canShowPerServing ? l10n.nutritionPerServing : l10n.nutritionTotalRecipe,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              // Toggle button
              if (canShowPerServing && onTogglePerServing != null)
                GestureDetector(
                  onTap: () => onTogglePerServing!(!showPerServing),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          showPerServing ? '1 serving' : '$servingsCount servings',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.swap_vert, size: 14, color: theme.colorScheme.onPrimaryContainer),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Calories - big display
          if (displayNutrition.calories != null) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(l10n.nutritionCalories, style: theme.textTheme.bodyLarge),
                const Spacer(),
                Text(
                  '${displayNutrition.calories!.round()}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE8A860),
                  ),
                ),
                const SizedBox(width: 4),
                Text('kcal', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Macros grid
          Row(
            children: [
              Expanded(child: _MacroTile(label: l10n.nutritionProtein, value: displayNutrition.protein, unit: 'g', color: Colors.red.shade400)),
              Expanded(child: _MacroTile(label: l10n.nutritionCarbs, value: displayNutrition.carbohydrates, unit: 'g', color: Colors.amber.shade600)),
              Expanded(child: _MacroTile(label: l10n.nutritionFat, value: displayNutrition.fat, unit: 'g', color: Colors.blue.shade400)),
            ],
          ),

          // Additional nutrients
          if (displayNutrition.fiber != null || displayNutrition.sugar != null || displayNutrition.sodium != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (displayNutrition.fiber != null)
                  _SmallNutrient(label: 'Fiber', value: displayNutrition.fiber!, unit: 'g'),
                if (displayNutrition.sugar != null)
                  _SmallNutrient(label: 'Sugar', value: displayNutrition.sugar!, unit: 'g'),
                if (displayNutrition.sodium != null)
                  _SmallNutrient(label: 'Sodium', value: displayNutrition.sodium!, unit: 'mg'),
                if (displayNutrition.cholesterol != null)
                  _SmallNutrient(label: 'Cholesterol', value: displayNutrition.cholesterol!, unit: 'mg'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  final String label;
  final double? value;
  final String unit;
  final Color color;

  const _MacroTile({required this.label, this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (value == null) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          '${value!.round()}$unit',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
      ],
    );
  }
}

class _SmallNutrient extends StatelessWidget {
  final String label;
  final double value;
  final String unit;

  const _SmallNutrient({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        Text('${value.round()}$unit', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ============ TABS ============

class _NutritionTab extends StatelessWidget {
  final NutritionData? nutrition;
  final double scaleFactor;
  final AppLocalizations l10n;
  final String? servings;
  final bool showPerServing;
  final ValueChanged<bool>? onTogglePerServing;

  const _NutritionTab({
    required this.nutrition,
    required this.scaleFactor,
    required this.l10n,
    this.servings,
    this.showPerServing = true,
    this.onTogglePerServing,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _ModernNutritionCard(
        nutrition: nutrition,
        scaleFactor: scaleFactor,
        l10n: l10n,
        servings: servings,
        showPerServing: showPerServing,
        onTogglePerServing: onTogglePerServing,
      ),
      const SizedBox(height: 32),
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
    return ListView(padding: const EdgeInsets.all(16), children: [
      ...steps.asMap().entries.map((entry) => _InstructionStep(stepNumber: entry.key + 1, step: entry.value)),
      if (notes != null && notes!.isNotEmpty) ...[
        const SizedBox(height: 24),
        _SectionHeader(title: l10n.recipeFieldNotes),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: Text(notes!, style: theme.textTheme.bodyMedium)),
      ],
      const SizedBox(height: 32),
    ]);
  }
}

// ============ APP BAR ============

class _RecipeAppBar extends StatelessWidget {
  final Recipe recipe;
  final WidgetRef ref;
  final VoidCallback onEdit;
  final VoidCallback onReload;

  const _RecipeAppBar({required this.recipe, required this.ref, required this.onEdit, required this.onReload});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasImage = recipe.imagePath != null && File(recipe.imagePath!).existsSync();

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
        child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: hasImage
            ? Stack(fit: StackFit.expand, children: [
          Image.file(File(recipe.imagePath!), fit: BoxFit.cover),
          Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.5), Colors.transparent, Colors.black.withOpacity(0.5)]))),
        ])
            : const RecipePlaceholderImage(height: 300, width: double.infinity),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
          child: IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: onEdit, tooltip: l10n.actionEdit),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'share', child: Row(children: [const Icon(Icons.share), const SizedBox(width: 12), Text(l10n.actionShare)])),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'pin', child: Row(children: [Icon(recipe.isPinned ? Icons.push_pin : Icons.push_pin_outlined), const SizedBox(width: 12), Text(recipe.isPinned ? l10n.recipeUnpin : l10n.recipePin)])),
              PopupMenuItem(value: 'duplicate', child: Row(children: [const Icon(Icons.copy), const SizedBox(width: 12), Text(l10n.recipeDuplicate)])),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete, color: Colors.red), const SizedBox(width: 12), Text(l10n.actionDelete, style: const TextStyle(color: Colors.red))])),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) async {
    final l10n = AppLocalizations.of(context)!;
    switch (action) {
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.actionShare} - Coming soon!')));
        break;
      case 'pin':
        await ref.read(recipeDaoProvider).togglePin(recipe.id, !recipe.isPinned);
        onReload();
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(recipe.isPinned ? l10n.recipeUnpin : l10n.recipePin)));
        break;
      case 'duplicate':
        _duplicateRecipe(context);
        break;
      case 'delete':
        _confirmDelete(context);
        break;
    }
  }

  void _duplicateRecipe(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final recipeDao = ref.read(recipeDaoProvider);
    final newId = 'recipe_${DateTime.now().millisecondsSinceEpoch}';

    try {
      await recipeDao.insertRecipe(RecipesCompanion.insert(
        id: newId,
        cookbookId: recipe.cookbookId,
        title: '${recipe.title} (Copy)',
        description: drift.Value(recipe.description),
        servings: drift.Value(recipe.servings),
        prepTimeMinutes: drift.Value(recipe.prepTimeMinutes),
        cookTimeMinutes: drift.Value(recipe.cookTimeMinutes),
        sourceUrl: drift.Value(recipe.sourceUrl),
        imagePath: drift.Value(recipe.imagePath),
        courseId: drift.Value(recipe.courseId),
        categoryId: drift.Value(recipe.categoryId),
        rating: drift.Value(recipe.rating),
        notes: drift.Value(recipe.notes),
        nutritionJson: drift.Value(recipe.nutritionJson),
      ));

      final ingredients = await recipeDao.getIngredientsForRecipe(recipe.id);
      for (var i = 0; i < ingredients.length; i++) {
        final ing = ingredients[i];
        await recipeDao.insertIngredient(IngredientsCompanion.insert(
          id: '${newId}_ing_$i',
          recipeId: newId,
          name: ing.name,
          amount: drift.Value(ing.amount),
          unit: drift.Value(ing.unit),
          notes: drift.Value(ing.notes),
          sortOrder: ing.sortOrder,
        ));
      }

      final steps = await recipeDao.getStepsForRecipe(recipe.id);
      for (var i = 0; i < steps.length; i++) {
        final step = steps[i];
        await recipeDao.insertStep(StepsCompanion.insert(
          id: '${newId}_step_$i',
          recipeId: newId,
          instruction: step.instruction,
          sortOrder: step.sortOrder,
        ));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.successSaved),
          action: SnackBarAction(label: 'View', onPressed: () => context.push('/recipe/$newId')),
        ));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.errorGeneric}: $e')));
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
              await ref.read(recipeDaoProvider).softDeleteRecipe(recipe.id);
              if (context.mounted) {
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

// ============ HELPER WIDGETS ============

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

class _MetaItem extends StatelessWidget {
  final IconData icon; final String label; final String value; final bool highlight;
  const _MetaItem({required this.icon, required this.label, required this.value, this.highlight = false});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(children: [Icon(icon, color: highlight ? const Color(0xFFE8A860) : theme.colorScheme.onSurfaceVariant), const SizedBox(height: 4), Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: highlight ? const Color(0xFFE8A860) : null)), Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline))]);
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

class _IngredientItemWithAllergen extends ConsumerWidget {
  final Ingredient ingredient;
  final double scaleFactor;
  const _IngredientItemWithAllergen({required this.ingredient, required this.scaleFactor});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final userAllergies = settings.allergens;

    String amount = ingredient.amount ?? '';
    if (scaleFactor != 1.0 && amount.isNotEmpty) {
      final num = double.tryParse(amount.replaceAll(RegExp(r'[^\d.]'), ''));
      if (num != null) {
        final scaled = num * scaleFactor;
        amount = scaled == scaled.roundToDouble() ? scaled.round().toString() : scaled.toStringAsFixed(1);
      }
    }

    // Check for allergens
    final detectedAllergens = AllergenData.detectAllergens(ingredient.name);
    final matchingAllergens = detectedAllergens.where((a) => userAllergies.contains(a)).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(margin: const EdgeInsets.only(top: 6), width: 8, height: 8, decoration: BoxDecoration(color: matchingAllergens.isNotEmpty ? Colors.red : theme.colorScheme.primary, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        if (amount.isNotEmpty) ...[Text(amount, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)), const SizedBox(width: 4)],
        if (ingredient.unit != null && ingredient.unit!.isNotEmpty) ...[Text(ingredient.unit!, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)), const SizedBox(width: 4)],
        Expanded(child: Text(ingredient.name, style: theme.textTheme.bodyLarge?.copyWith(color: matchingAllergens.isNotEmpty ? Colors.red.shade700 : null))),
        if (matchingAllergens.isNotEmpty)
          Tooltip(
            message: matchingAllergens.map((a) => AllergenData.getEmoji(a)).join(' '),
            child: Icon(Icons.warning_amber, size: 18, color: Colors.red.shade600),
          ),
      ]),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int stepNumber;
  final Step step;
  const _InstructionStep({required this.stepNumber, required this.step});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = step.imagePath != null && File(step.imagePath!).existsSync();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(color: const Color(0xFFE8A860), shape: BoxShape.circle), child: Center(child: Text('$stepNumber', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 12),
            Expanded(child: Text(step.instruction, style: theme.textTheme.bodyLarge)),
          ]),
          if (hasImage) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(step.imagePath!), height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============ ADD TO SHOPPING SHEET ============

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
  @override void initState() { super.initState(); _selectedIds = widget.ingredients.map((i) => i.id).toSet(); }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [Icon(Icons.shopping_cart, color: theme.colorScheme.primary), const SizedBox(width: 12), Expanded(child: Text(l10n.recipeAddToShoppingList, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
        const SizedBox(height: 16),
        Text('${_selectedIds.length} / ${widget.ingredients.length} ${l10n.ingredientsTitle.toLowerCase()}'),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _isAdding ? null : _addToList, icon: _isAdding ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add), label: Text(l10n.recipeAddToShoppingList))),
      ])),
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

// ============ ADD TO MEAL PLAN SHEET ============

class _AddToMealPlanSheet extends StatefulWidget {
  final String recipeId;
  final String recipeTitle;
  final WidgetRef ref;
  const _AddToMealPlanSheet({required this.recipeId, required this.recipeTitle, required this.ref});
  @override State<_AddToMealPlanSheet> createState() => _AddToMealPlanSheetState();
}

class _AddToMealPlanSheetState extends State<_AddToMealPlanSheet> {
  DateTime _selectedDate = DateTime.now();
  String _selectedMealType = 'Dinner';
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [Icon(Icons.calendar_month, color: theme.colorScheme.primary), const SizedBox(width: 12), Expanded(child: Text(l10n.recipeAddToMealPlan, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
        const SizedBox(height: 16),
        // Meal type selector
        Wrap(
          spacing: 8,
          children: ['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((type) {
            final isSelected = _selectedMealType == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedMealType = type),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _isSaving ? null : _addToMealPlan, icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add), label: Text(l10n.recipeAddToMealPlan))),
      ])),
    );
  }
  Future<void> _addToMealPlan() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);
    try {
      final mealPlanDao = widget.ref.read(mealPlanDaoProvider);
      final id = 'meal_${DateTime.now().millisecondsSinceEpoch}';
      final date = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      await mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
        id: id,
        date: date,
        mealType: drift.Value(_selectedMealType),
        recipeId: drift.Value(widget.recipeId),
      ));
      if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.recipeTitle} added to $_selectedMealType'))); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.errorGeneric}: $e'))); }
    finally { if (mounted) setState(() => _isSaving = false); }
  }
}