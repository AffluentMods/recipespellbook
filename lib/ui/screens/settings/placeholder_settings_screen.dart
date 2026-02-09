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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.imagePlaceholders),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Description
          Text(
            l10n.placeholderDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),

          // ============ RECIPE PLACEHOLDERS ============
          Text(
            l10n.recipePlaceholders,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Default Images (artwork, changes with RPG mode)
          _PlaceholderOptionCard(
            title: l10n.defaultImages,
            description: l10n.defaultImagesDescription,
            isSelected: settings.recipePlaceholderMode == PlaceholderImageMode.custom,
            onTap: () => ref.read(settingsProvider.notifier)
                .setRecipePlaceholderMode(PlaceholderImageMode.custom),
            preview: _DefaultImagePreview(isRecipe: true, nerdMode: settings.nerdMode),
          ),
          const SizedBox(height: 8),

          // Theme-Based (banner artwork)
          _PlaceholderOptionCard(
            title: l10n.themeBased,
            description: l10n.themeBasedDescription,
            isSelected: settings.recipePlaceholderMode == PlaceholderImageMode.theme,
            onTap: () => ref.read(settingsProvider.notifier)
                .setRecipePlaceholderMode(PlaceholderImageMode.theme),
            preview: _ThemeBannerPreview(isRecipe: true),
          ),
          const SizedBox(height: 8),

          // Gradient-Based (color gradient)
          _PlaceholderOptionCard(
            title: l10n.gradientBased,
            description: l10n.gradientBasedDescription,
            isSelected: settings.recipePlaceholderMode == PlaceholderImageMode.gradient,
            onTap: () => ref.read(settingsProvider.notifier)
                .setRecipePlaceholderMode(PlaceholderImageMode.gradient),
            preview: _GradientPreview(isRecipe: true),
          ),

          const SizedBox(height: 32),

          // ============ COOKBOOK PLACEHOLDERS ============
          Text(
            l10n.cookbookPlaceholders,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Default Images
          _PlaceholderOptionCard(
            title: l10n.defaultImages,
            description: l10n.defaultImagesDescription,
            isSelected: settings.cookbookPlaceholderMode == PlaceholderImageMode.custom,
            onTap: () => ref.read(settingsProvider.notifier)
                .setCookbookPlaceholderMode(PlaceholderImageMode.custom),
            preview: _DefaultImagePreview(isRecipe: false, nerdMode: settings.nerdMode),
          ),
          const SizedBox(height: 8),

          // Theme-Based
          _PlaceholderOptionCard(
            title: l10n.themeBased,
            description: l10n.themeBasedDescription,
            isSelected: settings.cookbookPlaceholderMode == PlaceholderImageMode.theme,
            onTap: () => ref.read(settingsProvider.notifier)
                .setCookbookPlaceholderMode(PlaceholderImageMode.theme),
            preview: _ThemeBannerPreview(isRecipe: false),
          ),
          const SizedBox(height: 8),

          // Gradient-Based
          _PlaceholderOptionCard(
            title: l10n.gradientBased,
            description: l10n.gradientBasedDescription,
            isSelected: settings.cookbookPlaceholderMode == PlaceholderImageMode.gradient,
            onTap: () => ref.read(settingsProvider.notifier)
                .setCookbookPlaceholderMode(PlaceholderImageMode.gradient),
            preview: _GradientPreview(isRecipe: false),
          ),

          const SizedBox(height: 32),

          // Info card
          Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.placeholderRpgInfo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

  const _PlaceholderOptionCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Preview image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }
}

class _DefaultImagePreview extends StatelessWidget {
  final bool isRecipe;
  final bool nerdMode;

  const _DefaultImagePreview({
    required this.isRecipe,
    required this.nerdMode,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = isRecipe
        ? (nerdMode
        ? 'assets/images/recipe_placeholder_rpg.png'
        : 'assets/images/recipe_placeholder_normal.png')
        : (nerdMode
        ? 'assets/images/cookbook_placeholder_rpg.png'
        : 'assets/images/cookbook_placeholder_normal.png');

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _GradientPreview(isRecipe: isRecipe);
      },
    );
  }
}

/// Preview showing the theme banner artwork
class _ThemeBannerPreview extends ConsumerWidget {
  final bool isRecipe;

  const _ThemeBannerPreview({required this.isRecipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final colorTheme = settings.appTheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          colorTheme.bannerAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _GradientPreview(isRecipe: isRecipe);
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.0),
                Colors.black.withValues(alpha: 0.2),
              ],
            ),
          ),
        ),
        Center(
          child: Icon(
            isRecipe
                ? (settings.nerdMode ? Icons.auto_awesome : Icons.restaurant)
                : (settings.nerdMode ? Icons.auto_stories : Icons.menu_book),
            size: 24,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

/// Preview showing just the gradient colors
class _GradientPreview extends ConsumerWidget {
  final bool isRecipe;

  const _GradientPreview({required this.isRecipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final colorTheme = settings.appTheme;
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
          isRecipe
              ? (settings.nerdMode ? Icons.auto_awesome : Icons.restaurant)
              : (settings.nerdMode ? Icons.auto_stories : Icons.menu_book),
          size: 24,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}