// lib/ui/screens/rpg/rpg_profile_screen.dart
// Main RPG Profile Screen for Recipe Spellbook

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/rpg/rpg_achievements.dart';
import '../../../data/rpg/rpg_models.dart';
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Fancy RPG Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: theme.colorScheme.primaryContainer,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(context, profile, theme),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showProfileSettings(context, ref, profile),
              ),
            ],
          ),

          // Stats Cards
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: _buildStatsRow(context, profile, theme),
            ),
          ),

          // Quick Actions Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: _buildQuickActionsGrid(context, ref, theme),
            ),
          ),

          // Daily Quests
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: RpgDailyQuestsCard(compact: false),
            ),
          ),

          // Recent Activity
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: _buildRecentActivity(context, rpgState, theme),
            ),
          ),

          // Achievement Showcase
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: _buildAchievementShowcase(context, profile, theme),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, PlayerProfile profile, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            profile.playerClass.color.withValues(alpha: 0.8),
            theme.colorScheme.primaryContainer,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar with frame and pet
              RpgAvatarWidget(
                avatarId: profile.avatarId ?? 'avatar_default',
                frameId: profile.frameId ?? 'frame_default',
                petId: profile.petId,
                size: 100,
                level: profile.level,
              ),
              const SizedBox(height: 12),

              // Name and title
              Text(
                profile.displayName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              Text(
                '${profile.playerClass.icon} ${profile.displayTitle}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 16),

              // XP Bar
              RpgXpBar(
                currentXp: profile.currentXp,
                maxXp: profile.xpForNextLevel - profile.xpForCurrentLevel,
                level: profile.level,
                showLabel: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, PlayerProfile profile, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.monetization_on,
            iconColor: Colors.amber,
            label: 'Gold',
            value: _formatNumber(profile.gold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.diamond,
            iconColor: Colors.purple,
            label: 'Gems',
            value: _formatNumber(profile.gems),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.auto_awesome,
            iconColor: Colors.blue,
            label: 'Mana',
            value: '${profile.mana}/${profile.calculatedMaxMana}',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚔️ Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.emoji_events,
                    label: 'Achievements',
                    color: Colors.amber,
                    onTap: () => context.push('/rpg/achievements'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.face,
                    label: 'Cosmetics',
                    color: Colors.purple,
                    onTap: () => context.push('/rpg/cosmetics'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.leaderboard,
                    label: 'Leaderboard',
                    color: Colors.green,
                    onTap: () => context.push('/rpg/leaderboard'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.casino,
                    label: 'Lottery',
                    color: Colors.pink,
                    onTap: () => _showLotteryDialog(context, ref),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.sports_martial_arts,
                    label: 'Boss Fight',
                    color: Colors.red,
                    onTap: () => context.push('/rpg/boss'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.school,
                    label: 'Classes',
                    color: Colors.blue,
                    onTap: () => _showClassSelector(context, ref),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, RpgState rpgState, ThemeData theme) {
    final recentXp = rpgState.recentXpGains;

    if (recentXp.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✨ Recent XP',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...recentXp.take(3).map((event) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  '+${event.totalXp}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(event.description ?? event.actionType.displayName),
              subtitle: Text(
                _formatTimeAgo(event.timestamp),
                style: theme.textTheme.bodySmall,
              ),
              trailing: event.multiplier > 1.0
                  ? Chip(
                label: Text('${event.multiplier}x'),
                backgroundColor: Colors.amber.withValues(alpha: 0.2),
                labelStyle: const TextStyle(fontSize: 10),
                padding: EdgeInsets.zero,
              )
                  : null,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementShowcase(BuildContext context, PlayerProfile profile, ThemeData theme) {
    final recentAchievements = profile.completedAchievements
        .take(4)
        .map((id) => RpgAchievements.getById(id))
        .whereType<Achievement>()
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🏆 Achievements',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/rpg/achievements'),
                  child: Text(
                    '${profile.completedAchievements.length}/${RpgAchievements.all.length}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (recentAchievements.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No achievements yet!\nStart earning XP to unlock achievements.',
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
                  return Chip(
                    avatar: Text(achievement.icon),
                    label: Text(achievement.name),
                    backgroundColor: achievement.tier.color.withValues(alpha: 0.2),
                  );
                }).toList(),
              ),
          ],
        ),
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

  void _showLotteryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _LotteryDialog(),
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

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ============ HELPER WIDGETS ============

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ PROFILE SETTINGS SHEET ============

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
            'Profile Settings',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              border: OutlineInputBorder(),
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
                  label: const Text('Cancel'),
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
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.red),
            title: const Text('Reset Progress'),
            subtitle: const Text('Start over from level 1'),
            onTap: () => _confirmReset(context),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will reset all your XP, level, gold, gems, achievements, and cosmetics. This cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(rpgProvider.notifier).resetProgress();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// ============ CLASS SELECTOR SHEET ============

class _ClassSelectorSheet extends ConsumerWidget {
  final ScrollController scrollController;

  const _ClassSelectorSheet({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentClass = ref.watch(rpgProvider).profile.playerClass;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Choose Your Class',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Each class provides bonus XP for specific actions',
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
                  '💡 Class Bonuses',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Ranger: +50% XP for importing recipes\n'
                      '• Warrior: +50% XP for cooking recipes\n'
                      '• Mage: +50% XP for adding nutrition\n'
                      '• Alchemist: +50% XP for creating recipes\n'
                      '• Bard: +50% XP for uploading cookbooks',
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

// ============ LOTTERY DIALOG ============

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

    return AlertDialog(
      title: const Row(
        children: [
          Text('🎰 '),
          Text('Gem Lottery'),
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
                  '$gems gems available',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Cost: 10 gems per spin',
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
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: gems >= 10 && !_isSpinning ? _spin : null,
          icon: const Icon(Icons.casino),
          label: const Text('Spin! (10 💎)'),
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

    switch (_result!.type) {
      case LotteryRewardType.xp:
        return '+${_result!.amount} XP!';
      case LotteryRewardType.gold:
        return '+${_result!.amount} Gold!';
      case LotteryRewardType.gems:
        return '+${_result!.amount} Gems!';
      case LotteryRewardType.rarePet:
        return '🎉 RARE PET! 🎉';
      case LotteryRewardType.nothing:
        return 'Better luck next time!';
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