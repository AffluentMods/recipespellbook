import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/ui/screens/settings/pantry_screen.dart';
import '../../../data/app_enums.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/export_import_service.dart';
import '../../../services/grocery_service.dart';
import '../../../services/onboarding_service.dart';
import '../../../services/revenuecat_service.dart';
import '../../widgets/app_snackbar.dart';
import 'nutrition_settings_screen.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        children: [
          // ============ COMPACT UPGRADE CARD (free users only) ============
          if (ref.watch(subscriptionProvider).tier == SubscriptionTier.free)
            _CompactUpgradeCard(),

          // ============ APPEARANCE ============
          _SettingsSection(
            title: l10n.settingsAppearance,
            children: [
              _ThemeSelectionTile(
                currentTheme: settings.appTheme,
                onThemeSelected: (appTheme) {
                  ref.read(settingsProvider.notifier).setAppTheme(appTheme);
                },
              ),
              _ThemeModeTile(
                currentMode: settings.themeMode,
                onModeSelected: (mode) {
                  ref.read(settingsProvider.notifier).setThemeMode(mode);
                },
              ),
              _LanguageTile(
                currentLanguage: settings.languageCode,
                onLanguageSelected: (code) {
                  ref.read(settingsProvider.notifier).setLanguage(code);
                },
              ),
              _TextScaleTile(
                currentScale: settings.textScaleFactor,
                onScaleChanged: (scale) {
                  ref.read(settingsProvider.notifier).setTextScaleFactor(scale);
                },
              ),
              _SettingsTile(
                icon: Icons.tune,
                title: l10n.nutritionDisplay,
                subtitle: l10n.nutritionDisplaySubtitle,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NutritionSettingsScreen()),
                ),
              ),
              _WeekStartDayTile(
                currentDay: settings.weekStartDay,
                onDaySelected: (day) {
                  ref.read(settingsProvider.notifier).setWeekStartDay(day);
                },
              ),
            ],
          ),

          // ============ RECIPES & SHOPPING ============
          _SettingsSection(
            title: 'Recipes & Shopping',
            children: [
              _SettingsTile(
                icon: Icons.bolt,
                title: l10n.settingsQuickAccess,
                subtitle: l10n.settingsQuickAccessSubtitle,
                onTap: () => context.push('/settings/quick-access'),
              ),
              _SettingsTile(
                icon: Icons.view_agenda,
                title: l10n.settingsRecipeLayout,
                subtitle: settings.recipeLayoutMode == RecipeLayoutMode.tabbed
                    ? l10n.layoutTabbed
                    : l10n.layoutStacked,
                onTap: () => context.push('/settings/recipe-layout'),
              ),
              _SettingsTile(
                icon: Icons.format_align_left,
                title: l10n.settingsIngredientLayout,
                subtitle: settings.ingredientLayout == IngredientLayout.columnar
                    ? l10n.ingredientLayoutColumnar
                    : l10n.ingredientLayoutInline,
                onTap: () => context.push('/settings/ingredient-layout'),
              ),
              _MeasurementSystemTile(
                currentSystem: settings.measurementSystem,
                onSystemSelected: (system) {
                  ref.read(settingsProvider.notifier).setMeasurementSystem(system);
                },
              ),
              _SettingsTile(
                icon: settings.nerdMode ? Icons.flash_on : Icons.warning_amber,
                title: settings.nerdMode ? 'Weaknesses' : l10n.settingsAllergies,
                subtitle: settings.nerdMode ? 'Set your dietary vulnerabilities' : l10n.settingsAllergiesSubtitle,
                onTap: () => context.push('/settings/allergies'),
              ),
              _SettingsTile(
                icon: Icons.kitchen,
                title: l10n.myPantry,
                subtitle: l10n.itemsAlwaysOnHand,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PantryScreen())),
              ),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: l10n.trashTitle,
                subtitle: l10n.trashSubtitle,
                onTap: () => context.push('/settings/trash'),
              ),
            ],
          ),

          // ============ INTEGRATIONS ============
          const _IntegrationsSection(),

          // ============ ADVANCED SETTINGS ============
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdvancedSettingsScreen())),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.tune, size: 20, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Advanced Settings',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            Text('Tags, courses, categories & more',
                                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 20,
                          color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ============ DATA ============
          _SettingsSection(
            title: l10n.settingsData,
            children: [
              _SettingsTile(
                icon: Icons.file_upload_outlined,
                title: l10n.settingsExport,
                subtitle: l10n.settingsExportSubtitle,
                onTap: () => _showExportOptions(context, ref),
              ),
              _SettingsTile(
                icon: Icons.file_download_outlined,
                title: l10n.settingsImport,
                subtitle: l10n.settingsImportSubtitle,
                onTap: () => _showImportOptions(context, ref),
              ),
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                title: 'Delete Data',
                subtitle: 'Erase app or cloud data',
                titleColor: theme.colorScheme.error,
                onTap: () => _showResetConfirmation(context, ref),
              ),
            ],
          ),

          // ============ SECRET ============
          _SettingsSection(
            title: settings.nerdMode ? '\u{1F3AE} RPG Mode' : '\u2728 Secret',
            children: [
              _RpgModeTile(
                isEnabled: settings.nerdMode,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setNerdMode(value);
                },
              ),
            ],
          ),

          // ============ ABOUT ============
          _SettingsSection(
            title: l10n.settingsAbout,
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: l10n.appTitle,
                subtitle: 'Version 1.0.3 · Beta',
                onTap: () => context.push('/about'),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(databaseProvider);
    final service = ExportImportService(db);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ExportOptionsSheet(
        l10n: l10n,
        onExportCookbook: () async {
          Navigator.pop(context);
          _showLoadingSnackbar(context, l10n.exporting);
          final cookbookId = ref.read(selectedCookbookIdProvider) ?? 'starter';
          final data = await service.exportCookbook(cookbookId);
          await service.shareExport(data, 'cookbook_export.json');
          if (context.mounted) AppSnackbar.dismiss(context);
        },
        onExportSelective: (options) async {
          Navigator.pop(context);
          _showLoadingSnackbar(context, l10n.exporting);
          final data = await service.exportSelective(options);
          await service.shareExport(data, 'recipe_spellbook_backup.json');
          if (context.mounted) AppSnackbar.dismiss(context);
        },
      ),
    );
  }

  void _showImportOptions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(databaseProvider);
    final service = ExportImportService(db);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.settingsImport,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.file_open),
              title: Text(l10n.importFromJson),
              subtitle: Text(l10n.importFromJsonSubtitle),
              onTap: () async {
                Navigator.pop(context);
                _showLoadingSnackbar(context, l10n.importing);
                final result = await service.importFromFile();
                if (context.mounted) {
                  AppSnackbar.dismiss(context);
                  if (result.success) {
                    AppSnackbar.success(context, result.message);
                  } else {
                    AppSnackbar.error(context, result.message);
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLoadingSnackbar(BuildContext context, String message) {
    AppSnackbar.loading(context, message);
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, size: 48, color: theme.colorScheme.error),
        title: Text(l10n.resetApp),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.resetAppWarning),
            const SizedBox(height: 20),
            Text(l10n.whatToDelete,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Local Data option
            _ResetOptionTile(
              icon: Icons.phone_android,
              title: l10n.localData,
              subtitle: l10n.localDataDesc,
              color: theme.colorScheme.error,
              onTap: () {
                Navigator.pop(context);
                _showFinalResetConfirmation(context, ref, _ResetScope.local);
              },
            ),
            const SizedBox(height: 8),
            // Cloud Data option (disabled for now)
            _ResetOptionTile(
              icon: Icons.cloud_outlined,
              title: l10n.cloudData,
              subtitle: l10n.cloudDataDesc,
              color: theme.colorScheme.outline,
              enabled: false,
              onTap: () {},
            ),
            const SizedBox(height: 8),
            // All Data option
            _ResetOptionTile(
              icon: Icons.delete_forever,
              title: l10n.allData,
              subtitle: l10n.allDataDesc,
              color: theme.colorScheme.error,
              onTap: () {
                Navigator.pop(context);
                _showFinalResetConfirmation(context, ref, _ResetScope.all);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
        ],
      ),
    );
  }

  void _showFinalResetConfirmation(BuildContext context, WidgetRef ref, _ResetScope scope) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    final scopeLabel = switch (scope) {
      _ResetScope.local => 'local data',
      _ResetScope.cloud => 'cloud data',
      _ResetScope.all => 'all data and settings',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.delete_forever, size: 48, color: Theme.of(context).colorScheme.error),
        title: Text(l10n.finalConfirmation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.permanentlyDeleteWarning(scopeLabel)),
            const SizedBox(height: 16),
            Text(l10n.typeDeleteToConfirm, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: l10n.typeDeleteHint,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final isValid = controller.text.toUpperCase() == 'DELETE';
              return FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: isValid ? () => _performReset(context, ref, l10n, scope) : null,
                child: Text(l10n.actionDelete),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _performReset(BuildContext context, WidgetRef ref, AppLocalizations l10n, _ResetScope scope) async {
    try {
      final db = ref.read(databaseProvider);

      // Delete all recipe data (order matters for foreign key deps)
      await db.customStatement('DELETE FROM recipe_links');
      await db.customStatement('DELETE FROM recipe_tags');
      await db.customStatement('DELETE FROM ingredient_usda_mappings');
      await db.customStatement('DELETE FROM user_ingredient_mappings');
      await db.customStatement('DELETE FROM ingredients');
      await db.customStatement('DELETE FROM steps');
      await db.customStatement('DELETE FROM recipes');
      await db.customStatement("DELETE FROM cookbooks WHERE id != 'starter'");

      // Delete shopping data
      await db.customStatement('DELETE FROM shopping_list_items');
      await db.customStatement("DELETE FROM shopping_lists WHERE id != 'list_default'");

      // Delete meal plans
      await db.customStatement('DELETE FROM meal_plans');

      // Delete custom taxonomy (keep system defaults)
      await db.customStatement('DELETE FROM custom_courses');
      await db.customStatement('DELETE FROM custom_categories');

      if (scope == _ResetScope.all) {
        // Also reset all settings to defaults
        ref.read(settingsProvider.notifier).resetToDefaults();
      }

      if (context.mounted) {
        Navigator.pop(context); // Close the type-DELETE dialog
        _showReimportDefaultsDialog(context, ref, l10n);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        AppSnackbar.error(context, '${l10n.resetFailed}: $e');
      }
    }
  }

  void _showReimportDefaultsDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.auto_awesome, size: 48, color: Colors.amber),
        title: Text(l10n.dataResetComplete),
        content: const Text(
          'All data has been cleared successfully.\n\n'
              'Would you like to import the 10 default starter recipes?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppSnackbar.success(context, l10n.appResetSuccess);
              context.go('/');
            },
            child: Text(l10n.noThanks),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingSnackbar(context, 'Importing default recipes...');
              try {
                final db = ref.read(databaseProvider);
                final count = await OnboardingService.seedDefaultRecipes(db);
                if (context.mounted) {
                  AppSnackbar.dismiss(context);
                  AppSnackbar.success(context, l10n.defaultRecipesImported(count));
                  context.go('/');
                }
              } catch (e) {
                if (context.mounted) {
                  AppSnackbar.dismiss(context);
                  AppSnackbar.error(context, '${l10n.importFailed}: $e');
                  context.go('/');
                }
              }
            },
            child: Text(l10n.yesAddThem),
          ),
        ],
      ),
    );
  }
}

