// lib/providers/kitchen_buddy_provider.dart
// Kitchen Buddy state management — coins, companion, shop, achievements

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/kitchen_buddy/kitchen_buddy_models.dart';
import '../data/kitchen_buddy/kitchen_buddy_shop.dart';
import '../data/rpg/rpg_achievements.dart';
import 'settings_provider.dart';

// ============ NOTIFIER ============

class KitchenBuddyNotifier extends Notifier<KitchenBuddyState> {
  static const _stateKey = 'kitchen_buddy_state';
  static const _migratedKey = 'kitchen_buddy_migrated';

  @override
  KitchenBuddyState build() {
    _loadState();
    return const KitchenBuddyState(isLoading: true);
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // Try to load saved state
    final stateJson = prefs.getString(_stateKey);
    KitchenBuddyState loaded;

    if (stateJson != null) {
      try {
        loaded = KitchenBuddyState.fromJson(jsonDecode(stateJson));
      } catch (_) {
        loaded = _defaultState();
      }
    } else {
      // Check if we need to migrate from old RPG data
      loaded = await _migrateFromRpg(prefs);
    }

    // Ensure default items are owned
    final ownedItems = Set<String>.from(loaded.ownedItems);
    ownedItems.addAll(KitchenBuddyShop.defaultOwnedIds);

    // Check daily login
    final wallet = _checkDailyLogin(loaded.wallet);

    state = loaded.copyWith(
      wallet: wallet,
      ownedItems: ownedItems,
      isLoading: false,
    );

    await _saveState();
  }

  KitchenBuddyState _defaultState() {
    return KitchenBuddyState(
      wallet: const BuddyWallet(),
      ownedItems: KitchenBuddyShop.defaultOwnedIds,
      isLoading: false,
    );
  }

  /// Migrate from old RPG system (one-time)
  Future<KitchenBuddyState> _migrateFromRpg(SharedPreferences prefs) async {
    final alreadyMigrated = prefs.getBool(_migratedKey) ?? false;
    if (alreadyMigrated) return _defaultState();

    try {
      // Try to read old RPG profile
      final rpgJson = prefs.getString('rpg_profile');
      if (rpgJson == null) {
        await prefs.setBool(_migratedKey, true);
        return _defaultState();
      }

      final rpgData = jsonDecode(rpgJson) as Map<String, dynamic>;

      // Convert gold + gems to Spice Coins
      final gold = rpgData['gold'] as int? ?? 0;
      final gems = rpgData['gems'] as int? ?? 0;
      final coins = gold + (gems * 2);

      // Carry over achievements
      final completedList = rpgData['completedAchievements'] as List<dynamic>? ?? [];
      final completedAchievements = completedList.map((e) => e as String).toSet();

      final progressMap = rpgData['achievementProgress'] as Map<String, dynamic>? ?? {};
      final achievementProgress = progressMap.map((k, v) => MapEntry(k, v as int));

      // Carry over login streak
      final loginStreak = rpgData['loginStreak'] as int? ?? 0;
      final lastLoginStr = rpgData['lastLoginDate'] as String?;
      final lastLoginDate = lastLoginStr != null ? DateTime.tryParse(lastLoginStr) : null;

      // Carry over companion name
      final companionJson = prefs.getString('rpg_companion');
      BuddyCompanion? companion;
      if (companionJson != null) {
        final companionData = jsonDecode(companionJson) as Map<String, dynamic>;
        final name = companionData['name'] as String? ?? 'Buddy';
        companion = BuddyCompanion(name: name, createdAt: DateTime.now());
      }

      await prefs.setBool(_migratedKey, true);

      return KitchenBuddyState(
        wallet: BuddyWallet(
          spiceCoins: coins,
          totalCoinsEarned: coins,
          loginStreak: loginStreak,
          lastLoginDate: lastLoginDate,
        ),
        companion: companion,
        ownedItems: KitchenBuddyShop.defaultOwnedIds,
        completedAchievements: completedAchievements,
        achievementProgress: achievementProgress,
        isLoading: false,
      );
    } catch (_) {
      await prefs.setBool(_migratedKey, true);
      return _defaultState();
    }
  }

  BuddyWallet _checkDailyLogin(BuddyWallet wallet) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastLogin = wallet.lastLoginDate;

