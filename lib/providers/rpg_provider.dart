// lib/providers/rpg_provider.dart
// RPG State Management for Recipe Spellbook

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../data/rpg/rpg_models.dart';
import '../../../data/rpg/rpg_achievements.dart';
import '../../../data/rpg/rpg_cosmetics.dart';

// ============ RPG STATE ============

class RpgState {
  final PlayerProfile profile;
  final bool isEnabled;               // Master toggle for RPG mode
  final List<XpGainEvent> recentXpGains; // Recent XP gains for toast display
  final LevelUpEvent? pendingLevelUp;  // Pending level up notification
  final Achievement? pendingAchievement; // Pending achievement notification
  final bool isLoading;

  const RpgState({
    required this.profile,
    this.isEnabled = true,
    this.recentXpGains = const [],
    this.pendingLevelUp,
    this.pendingAchievement,
    this.isLoading = true,
  });

  RpgState copyWith({
    PlayerProfile? profile,
    bool? isEnabled,
    List<XpGainEvent>? recentXpGains,
    LevelUpEvent? pendingLevelUp,
    bool clearPendingLevelUp = false,
    Achievement? pendingAchievement,
    bool clearPendingAchievement = false,
    bool? isLoading,
  }) {
    return RpgState(
      profile: profile ?? this.profile,
      isEnabled: isEnabled ?? this.isEnabled,
      recentXpGains: recentXpGains ?? this.recentXpGains,
      pendingLevelUp: clearPendingLevelUp ? null : (pendingLevelUp ?? this.pendingLevelUp),
      pendingAchievement: clearPendingAchievement ? null : (pendingAchievement ?? this.pendingAchievement),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ============ RPG NOTIFIER ============

class RpgNotifier extends Notifier<RpgState> {
  static const _profileKey = 'rpg_profile';
  static const _enabledKey = 'rpg_enabled';

  @override
  RpgState build() {
    _loadState();
    return RpgState(
      profile: PlayerProfile.newPlayer(const Uuid().v4()),
      isLoading: true,
    );
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    final isEnabled = prefs.getBool(_enabledKey) ?? true;
    final profileJson = prefs.getString(_profileKey);

    PlayerProfile profile;
    if (profileJson != null) {
      try {
        profile = PlayerProfile.fromJson(jsonDecode(profileJson));
      } catch (_) {
        profile = PlayerProfile.newPlayer(const Uuid().v4());
      }
    } else {
      profile = PlayerProfile.newPlayer(const Uuid().v4());
    }

    // Check for daily login
    profile = await _checkDailyLogin(profile);

    // Passive mana regeneration: +10% every 6 minutes (full in 1 hour)
    profile = _applyPassiveManaRegen(profile);

    // Recalculate currentXp from totalXp (fixes negative XP from old formula)
    final correctLevel = PlayerProfile.calculateLevelFromXp(profile.totalXp);
    final correctCurrentXp = profile.totalXp - PlayerProfile.calculateXpForLevel(correctLevel);
    if (profile.level != correctLevel || profile.currentXp != correctCurrentXp) {
      profile = profile.copyWith(
        level: correctLevel,
        currentXp: correctCurrentXp,
      );
    }

    // Ensure maxMana matches level (in case of upgrade from old version)
    final correctMaxMana = PlayerProfile.maxManaForLevel(profile.level);
    if (profile.maxMana != correctMaxMana) {
      profile = profile.copyWith(
        maxMana: correctMaxMana,
        mana: profile.mana.clamp(0, correctMaxMana),
      );
    }

    // Migration: ensure frame_wooden is unlocked for all existing users
    if (!profile.unlockedFrames.contains('frame_wooden')) {
      profile = profile.copyWith(
        unlockedFrames: [...profile.unlockedFrames, 'frame_wooden'],
      );
    }

    state = state.copyWith(
      profile: profile,
      isEnabled: isEnabled,
      isLoading: false,
    );

    await _saveProfile();
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(state.profile.toJson()));
    await prefs.setBool(_enabledKey, state.isEnabled);
  }

  /// Check and update daily login streak
  Future<PlayerProfile> _checkDailyLogin(PlayerProfile profile) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (profile.lastLoginDate == null) {
      // First login ever
      return profile.copyWith(
        lastLoginDate: today,
        loginStreak: 1,
      );
    }

    final lastLogin = DateTime(
      profile.lastLoginDate!.year,
      profile.lastLoginDate!.month,
      profile.lastLoginDate!.day,
    );

    final daysSinceLastLogin = today.difference(lastLogin).inDays;

    if (daysSinceLastLogin == 0) {
      // Already logged in today
      return profile;
    } else if (daysSinceLastLogin == 1) {
      // Consecutive day - increase streak
      final newStreak = profile.loginStreak + 1;

      // Award daily login XP and streak bonus
      // This will be handled separately to show notifications
      return profile.copyWith(
        lastLoginDate: today,
        loginStreak: newStreak,
      );
    } else {
      // Streak broken
      return profile.copyWith(
        lastLoginDate: today,
        loginStreak: 1,
      );
    }
  }

  // ============ TOGGLE RPG MODE ============

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(isEnabled: enabled);
    await _saveProfile();
  }

