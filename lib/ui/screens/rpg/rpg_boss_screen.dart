// lib/ui/screens/rpg/rpg_boss_screen.dart
// Boss Fight System for Recipe Spellbook RPG

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipespellbook/data/rpg/rpg_models.dart';
import 'package:recipespellbook/providers/rpg_provider.dart';

// ============ BOSS DEFINITIONS ============

class Boss {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int maxHp;
  final int currentHp;
  final Color color;
  final List<String> attacks;
  final int minLevel; // Minimum player level to fight

  const Boss({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.maxHp,
    required this.currentHp,
    required this.color,
    required this.attacks,
    required this.minLevel,
  });

  Boss copyWith({int? currentHp}) {
    return Boss(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      maxHp: maxHp,
      currentHp: currentHp ?? this.currentHp,
      color: color,
      attacks: attacks,
      minLevel: minLevel,
    );
  }

  double get hpPercent => currentHp / maxHp;
  bool get isDefeated => currentHp <= 0;
}

class BossData {
  static const List<Boss> weeklyBosses = [
    Boss(
      id: 'boss_burnt_toast',
      name: 'Burnt Toast Terror',
      description: 'A crispy menace that ruins breakfast!',
      emoji: '🍞',
      maxHp: 500,
      currentHp: 500,
      color: Color(0xFF8B4513),
      attacks: ['Smoke Cloud', 'Crumb Attack', 'Charred Slam'],
      minLevel: 1,
    ),
    Boss(
      id: 'boss_soupy_slime',
      name: 'Soupy Slime',
      description: 'A gelatinous glob of overcooked broth',
      emoji: '🍲',
      maxHp: 750,
      currentHp: 750,
      color: Color(0xFF2E7D32),
      attacks: ['Splash', 'Bubble Barrage', 'Steam Blast'],
      minLevel: 5,
    ),
    Boss(
      id: 'boss_pasta_phantom',
      name: 'Pasta Phantom',
      description: 'An ethereal entity of tangled noodles',
      emoji: '🍝',
      maxHp: 1000,
      currentHp: 1000,
      color: Color(0xFFFFD54F),
      attacks: ['Noodle Whip', 'Sauce Splash', 'Carb Coma'],
      minLevel: 10,
    ),
    Boss(
      id: 'boss_cake_golem',
      name: 'Cake Golem',
      description: 'A towering monster of frosting and fury',
      emoji: '🎂',
      maxHp: 1500,
      currentHp: 1500,
      color: Color(0xFFE91E63),
      attacks: ['Frosting Fist', 'Sugar Rush', 'Layer Slam'],
      minLevel: 15,
    ),
    Boss(
      id: 'boss_pizza_dragon',
      name: 'Pizza Dragon',
      description: 'The legendary beast of melted cheese',
      emoji: '🐉',
      maxHp: 2500,
      currentHp: 2500,
      color: Color(0xFFFF5722),
      attacks: ['Cheese Breath', 'Pepperoni Barrage', 'Crust Crush'],
      minLevel: 25,
    ),
    Boss(
      id: 'boss_final_feast',
      name: 'The Final Feast',
      description: 'Ultimate culinary chaos incarnate',
      emoji: '👹',
      maxHp: 5000,
      currentHp: 5000,
      color: Color(0xFF9C27B0),
      attacks: ['Flavor Explosion', 'Kitchen Sink', 'Grand Finale'],
      minLevel: 50,
    ),
  ];

  static Boss getCurrentWeeklyBoss() {
    // Rotate boss based on week of year
    final weekOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays ~/ 7;
    return weeklyBosses[weekOfYear % weeklyBosses.length];
  }
}

// ============ BOSS FIGHT SCREEN ============

class RpgBossScreen extends ConsumerStatefulWidget {
  const RpgBossScreen({super.key});

  @override
  ConsumerState<RpgBossScreen> createState() => _RpgBossScreenState();
}

