import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/allergen_data.dart';
import '../../../providers/settings_provider.dart';
import '../../../l10n/app_localizations.dart';

/// Screen for managing user's allergen/allergy settings
class AllergySettingsScreen extends ConsumerStatefulWidget {
  const AllergySettingsScreen({super.key});

  @override
  ConsumerState<AllergySettingsScreen> createState() => _AllergySettingsScreenState();
}

class _AllergySettingsScreenState extends ConsumerState<AllergySettingsScreen> {
  late Set<Allergen> _selectedAllergens;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _selectedAllergens = Set.from(settings.allergens);
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

    // Group allergens: Major (FDA) and Additional
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
        ),
        body: ListView(
          children: [
            // Info card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
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

            const SizedBox(height: 100), // Bottom padding for FAB
          ],
        ),
        floatingActionButton: _hasChanges
            ? FloatingActionButton.extended(
          onPressed: _saveAndPop,
          icon: const Icon(Icons.save),
          label: Text(l10n.actionSave),
        )
            : null,
      ),
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
    // Return localized name based on allergen
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