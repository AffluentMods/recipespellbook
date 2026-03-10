// lib/data/kitchen_buddy/kitchen_buddy_shop.dart
// Shop catalog for Kitchen Buddy companion mode

import 'kitchen_buddy_models.dart';

class KitchenBuddyShop {
  KitchenBuddyShop._();

  // ============ HATS ============

  static const List<ShopItem> hats = [
    ShopItem(
      id: 'hat_chef_toque',
      name: 'Classic Toque',
      description: 'The iconic tall white chef hat',
      category: ShopCategory.hats,
      price: 30,
    ),
    ShopItem(
      id: 'hat_beret',
      name: 'French Beret',
      description: 'A stylish burgundy beret',
      category: ShopCategory.hats,
      price: 50,
    ),
    ShopItem(
      id: 'hat_sombrero',
      name: 'Party Sombrero',
      description: 'A festive wide-brimmed sombrero',
      category: ShopCategory.hats,
      price: 75,
    ),
    ShopItem(
      id: 'hat_viking',
      name: 'Viking Helmet',
      description: 'A horned helmet for the boldest chef',
      category: ShopCategory.hats,
      price: 120,
    ),
    ShopItem(
      id: 'hat_crown',
      name: 'Golden Crown',
      description: 'A crown fit for a culinary king',
      category: ShopCategory.hats,
      price: 200,
      requiredAchievementId: 'ach_recipes_100',
    ),
  ];

  // ============ OUTFITS ============

  static const List<ShopItem> outfits = [
    ShopItem(
      id: 'outfit_apron_white',
      name: 'White Apron',
      description: 'A classic clean white apron',
      category: ShopCategory.outfits,
      price: 0,
      isDefault: true,
    ),
    ShopItem(
      id: 'outfit_apron_red',
      name: 'Red Apron',
      description: 'A bold red apron for confident chefs',
      category: ShopCategory.outfits,
      price: 40,
    ),
    ShopItem(
      id: 'outfit_sushi',
      name: 'Sushi Chef Wrap',
      description: 'Traditional sushi chef attire',
      category: ShopCategory.outfits,
      price: 80,
    ),
    ShopItem(
      id: 'outfit_bbq',
      name: 'BBQ Master Vest',
      description: 'Rugged gear for the grill master',
      category: ShopCategory.outfits,
      price: 100,
    ),
    ShopItem(
      id: 'outfit_golden',
      name: 'Golden Chef Coat',
      description: 'A luxurious golden chef coat',
      category: ShopCategory.outfits,
      price: 200,
      requiredAchievementId: 'ach_cook_100',
    ),
  ];

  // ============ ACCESSORIES ============

  static const List<ShopItem> accessories = [
    ShopItem(
      id: 'acc_whisk',
      name: 'Whisk',
      description: 'A trusty whisk for all occasions',
      category: ShopCategory.accessories,
      price: 25,
    ),
    ShopItem(
      id: 'acc_rolling_pin',
      name: 'Rolling Pin',
      description: 'Perfect for the baking enthusiast',
      category: ShopCategory.accessories,
      price: 50,
    ),
    ShopItem(
      id: 'acc_trophy',
      name: 'Golden Trophy',
      description: 'A gleaming trophy for the dedicated chef',
      category: ShopCategory.accessories,
      price: 150,
      requiredAchievementId: 'ach_streak_30',
    ),
  ];

  // ============ BACKGROUNDS ============

  static const List<ShopItem> backgrounds = [
    ShopItem(
      id: 'bg_kitchen_basic',
      name: 'Home Kitchen',
      description: 'A cozy home kitchen',
      category: ShopCategory.backgrounds,
      price: 0,
      isDefault: true,
    ),
    ShopItem(
      id: 'bg_kitchen_pro',
      name: 'Pro Kitchen',
      description: 'A sleek professional kitchen',
      category: ShopCategory.backgrounds,
      price: 100,
    ),
    ShopItem(
      id: 'bg_kitchen_garden',
      name: 'Garden Kitchen',
      description: 'Cook outdoors surrounded by nature',
      category: ShopCategory.backgrounds,
      price: 150,
    ),
  ];

  // ============ BODY COLORS ============

  static const List<ShopItem> bodyColors = [
    ShopItem(
      id: 'color_white',
      name: 'Classic White',
      description: 'Clean and classic',
      category: ShopCategory.bodyColors,
      price: 0,
      isDefault: true,
    ),
    ShopItem(
      id: 'color_peach',
      name: 'Peach',
      description: 'Warm and friendly',
      category: ShopCategory.bodyColors,
      price: 20,
    ),
    ShopItem(
      id: 'color_mint',
      name: 'Mint Green',
      description: 'Fresh and cool',
      category: ShopCategory.bodyColors,
      price: 20,
    ),
    ShopItem(
      id: 'color_sky',
      name: 'Sky Blue',
      description: 'Light and airy',
      category: ShopCategory.bodyColors,
      price: 20,
    ),
    ShopItem(
      id: 'color_lavender',
      name: 'Lavender',
      description: 'Soft and elegant',
      category: ShopCategory.bodyColors,
      price: 20,
    ),
  ];

  // ============ ALL ITEMS ============

  static List<ShopItem> get all => [
    ...hats,
    ...outfits,
    ...accessories,
    ...backgrounds,
    ...bodyColors,
  ];

  /// Default items that are owned from the start
  static Set<String> get defaultOwnedIds =>
      all.where((item) => item.isDefault || item.isFree).map((e) => e.id).toSet();

  /// Get item by ID
  static ShopItem? getById(String id) {
    try {
      return all.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get items by category
  static List<ShopItem> getByCategory(ShopCategory category) {
    return all.where((item) => item.category == category).toList();
  }

  /// Get items affordable with given coins (excluding achievement-locked)
  static List<ShopItem> getAffordable(int coins, {Set<String>? ownedIds}) {
    return all.where((item) {
      if (ownedIds?.contains(item.id) == true) return false;
      if (item.requiredAchievementId != null) return false;
      return item.price <= coins;
    }).toList();
  }

  /// Check if an achievement-locked item is purchasable
  static bool canPurchase(ShopItem item, int coins, Set<String> completedAchievements, Set<String> ownedItems) {
    if (ownedItems.contains(item.id)) return false;
    if (item.price > coins) return false;
    if (item.requiredAchievementId != null &&
        !completedAchievements.contains(item.requiredAchievementId)) return false;
    return true;
  }
}
