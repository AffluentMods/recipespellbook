// lib/ui/screens/rpg/rpg_cosmetics_screen.dart
// Cosmetics shop and customization for Recipe Spellbook RPG System

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/rpg/rpg_models.dart';
import '../../../data/rpg/rpg_cosmetics.dart';
import '../../../providers/rpg_provider.dart';
import '../../../../ui/widgets/rpg/rpg_widgets.dart';

class RpgCosmeticsScreen extends ConsumerStatefulWidget {
  const RpgCosmeticsScreen({super.key});

  @override
  ConsumerState<RpgCosmeticsScreen> createState() => _RpgCosmeticsScreenState();
}

class _RpgCosmeticsScreenState extends ConsumerState<RpgCosmeticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('🎨 Cosmetics'),
        actions: [
          // Currency display
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: RpgCurrencyDisplay(compact: true),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Avatars'),
            Tab(icon: Icon(Icons.filter_frames), text: 'Frames'),
            Tab(icon: Icon(Icons.pets), text: 'Pets'),
            Tab(icon: Icon(Icons.badge), text: 'Titles'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Preview section
          _buildPreviewSection(context, profile, theme),
          // Shop tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAvatarTab(context, profile, theme),
                _buildFrameTab(context, profile, theme),
                _buildPetTab(context, profile, theme),
                _buildTitleTab(context, profile, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(
      BuildContext context,
      PlayerProfile profile,
      ThemeData theme,
      ) {
    final themeColor = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: _StarfieldPainter(baseColor: themeColor),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.9,
                colors: [
                  themeColor.withValues(alpha: 0.18),
                  themeColor.withValues(alpha: 0.08),
                  theme.colorScheme.surface.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: Column(
              children: [
                // Avatar with frame
                RpgAvatarWidget(
                  avatarId: profile.avatarId ?? 'avatar_default',
                  frameId: profile.frameId ?? 'frame_default',
                  petId: profile.petId,
                  size: 100,
                  level: profile.level,
                ),
                const SizedBox(height: 14),
                Text(
                  profile.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.displayTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: themeColor.withValues(alpha: 0.85),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarTab(
      BuildContext context,
      PlayerProfile profile,
      ThemeData theme,
      ) {
    final avatars = RpgAvatars.all;
    final ownedIds = profile.unlockedAvatars.toSet();
    final equippedId = profile.avatarId ?? 'avatar_default';

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final avatar = avatars[index];
        final isOwned = ownedIds.contains(avatar.id);
        final isEquipped = avatar.id == equippedId;
        final canPurchase = !isOwned && avatar.isPurchasable &&
            profile.gold >= (avatar.price ?? 0);

        return _CosmeticCard(
          item: avatar,
          isOwned: isOwned,
          isEquipped: isEquipped,
          canPurchase: canPurchase,
          onTap: () => _handleCosmeticTap(
            context, avatar, isOwned, isEquipped, profile,
          ),
        );
      },
    );
  }

  Widget _buildFrameTab(
      BuildContext context,
      PlayerProfile profile,
      ThemeData theme,
      ) {
    final frames = RpgFrames.all;
    final ownedIds = profile.unlockedFrames.toSet();
    final equippedId = profile.frameId ?? 'frame_default';

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: frames.length,
      itemBuilder: (context, index) {
        final frame = frames[index];
        final isOwned = ownedIds.contains(frame.id);
        final isEquipped = frame.id == equippedId;
        final canPurchase = !isOwned && frame.isPurchasable &&
            profile.gold >= (frame.price ?? 0);

        return _CosmeticCard(
          item: frame,
          isOwned: isOwned,
          isEquipped: isEquipped,
          canPurchase: canPurchase,
          onTap: () => _handleCosmeticTap(
            context, frame, isOwned, isEquipped, profile,
          ),
        );
      },
    );
  }

  Widget _buildPetTab(
      BuildContext context,
      PlayerProfile profile,
      ThemeData theme,
      ) {
    final pets = RpgPets.all;
    final ownedIds = profile.unlockedPets.toSet();
    final equippedId = profile.petId;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        final isOwned = ownedIds.contains(pet.id);
        final isEquipped = pet.id == equippedId;
        final canPurchase = !isOwned && pet.isPurchasable &&
            profile.gems >= (pet.price ?? 0);

        return _CosmeticCard(
          item: pet,
          isOwned: isOwned,
          isEquipped: isEquipped,
          canPurchase: canPurchase,
          onTap: () => _handleCosmeticTap(
            context, pet, isOwned, isEquipped, profile,
          ),
        );
      },
    );
  }

  Widget _buildTitleTab(
      BuildContext context,
      PlayerProfile profile,
      ThemeData theme,
      ) {
    final titles = RpgTitle.allTitles;
    final ownedIds = profile.unlockedTitles.toSet();
    final equippedId = profile.titleId ?? 'title_apprentice';

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: titles.length,
      itemBuilder: (context, index) {
        final title = titles[index];
        final isOwned = ownedIds.contains(title.id);
        final isEquipped = title.id == equippedId;

        return _TitleCard(
          title: title,
          isOwned: isOwned,
          isEquipped: isEquipped,
          completedAchievements: profile.completedAchievements.toSet(),
          onTap: isOwned
              ? () {
            ref.read(rpgProvider.notifier).equipTitle(title.id);
          }
              : null,
        );
      },
    );
  }

  void _handleCosmeticTap(
      BuildContext context,
      CosmeticItem item,
      bool isOwned,
      bool isEquipped,
      PlayerProfile profile,
      ) {
    if (isOwned) {
      // Equip/unequip
      if (isEquipped) {
        // Can't unequip default items
        if (item.id.contains('default')) return;
        // Unequip
        switch (item.type) {
          case CosmeticType.avatar:
            ref.read(rpgProvider.notifier).equipAvatar('avatar_default');
            break;
          case CosmeticType.frame:
            ref.read(rpgProvider.notifier).equipFrame('frame_default');
            break;
          case CosmeticType.pet:
            ref.read(rpgProvider.notifier).equipPet(null);
            break;
          case CosmeticType.title:
            ref.read(rpgProvider.notifier).equipTitle('title_apprentice');
            break;
        }
      } else {
        // Equip
        switch (item.type) {
          case CosmeticType.avatar:
            ref.read(rpgProvider.notifier).equipAvatar(item.id);
            break;
          case CosmeticType.frame:
            ref.read(rpgProvider.notifier).equipFrame(item.id);
            break;
          case CosmeticType.pet:
            ref.read(rpgProvider.notifier).equipPet(item.id);
            break;
          case CosmeticType.title:
            ref.read(rpgProvider.notifier).equipTitle(item.id);
            break;
        }
      }
    } else {
      // Show purchase dialog
      _showPurchaseDialog(context, item, profile);
    }
  }

  void _showPurchaseDialog(
      BuildContext context,
      CosmeticItem item,
      PlayerProfile profile,
      ) {
    final theme = Theme.of(context);
    final canAfford = item.currency == CurrencyType.gold
        ? profile.gold >= (item.price ?? 0)
        : profile.gems >= (item.price ?? 0);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Purchase ${item.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Item preview
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.rarity.color.withValues(alpha: 0.2),
                border: Border.all(color: item.rarity.color, width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  item.assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    _getIconForType(item.type),
                    size: 40,
                    color: item.rarity.color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(item.description),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: item.rarity.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.rarity.displayName,
                style: TextStyle(
                  color: item.rarity.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Price
            if (!item.isPurchasable)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Unlocked via achievement',
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Price: ', style: theme.textTheme.titleMedium),
                  Icon(
                    item.currency == CurrencyType.gold
                        ? Icons.monetization_on
                        : Icons.diamond,
                    color: item.currency == CurrencyType.gold
                        ? Colors.amber
                        : Colors.purple,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.price}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: item.currency == CurrencyType.gold
                          ? Colors.amber
                          : Colors.purple,
                    ),
                  ),
                ],
              ),
            if (item.isPurchasable && !canAfford) ...[
              const SizedBox(height: 8),
              Text(
                'Not enough ${item.currency == CurrencyType.gold ? "gold" : "gems"}!',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          if (item.isPurchasable)
            FilledButton(
              onPressed: canAfford
                  ? () async {
                Navigator.pop(ctx);
                final success = item.currency == CurrencyType.gold
                    ? await ref.read(rpgProvider.notifier)
                    .purchaseWithGold(item)
                    : await ref.read(rpgProvider.notifier)
                    .purchaseWithGems(item);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Purchased ${item.name}!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
                  : null,
              child: const Text('Purchase'),
            ),
        ],
      ),
    );
  }

  IconData _getIconForType(CosmeticType type) {
    switch (type) {
      case CosmeticType.avatar: return Icons.person;
      case CosmeticType.frame: return Icons.filter_frames;
      case CosmeticType.pet: return Icons.pets;
      case CosmeticType.title: return Icons.badge;
    }
  }
}

