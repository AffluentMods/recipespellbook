import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';

/// Layout mode for recipe content display
enum RecipeContentLayout {
  /// Traditional stacked layout (Ingredients, then Instructions)
  stacked,
  /// Swipeable tabs (swipe left/right between Ingredients and Instructions)
  tabbed,
}

/// Provider for recipe content layout preference
final recipeContentLayoutProvider = StateProvider<RecipeContentLayout>((ref) {
  // You can read from settings here if you add recipeContentLayout to your settings
  // final settings = ref.watch(settingsProvider);
  // return settings.recipeContentLayout ?? RecipeContentLayout.stacked;
  return RecipeContentLayout.stacked;
});

/// Main widget that displays recipe content (ingredients + instructions)
/// Supports both stacked and tabbed layouts based on user preference
class RecipeContentView extends ConsumerWidget {
  final List<Ingredient> ingredients;
  final List<Step> steps;
  final double scale;
  final double fontScale;
  final Function(String)? onIngredientTap;
  final Function(int)? onStepTap;

  const RecipeContentView({
    super.key,
    required this.ingredients,
    required this.steps,
    this.scale = 1.0,
    this.fontScale = 1.0,
    this.onIngredientTap,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(recipeContentLayoutProvider);

    if (layout == RecipeContentLayout.tabbed) {
      return _TabbedRecipeContent(
        ingredients: ingredients,
        steps: steps,
        scale: scale,
        fontScale: fontScale,
        onIngredientTap: onIngredientTap,
        onStepTap: onStepTap,
      );
    }

    return _StackedRecipeContent(
      ingredients: ingredients,
      steps: steps,
      scale: scale,
      fontScale: fontScale,
      onIngredientTap: onIngredientTap,
      onStepTap: onStepTap,
    );
  }
}

/// Traditional stacked layout
class _StackedRecipeContent extends StatelessWidget {
  final List<Ingredient> ingredients;
  final List<Step> steps;
  final double scale;
  final double fontScale;
  final Function(String)? onIngredientTap;
  final Function(int)? onStepTap;

  const _StackedRecipeContent({
    required this.ingredients,
    required this.steps,
    required this.scale,
    required this.fontScale,
    this.onIngredientTap,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ingredients Section
        if (ingredients.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.checklist,
            title: l10n.recipeIngredients,
            count: ingredients.length,
          ),
          const SizedBox(height: 12),
          ...ingredients.map((ing) => _IngredientItem(
            ingredient: ing,
            scale: scale,
            fontScale: fontScale,
            onTap: onIngredientTap != null ? () => onIngredientTap!(ing.id) : null,
          )),
          const SizedBox(height: 24),
        ],

        // Instructions Section
        if (steps.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.format_list_numbered,
            title: l10n.recipeInstructions,
            count: steps.length,
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((entry) => _StepItem(
            step: entry.value,
            stepNumber: entry.key + 1,
            fontScale: fontScale,
            onTap: onStepTap != null ? () => onStepTap!(entry.key) : null,
          )),
        ],
      ],
    );
  }
}

/// Swipeable tabbed layout
class _TabbedRecipeContent extends StatefulWidget {
  final List<Ingredient> ingredients;
  final List<Step> steps;
  final double scale;
  final double fontScale;
  final Function(String)? onIngredientTap;
  final Function(int)? onStepTap;

  const _TabbedRecipeContent({
    required this.ingredients,
    required this.steps,
    required this.scale,
    required this.fontScale,
    this.onIngredientTap,
    this.onStepTap,
  });

  @override
  State<_TabbedRecipeContent> createState() => _TabbedRecipeContentState();
}