  // ============ XP SYSTEM ============

  /// Award XP for an action
  Future<void> awardXp(XpActionType action, {int multiplier = 1, String? description}) async {
    // UI controls RPG access via nerdMode

    final profile = state.profile;
    final baseXp = action.baseXp * multiplier;
    final classMultiplier = profile.playerClass.bonusMultiplierFor(action);
    final totalXp = (baseXp * classMultiplier).round();

    final event = XpGainEvent.create(
      actionType: action,
      baseXp: baseXp,
      multiplier: classMultiplier,
      description: description,
    );

    // Add XP and check for level up
    final newTotalXp = profile.totalXp + totalXp;
    final newLevel = PlayerProfile.calculateLevelFromXp(newTotalXp);
    final previousLevel = profile.level;

    final newCurrentXp = newTotalXp - PlayerProfile.calculateXpForLevel(newLevel);

    var updatedProfile = profile.copyWith(
      totalXp: newTotalXp,
      level: newLevel,
      currentXp: newCurrentXp,
    );

    // Handle level up
    LevelUpEvent? levelUpEvent;
    if (newLevel > previousLevel) {
      final goldReward = LevelUpEvent.calculateGoldReward(newLevel);
      final newMaxMana = PlayerProfile.maxManaForLevel(newLevel);
      updatedProfile = updatedProfile.copyWith(
        gold: updatedProfile.gold + goldReward,
        maxMana: newMaxMana,
        mana: newMaxMana, // Full mana refill on level up!
      );

      levelUpEvent = LevelUpEvent(
        previousLevel: previousLevel,
        newLevel: newLevel,
        goldReward: goldReward,
      );
    }

    // Update recent XP gains (keep last 5)
    final recentGains = [event, ...state.recentXpGains.take(4)];

    state = state.copyWith(
      profile: updatedProfile,
      recentXpGains: recentGains,
      pendingLevelUp: levelUpEvent,
    );

    await _saveProfile();

    // Regenerate some mana when doing recipe actions (not from daily login/streak)
    if (action != XpActionType.dailyLogin &&
        action != XpActionType.streakBonus &&
        action != XpActionType.achievementUnlocked) {
      await regenerateMana(amount: 10);
    }

    // Check achievements
    await _checkAchievements();
  }

  /// Award daily login XP (called once per day)
  Future<void> awardDailyLoginXp() async {
    // UI controls RPG access via nerdMode

    final profile = state.profile;

    // Award base daily XP
    await awardXp(XpActionType.dailyLogin, description: 'Daily Login');

    // Award streak bonus if applicable
    if (profile.loginStreak > 1) {
      await awardXp(
        XpActionType.streakBonus,
        multiplier: profile.loginStreak,
        description: '${profile.loginStreak} Day Streak!',
      );
    }
  }

  // ============ CURRENCY SYSTEM ============

  /// Award gold
  Future<void> awardGold(int amount, {String? reason}) async {
    if (amount <= 0) return;

    state = state.copyWith(
      profile: state.profile.copyWith(
        gold: state.profile.gold + amount,
      ),
    );
    await _saveProfile();
  }

  /// Award gems (from achievements)
  Future<void> awardGems(int amount, {String? reason}) async {
    if (amount <= 0) return;

    state = state.copyWith(
      profile: state.profile.copyWith(
        gems: state.profile.gems + amount,
      ),
    );
    await _saveProfile();
  }

