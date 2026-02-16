import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/ui/screens/settings/pantry_screen.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../services/export_import_service.dart';
import '../../../services/onboarding_service.dart';
import '../../../services/grocery_service.dart';
import '../../../data/app_enums.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'nutrition_settings_screen.dart';
import '../../../ui/widgets/account_section.dart';

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
          // ============ ACCOUNT & SYNC ============
          const AccountSection(),

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
              _SettingsTile(
                icon: Icons.image_outlined,
                title: l10n.imagePlaceholders,
                subtitle: l10n.imagePlaceholdersSubtitle,
                onTap: () => context.push('/settings/placeholders'),
              ),
            ],
          ),

          // ============ HOME SCREEN ============
          _SettingsSection(
            title: l10n.homeScreenSection,
            children: [
              _SettingsTile(
                icon: Icons.bolt,
                title: l10n.settingsQuickAccess,
                subtitle: l10n.settingsQuickAccessSubtitle,
                onTap: () => context.push('/settings/quick-access'),
              ),
            ],
          ),

          // ============ RECIPES ============
          _SettingsSection(
            title: l10n.settingsRecipes,
            children: [
              _SettingsTile(
                icon: Icons.view_agenda,
                title: l10n.settingsRecipeLayout,
                subtitle: settings.recipeLayoutMode == RecipeLayoutMode.tabbed
                    ? l10n.layoutTabbed
                    : l10n.layoutStacked,
                onTap: () => context.push('/settings/recipe-layout'),
              ),
              _MeasurementSystemTile(
                currentSystem: settings.measurementSystem,
                onSystemSelected: (system) {
                  ref.read(settingsProvider.notifier).setMeasurementSystem(system);
                },
              ),
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
                icon: settings.nerdMode ? Icons.flash_on : Icons.warning_amber,
                title: settings.nerdMode ? 'Weaknesses' : l10n.settingsAllergies,
                subtitle: settings.nerdMode ? 'Set your dietary vulnerabilities' : l10n.settingsAllergiesSubtitle,
                onTap: () => context.push('/settings/allergies'),
              ),
            ],
          ),

          // ============ NUTRITION DISPLAY (NEW!) ============
          _NutritionSettingsSection(settings: settings, ref: ref),

          // ============ SHOPPING ============
          _SettingsSection(
            title: l10n.shoppingTitle,
            children: [
              _SettingsTile(
                icon: Icons.view_list,
                title: l10n.settingsShoppingCategories,
                subtitle: l10n.settingsShoppingCategoriesSubtitle,
                onTap: () => context.push('/settings/shopping-categories'),
              ),
              ListTile(
                leading: const Icon(Icons.kitchen),
                title: const Text('My Pantry'),
                subtitle: const Text('Items you always have on hand'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PantryScreen())),
              ),
            ],
          ),

          // ============ STORE INTEGRATIONS ============
          const _StoreIntegrationsSection(),

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
            ],
          ),

          // ============ RPG MODE ============
          _SettingsSection(
            title: settings.nerdMode ? '🎮 RPG Mode' : '✨ Secret',
            children: [
              _RpgModeTile(
                isEnabled: settings.nerdMode,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setNerdMode(value);
                },
              ),
              // Show additional RPG options when enabled
              if (settings.nerdMode) ...[
                SwitchListTile(
                  secondary: const Icon(Icons.animation),
                  title: Text(l10n.settingsRpgAnimations),
                  subtitle: Text(l10n.settingsRpgAnimationsSubtitle),
                  value: settings.rpgAnimationsEnabled,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setRpgAnimations(value);
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_outlined),
                  title: Text(l10n.settingsRpgSounds),
                  subtitle: Text(l10n.settingsRpgSoundsSubtitle),
                  value: settings.rpgSoundsEnabled,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setRpgSounds(value);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_events_outlined),
                  title: Text(l10n.settingsRpgAchievements),
                  subtitle: Text(l10n.settingsRpgAchievementsSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/rpg/achievements'),
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: Text(l10n.settingsRpgStats),
                  subtitle: Text(l10n.settingsRpgStatsSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/rpg/stats'),
                ),
              ],
            ],
          ),

          // ============ ABOUT ============
          _SettingsSection(
            title: l10n.settingsAbout,
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: l10n.appTitle,
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: l10n.trashTitle,
                subtitle: l10n.trashSubtitle,
                onTap: () => context.push('/settings/trash'),
              ),
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                title: l10n.resetApp,
                subtitle: l10n.resetAppSubtitle,
                titleColor: theme.colorScheme.error,
                onTap: () => _showResetConfirmation(context, ref),
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
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.settingsExport,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: Text(l10n.exportCurrentCookbook),
              onTap: () async {
                Navigator.pop(context);
                _showLoadingSnackbar(context, l10n.exporting);
                final cookbookId = ref.read(selectedCookbookIdProvider) ?? 'starter';
                final data = await service.exportCookbook(cookbookId);
                await service.shareExport(data, 'cookbook_export.json');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: Text(l10n.exportAllCookbooks),
              onTap: () async {
                Navigator.pop(context);
                _showLoadingSnackbar(context, l10n.exporting);
                final data = await service.exportAll();
                await service.shareExport(data, 'recipe_spellbook_backup.json');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
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
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      backgroundColor: result.success ? Colors.green : Colors.red,
                    ),
                  );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 30),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('📖✨', style: TextStyle(fontSize: 32)),
        ),
      ),
      children: [
        Text(l10n.aboutDescription),
        const SizedBox(height: 16),
        Text(l10n.madeWithLove, style: const TextStyle(fontSize: 12)),
      ],
    );
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
            Text('What would you like to delete?',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Local Data option
            _ResetOptionTile(
              icon: Icons.phone_android,
              title: 'Local Data',
              subtitle: 'Recipes, cookbooks, meal plans, shopping lists on this device',
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
              title: 'Cloud Data',
              subtitle: 'Coming soon — Cloud Sync not yet available',
              color: theme.colorScheme.outline,
              enabled: false,
              onTap: () {},
            ),
            const SizedBox(height: 8),
            // All Data option
            _ResetOptionTile(
              icon: Icons.delete_forever,
              title: 'All Data',
              subtitle: 'Local data and settings — complete fresh start',
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
            Text('This will permanently delete $scopeLabel. This cannot be undone.'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.resetFailed}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showReimportDefaultsDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.auto_awesome, size: 48, color: Colors.amber),
        title: const Text('Data Reset Complete'),
        content: const Text(
          'All data has been cleared successfully.\n\n'
              'Would you like to import the 10 default starter recipes?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.appResetSuccess), backgroundColor: Colors.green),
              );
              context.go('/');
            },
            child: const Text('No thanks'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingSnackbar(context, 'Importing default recipes...');
              try {
                final db = ref.read(databaseProvider);
                final count = await OnboardingService.seedDefaultRecipes(db);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$count default recipes imported!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.go('/');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Import failed: $e'), backgroundColor: Colors.red),
                  );
                  context.go('/');
                }
              }
            },
            child: const Text('Yes, add them'),
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

