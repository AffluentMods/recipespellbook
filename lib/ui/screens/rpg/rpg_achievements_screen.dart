// lib/ui/screens/rpg/rpg_achievements_screen.dart
// Achievements browser for Recipe Spellbook RPG System

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/rpg/rpg_achievements.dart';
import '../../../data/rpg/rpg_models.dart';
import '../../../providers/rpg_provider.dart';

class RpgAchievementsScreen extends ConsumerStatefulWidget {
  const RpgAchievementsScreen({super.key});

  @override
  ConsumerState<RpgAchievementsScreen> createState() => _RpgAchievementsScreenState();
}

class _RpgAchievementsScreenState extends ConsumerState<RpgAchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AchievementCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AchievementCategory.values.length + 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(rpgProvider).profile;
    final completedIds = profile.completedAchievements.toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Achievements'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'All'),
            ...AchievementCategory.values.map((cat) => Tab(
              text: cat.displayName,
              icon: Icon(cat.icon, size: 16),
            )),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${completedIds.length}/${RpgAchievements.all.length}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All achievements
          _buildAchievementList(
            RpgAchievements.getVisible(completedIds),
            completedIds,
            profile,
          ),
          // Category tabs
          ...AchievementCategory.values.map((category) {
            final achievements = RpgAchievements.getByCategory(category)
                .where((a) => !a.isSecret || completedIds.contains(a.id))
                .toList();
            return _buildAchievementList(achievements, completedIds, profile);
          }),
        ],
      ),
    );
  }

  Widget _buildAchievementList(
      List<Achievement> achievements,
      Set<String> completedIds,
      PlayerProfile profile,
      ) {
    final theme = Theme.of(context);

    // Sort: completed first, then by tier
    achievements.sort((a, b) {
      final aCompleted = completedIds.contains(a.id);
      final bCompleted = completedIds.contains(b.id);
      if (aCompleted != bCompleted) {
        return aCompleted ? -1 : 1;
      }
      return a.tier.index.compareTo(b.tier.index);
    });

    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No achievements in this category',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final isCompleted = completedIds.contains(achievement.id);
        final progress = profile.achievementProgress[achievement.id] ?? 0;

        return _AchievementCard(
          achievement: achievement,
          isCompleted: isCompleted,
          progress: progress,
        );
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isCompleted;
  final int progress;

  const _AchievementCard({
    required this.achievement,
    required this.isCompleted,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressPercent = achievement.targetValue > 0
        ? (progress / achievement.targetValue).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isCompleted
          ? achievement.tier.color.withValues(alpha: 0.1)
          : null,
      child: InkWell(
        onTap: () => _showDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? achievement.tier.color.withValues(alpha: 0.3)
                      : theme.colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: isCompleted
                        ? achievement.tier.color
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 28),
                  )
                      : Icon(
                    Icons.lock_outline,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? achievement.tier.color
                                  : null,
                            ),
                          ),
                        ),
                        _TierBadge(tier: achievement.tier),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    if (!isCompleted && achievement.targetValue > 1) ...[
                      const SizedBox(height: 8),
                      // Progress bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progressPercent,
                                backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation(
                                  achievement.tier.color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$progress/${achievement.targetValue}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Rewards
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.diamond, color: Colors.purple, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '+${achievement.gemReward}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('✨', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '+${achievement.xpReward} XP',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (achievement.unlocksItemId != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.card_giftcard,
                            size: 14,
                            color: theme.colorScheme.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Unlocks item',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            _TierBadge(tier: achievement.tier, large: true),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Category: ${achievement.category.displayName}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RewardChip(
                  icon: Icons.diamond,
                  color: Colors.purple,
                  value: '+${achievement.gemReward}',
                  label: 'Gems',
                ),
                const SizedBox(width: 16),
                _RewardChip(
                  icon: Icons.auto_awesome,
                  color: theme.colorScheme.primary,
                  value: '+${achievement.xpReward}',
                  label: 'XP',
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (isCompleted)
              const Chip(
                avatar: Icon(Icons.check, color: Colors.green),
                label: Text('Completed!'),
                backgroundColor: Colors.green,
              )
            else
              Text(
                'Progress: $progress / ${achievement.targetValue}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final AchievementTier tier;
  final bool large;

  const _TierBadge({required this.tier, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 4 : 2,
      ),
      decoration: BoxDecoration(
        color: tier.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tier.color),
      ),
      child: Text(
        tier.displayName,
        style: TextStyle(
          fontSize: large ? 14 : 10,
          fontWeight: FontWeight.bold,
          color: tier.color,
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _RewardChip({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
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
        ],
      ),
    );
  }
}