  /// Spend gold on a cosmetic
  Future<bool> purchaseWithGold(CosmeticItem item) async {
    // UI controls RPG access via nerdMode
    if (item.currency != CurrencyType.gold) return false;
    if (item.price == null || state.profile.gold < item.price!) return false;

    final profile = state.profile;
    List<String> updatedList;

    switch (item.type) {
      case CosmeticType.avatar:
        if (profile.unlockedAvatars.contains(item.id)) return false;
        updatedList = [...profile.unlockedAvatars, item.id];
        state = state.copyWith(
          profile: profile.copyWith(
            gold: profile.gold - item.price!,
            unlockedAvatars: updatedList,
          ),
        );
        break;
      case CosmeticType.frame:
        if (profile.unlockedFrames.contains(item.id)) return false;
        updatedList = [...profile.unlockedFrames, item.id];
        state = state.copyWith(
          profile: profile.copyWith(
            gold: profile.gold - item.price!,
            unlockedFrames: updatedList,
          ),
        );
        break;
      case CosmeticType.pet:
      // Pets are purchased with gems, not gold
        return false;
      case CosmeticType.title:
        if (profile.unlockedTitles.contains(item.id)) return false;
        updatedList = [...profile.unlockedTitles, item.id];
        state = state.copyWith(
          profile: profile.copyWith(
            gold: profile.gold - item.price!,
            unlockedTitles: updatedList,
          ),
        );
        break;
    }

    await _saveProfile();
    return true;
  }

  /// Spend gems on a pet or lottery
  Future<bool> purchaseWithGems(CosmeticItem item) async {
    // UI controls RPG access via nerdMode
    if (item.currency != CurrencyType.gems) return false;
    if (item.price == null || state.profile.gems < item.price!) return false;

    final profile = state.profile;

    if (item.type == CosmeticType.pet) {
      if (profile.unlockedPets.contains(item.id)) return false;
      final updatedList = [...profile.unlockedPets, item.id];
      state = state.copyWith(
        profile: profile.copyWith(
          gems: profile.gems - item.price!,
          unlockedPets: updatedList,
        ),
      );
    } else {
      return false;
    }

    await _saveProfile();
    return true;
  }

  // ============ LOTTERY SYSTEM ============

  /// Spin the gem lottery (costs gems)
  Future<LotteryResult> spinLottery({int cost = 10}) async {
    if (state.profile.gems < cost) {
      return LotteryResult(type: LotteryRewardType.nothing, amount: 0);
    }

    // Deduct gems
    state = state.copyWith(
      profile: state.profile.copyWith(
        gems: state.profile.gems - cost,
      ),
    );

    // Random result
    final random = Random();
    final roll = random.nextDouble() * 100;

    LotteryResult result;

    if (roll < 1) {
      // 1% chance - Rare pet!
      final rarePets = RpgPets.getLotteryPets();
      if (rarePets.isNotEmpty &&
          !state.profile.unlockedPets.contains(rarePets.first.id)) {
        state = state.copyWith(
          profile: state.profile.copyWith(
            unlockedPets: [...state.profile.unlockedPets, rarePets.first.id],
          ),
        );
        result = LotteryResult(
          type: LotteryRewardType.rarePet,
          amount: 1,
          petId: rarePets.first.id,
        );

        // Award achievement
        await _unlockAchievement('ach_lottery_win');
      } else {
        // Already have the pet, give gems instead
        result = LotteryResult(type: LotteryRewardType.gems, amount: 50);
      }
    } else if (roll < 10) {
      // 9% chance - Gems (5-25)
      final gems = 5 + random.nextInt(21);
      result = LotteryResult(type: LotteryRewardType.gems, amount: gems);
    } else if (roll < 35) {
      // 25% chance - Gold (50-200)
      final gold = 50 + random.nextInt(151);
      result = LotteryResult(type: LotteryRewardType.gold, amount: gold);
    } else if (roll < 70) {
      // 35% chance - XP (25-100)
      final xp = 25 + random.nextInt(76);
      result = LotteryResult(type: LotteryRewardType.xp, amount: xp);
    } else {
      // 30% chance - Small gold (10-30)
      final gold = 10 + random.nextInt(21);
      result = LotteryResult(type: LotteryRewardType.gold, amount: gold);
    }

    // Apply result
    switch (result.type) {
      case LotteryRewardType.xp:
        await awardXp(XpActionType.achievementUnlocked,
            multiplier: result.amount ~/ 25,
            description: 'Lottery Win!');
        break;
      case LotteryRewardType.gold:
        await awardGold(result.amount, reason: 'Lottery Win');
        break;
      case LotteryRewardType.gems:
        await awardGems(result.amount, reason: 'Lottery Win');
        break;
      case LotteryRewardType.rarePet:
      // Already handled above
        break;
      case LotteryRewardType.nothing:
        break;
    }

    await _saveProfile();
    return result;
  }

