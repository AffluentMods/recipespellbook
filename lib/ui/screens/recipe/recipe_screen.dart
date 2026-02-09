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
import '../../../data/rpg/rpg_text.dart';
import '../settings/nutrition_settings_screen.dart';
import '../settings/ingredient_substitutions_screen.dart';

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

// ============ UNIT CONVERSION ============

enum _UnitConversion { none, toImperial, toMetric }

class _UnitConverter {
  static const Map<String, _ConversionRule> _metricToImperial = {
    'ml': _ConversionRule('fl oz', 0.033814),
    'l': _ConversionRule('qt', 1.05669),
    'g': _ConversionRule('oz', 0.035274),
    'kg': _ConversionRule('lb', 2.20462),
    'cm': _ConversionRule('in', 0.393701),
    'mm': _ConversionRule('in', 0.0393701),
  };
  static const Map<String, _ConversionRule> _imperialToMetric = {
    'oz': _ConversionRule('g', 28.3495),
    'lb': _ConversionRule('kg', 0.453592),
    'cup': _ConversionRule('ml', 236.588),
    'cups': _ConversionRule('ml', 236.588),
    'fl oz': _ConversionRule('ml', 29.5735),
    'qt': _ConversionRule('l', 0.946353),
    'gal': _ConversionRule('l', 3.78541),
    'gallon': _ConversionRule('l', 3.78541),
    'tsp': _ConversionRule('ml', 4.92892),
    'tbsp': _ConversionRule('ml', 14.7868),
    'in': _ConversionRule('cm', 2.54),
    'pt': _ConversionRule('ml', 473.176),
    'pint': _ConversionRule('ml', 473.176),
  };

  static ({String amount, String unit}) convert(
      String amount, String unit, _UnitConversion mode,
      ) {
    if (mode == _UnitConversion.none || unit.isEmpty) {
      return (amount: amount, unit: unit);
    }

    final rules = mode == _UnitConversion.toImperial
        ? _metricToImperial
        : _imperialToMetric;

    final unitLower = unit.toLowerCase().trim();
    final rule = rules[unitLower];
    if (rule == null) return (amount: amount, unit: unit);

    final numVal = double.tryParse(amount.replaceAll(RegExp(r'[^\d.]'), ''));
    if (numVal == null) return (amount: amount, unit: unit);

    final converted = numVal * rule.factor;
    final displayAmount = converted < 10
        ? converted.toStringAsFixed(1)
        : converted.round().toString();

    return (amount: displayAmount, unit: rule.targetUnit);
  }
}

class _ConversionRule {
  final String targetUnit;
  final double factor;
  const _ConversionRule(this.targetUnit, this.factor);
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
  List<Recipe> _linkedRecipes = [];
  bool _isLoading = true;
  double _scaleFactor = 1.0;
  _UnitConversion _unitConversion = _UnitConversion.none;

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
    final linkedRecipes = await dao.getLinkedRecipes(widget.recipeId);

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
      _linkedRecipes = linkedRecipes;
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

