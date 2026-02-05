import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../data/app_enums.dart';

/// Recipe placeholder image widget
/// Shows either theme-based gradient or custom image based on settings
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

    // FIXED: Correct logic - theme mode shows gradient, custom mode shows images
    if (mode == PlaceholderImageMode.theme) {
      // Theme-based gradient placeholder
      placeholder = _ThemeGradientPlaceholder(
        colorTheme: colorTheme,
        nerdMode: nerdMode,
        isRecipe: true,
      );
    } else {
      // Custom/default image placeholder
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
/// Shows either theme-based gradient or custom image based on settings
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

    // FIXED: Correct logic - theme mode shows gradient, custom mode shows images
    if (mode == PlaceholderImageMode.theme) {
      // Theme-based gradient placeholder
      placeholder = _ThemeGradientPlaceholder(
        colorTheme: colorTheme,
        nerdMode: nerdMode,
        isRecipe: false,
      );
    } else {
      // Custom/default image placeholder
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

/// Theme-based gradient placeholder
class _ThemeGradientPlaceholder extends StatelessWidget {
  final AppColorTheme colorTheme;
  final bool nerdMode;
  final bool isRecipe;

  const _ThemeGradientPlaceholder({
    required this.colorTheme,
    required this.nerdMode,
    required this.isRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final colors = isRecipe
        ? _getRecipeColorsForTheme(colorTheme)
        : _getCookbookColorsForTheme(colorTheme);

    final icon = isRecipe
        ? (nerdMode ? Icons.auto_awesome : Icons.restaurant)
        : (nerdMode ? Icons.auto_stories : Icons.menu_book);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 48,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  List<Color> _getRecipeColorsForTheme(AppColorTheme theme) {
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

  List<Color> _getCookbookColorsForTheme(AppColorTheme theme) {
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
    // FIXED: Use correct asset paths with RPG support for both recipe AND cookbook
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
        // Fallback to theme-based gradient if image not found
        return _ThemeGradientPlaceholder(
          colorTheme: colorTheme,
          nerdMode: nerdMode,
          isRecipe: isRecipe,
        );
      },
    );
  }
}

/// Simplified recipe placeholder for use when WidgetRef is not available
/// Defaults to showing a simple gradient
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