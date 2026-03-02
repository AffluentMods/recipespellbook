// lib/ui/screens/rpg/rpg_profile_screen.dart
// Main RPG Profile Screen for Recipe Spellbook – "Adventure Card" redesign

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/rpg/rpg_achievements.dart';
import '../../../data/rpg/rpg_cosmetics.dart';
import '../../../data/rpg/rpg_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/rpg_provider.dart';
import '../../../ui/screens/rpg/rpg_daily_quests.dart';
import '../../../ui/widgets/rpg/rpg_widgets.dart';

class RpgProfileScreen extends ConsumerWidget {
  const RpgProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rpgState = ref.watch(rpgProvider);
    final profile = rpgState.profile;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? theme.colorScheme.surface
          : theme.colorScheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          // ── Transparent pinned AppBar ──
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: profile.playerClass.color.withValues(alpha: 0.95),
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              profile.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => _showProfileSettings(context, ref, profile),
              ),
            ],
          ),

          // ── Adventure Card header ──
          SliverToBoxAdapter(
            child: _AdventureCard(profile: profile),
          ),

          // ── Adventurer's Pouch (horizontal stats) ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _AdventurerPouch(profile: profile),
            ),
          ),

          // ── Quick Actions 2×2 grid ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _QuickActionsGrid(
                onBoss: () => context.push('/rpg/boss'),
                onAchievements: () => context.push('/rpg/achievements'),
                onCosmetics: () => context.push('/rpg/cosmetics'),
                onClasses: () => _showClassSelector(context, ref),
              ),
            ),
          ),

          // ── Quest Board (parchment style) ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _QuestBoard(),
            ),
          ),

          // ── Achievement Showcase ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _AchievementShowcase(profile: profile),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  void _showProfileSettings(BuildContext context, WidgetRef ref, PlayerProfile profile) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ProfileSettingsSheet(profile: profile),
    );
  }

  void _showClassSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _ClassSelectorSheet(
          scrollController: scrollController,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  ADVENTURE CARD  –  Full-width hero header
// ════════════════════════════════════════════════════════════════════

class _AdventureCard extends StatelessWidget {
  final PlayerProfile profile;
  const _AdventureCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pet = profile.petId != null ? RpgPets.getById(profile.petId!) : null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            profile.playerClass.color.withValues(alpha: 0.85),
            profile.playerClass.color.withValues(alpha: 0.55),
            isDark ? theme.colorScheme.surface : theme.colorScheme.surfaceContainerLow,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          children: [
            // ── Avatar row: companion + avatar + level ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Companion pet (left side)
                if (pet != null) ...[
                  _CompanionBubble(pet: pet, size: 56),
                  const SizedBox(width: 12),
                ] else
                  const SizedBox(width: 68), // spacer for alignment

                // Main avatar
                RpgAvatarWidget(
                  avatarId: profile.avatarId ?? 'avatar_default',
                  frameId: profile.frameId ?? 'frame_default',
                  petId: null, // We show pet separately now
                  size: 80,
                  level: profile.level,
                ),

                // Class badge (right side)
                const SizedBox(width: 12),
                _ClassBadge(playerClass: profile.playerClass),
              ],
            ),

            const SizedBox(height: 12),

            // ── Name + title ──
            Text(
              profile.displayName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${profile.playerClass.icon}  ${profile.displayTitle}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 14),

            // ── XP bar ──
            RpgXpBar(
              currentXp: profile.currentXp,
              maxXp: profile.xpForNextLevel - profile.xpForCurrentLevel,
              level: profile.level,
              showLabel: true,
              height: 10,
            ),

            // ── Login streak pill ──
            if (profile.loginStreak > 1) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.rpgDaysAgo(profile.loginStreak),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Companion pet bubble ──
class _CompanionBubble extends StatelessWidget {
  final CosmeticItem pet;
  final double size;
  const _CompanionBubble({required this.pet, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surface,
        border: Border.all(color: pet.rarity.color, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: pet.rarity.color.withValues(alpha: 0.35),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          pet.assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text('🐾', style: TextStyle(fontSize: size * 0.4)),
          ),
        ),
      ),
    );
  }
}

