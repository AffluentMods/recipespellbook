// lib/ui/screens/rpg/rpg_leaderboard_screen.dart
// Leaderboard System for Recipe Spellbook RPG

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipespellbook/data/rpg/rpg_models.dart';
import 'package:recipespellbook/providers/rpg_provider.dart';

// ============ LEADERBOARD CATEGORIES ============

enum LeaderboardCategory {
  level,
  totalXp,
  recipesCreated,
  recipesCook,
  streak,
  bossKills,
}

extension LeaderboardCategoryExtension on LeaderboardCategory {
  String get displayName {
    switch (this) {
      case LeaderboardCategory.level: return 'Level';
      case LeaderboardCategory.totalXp: return 'Total XP';
      case LeaderboardCategory.recipesCreated: return 'Recipes';
      case LeaderboardCategory.recipesCook: return 'Cooked';
      case LeaderboardCategory.streak: return 'Streak';
      case LeaderboardCategory.bossKills: return 'Boss Damage';
    }
  }

  IconData get icon {
    switch (this) {
      case LeaderboardCategory.level: return Icons.military_tech;
      case LeaderboardCategory.totalXp: return Icons.auto_awesome;
      case LeaderboardCategory.recipesCreated: return Icons.menu_book;
      case LeaderboardCategory.recipesCook: return Icons.local_fire_department;
      case LeaderboardCategory.streak: return Icons.local_fire_department;
      case LeaderboardCategory.bossKills: return Icons.shield;
    }
  }
}

// ============ LEADERBOARD ENTRY ============

class LeaderboardEntry {
  final String odisplayName;
  final String odisplayTitle;
  final int rank;
  final int value;
  final int level;
  final String avatarId;
  final String frameId;
  final PlayerClass playerClass;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.odisplayName,
    required this.odisplayTitle,
    required this.rank,
    required this.value,
    required this.level,
    required this.avatarId,
    required this.frameId,
    required this.playerClass,
    this.isCurrentUser = false,
  });
}

// ============ LEADERBOARD SCREEN ============

class RpgLeaderboardScreen extends ConsumerStatefulWidget {
  const RpgLeaderboardScreen({super.key});

  @override
  ConsumerState<RpgLeaderboardScreen> createState() => _RpgLeaderboardScreenState();
}

