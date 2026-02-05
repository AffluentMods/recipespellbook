import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';

/// A rating widget that displays either standard stars or RPG rarity tiers
/// based on the nerdMode setting
class RecipeRating extends ConsumerWidget {
  final int rating; // 1-5
  final double size;
  final bool showLabel;

  const RecipeRating({
    super.key,
    required this.rating,
    this.size = 20,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    if (settings.nerdMode) {
      return _RpgRarityRating(rating: rating, size: size, showLabel: showLabel);
    } else {
      return _StandardStarRating(rating: rating, size: size);
    }
  }
}

/// Standard 1-5 star rating
class _StandardStarRating extends StatelessWidget {
  final int rating;
  final double size;

  const _StandardStarRating({required this.rating, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }
}

/// RPG-style rarity rating with colored stars and labels
class _RpgRarityRating extends StatelessWidget {
  final int rating;
  final double size;
  final bool showLabel;

  const _RpgRarityRating({
    required this.rating,
    required this.size,
    required this.showLabel,
  });

  @override
  Widget build(BuildContext context) {
    final rarity = RecipeRarity.fromRating(rating);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stars in rarity color
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(rating, (index) {
            return Icon(
              Icons.star_rounded,
              color: rarity.color,
              size: size,
            );
          }),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: rarity.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: rarity.color.withValues(alpha: 0.5)),
            ),
            child: Text(
              rarity.displayName,
              style: TextStyle(
                color: rarity.color,
                fontSize: size * 0.6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// RPG rarity tiers
enum RecipeRarity {
  common(1, 'Common', Color(0xFFB0B0B0), '⚪'),       // Grey/White
  uncommon(2, 'Uncommon', Color(0xFF1EFF00), '🟢'),   // Green
  rare(3, 'Rare', Color(0xFF0070DD), '🔵'),           // Blue
  epic(4, 'Epic', Color(0xFFA335EE), '🟣'),           // Purple
  legendary(5, 'Legendary', Color(0xFFFF8000), '🟠'); // Orange/Gold

  final int rating;
  final String displayName;
  final Color color;
  final String emoji;

  const RecipeRarity(this.rating, this.displayName, this.color, this.emoji);

  static RecipeRarity fromRating(int rating) {
    switch (rating) {
      case 1: return RecipeRarity.common;
      case 2: return RecipeRarity.uncommon;
      case 3: return RecipeRarity.rare;
      case 4: return RecipeRarity.epic;
      case 5: return RecipeRarity.legendary;
      default: return RecipeRarity.common;
    }
  }
}

/// Interactive rating picker that supports both modes
class RecipeRatingPicker extends ConsumerWidget {
  final int rating;
  final ValueChanged<int> onChanged;
  final double size;

  const RecipeRatingPicker({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isRpgMode = settings.nerdMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starRating = index + 1;
            final isSelected = index < rating;
            final rarity = RecipeRarity.fromRating(starRating);

            Color starColor;
            if (isRpgMode) {
              // In RPG mode, show each star in its rarity color
              starColor = isSelected ? rarity.color : Colors.grey.shade400;
            } else {
              // Standard mode: all amber
              starColor = isSelected ? Colors.amber : Colors.grey.shade400;
            }

            return GestureDetector(
              onTap: () => onChanged(starRating),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: starColor,
                  size: size,
                ),
              ),
            );
          }),
        ),
        if (isRpgMode && rating > 0) ...[
          const SizedBox(height: 8),
          _RarityLabel(rarity: RecipeRarity.fromRating(rating)),
        ],
      ],
    );
  }
}

class _RarityLabel extends StatelessWidget {
  final RecipeRarity rarity;

  const _RarityLabel({required this.rarity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rarity.color.withValues(alpha: 0.3),
            rarity.color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: rarity.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(rarity.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            rarity.displayName,
            style: TextStyle(
              color: rarity.color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact rating for list items
class CompactRecipeRating extends ConsumerWidget {
  final int rating;

  const CompactRecipeRating({super.key, required this.rating});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    if (rating == 0) return const SizedBox.shrink();

    if (settings.nerdMode) {
      final rarity = RecipeRarity.fromRating(rating);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: rarity.color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, size: 12, color: rarity.color),
            const SizedBox(width: 2),
            Text(
              rarity.displayName,
              style: TextStyle(
                fontSize: 10,
                color: rarity.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
          const SizedBox(width: 2),
          Text(
            '$rating',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }
  }
}