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
import '../../../data/allergen_data.dart';
import '../../widgets/recipe_tags_display.dart';
import '../../widgets/add_to_meal_plan_dialogue.dart';
import '../../widgets/add_to_shopping_list_sheet.dart';
import '../../widgets/recipe_share_sheet.dart';

// ============ DISMISSED ALLERGY WARNINGS ============
// Canonical provider is in allergy_settings_screen.dart — imported via:
import '../settings/allergy_settings_screen.dart' show dismissedAllergyWarningsProvider;

// ============ SESSION DISMISSED WARNINGS (temporary) ============

final sessionDismissedWarningsProvider = StateProvider<Set<String>>((ref) => {});

// ============ RPG RARITY COLORS ============

class RarityColors {
  static const Color common = Color(0xFF9E9E9E);
  static const Color uncommon = Color(0xFF4CAF50);
  static const Color rare = Color(0xFF2196F3);
  static const Color epic = Color(0xFF9C27B0);
  static const Color legendary = Color(0xFFFF9800);

  static Color getColor(int rating) {
    switch (rating) {
      case 1: return common;
      case 2: return uncommon;
      case 3: return rare;
      case 4: return epic;
      case 5: return legendary;
      default: return common;
    }
  }

  static Color getTitleColor(int rating) {
    // For title text - subtle gradient from white to golden
    switch (rating) {
      case 1: return Colors.white;
      case 2: return const Color(0xFFE8F5E9); // Light green tint
      case 3: return const Color(0xFFE3F2FD); // Light blue tint
      case 4: return const Color(0xFFF3E5F5); // Light purple tint
      case 5: return const Color(0xFFFFE0B2); // Golden/orange tint
      default: return Colors.white;
    }
  }
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

  void _showAddToMealPlanSheet() {
    showAddToMealPlanSheet(context, ref, widget.recipeId, _recipe?.title ?? '');
  }

