// lib/ui/screens/rpg/rpg_boss_screen.dart
// Boss Fight System for Recipe Spellbook RPG

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipespellbook/data/rpg/rpg_models.dart';
import 'package:recipespellbook/providers/rpg_provider.dart';

// ============ ENEMY DEFINITIONS ============

class Enemy {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int maxHp;
  final int currentHp;
  final Color color;
  final List<String> attacks;
  final int minLevel;
  final bool isBoss;
  final int goldReward;
  final int xpReward;

  const Enemy({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.maxHp,
    required this.currentHp,
    required this.color,
    required this.attacks,
    required this.minLevel,
    this.isBoss = false,
    required this.goldReward,
    required this.xpReward,
  });

  Enemy copyWith({int? currentHp}) {
    return Enemy(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      maxHp: maxHp,
      currentHp: currentHp ?? this.currentHp,
      color: color,
      attacks: attacks,
      minLevel: minLevel,
      isBoss: isBoss,
      goldReward: goldReward,
      xpReward: xpReward,
    );
  }

  double get hpPercent => maxHp > 0 ? (currentHp / maxHp).clamp(0.0, 1.0) : 0.0;
  bool get isDefeated => currentHp <= 0;
}

class EnemyData {
  static List<Enemy> get allEnemies => [
    // ---- SMALL ENEMIES (beatable at level 1) ----
    const Enemy(
      id: 'enemy_runaway_muffin',
      name: 'Runaway Muffin',
      description: 'A pastry with tiny legs that won\'t stay on the plate!',
      emoji: '🧁',
      maxHp: 100,
      currentHp: 100,
      color: Color(0xFFFF8A65),
      attacks: ['Crumb Toss', 'Sugar Rush'],
      minLevel: 1,
      goldReward: 10,
      xpReward: 25,
    ),
    const Enemy(
      id: 'enemy_stale_cracker',
      name: 'Stale Cracker',
      description: 'Crunchy, unpleasant, and surprisingly hostile.',
      emoji: '🍘',
      maxHp: 150,
      currentHp: 150,
      color: Color(0xFFBCAAA4),
      attacks: ['Crunch', 'Stale Slap'],
      minLevel: 1,
      goldReward: 15,
      xpReward: 35,
    ),
    const Enemy(
      id: 'enemy_angry_egg',
      name: 'Angry Egg',
      description: 'Don\'t let the shell fool you — it\'s furious inside.',
      emoji: '🥚',
      maxHp: 200,
      currentHp: 200,
      color: Color(0xFFFFF9C4),
      attacks: ['Egg Toss', 'Shell Slam', 'Yolk Splash'],
      minLevel: 1,
      goldReward: 20,
      xpReward: 50,
    ),

    // ---- BOSSES ----
    const Enemy(
      id: 'boss_burnt_toast',
      name: 'Burnt Toast Terror',
      description: 'A crispy menace that ruins breakfast!',
      emoji: '🍞',
      maxHp: 500,
      currentHp: 500,
      color: Color(0xFF8B4513),
      attacks: ['Smoke Cloud', 'Crumb Attack', 'Charred Slam'],
      minLevel: 1,
      isBoss: true,
      goldReward: 50,
      xpReward: 100,
    ),
    const Enemy(
      id: 'boss_soupy_slime',
      name: 'Soupy Slime',
      description: 'A gelatinous glob of overcooked broth',
      emoji: '🍲',
      maxHp: 750,
      currentHp: 750,
      color: Color(0xFF2E7D32),
      attacks: ['Splash', 'Bubble Barrage', 'Steam Blast'],
      minLevel: 5,
      isBoss: true,
      goldReward: 75,
      xpReward: 150,
    ),
    const Enemy(
      id: 'boss_pasta_phantom',
      name: 'Pasta Phantom',
      description: 'An ethereal entity of tangled noodles',
      emoji: '🍝',
      maxHp: 1000,
      currentHp: 1000,
      color: Color(0xFFFFD54F),
      attacks: ['Noodle Whip', 'Sauce Splash', 'Carb Coma'],
      minLevel: 10,
      isBoss: true,
      goldReward: 100,
      xpReward: 200,
    ),
    const Enemy(
      id: 'boss_cake_golem',
      name: 'Cake Golem',
      description: 'A towering monster of frosting and fury',
      emoji: '🎂',
      maxHp: 1500,
      currentHp: 1500,
      color: Color(0xFFE91E63),
      attacks: ['Frosting Fist', 'Sugar Rush', 'Layer Slam'],
      minLevel: 15,
      isBoss: true,
      goldReward: 150,
      xpReward: 300,
    ),
    const Enemy(
      id: 'boss_pizza_dragon',
      name: 'Pizza Dragon',
      description: 'The legendary beast of melted cheese',
      emoji: '🐉',
      maxHp: 2500,
      currentHp: 2500,
      color: Color(0xFFFF5722),
      attacks: ['Cheese Breath', 'Pepperoni Barrage', 'Crust Crush'],
      minLevel: 25,
      isBoss: true,
      goldReward: 250,
      xpReward: 500,
    ),
    const Enemy(
      id: 'boss_final_feast',
      name: 'The Final Feast',
      description: 'Ultimate culinary chaos incarnate',
      emoji: '👹',
      maxHp: 5000,
      currentHp: 5000,
      color: Color(0xFF9C27B0),
      attacks: ['Flavor Explosion', 'Kitchen Sink', 'Grand Finale'],
      minLevel: 50,
      isBoss: true,
      goldReward: 500,
      xpReward: 1000,
    ),
  ];

