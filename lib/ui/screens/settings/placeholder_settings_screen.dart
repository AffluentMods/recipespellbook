import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/settings_provider.dart';
import '../../../data/app_enums.dart';
import '../../widgets/placeholder_image.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';

class PlaceholderSettingsScreen extends ConsumerWidget {
  const PlaceholderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use recipe mode as the unified mode (both are always in sync)
    final currentMode = settings.recipePlaceholderMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Placeholders'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Description
          Text(
            'Choose what to display for recipes and cookbooks that don\'t have images.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),

          // ============ DEFAULT IMAGES ============
          _PlaceholderOptionCard(
            title: 'Default images',
            description: 'Displays default app artwork',
            isSelected: currentMode == PlaceholderImageMode.custom,
            onTap: () => ref.read(settingsProvider.notifier)
                .setPlaceholderMode(PlaceholderImageMode.custom),
            preview: _DefaultImagePreview(nerdMode: settings.nerdMode),
            isDark: isDark,
            theme: theme,
          ),
          const SizedBox(height: 8),

          // ============ THEME-BASED ============
          _PlaceholderOptionCard(
            title: 'Theme-based',
            description: 'Art that changes with your color theme',
            isSelected: currentMode == PlaceholderImageMode.theme,
            onTap: () => ref.read(settingsProvider.notifier)
                .setPlaceholderMode(PlaceholderImageMode.theme),
            preview: _ThemeBannerPreview(colorTheme: settings.appTheme),
            isDark: isDark,
            theme: theme,
          ),
          const SizedBox(height: 8),

          // ============ GRADIENT-BASED ============
          _PlaceholderOptionCard(
            title: 'Gradient-based',
            description: 'Color gradient based on your theme',
            isSelected: currentMode == PlaceholderImageMode.gradient,
            onTap: () => ref.read(settingsProvider.notifier)
                .setPlaceholderMode(PlaceholderImageMode.gradient),
            preview: _GradientPreview(colorTheme: settings.appTheme),
            isDark: isDark,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _PlaceholderOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget preview;
  final bool isDark;
  final ThemeData theme;

  const _PlaceholderOptionCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.preview,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHigh
              : theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // Preview image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 80,
                height: 60,
                child: preview,
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            // Checkmark
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

/// Preview: default app artwork
class _DefaultImagePreview extends StatelessWidget {
  final bool nerdMode;

  const _DefaultImagePreview({required this.nerdMode});

  @override
  Widget build(BuildContext context) {
    final imagePath = nerdMode
        ? 'assets/images/recipe_placeholder_rpg.png'
        : 'assets/images/recipe_placeholder_normal.png';

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.image, size: 24)),
      ),
    );
  }
}

/// Preview: theme banner art (actual banner image, no gradient overlay)
class _ThemeBannerPreview extends StatelessWidget {
  final AppColorTheme colorTheme;

  const _ThemeBannerPreview({required this.colorTheme});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      colorTheme.bannerAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.palette, size: 24)),
      ),
    );
  }
}

/// Preview: gradient with theme colors + icon
class _GradientPreview extends ConsumerWidget {
  final AppColorTheme colorTheme;

  const _GradientPreview({required this.colorTheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = Theme.of(context).brightness == Brightness.dark
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
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 24,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}