  void _showAddToShoppingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddIngredientsToShoppingSheet(
        ingredients: _ingredients,
        recipeName: _recipe?.title ?? '',
        recipeId: widget.recipeId,
        scaleFactor: _scaleFactor,
      ),
    );
  }

  void _showShareSheet() {
    showRecipeShareSheet(context, ref, _recipe!);
  }

  Future<void> _toggleFavorite() async {
    if (_recipe == null) return;
    await ref.read(recipeDaoProvider).toggleFavorite(_recipe!.id, !_recipe!.isFavorite);
    _loadRecipe();
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
          isNerdMode: isNerdMode,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with RPG rarity color
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _recipe!.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isNerdMode && _recipe!.rating != null && _recipe!.rating! > 0
                              ? RarityColors.getColor(_recipe!.rating!)
                              : null,
                        ),
                      ),
                    ),
                    _FavoriteButton(isFavorite: _recipe!.isFavorite, onToggle: _toggleFavorite),
                  ],
                ),
                // Rating/Rarity badge - only show in non-nerd mode (nerd mode uses title color)
                if (_recipe!.rating != null && _recipe!.rating! > 0 && !isNerdMode) ...[
                  const SizedBox(height: 8),
                  RecipeRating(rating: _recipe!.rating!, nerdMode: false),
                ],
                // Tags display
                const SizedBox(height: 12),
                RecipeTagsDisplay(recipeId: widget.recipeId),

                if (_recipe!.description != null && _recipe!.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_recipe!.description!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
                const SizedBox(height: 16),

                // NEW: 3 Simple Action Buttons (Meal Plan, Groceries, Share)
                _ModernQuickActionsRow(
                  onAddToMealPlan: _showAddToMealPlanSheet,
                  onAddToShopping: _showAddToShoppingSheet,
                  onShare: _showShareSheet,
                ),
                const SizedBox(height: 20),

                // Recipe meta info (times, servings) WITHOUT scale buttons
                _RecipeMetaInfoCard(recipe: _recipe!),

                // NEW: Separate Scale & Convert buttons
                const SizedBox(height: 16),
                _ModernScaleConvertButtons(
                  currentScale: _scaleFactor,
                  servings: _recipe!.servings,
                  onScaleChanged: (scale) => setState(() => _scaleFactor = scale),
                ),

                // Dismissible Allergy warning banner with improved UX
                const SizedBox(height: 16),
                _ImprovedAllergyWarning(
                  recipeId: widget.recipeId,
                  ingredientTexts: _ingredients.map((i) => i.name).toList(),
                ),

                const SizedBox(height: 24),
                _SectionHeader(title: l10n.ingredientsTitle, trailing: _scaleFactor != 1.0 ? Text('${_scaleFactor}x', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)) : null),
                const SizedBox(height: 12),
                ..._ingredients.map((ing) => _IngredientItemWithAllergen(ingredient: ing, scaleFactor: _scaleFactor)),

                // NEW: Large "Add to Shopping List" button at bottom of ingredients
                const SizedBox(height: 16),
                _LargeAddToShoppingButton(onTap: _showAddToShoppingSheet),

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
                // Nutrition section
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
                  isNerdMode: isNerdMode,
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
          isNerdMode: isNerdMode,
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
                    Expanded(
                      child: Text(
                        _recipe!.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isNerdMode && _recipe!.rating != null && _recipe!.rating! > 0
                              ? RarityColors.getColor(_recipe!.rating!)
                              : null,
                        ),
                      ),
                    ),
                    _FavoriteButton(isFavorite: _recipe!.isFavorite, onToggle: _toggleFavorite),
                  ],
                ),
                if (_recipe!.rating != null && _recipe!.rating! > 0 && !isNerdMode) ...[
                  const SizedBox(height: 8),
                  RecipeRating(rating: _recipe!.rating!, nerdMode: false),
                ],
                const SizedBox(height: 12),
                RecipeTagsDisplay(recipeId: widget.recipeId),
                if (_recipe!.description != null && _recipe!.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_recipe!.description!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
                const SizedBox(height: 16),
                _ModernQuickActionsRow(
                  onAddToMealPlan: _showAddToMealPlanSheet,
                  onAddToShopping: _showAddToShoppingSheet,
                  onShare: _showShareSheet,
                ),
                const SizedBox(height: 20),
                _RecipeMetaInfoCard(recipe: _recipe!),
                const SizedBox(height: 16),
                _ModernScaleConvertButtons(
                  currentScale: _scaleFactor,
                  servings: _recipe!.servings,
                  onScaleChanged: (scale) => setState(() => _scaleFactor = scale),
                ),
                const SizedBox(height: 16),
                _ImprovedAllergyWarning(
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
              tabs: [
                Tab(text: l10n.nutritionTitle),
                Tab(text: l10n.ingredientsTitle),
                Tab(text: l10n.instructionsTitle),
              ],
            ),
            theme.colorScheme.surface,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _NutritionTab(nutrition: _nutrition, scaleFactor: _scaleFactor, l10n: l10n, servings: _recipe!.servings, showPerServing: _showNutritionPerServing, onTogglePerServing: (v) => setState(() => _showNutritionPerServing = v), isNerdMode: isNerdMode),
          _IngredientsTab(ingredients: _ingredients, scaleFactor: _scaleFactor, l10n: l10n, onAddToShopping: _showAddToShoppingSheet),
          _InstructionsTab(steps: _steps, notes: _recipe!.notes, l10n: l10n),
        ],
      ),
    );
  }
}

// ============ MODERN 3-BUTTON QUICK ACTIONS ============

class _ModernQuickActionsRow extends StatelessWidget {
  final VoidCallback onAddToMealPlan;
  final VoidCallback onAddToShopping;
  final VoidCallback onShare;

  const _ModernQuickActionsRow({
    required this.onAddToMealPlan,
    required this.onAddToShopping,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _ModernActionButton(
            icon: Icons.calendar_month_outlined,
            label: l10n.mealPlanButton,
            onTap: onAddToMealPlan,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModernActionButton(
            icon: Icons.add_shopping_cart_rounded,
            label: l10n.groceriesButton,
            onTap: onAddToShopping,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModernActionButton(
            icon: Icons.share_outlined,
            label: l10n.actionShare,
            onTap: onShare,
          ),
        ),
      ],
    );
  }
}

class _ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: theme.colorScheme.primary),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ RECIPE META INFO CARD (without scale) ============

