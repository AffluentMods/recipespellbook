// lib/data/rpg/rpg_models.dart
// Core RPG data models for Recipe Spellbook

import 'package:flutter/material.dart';

// ============ PLAYER CLASS SYSTEM ============

/// Character classes with unique bonuses
enum PlayerClass {
  apprentice, // Default starting class
  ranger,     // Bonus XP for importing recipes
  warrior,    // Bonus XP for cooking recipes
  mage,       // Bonus XP for adding nutrition data
  alchemist,  // Bonus XP for creating recipes from scratch
  bard,       // Bonus XP for sharing/uploading cookbooks
}

extension PlayerClassExtension on PlayerClass {
  String get displayName {
    switch (this) {
      case PlayerClass.apprentice: return 'Apprentice Chef';
      case PlayerClass.ranger: return 'Recipe Ranger';
      case PlayerClass.warrior: return 'Kitchen Warrior';
      case PlayerClass.mage: return 'Culinary Mage';
      case PlayerClass.alchemist: return 'Food Alchemist';
      case PlayerClass.bard: return 'Recipe Bard';
    }
  }

  String get description {
    switch (this) {
      case PlayerClass.apprentice: return 'A humble chef beginning their culinary journey';
      case PlayerClass.ranger: return 'Expert at discovering and importing recipes from afar';
      case PlayerClass.warrior: return 'Fearless in the kitchen, masters recipes through practice';
      case PlayerClass.mage: return 'Harnesses the arcane power of nutrition knowledge';
      case PlayerClass.alchemist: return 'Creates original recipes from pure inspiration';
      case PlayerClass.bard: return 'Shares culinary wisdom with the community';
    }
  }

  String get icon {
    switch (this) {
      case PlayerClass.apprentice: return '🧑‍🍳';
      case PlayerClass.ranger: return '🏹';
      case PlayerClass.warrior: return '⚔️';
      case PlayerClass.mage: return '🔮';
      case PlayerClass.alchemist: return '⚗️';
      case PlayerClass.bard: return '🎵';
    }
  }

  Color get color {
    switch (this) {
      case PlayerClass.apprentice: return Colors.grey;
      case PlayerClass.ranger: return Colors.green;
      case PlayerClass.warrior: return Colors.red;
      case PlayerClass.mage: return Colors.purple;
      case PlayerClass.alchemist: return Colors.amber;
      case PlayerClass.bard: return Colors.blue;
    }
  }

  /// Bonus multiplier for specific actions (1.0 = no bonus)
  double bonusMultiplierFor(XpActionType action) {
    switch (this) {
      case PlayerClass.apprentice:
        return 1.0; // No bonus
      case PlayerClass.ranger:
        return action == XpActionType.importRecipe ? 1.5 : 1.0;
      case PlayerClass.warrior:
        return action == XpActionType.cookRecipe ? 1.5 : 1.0;
      case PlayerClass.mage:
        return action == XpActionType.addNutrition ? 1.5 : 1.0;
      case PlayerClass.alchemist:
        return action == XpActionType.createRecipe ? 1.5 : 1.0;
      case PlayerClass.bard:
        return action == XpActionType.uploadCookbook ? 1.5 : 1.0;
    }
  }
}

// ============ XP ACTION TYPES ============

/// Actions that earn XP
enum XpActionType {
  // Recipe actions
  createRecipe,       // 50 XP base
  importRecipe,       // 25 XP base
  cookRecipe,         // 20 XP base (mark as cooked in cooking mode)
  addPhoto,           // 10 XP per photo
  addNutrition,       // 15 XP
  addSteps,           // 5 XP per step
  addIngredients,     // 5 XP per 5 ingredients
  rateRecipe,         // 5 XP
  addNotes,           // 5 XP

  // Cookbook actions
  createCookbook,     // 30 XP
  uploadCookbook,     // 50 XP base
  getCookbookDownload, // 5 XP per download (passive)
  getCookbookRating,  // 10 XP per 5-star rating

  // Meal planning
  planMeal,           // 5 XP per meal
  completeWeekPlan,   // 50 XP bonus for full week

  // Shopping
  completeShoppingList, // 20 XP

  // Daily/Streak
  dailyLogin,         // 10 XP
  streakBonus,        // 5 XP per day in streak

  // Achievements
  achievementUnlocked, // Varies

