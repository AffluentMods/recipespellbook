// lib/data/rpg/rpg_achievements.dart
// Achievement definitions for Recipe Spellbook RPG System

import 'package:flutter/material.dart';

// ============ ACHIEVEMENT CATEGORY ============

enum AchievementCategory {
  recipes,      // Recipe creation/collection
  cooking,      // Cooking mode usage
  community,    // Uploads, downloads, ratings
  collection,   // Collecting cosmetics, cookbooks
  mastery,      // Leveling, XP milestones
  dedication,   // Streaks, daily login
  exploration,  // Using features
  special,      // Premium, events, rare
}

extension AchievementCategoryExtension on AchievementCategory {
  String get displayName {
    switch (this) {
      case AchievementCategory.recipes: return 'Recipes';
      case AchievementCategory.cooking: return 'Cooking';
      case AchievementCategory.community: return 'Community';
      case AchievementCategory.collection: return 'Collection';
      case AchievementCategory.mastery: return 'Mastery';
      case AchievementCategory.dedication: return 'Dedication';
      case AchievementCategory.exploration: return 'Exploration';
      case AchievementCategory.special: return 'Special';
    }
  }

  IconData get icon {
    switch (this) {
      case AchievementCategory.recipes: return Icons.menu_book;
      case AchievementCategory.cooking: return Icons.local_fire_department;
      case AchievementCategory.community: return Icons.people;
      case AchievementCategory.collection: return Icons.collections_bookmark;
      case AchievementCategory.mastery: return Icons.stars;
      case AchievementCategory.dedication: return Icons.calendar_today;
      case AchievementCategory.exploration: return Icons.explore;
      case AchievementCategory.special: return Icons.auto_awesome;
    }
  }

  Color get color {
    switch (this) {
      case AchievementCategory.recipes: return Colors.amber;
      case AchievementCategory.cooking: return Colors.orange;
      case AchievementCategory.community: return Colors.blue;
      case AchievementCategory.collection: return Colors.purple;
      case AchievementCategory.mastery: return Colors.yellow;
      case AchievementCategory.dedication: return Colors.green;
      case AchievementCategory.exploration: return Colors.teal;
      case AchievementCategory.special: return Colors.pink;
    }
  }
}

// ============ ACHIEVEMENT TIER ============

enum AchievementTier {
  bronze,   // Easy, 5 gems
  silver,   // Medium, 15 gems
  gold,     // Hard, 30 gems
  platinum, // Very hard, 50 gems
  diamond,  // Extreme, 100 gems
}

extension AchievementTierExtension on AchievementTier {
  int get gemReward {
    switch (this) {
      case AchievementTier.bronze: return 5;
      case AchievementTier.silver: return 15;
      case AchievementTier.gold: return 30;
      case AchievementTier.platinum: return 50;
      case AchievementTier.diamond: return 100;
    }
  }

  int get xpReward {
    switch (this) {
      case AchievementTier.bronze: return 25;
      case AchievementTier.silver: return 50;
      case AchievementTier.gold: return 100;
      case AchievementTier.platinum: return 200;
      case AchievementTier.diamond: return 500;
    }
  }

  Color get color {
    switch (this) {
      case AchievementTier.bronze: return const Color(0xFFCD7F32);
      case AchievementTier.silver: return const Color(0xFFC0C0C0);
      case AchievementTier.gold: return const Color(0xFFFFD700);
      case AchievementTier.platinum: return const Color(0xFFE5E4E2);
      case AchievementTier.diamond: return const Color(0xFFB9F2FF);
    }
  }

  String get displayName {
    switch (this) {
      case AchievementTier.bronze: return 'Bronze';
      case AchievementTier.silver: return 'Silver';
      case AchievementTier.gold: return 'Gold';
      case AchievementTier.platinum: return 'Platinum';
      case AchievementTier.diamond: return 'Diamond';
    }
  }
}