class _RecipeMetaInfoCard extends StatelessWidget {
  final Recipe recipe;

  const _RecipeMetaInfoCard({required this.recipe});

  String _formatMinutes(int? minutes) {
    if (minutes == null || minutes <= 0) return '';
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final prepTimeStr = _formatMinutes(recipe.prepTimeMinutes);
    final cookTimeStr = _formatMinutes(recipe.cookTimeMinutes);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (prepTimeStr.isNotEmpty)
            _MetaItem(icon: Icons.timer_outlined, label: l10n.recipeFieldPrepTime, value: prepTimeStr),
          if (cookTimeStr.isNotEmpty)
            _MetaItem(icon: Icons.local_fire_department_outlined, label: l10n.recipeFieldCookTime, value: cookTimeStr),
          if (recipe.servings != null && recipe.servings!.isNotEmpty)
            _MetaItem(icon: Icons.people_outline, label: l10n.recipeFieldServings, value: recipe.servings!),
        ],
      ),
    );
  }
}

// ============ MODERN SCALE & CONVERT BUTTONS ============

class _ModernScaleConvertButtons extends StatelessWidget {
  final double currentScale;
  final String? servings;
  final ValueChanged<double> onScaleChanged;

  const _ModernScaleConvertButtons({
    required this.currentScale,
    this.servings,
    required this.onScaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showScaleDialog(context),
            icon: const Icon(Icons.scale, size: 18),
            label: Text(currentScale == 1.0 ? l10n.scaleRecipeButton : '${currentScale}x'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(
                color: currentScale != 1.0
                    ? const Color(0xFFE8A860)
                    : theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
              foregroundColor: currentScale != 1.0
                  ? const Color(0xFFE8A860)
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showConvertDialog(context),
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: Text(l10n.convertUnitsButton),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }

  void _showScaleDialog(BuildContext context) {
    final theme = Theme.of(context);
    final presets = [0.5, 1.0, 1.5, 2.0, 3.0, 4.0];
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Scale Recipe', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                servings != null ? 'Original: $servings' : 'Adjust ingredient quantities',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presets.map((preset) => _ScaleChip(
                  label: preset == 1.0 ? '1x (Original)' : '${preset}x',
                  isSelected: currentScale == preset,
                  onTap: () {
                    onScaleChanged(preset);
                    Navigator.pop(ctx);
                  },
                )).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Custom scale',
                  hintText: 'e.g., 2.5',
                  suffixText: 'x',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (value) {
                  final scale = double.tryParse(value);
                  if (scale != null && scale > 0 && scale <= 100) {
                    onScaleChanged(scale);
                    Navigator.pop(ctx);
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConvertDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Convert Units', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.straighten),
              title: const Text('Metric → Imperial'),
              subtitle: const Text('ml to cups, g to oz'),
              onTap: () {
                Navigator.pop(ctx);
                // TODO: Implement conversion
              },
            ),
            ListTile(
              leading: const Icon(Icons.square_foot),
              title: const Text('Imperial → Metric'),
              subtitle: const Text('cups to ml, oz to g'),
              onTap: () {
                Navigator.pop(ctx);
                // TODO: Implement conversion
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8A860) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ============ LARGE ADD TO SHOPPING BUTTON ============

class _LargeAddToShoppingButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LargeAddToShoppingButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(l10n.recipeAddToShoppingList),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xFFE8A860),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

// ============ IMPROVED ALLERGY WARNING ============

class _ImprovedAllergyWarning extends ConsumerStatefulWidget {
  final String recipeId;
  final List<String> ingredientTexts;

  const _ImprovedAllergyWarning({
    required this.recipeId,
    required this.ingredientTexts,
  });

  @override
  ConsumerState<_ImprovedAllergyWarning> createState() => _ImprovedAllergyWarningState();
}

class _ImprovedAllergyWarningState extends ConsumerState<_ImprovedAllergyWarning> {
  bool _showDisablePrompt = false;
  bool _sessionDismissed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final dismissedWarnings = ref.watch(dismissedAllergyWarningsProvider);

    // Check if user has any allergies set
    final userAllergies = settings.allergens;
    if (userAllergies.isEmpty) return const SizedBox.shrink();

    // Check if permanently dismissed
    if (dismissedWarnings.containsKey(widget.recipeId)) return const SizedBox.shrink();

    // Check if session dismissed
    if (_sessionDismissed) {
      if (_showDisablePrompt) {
        return _buildDisablePrompt(theme, l10n);
      }
      return const SizedBox.shrink();
    }

    // Check ingredients for allergens
    // AllergenData.detectAllergens() returns String keys; userAllergies is List<Allergen>
    final userAllergyKeys = userAllergies.map((a) => a.key).toSet();
    final detectedAllergens = <String>[];
    for (final ingredientText in widget.ingredientTexts) {
      final allergens = AllergenData.detectAllergens(ingredientText);
      for (final allergen in allergens) {
        if (userAllergyKeys.contains(allergen) && !detectedAllergens.contains(allergen)) {
          detectedAllergens.add(allergen);
        }
      }
    }

    if (detectedAllergens.isEmpty) return const SizedBox.shrink();

    // Get localized allergen names
    final allergenNames = detectedAllergens.map((a) => AllergenData.getLocalizedName(a, l10n)).toList();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: const ValueKey('warning'),
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
                  // X button on RIGHT
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red.shade700, size: 20),
                    tooltip: l10n.allergyDismissTooltip,
                    onPressed: () {
                      setState(() {
                        _sessionDismissed = true;
                        _showDisablePrompt = true;
                      });
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
      ),
    );
  }

  Widget _buildDisablePrompt(ThemeData theme, AppLocalizations l10n) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: const ValueKey('prompt'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_off_outlined, color: theme.colorScheme.outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.allergyDisablePrompt,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                setState(() => _showDisablePrompt = false);
              },
              child: Text(l10n.no),
            ),
            FilledButton(
              onPressed: () {
                // Dismiss all of user's configured allergens for this recipe
                final currentAllergens = ref.read(settingsProvider).allergens.toSet();
                ref.read(dismissedAllergyWarningsProvider.notifier).dismissForRecipe(widget.recipeId, currentAllergens);
                setState(() => _showDisablePrompt = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.allergyDisabledForRecipe)),
                );
              },
              child: Text(l10n.yes),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ NUTRITION CARD WITH BUG FIX ============

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
  final bool isNerdMode;

  const _ModernNutritionCard({
    this.nutrition,
    this.scaleFactor = 1.0,
    required this.l10n,
    this.servings,
    this.showPerServing = true,
    this.onTogglePerServing,
    this.isNerdMode = false,
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
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
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

    // BUG FIX: Nutrition data is stored as PER SERVING values
    // When showPerServing is true, show data as-is (no division)
    // When showPerServing is false (showing total), MULTIPLY by servings
    var displayNutrition = nutrition!;
    final servingsCount = _parseServings();
    final canShowPerServing = servingsCount != null && servingsCount > 0;

    // Apply scale factor first
    if (scaleFactor != 1.0) {
      displayNutrition = displayNutrition.scaled(scaleFactor);
    }

    // If showing TOTAL (not per serving), multiply by servings count
    if (!showPerServing && canShowPerServing) {
      displayNutrition = displayNutrition.scaled(servingsCount.toDouble());
    }

    // Use RPG stat cards style if nerd mode is enabled
    if (isNerdMode) {
      return _buildRpgNutritionCard(context, displayNutrition, canShowPerServing, servingsCount);
    }

    return _buildStandardNutritionCard(context, displayNutrition, canShowPerServing, servingsCount);
  }

  Widget _buildStandardNutritionCard(BuildContext context, NutritionData displayNutrition, bool canShowPerServing, int? servingsCount) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
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
          const Divider(),
          const SizedBox(height: 12),

          // Macros
          _NutritionRow(label: l10n.nutritionFat, value: displayNutrition.fat, unit: 'g', dailyValue: _DailyValues.fat),
          if (displayNutrition.saturatedFat != null)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _NutritionRow(label: l10n.nutritionSaturatedFat, value: displayNutrition.saturatedFat, unit: 'g', dailyValue: _DailyValues.saturatedFat, isSubItem: true),
            ),
          _NutritionRow(label: l10n.nutritionCarbs, value: displayNutrition.carbohydrates, unit: 'g', dailyValue: _DailyValues.carbohydrates),
          if (displayNutrition.fiber != null)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _NutritionRow(label: l10n.nutritionFiber, value: displayNutrition.fiber, unit: 'g', dailyValue: _DailyValues.fiber, isSubItem: true),
            ),
          if (displayNutrition.sugar != null)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _NutritionRow(label: l10n.nutritionSugar, value: displayNutrition.sugar, unit: 'g', dailyValue: _DailyValues.sugar, isSubItem: true),
            ),
          _NutritionRow(label: l10n.nutritionProtein, value: displayNutrition.protein, unit: 'g', dailyValue: _DailyValues.protein),

          if (displayNutrition.sodium != null || displayNutrition.cholesterol != null) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            if (displayNutrition.sodium != null)
              _NutritionRow(label: l10n.nutritionSodium, value: displayNutrition.sodium, unit: 'mg', dailyValue: _DailyValues.sodium),
            if (displayNutrition.cholesterol != null)
              _NutritionRow(label: l10n.nutritionCholesterol, value: displayNutrition.cholesterol, unit: 'mg', dailyValue: _DailyValues.cholesterol),
          ],
        ],
      ),
    );
  }

  Widget _buildRpgNutritionCard(BuildContext context, NutritionData displayNutrition, bool canShowPerServing, int? servingsCount) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8A860).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8A860).withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with toggle
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Color(0xFFE8A860)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  showPerServing && canShowPerServing ? l10n.nutritionPerServing : l10n.nutritionTotalRecipe,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (canShowPerServing && onTogglePerServing != null)
                GestureDetector(
                  onTap: () => onTogglePerServing!(!showPerServing),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8A860).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8A860).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          showPerServing ? '1 serving' : '$servingsCount servings',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFFE8A860),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.swap_vert, size: 14, color: Color(0xFFE8A860)),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // RPG Stat Cards
          Row(
            children: [
              Expanded(
                child: _RpgStatCard(
                  label: 'STR',
                  sublabel: l10n.nutritionProtein,
                  value: displayNutrition.protein != null ? '${displayNutrition.protein!.round()}g' : '-',
                  icon: Icons.fitness_center,
                  glowColor: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RpgStatCard(
                  label: 'STA',
                  sublabel: l10n.nutritionCarbs,
                  value: displayNutrition.carbohydrates != null ? '${displayNutrition.carbohydrates!.round()}g' : '-',
                  icon: Icons.bolt,
                  glowColor: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RpgStatCard(
                  label: 'CON',
                  sublabel: l10n.nutritionFat,
                  value: displayNutrition.fat != null ? '${displayNutrition.fat!.round()}g' : '-',
                  icon: Icons.shield,
                  glowColor: Colors.amber,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Calories center
          if (displayNutrition.calories != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A3C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8A860).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.whatshot, color: Color(0xFFE8A860), size: 28),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Text(
                        '${displayNutrition.calories!.round()}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFE8A860),
                        ),
                      ),
                      Text(
                        'ENERGY',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RpgStatCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final String value;
  final IconData icon;
  final Color glowColor;

  const _RpgStatCard({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.icon,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: glowColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: glowColor.withValues(alpha: 0.15), blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: glowColor, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final double? value;
  final String unit;
  final double? dailyValue;
  final bool isSubItem;

  const _NutritionRow({
    required this.label,
    this.value,
    required this.unit,
    this.dailyValue,
    this.isSubItem = false,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final percentage = dailyValue != null && dailyValue! > 0 ? (value! / dailyValue! * 100).round() : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isSubItem ? FontWeight.normal : FontWeight.w500,
              color: isSubItem ? theme.colorScheme.outline : null,
            ),
          ),
          const Spacer(),
          Text(
            '${value!.round()}$unit',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (percentage != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$percentage%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
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
  final bool isNerdMode;

  const _NutritionTab({
    required this.nutrition,
    required this.scaleFactor,
    required this.l10n,
    this.servings,
    this.showPerServing = true,
    this.onTogglePerServing,
    this.isNerdMode = false,
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
        isNerdMode: isNerdMode,
      ),
      const SizedBox(height: 32),
    ]);
  }
}

class _IngredientsTab extends ConsumerWidget {
  final List<Ingredient> ingredients;
  final double scaleFactor;
  final AppLocalizations l10n;
  final VoidCallback onAddToShopping;

  const _IngredientsTab({
    required this.ingredients,
    required this.scaleFactor,
    required this.l10n,
    required this.onAddToShopping,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (ingredients.isEmpty) return Center(child: Text(l10n.ingredientsEmpty, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...ingredients.map((ing) => _IngredientItemWithAllergen(ingredient: ing, scaleFactor: scaleFactor)),
        const SizedBox(height: 16),
        _LargeAddToShoppingButton(onTap: onAddToShopping),
        const SizedBox(height: 32),
      ],
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

// ============ APP BAR WITH RPG RARITY GLOW BORDER ============

class _RecipeAppBar extends StatelessWidget {
  final Recipe recipe;
  final WidgetRef ref;
  final VoidCallback onEdit;
  final VoidCallback onReload;
  final bool isNerdMode;

  const _RecipeAppBar({
    required this.recipe,
    required this.ref,
    required this.onEdit,
    required this.onReload,
    this.isNerdMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasImage = recipe.imagePath != null && File(recipe.imagePath!).existsSync();

    // Get rarity color for border glow
    final rarityColor = isNerdMode && recipe.rating != null && recipe.rating! > 0
        ? RarityColors.getColor(recipe.rating!)
        : null;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
        child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image with optional rarity glow border
            if (hasImage)
              Image.file(File(recipe.imagePath!), fit: BoxFit.cover)
            else
              const RecipePlaceholderImage(height: 300, width: double.infinity),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
            // Rarity glow border effect (subtle inner glow)
            if (rarityColor != null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: rarityColor.withValues(alpha: 0.6), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: rarityColor.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: -2,
                    ),
                  ],
                ),
              ),
            // Rarity glow vignette at edges
            if (rarityColor != null)
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        rarityColor.withValues(alpha: 0.15),
                        Colors.transparent,
                        Colors.transparent,
                        rarityColor.withValues(alpha: 0.2),
                      ],
                      stops: const [0.0, 0.15, 0.85, 1.0],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
          child: IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: onEdit, tooltip: l10n.actionEdit),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
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
      await recipeDao.duplicateRecipe(recipe.id, newId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.recipeDuplicated)));
        context.push('/recipe/$newId');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteRecipeTitle),
        content: Text(l10n.deleteRecipeConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(recipeDaoProvider).moveToTrash(recipe.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.recipeDeleted)));
              }
            },
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }
}

