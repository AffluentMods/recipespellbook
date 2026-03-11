import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/allergen_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/recipe_image.dart';

/// Provider for dismissed allergy warnings
/// Stores recipe IDs where user has permanently dismissed warnings
final dismissedAllergyWarningsProvider = StateNotifierProvider<DismissedAllergyWarningsNotifier, Map<String, Set<Allergen>>>((ref) {
  return DismissedAllergyWarningsNotifier();
});

class DismissedAllergyWarningsNotifier extends StateNotifier<Map<String, Set<Allergen>>> {
  static const _storageKey = 'dismissed_allergy_warnings';

  DismissedAllergyWarningsNotifier() : super({}) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_storageKey) ?? [];

    final Map<String, Set<Allergen>> loaded = {};
    for (final entry in stored) {
      final parts = entry.split('|');
      if (parts.length == 2) {
        final recipeId = parts[0];
        final allergenNames = parts[1].split(',');
        loaded[recipeId] = allergenNames
            .map((name) => Allergen.values.firstWhere(
              (a) => a.name == name,
          orElse: () => Allergen.milk,
        ))
            .toSet();
      }
    }
    state = loaded;
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = state.entries.map((e) {
      final allergenNames = e.value.map((a) => a.name).join(',');
      return '${e.key}|$allergenNames';
    }).toList();
    await prefs.setStringList(_storageKey, entries);
  }

  void dismissForRecipe(String recipeId, Set<Allergen> allergens) {
    state = {
      ...state,
      recipeId: {...(state[recipeId] ?? {}), ...allergens},
    };
    _saveToStorage();
  }

  void restoreForRecipe(String recipeId) {
    final newState = Map<String, Set<Allergen>>.from(state);
    newState.remove(recipeId);
    state = newState;
    _saveToStorage();
  }

  void restoreAll() {
    state = {};
    _saveToStorage();
  }

  bool isDismissed(String recipeId, Allergen allergen) {
    return state[recipeId]?.contains(allergen) ?? false;
  }

  Set<Allergen> getDismissedForRecipe(String recipeId) {
    return state[recipeId] ?? {};
  }
}

/// Screen for managing user's allergen/allergy settings with tabs
class AllergySettingsScreen extends ConsumerStatefulWidget {
  const AllergySettingsScreen({super.key});

  @override
  ConsumerState<AllergySettingsScreen> createState() => _AllergySettingsScreenState();
}