  // ============ MANA SYSTEM (Boss Attacks) ============

  /// Attack result record
  /// Spend mana to attack a boss - returns ({int damage, bool isCrit, bool success})
  Future<({int damage, bool isCrit, bool success})> attackBoss({int manaCost = 10}) async {
    if (state.profile.mana < manaCost) return (damage: 0, isCrit: false, success: false);

    final profile = state.profile;
    final random = Random();

    // Base damage: 10-25 random, multiplied by level
    final baseDamage = 10 + random.nextInt(16); // 10-25
    final levelMultiplier = PlayerProfile.damageMultiplier(profile.level); // double
    final isCrit = random.nextDouble() < 0.15;
    final critMultiplier = isCrit ? 2 : 1;

    final totalDamage =
    (baseDamage * levelMultiplier * critMultiplier).round(); // int ✅

    // Deduct mana IMMEDIATELY and update state
    state = state.copyWith(
      profile: profile.copyWith(
        mana: profile.mana - manaCost,
      ),
    );

    await _saveProfile();

    // Track damage for achievements
    await _updateAchievementProgress('ach_damage_100', totalDamage);
    await _updateAchievementProgress('ach_damage_1000', totalDamage);
    await _updateAchievementProgress('ach_damage_10000', totalDamage);

    return (damage: totalDamage, isCrit: isCrit, success: true);
  }

  /// Apply passive mana regeneration based on elapsed time
  /// +10% of maxMana every 6 minutes (full regen in ~1 hour)
  PlayerProfile _applyPassiveManaRegen(PlayerProfile profile) {
    final maxMana = PlayerProfile.maxManaForLevel(profile.level);
    if (profile.mana >= maxMana) {
      // Already full, just update timestamp
      return profile.copyWith(lastManaRegenTime: DateTime.now());
    }

    final lastRegen = profile.lastManaRegenTime ?? profile.createdAt;
    final elapsed = DateTime.now().difference(lastRegen);
    final intervalMinutes = 6; // +10% every 6 minutes
    final ticks = elapsed.inMinutes ~/ intervalMinutes;

    if (ticks <= 0) return profile;

    final regenPerTick = (maxMana * 0.1).round().clamp(1, maxMana);
    final totalRegen = regenPerTick * ticks;
    final newMana = (profile.mana + totalRegen).clamp(0, maxMana);

    return profile.copyWith(
      mana: newMana,
      lastManaRegenTime: DateTime.now(),
    );
  }

  /// Regenerate mana (called on XP-earning actions and periodically)
  Future<void> regenerateMana({int amount = 5}) async {
    // UI controls RPG access via nerdMode

    final profile = state.profile;
    final maxMana = PlayerProfile.maxManaForLevel(profile.level);
    final newMana = (profile.mana + amount).clamp(0, maxMana);

    if (newMana != profile.mana) {
      state = state.copyWith(
        profile: profile.copyWith(mana: newMana, lastManaRegenTime: DateTime.now()),
      );
      await _saveProfile();
    }
  }

  // ============ COSMETIC EQUIPPING ============

  Future<void> equipAvatar(String? avatarId) async {
    if (avatarId != null &&
        !state.profile.unlockedAvatars.contains(avatarId)) return;

    state = state.copyWith(
      profile: state.profile.copyWith(avatarId: avatarId),
    );
    await _saveProfile();
  }

  Future<void> equipFrame(String? frameId) async {
    if (frameId != null &&
        !state.profile.unlockedFrames.contains(frameId)) return;

    state = state.copyWith(
      profile: state.profile.copyWith(frameId: frameId),
    );
    await _saveProfile();
  }

