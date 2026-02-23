import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/app_enums.dart';
import '../../providers/settings_provider.dart';

/// Recipe placeholder image widget
/// Shows either default artwork, theme banner, or gradient based on settings
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

    switch (mode) {
      case PlaceholderImageMode.custom:
        placeholder = _DefaultImagePlaceholder(
          nerdMode: nerdMode,
          isRecipe: true,
          colorTheme: colorTheme,
        );
        break;
      case PlaceholderImageMode.theme:
        placeholder = _ThemeBannerPlaceholder(
          colorTheme: colorTheme,
          isRecipe: true,
        );
        break;
      case PlaceholderImageMode.gradient:
        placeholder = _GradientPlaceholder(
          colorTheme: colorTheme,
          isRecipe: true,
        );
        break;
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

    switch (mode) {
      case PlaceholderImageMode.custom:
        placeholder = _DefaultImagePlaceholder(
          nerdMode: nerdMode,
          isRecipe: false,
          colorTheme: colorTheme,
        );
        break;
      case PlaceholderImageMode.theme:
        placeholder = _ThemeBannerPlaceholder(
          colorTheme: colorTheme,
          isRecipe: false,
        );
        break;
      case PlaceholderImageMode.gradient:
        placeholder = _GradientPlaceholder(
          colorTheme: colorTheme,
          isRecipe: false,
        );
        break;
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
/// Uses the theme's unique banner art (changes per color theme)
class _ThemeBannerPlaceholder extends StatelessWidget {
  final AppColorTheme colorTheme;
  final bool isRecipe;

  const _ThemeBannerPlaceholder({
    required this.colorTheme,
    required this.isRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      colorTheme.bannerAsset,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to gradient if banner image missing
        return _GradientPlaceholder(
          colorTheme: colorTheme,
          isRecipe: isRecipe,
        );
      },
    );
  }
}

/// Gradient placeholder with theme colors + icon
class _GradientPlaceholder extends StatelessWidget {
  final AppColorTheme colorTheme;
  final bool isRecipe;

  const _GradientPlaceholder({
    required this.colorTheme,
    required this.isRecipe,
  });

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
          isRecipe ? Icons.restaurant : Icons.menu_book,
          size: 48,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

/// Default app artwork placeholder
class _DefaultImagePlaceholder extends StatelessWidget {
  final bool nerdMode;
  final bool isRecipe;
  final AppColorTheme colorTheme;

  const _DefaultImagePlaceholder({
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