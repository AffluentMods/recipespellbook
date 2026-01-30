import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/settings_provider.dart';
import '../../../data/app_enums.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsAppearance),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ============ THEME MODE SECTION ============
          Text(
            l10n.settingsThemeMode,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          _ThemeModeSelector(
            currentMode: settings.themeMode,
            onChanged: (mode) => settingsNotifier.setThemeMode(mode),
          ),
          const SizedBox(height: 32),

          // ============ COLOR THEME SECTION ============
          Text(
            l10n.colorTheme,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.colorThemeSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          _ColorThemeGrid(
            currentTheme: settings.appTheme,
            onChanged: (colorTheme) => settingsNotifier.setAppTheme(colorTheme),
          ),
          const SizedBox(height: 32),

          // ============ PREVIEW SECTION ============
          Text(
            l10n.preview,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _ThemePreview(),
        ],
      ),
    );
  }
}

// ============ THEME MODE SELECTOR ============

class _ThemeModeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _ModeOption(
              icon: Icons.brightness_auto,
              label: l10n.settingsThemeModeSystem,
              isSelected: currentMode == ThemeMode.system,
              onTap: () => onChanged(ThemeMode.system),
            ),
            _ModeOption(
              icon: Icons.light_mode,
              label: l10n.settingsThemeModeLight,
              isSelected: currentMode == ThemeMode.light,
              onTap: () => onChanged(ThemeMode.light),
            ),
            _ModeOption(
              icon: Icons.dark_mode,
              label: l10n.settingsThemeModeDark,
              isSelected: currentMode == ThemeMode.dark,
              onTap: () => onChanged(ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ COLOR THEME GRID ============

class _ColorThemeGrid extends StatelessWidget {
  final AppColorTheme currentTheme;
  final ValueChanged<AppColorTheme> onChanged;

  const _ColorThemeGrid({
    required this.currentTheme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: AppColorTheme.values.length,
      itemBuilder: (context, index) {
        final colorTheme = AppColorTheme.values[index];
        return _ColorThemeCard(
          colorTheme: colorTheme,
          isSelected: currentTheme == colorTheme,
          onTap: () => onChanged(colorTheme),
        );
      },
    );
  }
}

class _ColorThemeCard extends StatelessWidget {
  final AppColorTheme colorTheme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorThemeCard({
    required this.colorTheme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getThemeColors(colorTheme);
    final displayName = _getLocalizedThemeName(context, colorTheme);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Column(
            children: [
              // Top color band (primary)
              Expanded(
                flex: 2,
                child: Container(
                  color: colors[0],
                  child: Center(
                    child: isSelected
                        ? const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 28,
                    )
                        : null,
                  ),
                ),
              ),
              // Bottom accent colors
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(child: Container(color: colors[1])),
                    Expanded(child: Container(color: colors[2])),
                  ],
                ),
              ),
              // Theme name
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : null,
                    color: isSelected ? theme.colorScheme.primary : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get localized theme name
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

  List<Color> _getThemeColors(AppColorTheme colorTheme) {
    switch (colorTheme) {
      case AppColorTheme.spellbook:
        return [const Color(0xFF6750A4), const Color(0xFF9A82DB), const Color(0xFFE8DEF8)];
      case AppColorTheme.forest:
        return [const Color(0xFF2E7D32), const Color(0xFF66BB6A), const Color(0xFFC8E6C9)];
      case AppColorTheme.ocean:
        return [const Color(0xFF0288D1), const Color(0xFF4FC3F7), const Color(0xFFB3E5FC)];
      case AppColorTheme.sunset:
        return [const Color(0xFFE64A19), const Color(0xFFFF8A65), const Color(0xFFFFCCBC)];
      case AppColorTheme.midnight:
        return [const Color(0xFF1A237E), const Color(0xFF5C6BC0), const Color(0xFFC5CAE9)];
      case AppColorTheme.rose:
        return [const Color(0xFFAD1457), const Color(0xFFEC407A), const Color(0xFFF8BBD9)];
    }
  }
}

// ============ THEME PREVIEW ============

class _ThemePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.menu_book, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.appTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Buttons preview
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    child: Text(l10n.previewPrimary),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text(l10n.previewSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Chips preview
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.local_fire_department, size: 18),
                  label: Text(l10n.tagVegan),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
                Chip(
                  avatar: const Icon(Icons.timer, size: 18),
                  label: Text(l10n.tagQuick),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                ),
                Chip(
                  avatar: const Icon(Icons.favorite, size: 18),
                  label: Text(l10n.favoritesTitle),
                  backgroundColor: theme.colorScheme.tertiaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Color swatches
            Row(
              children: [
                _ColorSwatch(l10n.previewPrimary, theme.colorScheme.primary),
                _ColorSwatch(l10n.previewSecondary, theme.colorScheme.secondary),
                _ColorSwatch(l10n.previewTertiary, theme.colorScheme.tertiary),
                _ColorSwatch(l10n.previewError, theme.colorScheme.error),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorSwatch(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}