class _RpgLeaderboardScreenState extends ConsumerState<RpgLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LeaderboardCategory _selectedCategory = LeaderboardCategory.level;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Your Stats'),
            Tab(text: 'Community'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Your Stats tab
          _buildYourStatsTab(theme, profile),
          // Community tab (placeholder for now)
          _buildCommunityTab(theme, profile),
        ],
      ),
    );
  }

  Widget _buildYourStatsTab(ThemeData theme, PlayerProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player card
          _PlayerCard(profile: profile),

          const SizedBox(height: 24),

          // Stats grid
          Text(
            'Your Statistics',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                icon: Icons.military_tech,
                label: 'Level',
                value: profile.level.toString(),
                color: Colors.amber,
              ),
              _StatCard(
                icon: Icons.auto_awesome,
                label: 'Total XP',
                value: _formatNumber(profile.totalXp),
                color: Colors.purple,
              ),
              _StatCard(
                icon: Icons.local_fire_department,
                label: 'Login Streak',
                value: '${profile.loginStreak} days',
                color: Colors.orange,
              ),
              _StatCard(
                icon: Icons.emoji_events,
                label: 'Achievements',
                value: '${profile.completedAchievements.length}',
                color: Colors.green,
              ),
              _StatCard(
                icon: Icons.monetization_on,
                label: 'Gold Earned',
                value: _formatNumber(profile.gold),
                color: Colors.amber,
              ),
              _StatCard(
                icon: Icons.diamond,
                label: 'Gems Earned',
                value: _formatNumber(profile.gems),
                color: Colors.blue,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Milestones
          Text(
            'Milestones',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _MilestoneCard(
            title: 'Next Level',
            current: profile.currentXp,
            target: profile.xpForNextLevel,
            icon: Icons.arrow_upward,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          _MilestoneCard(
            title: 'Level 10',
            current: profile.level,
            target: 10,
            icon: Icons.military_tech,
            color: Colors.amber,
            isCompleted: profile.level >= 10,
          ),
          const SizedBox(height: 8),
          _MilestoneCard(
            title: 'Level 25',
            current: profile.level,
            target: 25,
            icon: Icons.military_tech,
            color: Colors.orange,
            isCompleted: profile.level >= 25,
          ),
          const SizedBox(height: 8),
          _MilestoneCard(
            title: 'Level 50',
            current: profile.level,
            target: 50,
            icon: Icons.military_tech,
            color: Colors.red,
            isCompleted: profile.level >= 50,
          ),

          const SizedBox(height: 24),

          // Comparison with average (placeholder)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.insights, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'How You Compare',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ComparisonRow(
                  label: 'Level',
                  yourValue: profile.level,
                  avgValue: 8,
                  isHigherBetter: true,
                ),
                _ComparisonRow(
                  label: 'Login Streak',
                  yourValue: profile.loginStreak,
                  avgValue: 5,
                  isHigherBetter: true,
                ),
                _ComparisonRow(
                  label: 'Achievements',
                  yourValue: profile.completedAchievements.length,
                  avgValue: 12,
                  isHigherBetter: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTab(ThemeData theme, PlayerProfile profile) {
    // For now, show placeholder until backend is ready
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.leaderboard,
                size: 64,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Community Leaderboard',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Compete with other chefs worldwide.\nSee who has the most recipes, highest level, and longest streaks!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 32),

            // Preview of what it will look like
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  _PreviewLeaderboardEntry(rank: 1, name: '???', level: '??', isGold: true),
                  _PreviewLeaderboardEntry(rank: 2, name: '???', level: '??', isSilver: true),
                  _PreviewLeaderboardEntry(rank: 3, name: '???', level: '??', isBronze: true),
                  const Divider(),
                  _PreviewLeaderboardEntry(
                    rank: 42,
                    name: profile.displayName,
                    level: profile.level.toString(),
                    isYou: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Community features coming in a future update!')),
                );
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('Notify Me'),
            ),
          ],
        ),
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

// ============ HELPER WIDGETS ============

class _PlayerCard extends StatelessWidget {
  final PlayerProfile profile;

  const _PlayerCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            profile.playerClass.color.withOpacity(0.3),
            theme.colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: profile.playerClass.color.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: profile.playerClass.color.withOpacity(0.2),
              border: Border.all(
                color: profile.playerClass.color,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                profile.playerClass.icon,
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      profile.playerClass.icon,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      profile.displayTitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Level badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: profile.playerClass.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Level ${profile.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final String title;
  final int current;
  final int target;
  final IconData icon;
  final Color color;
  final bool isCompleted;

  const _MilestoneCard({
    required this.title,
    required this.current,
    required this.target,
    required this.icon,
    required this.color,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (current / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted
            ? color.withOpacity(0.1)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: isCompleted
            ? Border.all(color: color)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted ? color : color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isCompleted ? Colors.white : color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (!isCompleted)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isCompleted ? '✓' : '$current / $target',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isCompleted ? color : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final int yourValue;
  final int avgValue;
  final bool isHigherBetter;

  const _ComparisonRow({
    required this.label,
    required this.yourValue,
    required this.avgValue,
    required this.isHigherBetter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAboveAvg = isHigherBetter ? yourValue > avgValue : yourValue < avgValue;
    final diff = ((yourValue - avgValue) / avgValue * 100).abs();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          Expanded(
            child: Text(
              yourValue.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isAboveAvg ? Colors.green : Colors.red,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'avg: $avgValue',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isAboveAvg
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAboveAvg ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: isAboveAvg ? Colors.green : Colors.red,
                ),
                Text(
                  '${diff.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isAboveAvg ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewLeaderboardEntry extends StatelessWidget {
  final int rank;
  final String name;
  final String level;
  final bool isGold;
  final bool isSilver;
  final bool isBronze;
  final bool isYou;

  const _PreviewLeaderboardEntry({
    required this.rank,
    required this.name,
    required this.level,
    this.isGold = false,
    this.isSilver = false,
    this.isBronze = false,
    this.isYou = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color? badgeColor;
    if (isGold) badgeColor = const Color(0xFFFFD700);
    if (isSilver) badgeColor = const Color(0xFFC0C0C0);
    if (isBronze) badgeColor = const Color(0xFFCD7F32);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: badgeColor ?? (isYou ? theme.colorScheme.primary : null),
              shape: BoxShape.circle,
              border: badgeColor == null && !isYou
                  ? Border.all(color: theme.colorScheme.outline)
                  : null,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: badgeColor != null || isYou
                      ? Colors.white
                      : theme.colorScheme.outline,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isYou ? FontWeight.bold : null,
                color: isYou ? theme.colorScheme.primary : null,
              ),
            ),
          ),
          // Level
          Text(
            'Lv.$level',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}