// lib/data/rpg/rpg_cosmetics.dart
// Cosmetic items for Recipe Spellbook RPG System

import 'rpg_models.dart';

// ============ AVATARS ============
// Files located in assets/rpg/avatars/

class RpgAvatars {
  static const List<CosmeticItem> all = [
    // === FREE/DEFAULT ===
    CosmeticItem(
      id: 'avatar_default',
      name: 'Apprentice',
      description: 'A humble chef beginning their journey',
      type: CosmeticType.avatar,
      rarity: CosmeticRarity.common,
      assetPath: 'assets/rpg/avatars/avatar_default.png',
    ),

    // === GOLD PURCHASABLE ===
    CosmeticItem(
      id: 'avatar_sous_chef',
      name: 'Sous Chef',
      description: 'A skilled assistant ready to take charge',
      type: CosmeticType.avatar,
      rarity: CosmeticRarity.common,
      assetPath: 'assets/rpg/avatars/avatar_sous_chef.png',
      currency: CurrencyType.gold,
      price: 150,
    ),
    CosmeticItem(
      id: 'avatar_baker',
      name: 'Baker',
      description: 'Master of breads and pastries',
      type: CosmeticType.avatar,
      rarity: CosmeticRarity.uncommon,
      assetPath: 'assets/rpg/avatars/avatar_baker.png',
      currency: CurrencyType.gold,
      price: 300,
    ),
    CosmeticItem(
      id: 'avatar_sushi_chef',
      name: 'Sushi Master',
      description: 'Expert in the art of Japanese cuisine',
      type: CosmeticType.avatar,
      rarity: CosmeticRarity.uncommon,
      assetPath: 'assets/rpg/avatars/avatar_sushi_master.png',
      currency: CurrencyType.gold,
      price: 400,
    ),
    CosmeticItem(
      id: 'avatar_grill_master',
      name: 'Grill Master',
      description: 'King of the BBQ and open flame',
      type: CosmeticType.avatar,
      rarity: CosmeticRarity.uncommon,
      assetPath: 'assets/rpg/avatars/avatar_grill_master.png',
      currency: CurrencyType.gold,
      price: 400,
    ),
    CosmeticItem(
      id: 'avatar_wizard_chef',
      name: 'Culinary Wizard',
      description: 'Combines magic and cooking in mysterious ways',
      type: CosmeticType.avatar,
      rarity: CosmeticRarity.rare,
      assetPath: 'assets/rpg/avatars/avatar_wizard_chef.png',
      currency: CurrencyType.gold,
      price: 1000,
    ),
    CosmeticItem(
      id: 'avatar_knight_chef',
      name: 'Knight of the Kitchen',
      description: 'Armored protector of culinary traditions',
      type: CosmeticType.avatar,
      rarity: CosmeticRarity.rare,
      assetPath: 'assets/rpg/avatars/avatar_knight_chef.png',
      currency: CurrencyType.gold,
      price: 1000,
    ),
    CosmeticItem(
      id: 'avatar_royal_chef',
      name: 'Royal Chef',
      description: 'Cooks for kings and queens',
      type: CosmeticType.avatar,
      rarity: CosmeticRarity.epic,
      assetPath: 'assets/rpg/avatars/avatar_royal_chef.png',
      currency: CurrencyType.gold,
      price: 2500,
    ),
    CosmeticItem(
      id: 'avatar_dragon_chef',
      name: 'Dragon Chef',
      description: 'Harnesses dragonfire for cooking',
      type: CosmeticType.avatar,
      rarity: CosmeticRarity.epic,
      assetPath: 'assets/rpg/avatars/avatar_dragon_chef.png',
      currency: CurrencyType.gold,
      price: 3000,
    ),

    // === ACHIEVEMENT LOCKED ===
    CosmeticItem(
      id: 'avatar_master_chef',
      name: 'Grand Master Chef',
      description: 'Earned by reaching level 50',
      type: CosmeticType.avatar,
      rarity: CosmeticRarity.legendary,
      assetPath: 'assets/rpg/avatars/avatar_master_chef.png',
      achievementId: 'ach_level_50',
    ),
    CosmeticItem(
      id: 'avatar_celebrity_chef',
      name: 'Celebrity Chef',
      description: 'Earned by getting 100 cookbook downloads',
      type: CosmeticType.avatar,
      rarity: CosmeticRarity.legendary,
      assetPath: 'assets/rpg/avatars/avatar_celebrity_chef.png',
      achievementId: 'ach_downloads_100',
    ),
    CosmeticItem(
      id: 'avatar_premium',
      name: 'Premium Chef',
      description: 'Exclusive avatar for premium supporters',
      type: CosmeticType.avatar,
      rarity: CosmeticRarity.epic,
      assetPath: 'assets/rpg/avatars/avatar_premium.png',
      achievementId: 'ach_premium',
    ),
  ];

  static CosmeticItem? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<CosmeticItem> getPurchasable() {
    return all.where((a) => a.isPurchasable).toList();
  }