class _RpgBossScreenState extends ConsumerState<RpgBossScreen>
    with SingleTickerProviderStateMixin {
  late Boss _currentBoss;
  bool _isAttacking = false;
  int? _lastDamage;
  String? _bossAttack;
  final List<_DamageNumber> _damageNumbers = [];
  late AnimationController _shakeController;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _currentBoss = BossData.getCurrentWeeklyBoss();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _attack() async {
    final profile = ref.read(rpgProvider).profile;

    if (profile.mana < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough mana! Wait for it to regenerate.')),
      );
      return;
    }

    if (_isAttacking) return;

    setState(() => _isAttacking = true);
    HapticFeedback.mediumImpact();

    // Calculate damage
    final baseDamage = 10;
    final levelBonus = _random.nextInt(profile.level * 5);
    final critChance = _random.nextDouble();
    final isCrit = critChance < 0.1; // 10% crit chance
    final damage = (baseDamage + levelBonus) * (isCrit ? 2 : 1);

    // Spend mana and deal damage
    await ref.read(rpgProvider.notifier).attackBoss();

    // Add floating damage number
    setState(() {
      _lastDamage = damage;
      _damageNumbers.add(_DamageNumber(
        damage: damage,
        isCrit: isCrit,
        x: 0.3 + _random.nextDouble() * 0.4,
        y: 0.3 + _random.nextDouble() * 0.2,
      ));
      _currentBoss = _currentBoss.copyWith(
        currentHp: (_currentBoss.currentHp - damage).clamp(0, _currentBoss.maxHp),
      );
    });

    // Shake animation
    _shakeController.forward(from: 0);

    // Boss counter-attack after delay
    await Future.delayed(const Duration(milliseconds: 300));

    if (_currentBoss.currentHp > 0) {
      setState(() {
        _bossAttack = _currentBoss.attacks[_random.nextInt(_currentBoss.attacks.length)];
      });
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _bossAttack = null);
    } else {
      // Boss defeated!
      _showVictoryDialog();
    }

    // Clear damage numbers after animation
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _damageNumbers.removeWhere((d) => d.damage == damage);
      _isAttacking = false;
    });
  }

  void _showVictoryDialog() {
    final goldReward = 50 + (_currentBoss.maxHp ~/ 10);
    final xpReward = 100 + (_currentBoss.maxHp ~/ 5);

    // Award rewards
    ref.read(rpgProvider.notifier).awardGold(goldReward);
    ref.read(rpgProvider.notifier).awardXp(
      XpActionType.achievementUnlocked,
      multiplier: xpReward ~/ 50,
      description: 'Defeated ${_currentBoss.name}!',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Text('🎉 '),
            const Text('Victory!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You defeated ${_currentBoss.name}!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(_currentBoss.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber),
                Text(' +$goldReward Gold'),
                const SizedBox(width: 16),
                const Text('✨'),
                Text(' +$xpReward XP'),
              ],
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Reset boss for next fight
              setState(() {
                _currentBoss = BossData.getCurrentWeeklyBoss();
              });
            },
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(rpgProvider).profile;
    final playerLevel = profile.level;
    final canFight = playerLevel >= _currentBoss.minLevel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚔️ Boss Fight'),
        actions: [
          // Mana display
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${profile.mana}/${profile.maxMana}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Boss selection tabs
          _BossSelector(
            bosses: BossData.weeklyBosses,
            selectedBoss: _currentBoss,
            playerLevel: playerLevel,
            onSelect: (boss) {
              if (playerLevel >= boss.minLevel) {
                setState(() => _currentBoss = boss);
              }
            },
          ),

          Expanded(
            child: canFight
                ? _buildBattleArea(theme, profile)
                : _buildLockedArea(theme),
          ),

          // Attack button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Mana bar
                  _ManaBar(current: profile.mana, max: profile.maxMana),
                  const SizedBox(height: 12),

                  // Attack button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: canFight && profile.mana >= 10 && !_isAttacking
                          ? _attack
                          : null,
                      icon: const Icon(Icons.flash_on, size: 28),
                      label: Text(
                        canFight
                            ? 'Attack! (10 Mana)'
                            : 'Level ${_currentBoss.minLevel} Required',
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: _currentBoss.color,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Mana regenerates over time',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleArea(ThemeData theme, PlayerProfile profile) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shakeOffset = sin(_shakeController.value * pi * 8) *
            (1 - _shakeController.value) * 10;

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _currentBoss.color.withOpacity(0.1),
                  theme.colorScheme.surface,
                ],
              ),
            ),
          ),

          // Boss display
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Boss name and level
                Text(
                  _currentBoss.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _currentBoss.color,
                  ),
                ),
                Text(
                  _currentBoss.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 24),

                // Boss emoji
                AnimatedScale(
                  scale: _isAttacking ? 0.9 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Text(
                    _currentBoss.emoji,
                    style: const TextStyle(fontSize: 120),
                  ),
                ),

                // Boss attack indicator
                if (_bossAttack != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '💥 $_bossAttack!',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // HP bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'HP',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_currentBoss.currentHp} / ${_currentBoss.maxHp}',
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _currentBoss.hpPercent,
                          minHeight: 20,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            _currentBoss.hpPercent > 0.5
                                ? Colors.green
                                : _currentBoss.hpPercent > 0.25
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Last damage display
                if (_lastDamage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '-$_lastDamage',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Floating damage numbers
          ..._damageNumbers.map((dn) => Positioned(
            left: MediaQuery.of(context).size.width * dn.x,
            top: MediaQuery.of(context).size.height * dn.y * 0.5,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -50 * value),
                  child: Opacity(
                    opacity: 1 - value,
                    child: Text(
                      '-${dn.damage}${dn.isCrit ? '!' : ''}',
                      style: TextStyle(
                        fontSize: dn.isCrit ? 32 : 24,
                        fontWeight: FontWeight.bold,
                        color: dn.isCrit ? Colors.orange : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLockedArea(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Level ${_currentBoss.minLevel} Required',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep earning XP to unlock this boss!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _currentBoss.emoji,
            style: TextStyle(
              fontSize: 80,
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ HELPER WIDGETS ============

class _DamageNumber {
  final int damage;
  final bool isCrit;
  final double x;
  final double y;

  _DamageNumber({
    required this.damage,
    required this.isCrit,
    required this.x,
    required this.y,
  });
}

class _BossSelector extends StatelessWidget {
  final List<Boss> bosses;
  final Boss selectedBoss;
  final int playerLevel;
  final Function(Boss) onSelect;

  const _BossSelector({
    required this.bosses,
    required this.selectedBoss,
    required this.playerLevel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: bosses.length,
        itemBuilder: (context, index) {
          final boss = bosses[index];
          final isSelected = boss.id == selectedBoss.id;
          final isLocked = playerLevel < boss.minLevel;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(boss),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                decoration: BoxDecoration(
                  color: isSelected
                      ? boss.color.withOpacity(0.2)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? boss.color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      boss.emoji,
                      style: TextStyle(
                        fontSize: 32,
                        color: isLocked ? Colors.grey : null,
                      ),
                    ),
                    if (isLocked)
                      Positioned(
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Lv${boss.minLevel}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ManaBar extends StatelessWidget {
  final int current;
  final int max;

  const _ManaBar({required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = current / max;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text('Mana', style: theme.textTheme.labelMedium),
              ],
            ),
            Text('$current / $max', style: theme.textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: const AlwaysStoppedAnimation(Colors.blue),
          ),
        ),
      ],
    );
  }
}