  /// Get the best starting enemy for a player's level
  static Enemy getDefaultEnemy(int playerLevel) {
    final unlocked = allEnemies.where((e) => playerLevel >= e.minLevel).toList();
    // Pick the first small enemy, or the first boss if none
    final smallEnemies = unlocked.where((e) => !e.isBoss).toList();
    if (smallEnemies.isNotEmpty) return smallEnemies.first;
    return unlocked.isNotEmpty ? unlocked.first : allEnemies.first;
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
  late Enemy _currentEnemy;
  int? _lastDamage;
  bool _lastWasCrit = false;
  String? _bossAttack;
  final List<_DamageNumber> _damageNumbers = [];
  late AnimationController _shakeController;
  final _random = Random();
  int _killCount = 0;

  @override
  void initState() {
    super.initState();
    final level = ref.read(rpgProvider).profile.level;
    _currentEnemy = EnemyData.getDefaultEnemy(level);
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _attack() async {
    if (_currentEnemy.isDefeated) return;

    final profile = ref.read(rpgProvider).profile;
    if (profile.mana < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not enough mana! Earn XP from recipes to regenerate.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();

    // Call provider to deduct mana and calculate damage
    final result = await ref.read(rpgProvider.notifier).attackBoss();

    if (!result.success) return;

    final damage = result.damage;
    final isCrit = result.isCrit;

    // Add floating damage number
    setState(() {
      _lastDamage = damage;
      _lastWasCrit = isCrit;
      _damageNumbers.add(_DamageNumber(
        damage: damage,
        isCrit: isCrit,
        x: 0.25 + _random.nextDouble() * 0.5,
        y: 0.25 + _random.nextDouble() * 0.25,
        createdAt: DateTime.now(),
      ));
      _currentEnemy = _currentEnemy.copyWith(
        currentHp: (_currentEnemy.currentHp - damage).clamp(0, _currentEnemy.maxHp),
      );
    });

    // Shake animation (quick)
    _shakeController.forward(from: 0);

    // Boss counter-attack text (brief flash, doesn't block)
    if (_currentEnemy.currentHp > 0 && _random.nextDouble() < 0.3) {
      setState(() {
        _bossAttack = _currentEnemy.attacks[_random.nextInt(_currentEnemy.attacks.length)];
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _bossAttack = null);
      });
    }

    // Check for defeat
    if (_currentEnemy.isDefeated) {
      _killCount++;
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _showVictoryDialog();
      });
    }

    // Clean up old damage numbers (non-blocking)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _damageNumbers.removeWhere((d) =>
          DateTime.now().difference(d.createdAt).inMilliseconds > 700);
        });
      }
    });
  }

  void _showVictoryDialog() {
    final goldReward = _currentEnemy.goldReward;
    final xpReward = _currentEnemy.xpReward;

    // Award rewards - defeatEnemy gives base 25 XP * multiplier
    ref.read(rpgProvider.notifier).awardGold(goldReward);
    ref.read(rpgProvider.notifier).awardXp(
      XpActionType.defeatEnemy,
      multiplier: (xpReward / 25).ceil().clamp(1, 100),
      description: 'Defeated ${_currentEnemy.name}!',
    );

    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Text('🎉 '),
            Expanded(child: Text(_currentEnemy.isBoss ? 'Boss Defeated!' : 'Victory!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You defeated ${_currentEnemy.name}!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(_currentEnemy.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                Text(' +$goldReward Gold', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                const Text('✨', style: TextStyle(fontSize: 16)),
                Text(' +$xpReward XP', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (_killCount > 1) ...[
              const SizedBox(height: 8),
              Text(
                'Kill streak: $_killCount 🔥',
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _currentEnemy = _currentEnemy.copyWith(currentHp: _currentEnemy.maxHp);
                _lastDamage = null;
                _damageNumbers.clear();
              });
            },
            child: const Text('Fight Again'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _currentEnemy = _currentEnemy.copyWith(currentHp: _currentEnemy.maxHp);
                _lastDamage = null;
                _damageNumbers.clear();
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
    final canFight = playerLevel >= _currentEnemy.minLevel;
    final maxMana = PlayerProfile.maxManaForLevel(playerLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚔️ Battle Arena'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${profile.mana}/$maxMana',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: profile.mana < 10 ? Colors.red : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Enemy selection tabs
          _EnemySelector(
            enemies: EnemyData.allEnemies,
            selectedEnemy: _currentEnemy,
            playerLevel: playerLevel,
            onSelect: (enemy) {
              if (playerLevel >= enemy.minLevel) {
                setState(() {
                  _currentEnemy = enemy;
                  _lastDamage = null;
                  _damageNumbers.clear();
                  _bossAttack = null;
                });
              }
            },
          ),

          Expanded(
            child: canFight
                ? _buildBattleArea(theme, profile)
                : _buildLockedArea(theme),
          ),

          // Attack controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _ManaBar(current: profile.mana, max: maxMana),
                  const SizedBox(height: 8),

                  // Level stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatChip(
                        icon: Icons.flash_on,
                        label: 'DMG',
                        value: '${playerLevel}x',
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        icon: Icons.auto_awesome,
                        label: 'Mana',
                        value: '$maxMana',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        icon: Icons.military_tech,
                        label: 'Level',
                        value: '$playerLevel',
                        color: Colors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Attack button - NO _isAttacking guard, spam allowed!
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: canFight && profile.mana >= 10 && !_currentEnemy.isDefeated
                          ? _attack
                          : null,
                      icon: const Icon(Icons.flash_on, size: 28),
                      label: Text(
                        canFight
                            ? profile.mana < 10
                            ? 'No Mana!'
                            : 'Attack! (10 Mana)'
                            : 'Level ${_currentEnemy.minLevel} Required',
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: canFight && profile.mana >= 10
                            ? _currentEnemy.color
                            : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    'Earn XP from recipes to regenerate mana • Level up for full refill',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _currentEnemy.color.withValues(alpha: 0.1),
                  theme.colorScheme.surface,
                ],
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Enemy name and type badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentEnemy.isBoss)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                        ),
                        child: const Text('BOSS', style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red,
                        )),
                      ),
                    Flexible(
                      child: Text(
                        _currentEnemy.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _currentEnemy.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  _currentEnemy.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                AnimatedScale(
                  scale: _shakeController.isAnimating ? 0.92 : 1.0,
                  duration: const Duration(milliseconds: 80),
                  child: Text(
                    _currentEnemy.emoji,
                    style: TextStyle(
                      fontSize: _currentEnemy.isBoss ? 120 : 100,
                    ),
                  ),
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: _bossAttack != null
                      ? Container(
                    key: ValueKey(_bossAttack),
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '💥 $_bossAttack!',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      : const SizedBox(key: ValueKey('empty'), height: 40),
                ),

                const SizedBox(height: 16),

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
                            '${_currentEnemy.currentHp} / ${_currentEnemy.maxHp}',
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _currentEnemy.hpPercent,
                          minHeight: 20,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            _currentEnemy.hpPercent > 0.5
                                ? Colors.green
                                : _currentEnemy.hpPercent > 0.25
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_lastDamage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '-$_lastDamage${_lastWasCrit ? ' CRIT!' : ''}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: _lastWasCrit ? Colors.orange : Colors.red,
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
              key: ValueKey(dn.createdAt.microsecondsSinceEpoch),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -50 * value),
                  child: Opacity(
                    opacity: (1 - value).clamp(0.0, 1.0),
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
          Icon(Icons.lock, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Level ${_currentEnemy.minLevel} Required',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep earning XP to unlock this ${_currentEnemy.isBoss ? 'boss' : 'enemy'}!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          Opacity(
            opacity: 0.4,
            child: Text(_currentEnemy.emoji, style: const TextStyle(fontSize: 80)),
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
  final DateTime createdAt;

  _DamageNumber({
    required this.damage,
    required this.isCrit,
    required this.x,
    required this.y,
    required this.createdAt,
  });
}

class _EnemySelector extends StatelessWidget {
  final List<Enemy> enemies;
  final Enemy selectedEnemy;
  final int playerLevel;
  final Function(Enemy) onSelect;

  const _EnemySelector({
    required this.enemies,
    required this.selectedEnemy,
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
        itemCount: enemies.length,
        itemBuilder: (context, index) {
          final enemy = enemies[index];
          final isSelected = enemy.id == selectedEnemy.id;
          final isLocked = playerLevel < enemy.minLevel;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(enemy),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                decoration: BoxDecoration(
                  color: isSelected
                      ? enemy.color.withValues(alpha: 0.2)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? enemy.color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: isLocked ? 0.3 : 1.0,
                      child: Text(enemy.emoji, style: const TextStyle(fontSize: 28)),
                    ),
                    if (enemy.isBoss)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Opacity(
                          opacity: isLocked ? 0.3 : 1.0,
                          child: const Text('👑', style: TextStyle(fontSize: 10)),
                        ),
                      ),
                    if (isLocked)
                      Positioned(
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Lv${enemy.minLevel}',
                            style: const TextStyle(fontSize: 10, color: Colors.white),
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
    final percent = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

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
            Text(
              '$current / $max',
              style: theme.textTheme.labelMedium?.copyWith(
                color: current < 10 ? Colors.red : null,
                fontWeight: current < 10 ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              current < 10 ? Colors.red : Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}