  Future<void> equipPet(String? petId) async {
    if (petId != null &&
        !state.profile.unlockedPets.contains(petId)) return;

    state = state.copyWith(
      profile: state.profile.copyWith(petId: petId),
    );
    await _saveProfile();
  }

  Future<void> equipTitle(String? titleId) async {
    if (titleId != null &&
        !state.profile.unlockedTitles.contains(titleId)) return;

    state = state.copyWith(
      profile: state.profile.copyWith(titleId: titleId),
    );
    await _saveProfile();
  }

  // ============ CLASS SYSTEM ============

  Future<void> changeClass(PlayerClass newClass) async {
    // UI controls RPG access via nerdMode
    if (newClass == state.profile.playerClass) return;

    state = state.copyWith(
      profile: state.profile.copyWith(playerClass: newClass),
    );
    await _saveProfile();
  }

  // ============ PROFILE UPDATES ============

  Future<void> updateDisplayName(String name) async {
    state = state.copyWith(
      profile: state.profile.copyWith(displayName: name),
    );
    await _saveProfile();
  }

  // ============ ACHIEVEMENTS ============

  Future<void> _checkAchievements() async {
    final profile = state.profile;

    // Level achievements
    await _checkLevelAchievement(profile.level);

    // XP achievements
    await _checkXpAchievement(profile.totalXp);

    // Streak achievements
    await _checkStreakAchievement(profile.loginStreak);

    // Collection achievements
    await _checkCollectionAchievements(profile);
  }

  Future<void> _checkLevelAchievement(int level) async {
    if (level >= 5) await _tryUnlockAchievement('ach_level_5');
    if (level >= 10) await _tryUnlockAchievement('ach_level_10');
    if (level >= 25) await _tryUnlockAchievement('ach_level_25');
    if (level >= 50) await _tryUnlockAchievement('ach_level_50');
    if (level >= 100) await _tryUnlockAchievement('ach_level_100');
  }

  Future<void> _checkXpAchievement(int totalXp) async {
    if (totalXp >= 10000) await _tryUnlockAchievement('ach_xp_10000');
    if (totalXp >= 100000) await _tryUnlockAchievement('ach_xp_100000');
  }

  Future<void> _checkStreakAchievement(int streak) async {
    if (streak >= 7) await _tryUnlockAchievement('ach_streak_7');
    if (streak >= 14) await _tryUnlockAchievement('ach_streak_14');
    if (streak >= 30) await _tryUnlockAchievement('ach_streak_30');
    if (streak >= 100) await _tryUnlockAchievement('ach_streak_100');
    if (streak >= 365) await _tryUnlockAchievement('ach_streak_365');
  }

  Future<void> _checkCollectionAchievements(PlayerProfile profile) async {
    if (profile.unlockedAvatars.length >= 5) {
      await _tryUnlockAchievement('ach_avatars_5');
    }
    if (profile.unlockedPets.length >= 3) {
      await _tryUnlockAchievement('ach_pets_3');
    }
  }

  Future<void> _tryUnlockAchievement(String achievementId) async {
    if (state.profile.completedAchievements.contains(achievementId)) return;
    await _unlockAchievement(achievementId);
  }

  Future<void> _unlockAchievement(String achievementId) async {
    final achievement = RpgAchievements.getById(achievementId);
    if (achievement == null) return;
    if (state.profile.completedAchievements.contains(achievementId)) return;

    final profile = state.profile;
    final completedList = [...profile.completedAchievements, achievementId];

    // Unlock any associated cosmetic
    var updatedProfile = profile.copyWith(
      completedAchievements: completedList,
      gems: profile.gems + achievement.gemReward,
    );

    if (achievement.unlocksItemId != null) {
      final item = RpgCosmetics.getById(achievement.unlocksItemId!);
      if (item != null) {
        switch (item.type) {
          case CosmeticType.avatar:
            if (!updatedProfile.unlockedAvatars.contains(item.id)) {
              updatedProfile = updatedProfile.copyWith(
                unlockedAvatars: [...updatedProfile.unlockedAvatars, item.id],
              );
            }
            break;
          case CosmeticType.frame:
            if (!updatedProfile.unlockedFrames.contains(item.id)) {
              updatedProfile = updatedProfile.copyWith(
                unlockedFrames: [...updatedProfile.unlockedFrames, item.id],
              );
            }
            break;
          case CosmeticType.pet:
            if (!updatedProfile.unlockedPets.contains(item.id)) {
              updatedProfile = updatedProfile.copyWith(
                unlockedPets: [...updatedProfile.unlockedPets, item.id],
              );
            }
            break;
          case CosmeticType.title:
            if (!updatedProfile.unlockedTitles.contains(item.id)) {
              updatedProfile = updatedProfile.copyWith(
                unlockedTitles: [...updatedProfile.unlockedTitles, item.id],
              );
            }
            break;
        }
      }
    }

    state = state.copyWith(
      profile: updatedProfile,
      pendingAchievement: achievement,
    );

    await _saveProfile();
  }

