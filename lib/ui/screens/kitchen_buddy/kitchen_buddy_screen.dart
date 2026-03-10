// lib/ui/screens/kitchen_buddy/kitchen_buddy_screen.dart
// Main Kitchen Buddy screen — companion view + closet/shop/achievements tabs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/kitchen_buddy/kitchen_buddy_models.dart';
import '../../../data/kitchen_buddy/kitchen_buddy_shop.dart';
import '../../../data/rpg/rpg_achievements.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/kitchen_buddy_provider.dart';
import '../../widgets/kitchen_buddy/kitchen_buddy_widget.dart';

class KitchenBuddyScreen extends ConsumerStatefulWidget {
  const KitchenBuddyScreen({super.key});

  @override
  ConsumerState<KitchenBuddyScreen> createState() => _KitchenBuddyScreenState();
}

class _KitchenBuddyScreenState extends ConsumerState<KitchenBuddyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buddyState = ref.watch(kitchenBuddyProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final companion = buddyState.companion;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.kitchenBuddyTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.checkroom), text: l10n.kitchenBuddyCloset),
            Tab(icon: const Icon(Icons.storefront), text: l10n.kitchenBuddyShop),
            Tab(icon: const Icon(Icons.emoji_events), text: l10n.kitchenBuddyAchievements),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Companion display ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: theme.colorScheme.surfaceContainerLowest,
            child: Column(
              children: [
                KitchenBuddyWidget(
                  size: 180,
                  showBackground: true,
                  interactive: true,
                ),
                const SizedBox(height: 8),
                if (companion != null) ...[
                  Text(
                    companion.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 4),
                    Text(
                      '${buddyState.wallet.spiceCoins}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB8860B),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.local_fire_department, size: 18, color: Colors.orange.shade700),
                    const SizedBox(width: 2),
                    Text(
                      l10n.kitchenBuddyStreakDays(buddyState.wallet.loginStreak),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Tab content ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ClosetTab(buddyState: buddyState),
                _ShopTab(buddyState: buddyState),
                _AchievementsTab(buddyState: buddyState),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
//  CLOSET TAB
// ══════════════════════════════════════════

class _ClosetTab extends ConsumerWidget {
  final KitchenBuddyState buddyState;
  const _ClosetTab({required this.buddyState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ownedItems = KitchenBuddyShop.all
        .where((item) => buddyState.ownedItems.contains(item.id))
        .toList();

    if (ownedItems.isEmpty) {
      return Center(
        child: Text(l10n.kitchenBuddyClosetEmpty),
      );
    }

    // Group by category
    final grouped = <ShopCategory, List<ShopItem>>{};
    for (final item in ownedItems) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final category in ShopCategory.values)
          if (grouped.containsKey(category)) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                '${category.emoji} ${category.displayName}',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: grouped[category]!.map((item) {
                final isEquipped = _isEquipped(item, buddyState);
                return ActionChip(
                  label: Text(item.name),
                  avatar: isEquipped
                      ? Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 18)
                      : null,
                  backgroundColor: isEquipped
                      ? theme.colorScheme.primaryContainer
                      : null,
                  onPressed: () {
                    final notifier = ref.read(kitchenBuddyProvider.notifier);
                    if (isEquipped) {
                      notifier.unequipCategory(item.category);
                    } else {
                      notifier.equipItem(item.id);
                    }
                  },
                );
              }).toList(),
            ),
          ],
      ],
    );
  }

  bool _isEquipped(ShopItem item, KitchenBuddyState state) {
    final c = state.companion;
    if (c == null) return false;
    switch (item.category) {
      case ShopCategory.hats: return c.hatId == item.id;
      case ShopCategory.outfits: return c.outfitId == item.id;
      case ShopCategory.accessories: return c.accessoryId == item.id;
      case ShopCategory.backgrounds: return c.backgroundId == item.id;
      case ShopCategory.bodyColors: return c.bodyColorId == item.id;
    }
  }
}

// ══════════════════════════════════════════
//  SHOP TAB
// ══════════════════════════════════════════

class _ShopTab extends ConsumerWidget {
  final KitchenBuddyState buddyState;
  const _ShopTab({required this.buddyState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final coins = buddyState.wallet.spiceCoins;

    // Group by category, exclude already owned
    final shopItems = KitchenBuddyShop.all
        .where((item) => !buddyState.ownedItems.contains(item.id))
        .toList();

    if (shopItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 8),
            Text(l10n.kitchenBuddyShopOwnEverything, style: theme.textTheme.titleMedium),
            Text(l10n.kitchenBuddyShopCheckBack, style: theme.textTheme.bodySmall),
          ],
        ),
      );
    }

    final grouped = <ShopCategory, List<ShopItem>>{};
    for (final item in shopItems) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final category in ShopCategory.values)
          if (grouped.containsKey(category)) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                '${category.emoji} ${category.displayName}',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ...grouped[category]!.map((item) {
              final isLocked = item.requiredAchievementId != null &&
                  !buddyState.completedAchievements.contains(item.requiredAchievementId);
              final canAfford = coins >= item.price;

              return Card(
                child: ListTile(
                  leading: isLocked
                      ? const Icon(Icons.lock_outline, color: Colors.grey)
                      : Icon(Icons.shopping_bag, color: theme.colorScheme.primary),
                  title: Text(item.name),
                  subtitle: Text(
                    isLocked
                        ? l10n.kitchenBuddyRequires(KitchenBuddyAchievements.getById(item.requiredAchievementId!)?.name ?? 'Unknown')
                        : item.description,
                  ),
                  trailing: isLocked
                      ? null
                      : TextButton(
                          onPressed: canAfford
                              ? () => _confirmPurchase(context, ref, item)
                              : null,
                          child: Text('🪙 ${item.price}'),
                        ),
                ),
              );
            }),
          ],
      ],
    );
  }

  void _confirmPurchase(BuildContext context, WidgetRef ref, ShopItem item) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.kitchenBuddyConfirmPurchase(item.name)),
        content: Text(l10n.kitchenBuddyCostSummary(item.price)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(kitchenBuddyProvider.notifier).purchaseItem(item.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? l10n.kitchenBuddyPurchaseSuccess(item.name) : l10n.kitchenBuddyNotEnoughCoins),
                  ),
                );
              }
            },
            child: Text(l10n.kitchenBuddyBuy),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
//  ACHIEVEMENTS TAB
// ══════════════════════════════════════════

class _AchievementsTab extends StatelessWidget {
  final KitchenBuddyState buddyState;
  const _AchievementsTab({required this.buddyState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = KitchenBuddyAchievements.getVisible(buddyState.completedAchievements);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final ach = visible[index];
        final isCompleted = buddyState.completedAchievements.contains(ach.id);
        final progress = buddyState.achievementProgress[ach.id] ?? 0;
        final progressFraction = (progress / ach.targetValue).clamp(0.0, 1.0);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? ach.tier.color.withValues(alpha: 0.2)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(ach.icon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ach.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted ? TextDecoration.none : null,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ach.tier.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ach.tier.displayName,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: ach.tier.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ach.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progressFraction,
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                color: isCompleted
                                    ? ach.tier.color
                                    : theme.colorScheme.primary,
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCompleted ? '✓' : '$progress / ${ach.targetValue}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isCompleted ? ach.tier.color : null,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '🪙 ${ach.coinReward}',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