    if (lastLogin != null) {
      final lastLoginDay = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
      if (lastLoginDay == today) {
        return wallet; // Already logged in today
      }

      final yesterday = today.subtract(const Duration(days: 1));
      if (lastLoginDay == yesterday) {
        // Consecutive day — increase streak
        final newStreak = wallet.loginStreak + 1;
        var coinsEarned = CoinAction.dailyLogin.coinValue;

        // 7-day streak bonus
        if (newStreak % 7 == 0) {
          coinsEarned += CoinAction.streakBonus7.coinValue;
        }

        return wallet.copyWith(
          spiceCoins: wallet.spiceCoins + coinsEarned,
          totalCoinsEarned: wallet.totalCoinsEarned + coinsEarned,
          loginStreak: newStreak,
          lastLoginDate: now,
        );
      } else {
        // Streak broken — reset to 1
        final coinsEarned = CoinAction.dailyLogin.coinValue;
        return wallet.copyWith(
          spiceCoins: wallet.spiceCoins + coinsEarned,
          totalCoinsEarned: wallet.totalCoinsEarned + coinsEarned,
          loginStreak: 1,
          lastLoginDate: now,
        );
      }
    } else {
      // First ever login
      final coinsEarned = CoinAction.dailyLogin.coinValue;
      return wallet.copyWith(
        spiceCoins: wallet.spiceCoins + coinsEarned,
        totalCoinsEarned: wallet.totalCoinsEarned + coinsEarned,
        loginStreak: 1,
        lastLoginDate: now,
      );
    }
  }

  // ============ COIN SYSTEM ============

  /// Earn coins from an action. Checks if Kitchen Buddy is enabled.
  Future<void> earnCoins(CoinAction action, {int? overrideAmount}) async {
    final enabled = ref.read(settingsProvider).kitchenBuddyEnabled;
    if (!enabled) return;

    final amount = overrideAmount ?? action.coinValue;
    if (amount <= 0) return;

    state = state.copyWith(
      wallet: state.wallet.copyWith(
        spiceCoins: state.wallet.spiceCoins + amount,
        totalCoinsEarned: state.wallet.totalCoinsEarned + amount,
      ),
      pendingCoinGain: CoinGainEvent(
        action: action,
        amount: amount,
        timestamp: DateTime.now(),
      ),
    );

    await _saveState();
  }

  void clearPendingCoinGain() {
    state = state.copyWith(clearPendingCoinGain: true);
  }

  // ============ SHOP ============

  /// Purchase a shop item. Returns true if successful.
  Future<bool> purchaseItem(String itemId) async {
    final item = KitchenBuddyShop.getById(itemId);
    if (item == null) return false;

    if (!KitchenBuddyShop.canPurchase(
      item,
      state.wallet.spiceCoins,
      state.completedAchievements,
      state.ownedItems,
    )) return false;

    final newOwned = Set<String>.from(state.ownedItems)..add(itemId);

    state = state.copyWith(
      wallet: state.wallet.copyWith(
        spiceCoins: state.wallet.spiceCoins - item.price,
      ),
      ownedItems: newOwned,
    );

    // Check cosmetic collection achievements
    await _updateProgress('ach_cosmetics_5', newOwned.length);
    await _updateProgress('ach_cosmetics_15', newOwned.length);

    await _saveState();
    return true;
  }

  // ============ EQUIP ============

  Future<void> equipHat(String? hatId) async {
    if (state.companion == null) return;
    state = state.copyWith(
      companion: hatId != null
          ? state.companion!.copyWith(hatId: hatId)
          : state.companion!.copyWith(clearHat: true),
    );
    await _saveState();
  }

  Future<void> equipOutfit(String? outfitId) async {
    if (state.companion == null) return;
    state = state.copyWith(
      companion: outfitId != null
          ? state.companion!.copyWith(outfitId: outfitId)
          : state.companion!.copyWith(clearOutfit: true),
    );
    await _saveState();
  }

  Future<void> equipAccessory(String? accessoryId) async {
    if (state.companion == null) return;
    state = state.copyWith(
      companion: accessoryId != null
          ? state.companion!.copyWith(accessoryId: accessoryId)
          : state.companion!.copyWith(clearAccessory: true),
    );
    await _saveState();
  }

  Future<void> equipBackground(String? backgroundId) async {
    if (state.companion == null) return;
    state = state.copyWith(
      companion: state.companion!.copyWith(backgroundId: backgroundId ?? 'bg_kitchen_basic'),
    );
    await _saveState();
  }

  Future<void> setBodyColor(String colorId) async {
    if (state.companion == null) return;
    state = state.copyWith(
      companion: state.companion!.copyWith(bodyColorId: colorId),
    );
    await _saveState();
  }

  /// Equip an item by ID — routes to the correct slot
  Future<void> equipItem(String itemId) async {
    final item = KitchenBuddyShop.getById(itemId);
    if (item == null) return;

    switch (item.category) {
      case ShopCategory.hats: await equipHat(itemId);
      case ShopCategory.outfits: await equipOutfit(itemId);
      case ShopCategory.accessories: await equipAccessory(itemId);
      case ShopCategory.backgrounds: await equipBackground(itemId);
      case ShopCategory.bodyColors: await setBodyColor(itemId);
    }
  }

  /// Unequip an item from a category slot
  Future<void> unequipCategory(ShopCategory category) async {
    switch (category) {
      case ShopCategory.hats: await equipHat(null);
      case ShopCategory.outfits: await equipOutfit(null);
      case ShopCategory.accessories: await equipAccessory(null);
      case ShopCategory.backgrounds: await equipBackground(null);
      case ShopCategory.bodyColors: break; // Always has a color
    }
  }

  // ============ COMPANION ============

  Future<void> createCompanion(String name) async {
    state = state.copyWith(
      companion: BuddyCompanion(
        name: name.trim(),
        createdAt: DateTime.now(),
      ),
    );
    await _saveState();
  }

  Future<void> renameCompanion(String name) async {
    if (state.companion == null) return;
    state = state.copyWith(
      companion: state.companion!.copyWith(name: name.trim()),
    );
    await _saveState();
  }

  // ============ ACHIEVEMENTS ============

  /// Set absolute progress for an achievement
  Future<void> setProgress(String achievementId, int value) async {
    await _updateProgress(achievementId, value);
    await _saveState();
  }

  /// Increment progress for an achievement
  Future<void> incrementProgress(String achievementId, {int amount = 1}) async {
    final current = state.achievementProgress[achievementId] ?? 0;
    await _updateProgress(achievementId, current + amount);
    await _saveState();
  }

  Future<void> _updateProgress(String achievementId, int value) async {
    // Already completed? Skip.
    if (state.completedAchievements.contains(achievementId)) return;

    final achievement = KitchenBuddyAchievements.getById(achievementId);
    if (achievement == null) return;

    final progress = Map<String, int>.from(state.achievementProgress);
    progress[achievementId] = value;

    state = state.copyWith(achievementProgress: progress);

    // Check if achievement is now complete
    if (value >= achievement.targetValue) {
      await _completeAchievement(achievement);
    }
  }

  Future<void> _completeAchievement(Achievement achievement) async {
    final completed = Set<String>.from(state.completedAchievements)..add(achievement.id);
    final ownedItems = Set<String>.from(state.ownedItems);

    // Unlock cosmetic if achievement has one
    if (achievement.unlocksItemId != null) {
      ownedItems.add(achievement.unlocksItemId!);
    }

    // Award coins
    final coinReward = achievement.coinReward;

    state = state.copyWith(
      completedAchievements: completed,
      ownedItems: ownedItems,
      wallet: state.wallet.copyWith(
        spiceCoins: state.wallet.spiceCoins + coinReward,
        totalCoinsEarned: state.wallet.totalCoinsEarned + coinReward,
      ),
      pendingCoinGain: CoinGainEvent(
        action: CoinAction.achievementReward,
        amount: coinReward,
        description: achievement.name,
        timestamp: DateTime.now(),
      ),
    );

    await _saveState();
  }

  // ============ RESET ============

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stateKey);
    state = _defaultState();
  }

  // ============ PERSISTENCE ============

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stateKey, jsonEncode(state.toJson()));
  }
}

// ============ PROVIDERS ============

final kitchenBuddyProvider =
    NotifierProvider<KitchenBuddyNotifier, KitchenBuddyState>(() {
  return KitchenBuddyNotifier();
});

/// Convenience: whether Kitchen Buddy is enabled in settings
final kitchenBuddyEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider.select((s) => s.kitchenBuddyEnabled));
});

/// Convenience: current companion data (or null)
final buddyCompanionProvider = Provider<BuddyCompanion?>((ref) {
  return ref.watch(kitchenBuddyProvider).companion;
});

/// Convenience: current coin balance
final buddyCoinsProvider = Provider<int>((ref) {
  return ref.watch(kitchenBuddyProvider).wallet.spiceCoins;
});