// ============ RESET SCOPE ENUM ============

enum _ResetScope { local, cloud, all }

class _ResetOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ResetOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600, color: color,
                      )),
                      Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                    ],
                  ),
                ),
                if (enabled)
                  Icon(Icons.chevron_right, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============ COMPACT UPGRADE CARD ============

class _CompactUpgradeCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [Colors.amber.shade600, Colors.orange.shade500],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => context.push('/upgrade'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.star_rounded, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Upgrade to Pro',
                            style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Cloud sync, photos & more',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85))),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.7), size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============ TEXT SCALE TILE — ACCESSIBILITY ============

class _TextScaleTile extends StatelessWidget {
  final double currentScale;
  final ValueChanged<double> onScaleChanged;

  const _TextScaleTile({required this.currentScale, required this.onScaleChanged});

  String get _scaleLabel {
    if (currentScale <= 0.85) return 'Small';
    if (currentScale <= 0.95) return 'Default';
    if (currentScale <= 1.05) return 'Medium';
    if (currentScale <= 1.15) return 'Large';
    return 'Extra Large';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.text_fields_rounded, size: 20, color: theme.colorScheme.primary),
      ),
      title: const Text('Text Size',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(_scaleLabel,
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right,
          size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      onTap: () => _showTextScalePicker(context),
    );
  }

  void _showTextScalePicker(BuildContext context) {
    final theme = Theme.of(context);
    double tempScale = currentScale;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Text Size', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Adjust text size across the entire app',
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 24),

                // Preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preview',
                          style: TextStyle(fontSize: 12 * tempScale, color: theme.colorScheme.outline)),
                      const SizedBox(height: 4),
                      Text('Grandma\'s Famous Chocolate Cake',
                          style: TextStyle(fontSize: 16 * tempScale, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('2 cups flour, 1 cup sugar, 3 eggs',
                          style: TextStyle(fontSize: 14 * tempScale, color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Slider with labels
                Row(
                  children: [
                    Text('A', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.outline)),
                    Expanded(
                      child: Slider(
                        value: tempScale,
                        min: 0.8,
                        max: 1.3,
                        divisions: 5,
                        label: '${(tempScale * 100).round()}%',
                        onChanged: (val) {
                          setSheetState(() => tempScale = val);
                          onScaleChanged(val);
                        },
                      ),
                    ),
                    Text('A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.outline)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${(tempScale * 100).round()}%',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ============ HELPER WIDGETS ============

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final itemBg = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : theme.colorScheme.surfaceContainerLowest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: itemBg,
            borderRadius: BorderRadius.circular(16),
            border: isDark
                ? Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 0.5,
            )
                : Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    indent: 56,
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;
  final bool enabled;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = enabled
        ? (titleColor ?? theme.colorScheme.primary)
        : theme.colorScheme.outline;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: enabled ? titleColor : theme.colorScheme.outline,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: enabled
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.outline,
        ),
      ),
      trailing: enabled
          ? Icon(Icons.chevron_right,
          size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5))
          : null,
      onTap: enabled ? onTap : null,
    );
  }
}


