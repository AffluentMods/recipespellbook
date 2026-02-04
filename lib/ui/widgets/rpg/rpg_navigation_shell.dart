// lib/ui/widgets/rpg/rpg_navigation_shell.dart
// RPG Mode Navigation Shell - wraps the app with RPG-specific UI

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/rpg/rpg_models.dart';
import '../../../providers/rpg_provider.dart';
import '../../../providers/settings_provider.dart';
import 'rpg_widgets.dart';

/// Wraps the main app shell with RPG-specific UI elements
/// This includes the floating XP bar and notification listener
class RpgNavigationShell extends ConsumerWidget {
  final Widget child;
  final StatefulNavigationShell? navigationShell;

  const RpgNavigationShell({
    super.key,
    required this.child,
    this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rpgEnabled = ref.watch(rpgEnabledProvider);
    final nerdMode = ref.watch(settingsProvider).nerdMode;

    // Only show RPG elements if both RPG mode is enabled AND nerd mode is on
    final showRpgUI = rpgEnabled && nerdMode;

    if (!showRpgUI) {
      return child;
    }

    return RpgNotificationListener(
      child: Stack(
        children: [
          child,
          // Floating RPG profile button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: _FloatingRpgButton(),
          ),
        ],
      ),
    );
  }
}

class _FloatingRpgButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/rpg/profile'),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: profile.playerClass.color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: profile.playerClass.color.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mini avatar
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: profile.playerClass.color.withOpacity(0.2),
                  border: Border.all(
                    color: profile.playerClass.color,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    profile.playerClass.icon,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Level and XP
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lv.${profile.level}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Mini XP bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: profile.levelProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: profile.playerClass.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Currency
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on,
                          color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        _formatCompact(profile.gold),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond,
                          color: Colors.purple, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        _formatCompact(profile.gems),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCompact(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

/// Custom bottom navigation bar with RPG enhancements
class RpgBottomNavigationBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  final List<NavigationDestination> destinations;

  const RpgBottomNavigationBar({
    super.key,
    required this.navigationShell,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rpgEnabled = ref.watch(rpgEnabledProvider);
    final nerdMode = ref.watch(settingsProvider).nerdMode;
    final showRpgUI = rpgEnabled && nerdMode;

    final theme = Theme.of(context);

    // Get RPG-themed labels
    final rpgDestinations = showRpgUI
        ? destinations.map((d) => NavigationDestination(
      icon: d.icon,
      selectedIcon: d.selectedIcon,
      label: _getRpgLabel(d.label),
    )).toList()
        : destinations;

    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      destinations: [
        ...rpgDestinations,
        if (showRpgUI)
          NavigationDestination(
            icon: Stack(
              children: [
                const Icon(Icons.shield_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            selectedIcon: const Icon(Icons.shield),
            label: 'Guild',
          ),
      ],
    );
  }

  String _getRpgLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home': return 'Tavern';
      case 'recipes': return 'Grimoire';
      case 'meal plan':
      case 'planner': return 'Quests';
      case 'shopping': return 'Market';
      default: return label;
    }
  }
}

/// XP Toast Overlay - shows XP gains as floating toasts
class RpgXpToastOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const RpgXpToastOverlay({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<RpgXpToastOverlay> createState() => _RpgXpToastOverlayState();
}

class _RpgXpToastOverlayState extends ConsumerState<RpgXpToastOverlay> {
  @override
  Widget build(BuildContext context) {
    final recentXpGains = ref.watch(rpgProvider).recentXpGains;
    final rpgEnabled = ref.watch(rpgEnabledProvider);

    if (!rpgEnabled || recentXpGains.isEmpty) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        // XP Toast stack
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          left: 0,
          right: 0,
          child: Column(
            children: recentXpGains.take(3).map((event) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - value) * -20),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: RpgXpGainToast(
                  event: event,
                  onDismiss: () {
                    ref.read(rpgProvider.notifier).clearRecentXpGains();
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Integration helper - call this to award XP from anywhere in the app
class RpgIntegration {
  static void onRecipeCreated(WidgetRef ref, {int stepCount = 0, int ingredientCount = 0}) {
    final rpgNotifier = ref.read(rpgProvider.notifier);
    rpgNotifier.awardXp(XpActionType.createRecipe, description: 'Created Recipe');

    if (stepCount > 0) {
      rpgNotifier.awardXp(XpActionType.addSteps,
          multiplier: stepCount,
          description: 'Added $stepCount steps');
    }
    if (ingredientCount >= 5) {
      rpgNotifier.awardXp(XpActionType.addIngredients,
          multiplier: ingredientCount ~/ 5,
          description: 'Added $ingredientCount ingredients');
    }
  }

  static void onRecipeImported(WidgetRef ref, {int count = 1}) {
    ref.read(rpgProvider.notifier).awardXp(
      XpActionType.importRecipe,
      multiplier: count,
      description: count > 1 ? 'Imported $count recipes' : 'Imported Recipe',
    );
  }

  static void onRecipeCooked(WidgetRef ref) {
    ref.read(rpgProvider.notifier).awardXp(
      XpActionType.cookRecipe,
      description: 'Cooked a recipe!',
    );
  }

  static void onPhotoAdded(WidgetRef ref) {
    ref.read(rpgProvider.notifier).awardXp(
      XpActionType.addPhoto,
      description: 'Added photo',
    );
  }

  static void onNutritionAdded(WidgetRef ref) {
    ref.read(rpgProvider.notifier).awardXp(
      XpActionType.addNutrition,
      description: 'Added nutrition info',
    );
  }

  static void onMealPlanned(WidgetRef ref) {
    ref.read(rpgProvider.notifier).awardXp(
      XpActionType.planMeal,
      description: 'Planned a meal',
    );
  }

  static void onShoppingListCompleted(WidgetRef ref) {
    ref.read(rpgProvider.notifier).awardXp(
      XpActionType.completeShoppingList,
      description: 'Completed shopping list!',
    );
  }

  static void onCookbookCreated(WidgetRef ref) {
    ref.read(rpgProvider.notifier).awardXp(
      XpActionType.createCookbook,
      description: 'Created cookbook',
    );
  }

  static void onCookbookUploaded(WidgetRef ref) {
    ref.read(rpgProvider.notifier).awardXp(
      XpActionType.uploadCookbook,
      description: 'Uploaded to community!',
    );
  }

  static void onRecipeRated(WidgetRef ref) {
    ref.read(rpgProvider.notifier).awardXp(
      XpActionType.rateRecipe,
      description: 'Rated recipe',
    );
  }

  static void onNotesAdded(WidgetRef ref) {
    ref.read(rpgProvider.notifier).awardXp(
      XpActionType.addNotes,
      description: 'Added notes',
    );
  }

  // Achievement progress updates
  static void updateRecipeCount(WidgetRef ref, int count) {
    final notifier = ref.read(rpgProvider.notifier);
    notifier.setProgress('ach_recipes_1', count);
    notifier.setProgress('ach_recipes_10', count);
    notifier.setProgress('ach_recipes_50', count);
    notifier.setProgress('ach_recipes_100', count);
    notifier.setProgress('ach_recipes_250', count);
    notifier.setProgress('ach_recipes_500', count);
  }

  static void updateImportCount(WidgetRef ref, int count) {
    final notifier = ref.read(rpgProvider.notifier);
    notifier.setProgress('ach_import_1', count);
    notifier.setProgress('ach_import_25', count);
    notifier.setProgress('ach_import_100', count);
  }

  static void updateCookCount(WidgetRef ref, int count) {
    final notifier = ref.read(rpgProvider.notifier);
    notifier.setProgress('ach_cook_1', count);
    notifier.setProgress('ach_cook_10', count);
    notifier.setProgress('ach_cook_50', count);
    notifier.setProgress('ach_cook_100', count);
    notifier.setProgress('ach_cook_500', count);
  }

  static void updateCookbookCount(WidgetRef ref, int count) {
    final notifier = ref.read(rpgProvider.notifier);
    notifier.setProgress('ach_cookbooks_3', count);
    notifier.setProgress('ach_cookbooks_10', count);
  }
}