  // Boss battles
  defeatEnemy,         // Varies based on enemy
}

extension XpActionTypeExtension on XpActionType {
  int get baseXp {
    switch (this) {
      case XpActionType.createRecipe: return 50;
      case XpActionType.importRecipe: return 25;
      case XpActionType.cookRecipe: return 20;
      case XpActionType.addPhoto: return 10;
      case XpActionType.addNutrition: return 15;
      case XpActionType.addSteps: return 5;
      case XpActionType.addIngredients: return 5;
      case XpActionType.rateRecipe: return 5;
      case XpActionType.addNotes: return 5;
      case XpActionType.createCookbook: return 30;
      case XpActionType.uploadCookbook: return 50;
      case XpActionType.getCookbookDownload: return 5;
      case XpActionType.getCookbookRating: return 10;
      case XpActionType.planMeal: return 5;
      case XpActionType.completeWeekPlan: return 50;
      case XpActionType.completeShoppingList: return 20;
      case XpActionType.dailyLogin: return 10;
      case XpActionType.streakBonus: return 5;
      case XpActionType.achievementUnlocked: return 0; // Varies
      case XpActionType.defeatEnemy: return 25; // Varies by multiplier
    }
  }

  String get displayName {
    switch (this) {
      case XpActionType.createRecipe: return 'Created Recipe';
      case XpActionType.importRecipe: return 'Imported Recipe';
      case XpActionType.cookRecipe: return 'Cooked Recipe';
      case XpActionType.addPhoto: return 'Added Photo';
      case XpActionType.addNutrition: return 'Added Nutrition';
      case XpActionType.addSteps: return 'Added Steps';
      case XpActionType.addIngredients: return 'Added Ingredients';
      case XpActionType.rateRecipe: return 'Rated Recipe';
      case XpActionType.addNotes: return 'Added Notes';
      case XpActionType.createCookbook: return 'Created Cookbook';
      case XpActionType.uploadCookbook: return 'Uploaded Cookbook';
      case XpActionType.getCookbookDownload: return 'Cookbook Downloaded';
      case XpActionType.getCookbookRating: return 'Cookbook Rated';
      case XpActionType.planMeal: return 'Planned Meal';
      case XpActionType.completeWeekPlan: return 'Week Planned';
      case XpActionType.completeShoppingList: return 'Shopping Complete';
      case XpActionType.dailyLogin: return 'Daily Login';
      case XpActionType.streakBonus: return 'Streak Bonus';
      case XpActionType.achievementUnlocked: return 'Achievement!';
      case XpActionType.defeatEnemy: return 'Boss Defeated!';
    }
  }
}

// ============ PLAYER PROFILE ============

class PlayerProfile {
  final String id;
  final String displayName;
  final PlayerClass playerClass;
  final int level;
  final int currentXp;      // XP in current level
  final int totalXp;        // Total XP earned ever
  final int gold;
  final int gems;
  final int mana;
  final int maxMana;
  final int hp;
  final int maxHp;
  final String? avatarId;
  final String? frameId;
  final String? petId;
  final String? titleId;
  final int loginStreak;
  final DateTime? lastLoginDate;
  final DateTime createdAt;
  final List<String> unlockedAvatars;
  final List<String> unlockedFrames;
  final List<String> unlockedPets;
  final List<String> unlockedTitles;
  final List<String> completedAchievements;
  final Map<String, int> achievementProgress;  // Achievement ID -> progress
  final DateTime? lastManaRegenTime;  // For passive mana regeneration

  const PlayerProfile({
    required this.id,
    this.displayName = 'Apprentice Chef',
    this.playerClass = PlayerClass.apprentice,
    this.level = 1,
    this.currentXp = 0,
    this.totalXp = 0,
    this.gold = 0,
    this.gems = 0,
    this.mana = 100,
    this.maxMana = 100,
    this.hp = 100,
    this.maxHp = 100,
    this.avatarId,
    this.frameId,
    this.petId,
    this.titleId,
    this.loginStreak = 0,
    this.lastLoginDate,
    required this.createdAt,
    this.unlockedAvatars = const ['avatar_default'],
    this.unlockedFrames = const ['frame_default', 'frame_wooden'],
    this.unlockedPets = const [],
    this.unlockedTitles = const ['title_apprentice'],
    this.completedAchievements = const [],
    this.achievementProgress = const {},
    this.lastManaRegenTime,
  });