// ============ RPG MODE TILE WITH ANIMATION ============

class _RpgModeTile extends StatefulWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const _RpgModeTile({required this.isEnabled, required this.onChanged});

  @override
  State<_RpgModeTile> createState() => _RpgModeTileState();
}

class _RpgModeTileState extends State<_RpgModeTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _glowAnimation;
  bool _showMagicEffect = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.03), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.03, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleToggle(bool value) {
    if (value) {
      setState(() => _showMagicEffect = true);
      _controller.forward(from: 0.0).then((_) {
        setState(() => _showMagicEffect = false);
      });
    }
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (_showMagicEffect)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _glowAnimation.value * 0.3,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(_glowAnimation.value * 0.5),
                          blurRadius: 20 * _glowAnimation.value,
                          spreadRadius: 5 * _glowAnimation.value,
                        ),
                        BoxShadow(
                          color: Colors.amber.withOpacity(_glowAnimation.value * 0.3),
                          blurRadius: 30 * _glowAnimation.value,
                          spreadRadius: 10 * _glowAnimation.value,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotateAnimation.value,
                child: Container(
                  margin: _showMagicEffect
                      ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                      : EdgeInsets.zero,
                  decoration: _showMagicEffect
                      ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withOpacity(_glowAnimation.value * 0.8),
                      width: 2,
                    ),
                  )
                      : null,
                  child: SwitchListTile(
                    secondary: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.isEnabled
                            ? Colors.purple.withValues(alpha: 0.2)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: RotationTransition(
                              turns: Tween(begin: 0.5, end: 1.0).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          widget.isEnabled ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                          key: ValueKey(widget.isEnabled),
                          color: widget.isEnabled ? Colors.amber : null,
                        ),
                      ),
                    ),
                    title: Text(
                      l10n.settingsRPGMode,
                      style: TextStyle(
                        fontWeight: widget.isEnabled ? FontWeight.bold : FontWeight.normal,
                        color: widget.isEnabled ? Colors.amber.shade700 : null,
                      ),
                    ),
                    subtitle: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        widget.isEnabled
                            ? l10n.settingsRPGModeActive
                            : l10n.settingsRPGModeSubtitle,
                        key: ValueKey(widget.isEnabled),
                        style: TextStyle(
                          color: widget.isEnabled ? Colors.purple : null,
                          fontStyle: widget.isEnabled ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                    ),
                    value: widget.isEnabled,
                    onChanged: _handleToggle,
                  ),
                ),
              ),
            ),

            if (_showMagicEffect)
              ...List.generate(8, (index) {
                final radius = 40 + (index % 3) * 20.0;
                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 +
                      radius * _glowAnimation.value * (index.isEven ? 1 : -1) *
                          (0.5 + 0.5 * (index % 3)) - 10,
                  top: 30 + radius * _glowAnimation.value * (index < 4 ? -1 : 1) * 0.5,
                  child: AnimatedOpacity(
                    opacity: (1 - _glowAnimation.value).clamp(0.0, 1.0),
                    duration: const Duration(milliseconds: 100),
                    child: Text(
                      ['✨', '⭐', '💫', '🌟'][index % 4],
                      style: TextStyle(fontSize: 12 + (index % 3) * 4.0),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}


class _ThemeSelectionTile extends StatelessWidget {
  final AppColorTheme currentTheme;
  final ValueChanged<AppColorTheme> onThemeSelected;

  const _ThemeSelectionTile({required this.currentTheme, required this.onThemeSelected});

  String _getThemeName(BuildContext context, AppColorTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    switch (theme) {
      case AppColorTheme.spellbook:
        return l10n.themeSpellbook;
      case AppColorTheme.forest:
        return l10n.themeForest;
      case AppColorTheme.ocean:
        return l10n.themeOcean;
      case AppColorTheme.sunset:
        return l10n.themeSunset;
      case AppColorTheme.midnight:
        return l10n.themeMidnight;
      case AppColorTheme.rose:
        return l10n.themeRose;
      case AppColorTheme.frost:
        return 'Frost';
      case AppColorTheme.ember:
        return 'Ember';
      case AppColorTheme.spring:
        return 'Spring';
      case AppColorTheme.alchemist:
        return 'Alchemist';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.palette_outlined, size: 20, color: theme.colorScheme.primary),
      ),
      title: Text(l10n.settingsTheme,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text('${currentTheme.emoji} ${_getThemeName(context, currentTheme)}',
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right,
          size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      onTap: () => _showThemePicker(context),
    );
  }

  void _showThemePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => SafeArea(
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 8),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.settingsTheme, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: AppColorTheme.values.length,
                  itemBuilder: (context, index) {
                    final appTheme = AppColorTheme.values[index];
                    final isSelected = currentTheme == appTheme;
                    return _ThemeCard(
                      theme: appTheme,
                      label: _getThemeName(context, appTheme),
                      isSelected: isSelected,
                      onTap: () {
                        onThemeSelected(appTheme);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AppColorTheme theme;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final uiTheme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? uiTheme.colorScheme.primary : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: uiTheme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8)]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isSelected ? 11 : 14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Banner image
              Image.asset(
                theme.bannerAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: theme.seedColor.withValues(alpha: 0.3),
                ),
              ),

              // Bottom label bar
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(theme.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ThemeModeTile extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onModeSelected;

  const _ThemeModeTile({required this.currentMode, required this.onModeSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String subtitle;
    IconData icon;

    switch (currentMode) {
      case ThemeMode.system:
        subtitle = l10n.settingsThemeModeSystem;
        icon = Icons.brightness_auto;
        break;
      case ThemeMode.light:
        subtitle = l10n.settingsThemeModeLight;
        icon = Icons.light_mode;
        break;
      case ThemeMode.dark:
        subtitle = l10n.settingsThemeModeDark;
        icon = Icons.dark_mode;
        break;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(l10n.settingsThemeMode,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right,
          size: 20, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
      onTap: () => _showModePicker(context),
    );
  }

  void _showModePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Text(l10n.settingsThemeMode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: Text(l10n.settingsThemeModeSystem),
              trailing: currentMode == ThemeMode.system ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
              onTap: () { onModeSelected(ThemeMode.system); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: Text(l10n.settingsThemeModeLight),
              trailing: currentMode == ThemeMode.light ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
              onTap: () { onModeSelected(ThemeMode.light); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: Text(l10n.settingsThemeModeDark),
              trailing: currentMode == ThemeMode.dark ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
              onTap: () { onModeSelected(ThemeMode.dark); Navigator.pop(context); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}


class _MeasurementSystemTile extends StatelessWidget {
  final MeasurementSystem currentSystem;
  final ValueChanged<MeasurementSystem> onSystemSelected;

  const _MeasurementSystemTile({required this.currentSystem, required this.onSystemSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.straighten, size: 20, color: theme.colorScheme.primary),
      ),
      title: Text(l10n.settingsMeasurements,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(currentSystem.displayName,
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right,
          size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      onTap: () => _showSystemPicker(context),
    );
  }

  void _showSystemPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Text(l10n.settingsMeasurements, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: Text(l10n.settingsMeasurementsUS),
              subtitle: Text(l10n.usUnits),
              trailing: currentSystem == MeasurementSystem.us ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
              onTap: () { onSystemSelected(MeasurementSystem.us); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Text('🌍', style: TextStyle(fontSize: 24)),
              title: Text(l10n.settingsMeasurementsMetric),
              subtitle: Text(l10n.metricUnits),
              trailing: currentSystem == MeasurementSystem.metric ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
              onTap: () { onSystemSelected(MeasurementSystem.metric); Navigator.pop(context); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}


class _WeekStartDayTile extends StatelessWidget {
  final int currentDay; // 1=Mon .. 7=Sun
  final ValueChanged<int> onDaySelected;

  const _WeekStartDayTile({required this.currentDay, required this.onDaySelected});

  String _dayName(BuildContext context, int day) {
    final l10n = AppLocalizations.of(context)!;
    switch (day) {
      case 1: return l10n.monday;
      case 2: return l10n.tuesday;
      case 3: return l10n.wednesday;
      case 4: return l10n.thursday;
      case 5: return l10n.friday;
      case 6: return l10n.saturday;
      case 7: return l10n.sunday;
      default: return l10n.monday;
    }
  }

  String _dayEmoji(int day) {
    switch (day) {
      case 1: return '📅';
      case 2: return '🔥';
      case 3: return '💧';
      case 4: return '⚡';
      case 5: return '🎉';
      case 6: return '🛋️';
      case 7: return '☀️';
      default: return '📅';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.calendar_today, size: 20, color: theme.colorScheme.primary),
      ),
      title: Text(l10n.settingsWeekStartDay,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(_dayName(context, currentDay),
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right,
          size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      onTap: () => _showDayPicker(context),
    );
  }

  void _showDayPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.settingsWeekStartDay, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...[1, 2, 3, 4, 5, 6, 7].map((day) => ListTile(
              leading: Text(
                _dayEmoji(day),
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(_dayName(context, day)),
              trailing: currentDay == day
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                onDaySelected(day);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}


class _LanguageTile extends StatelessWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageSelected;

  const _LanguageTile({required this.currentLanguage, required this.onLanguageSelected});

  String get _currentLanguageName {
    for (final lang in supportedLanguages) {
      if (lang.code == currentLanguage) return '${lang.flag} ${lang.nativeName}';
    }
    return '🌐 System';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.language, size: 20, color: theme.colorScheme.primary),
      ),
      title: Text(l10n.settingsLanguage,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(_currentLanguageName,
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right,
          size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      onTap: () => _showLanguagePicker(context),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Text(l10n.settingsLanguage, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ...supportedLanguages.map((lang) => ListTile(
              leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
              title: Text(lang.nativeName),
              subtitle: Text(lang.name),
              trailing: currentLanguage == lang.code ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
              onTap: () { onLanguageSelected(lang.code); Navigator.pop(context); },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  INTEGRATIONS SECTION (unified: auth + Discord + stores)
// ════════════════════════════════════════════════════════════

class _IntegrationsSection extends ConsumerStatefulWidget {
  const _IntegrationsSection();

  @override
  ConsumerState<_IntegrationsSection> createState() => _IntegrationsSectionState();
}

class _IntegrationsSectionState extends ConsumerState<_IntegrationsSection> {
  bool _instacartConfigured = false;
  bool _krogerConfigured = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkStoreStatus();
  }

  Future<void> _checkStoreStatus() async {
    final ic = await GroceryService.isConfigured(GroceryProvider.instacart);
    final kr = await GroceryService.isConfigured(GroceryProvider.kroger);
    if (mounted) {
      setState(() {
        _instacartConfigured = ic;
        _krogerConfigured = kr;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    return _SettingsSection(
      title: 'Integrations',
      children: [
        // ── Auth status ──
        _buildAuthTile(context, theme, authState),
        // ── Discord (coming soon) ──
        _SettingsTile(
          icon: Icons.forum_outlined,
          title: 'Discord',
          subtitle: 'Coming soon',
          enabled: false,
          onTap: () {},
        ),
        // ── Instacart ──
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF43B02A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text('\u{1F955}', style: TextStyle(fontSize: 18))),
          ),
          title: Text(l10n.instacart,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          subtitle: Text(
            _loading ? 'Checking...'
                : _instacartConfigured ? 'Connected \u2022 Tap to manage' : 'Not connected',
            style: TextStyle(fontSize: 13,
                color: _instacartConfigured ? const Color(0xFF43B02A) : theme.colorScheme.outline),
          ),
          trailing: _instacartConfigured
              ? const Icon(Icons.check_circle, color: Color(0xFF43B02A), size: 20)
              : Icon(Icons.chevron_right, size: 20,
              color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          onTap: () => _showInstacartOptions(context),
        ),
        // ── Kroger ──
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0068B5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text('\u{1F3EA}', style: TextStyle(fontSize: 18))),
          ),
          title: Text(l10n.kroger,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          subtitle: Text(
            _loading ? 'Checking...'
                : _krogerConfigured ? 'Connected \u2022 Tap to manage' : 'Tap to sign in',
            style: TextStyle(fontSize: 13,
                color: _krogerConfigured ? const Color(0xFF43B02A) : theme.colorScheme.outline),
          ),
          trailing: _krogerConfigured
              ? const Icon(Icons.check_circle, color: Color(0xFF43B02A), size: 20)
              : Icon(Icons.chevron_right, size: 20,
              color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          onTap: () => _showKrogerOptions(context),
        ),
      ],
    );
  }

  Widget _buildAuthTile(BuildContext context, ThemeData theme, AuthState authState) {
    final isSignedIn = authState.isSignedIn;
    final user = authState.user;

    if (isSignedIn && user != null) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF43B02A).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.check_circle, color: Color(0xFF43B02A), size: 20),
        ),
        title: Text('Signed in as ${user.displayName}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: Text(user.email,
            style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
        trailing: TextButton(
          onPressed: () => ref.read(authProvider.notifier).signOut(),
          child: Text('Log out', style: TextStyle(color: theme.colorScheme.error, fontSize: 13)),
        ),
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.person_outline, size: 20, color: theme.colorScheme.primary),
      ),
      title: const Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text('Google or Apple',
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right, size: 20,
          color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      onTap: () => _showSignInSheet(context),
    );
  }

  void _showSignInSheet(BuildContext context) {
    final theme = Theme.of(context);
    final authNotifier = ref.read(authProvider.notifier);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Icon(Icons.account_circle_outlined, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text('Sign In', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Sync recipes and back up your data',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () { Navigator.pop(ctx); authNotifier.signInWithGoogle(); },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                      const SizedBox(width: 10),
                      Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () { Navigator.pop(ctx); authNotifier.signInWithApple(); },
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                    foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.apple, size: 20),
                      const SizedBox(width: 10),
                      const Text('Continue with Apple', style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showInstacartOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Text('\u{1F955}', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(l10n.instacart, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                if (_instacartConfigured) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43B02A).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(l10n.connected,
                        style: const TextStyle(color: Color(0xFF43B02A), fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ]),
            ),
            ListTile(
              leading: const Icon(Icons.vpn_key_outlined),
              title: Text(l10n.setCustomApiKey),
              subtitle: Text(l10n.useOwnInstacartKey),
              onTap: () {
                Navigator.pop(ctx);
                _showApiKeyDialog(context,
                    provider: GroceryProvider.instacart,
                    title: l10n.instacartApiKey,
                    hint: 'Bearer key from Developer Dashboard');
              },
            ),
            ListTile(
              leading: Icon(Icons.link_off, color: theme.colorScheme.error),
              title: Text(l10n.resetToDefaultKey, style: TextStyle(color: theme.colorScheme.error)),
              subtitle: Text(l10n.removeCustomKey),
              onTap: () async {
                Navigator.pop(ctx);
                await GroceryService.disconnect(GroceryProvider.instacart);
                _checkStoreStatus();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showKrogerOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Text('\u{1F3EA}', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(l10n.kroger, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                if (_krogerConfigured) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43B02A).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(l10n.connected,
                        style: const TextStyle(color: Color(0xFF43B02A), fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ]),
            ),
            if (!_krogerConfigured)
              ListTile(
                leading: const Icon(Icons.login),
                title: Text(l10n.signInToKroger),
                subtitle: Text(l10n.connectToAddItems),
                onTap: () async {
                  Navigator.pop(ctx);
                  await GroceryService.krogerStartOAuthLogin();
                },
              ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(l10n.setPreferredStore),
              subtitle: Text(l10n.searchByZipCode),
              onTap: () {
                Navigator.pop(ctx);
                _showKrogerLocationDialog(context);
              },
            ),
            if (_krogerConfigured)
              ListTile(
                leading: Icon(Icons.link_off, color: theme.colorScheme.error),
                title: Text(l10n.disconnect, style: TextStyle(color: theme.colorScheme.error)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await GroceryService.disconnect(GroceryProvider.kroger);
                  _checkStoreStatus();
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, {
    required GroceryProvider provider,
    required String title,
    required String hint,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () async {
              final key = controller.text.trim();
              if (key.isEmpty) return;
              Navigator.pop(ctx);
              await GroceryService.configureInstacart(apiKey: key);
              _checkStoreStatus();
              if (mounted) {
                AppSnackbar.success(context, l10n.apiKeySaved);
              }
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  void _showKrogerLocationDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        List<Map<String, dynamic>> results = [];
        bool searching = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text(l10n.findYourKrogerStore),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: l10n.enterZipCode,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: searching
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.search),
                      onPressed: () async {
                        final zip = controller.text.trim();
                        if (zip.isEmpty) return;
                        setDialogState(() => searching = true);
                        final locs = await GroceryService.krogerSearchLocations(zip);
                        setDialogState(() { results = locs; searching = false; });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                if (results.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: results.length,
                      itemBuilder: (_, i) {
                        final loc = results[i];
                        return ListTile(
                          dense: true,
                          title: Text(loc['name'] ?? 'Store'),
                          subtitle: Text('${loc['address'] ?? ''}, ${loc['city'] ?? ''} ${loc['state'] ?? ''}',
                              style: theme.textTheme.bodySmall),
                          onTap: () async {
                            final id = loc['id']?.toString();
                            if (id != null) await GroceryService.setKrogerLocation(id);
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              AppSnackbar.success(context, l10n.storeSet(loc['name'] ?? 'Kroger'));
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionClose))],
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ADVANCED SETTINGS SCREEN
// ════════════════════════════════════════════════════════════

class AdvancedSettingsScreen extends StatelessWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Settings')),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'Manage',
            children: [
              _SettingsTile(
                icon: Icons.local_offer_outlined,
                title: l10n.settingsManageTags,
                subtitle: l10n.settingsManageTagsSubtitle,
                onTap: () => context.push('/settings/tags'),
              ),
              _SettingsTile(
                icon: Icons.restaurant_menu,
                title: l10n.settingsManageCourses,
                subtitle: l10n.settingsManageCoursesSubtitle,
                onTap: () => context.push('/settings/courses'),
              ),
              _SettingsTile(
                icon: Icons.category_outlined,
                title: l10n.settingsManageCategories,
                subtitle: l10n.settingsManageCategoriesSubtitle,
                onTap: () => context.push('/settings/categories'),
              ),
              _SettingsTile(
                icon: Icons.view_list,
                title: l10n.settingsShoppingCategories,
                subtitle: l10n.settingsShoppingCategoriesSubtitle,
                onTap: () => context.push('/settings/shopping-categories'),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  EXPORT OPTIONS SHEET
// ════════════════════════════════════════════

class _ExportOptionsSheet extends StatefulWidget {
  final AppLocalizations l10n;
  final VoidCallback onExportCookbook;
  final ValueChanged<ExportOptions> onExportSelective;

  const _ExportOptionsSheet({
    required this.l10n,
    required this.onExportCookbook,
    required this.onExportSelective,
  });

  @override
  State<_ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends State<_ExportOptionsSheet> {
  bool _cookbooks = true;
  bool _shoppingLists = true;
  bool _mealPlans = true;
  bool _tags = true;
  bool _customCategories = true;
  bool _customCourses = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = widget.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.settingsExport,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Quick option: current cookbook only
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: Text(l10n.exportCurrentCookbook),
              trailing: const Icon(Icons.chevron_right),
              onTap: widget.onExportCookbook,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                l10n.exportFullBackup,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),

            // Checkboxes
            _ExportCheckbox(title: l10n.exportCookbooksRecipes, value: _cookbooks,
                onChanged: (v) => setState(() => _cookbooks = v ?? true)),
            _ExportCheckbox(title: l10n.exportShoppingLists, value: _shoppingLists,
                onChanged: (v) => setState(() => _shoppingLists = v ?? false)),
            _ExportCheckbox(title: l10n.exportMealPlans, value: _mealPlans,
                onChanged: (v) => setState(() => _mealPlans = v ?? false)),
            _ExportCheckbox(title: l10n.exportTags, value: _tags,
                onChanged: (v) => setState(() => _tags = v ?? false)),
            _ExportCheckbox(title: l10n.exportCategories, value: _customCategories,
                onChanged: (v) => setState(() => _customCategories = v ?? false)),
            _ExportCheckbox(title: l10n.exportCourses, value: _customCourses,
                onChanged: (v) => setState(() => _customCourses = v ?? false)),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => widget.onExportSelective(ExportOptions(
                  cookbooks: _cookbooks,
                  shoppingLists: _shoppingLists,
                  mealPlans: _mealPlans,
                  tags: _tags,
                  customCategories: _customCategories,
                  customCourses: _customCourses,
                )),
                icon: const Icon(Icons.download),
                label: Text(l10n.exportFullBackup),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ExportCheckbox extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _ExportCheckbox({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}