import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/rpg_provider.dart';

/// Helper class for RPG-style ratings
class RpgRatingHelper {
  /// Get the localized rating name based on star count and RPG mode
  static String getRatingName(BuildContext context, int? rating, bool nerdMode) {
    final l10n = AppLocalizations.of(context)!;

    if (rating == null || rating == 0) {
      return nerdMode ? l10n.ratingUnrated : '';
    }

    if (!nerdMode) {
      return '$rating ★';
    }

    // RPG mode rating names
    switch (rating) {
      case 1:
        return l10n.ratingCommon;
      case 2:
        return l10n.ratingUncommon;
      case 3:
        return l10n.ratingRare;
      case 4:
        return l10n.ratingEpic;
      case 5:
        return l10n.ratingLegendary;
      default:
        return l10n.ratingUnrated;
    }
  }

  /// Get the color for RPG rating
  static Color getRatingColor(int? rating, bool nerdMode) {
    if (!nerdMode || rating == null || rating == 0) {
      return Colors.amber;
    }

    switch (rating) {
      case 1:
        return Colors.grey; // Common
      case 2:
        return Colors.green; // Uncommon
      case 3:
        return Colors.blue; // Rare
      case 4:
        return Colors.purple; // Epic
      case 5:
        return Colors.orange; // Legendary
      default:
        return Colors.grey;
    }
  }

  /// Get the icon for RPG rating
  static IconData getRatingIcon(int? rating, bool nerdMode) {
    if (!nerdMode) {
      return Icons.star;
    }

    switch (rating) {
      case 1:
        return Icons.circle_outlined; // Common
      case 2:
        return Icons.hexagon_outlined; // Uncommon
      case 3:
        return Icons.diamond_outlined; // Rare
      case 4:
        return Icons.auto_awesome; // Epic
      case 5:
        return Icons.whatshot; // Legendary
      default:
        return Icons.remove;
    }
  }
}

/// A widget that displays recipe rating in either star or RPG style
class RecipeRatingDisplay extends ConsumerWidget {
  final int? rating;
  final bool compact;
  final double? iconSize;

  const RecipeRatingDisplay({
    super.key,
    required this.rating,
    this.compact = false,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final rpgEnabled = ref.watch(rpgEnabledProvider);
    final nerdMode = settings.nerdMode && rpgEnabled; // RPG ratings only when BOTH are on
    final theme = Theme.of(context);

    if (rating == null || rating == 0) {
      return const SizedBox.shrink();
    }

    final color = RpgRatingHelper.getRatingColor(rating, nerdMode);
    final name = RpgRatingHelper.getRatingName(context, rating, nerdMode);
    final icon = RpgRatingHelper.getRatingIcon(rating, nerdMode);
    final size = iconSize ?? (compact ? 14.0 : 18.0);

    if (nerdMode) {
      // RPG style display
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 10,
          vertical: compact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(compact ? 4 : 8),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: size, color: color),
            const SizedBox(width: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );
    } else {
      // Standard star display
      if (compact) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: size, color: Colors.amber),
            const SizedBox(width: 2),
            Text(
              '$rating',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return Icon(
            index < rating! ? Icons.star : Icons.star_border,
            size: size,
            color: Colors.amber,
          );
        }),
      );
    }
  }
}

/// Rating picker that supports both star and RPG modes
class RecipeRatingPicker extends ConsumerWidget {
  final int? currentRating;
  final ValueChanged<int?> onRatingChanged;

  const RecipeRatingPicker({
    super.key,
    required this.currentRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final rpgEnabled = ref.watch(rpgEnabledProvider);
    final nerdMode = settings.nerdMode && rpgEnabled;
    final l10n = AppLocalizations.of(context)!;

    if (nerdMode) {
      // RPG style picker
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.recipeFieldRating, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RpgRatingChip(
                rating: 1,
                label: l10n.ratingCommon,
                color: Colors.grey,
                isSelected: currentRating == 1,
                onTap: () => onRatingChanged(currentRating == 1 ? null : 1),
              ),
              _RpgRatingChip(
                rating: 2,
                label: l10n.ratingUncommon,
                color: Colors.green,
                isSelected: currentRating == 2,
                onTap: () => onRatingChanged(currentRating == 2 ? null : 2),
              ),
              _RpgRatingChip(
                rating: 3,
                label: l10n.ratingRare,
                color: Colors.blue,
                isSelected: currentRating == 3,
                onTap: () => onRatingChanged(currentRating == 3 ? null : 3),
              ),
              _RpgRatingChip(
                rating: 4,
                label: l10n.ratingEpic,
                color: Colors.purple,
                isSelected: currentRating == 4,
                onTap: () => onRatingChanged(currentRating == 4 ? null : 4),
              ),
              _RpgRatingChip(
                rating: 5,
                label: l10n.ratingLegendary,
                color: Colors.orange,
                isSelected: currentRating == 5,
                onTap: () => onRatingChanged(currentRating == 5 ? null : 5),
              ),
            ],
          ),
        ],
      );
    } else {
      // Standard star picker
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.recipeFieldRating, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              final starRating = index + 1;
              return IconButton(
                icon: Icon(
                  starRating <= (currentRating ?? 0) ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () => onRatingChanged(
                  currentRating == starRating ? null : starRating,
                ),
              );
            }),
          ),
        ],
      );
    }
  }
}

class _RpgRatingChip extends StatelessWidget {
  final int rating;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RpgRatingChip({
    required this.rating,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              RpgRatingHelper.getRatingIcon(rating, true),
              size: 18,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}