  /// XP needed to reach next level
  int get xpForNextLevel => calculateXpForLevel(level + 1);

  /// XP needed for current level (cumulative)
  int get xpForCurrentLevel => calculateXpForLevel(level);

  /// Progress to next level (0.0 - 1.0)
  double get levelProgress {
    final needed = xpForNextLevel - xpForCurrentLevel;
    return needed > 0 ? currentXp / needed : 0.0;
  }

  /// Max mana scales with level: 100 + (level-1) * 50
  static int maxManaForLevel(int level) => 100 + (level - 1) * 50;

  /// Damage multiplier by level (double so you can scale smoothly)
  /// Example: +5% per level
  static double damageMultiplier(int level) => 1.0 + (level - 1) * 0.05;


  /// Calculate total XP needed for a specific level
  /// Level 1 = 0 (starting level), Level 2 = 100, Level 3 = 300, Level 4 = 600...
  /// Uses a gentle curve: 100 * (level-1) * level / 2
  static int calculateXpForLevel(int level) {
    if (level <= 1) return 0;
    return 100 * (level - 1) * level ~/ 2;
  }

  /// Calculate level from total XP
  static int calculateLevelFromXp(int totalXp) {
    int level = 1;
    while (calculateXpForLevel(level + 1) <= totalXp) {
      level++;
    }
    return level;
  }

  /// Get the title string to display
  String get displayTitle {
    if (titleId != null) {
      return RpgTitle.getById(titleId!)?.displayName ?? playerClass.displayName;
    }
    return playerClass.displayName;
  }

  /// Max mana scales with level: 100 + (level-1) * 50
  /// L1=100, L2=150, L3=200, L10=550, L50=2550
  int get calculatedMaxMana => 100 + (level - 1) * 50;

  /// Base damage scales linearly with level: 10 * level
  /// L1=10, L2=20, L5=50, L10=100, L50=500
  int get baseDamage => 10 * level;