// ============ NUTRITION SETTINGS SECTION (NEW!) ============

class _NutritionSettingsSection extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;

  const _NutritionSettingsSection({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'Nutrition Display',
      children: [
        ListTile(
          leading: const Icon(Icons.tune),
          title: const Text('Nutrition Display'),
          subtitle: const Text('Chart style, visible nutrients'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NutritionSettingsScreen()),
          ),
        ),
      ],
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
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        for (final child in children) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: itemBg,
              borderRadius: BorderRadius.circular(14),
              border: isDark
                  ? null
                  : Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
          const SizedBox(height: 4),
        ],
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
    return ListTile(
      leading: Icon(icon, color: enabled ? (titleColor ?? theme.colorScheme.onSurfaceVariant) : theme.colorScheme.outline),
      title: Text(title, style: TextStyle(color: enabled ? titleColor : theme.colorScheme.outline)),
      subtitle: Text(subtitle, style: TextStyle(color: enabled ? null : theme.colorScheme.outline)),
      trailing: enabled ? const Icon(Icons.chevron_right) : null,
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
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: Text(l10n.settingsTheme),
      subtitle: Text('${currentTheme.emoji} ${_getThemeName(context, currentTheme)}'),
      trailing: const Icon(Icons.chevron_right),
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
      leading: Icon(icon),
      title: Text(l10n.settingsThemeMode),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
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
    return ListTile(
      leading: const Icon(Icons.straighten),
      title: Text(l10n.settingsMeasurements),
      subtitle: Text(currentSystem.displayName),
      trailing: const Icon(Icons.chevron_right),
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
              subtitle: const Text('cups, tablespoons, ounces, °F'),
              trailing: currentSystem == MeasurementSystem.us ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
              onTap: () { onSystemSelected(MeasurementSystem.us); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Text('🌍', style: TextStyle(fontSize: 24)),
              title: Text(l10n.settingsMeasurementsMetric),
              subtitle: const Text('milliliters, grams, °C'),
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
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.settingsLanguage),
      subtitle: Text(_currentLanguageName),
      trailing: const Icon(Icons.chevron_right),
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

// ════════════════════════════════════════════
//  STORE INTEGRATIONS SECTION
// ════════════════════════════════════════════

class _StoreIntegrationsSection extends StatefulWidget {
  const _StoreIntegrationsSection();

  @override
  State<_StoreIntegrationsSection> createState() =>
      _StoreIntegrationsSectionState();
}

class _StoreIntegrationsSectionState extends State<_StoreIntegrationsSection> {
  bool _instacartConfigured = false;
  bool _krogerConfigured = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
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

    return _SettingsSection(
      title: 'Store Integrations',
      children: [
        // Instacart
        ListTile(
          leading: const Text('\u{1F955}', style: TextStyle(fontSize: 22)),
          title: const Text('Instacart'),
          subtitle: Text(
            _loading
                ? 'Checking...'
                : _instacartConfigured
                ? 'Connected \u2022 Tap to manage'
                : 'Not connected',
            style: TextStyle(
              color: _instacartConfigured
                  ? const Color(0xFF43B02A)
                  : theme.colorScheme.outline,
            ),
          ),
          trailing: _instacartConfigured
              ? const Icon(Icons.check_circle, color: Color(0xFF43B02A), size: 20)
              : const Icon(Icons.chevron_right),
          onTap: () => _showInstacartOptions(context),
        ),
        // Kroger
        ListTile(
          leading: const Text('\u{1F3EA}', style: TextStyle(fontSize: 22)),
          title: const Text('Kroger'),
          subtitle: Text(
            _loading
                ? 'Checking...'
                : _krogerConfigured
                ? 'Connected \u2022 Tap to manage'
                : 'Tap to sign in',
            style: TextStyle(
              color: _krogerConfigured
                  ? const Color(0xFF43B02A)
                  : theme.colorScheme.outline,
            ),
          ),
          trailing: _krogerConfigured
              ? const Icon(Icons.check_circle, color: Color(0xFF43B02A), size: 20)
              : const Icon(Icons.chevron_right),
          onTap: () => _showKrogerOptions(context),
        ),
      ],
    );
  }

  void _showInstacartOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('\u{1F955}', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text('Instacart',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  if (_instacartConfigured) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43B02A).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Connected',
                          style: TextStyle(
                              color: Color(0xFF43B02A),
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.vpn_key_outlined),
              title: const Text('Set custom API key'),
              subtitle: const Text('Use your own Instacart Connect key'),
              onTap: () {
                Navigator.pop(ctx);
                _showApiKeyDialog(context,
                    provider: GroceryProvider.instacart,
                    title: 'Instacart API Key',
                    hint: 'Bearer key from Developer Dashboard');
              },
            ),
            ListTile(
              leading: Icon(Icons.link_off, color: theme.colorScheme.error),
              title: Text('Reset to default key',
                  style: TextStyle(color: theme.colorScheme.error)),
              subtitle: const Text('Remove custom key, use built-in'),
              onTap: () async {
                Navigator.pop(ctx);
                await GroceryService.disconnect(GroceryProvider.instacart);
                _checkStatus();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showKrogerOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('\u{1F3EA}', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text('Kroger',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  if (_krogerConfigured) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43B02A).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Connected',
                          style: TextStyle(
                              color: Color(0xFF43B02A),
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),
            if (!_krogerConfigured)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Sign in to Kroger'),
                subtitle: const Text('Connect to add items to your cart'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await GroceryService.krogerStartOAuthLogin();
                },
              ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Set preferred store'),
              subtitle: const Text('Search by zip code'),
              onTap: () {
                Navigator.pop(ctx);
                _showKrogerLocationDialog(context);
              },
            ),
            if (_krogerConfigured)
              ListTile(
                leading: Icon(Icons.link_off, color: theme.colorScheme.error),
                title: Text('Disconnect',
                    style: TextStyle(color: theme.colorScheme.error)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await GroceryService.disconnect(GroceryProvider.kroger);
                  _checkStatus();
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final key = controller.text.trim();
              if (key.isEmpty) return;
              Navigator.pop(ctx);
              await GroceryService.configureInstacart(apiKey: key);
              _checkStatus();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API key saved'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2)),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showKrogerLocationDialog(BuildContext context) {
    final controller = TextEditingController();
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        List<Map<String, dynamic>> results = [];
        bool searching = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: const Text('Find your Kroger store'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter zip code',
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Store set: ${loc['name'] ?? 'Kroger'}'),
                                    behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
          ),
        );
      },
    );
  }
}