import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/rpg/rpg_achievements.dart';
import '../../../data/rpg/rpg_cosmetics.dart';
import '../../../data/rpg/rpg_models.dart';
import '../../../providers/rpg_provider.dart';

// ============ RPG AVATAR WIDGET ============

class RpgAvatarWidget extends StatelessWidget {
  final String? avatarId;
  final String? frameId;
  final double size;
  final int? level;
  final bool showLevel;
  final String? petId;

  const RpgAvatarWidget({
    super.key,
    this.avatarId,
    this.frameId,
    this.size = 64,
    this.level,
    this.showLevel = true,
    this.petId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatar = avatarId != null ? RpgAvatars.getById(avatarId!) : null;
    final frame = frameId != null ? RpgFrames.getById(frameId!) : null;
    final pet = petId != null ? RpgPets.getById(petId!) : null;
    final isDefaultFrame = frameId == null || frameId == 'frame_default';

    final totalSize = size + 16;

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1) Glow effect behind everything (non-default frames only)
          if (!isDefaultFrame && frame != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: frame.rarity.color.withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),

          // 2) Avatar image (base layer, fills circle with inset for frame space)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: avatar != null
                      ? Image.asset(
                    avatar.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      size: size * 0.5,
                      color: theme.colorScheme.outline,
                    ),
                  )
                      : Icon(
                    Icons.person,
                    size: size * 0.5,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ),
          ),

          // 3) Frame overlay ON TOP of avatar
          if (isDefaultFrame)
          // Default: simple grey circular border
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                    width: 2.5,
                  ),
                ),
              ),
            )
          else if (frame != null)
          // Custom frame: load PNG overlay (ring with transparent center)
            Positioned.fill(
              child: ClipOval(
                child: Image.asset(
                  frame.assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: frame.rarity.color,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 4) Level badge (bottom-right)
          if (showLevel && level != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  'Lv.$level',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),

          // 5) Pet companion (top-right, outside the circle)
          if (pet != null)
            Positioned(
              right: -10,
              top: -4,
              child: Container(
                width: size * 0.38,
                height: size * 0.38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: pet.rarity.color,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: pet.rarity.color.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    pet.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        '🐾',
                        style: TextStyle(fontSize: size * 0.15),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============ XP BAR WIDGET ============

class RpgXpBar extends StatelessWidget {
  final int currentXp;
  final int maxXp;
  final int level;
  final bool showLabel;
  final double height;
  final Color? barColor;
  final Color? backgroundColor;

  const RpgXpBar({
    super.key,
    required this.currentXp,
    required this.maxXp,
    required this.level,
    this.showLabel = false,
    this.height = 12,
    this.barColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = maxXp > 0 ? (currentXp / maxXp).clamp(0.0, 1.0) : 0.0;
    final effectiveBarColor = barColor ?? theme.colorScheme.primary;
    final effectiveBgColor = backgroundColor ??
        theme.colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level $level',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$currentXp / $maxXp XP',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: effectiveBgColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Stack(
            children: [
              // Progress bar
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        effectiveBarColor,
                        effectiveBarColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: effectiveBarColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              // Shine effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height / 2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============ COMPACT XP BAR (for app bar) ============

class RpgCompactXpBar extends ConsumerWidget {
  const RpgCompactXpBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rpgState = ref.watch(rpgProvider);
    if (!rpgState.isEnabled) return const SizedBox.shrink();

    final profile = rpgState.profile;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Lv.${profile.level}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Mini XP bar
          SizedBox(
            width: 60,
            child: RpgXpBar(
              currentXp: profile.currentXp,
              maxXp: profile.xpForNextLevel - profile.xpForCurrentLevel,
              level: profile.level,
              height: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ XP GAIN TOAST ============

class RpgXpGainToast extends StatelessWidget {
  final XpGainEvent event;
  final VoidCallback? onDismiss;

  const RpgXpGainToast({
    super.key,
    required this.event,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '+${event.totalXp}',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.description ?? event.actionType.displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (event.multiplier > 1.0)
                    Text(
                      '${event.multiplier}x Class Bonus!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.amber,
                      ),
                    ),
                ],
              ),
            ),
            if (onDismiss != null)
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}

// ============ LEVEL UP DIALOG ============

class RpgLevelUpDialog extends StatelessWidget {
  final LevelUpEvent event;

  const RpgLevelUpDialog({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.amber,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stars decoration
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✨', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  'LEVEL UP!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('✨', style: TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 24),
            // Level change
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LevelBadge(level: event.previousLevel, isOld: true),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.arrow_forward, size: 32, color: Colors.amber),
                ),
                _LevelBadge(level: event.newLevel, isOld: false),
              ],
            ),
            const SizedBox(height: 24),
            // Rewards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '+${event.goldReward} Gold',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            if (event.unlockedItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Unlocked: ${event.unlockedItems.join(", ")}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Awesome!'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  final bool isOld;

  const _LevelBadge({required this.level, required this.isOld});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOld
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.amber,
        border: Border.all(
          color: isOld ? Colors.grey : Colors.amber.shade700,
          width: 3,
        ),
      ),
      child: Center(
        child: Text(
          '$level',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isOld ? Colors.grey : Colors.black87,
          ),
        ),
      ),
    );
  }
}

// ============ ACHIEVEMENT UNLOCK DIALOG ============

class RpgAchievementUnlockDialog extends StatelessWidget {
  final Achievement achievement;

  const RpgAchievementUnlockDialog({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: achievement.tier.color,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: achievement.tier.color.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🏆 Achievement Unlocked!',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Achievement icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: achievement.tier.color.withValues(alpha: 0.2),
                border: Border.all(
                  color: achievement.tier.color,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              achievement.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Rewards
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.diamond, color: Colors.purple, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '+${achievement.gemReward}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '+${achievement.xpReward} XP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Claim!'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ RPG NOTIFICATION LISTENER ============

class RpgNotificationListener extends ConsumerWidget {
  final Widget child;

  const RpgNotificationListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for level up events
    ref.listen<LevelUpEvent?>(pendingLevelUpProvider, (previous, next) {
      if (next != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => RpgLevelUpDialog(event: next),
        ).then((_) {
          ref.read(rpgProvider.notifier).clearPendingLevelUp();
        });
      }
    });

    // Listen for achievement unlocks
    ref.listen<Achievement?>(pendingAchievementProvider, (previous, next) {
      if (next != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => RpgAchievementUnlockDialog(achievement: next),
        ).then((_) {
          ref.read(rpgProvider.notifier).clearPendingAchievement();
        });
      }
    });

    return child;
  }
}

// ============ RPG CURRENCY DISPLAY ============

class RpgCurrencyDisplay extends ConsumerWidget {
  final bool showGold;
  final bool showGems;
  final bool compact;

  const RpgCurrencyDisplay({
    super.key,
    this.showGold = true,
    this.showGems = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(rpgProvider).profile;
    final theme = Theme.of(context);

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showGold) ...[
            const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              _formatNumber(profile.gold),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
          if (showGold && showGems) const SizedBox(width: 12),
          if (showGems) ...[
            const Icon(Icons.diamond, color: Colors.purple, size: 16),
            const SizedBox(width: 4),
            Text(
              _formatNumber(profile.gems),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showGold) ...[
            const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              _formatNumber(profile.gold),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
          if (showGold && showGems) const SizedBox(width: 16),
          if (showGems) ...[
            const Icon(Icons.diamond, color: Colors.purple, size: 20),
            const SizedBox(width: 4),
            Text(
              _formatNumber(profile.gems),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

// ============ RPG MANA BAR ============

class RpgManaBar extends StatelessWidget {
  final int current;
  final int max;
  final double height;

  const RpgManaBar({
    super.key,
    required this.current,
    required this.max,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final progress = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        widthFactor: progress,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}