// ── Class badge (icon in colored circle) ──
class _ClassBadge extends StatelessWidget {
  final PlayerClass playerClass;
  const _ClassBadge({required this.playerClass});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                playerClass.icon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            playerClass.displayName.split(' ').last, // "Warrior", "Mage", etc.
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  ADVENTURER'S POUCH  –  Horizontal scroll of circular stats
// ════════════════════════════════════════════════════════════════════

class _AdventurerPouch extends StatelessWidget {
  final PlayerProfile profile;
  const _AdventurerPouch({required this.profile});

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          _CircleStat(
            emoji: '🪙',
            value: _fmt(profile.gold),
            label: l10n.rpgGold,
            ringColor: Colors.amber,
            progress: 1.0, // always full – not a bar
          ),
          const SizedBox(width: 16),
          _CircleStat(
            emoji: '💎',
            value: _fmt(profile.gems),
            label: l10n.rpgGems,
            ringColor: Colors.purple,
            progress: 1.0,
          ),
          const SizedBox(width: 16),
          _CircleStat(
            emoji: '🔮',
            value: '${profile.mana}',
            label: l10n.rpgMana,
            ringColor: Colors.blue,
            progress: profile.calculatedMaxMana > 0
                ? profile.mana / profile.calculatedMaxMana
                : 0.0,
          ),
          const SizedBox(width: 16),
          _CircleStat(
            emoji: '❤️',
            value: '${profile.hp}',
            label: 'HP',
            ringColor: Colors.red,
            progress: profile.calculatedMaxHp > 0
                ? profile.hp / profile.calculatedMaxHp
                : 0.0,
          ),
          const SizedBox(width: 16),
          _CircleStat(
            emoji: '⚔️',
            value: '${profile.baseDamage}',
            label: 'ATK',
            ringColor: Colors.orange,
            progress: 1.0,
          ),
        ],
      ),
    );
  }
}

