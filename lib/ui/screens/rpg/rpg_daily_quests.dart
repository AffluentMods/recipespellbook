// lib/ui/widgets/rpg/rpg_daily_quests.dart
// Daily Quests Widget for Recipe Spellbook RPG

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipespellbook/data/rpg/rpg_quests.dart';
import 'package:recipespellbook/data/rpg/rpg_models.dart';
import 'package:recipespellbook/providers/rpg_provider.dart';

// ============ QUESTS PROVIDER ============

final dailyQuestsProvider = StateNotifierProvider<DailyQuestsNotifier, DailyQuestsState>((ref) {
  return DailyQuestsNotifier(ref);
});

class DailyQuestsState {
  final List<DailyQuest> quests;
  final WeeklyChallenge weeklyChallenge;
  final DateTime lastRefresh;

  DailyQuestsState({
    required this.quests,
    required this.weeklyChallenge,
    required this.lastRefresh,
  });

  DailyQuestsState copyWith({
    List<DailyQuest>? quests,
    WeeklyChallenge? weeklyChallenge,
    DateTime? lastRefresh,
  }) {
    return DailyQuestsState(
      quests: quests ?? this.quests,
      weeklyChallenge: weeklyChallenge ?? this.weeklyChallenge,
      lastRefresh: lastRefresh ?? this.lastRefresh,
    );
  }

  int get completedCount => quests.where((q) => q.isCompleted).length;
  int get claimedCount => quests.where((q) => q.isClaimed).length;
  bool get allClaimed => claimedCount == quests.length;
}

class DailyQuestsNotifier extends StateNotifier<DailyQuestsState> {
  final Ref _ref;

  DailyQuestsNotifier(this._ref) : super(DailyQuestsState(
    quests: QuestTemplates.generateDailyQuests(DateTime.now()),
    weeklyChallenge: WeeklyChallenge.getCurrentWeekly(),
    lastRefresh: DateTime.now(),
  )) {
    _checkForNewDay();
  }

  void _checkForNewDay() {
    final now = DateTime.now();
    final lastDate = state.lastRefresh;

    // If it's a new day, regenerate quests
    if (now.day != lastDate.day || now.month != lastDate.month || now.year != lastDate.year) {
      state = DailyQuestsState(
        quests: QuestTemplates.generateDailyQuests(now),
        weeklyChallenge: WeeklyChallenge.getCurrentWeekly(),
        lastRefresh: now,
      );
    }
  }

  void updateQuestProgress(QuestType type, int amount) {
    final updatedQuests = state.quests.map((quest) {
      if (quest.type == type && !quest.isCompleted) {
        final newProgress = quest.currentProgress + amount;
        final isNowCompleted = newProgress >= quest.targetCount;
        return quest.copyWith(
          currentProgress: newProgress,
          isCompleted: isNowCompleted,
        );
      }
      return quest;
    }).toList();

    state = state.copyWith(quests: updatedQuests);
  }

  Future<bool> claimQuest(String questId) async {
    final questIndex = state.quests.indexWhere((q) => q.id == questId);
    if (questIndex == -1) return false;

    final quest = state.quests[questIndex];
    if (!quest.isCompleted || quest.isClaimed) return false;

    // Award rewards
    _ref.read(rpgProvider.notifier).awardXp(
      XpActionType.achievementUnlocked,
      multiplier: quest.xpReward ~/ 50,
      description: 'Quest: ${quest.title}',
    );
    _ref.read(rpgProvider.notifier).awardGold(quest.goldReward);

    // Mark as claimed
    final updatedQuests = [...state.quests];
    updatedQuests[questIndex] = quest.copyWith(isClaimed: true);
    state = state.copyWith(quests: updatedQuests);

    return true;
  }

  void refresh() {
    _checkForNewDay();
  }
}

// ============ DAILY QUESTS WIDGET ============

class RpgDailyQuestsCard extends ConsumerWidget {
  final bool compact;

