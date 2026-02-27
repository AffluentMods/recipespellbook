import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Recipe rarity levels for RPG mode
enum RecipeRarity {
  common(1, Color(0xFF9E9E9E), '⚪'),
  uncommon(2, Color(0xFF4CAF50), '🟢'),
  rare(3, Color(0xFF2196F3), '🔵'),
  epic(4, Color(0xFF9C27B0), '🟣'),
  legendary(5, Color(0xFFFF9800), '🟠');

  final int value;
  final Color color;
  final String icon;

  const RecipeRarity(this.value, this.color, this.icon);

  static RecipeRarity fromRating(int rating) {
    return RecipeRarity.values.firstWhere(
          (r) => r.value == rating.clamp(1, 5),
      orElse: () => RecipeRarity.common,
    );
  }

  String label(AppLocalizations l10n) {
    switch (this) {
      case RecipeRarity.common:
        return l10n.rarityCommon;
      case RecipeRarity.uncommon:
        return l10n.rarityUncommon;
      case RecipeRarity.rare:
        return l10n.rarityRare;
      case RecipeRarity.epic:
        return l10n.rarityEpic;
      case RecipeRarity.legendary:
        return l10n.rarityLegendary;
    }
  }

  String description(AppLocalizations l10n) {
    switch (this) {
      case RecipeRarity.common:
        return l10n.rarityCommonDesc;
      case RecipeRarity.uncommon:
        return l10n.rarityUncommonDesc;
      case RecipeRarity.rare:
        return l10n.rarityRareDesc;
      case RecipeRarity.epic:
        return l10n.rarityEpicDesc;
      case RecipeRarity.legendary:
        return l10n.rarityLegendaryDesc;
    }
  }
}

/// RPG-style rarity picker that replaces star ratings when RPG mode is enabled
class RpgRarityPicker extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int> onChanged;
  final bool enableAnimations;
  final bool compact;

  const RpgRarityPicker({
    super.key,
    required this.initialRating,
    required this.onChanged,
    this.enableAnimations = true,
    this.compact = false,
  });

  @override
  State<RpgRarityPicker> createState() => _RpgRarityPickerState();
}

class _RpgRarityPickerState extends State<RpgRarityPicker>
    with SingleTickerProviderStateMixin {
  late RecipeRarity _selected;
  late AnimationController _animController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialRating == 0
        ? RecipeRarity.common
        : RecipeRarity.fromRating(widget.initialRating);

    _animController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _startAnimationIfNeeded();
  }

  void _startAnimationIfNeeded() {
    if (widget.enableAnimations && _selected.value >= 4) {
      _animController.repeat(reverse: true);
    } else {
      _animController.stop();
      _animController.reset();
    }
  }

  @override
  void didUpdateWidget(RpgRarityPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enableAnimations != widget.enableAnimations) {
      _startAnimationIfNeeded();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectRarity(RecipeRarity rarity) {
    setState(() => _selected = rarity);
    widget.onChanged(rarity.value);
    _startAnimationIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.compact) {
      return _buildCompact(theme);
    }

    return _buildFull(theme);
  }

  Widget _buildCompact(ThemeData theme) {
    return Row(
      children: RecipeRarity.values.map((rarity) {
        final isSelected = rarity == _selected;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: GestureDetector(
            onTap: () => _selectRarity(rarity),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? rarity.color.withValues(alpha: 0.3) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? rarity.color : theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(rarity.icon, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFull(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.rpgRecipeRarity, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: RecipeRarity.values.map((rarity) {
            final isSelected = rarity == _selected;
            final shouldAnimate = isSelected && rarity.value >= 4 && widget.enableAnimations;

            return AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final glowIntensity = shouldAnimate ? _glowAnimation.value : 0.0;
                final scale = shouldAnimate ? _pulseAnimation.value : 1.0;

                return Transform.scale(
                  scale: isSelected ? scale : 1.0,
                  child: GestureDetector(
                    onTap: () => _selectRarity(rarity),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected ? LinearGradient(
                          colors: [
                            rarity.color.withValues(alpha: 0.3),
                            rarity.color.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ) : null,
                        color: isSelected ? null : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? rarity.color : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: glowIntensity > 0 ? [
                          BoxShadow(
                            color: rarity.color.withOpacity(0.5 * glowIntensity),
                            blurRadius: 16 * glowIntensity,
                            spreadRadius: 2 * glowIntensity,
                          ),
                        ] : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(rarity.icon, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            rarity.label(l10n),
                            style: TextStyle(
                              color: isSelected ? rarity.color : theme.colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),

        // Description text for selected rarity
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Padding(
            key: ValueKey(_selected),
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                if (_selected.value >= 4) ...[
                  Text(
                    _selected.value == 5 ? '✨' : '💎',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    _selected.description(l10n),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _selected.color,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Display-only rarity badge for showing on recipe cards/views
class RarityBadge extends StatelessWidget {
  final int rating;
  final bool showLabel;
  final double size;

  const RarityBadge({
    super.key,
    required this.rating,
    this.showLabel = true,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final rarity = RecipeRarity.fromRating(rating);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 10 : 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rarity.color.withValues(alpha: 0.3),
            rarity.color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rarity.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(rarity.icon, style: TextStyle(fontSize: size * 0.7)),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              rarity.label(l10n),
              style: theme.textTheme.labelSmall?.copyWith(
                color: rarity.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}