class _CircleStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color ringColor;
  final double progress;

  const _CircleStat({
    required this.emoji,
    required this.value,
    required this.label,
    required this.ringColor,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: 72,
      child: Column(
        children: [
          // Circular progress ring
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 3.5,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(
                      ringColor.withValues(alpha: isDark ? 0.15 : 0.12),
                    ),
                  ),
                ),
                // Progress ring
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 3.5,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(ringColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Emoji center
                Text(emoji, style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  QUICK ACTIONS  –  2×2 illustrated card grid
// ════════════════════════════════════════════════════════════════════

class _QuickActionsGrid extends StatelessWidget {
  final VoidCallback onBoss;
  final VoidCallback onAchievements;
  final VoidCallback onCosmetics;
  final VoidCallback onClasses;

  const _QuickActionsGrid({
    required this.onBoss,
    required this.onAchievements,
    required this.onCosmetics,
    required this.onClasses,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.sports_martial_arts,
                emoji: '⚔️',
                label: l10n.rpgBossFight,
                color: Colors.red,
                onTap: onBoss,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.emoji_events,
                emoji: '🏆',
                label: l10n.rpgAchievements,
                color: Colors.amber,
                onTap: onAchievements,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.face,
                emoji: '✨',
                label: l10n.rpgCosmetics,
                color: Colors.purple,
                onTap: onCosmetics,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.school,
                emoji: '📖',
                label: l10n.rpgClasses,
                color: Colors.blue,
                onTap: onClasses,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark
          ? theme.colorScheme.surfaceContainerHigh
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: isDark ? 0 : 1,
      shadowColor: color.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.2 : 0.12),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Colored icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  QUEST BOARD  –  Parchment-styled daily quests
// ════════════════════════════════════════════════════════════════════

class _QuestBoard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHigh
            : const Color(0xFFFFF8E7), // warm parchment
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.2)
              : const Color(0xFFE8D5B0), // parchment edge
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Board header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.amber.withValues(alpha: 0.08)
                  : const Color(0xFFF5E6C8),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Text('📜', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  l10n.rpgDailyQuests,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ],
            ),
          ),

          // Quests content
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: RpgDailyQuestsCard(compact: false),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  ACHIEVEMENT SHOWCASE  –  Recent unlocks
// ════════════════════════════════════════════════════════════════════

class _AchievementShowcase extends StatelessWidget {
  final PlayerProfile profile;
  const _AchievementShowcase({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final recentAchievements = profile.completedAchievements
        .take(4)
        .map((id) => RpgAchievements.getById(id))
        .whereType<Achievement>()
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(
            alpha: isDark ? 0.2 : 0.3,
          ),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🏅', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    l10n.rpgAchievements,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/rpg/achievements'),
                child: Text(
                  '${profile.completedAchievements.length}/${RpgAchievements.all.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentAchievements.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 42,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.rpgNoAchievementsYet,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentAchievements.map((achievement) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: achievement.tier.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: achievement.tier.color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(achievement.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        achievement.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  PROFILE SETTINGS SHEET  (kept from original)
// ════════════════════════════════════════════════════════════════════

class _ProfileSettingsSheet extends ConsumerStatefulWidget {
  final PlayerProfile profile;

  const _ProfileSettingsSheet({required this.profile});

  @override
  ConsumerState<_ProfileSettingsSheet> createState() => _ProfileSettingsSheetState();
}

class _ProfileSettingsSheetState extends ConsumerState<_ProfileSettingsSheet> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.rpgProfileSettings,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.rpgDisplayName,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                ref.read(rpgProvider.notifier).updateDisplayName(value);
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: Text(l10n.actionCancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty) {
                      ref.read(rpgProvider.notifier)
                          .updateDisplayName(_nameController.text);
                    }
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.save),
                  label: Text(l10n.actionSave),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.red),
            title: Text(l10n.rpgResetProgress),
            subtitle: Text(l10n.rpgResetProgressSubtitle),
            onTap: () => _confirmReset(context),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.rpgResetProgressConfirmTitle),
        content: Text(l10n.rpgResetProgressConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(rpgProvider.notifier).resetProgress();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(l10n.rpgReset),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  CLASS SELECTOR SHEET  (kept from original)
// ════════════════════════════════════════════════════════════════════

class _ClassSelectorSheet extends ConsumerWidget {
  final ScrollController scrollController;

  const _ClassSelectorSheet({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentClass = ref.watch(rpgProvider).profile.playerClass;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.rpgChooseYourClass,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.rpgClassBonusSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 16),
        ...PlayerClass.values.map((playerClass) {
          final isSelected = playerClass == currentClass;
          return Card(
            color: isSelected
                ? playerClass.color.withValues(alpha: 0.2)
                : null,
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: playerClass.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    playerClass.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              title: Text(
                playerClass.displayName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
              subtitle: Text(playerClass.description),
              trailing: isSelected
                  ? Icon(
                Icons.check_circle,
                color: playerClass.color,
              )
                  : null,
              onTap: () {
                ref.read(rpgProvider.notifier).changeClass(playerClass);
                Navigator.pop(context);
              },
            ),
          );
        }),
        const SizedBox(height: 16),
        Card(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.rpgClassBonusesTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.rpgClassBonusesList,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  LOTTERY DIALOG  (kept from original)
// ════════════════════════════════════════════════════════════════════

class _LotteryDialog extends ConsumerStatefulWidget {
  const _LotteryDialog();

  @override
  ConsumerState<_LotteryDialog> createState() => _LotteryDialogState();
}

class _LotteryDialogState extends ConsumerState<_LotteryDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isSpinning = false;
  LotteryResult? _result;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gems = ref.watch(rpgProvider).profile.gems;

    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          const Text('🎰 '),
          Text(l10n.rpgGemLottery),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Spinning wheel animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 10 * 3.14159,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Colors.amber,
                          Colors.purple,
                          Colors.blue,
                          Colors.green,
                          Colors.pink,
                          Colors.amber,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.surface,
                        ),
                        child: Center(
                          child: _result != null
                              ? _buildResultIcon()
                              : Text(
                            '?',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            if (_result != null) ...[
              Text(
                _getResultText(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getResultColor(),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.diamond, color: Colors.purple, size: 20),
                const SizedBox(width: 4),
                Text(
                  l10n.rpgGemsAvailable(gems),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.rpgLotteryCost,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionClose),
        ),
        FilledButton.icon(
          onPressed: gems >= 10 && !_isSpinning ? _spin : null,
          icon: const Icon(Icons.casino),
          label: Text(l10n.rpgSpin),
        ),
      ],
    );
  }

  Widget _buildResultIcon() {
    if (_result == null) return const SizedBox();

    switch (_result!.type) {
      case LotteryRewardType.xp:
        return const Text('✨', style: TextStyle(fontSize: 32));
      case LotteryRewardType.gold:
        return const Text('🪙', style: TextStyle(fontSize: 32));
      case LotteryRewardType.gems:
        return const Text('💎', style: TextStyle(fontSize: 32));
      case LotteryRewardType.rarePet:
        return const Text('🐣', style: TextStyle(fontSize: 32));
      case LotteryRewardType.nothing:
        return const Text('💨', style: TextStyle(fontSize: 32));
    }
  }

  String _getResultText() {
    if (_result == null) return '';
    final l10n = AppLocalizations.of(context)!;

    switch (_result!.type) {
      case LotteryRewardType.xp:
        return l10n.rpgLotteryResultXp(_result!.amount);
      case LotteryRewardType.gold:
        return l10n.rpgLotteryResultGold(_result!.amount);
      case LotteryRewardType.gems:
        return l10n.rpgLotteryResultGems(_result!.amount);
      case LotteryRewardType.rarePet:
        return l10n.rpgLotteryResultRarePet;
      case LotteryRewardType.nothing:
        return l10n.rpgLotteryResultNothing;
    }
  }

  Color _getResultColor() {
    if (_result == null) return Colors.grey;

    switch (_result!.type) {
      case LotteryRewardType.xp:
        return Colors.blue;
      case LotteryRewardType.gold:
        return Colors.amber;
      case LotteryRewardType.gems:
        return Colors.purple;
      case LotteryRewardType.rarePet:
        return Colors.orange;
      case LotteryRewardType.nothing:
        return Colors.grey;
    }
  }

  Future<void> _spin() async {
    setState(() {
      _isSpinning = true;
      _result = null;
    });

    _controller.repeat();

    // Get result
    final result = await ref.read(rpgProvider.notifier).spinLottery();

    // Wait for animation
    await Future.delayed(const Duration(seconds: 2));

    _controller.stop();

    setState(() {
      _isSpinning = false;
      _result = result;
    });
  }
}