  const RpgDailyQuestsCard({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final questsState = ref.watch(dailyQuestsProvider);
    final quests = questsState.quests;

    if (compact) {
      return _buildCompactCard(context, theme, quests, ref);
    }

    return _buildFullCard(context, theme, quests, questsState.weeklyChallenge, ref);
  }

  Widget _buildCompactCard(
      BuildContext context,
      ThemeData theme,
      List<DailyQuest> quests,
      WidgetRef ref,
      ) {
    final completedCount = quests.where((q) => q.isCompleted).length;
    final claimedCount = quests.where((q) => q.isClaimed).length;
    final hasUnclaimed = completedCount > claimedCount;

    return Card(
      child: InkWell(
        onTap: () => _showQuestsSheet(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasUnclaimed
                      ? Colors.amber.withValues(alpha: 0.2)
                      : theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assignment,
                  color: hasUnclaimed
                      ? Colors.amber
                      : theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Quests',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$completedCount/${quests.length} completed',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasUnclaimed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Claim!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullCard(
      BuildContext context,
      ThemeData theme,
      List<DailyQuest> quests,
      WeeklyChallenge weeklyChallenge,
      WidgetRef ref,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                '📋 Daily Quests',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                _getTimeUntilReset(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Quest list
        ...quests.map((quest) => _QuestTile(
          quest: quest,
          onClaim: () => ref.read(dailyQuestsProvider.notifier).claimQuest(quest.id),
        )),

        const SizedBox(height: 16),

        // Weekly challenge
        _WeeklyChallengeCard(challenge: weeklyChallenge),
      ],
    );
  }

  String _getTimeUntilReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final remaining = tomorrow.difference(now);

    if (remaining.inHours > 0) {
      return 'Resets in ${remaining.inHours}h';
    }
    return 'Resets in ${remaining.inMinutes}m';
  }

  void _showQuestsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => RpgDailyQuestsSheet(
          scrollController: controller,
        ),
      ),
    );
  }
}

// ============ QUEST TILE ============

class _QuestTile extends StatelessWidget {
  final DailyQuest quest;
  final VoidCallback onClaim;

  const _QuestTile({
    required this.quest,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canClaim = quest.isCompleted && !quest.isClaimed;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: quest.isClaimed
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
          : canClaim
          ? Colors.amber.withValues(alpha: 0.1)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: quest.isClaimed
                    ? Colors.green.withValues(alpha: 0.2)
                    : quest.type.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                quest.isClaimed ? Icons.check : quest.type.icon,
                color: quest.isClaimed ? Colors.green : quest.type.color,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        quest.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: quest.isClaimed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: quest.difficulty.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          quest.difficulty.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: quest.difficulty.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    quest.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: quest.progressPercent,
                            minHeight: 6,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(
                              quest.isCompleted ? Colors.green : quest.type.color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${quest.currentProgress}/${quest.targetCount}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Rewards / Claim button
            if (canClaim)
              FilledButton(
                onPressed: onClaim,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Claim'),
              )
            else if (quest.isClaimed)
              const Icon(Icons.check_circle, color: Colors.green)
            else
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 12)),
                      Text(
                        '+${quest.xpReward}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, size: 12, color: Colors.amber),
                      Text(
                        '+${quest.goldReward}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ============ WEEKLY CHALLENGE CARD ============

class _WeeklyChallengeCard extends StatelessWidget {
  final WeeklyChallenge challenge;

  const _WeeklyChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withValues(alpha: 0.2),
            Colors.blue.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                'Weekly Challenge',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const Spacer(),
              Text(
                challenge.timeRemainingDisplay,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            challenge.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            challenge.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          // Progress
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: challenge.progressPercent,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: const AlwaysStoppedAnimation(Colors.purple),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${challenge.currentProgress}/${challenge.targetCount}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Rewards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _RewardBadge(icon: '✨', value: '+${challenge.xpReward} XP'),
              _RewardBadge(icon: '🪙', value: '+${challenge.goldReward}'),
              _RewardBadge(icon: '💎', value: '+${challenge.gemReward}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  final String icon;
  final String value;

  const _RewardBadge({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ============ FULL QUESTS SHEET ============

class RpgDailyQuestsSheet extends ConsumerWidget {
  final ScrollController scrollController;

  const RpgDailyQuestsSheet({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final questsState = ref.watch(dailyQuestsProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Text(
                '📋 Daily Quests',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${questsState.completedCount}/${questsState.quests.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Complete quests to earn bonus XP and gold!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 20),

          // Quest list
          ...questsState.quests.map((quest) => _QuestTile(
            quest: quest,
            onClaim: () => ref.read(dailyQuestsProvider.notifier).claimQuest(quest.id),
          )),

          const SizedBox(height: 24),

          // Weekly challenge
          _WeeklyChallengeCard(challenge: questsState.weeklyChallenge),
        ],
      ),
    );
  }
}