class _TabbedRecipeContentState extends State<_TabbedRecipeContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            dividerColor: Colors.transparent,
            labelColor: theme.colorScheme.onPrimaryContainer,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.checklist, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.recipeIngredients),
                    const SizedBox(width: 4),
                    _CountBadge(count: widget.ingredients.length),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.format_list_numbered, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.recipeInstructions),
                    const SizedBox(width: 4),
                    _CountBadge(count: widget.steps.length),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Swipe hint
        _SwipeHint(),

        // Page View
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              _tabController.animateTo(index);
              HapticFeedback.selectionClick();
            },
            children: [
              // Ingredients Page
              _IngredientsPage(
                ingredients: widget.ingredients,
                scale: widget.scale,
                fontScale: widget.fontScale,
                onIngredientTap: widget.onIngredientTap,
              ),

              // Instructions Page
              _InstructionsPage(
                steps: widget.steps,
                fontScale: widget.fontScale,
                onStepTap: widget.onStepTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IngredientsPage extends StatelessWidget {
  final List<Ingredient> ingredients;
  final double scale;
  final double fontScale;
  final Function(String)? onIngredientTap;

  const _IngredientsPage({
    required this.ingredients,
    required this.scale,
    required this.fontScale,
    this.onIngredientTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (ingredients.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(l10n.ingredientsEmpty, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        return _IngredientItem(
          ingredient: ingredients[index],
          scale: scale,
          fontScale: fontScale,
          onTap: onIngredientTap != null ? () => onIngredientTap!(ingredients[index].id) : null,
        );
      },
    );
  }
}

class _InstructionsPage extends StatelessWidget {
  final List<Step> steps;
  final double fontScale;
  final Function(int)? onStepTap;

  const _InstructionsPage({
    required this.steps,
    required this.fontScale,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (steps.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.format_list_numbered, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(l10n.instructionsEmpty, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return _StepItem(
          step: steps[index],
          stepNumber: index + 1,
          fontScale: fontScale,
          onTap: onStepTap != null ? () => onStepTap!(index) : null,
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          _CountBadge(count: count),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _IngredientItem extends StatefulWidget {
  final Ingredient ingredient;
  final double scale;
  final double fontScale;
  final VoidCallback? onTap;

  const _IngredientItem({
    required this.ingredient,
    required this.scale,
    required this.fontScale,
    this.onTap,
  });

  @override
  State<_IngredientItem> createState() => _IngredientItemState();
}

class _IngredientItemState extends State<_IngredientItem> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ing = widget.ingredient;

    // Format amount with scaling
    String amountText = '';
    if (ing.amount != null && ing.amount!.isNotEmpty) {
      final parsed = double.tryParse(ing.amount!);
      if (parsed != null) {
        final scaledAmount = parsed * widget.scale;
        amountText = _formatAmount(scaledAmount);
      } else {
        amountText = ing.amount!;
      }
    }

    final fullText = [
      if (amountText.isNotEmpty) amountText,
      if (ing.unit != null && ing.unit!.isNotEmpty) ing.unit!,
      ing.name,
    ].join(' ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: _isChecked
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            setState(() => _isChecked = !_isChecked);
            HapticFeedback.selectionClick();
            widget.onTap?.call();
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _isChecked ? Icons.check_circle : Icons.circle_outlined,
                  size: 22,
                  color: _isChecked
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fullText,
                    style: TextStyle(
                      fontSize: 15 * widget.fontScale,
                      decoration: _isChecked ? TextDecoration.lineThrough : null,
                      color: _isChecked
                          ? theme.colorScheme.outline
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.round().toString();
    }

    final fractions = {
      0.25: '¼', 0.33: '⅓', 0.5: '½', 0.67: '⅔', 0.75: '¾',
      0.125: '⅛', 0.375: '⅜', 0.625: '⅝', 0.875: '⅞',
    };

    final whole = amount.floor();
    final frac = amount - whole;

    for (final entry in fractions.entries) {
      if ((frac - entry.key).abs() < 0.05) {
        if (whole > 0) {
          return '$whole ${entry.value}';
        }
        return entry.value;
      }
    }

    return amount.toStringAsFixed(1);
  }
}

class _StepItem extends StatefulWidget {
  final Step step;
  final int stepNumber;
  final double fontScale;
  final VoidCallback? onTap;

  const _StepItem({
    required this.step,
    required this.stepNumber,
    required this.fontScale,
    this.onTap,
  });

  @override
  State<_StepItem> createState() => _StepItemState();
}

class _StepItemState extends State<_StepItem> {
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: _isCompleted
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() => _isCompleted = !_isCompleted);
            HapticFeedback.selectionClick();
            widget.onTap?.call();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step number badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _isCompleted
                        ? Icon(Icons.check, size: 18, color: theme.colorScheme.onPrimary)
                        : Text(
                      '${widget.stepNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.step.instruction,
                    style: TextStyle(
                      fontSize: 15 * widget.fontScale,
                      height: 1.5,
                      decoration: _isCompleted ? TextDecoration.lineThrough : null,
                      color: _isCompleted
                          ? theme.colorScheme.outline
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swipe, size: 14, color: theme.colorScheme.outline),
          const SizedBox(width: 6),
          Text(
            l10n.recipeSwipeHint,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}