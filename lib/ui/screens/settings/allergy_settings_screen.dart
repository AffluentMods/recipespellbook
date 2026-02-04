import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/allergen_data.dart';
import '../../../providers/settings_provider.dart';
import '../../../l10n/app_localizations.dart';

/// Screen for managing user's allergen preferences
class AllergySettingsScreen extends ConsumerStatefulWidget {
  const AllergySettingsScreen({super.key});

  @override
  ConsumerState<AllergySettingsScreen> createState() => _AllergySettingsScreenState();
}

class _AllergySettingsScreenState extends ConsumerState<AllergySettingsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final userAllergens = settings.allergens;

    // Group allergens by category
    final categories = _getGroupedAllergens();

    // Filter by search
    final filteredCategories = _searchQuery.isEmpty
        ? categories
        : _filterCategories(categories, _searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsAllergies),
        actions: [
          if (userAllergens.isNotEmpty)
            TextButton(
              onPressed: () => _clearAll(ref),
              child: Text(l10n.allergyClearAll),
            ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.allergyInfoText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),

          const SizedBox(height: 8),

          // Selected count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  l10n.allergySelectedCount(userAllergens.length),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

          // Allergen list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final category = filteredCategories.keys.elementAt(index);
                final allergens = filteredCategories[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        category,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Allergens in category
                    ...allergens.map((allergen) => _AllergenTile(
                      allergen: allergen,
                      isSelected: userAllergens.contains(allergen),
                      onToggle: () => ref.read(settingsProvider.notifier).toggleAllergen(allergen),
                      l10n: l10n,
                    )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Allergen>> _getGroupedAllergens() {
    return {
      'Common (Big 9)': [
        Allergen.milk,
        Allergen.eggs,
        Allergen.peanuts,
        Allergen.treeNuts,
        Allergen.wheat,
        Allergen.soy,
        Allergen.fish,
        Allergen.shellfish,
        Allergen.sesame,
      ],
      'EU Additional': [
        Allergen.gluten,
        Allergen.mustard,
        Allergen.celery,
        Allergen.lupin,
        Allergen.mollusks,
        Allergen.sulfites,
      ],
      'Other Common': [
        Allergen.corn,
        Allergen.nightshades,
        Allergen.coconut,
      ],
      'Dietary Sensitivities': [
        Allergen.garlic,
        Allergen.onion,
        Allergen.mushrooms,
        Allergen.fodmap,
        Allergen.histamine,
        Allergen.salicylates,
        Allergen.msg,
      ],
      'Stimulants & Alcohol': [
        Allergen.chocolate,
        Allergen.caffeine,
        Allergen.alcohol,
      ],
      'Fruits': [
        Allergen.citrus,
        Allergen.stoneFruits,
        Allergen.avocado,
        Allergen.banana,
        Allergen.kiwi,
        Allergen.latexFoods,
      ],
      'Animal Products': [
        Allergen.redMeat,
        Allergen.gelatin,
      ],
    };
  }

  Map<String, List<Allergen>> _filterCategories(
      Map<String, List<Allergen>> categories,
      String query,
      ) {
    final filtered = <String, List<Allergen>>{};

    for (final entry in categories.entries) {
      final matchingAllergens = entry.value.where((allergen) {
        return allergen.displayName.toLowerCase().contains(query) ||
            allergen.key.toLowerCase().contains(query) ||
            allergen.description.toLowerCase().contains(query);
      }).toList();

      if (matchingAllergens.isNotEmpty) {
        filtered[entry.key] = matchingAllergens;
      }
    }

    return filtered;
  }

  void _clearAll(WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.allergyClearAll),
        content: const Text('This will remove all your allergen selections.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(settingsProvider.notifier).setAllergens([]);
            },
            child: Text(l10n.allergyClearAll),
          ),
        ],
      ),
    );
  }
}

class _AllergenTile extends StatelessWidget {
  final Allergen allergen;
  final bool isSelected;
  final VoidCallback onToggle;
  final AppLocalizations l10n;

  const _AllergenTile({
    required this.allergen,
    required this.isSelected,
    required this.onToggle,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(allergen.emoji, style: const TextStyle(fontSize: 20)),
        ),
      ),
      title: Text(allergen.getLocalizedName(l10n)),
      subtitle: Text(
        allergen.description,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Switch(
        value: isSelected,
        onChanged: (_) => onToggle(),
      ),
      onTap: onToggle,
    );
  }
}