  Future<void> _updateAchievementProgress(String achievementId, int amount) async {
    final achievement = RpgAchievements.getById(achievementId);
    if (achievement == null) return;
    if (state.profile.completedAchievements.contains(achievementId)) return;

    final progress = state.profile.achievementProgress;
    final currentProgress = progress[achievementId] ?? 0;
    final newProgress = currentProgress + amount;

    final updatedProgress = Map<String, int>.from(progress);
    updatedProgress[achievementId] = newProgress;

    state = state.copyWith(
      profile: state.profile.copyWith(achievementProgress: updatedProgress),
    );

    if (newProgress >= achievement.targetValue) {
      await _unlockAchievement(achievementId);
    }

    await _saveProfile();
  }

  /// Called from external sources to update achievement progress
  Future<void> updateProgress(String achievementId, int value) async {
    // UI controls RPG access via nerdMode
    await _updateAchievementProgress(achievementId, value);
  }

  /// Set absolute progress (for count-based achievements like recipe count)
  Future<void> setProgress(String achievementId, int value) async {
    // UI controls RPG access via nerdMode

    final achievement = RpgAchievements.getById(achievementId);
    if (achievement == null) return;
    if (state.profile.completedAchievements.contains(achievementId)) return;

    final updatedProgress = Map<String, int>.from(state.profile.achievementProgress);
    updatedProgress[achievementId] = value;

    state = state.copyWith(
      profile: state.profile.copyWith(achievementProgress: updatedProgress),
    );

    if (value >= achievement.targetValue) {
      await _unlockAchievement(achievementId);
    }

    await _saveProfile();
  }

  // ============ NOTIFICATION CLEARING ============

  void clearPendingLevelUp() {
    state = state.copyWith(clearPendingLevelUp: true);
  }

  void clearPendingAchievement() {
    state = state.copyWith(clearPendingAchievement: true);
  }

  void clearRecentXpGains() {
    state = state.copyWith(recentXpGains: []);
  }

  // ============ RESET ============

  Future<void> resetProgress() async {
    state = RpgState(
      profile: PlayerProfile.newPlayer(const Uuid().v4()),
      isEnabled: state.isEnabled,
      isLoading: false,
    );
    await _saveProfile();
  }
}

// ============ LOTTERY RESULT ============

enum LotteryRewardType {
  xp,
  gold,
  gems,
  rarePet,
  nothing,
}

class LotteryResult {
  final LotteryRewardType type;
  final int amount;
  final String? petId;

  const LotteryResult({
    required this.type,
    required this.amount,
    this.petId,
  });
}

// ============ PROVIDER ============

final rpgProvider = NotifierProvider<RpgNotifier, RpgState>(() {
  return RpgNotifier();
});

// ============ CONVENIENCE PROVIDERS ============

/// Quick check if RPG mode is enabled
final rpgEnabledProvider = Provider<bool>((ref) {
  return ref.watch(rpgProvider).isEnabled;
});

/// Quick access to player profile
final playerProfileProvider = Provider<PlayerProfile>((ref) {
  return ref.watch(rpgProvider).profile;
});

/// Check if there's a pending level up notification
final pendingLevelUpProvider = Provider<LevelUpEvent?>((ref) {
  return ref.watch(rpgProvider).pendingLevelUp;
});

/// Check if there's a pending achievement notification
final pendingAchievementProvider = Provider<Achievement?>((ref) {
  return ref.watch(rpgProvider).pendingAchievement;
});