  static List<CosmeticItem> getByRarity(CosmeticRarity rarity) {
    return all.where((a) => a.rarity == rarity).toList();
  }
}

// ============ FRAMES ============
// Files located in assets/rpg/frames/

class RpgFrames {
  static const List<CosmeticItem> all = [
    // === FREE/DEFAULT — plain thin circle, no asset needed ===
    CosmeticItem(
      id: 'frame_default',
      name: 'Plain Frame',
      description: 'A clean, minimal border',
      type: CosmeticType.frame,
      rarity: CosmeticRarity.common,
      assetPath: '', // No asset — rendered as simple grey circle in code
    ),

    // === BASIC PURCHASABLE ===
    CosmeticItem(
      id: 'frame_wooden',
      name: 'Wooden Frame',
      description: 'A rustic wooden border',
      type: CosmeticType.frame,
      rarity: CosmeticRarity.common,
      assetPath: 'assets/rpg/frames/frame_default.png',
      currency: CurrencyType.gold,
      price: 1,
    ),

    // === GOLD PURCHASABLE ===
    CosmeticItem(
      id: 'frame_bronze',
      name: 'Bronze Frame',
      description: 'Warm bronze finish',
      type: CosmeticType.frame,
      rarity: CosmeticRarity.common,
      assetPath: 'assets/rpg/frames/frame_bronze.png',
      currency: CurrencyType.gold,
      price: 100,
    ),
    CosmeticItem(
      id: 'frame_silver',
      name: 'Silver Frame',
      description: 'Elegant silver serving tray',
      type: CosmeticType.frame,
      rarity: CosmeticRarity.uncommon,
      assetPath: 'assets/rpg/frames/frame_silver.png',
      currency: CurrencyType.gold,
      price: 250,
    ),
    CosmeticItem(
      id: 'frame_golden',
      name: 'Golden Frame',
      description: 'Prestigious golden border',
      type: CosmeticType.frame,
      rarity: CosmeticRarity.rare,
      assetPath: 'assets/rpg/frames/frame_golden.png',
      currency: CurrencyType.gold,
      price: 750,
    ),
    CosmeticItem(
      id: 'frame_enchanted',
      name: 'Enchanted Frame',
      description: 'Glowing with magical energy',
      type: CosmeticType.frame,
      rarity: CosmeticRarity.epic,
      assetPath: 'assets/rpg/frames/frame_enchanted.png',
      currency: CurrencyType.gold,
      price: 2000,
    ),
    CosmeticItem(
      id: 'frame_flames',
      name: 'Flame Frame',
      description: 'Surrounded by culinary fire',
      type: CosmeticType.frame,
      rarity: CosmeticRarity.rare,
      assetPath: 'assets/rpg/frames/frame_flames.png',
      currency: CurrencyType.gold,
      price: 1000,
    ),
    CosmeticItem(
      id: 'frame_ice',
      name: 'Ice Frame',
      description: 'Frosty dessert-inspired border',
      type: CosmeticType.frame,
      rarity: CosmeticRarity.rare,
      assetPath: 'assets/rpg/frames/frame_ice.png',
      currency: CurrencyType.gold,
      price: 1000,
    ),

    // === ACHIEVEMENT LOCKED ===
    CosmeticItem(
      id: 'frame_legendary',
      name: 'Legendary Frame',
      description: 'Earned by reaching level 100',
      type: CosmeticType.frame,
      rarity: CosmeticRarity.legendary,
      assetPath: 'assets/rpg/frames/frame_legendary.png',
      achievementId: 'ach_level_100',
    ),
    CosmeticItem(
      id: 'frame_streak',
      name: 'Dedication Frame',
      description: 'Earned with a 30-day streak',
      type: CosmeticType.frame,
      rarity: CosmeticRarity.epic,
      assetPath: 'assets/rpg/frames/frame_streak.png',
      achievementId: 'ach_streak_30',
    ),
  ];

