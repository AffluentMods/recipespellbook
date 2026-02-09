import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../data/app_enums.dart';

/// Recipe placeholder image widget
/// Shows either theme-based banner or custom image based on settings
class RecipePlaceholderImage extends ConsumerWidget {
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const RecipePlaceholderImage({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final mode = settings.recipePlaceholderMode;
    final nerdMode = settings.nerdMode;
    final colorTheme = settings.appTheme;

    Widget placeholder;

    if (mode == PlaceholderImageMode.theme) {
      placeholder = _ThemeBannerPlaceholder(
        colorTheme: colorTheme,
        nerdMode: nerdMode,
        isRecipe: true,
      );
    } else {
      placeholder = _CustomImagePlaceholder(
        nerdMode: nerdMode,
        isRecipe: true,
        colorTheme: colorTheme,
      );
    }

    Widget result = Container(
      height: height,
      width: width,
      child: placeholder,
    );

    if (borderRadius != null) {
      result = ClipRRect(
        borderRadius: borderRadius!,
        child: result,
      );
    }

    return result;
  }
}

/// Cookbook placeholder image widget
class CookbookPlaceholderImage extends ConsumerWidget {
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CookbookPlaceholderImage({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final mode = settings.cookbookPlaceholderMode;
    final nerdMode = settings.nerdMode;
    final colorTheme = settings.appTheme;

    Widget placeholder;

    if (mode == PlaceholderImageMode.theme) {
      placeholder = _ThemeBannerPlaceholder(
        colorTheme: colorTheme,
        nerdMode: nerdMode,
        isRecipe: false,
      );
    } else {
      placeholder = _CustomImagePlaceholder(
        nerdMode: nerdMode,
        isRecipe: false,
        colorTheme: colorTheme,
      );
    }

    Widget result = Container(
      height: height,
      width: width,
      child: placeholder,
    );

    if (borderRadius != null) {
      result = ClipRRect(
        borderRadius: borderRadius!,
        child: result,
      );
    }

    return result;
  }
}

/// Theme-based banner image placeholder
/// Uses the theme's unique spellbook banner art
class _ThemeBannerPlaceholder extends StatelessWidget {
  final AppColorTheme colorTheme;
  final bool nerdMode;
  final bool isRecipe;

  const _ThemeBannerPlaceholder({
    required this.colorTheme,
    required this.nerdMode,
    required this.isRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Banner image
        Image.asset(
          colorTheme.bannerAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _GradientFallback(colorTheme: colorTheme);
          },
        ),

        // Subtle darkening overlay for icon readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.0),
                Colors.black.withValues(alpha: 0.25),
              ],
            ),
          ),
        ),

        // Centered icon
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRecipe
                  ? (nerdMode ? Icons.auto_awesome : Icons.restaurant)
                  : (nerdMode ? Icons.auto_stories : Icons.menu_book),
              size: 32,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}

/// Gradient fallback when banner image is not available
class _GradientFallback extends StatelessWidget {
  final AppColorTheme colorTheme;

  const _GradientFallback({required this.colorTheme});

  @override
  Widget build(BuildContext context) {
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
          size: 48,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

/// Custom image placeholder with RPG support
class _CustomImagePlaceholder extends StatelessWidget {
  final bool nerdMode;
  final bool isRecipe;
  final AppColorTheme colorTheme;

  const _CustomImagePlaceholder({
    required this.nerdMode,
    required this.isRecipe,
    required this.colorTheme,
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
        return _ThemeBannerPlaceholder(
          colorTheme: colorTheme,
          nerdMode: nerdMode,
          isRecipe: isRecipe,
        );
      },
    );
  }
}

/// Simplified recipe placeholder for use when WidgetRef is not available
class SimpleRecipePlaceholder extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? primaryColor;
  final Color? secondaryColor;

  const SimpleRecipePlaceholder({
    super.key,
    this.height,
    this.width,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = primaryColor ?? theme.colorScheme.primaryContainer;
    final secondary = secondaryColor ?? theme.colorScheme.primary;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, secondary],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 48,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}