// ============ HELPER WIDGETS ============

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
    // In nerd mode, we use title color instead of badges
    if (nerdMode) return const SizedBox.shrink();
    return Row(children: List.generate(5, (index) => Icon(index < rating ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.amber, size: 20)));
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
    final userAllergyKeys = userAllergies.map((a) => a.key).toSet();
    final matchingAllergens = detectedAllergens.where((a) => userAllergyKeys.contains(a)).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(margin: const EdgeInsets.only(top: 6), width: 8, height: 8, decoration: BoxDecoration(color: matchingAllergens.isNotEmpty ? Colors.red : theme.colorScheme.primary, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyLarge,
              children: [
                if (amount.isNotEmpty) TextSpan(text: '$amount ', style: const TextStyle(fontWeight: FontWeight.w600)),
                if (ingredient.unit != null && ingredient.unit!.isNotEmpty) TextSpan(text: '${ingredient.unit} '),
                TextSpan(text: ingredient.name),
              ],
            ),
          ),
        ),
        if (matchingAllergens.isNotEmpty)
          Tooltip(
            message: 'Contains: ${matchingAllergens.join(", ")}',
            child: Icon(Icons.warning_amber_rounded, size: 18, color: Colors.red.shade700),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: const Color(0xFFE8A860), borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text('$stepNumber', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Padding(padding: const EdgeInsets.only(top: 4), child: Text(step.instruction, style: theme.textTheme.bodyLarge))),
      ]),
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