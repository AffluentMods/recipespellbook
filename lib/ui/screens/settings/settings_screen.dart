import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../services/export_import_service.dart';
import '../../../data/app_enums.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';

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
              ListTile(
                leading: const Icon(Icons.warning_amber),
                title: Text(l10n.settingsAllergies),
                subtitle: Text(l10n.settingsAllergiesSubtitle),
                trailing: const Icon(Icons.chevron_right),
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
            ],
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
            ],
          ),

          // ============ SYNC (Future) ============
          _SettingsSection(
            title: l10n.syncSection,
            children: [
              _SettingsTile(
                icon: Icons.cloud_outlined,
                title: l10n.cloudSync,
                subtitle: l10n.comingSoon,
                enabled: false,
                onTap: () {},
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
                const Divider(height: 1),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, size: 48, color: Theme.of(context).colorScheme.error),
        title: Text(l10n.resetApp),
        content: Text(l10n.resetAppWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              _showFinalResetConfirmation(context, ref);
            },
            child: Text(l10n.actionContinue),
          ),
        ],
      ),
    );
  }

  void _showFinalResetConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.delete_forever, size: 48, color: Theme.of(context).colorScheme.error),
        title: Text(l10n.finalConfirmation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                onPressed: isValid ? () => _performReset(context, ref, l10n) : null,
                child: Text(l10n.actionDelete),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _performReset(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    try {
      final db = ref.read(databaseProvider);

      await db.customStatement('DELETE FROM recipes');
      await db.customStatement('DELETE FROM ingredients');
      await db.customStatement('DELETE FROM steps');
      await db.customStatement('DELETE FROM cookbooks WHERE id != "starter"');
      await db.customStatement('DELETE FROM shopping_lists WHERE id != "list_default"');
      await db.customStatement('DELETE FROM shopping_list_items');
      await db.customStatement('DELETE FROM meal_plans');
      ref.read(settingsProvider.notifier).resetToDefaults();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.appResetSuccess), backgroundColor: Colors.green),
        );
        context.go('/');
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
}

// ============ NUTRITION SETTINGS SECTION (NEW!) ============

class _NutritionSettingsSection extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;

  const _NutritionSettingsSection({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SettingsSection(
      title: 'Nutrition Display',
      children: [
        // Chart Style
        ListTile(
          leading: Icon(_getIconForStyle(settings.nutritionChartStyle)),
          title: const Text('Chart style'),
          subtitle: Text(_getNameForStyle(settings.nutritionChartStyle)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showStylePicker(context),
        ),

        const Divider(height: 1),

        // Show Expanded by Default
        SwitchListTile(
          value: settings.showExpandedNutrition,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setShowExpandedNutrition(value);
          },
          title: const Text('Show expanded nutrition'),
          subtitle: const Text('Show all nutrition details by default'),
          secondary: const Icon(Icons.unfold_more),
        ),
      ],
    );
  }

  IconData _getIconForStyle(NutritionChartStyle style) {
    switch (style) {
      case NutritionChartStyle.donut:
        return Icons.donut_large;
      case NutritionChartStyle.bars:
        return Icons.bar_chart;
      case NutritionChartStyle.numbers:
        return Icons.numbers;
    }
  }

  String _getNameForStyle(NutritionChartStyle style) {
    switch (style) {
      case NutritionChartStyle.donut:
        return 'Donut chart';
      case NutritionChartStyle.bars:
        return 'Bar chart';
      case NutritionChartStyle.numbers:
        return 'Numbers only';
    }
  }

  void _showStylePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Chart Style',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...NutritionChartStyle.values.map((style) => RadioListTile<NutritionChartStyle>(
              value: style,
              groupValue: settings.nutritionChartStyle,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setNutritionChartStyle(value!);
                Navigator.pop(ctx);
              },
              title: Text(_getNameForStyle(style)),
              secondary: Icon(_getIconForStyle(style)),
            )),
            const SizedBox(height: 16),
          ],
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
        ...children,
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

  String _getLocalizedThemeName(BuildContext context, AppColorTheme theme) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: Text(l10n.settingsTheme),
      subtitle: Text('${currentTheme.emoji} ${_getLocalizedThemeName(context, currentTheme)}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemePicker(context),
    );
  }

  void _showThemePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.settingsTheme, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...AppColorTheme.values.map((appTheme) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: appTheme.seedColor, borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text(appTheme.emoji, style: const TextStyle(fontSize: 18))),
              ),
              title: Text(_getLocalizedThemeName(context, appTheme)),
              trailing: currentTheme == appTheme ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
              onTap: () { onThemeSelected(appTheme); Navigator.pop(context); },
            )),
            const SizedBox(height: 16),
          ],
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