// ============ COSMETIC CARD ============

class _CosmeticCard extends StatelessWidget {
  final CosmeticItem item;
  final bool isOwned;
  final bool isEquipped;
  final bool canPurchase;
  final VoidCallback onTap;

  const _CosmeticCard({
    required this.item,
    required this.isOwned,
    required this.isEquipped,
    required this.canPurchase,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: isEquipped
          ? item.rarity.color.withValues(alpha: 0.2)
          : null,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              children: [
                // Image area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      border: isEquipped
                          ? Border(
                        bottom: BorderSide(
                          color: item.rarity.color,
                          width: 3,
                        ),
                      )
                          : null,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Always try to show the actual image
                        Image.asset(
                          item.assetPath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              _getIcon(),
                              size: 40,
                              color: isOwned ? item.rarity.color : theme.colorScheme.outline.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        // Dark overlay + lock for items not yet owned
                        if (!isOwned) ...[
                          Container(color: Colors.black.withValues(alpha: 0.5)),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lock_outline,
                                size: 20,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Info area
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      if (isOwned)
                        Text(
                          isEquipped ? 'Equipped' : 'Owned',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isEquipped
                                ? item.rarity.color
                                : theme.colorScheme.outline,
                          ),
                        )
                      else if (item.isPurchasable)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.currency == CurrencyType.gold
                                  ? Icons.monetization_on
                                  : Icons.diamond,
                              size: 12,
                              color: item.currency == CurrencyType.gold
                                  ? Colors.amber
                                  : Colors.purple,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${item.price}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: canPurchase
                                    ? null
                                    : theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        )
                      else
                        Icon(
                          Icons.emoji_events,
                          size: 14,
                          color: Colors.amber,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Rarity indicator
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.rarity.color,
                  boxShadow: [
                    BoxShadow(
                      color: item.rarity.color.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            // Equipped checkmark
            if (isEquipped)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (item.type) {
      case CosmeticType.avatar: return Icons.person;
      case CosmeticType.frame: return Icons.filter_frames;
      case CosmeticType.pet: return Icons.pets;
      case CosmeticType.title: return Icons.badge;
    }
  }
}

// ============ TITLE CARD ============

class _TitleCard extends StatelessWidget {
  final RpgTitle title;
  final bool isOwned;
  final bool isEquipped;
  final Set<String> completedAchievements;
  final VoidCallback? onTap;

  const _TitleCard({
    required this.title,
    required this.isOwned,
    required this.isEquipped,
    required this.completedAchievements,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = title.achievementId != null &&
        !completedAchievements.contains(title.achievementId);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isEquipped ? title.rarity.color.withValues(alpha: 0.2) : null,
      child: ListTile(
        enabled: isOwned,
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: title.rarity.color.withValues(alpha: 0.2),
            border: Border.all(
              color: isOwned ? title.rarity.color : Colors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: isLocked
                ? const Icon(Icons.lock, color: Colors.grey)
                : const Icon(Icons.badge),
          ),
        ),
        title: Text(
          title.displayName,
          style: TextStyle(
            fontWeight: isEquipped ? FontWeight.bold : null,
            color: isOwned ? null : theme.colorScheme.outline,
          ),
        ),
        subtitle: Text(
          title.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        trailing: isEquipped
            ? Chip(
          label: const Text('Equipped'),
          backgroundColor: title.rarity.color.withValues(alpha: 0.3),
        )
            : isLocked
            ? const Icon(Icons.emoji_events, color: Colors.amber)
            : isOwned
            ? const Icon(Icons.chevron_right)
            : null,
      ),
    );
  }
}

// ============ STARFIELD BACKGROUND PAINTER ============

class _StarfieldPainter extends CustomPainter {
  final Color baseColor;
  _StarfieldPainter({required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42); // Fixed seed for consistent stars
    final paint = Paint();

    for (int i = 0; i < 40; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final radius = 0.5 + rng.nextDouble() * 2.0;
      final opacity = 0.15 + rng.nextDouble() * 0.35;

      // Alternate between white and theme-colored stars
      final isColored = rng.nextDouble() > 0.45;
      paint.color = isColored
          ? baseColor.withValues(alpha: opacity)
          : Colors.white.withValues(alpha: opacity * 0.6);

      canvas.drawCircle(Offset(x, y), radius, paint);

      // Occasional larger glow
      if (rng.nextDouble() > 0.82) {
        paint.color = baseColor.withValues(alpha: opacity * 0.25);
        canvas.drawCircle(Offset(x, y), radius * 3.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}