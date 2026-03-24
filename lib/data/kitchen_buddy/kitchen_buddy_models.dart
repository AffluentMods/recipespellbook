// lib/data/kitchen_buddy/kitchen_buddy_models.dart
// Data models for Kitchen Buddy companion mode


// ============ COIN ACTIONS ============

enum CoinAction {
  saveRecipe,
  cookRecipe,
  importRecipe,
  shareRecipe,
  publishCookbook,
  dailyLogin,
  streakBonus7,
  completeMealPlan,
  achievementReward,
}

extension CoinActionExtension on CoinAction {
  int get coinValue {
    switch (this) {
      case CoinAction.saveRecipe: return 10;
      case CoinAction.cookRecipe: return 15;
      case CoinAction.importRecipe: return 5;
      case CoinAction.shareRecipe: return 5;
      case CoinAction.publishCookbook: return 20;
      case CoinAction.dailyLogin: return 3;
      case CoinAction.streakBonus7: return 10;
      case CoinAction.completeMealPlan: return 25;
      case CoinAction.achievementReward: return 0; // Dynamic, set via amount
    }
  }

  String get label {
    switch (this) {
      case CoinAction.saveRecipe: return 'Recipe saved';
      case CoinAction.cookRecipe: return 'Recipe cooked';
      case CoinAction.importRecipe: return 'Recipe imported';
      case CoinAction.shareRecipe: return 'Recipe shared';
      case CoinAction.publishCookbook: return 'Cookbook published';
      case CoinAction.dailyLogin: return 'Daily login';
      case CoinAction.streakBonus7: return '7-day streak bonus';
      case CoinAction.completeMealPlan: return 'Meal plan completed';
      case CoinAction.achievementReward: return 'Achievement reward';
    }
  }
}

// ============ SHOP CATEGORY ============

enum ShopCategory {
  hats,
  outfits,
  accessories,
  backgrounds,
  bodyColors,
}

extension ShopCategoryExtension on ShopCategory {
  String get displayName {
    switch (this) {
      case ShopCategory.hats: return 'Hats';
      case ShopCategory.outfits: return 'Outfits';
      case ShopCategory.accessories: return 'Accessories';
      case ShopCategory.backgrounds: return 'Backgrounds';
      case ShopCategory.bodyColors: return 'Colors';
    }
  }

  String get emoji {
    switch (this) {
      case ShopCategory.hats: return '👒';
      case ShopCategory.outfits: return '👕';
      case ShopCategory.accessories: return '🍳';
      case ShopCategory.backgrounds: return '🖼️';
      case ShopCategory.bodyColors: return '🎨';
    }
  }
}

// ============ SHOP ITEM ============

class ShopItem {
  final String id;
  final String name;
  final String description;
  final ShopCategory category;
  final int price;
  final String? requiredAchievementId;
  final bool isDefault;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.requiredAchievementId,
    this.isDefault = false,
  });

  bool get isFree => price == 0;
  bool get isAchievementLocked => requiredAchievementId != null;
}

// ============ BUDDY WALLET ============

class BuddyWallet {
  final int spiceCoins;
  final int totalCoinsEarned;
  final int loginStreak;
  final DateTime? lastLoginDate;

  const BuddyWallet({
    this.spiceCoins = 0,
    this.totalCoinsEarned = 0,
    this.loginStreak = 0,
    this.lastLoginDate,
  });

  BuddyWallet copyWith({
    int? spiceCoins,
    int? totalCoinsEarned,
    int? loginStreak,
    DateTime? lastLoginDate,
  }) {
    return BuddyWallet(
      spiceCoins: spiceCoins ?? this.spiceCoins,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      loginStreak: loginStreak ?? this.loginStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'spiceCoins': spiceCoins,
    'totalCoinsEarned': totalCoinsEarned,
    'loginStreak': loginStreak,
    'lastLoginDate': lastLoginDate?.toIso8601String(),
  };

  factory BuddyWallet.fromJson(Map<String, dynamic> json) => BuddyWallet(
    spiceCoins: json['spiceCoins'] as int? ?? 0,
    totalCoinsEarned: json['totalCoinsEarned'] as int? ?? 0,
    loginStreak: json['loginStreak'] as int? ?? 0,
    lastLoginDate: json['lastLoginDate'] != null
        ? DateTime.tryParse(json['lastLoginDate'] as String)
        : null,
  );
}

// ============ BUDDY COMPANION ============

class BuddyCompanion {
  final String name;
  final String bodyColorId;
  final String? hatId;
  final String? outfitId;
  final String? accessoryId;
  final String? backgroundId;
  final DateTime createdAt;