  PlayerProfile copyWith({
    String? id,
    String? displayName,
    PlayerClass? playerClass,
    int? level,
    int? currentXp,
    int? totalXp,
    int? gold,
    int? gems,
    int? mana,
    int? maxMana,
    int? hp,
    int? maxHp,
    String? avatarId,
    String? frameId,
    String? petId,
    String? titleId,
    int? loginStreak,
    DateTime? lastLoginDate,
    DateTime? createdAt,
    List<String>? unlockedAvatars,
    List<String>? unlockedFrames,
    List<String>? unlockedPets,
    List<String>? unlockedTitles,
    List<String>? completedAchievements,
    Map<String, int>? achievementProgress,
    DateTime? lastManaRegenTime,
  }) {
    return PlayerProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      playerClass: playerClass ?? this.playerClass,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      totalXp: totalXp ?? this.totalXp,
      gold: gold ?? this.gold,
      gems: gems ?? this.gems,
      mana: mana ?? this.mana,
      maxMana: maxMana ?? this.maxMana,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      avatarId: avatarId ?? this.avatarId,
      frameId: frameId ?? this.frameId,
      petId: petId ?? this.petId,
      titleId: titleId ?? this.titleId,
      loginStreak: loginStreak ?? this.loginStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      createdAt: createdAt ?? this.createdAt,
      unlockedAvatars: unlockedAvatars ?? this.unlockedAvatars,
      unlockedFrames: unlockedFrames ?? this.unlockedFrames,
      unlockedPets: unlockedPets ?? this.unlockedPets,
      unlockedTitles: unlockedTitles ?? this.unlockedTitles,
      completedAchievements: completedAchievements ?? this.completedAchievements,
      achievementProgress: achievementProgress ?? this.achievementProgress,
      lastManaRegenTime: lastManaRegenTime ?? this.lastManaRegenTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'playerClass': playerClass.name,
      'level': level,
      'currentXp': currentXp,
      'totalXp': totalXp,
      'gold': gold,
      'gems': gems,
      'mana': mana,
      'maxMana': maxMana,
      'hp': hp,
      'maxHp': maxHp,
      'avatarId': avatarId,
      'frameId': frameId,
      'petId': petId,
      'titleId': titleId,
      'loginStreak': loginStreak,
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'unlockedAvatars': unlockedAvatars,
      'unlockedFrames': unlockedFrames,
      'unlockedPets': unlockedPets,
      'unlockedTitles': unlockedTitles,
      'completedAchievements': completedAchievements,
      'achievementProgress': achievementProgress,
      'lastManaRegenTime': lastManaRegenTime?.toIso8601String(),
    };
  }

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String? ?? 'Apprentice Chef',
      playerClass: PlayerClass.values.firstWhere(
            (c) => c.name == json['playerClass'],
        orElse: () => PlayerClass.apprentice,
      ),
      level: json['level'] as int? ?? 1,
      currentXp: json['currentXp'] as int? ?? 0,
      totalXp: json['totalXp'] as int? ?? 0,
      gold: json['gold'] as int? ?? 0,
      gems: json['gems'] as int? ?? 0,
      mana: json['mana'] as int? ?? 100,
      maxMana: json['maxMana'] as int? ?? 100,
      hp: json['hp'] as int? ?? 100,
      maxHp: json['maxHp'] as int? ?? 100,
      avatarId: json['avatarId'] as String?,
      frameId: json['frameId'] as String?,
      petId: json['petId'] as String?,
      titleId: json['titleId'] as String?,
      loginStreak: json['loginStreak'] as int? ?? 0,
      lastLoginDate: json['lastLoginDate'] != null
          ? DateTime.parse(json['lastLoginDate'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      unlockedAvatars: (json['unlockedAvatars'] as List<dynamic>?)
          ?.cast<String>() ??
          ['avatar_default'],
      unlockedFrames: (json['unlockedFrames'] as List<dynamic>?)
          ?.cast<String>() ??
          ['frame_default', 'frame_wooden'],
      unlockedPets: (json['unlockedPets'] as List<dynamic>?)?.cast<String>() ??
          [],
      unlockedTitles: (json['unlockedTitles'] as List<dynamic>?)
          ?.cast<String>() ??
          ['title_apprentice'],
      completedAchievements:
      (json['completedAchievements'] as List<dynamic>?)?.cast<String>() ??
          [],
      achievementProgress:
      (json['achievementProgress'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      lastManaRegenTime: json['lastManaRegenTime'] != null
          ? DateTime.parse(json['lastManaRegenTime'] as String)
          : null,
    );
  }

  factory PlayerProfile.newPlayer(String id) {
    return PlayerProfile(
      id: id,
      createdAt: DateTime.now(),
    );
  }
}

// ============ COSMETIC ITEMS ============

enum CosmeticType {
  avatar,
  frame,
  pet,
  title,
}

enum CosmeticRarity {
  common,     // Gray - free or very cheap
  uncommon,   // Green - affordable
  rare,       // Blue - moderate cost
  epic,       // Purple - expensive
  legendary,  // Orange - very expensive or achievement-only
}

extension CosmeticRarityExtension on CosmeticRarity {
  Color get color {
    switch (this) {
      case CosmeticRarity.common: return Colors.grey;
      case CosmeticRarity.uncommon: return Colors.green;
      case CosmeticRarity.rare: return Colors.blue;
      case CosmeticRarity.epic: return Colors.purple;
      case CosmeticRarity.legendary: return Colors.orange;
    }
  }

  String get displayName {
    switch (this) {
      case CosmeticRarity.common: return 'Common';
      case CosmeticRarity.uncommon: return 'Uncommon';
      case CosmeticRarity.rare: return 'Rare';
      case CosmeticRarity.epic: return 'Epic';
      case CosmeticRarity.legendary: return 'Legendary';
    }
  }
}

enum CurrencyType {
  gold,   // Earned from leveling, cookbook uploads
  gems,   // Earned from achievements, lottery
}

class CosmeticItem {
  final String id;
  final String name;
  final String description;
  final CosmeticType type;
  final CosmeticRarity rarity;
  final String assetPath;    // Path to image asset
  final CurrencyType? currency; // null = achievement/special unlock
  final int? price;          // null = not purchasable
  final String? achievementId; // Required achievement to unlock

  const CosmeticItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    required this.assetPath,
    this.currency,
    this.price,
    this.achievementId,
  });

  bool get isPurchasable => currency != null && price != null;
  bool get isAchievementLocked => achievementId != null;
}

// ============ TITLES ============