class _AllergySettingsScreenState extends ConsumerState<AllergySettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Set<Allergen> _selectedAllergens;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final settings = ref.read(settingsProvider);
    _selectedAllergens = Set.from(settings.allergens);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleAllergen(Allergen allergen) {
    setState(() {
      if (_selectedAllergens.contains(allergen)) {
        _selectedAllergens.remove(allergen);
      } else {
        _selectedAllergens.add(allergen);
      }
      _hasChanges = true;
    });
  }

  void _saveAndPop() {
    ref.read(settingsProvider.notifier).setAllergens(_selectedAllergens.toList());
    Navigator.pop(context);
  }

  void _selectAll() {
    setState(() {
      _selectedAllergens = Set.from(Allergen.values);
      _hasChanges = true;
    });
  }

  void _clearAll() {
    setState(() {
      _selectedAllergens.clear();
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dismissedWarnings = ref.watch(dismissedAllergyWarningsProvider);
    final dismissedCount = dismissedWarnings.length;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasChanges) {
          _showUnsavedChangesDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.allergySettingsTitle),
          actions: [
            if (_tabController.index == 0)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'all') _selectAll();
                  if (value == 'none') _clearAll();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'all',
                    child: Row(
                      children: [
                        const Icon(Icons.select_all),
                        const SizedBox(width: 12),
                        Text(l10n.allergySelectAll),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'none',
                    child: Row(
                      children: [
                        const Icon(Icons.deselect),
                        const SizedBox(width: 12),
                        Text(l10n.allergyClearAll),
                      ],
                    ),
                  ),
                ],
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            onTap: (_) => setState(() {}),
            tabs: [
              Tab(
                icon: const Icon(Icons.warning_amber),
                text: l10n.allergyMyAllergies,
              ),
              Tab(
                icon: Badge(
                  isLabelVisible: dismissedCount > 0,
                  label: Text('$dismissedCount'),
                  child: const Icon(Icons.visibility_off),
                ),
                text: l10n.allergyDisabledTab,
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: My Allergies
            _buildAllergiesTab(theme, l10n),
            // Tab 2: Disabled Warnings
            _DisabledWarningsTab(),
          ],
        ),
        floatingActionButton: _hasChanges && _tabController.index == 0
            ? FloatingActionButton.extended(
          onPressed: _saveAndPop,
          icon: const Icon(Icons.save),
          label: Text(l10n.actionSave),
        )
            : null,
      ),
    );
  }

  Widget _buildAllergiesTab(ThemeData theme, AppLocalizations l10n) {
    final majorAllergens = [
      Allergen.milk,
      Allergen.eggs,
      Allergen.fish,
      Allergen.shellfish,
      Allergen.treeNuts,
      Allergen.peanuts,
      Allergen.wheat,
      Allergen.soy,
      Allergen.sesame,
    ];
    final additionalAllergens = Allergen.values
        .where((a) => !majorAllergens.contains(a))
        .toList();

    return ListView(
      children: [
        // Info card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.allergyInfoText,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),

        // Selected count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.allergySelectedCount(_selectedAllergens.length),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Major Allergens Section
        _buildSectionHeader(
          theme,
          l10n.allergyMajorTitle,
          l10n.allergyMajorSubtitle,
        ),

        ...majorAllergens.map((allergen) => _buildAllergenTile(
          theme,
          allergen,
          l10n,
        )),

        const Divider(height: 32),

        // Additional Allergens Section
        _buildSectionHeader(
          theme,
          l10n.allergyAdditionalTitle,
          l10n.allergyAdditionalSubtitle,
        ),

        ...additionalAllergens.map((allergen) => _buildAllergenTile(
          theme,
          allergen,
          l10n,
        )),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergenTile(
      ThemeData theme,
      Allergen allergen,
      AppLocalizations l10n,
      ) {
    final isSelected = _selectedAllergens.contains(allergen);
    final localizedName = _getLocalizedAllergenName(allergen, l10n);

    return CheckboxListTile(
      value: isSelected,
      onChanged: (_) => _toggleAllergen(allergen),
      title: Row(
        children: [
          Text(
            allergen.emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Text(localizedName),
        ],
      ),
      subtitle: isSelected
          ? Text(
        l10n.allergyWillWarn,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.orange.shade700,
        ),
      )
          : null,
      secondary: isSelected
          ? Icon(
        Icons.warning_amber,
        color: Colors.orange.shade700,
      )
          : null,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  String _getLocalizedAllergenName(Allergen allergen, AppLocalizations l10n) {
    switch (allergen) {
      case Allergen.milk:
        return l10n.allergenMilk;
      case Allergen.eggs:
        return l10n.allergenEggs;
      case Allergen.fish:
        return l10n.allergenFish;
      case Allergen.shellfish:
        return l10n.allergenShellfish;
      case Allergen.treeNuts:
        return l10n.allergenTreeNuts;
      case Allergen.peanuts:
        return l10n.allergenPeanuts;
      case Allergen.wheat:
        return l10n.allergenWheat;
      case Allergen.soy:
        return l10n.allergenSoy;
      case Allergen.sesame:
        return l10n.allergenSesame;
      case Allergen.mustard:
        return l10n.allergenMustard;
      case Allergen.celery:
        return l10n.allergenCelery;
      case Allergen.lupin:
        return l10n.allergenLupin;
      case Allergen.mollusks:
        return l10n.allergenMollusks;
      case Allergen.sulfites:
        return l10n.allergenSulfites;
      case Allergen.corn:
        return l10n.allergenCorn;
      case Allergen.nightshades:
        return l10n.allergenNightshades;
      case Allergen.gluten:
        return l10n.allergenGluten;
      case Allergen.chocolate:
        return l10n.allergenChocolate;
      case Allergen.caffeine:
        return l10n.allergenCaffeine;
      case Allergen.alcohol:
        return l10n.allergenAlcohol;
      case Allergen.citrus:
        return l10n.allergenCitrus;
      case Allergen.stoneFruits:
        return l10n.allergenStoneFruits;
      case Allergen.coconut:
        return l10n.allergenCoconut;
      case Allergen.garlic:
        return l10n.allergenGarlic;
      case Allergen.onion:
        return l10n.allergenOnion;
      case Allergen.mushrooms:
        return l10n.allergenMushrooms;
      case Allergen.avocado:
        return l10n.allergenAvocado;
      case Allergen.banana:
        return l10n.allergenBanana;
      case Allergen.kiwi:
        return l10n.allergenKiwi;
      case Allergen.latexFoods:
        return l10n.allergenLatexFoods;
      case Allergen.fodmap:
        return l10n.allergenFodmap;
      case Allergen.histamine:
        return l10n.allergenHistamine;
      case Allergen.salicylates:
        return l10n.allergenSalicylates;
      case Allergen.msg:
        return l10n.allergenMsg;
      case Allergen.redMeat:
        return l10n.allergenRedMeat;
      case Allergen.gelatin:
        return l10n.allergenGelatin;
    }
  }

  Future<void> _showUnsavedChangesDialog() async {
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsavedChangesTitle),
        content: Text(l10n.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionDiscard),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );

    if (result == true) {
      _saveAndPop();
    } else if (result == false) {
      if (mounted) Navigator.pop(context);
    }
  }
}

// ============ DISABLED WARNINGS TAB ============

class _DisabledWarningsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dismissedWarnings = ref.watch(dismissedAllergyWarningsProvider);

    if (dismissedWarnings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.allergyNoDisabledTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.allergyNoDisabledSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      children: [
        // Info card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.allergyDisabledInfo,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),

        // Restore All button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: () => _restoreAll(context, ref),
            icon: const Icon(Icons.restore),
            label: Text(l10n.restoreAllWarnings),
          ),
        ),

        const SizedBox(height: 16),

        // List of recipes with disabled warnings
        ...dismissedWarnings.entries.map((entry) {
          return _DisabledRecipeTile(
            recipeId: entry.key,
            dismissedAllergens: entry.value,
            onRestore: () {
              ref.read(dismissedAllergyWarningsProvider.notifier)
                  .restoreForRecipe(entry.key);
              AppSnackbar.info(context, l10n.warningsRestoredForRecipe);
            },
          );
        }),

        const SizedBox(height: 100),
      ],
    );
  }

  void _restoreAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.restoreAllWarningsQuestion),
        content: Text(
          l10n.restoreAllWarningsDesc,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.restoreAll),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(dismissedAllergyWarningsProvider.notifier).restoreAll();
      if (context.mounted) {
        AppSnackbar.info(context, l10n.allWarningsRestored);
      }
    }
  }
}

class _DisabledRecipeTile extends ConsumerWidget {
  final String recipeId;
  final Set<Allergen> dismissedAllergens;
  final VoidCallback onRestore;

  const _DisabledRecipeTile({
    required this.recipeId,
    required this.dismissedAllergens,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dao = ref.watch(recipeDaoProvider);

    return FutureBuilder(
      future: dao.getRecipeById(recipeId),
      builder: (context, snapshot) {
        final recipe = snapshot.data;
        final recipeName = recipe?.title ?? recipeId;


        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Recipe image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: RecipeImage.thumbnail(
                    imagePath: recipe?.imagePath,
                    recipeId: recipeId,
                    width: 56,
                    height: 56,
                  ),
                ),
                const SizedBox(width: 12),

                // Recipe info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipeName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Allergen chips
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: dismissedAllergens.take(4).map((allergen) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  allergen.emoji,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  allergen.getLocalizedName(l10n),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Restore button
                IconButton(
                  onPressed: onRestore,
                  icon: Icon(
                    Icons.restore,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: l10n.restoreAllWarnings,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}