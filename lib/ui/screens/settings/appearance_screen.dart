import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../../data/app_enums.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../services/revenuecat_service.dart';
import '../../../utils/responsive_utils.dart';
import 'custom_theme_screen.dart';

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
      body: Responsive.constrainWidth(context, child: ListView(
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
      )),
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

class _ColorThemeGrid extends ConsumerWidget {
  final AppColorTheme currentTheme;
  final ValueChanged<AppColorTheme> onChanged;

  const _ColorThemeGrid({
    required this.currentTheme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(subscriptionProvider).tier;
    final isPremium = tier.index >= SubscriptionTier.premium.index;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: AppColorTheme.values.length,
      itemBuilder: (context, index) {
        final colorTheme = AppColorTheme.values[index];
        return _ColorThemeCard(
          colorTheme: colorTheme,
          isSelected: currentTheme == colorTheme,
          isPremium: isPremium,
          customColors: colorTheme.isCustom
              ? (
                  bg: ref.watch(settingsProvider).customBgColor,
                  primary: ref.watch(settingsProvider).customPrimaryColor,
                  accent: ref.watch(settingsProvider).customAccentColor,
                )
              : null,
          onTap: () {
            if (colorTheme.isCustom) {
              if (isPremium) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomThemeScreen()),
                );
              } else {
                // Show upgrade hint
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.appearanceCustomThemeRequiresPremium)),
                );
              }
            } else {
              onChanged(colorTheme);
            }
          },
        );
      },
    );
  }
}

class _ColorThemeCard extends StatelessWidget {
  final AppColorTheme colorTheme;
  final bool isSelected;
  final bool isPremium;
  final ({Color? bg, Color? primary, Color? accent})? customColors;
  final VoidCallback onTap;

  const _ColorThemeCard({
    required this.colorTheme,
    required this.isSelected,
    required this.onTap,
    this.isPremium = true,
    this.customColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = _getThemeName(context, colorTheme);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isSelected ? 11 : 14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Banner image (or gradient for custom theme)
              if (colorTheme.isCustom)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        customColors?.primary ?? const Color(0xFF6750A4),
                        customColors?.accent ?? const Color(0xFF7D5260),
                        customColors?.bg ?? const Color(0xFFF5F5F5),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.palette_rounded,
                      size: 36,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                )
              else
                Image.asset(
                  colorTheme.bannerAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    // Fallback to color gradient
                    final palette = theme.brightness == Brightness.dark
                        ? colorTheme.dark
                        : colorTheme.light;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [palette.primary, palette.secondary],
                        ),
                      ),
                    );
                  },
                ),

              // Premium lock badge for custom theme (when not premium)
              if (colorTheme.isCustom && !isPremium)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_rounded, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          AppLocalizations.of(context)!.appearancePremiumBadge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Selected check
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                ),

              // Bottom label bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
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
                      Text(colorTheme.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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

  String _getThemeName(BuildContext context, AppColorTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    switch (theme) {
      case AppColorTheme.spellbook:
        return l10n.themeSpellbook;
      case AppColorTheme.custom:
        return l10n.themeCustom;
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
        return l10n.themeFrost;
      case AppColorTheme.ember:
        return l10n.themeEmber;
      case AppColorTheme.spring:
        return l10n.themeSpring;
      case AppColorTheme.alchemist:
        return l10n.themeAlchemist;
      case AppColorTheme.matcha:
        return l10n.themeMatcha;
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