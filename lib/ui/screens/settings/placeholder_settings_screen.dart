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

          // Theme-based option (primary option)
          _PlaceholderOptionCard(
            title: l10n.themeBased,
            description: l10n.themeBasedDescription,
            isSelected: settings.recipePlaceholderMode == PlaceholderImageMode.theme,
            onTap: () => ref.read(settingsProvider.notifier)
                .setRecipePlaceholderMode(PlaceholderImageMode.theme),
            preview: _ThemePreview(isRecipe: true),
          ),
          const SizedBox(height: 8),

          // Custom option (for future use)
          _PlaceholderOptionCard(
            title: l10n.defaultImages,
            description: l10n.defaultImagesDescription,
            isSelected: settings.recipePlaceholderMode == PlaceholderImageMode.custom,
            onTap: () => ref.read(settingsProvider.notifier)
                .setRecipePlaceholderMode(PlaceholderImageMode.custom),
            preview: _DefaultImagePreview(isRecipe: true, nerdMode: settings.nerdMode),
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

          // Theme-based option
          _PlaceholderOptionCard(
            title: l10n.themeBased,
            description: l10n.themeBasedDescription,
            isSelected: settings.cookbookPlaceholderMode == PlaceholderImageMode.theme,
            onTap: () => ref.read(settingsProvider.notifier)
                .setCookbookPlaceholderMode(PlaceholderImageMode.theme),
            preview: _ThemePreview(isRecipe: false),
          ),
          const SizedBox(height: 8),

          // Custom option
          _PlaceholderOptionCard(
            title: l10n.defaultImages,
            description: l10n.defaultImagesDescription,
            isSelected: settings.cookbookPlaceholderMode == PlaceholderImageMode.custom,
            onTap: () => ref.read(settingsProvider.notifier)
                .setCookbookPlaceholderMode(PlaceholderImageMode.custom),
            preview: _DefaultImagePreview(isRecipe: false, nerdMode: settings.nerdMode),
          ),

          const SizedBox(height: 32),

          // Info card
          Card(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
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
        // Show theme-based as fallback
        return _ThemePreview(isRecipe: isRecipe);
      },
    );
  }
}

class _ThemePreview extends StatelessWidget {
  final bool isRecipe;

  const _ThemePreview({required this.isRecipe});

  @override
  Widget build(BuildContext context) {
    if (isRecipe) {
      return const _ForceThemeRecipePlaceholder(height: 60);
    } else {
      return const _ForceThemeCookbookPlaceholder(height: 60);
    }
  }
}

class _ForceThemeRecipePlaceholder extends ConsumerWidget {
  final double height;

  const _ForceThemeRecipePlaceholder({required this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final colorTheme = settings.appTheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getColorsForTheme(colorTheme),
        ),
      ),
      child: Center(
        child: Icon(
          settings.nerdMode ? Icons.auto_awesome : Icons.restaurant,
          size: height * 0.4,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  List<Color> _getColorsForTheme(AppColorTheme theme) {
    switch (theme) {
      case AppColorTheme.spellbook:
        return [const Color(0xFF5E35B1), const Color(0xFF7E57C2)];
      case AppColorTheme.forest:
        return [const Color(0xFF2E7D32), const Color(0xFF4CAF50)];
      case AppColorTheme.ocean:
        return [const Color(0xFF0277BD), const Color(0xFF03A9F4)];
      case AppColorTheme.sunset:
        return [const Color(0xFFE64A19), const Color(0xFFFF7043)];
      case AppColorTheme.midnight:
        return [const Color(0xFF283593), const Color(0xFF5C6BC0)];
      case AppColorTheme.rose:
        return [const Color(0xFFC2185B), const Color(0xFFEC407A)];
    }
  }
}

class _ForceThemeCookbookPlaceholder extends ConsumerWidget {
  final double height;

  const _ForceThemeCookbookPlaceholder({required this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final colorTheme = settings.appTheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getColorsForTheme(colorTheme),
        ),
      ),
      child: Center(
        child: Icon(
          settings.nerdMode ? Icons.auto_stories : Icons.menu_book,
          size: height * 0.4,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  List<Color> _getColorsForTheme(AppColorTheme theme) {
    switch (theme) {
      case AppColorTheme.spellbook:
        return [const Color(0xFF7B1FA2), const Color(0xFF9C27B0)];
      case AppColorTheme.forest:
        return [const Color(0xFF1B5E20), const Color(0xFF388E3C)];
      case AppColorTheme.ocean:
        return [const Color(0xFF01579B), const Color(0xFF0288D1)];
      case AppColorTheme.sunset:
        return [const Color(0xFFBF360C), const Color(0xFFE64A19)];
      case AppColorTheme.midnight:
        return [const Color(0xFF1A237E), const Color(0xFF303F9F)];
      case AppColorTheme.rose:
        return [const Color(0xFF880E4F), const Color(0xFFAD1457)];
    }
  }
}