class RpgTitle {
  final String id;
  final String displayName;
  final String description;
  final CosmeticRarity rarity;
  final String? achievementId;

  const RpgTitle({
    required this.id,
    required this.displayName,
    required this.description,
    required this.rarity,
    this.achievementId,
  });

  static const List<RpgTitle> allTitles = [
    // Default/starter
    RpgTitle(
      id: 'title_apprentice',
      displayName: 'Apprentice Chef',
      description: 'Every master was once a beginner',
      rarity: CosmeticRarity.common,
    ),
    // Level-based
    RpgTitle(
      id: 'title_journeyman',
      displayName: 'Journeyman Chef',
      description: 'Reached level 10',
      rarity: CosmeticRarity.uncommon,
      achievementId: 'ach_level_10',
    ),
    RpgTitle(
      id: 'title_master',
      displayName: 'Master Chef',
      description: 'Reached level 25',
      rarity: CosmeticRarity.rare,
      achievementId: 'ach_level_25',
    ),
    RpgTitle(
      id: 'title_grandmaster',
      displayName: 'Grandmaster Chef',
      description: 'Reached level 50',
      rarity: CosmeticRarity.epic,
      achievementId: 'ach_level_50',
    ),
    RpgTitle(
      id: 'title_legendary',
      displayName: 'Legendary Chef',
      description: 'Reached level 100',
      rarity: CosmeticRarity.legendary,
      achievementId: 'ach_level_100',
    ),
    // Recipe-based
    RpgTitle(
      id: 'title_collector',
      displayName: 'Recipe Collector',
      description: 'Collected 100 recipes',
      rarity: CosmeticRarity.uncommon,
      achievementId: 'ach_recipes_100',
    ),
    RpgTitle(
      id: 'title_archivist',
      displayName: 'Grand Archivist',
      description: 'Collected 500 recipes',
      rarity: CosmeticRarity.epic,
      achievementId: 'ach_recipes_500',
    ),
    // Community-based
    RpgTitle(
      id: 'title_generous',
      displayName: 'Generous Chef',
      description: 'Uploaded 5 cookbooks to community',
      rarity: CosmeticRarity.rare,
      achievementId: 'ach_upload_5',
    ),
    RpgTitle(
      id: 'title_celebrity',
      displayName: 'Celebrity Chef',
      description: 'Had a cookbook downloaded 100 times',
      rarity: CosmeticRarity.legendary,
      achievementId: 'ach_downloads_100',
    ),
    // Special
    RpgTitle(
      id: 'title_premium',
      displayName: 'Premium Supporter',
      description: 'Purchased premium',
      rarity: CosmeticRarity.rare,
      achievementId: 'ach_premium',
    ),
    RpgTitle(
      id: 'title_dedicated',
      displayName: 'Dedicated Chef',
      description: 'Maintained a 30-day login streak',
      rarity: CosmeticRarity.epic,
      achievementId: 'ach_streak_30',
    ),
  ];

  static RpgTitle? getById(String id) {
    try {
      return allTitles.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}

// ============ XP GAIN EVENT ============

class XpGainEvent {
  final XpActionType actionType;
  final int baseXp;
  final double multiplier;
  final int totalXp;
  final String? description;
  final DateTime timestamp;

  const XpGainEvent({
    required this.actionType,
    required this.baseXp,
    required this.multiplier,
    required this.totalXp,
    this.description,
    required this.timestamp,
  });

  factory XpGainEvent.create({
    required XpActionType actionType,
    required int baseXp,
    double multiplier = 1.0,
    String? description,
  }) {
    return XpGainEvent(
      actionType: actionType,
      baseXp: baseXp,
      multiplier: multiplier,
      totalXp: (baseXp * multiplier).round(),
      description: description,
      timestamp: DateTime.now(),
    );
  }
}

// ============ LEVEL UP EVENT ============

class LevelUpEvent {
  final int previousLevel;
  final int newLevel;
  final int goldReward;
  final List<String> unlockedItems; // IDs of newly unlocked items

  const LevelUpEvent({
    required this.previousLevel,
    required this.newLevel,
    required this.goldReward,
    this.unlockedItems = const [],
  });

  /// Gold reward scales with level
  static int calculateGoldReward(int newLevel) {
    return 10 + (newLevel * 5);
  }
}