  static CosmeticItem? getById(String id) {
    try {
      return all.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
}

// ============ PETS ============
// Files located in assets/rpg/pets/

class RpgPets {
  static const List<CosmeticItem> all = [
    // === GEM PURCHASABLE ===
    CosmeticItem(
      id: 'pet_mouse',
      name: 'Kitchen Mouse',
      description: 'A tiny helper that loves crumbs',
      type: CosmeticType.pet,
      rarity: CosmeticRarity.common,
      assetPath: 'assets/rpg/pets/mouse.png',
      currency: CurrencyType.gems,
      price: 25,
    ),
    CosmeticItem(
      id: 'pet_cat',
      name: 'Culinary Cat',
      description: 'Watches you cook with keen interest',
      type: CosmeticType.pet,
      rarity: CosmeticRarity.common,
      assetPath: 'assets/rpg/pets/cat.png',
      currency: CurrencyType.gems,
      price: 30,
    ),
    CosmeticItem(
      id: 'pet_dog',
      name: 'Sous Pup',
      description: 'Your loyal kitchen companion',
      type: CosmeticType.pet,
      rarity: CosmeticRarity.common,
      assetPath: 'assets/rpg/pets/dog.png',
      currency: CurrencyType.gems,
      price: 30,
    ),
    CosmeticItem(
      id: 'pet_parrot',
      name: 'Recipe Parrot',
      description: 'Memorizes and recites recipes',
      type: CosmeticType.pet,
      rarity: CosmeticRarity.uncommon,
      assetPath: 'assets/rpg/pets/parrot.png',
      currency: CurrencyType.gems,
      price: 50,
    ),
    CosmeticItem(
      id: 'pet_owl',
      name: 'Wise Owl',
      description: 'Offers cooking wisdom at night',
      type: CosmeticType.pet,
      rarity: CosmeticRarity.uncommon,
      assetPath: 'assets/rpg/pets/owl.png',
      currency: CurrencyType.gems,
      price: 60,
    ),
    CosmeticItem(
      id: 'pet_pig',
      name: 'Truffle Pig',
      description: 'Expert at finding rare ingredients',
      type: CosmeticType.pet,
      rarity: CosmeticRarity.rare,
      assetPath: 'assets/rpg/pets/pig.png',
      currency: CurrencyType.gems,
      price: 100,
    ),
    CosmeticItem(
      id: 'pet_dragon_small',
      name: 'Baby Dragon',
      description: 'Provides its own heat source',
      type: CosmeticType.pet,
      rarity: CosmeticRarity.rare,
      assetPath: 'assets/rpg/pets/dragon_small.png',
      currency: CurrencyType.gems,
      price: 150,
    ),
    CosmeticItem(
      id: 'pet_phoenix',
      name: 'Culinary Phoenix',
      description: 'Rises from the ashes of burnt dishes',
      type: CosmeticType.pet,
      rarity: CosmeticRarity.epic,
      assetPath: 'assets/rpg/pets/phoenix.png',
      currency: CurrencyType.gems,
      price: 300,
    ),
    CosmeticItem(
      id: 'pet_unicorn',
      name: 'Rainbow Unicorn',
      description: 'Makes every dish magical',
      type: CosmeticType.pet,
      rarity: CosmeticRarity.epic,
      assetPath: 'assets/rpg/pets/unicorn.png',
      currency: CurrencyType.gems,
      price: 400,
    ),

    // === LOTTERY/ACHIEVEMENT ONLY ===
    CosmeticItem(
      id: 'pet_golden_goose',
      name: 'Golden Goose',
      description: 'Extremely rare lottery-only pet',
      type: CosmeticType.pet,
      rarity: CosmeticRarity.legendary,
      assetPath: 'assets/rpg/pets/golden_goose.png',
      achievementId: 'ach_lottery_win',
    ),
    CosmeticItem(
      id: 'pet_recipe_spirit',
      name: 'Recipe Spirit',
      description: 'A mystical being of pure culinary energy',
      type: CosmeticType.pet,
      rarity: CosmeticRarity.legendary,
      assetPath: 'assets/rpg/pets/recipe_spirit.png',
      achievementId: 'ach_recipes_500',
    ),
  ];

  static CosmeticItem? getById(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<CosmeticItem> getPurchasable() {
    return all.where((p) => p.isPurchasable).toList();
  }

  /// Get pets available in lottery (rare chance pets)
  static List<CosmeticItem> getLotteryPets() {
    return all.where((p) =>
    p.rarity == CosmeticRarity.legendary &&
        p.achievementId == 'ach_lottery_win'
    ).toList();
  }
}

// ============ COMBINED COSMETICS ============

class RpgCosmetics {
  static List<CosmeticItem> get allAvatars => RpgAvatars.all;
  static List<CosmeticItem> get allFrames => RpgFrames.all;
  static List<CosmeticItem> get allPets => RpgPets.all;

  static List<CosmeticItem> get all => [
    ...allAvatars,
    ...allFrames,
    ...allPets,
  ];

  static CosmeticItem? getById(String id) {
    return RpgAvatars.getById(id) ??
        RpgFrames.getById(id) ??
        RpgPets.getById(id);
  }

  static List<CosmeticItem> getByType(CosmeticType type) {
    switch (type) {
      case CosmeticType.avatar: return allAvatars;
      case CosmeticType.frame: return allFrames;
      case CosmeticType.pet: return allPets;
      case CosmeticType.title: return []; // Titles are handled separately
    }
  }

  /// Get all items the player can currently purchase
  static List<CosmeticItem> getPurchasableFor({
    required int gold,
    required int gems,
    required Set<String> owned,
    required Set<String> completedAchievements,
  }) {
    return all.where((item) {
      // Already owned
      if (owned.contains(item.id)) return false;

      // Achievement locked and not completed
      if (item.achievementId != null &&
          !completedAchievements.contains(item.achievementId)) {
        return false;
      }

      // Not purchasable
      if (!item.isPurchasable) return false;

      // Can afford
      if (item.currency == CurrencyType.gold) {
        return gold >= item.price!;
      } else {
        return gems >= item.price!;
      }
    }).toList();
  }
}