  void _showLinkRecipePicker() async {
    final dao = ref.read(recipeDaoProvider);
    final allRecipes = await dao.getAllRecipes();
    // Filter out current recipe and already-linked recipes
    final linkedIds = _linkedRecipes.map((r) => r.id).toSet();
    final available = allRecipes
        .where((r) => r.id != widget.recipeId && !linkedIds.contains(r.id))
        .toList();

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RecipeLinkPicker(
        recipes: available,
        onSelected: (selectedId) async {
          Navigator.pop(ctx);
          await dao.addRecipeLink(widget.recipeId, selectedId);
          _loadRecipe();
        },
      ),
    );
  }

  Future<void> _unlinkRecipe(String linkedId) async {
    await ref.read(recipeDaoProvider).removeRecipeLink(widget.recipeId, linkedId);
    _loadRecipe();
  }

  bool _hasMetaInfo(Recipe recipe) {
    final hasPrepTime = recipe.prepTimeMinutes != null && recipe.prepTimeMinutes! > 0;
    final hasCookTime = recipe.cookTimeMinutes != null && recipe.cookTimeMinutes! > 0;
    final hasServings = recipe.servings != null && recipe.servings!.isNotEmpty;
    return hasPrepTime || hasCookTime || hasServings;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final isNerdMode = settings.nerdMode;
    final rpg = RpgText.of(l10n, isNerdMode);
    final useTabbed = settings.recipeLayoutMode == RecipeLayoutMode.tabbed;

    if (_isLoading || _recipe == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: useTabbed
          ? _buildTabbedLayout(theme, l10n, isNerdMode, rpg)
          : _buildStackedLayout(theme, l10n, isNerdMode, rpg),
    );
  }

  Widget _buildStackedLayout(ThemeData theme, AppLocalizations l10n, bool isNerdMode, RpgText rpg) {
    return CustomScrollView(
      slivers: [
        _RecipeAppBar(
          recipe: _recipe!,
          ref: ref,
          onEdit: _navigateToEdit,
          onReload: _loadRecipe,
          onLinkRecipe: _showLinkRecipePicker,
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

                // Linked recipes
                if (_linkedRecipes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _LinkedRecipesSection(
                    linkedRecipes: _linkedRecipes,
                    onTap: (id) => context.push('/recipe/$id'),
                    onRemove: _unlinkRecipe,
                  ),
                ],

                const SizedBox(height: 16),

                // NEW: 3 Simple Action Buttons (Meal Plan, Groceries, Share)
                _ModernQuickActionsRow(
                  onAddToMealPlan: _showAddToMealPlanSheet,
                  onAddToShopping: _showAddToShoppingSheet,
                  onShare: _showShareSheet,
                  nerdMode: isNerdMode,
                ),
                const SizedBox(height: 20),

                // Recipe meta info (times, servings) — hidden if all empty
                if (_hasMetaInfo(_recipe!))
                  _RecipeMetaInfoCard(recipe: _recipe!, nerdMode: isNerdMode),

                // NEW: Separate Scale & Convert buttons
                const SizedBox(height: 16),
                _ModernScaleConvertButtons(
                  currentScale: _scaleFactor,
                  servings: _recipe!.servings,
                  onScaleChanged: (scale) => setState(() => _scaleFactor = scale),
                  nerdMode: isNerdMode,
                  unitConversion: _unitConversion,
                  onConversionChanged: (mode) => setState(() => _unitConversion = mode),
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
                ..._ingredients.map((ing) => _IngredientItemWithAllergen(ingredient: ing, scaleFactor: _scaleFactor, unitConversion: _unitConversion)),

                // NEW: Large "Add to Shopping List" button at bottom of ingredients
                const SizedBox(height: 16),
                _LargeAddToShoppingButton(onTap: _showAddToShoppingSheet),

                const SizedBox(height: 32),
                _SectionHeader(title: rpg.instructionsTitle),
                const SizedBox(height: 12),
                ..._steps.asMap().entries.map((entry) => _InstructionStep(
                  stepNumber: entry.key + 1,
                  step: entry.value,
                )),
                if (_recipe!.notes != null && _recipe!.notes!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _SectionHeader(title: rpg.recipeFieldNotes),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                    child: Text(_recipe!.notes!, style: theme.textTheme.bodyMedium),
                  ),
                ],
                // Nutrition section
                const SizedBox(height: 32),
                _SectionHeader(title: rpg.nutritionTitle),
                const SizedBox(height: 12),
                NutritionWidget(
                  nutrition: _nutrition,
                  scaleFactor: _scaleFactor,
                  servings: _recipe!.servings,
                  chartStyle: ref.watch(settingsProvider).nutritionChartStyle,
                  enabledNutrients: ref.watch(settingsProvider).enabledNutrients,
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

  Widget _buildTabbedLayout(ThemeData theme, AppLocalizations l10n, bool isNerdMode, RpgText rpg) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _RecipeAppBar(
          recipe: _recipe!,
          ref: ref,
          onEdit: _navigateToEdit,
          onReload: _loadRecipe,
          onLinkRecipe: _showLinkRecipePicker,
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

                // Linked recipes
                if (_linkedRecipes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _LinkedRecipesSection(
                    linkedRecipes: _linkedRecipes,
                    onTap: (id) => context.push('/recipe/$id'),
                    onRemove: _unlinkRecipe,
                  ),
                ],

                const SizedBox(height: 16),
                _ModernQuickActionsRow(
                  onAddToMealPlan: _showAddToMealPlanSheet,
                  onAddToShopping: _showAddToShoppingSheet,
                  onShare: _showShareSheet,
                  nerdMode: isNerdMode,
                ),
                const SizedBox(height: 20),
                if (_hasMetaInfo(_recipe!))
                  _RecipeMetaInfoCard(recipe: _recipe!, nerdMode: isNerdMode),
                const SizedBox(height: 16),
                _ModernScaleConvertButtons(
                  currentScale: _scaleFactor,
                  servings: _recipe!.servings,
                  onScaleChanged: (scale) => setState(() => _scaleFactor = scale),
                  nerdMode: isNerdMode,
                  unitConversion: _unitConversion,
                  onConversionChanged: (mode) => setState(() => _unitConversion = mode),
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
                Tab(text: l10n.ingredientsTitle),
                Tab(text: rpg.instructionsTitle),
                Tab(text: rpg.nutritionTitle),
              ],
            ),
            theme.colorScheme.surface,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _IngredientsTab(ingredients: _ingredients, scaleFactor: _scaleFactor, l10n: l10n, onAddToShopping: _showAddToShoppingSheet, unitConversion: _unitConversion),
          _InstructionsTab(steps: _steps, notes: _recipe!.notes, l10n: l10n, nerdMode: isNerdMode),
          // Nutrition tab — uses the unified widget
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: NutritionWidget(
              nutrition: _nutrition,
              scaleFactor: _scaleFactor,
              servings: _recipe!.servings,
              chartStyle: ref.watch(settingsProvider).nutritionChartStyle,
              enabledNutrients: ref.watch(settingsProvider).enabledNutrients,
              isNerdMode: isNerdMode,
            ),
          ),
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
  final bool nerdMode;

  const _ModernQuickActionsRow({
    required this.onAddToMealPlan,
    required this.onAddToShopping,
    required this.onShare,
    this.nerdMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rpg = RpgText.of(l10n, nerdMode);
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _ModernActionButton(
            icon: Icons.calendar_month_outlined,
            label: rpg.mealPlanButton,
            onTap: onAddToMealPlan,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModernActionButton(
            icon: Icons.add_shopping_cart_rounded,
            label: rpg.groceriesButton,
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
  final bool nerdMode;

  const _RecipeMetaInfoCard({required this.recipe, this.nerdMode = false});

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
    final rpg = RpgText.of(l10n, nerdMode);

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
            _MetaItem(icon: Icons.timer_outlined, label: rpg.recipeFieldPrepTime, value: prepTimeStr),
          if (cookTimeStr.isNotEmpty)
            _MetaItem(icon: Icons.local_fire_department_outlined, label: rpg.recipeFieldCookTime, value: cookTimeStr),
          if (recipe.servings != null && recipe.servings!.isNotEmpty)
            _MetaItem(icon: Icons.people_outline, label: rpg.recipeFieldServings, value: recipe.servings!),
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
  final bool nerdMode;
  final _UnitConversion unitConversion;
  final ValueChanged<_UnitConversion> onConversionChanged;

  const _ModernScaleConvertButtons({
    required this.currentScale,
    this.servings,
    required this.onScaleChanged,
    this.nerdMode = false,
    this.unitConversion = _UnitConversion.none,
    required this.onConversionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final rpg = RpgText.of(l10n, nerdMode);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showScaleDialog(context),
            icon: const Icon(Icons.scale, size: 18),
            label: Text(currentScale == 1.0 ? rpg.scaleRecipeButton : '${currentScale}x'),
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
            label: Text(rpg.convertUnitsButton),
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
              leading: Icon(Icons.straighten, color: unitConversion == _UnitConversion.toImperial ? const Color(0xFFE8A860) : null),
              title: const Text('Metric → Imperial'),
              subtitle: const Text('ml→fl oz, g→oz, kg→lb'),
              trailing: unitConversion == _UnitConversion.toImperial ? const Icon(Icons.check_circle, color: Color(0xFFE8A860)) : null,
              onTap: () {
                Navigator.pop(ctx);
                onConversionChanged(unitConversion == _UnitConversion.toImperial ? _UnitConversion.none : _UnitConversion.toImperial);
              },
            ),
            ListTile(
              leading: Icon(Icons.square_foot, color: unitConversion == _UnitConversion.toMetric ? const Color(0xFFE8A860) : null),
              title: const Text('Imperial → Metric'),
              subtitle: const Text('cups→ml, oz→g, tsp→ml'),
              trailing: unitConversion == _UnitConversion.toMetric ? const Icon(Icons.check_circle, color: Color(0xFFE8A860)) : null,
              onTap: () {
                Navigator.pop(ctx);
                onConversionChanged(unitConversion == _UnitConversion.toMetric ? _UnitConversion.none : _UnitConversion.toMetric);
              },
            ),
            if (unitConversion != _UnitConversion.none)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onConversionChanged(_UnitConversion.none);
                  },
                  child: const Text('Reset to Original'),
                ),
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

class _IngredientsTab extends ConsumerWidget {
  final List<Ingredient> ingredients;
  final double scaleFactor;
  final AppLocalizations l10n;
  final VoidCallback onAddToShopping;
  final _UnitConversion unitConversion;

  const _IngredientsTab({
    required this.ingredients,
    required this.scaleFactor,
    required this.l10n,
    required this.onAddToShopping,
    this.unitConversion = _UnitConversion.none,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (ingredients.isEmpty) return Center(child: Text(l10n.ingredientsEmpty, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...ingredients.map((ing) => _IngredientItemWithAllergen(ingredient: ing, scaleFactor: scaleFactor, unitConversion: unitConversion)),
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
  final bool nerdMode;
  const _InstructionsTab({required this.steps, this.notes, required this.l10n, this.nerdMode = false});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rpg = RpgText.of(l10n, nerdMode);
    if (steps.isEmpty) return Center(child: Text(l10n.instructionsEmpty, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)));
    return ListView(padding: const EdgeInsets.all(16), children: [
      ...steps.asMap().entries.map((entry) => _InstructionStep(stepNumber: entry.key + 1, step: entry.value)),
      if (notes != null && notes!.isNotEmpty) ...[
        const SizedBox(height: 24),
        _SectionHeader(title: rpg.recipeFieldNotes),
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
  final VoidCallback? onLinkRecipe;
  final bool isNerdMode;

  const _RecipeAppBar({
    required this.recipe,
    required this.ref,
    required this.onEdit,
    required this.onReload,
    this.onLinkRecipe,
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
              const PopupMenuItem(value: 'link', child: Row(children: [Icon(Icons.link), SizedBox(width: 12), Text('Link Recipe')])),
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
      case 'link':
        onLinkRecipe?.call();
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
  final _UnitConversion unitConversion;
  const _IngredientItemWithAllergen({required this.ingredient, required this.scaleFactor, this.unitConversion = _UnitConversion.none});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final userAllergies = settings.allergens;

    String amount = ingredient.amount ?? '';
    String unit = ingredient.unit ?? '';

    // Apply scaling first
    if (scaleFactor != 1.0 && amount.isNotEmpty) {
      final num = double.tryParse(amount.replaceAll(RegExp(r'[^\d.]'), ''));
      if (num != null) {
        final scaled = num * scaleFactor;
        amount = scaled == scaled.roundToDouble() ? scaled.round().toString() : scaled.toStringAsFixed(1);
      }
    }

    // Apply unit conversion
    if (unitConversion != _UnitConversion.none && unit.isNotEmpty) {
      final converted = _UnitConverter.convert(amount, unit, unitConversion);
      amount = converted.amount;
      unit = converted.unit;
    }

    // Check for allergens
    final detectedAllergens = AllergenData.detectAllergens(ingredient.name);
    final userAllergyKeys = userAllergies.map((a) => a.key).toSet();
    final matchingAllergens = detectedAllergens.where((a) => userAllergyKeys.contains(a)).toList();

    return GestureDetector(
      onLongPress: () => showIngredientSubsSheet(context, ingredient.name),
      child: Padding(
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
                  if (unit.isNotEmpty) TextSpan(text: '$unit '),
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
      ),
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
    final hasImage = step.imagePath != null &&
        step.imagePath!.isNotEmpty &&
        File(step.imagePath!).existsSync();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: const Color(0xFFE8A860),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Text('$stepNumber',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14))),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(step.instruction,
                        style: theme.textTheme.bodyLarge))),
          ]),
          if (hasImage) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(step.imagePath!),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ],
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

// ============ LINKED RECIPES SECTION ============

class _LinkedRecipesSection extends StatelessWidget {
  final List<Recipe> linkedRecipes;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;

  const _LinkedRecipesSection({
    required this.linkedRecipes,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.link, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              'Linked Recipes',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: linkedRecipes.map((recipe) => _LinkedRecipeChip(
            recipe: recipe,
            onTap: () => onTap(recipe.id),
            onRemove: () => onRemove(recipe.id),
          )).toList(),
        ),
      ],
    );
  }
}

class _LinkedRecipeChip extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _LinkedRecipeChip({
    required this.recipe,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6, right: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restaurant_menu, size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Text(
                  recipe.title,
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 2),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close, size: 16, color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ RECIPE LINK PICKER ============

class _RecipeLinkPicker extends StatefulWidget {
  final List<Recipe> recipes;
  final ValueChanged<String> onSelected;

  const _RecipeLinkPicker({required this.recipes, required this.onSelected});

  @override
  State<_RecipeLinkPicker> createState() => _RecipeLinkPickerState();
}

class _RecipeLinkPickerState extends State<_RecipeLinkPicker> {
  final _searchController = TextEditingController();
  late List<Recipe> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.recipes;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = widget.recipes;
      } else {
        final lower = query.toLowerCase();
        _filtered = widget.recipes.where((r) => r.title.toLowerCase().contains(lower)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.link, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Link a Recipe',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Search recipes...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const Divider(),
            // Recipe list
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                child: Text(
                  'No recipes found',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                ),
              )
                  : ListView.builder(
                controller: controller,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final recipe = _filtered[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: recipe.imagePath != null && File(recipe.imagePath!).existsSync()
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(recipe.imagePath!), fit: BoxFit.cover),
                      )
                          : Icon(Icons.restaurant_menu, color: theme.colorScheme.onPrimaryContainer, size: 20),
                    ),
                    title: Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: recipe.description != null
                        ? Text(recipe.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                        : null,
                    onTap: () => widget.onSelected(recipe.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}