  const BuddyCompanion({
    required this.name,
    this.bodyColorId = 'color_white',
    this.hatId,
    this.outfitId = 'outfit_apron_white',
    this.accessoryId,
    this.backgroundId = 'bg_kitchen_basic',
    required this.createdAt,
  });

  BuddyCompanion copyWith({
    String? name,
    String? bodyColorId,
    String? hatId,
    bool clearHat = false,
    String? outfitId,
    bool clearOutfit = false,
    String? accessoryId,
    bool clearAccessory = false,
    String? backgroundId,
  }) {
    return BuddyCompanion(
      name: name ?? this.name,
      bodyColorId: bodyColorId ?? this.bodyColorId,
      hatId: clearHat ? null : (hatId ?? this.hatId),
      outfitId: clearOutfit ? null : (outfitId ?? this.outfitId),
      accessoryId: clearAccessory ? null : (accessoryId ?? this.accessoryId),
      backgroundId: backgroundId ?? this.backgroundId,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'bodyColorId': bodyColorId,
    'hatId': hatId,
    'outfitId': outfitId,
    'accessoryId': accessoryId,
    'backgroundId': backgroundId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory BuddyCompanion.fromJson(Map<String, dynamic> json) => BuddyCompanion(
    name: json['name'] as String? ?? 'Buddy',
    bodyColorId: json['bodyColorId'] as String? ?? 'color_white',
    hatId: json['hatId'] as String?,
    outfitId: json['outfitId'] as String?,
    accessoryId: json['accessoryId'] as String?,
    backgroundId: json['backgroundId'] as String? ?? 'bg_kitchen_basic',
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );
}

// ============ COIN GAIN EVENT ============

class CoinGainEvent {
  final CoinAction action;
  final int amount;
  final String? description;
  final DateTime timestamp;

  const CoinGainEvent({
    required this.action,
    required this.amount,
    this.description,
    required this.timestamp,
  });
}

// ============ KITCHEN BUDDY STATE ============

class KitchenBuddyState {
  final BuddyWallet wallet;
  final BuddyCompanion? companion;
  final Set<String> ownedItems;
  final Set<String> completedAchievements;
  final Map<String, int> achievementProgress;
  final CoinGainEvent? pendingCoinGain;
  final bool isLoading;

  const KitchenBuddyState({
    this.wallet = const BuddyWallet(),
    this.companion,
    this.ownedItems = const {},
    this.completedAchievements = const {},
    this.achievementProgress = const {},
    this.pendingCoinGain,
    this.isLoading = true,
  });

  KitchenBuddyState copyWith({
    BuddyWallet? wallet,
    BuddyCompanion? companion,
    bool clearCompanion = false,
    Set<String>? ownedItems,
    Set<String>? completedAchievements,
    Map<String, int>? achievementProgress,
    CoinGainEvent? pendingCoinGain,
    bool clearPendingCoinGain = false,
    bool? isLoading,
  }) {
    return KitchenBuddyState(
      wallet: wallet ?? this.wallet,
      companion: clearCompanion ? null : (companion ?? this.companion),
      ownedItems: ownedItems ?? this.ownedItems,
      completedAchievements: completedAchievements ?? this.completedAchievements,
      achievementProgress: achievementProgress ?? this.achievementProgress,
      pendingCoinGain: clearPendingCoinGain ? null : (pendingCoinGain ?? this.pendingCoinGain),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Serialize the full state to JSON for persistence
  Map<String, dynamic> toJson() => {
    'wallet': wallet.toJson(),
    'companion': companion?.toJson(),
    'ownedItems': ownedItems.toList(),
    'completedAchievements': completedAchievements.toList(),
    'achievementProgress': achievementProgress,
  };

  /// Deserialize state from JSON
  factory KitchenBuddyState.fromJson(Map<String, dynamic> json) {
    return KitchenBuddyState(
      wallet: json['wallet'] != null
          ? BuddyWallet.fromJson(json['wallet'] as Map<String, dynamic>)
          : const BuddyWallet(),
      companion: json['companion'] != null
          ? BuddyCompanion.fromJson(json['companion'] as Map<String, dynamic>)
          : null,
      ownedItems: (json['ownedItems'] as List<dynamic>?)
          ?.map((e) => e as String).toSet() ?? {},
      completedAchievements: (json['completedAchievements'] as List<dynamic>?)
          ?.map((e) => e as String).toSet() ?? {},
      achievementProgress: (json['achievementProgress'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int)) ?? {},
      isLoading: false,
    );
  }
}