// ============ ACHIEVEMENT DEFINITION ============

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;              // Emoji or icon name
  final AchievementCategory category;
  final AchievementTier tier;
  final int targetValue;          // Target to reach (e.g., 100 recipes)
  final String? unlocksItemId;    // Cosmetic/title unlocked
  final bool isSecret;            // Hidden until unlocked
  final bool isRepeatable;        // Can earn multiple times

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.tier,
    required this.targetValue,
    this.unlocksItemId,
    this.isSecret = false,
    this.isRepeatable = false,
  });

  int get gemReward => tier.gemReward;
  int get xpReward => tier.xpReward;
}

// ============ ALL ACHIEVEMENTS ============

class RpgAchievements {
  static const List<Achievement> all = [
    // ========== RECIPES ==========
    // Recipe creation milestones
    Achievement(
      id: 'ach_recipes_1',
      name: 'First Recipe',
      description: 'Create your first recipe',
      icon: '📝',
      category: AchievementCategory.recipes,
      tier: AchievementTier.bronze,
      targetValue: 1,
    ),
    Achievement(
      id: 'ach_recipes_10',
      name: 'Recipe Enthusiast',
      description: 'Have 10 recipes in your collection',
      icon: '📚',
      category: AchievementCategory.recipes,
      tier: AchievementTier.bronze,
      targetValue: 10,
    ),
    Achievement(
      id: 'ach_recipes_50',
      name: 'Recipe Hobbyist',
      description: 'Have 50 recipes in your collection',
      icon: '📖',
      category: AchievementCategory.recipes,
      tier: AchievementTier.silver,
      targetValue: 50,
    ),
    Achievement(
      id: 'ach_recipes_100',
      name: 'Recipe Collector',
      description: 'Have 100 recipes in your collection',
      icon: '📕',
      category: AchievementCategory.recipes,
      tier: AchievementTier.gold,
      targetValue: 100,
      unlocksItemId: 'title_collector',
    ),
    Achievement(
      id: 'ach_recipes_250',
      name: 'Recipe Hoarder',
      description: 'Have 250 recipes in your collection',
      icon: '📗',
      category: AchievementCategory.recipes,
      tier: AchievementTier.platinum,
      targetValue: 250,
    ),
    Achievement(
      id: 'ach_recipes_500',
      name: 'Grand Archivist',
      description: 'Have 500 recipes in your collection',
      icon: '📘',
      category: AchievementCategory.recipes,
      tier: AchievementTier.diamond,
      targetValue: 500,
      unlocksItemId: 'title_archivist',
    ),

    // Import milestones
    Achievement(
      id: 'ach_import_1',
      name: 'First Import',
      description: 'Import your first recipe',
      icon: '⬇️',
      category: AchievementCategory.recipes,
      tier: AchievementTier.bronze,
      targetValue: 1,
    ),
    Achievement(
      id: 'ach_import_25',
      name: 'Import Apprentice',
      description: 'Import 25 recipes',
      icon: '📥',
      category: AchievementCategory.recipes,
      tier: AchievementTier.silver,
      targetValue: 25,
    ),
    Achievement(
      id: 'ach_import_100',
      name: 'Import Master',
      description: 'Import 100 recipes',
      icon: '🌐',
      category: AchievementCategory.recipes,
      tier: AchievementTier.gold,
      targetValue: 100,
    ),

    // Photo milestones
    Achievement(
      id: 'ach_photos_10',
      name: 'Foodographer',
      description: 'Add photos to 10 recipes',
      icon: '📸',
      category: AchievementCategory.recipes,
      tier: AchievementTier.bronze,
      targetValue: 10,
    ),
    Achievement(
      id: 'ach_photos_50',
      name: 'Photo Enthusiast',
      description: 'Add photos to 50 recipes',
      icon: '📷',
      category: AchievementCategory.recipes,
      tier: AchievementTier.silver,
      targetValue: 50,
    ),

    // ========== COOKING ==========
    Achievement(
      id: 'ach_cook_1',
      name: 'First Meal',
      description: 'Cook your first recipe',
      icon: '🍳',
      category: AchievementCategory.cooking,
      tier: AchievementTier.bronze,
      targetValue: 1,
    ),
    Achievement(
      id: 'ach_cook_10',
      name: 'Home Cook',
      description: 'Cook 10 recipes',
      icon: '👨‍🍳',
      category: AchievementCategory.cooking,
      tier: AchievementTier.bronze,
      targetValue: 10,
    ),
    Achievement(
      id: 'ach_cook_50',
      name: 'Experienced Chef',
      description: 'Cook 50 recipes',
      icon: '🔥',
      category: AchievementCategory.cooking,
      tier: AchievementTier.silver,
      targetValue: 50,
    ),
    Achievement(
      id: 'ach_cook_100',
      name: 'Kitchen Master',
      description: 'Cook 100 recipes',
      icon: '⭐',
      category: AchievementCategory.cooking,
      tier: AchievementTier.gold,
      targetValue: 100,
    ),
    Achievement(
      id: 'ach_cook_500',
      name: 'Culinary Legend',
      description: 'Cook 500 recipes',
      icon: '🏆',
      category: AchievementCategory.cooking,
      tier: AchievementTier.diamond,
      targetValue: 500,
    ),

    // ========== COMMUNITY ==========
    Achievement(
      id: 'ach_upload_1',
      name: 'First Upload',
      description: 'Upload your first cookbook to the community',
      icon: '⬆️',
      category: AchievementCategory.community,
      tier: AchievementTier.bronze,
      targetValue: 1,
    ),
    Achievement(
      id: 'ach_upload_5',
      name: 'Generous Chef',
      description: 'Upload 5 cookbooks to the community',
      icon: '🎁',
      category: AchievementCategory.community,
      tier: AchievementTier.silver,
      targetValue: 5,
      unlocksItemId: 'title_generous',
    ),
    Achievement(
      id: 'ach_upload_10',
      name: 'Community Pillar',
      description: 'Upload 10 cookbooks to the community',
      icon: '🏛️',
      category: AchievementCategory.community,
      tier: AchievementTier.gold,
      targetValue: 10,
    ),
    Achievement(
      id: 'ach_downloads_10',
      name: 'Getting Popular',
      description: 'Have your cookbooks downloaded 10 times',
      icon: '📈',
      category: AchievementCategory.community,
      tier: AchievementTier.bronze,
      targetValue: 10,
    ),
    Achievement(
      id: 'ach_downloads_50',
      name: 'Rising Star',
      description: 'Have your cookbooks downloaded 50 times',
      icon: '🌟',
      category: AchievementCategory.community,
      tier: AchievementTier.silver,
      targetValue: 50,
    ),
    Achievement(
      id: 'ach_downloads_100',
      name: 'Celebrity Chef',
      description: 'Have your cookbooks downloaded 100 times',
      icon: '👑',
      category: AchievementCategory.community,
      tier: AchievementTier.gold,
      targetValue: 100,
      unlocksItemId: 'title_celebrity',
    ),
    Achievement(
      id: 'ach_downloads_500',
      name: 'Culinary Icon',
      description: 'Have your cookbooks downloaded 500 times',
      icon: '🎖️',
      category: AchievementCategory.community,
      tier: AchievementTier.diamond,
      targetValue: 500,
    ),

    // Ratings
    Achievement(
      id: 'ach_rating_5star',
      name: 'Five Star Chef',
      description: 'Receive a 5-star rating on a cookbook',
      icon: '⭐',
      category: AchievementCategory.community,
      tier: AchievementTier.bronze,
      targetValue: 1,
    ),
    Achievement(
      id: 'ach_ratings_10',
      name: 'Well Reviewed',
      description: 'Receive 10 ratings on your cookbooks',
      icon: '📊',
      category: AchievementCategory.community,
      tier: AchievementTier.silver,
      targetValue: 10,
    ),

    // ========== COLLECTION ==========
    Achievement(
      id: 'ach_cookbooks_3',
      name: 'Organized Chef',
      description: 'Create 3 cookbooks',
      icon: '📚',
      category: AchievementCategory.collection,
      tier: AchievementTier.bronze,
      targetValue: 3,
    ),
    Achievement(
      id: 'ach_cookbooks_10',
      name: 'Cookbook Curator',
      description: 'Create 10 cookbooks',
      icon: '📖',
      category: AchievementCategory.collection,
      tier: AchievementTier.silver,
      targetValue: 10,
    ),
    Achievement(
      id: 'ach_avatars_5',
      name: 'Fashion Forward',
      description: 'Own 5 different avatars',
      icon: '🎭',
      category: AchievementCategory.collection,
      tier: AchievementTier.bronze,
      targetValue: 5,
    ),
    Achievement(
      id: 'ach_pets_3',
      name: 'Pet Collector',
      description: 'Own 3 different pets',
      icon: '🐾',
      category: AchievementCategory.collection,
      tier: AchievementTier.silver,
      targetValue: 3,
    ),

    // ========== MASTERY ==========
    Achievement(
      id: 'ach_level_5',
      name: 'Getting Started',
      description: 'Reach level 5',
      icon: '🌱',
      category: AchievementCategory.mastery,
      tier: AchievementTier.bronze,
      targetValue: 5,
    ),
    Achievement(
      id: 'ach_level_10',
      name: 'Journeyman',
      description: 'Reach level 10',
      icon: '📈',
      category: AchievementCategory.mastery,
      tier: AchievementTier.silver,
      targetValue: 10,
      unlocksItemId: 'title_journeyman',
    ),
    Achievement(
      id: 'ach_level_25',
      name: 'Expert',
      description: 'Reach level 25',
      icon: '🎯',
      category: AchievementCategory.mastery,
      tier: AchievementTier.gold,
      targetValue: 25,
      unlocksItemId: 'title_master',
    ),
    Achievement(
      id: 'ach_level_50',
      name: 'Master',
      description: 'Reach level 50',
      icon: '🏅',
      category: AchievementCategory.mastery,
      tier: AchievementTier.platinum,
      targetValue: 50,
      unlocksItemId: 'title_grandmaster',
    ),
    Achievement(
      id: 'ach_level_100',
      name: 'Legend',
      description: 'Reach level 100',
      icon: '🏆',
      category: AchievementCategory.mastery,
      tier: AchievementTier.diamond,
      targetValue: 100,
      unlocksItemId: 'title_legendary',
    ),
    Achievement(
      id: 'ach_xp_10000',
      name: 'XP Grinder',
      description: 'Earn 10,000 total XP',
      icon: '✨',
      category: AchievementCategory.mastery,
      tier: AchievementTier.silver,
      targetValue: 10000,
    ),
    Achievement(
      id: 'ach_xp_100000',
      name: 'XP Master',
      description: 'Earn 100,000 total XP',
      icon: '💫',
      category: AchievementCategory.mastery,
      tier: AchievementTier.platinum,
      targetValue: 100000,
    ),

    // ========== DEDICATION ==========
    Achievement(
      id: 'ach_streak_7',
      name: 'Weekly Regular',
      description: 'Maintain a 7-day login streak',
      icon: '📅',
      category: AchievementCategory.dedication,
      tier: AchievementTier.bronze,
      targetValue: 7,
    ),
    Achievement(
      id: 'ach_streak_14',
      name: 'Two Week Champion',
      description: 'Maintain a 14-day login streak',
      icon: '🗓️',
      category: AchievementCategory.dedication,
      tier: AchievementTier.silver,
      targetValue: 14,
    ),
    Achievement(
      id: 'ach_streak_30',
      name: 'Dedicated Chef',
      description: 'Maintain a 30-day login streak',
      icon: '🔥',
      category: AchievementCategory.dedication,
      tier: AchievementTier.gold,
      targetValue: 30,
      unlocksItemId: 'title_dedicated',
    ),
    Achievement(
      id: 'ach_streak_100',
      name: 'Centurion',
      description: 'Maintain a 100-day login streak',
      icon: '💯',
      category: AchievementCategory.dedication,
      tier: AchievementTier.platinum,
      targetValue: 100,
    ),
    Achievement(
      id: 'ach_streak_365',
      name: 'Year-Round Chef',
      description: 'Maintain a 365-day login streak',
      icon: '🎊',
      category: AchievementCategory.dedication,
      tier: AchievementTier.diamond,
      targetValue: 365,
      isSecret: true,
    ),

    // ========== EXPLORATION ==========
    Achievement(
      id: 'ach_meal_plan_week',
      name: 'Meal Planner',
      description: 'Plan meals for a full week',
      icon: '📋',
      category: AchievementCategory.exploration,
      tier: AchievementTier.bronze,
      targetValue: 7,
    ),
    Achievement(
      id: 'ach_shopping_complete',
      name: 'Shopping Spree',
      description: 'Complete 10 shopping lists',
      icon: '🛒',
      category: AchievementCategory.exploration,
      tier: AchievementTier.bronze,
      targetValue: 10,
    ),
    Achievement(
      id: 'ach_nutrition_10',
      name: 'Nutrition Tracker',
      description: 'Add nutrition info to 10 recipes',
      icon: '🥗',
      category: AchievementCategory.exploration,
      tier: AchievementTier.silver,
      targetValue: 10,
    ),
    Achievement(
      id: 'ach_tags_used',
      name: 'Tag Master',
      description: 'Use 20 different tags',
      icon: '🏷️',
      category: AchievementCategory.exploration,
      tier: AchievementTier.bronze,
      targetValue: 20,
    ),
    Achievement(
      id: 'ach_all_import_methods',
      name: 'Import Expert',
      description: 'Use all import methods (URL, OCR, Manual, PDF)',
      icon: '🔄',
      category: AchievementCategory.exploration,
      tier: AchievementTier.silver,
      targetValue: 4,
    ),

    // ========== SPECIAL ==========
    Achievement(
      id: 'ach_premium',
      name: 'Premium Supporter',
      description: 'Purchase premium to support development',
      icon: '💎',
      category: AchievementCategory.special,
      tier: AchievementTier.gold,
      targetValue: 1,
      unlocksItemId: 'title_premium',
    ),
    Achievement(
      id: 'ach_early_adopter',
      name: 'Early Adopter',
      description: 'Joined during the first year',
      icon: '🚀',
      category: AchievementCategory.special,
      tier: AchievementTier.silver,
      targetValue: 1,
      isSecret: true,
    ),
    Achievement(
      id: 'ach_bug_reporter',
      name: 'Bug Hunter',
      description: 'Report a bug that gets fixed',
      icon: '🐛',
      category: AchievementCategory.special,
      tier: AchievementTier.silver,
      targetValue: 1,
      isSecret: true,
    ),
    Achievement(
      id: 'ach_lottery_win',
      name: 'Lucky Chef',
      description: 'Win the rare pet in the gem lottery',
      icon: '🎰',
      category: AchievementCategory.special,
      tier: AchievementTier.diamond,
      targetValue: 1,
      isSecret: true,
    ),

    // Boss damage achievements
    Achievement(
      id: 'ach_damage_100',
      name: 'First Blood',
      description: 'Deal 100 total damage to bosses',
      icon: '⚔️',
      category: AchievementCategory.special,
      tier: AchievementTier.bronze,
      targetValue: 100,
    ),
    Achievement(
      id: 'ach_damage_1000',
      name: 'Boss Slayer',
      description: 'Deal 1,000 total damage to bosses',
      icon: '🗡️',
      category: AchievementCategory.special,
      tier: AchievementTier.silver,
      targetValue: 1000,
    ),
    Achievement(
      id: 'ach_damage_10000',
      name: 'Dragon Slayer',
      description: 'Deal 10,000 total damage to bosses',
      icon: '🐉',
      category: AchievementCategory.special,
      tier: AchievementTier.gold,
      targetValue: 10000,
    ),
  ];

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get achievements by category
  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }

  /// Get achievements by tier
  static List<Achievement> getByTier(AchievementTier tier) {
    return all.where((a) => a.tier == tier).toList();
  }

  /// Get visible achievements (non-secret or already completed)
  static List<Achievement> getVisible(Set<String> completedIds) {
    return all.where((a) => !a.isSecret || completedIds.contains(a.id)).toList();
  }
}