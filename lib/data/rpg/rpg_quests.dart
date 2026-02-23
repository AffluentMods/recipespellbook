import 'dart:math';
import 'package:flutter/material.dart';

// ============ QUEST TYPES ============

enum QuestType {
  createRecipe,
  importRecipe,
  cookRecipe,
  addPhoto,
  addNutrition,
  planMeal,
  completeShoppingList,
  viewRecipes,
  useTimer,
  rateRecipe,
}

extension QuestTypeExtension on QuestType {
  String get displayName {
    switch (this) {
      case QuestType.createRecipe: return 'Create Recipe';
      case QuestType.importRecipe: return 'Import Recipe';
      case QuestType.cookRecipe: return 'Cook Recipe';
      case QuestType.addPhoto: return 'Add Photo';
      case QuestType.addNutrition: return 'Add Nutrition';
      case QuestType.planMeal: return 'Plan Meal';
      case QuestType.completeShoppingList: return 'Complete Shopping';
      case QuestType.viewRecipes: return 'Browse Recipes';
      case QuestType.useTimer: return 'Use Timer';
      case QuestType.rateRecipe: return 'Rate Recipe';
    }
  }

  IconData get icon {
    switch (this) {
      case QuestType.createRecipe: return Icons.edit_note;
      case QuestType.importRecipe: return Icons.download;
      case QuestType.cookRecipe: return Icons.local_fire_department;
      case QuestType.addPhoto: return Icons.camera_alt;
      case QuestType.addNutrition: return Icons.monitor_weight;
      case QuestType.planMeal: return Icons.calendar_today;
      case QuestType.completeShoppingList: return Icons.shopping_cart;
      case QuestType.viewRecipes: return Icons.menu_book;
      case QuestType.useTimer: return Icons.timer;
      case QuestType.rateRecipe: return Icons.star;
    }
  }

  Color get color {
    switch (this) {
      case QuestType.createRecipe: return Colors.blue;
      case QuestType.importRecipe: return Colors.green;
      case QuestType.cookRecipe: return Colors.orange;
      case QuestType.addPhoto: return Colors.purple;
      case QuestType.addNutrition: return Colors.teal;
      case QuestType.planMeal: return Colors.amber;
      case QuestType.completeShoppingList: return Colors.pink;
      case QuestType.viewRecipes: return Colors.indigo;
      case QuestType.useTimer: return Colors.red;
      case QuestType.rateRecipe: return Colors.yellow;
    }
  }
}

// ============ QUEST DIFFICULTY ============

enum QuestDifficulty {
  easy,
  medium,
  hard,
}

extension QuestDifficultyExtension on QuestDifficulty {
  int get xpMultiplier {
    switch (this) {
      case QuestDifficulty.easy: return 1;
      case QuestDifficulty.medium: return 2;
      case QuestDifficulty.hard: return 3;
    }
  }

  int get goldReward {
    switch (this) {
      case QuestDifficulty.easy: return 10;
      case QuestDifficulty.medium: return 25;
      case QuestDifficulty.hard: return 50;
    }
  }

  Color get color {
    switch (this) {
      case QuestDifficulty.easy: return Colors.green;
      case QuestDifficulty.medium: return Colors.orange;
      case QuestDifficulty.hard: return Colors.red;
    }
  }

  String get displayName {
    switch (this) {
      case QuestDifficulty.easy: return 'Easy';
      case QuestDifficulty.medium: return 'Medium';
      case QuestDifficulty.hard: return 'Hard';
    }
  }
}

// ============ QUEST DEFINITION ============

class DailyQuest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final QuestDifficulty difficulty;
  final int targetCount;
  final int currentProgress;
  final int xpReward;
  final bool isCompleted;
  final bool isClaimed;

  const DailyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.targetCount,
    this.currentProgress = 0,
    required this.xpReward,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  DailyQuest copyWith({
    int? currentProgress,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return DailyQuest(
      id: id,
      title: title,
      description: description,
      type: type,
      difficulty: difficulty,
      targetCount: targetCount,
      currentProgress: currentProgress ?? this.currentProgress,
      xpReward: xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  double get progressPercent => (currentProgress / targetCount).clamp(0.0, 1.0);
  int get goldReward => difficulty.goldReward;
}

// ============ QUEST TEMPLATES ============

class QuestTemplates {
  static const List<_QuestTemplate> _templates = [
    // Easy quests
    _QuestTemplate(
      titleTemplate: 'Quick Recipe',
      descriptionTemplate: 'Create {count} recipe',
      type: QuestType.createRecipe,
      difficulty: QuestDifficulty.easy,
      minCount: 1,
      maxCount: 1,
      baseXp: 30,
    ),
    _QuestTemplate(
      titleTemplate: 'Web Scraper',
      descriptionTemplate: 'Import {count} recipe from URL',
      type: QuestType.importRecipe,
      difficulty: QuestDifficulty.easy,
      minCount: 1,
      maxCount: 1,
      baseXp: 25,
    ),
    _QuestTemplate(
      titleTemplate: 'Home Chef',
      descriptionTemplate: 'Cook {count} recipe',
      type: QuestType.cookRecipe,
      difficulty: QuestDifficulty.easy,
      minCount: 1,
      maxCount: 1,
      baseXp: 25,
    ),
    _QuestTemplate(
      titleTemplate: 'Meal Planner',
      descriptionTemplate: 'Plan {count} meal',
      type: QuestType.planMeal,
      difficulty: QuestDifficulty.easy,
      minCount: 1,
      maxCount: 2,
      baseXp: 20,
    ),
    _QuestTemplate(
      titleTemplate: 'Food Photographer',
      descriptionTemplate: 'Add a photo to {count} recipe',
      type: QuestType.addPhoto,
      difficulty: QuestDifficulty.easy,
      minCount: 1,
      maxCount: 1,
      baseXp: 20,
    ),

    // Medium quests
    _QuestTemplate(
      titleTemplate: 'Recipe Builder',
      descriptionTemplate: 'Create {count} recipes',
      type: QuestType.createRecipe,
      difficulty: QuestDifficulty.medium,
      minCount: 2,
      maxCount: 3,
      baseXp: 60,
    ),
    _QuestTemplate(
      titleTemplate: 'Import Master',
      descriptionTemplate: 'Import {count} recipes',
      type: QuestType.importRecipe,
      difficulty: QuestDifficulty.medium,
      minCount: 3,
      maxCount: 5,
      baseXp: 50,
    ),
    _QuestTemplate(
      titleTemplate: 'Kitchen Hero',
      descriptionTemplate: 'Cook {count} recipes',
      type: QuestType.cookRecipe,
      difficulty: QuestDifficulty.medium,
      minCount: 2,
      maxCount: 3,
      baseXp: 50,
    ),
    _QuestTemplate(
      titleTemplate: 'Week Planner',
      descriptionTemplate: 'Plan {count} meals',
      type: QuestType.planMeal,
      difficulty: QuestDifficulty.medium,
      minCount: 5,
      maxCount: 7,
      baseXp: 40,
    ),
    _QuestTemplate(
      titleTemplate: 'Nutrition Tracker',
      descriptionTemplate: 'Add nutrition to {count} recipes',
      type: QuestType.addNutrition,
      difficulty: QuestDifficulty.medium,
      minCount: 2,
      maxCount: 3,
      baseXp: 45,
    ),
    _QuestTemplate(
      titleTemplate: 'Shopping Pro',
      descriptionTemplate: 'Complete your shopping list',
      type: QuestType.completeShoppingList,
      difficulty: QuestDifficulty.medium,
      minCount: 1,
      maxCount: 1,
      baseXp: 40,
    ),

    // Hard quests
    _QuestTemplate(
      titleTemplate: 'Recipe Marathon',
      descriptionTemplate: 'Create {count} recipes',
      type: QuestType.createRecipe,
      difficulty: QuestDifficulty.hard,
      minCount: 5,
      maxCount: 5,
      baseXp: 100,
    ),
    _QuestTemplate(
      titleTemplate: 'Import Frenzy',
      descriptionTemplate: 'Import {count} recipes',
      type: QuestType.importRecipe,
      difficulty: QuestDifficulty.hard,
      minCount: 10,
      maxCount: 10,
      baseXp: 80,
    ),
    _QuestTemplate(
      titleTemplate: 'Cooking Spree',
      descriptionTemplate: 'Cook {count} recipes',
      type: QuestType.cookRecipe,
      difficulty: QuestDifficulty.hard,
      minCount: 5,
      maxCount: 5,
      baseXp: 80,
    ),
    _QuestTemplate(
      titleTemplate: 'Photo Album',
      descriptionTemplate: 'Add photos to {count} recipes',
      type: QuestType.addPhoto,
      difficulty: QuestDifficulty.hard,
      minCount: 5,
      maxCount: 5,
      baseXp: 70,
    ),
  ];

  /// Generate daily quests based on day seed
  static List<DailyQuest> generateDailyQuests(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);

    // Get templates by difficulty
    final easyTemplates = _templates.where((t) => t.difficulty == QuestDifficulty.easy).toList();
    final mediumTemplates = _templates.where((t) => t.difficulty == QuestDifficulty.medium).toList();
    final hardTemplates = _templates.where((t) => t.difficulty == QuestDifficulty.hard).toList();

    // Pick quests: 2 easy, 2 medium, 1 hard
    final quests = <DailyQuest>[];

    // Pick 2 random easy
    easyTemplates.shuffle(random);
    for (var i = 0; i < 2 && i < easyTemplates.length; i++) {
      quests.add(easyTemplates[i].generate(random, 'daily_easy_$i'));
    }

    // Pick 2 random medium
    mediumTemplates.shuffle(random);
    for (var i = 0; i < 2 && i < mediumTemplates.length; i++) {
      quests.add(mediumTemplates[i].generate(random, 'daily_medium_$i'));
    }

    // Pick 1 random hard
    hardTemplates.shuffle(random);
    if (hardTemplates.isNotEmpty) {
      quests.add(hardTemplates[0].generate(random, 'daily_hard_0'));
    }

    return quests;
  }
}

class _QuestTemplate {
  final String titleTemplate;
  final String descriptionTemplate;
  final QuestType type;
  final QuestDifficulty difficulty;
  final int minCount;
  final int maxCount;
  final int baseXp;

  const _QuestTemplate({
    required this.titleTemplate,
    required this.descriptionTemplate,
    required this.type,
    required this.difficulty,
    required this.minCount,
    required this.maxCount,
    required this.baseXp,
  });

  DailyQuest generate(Random random, String id) {
    final count = minCount + random.nextInt(maxCount - minCount + 1);
    final description = descriptionTemplate
        .replaceAll('{count}', count.toString())
        .replaceAll('1 recipe', 'a recipe')
        .replaceAll('1 meal', 'a meal');

    return DailyQuest(
      id: id,
      title: titleTemplate,
      description: description,
      type: type,
      difficulty: difficulty,
      targetCount: count,
      xpReward: baseXp * difficulty.xpMultiplier,
    );
  }
}

// ============ WEEKLY CHALLENGE ============

class WeeklyChallenge {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  final int currentProgress;
  final int xpReward;
  final int goldReward;
  final int gemReward;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final bool isClaimed;

  const WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    this.currentProgress = 0,
    required this.xpReward,
    required this.goldReward,
    required this.gemReward,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  double get progressPercent => (currentProgress / targetCount).clamp(0.0, 1.0);

  Duration get timeRemaining => endDate.difference(DateTime.now());

  String get timeRemainingDisplay {
    final remaining = timeRemaining;
    if (remaining.isNegative) return 'Expired';
    if (remaining.inDays > 0) return '${remaining.inDays}d remaining';
    if (remaining.inHours > 0) return '${remaining.inHours}h remaining';
    return '${remaining.inMinutes}m remaining';
  }

  static WeeklyChallenge getCurrentWeekly() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));

    // Rotate weekly challenges
    final weekOfYear = now.difference(DateTime(now.year, 1, 1)).inDays ~/ 7;
    final challenges = [
      WeeklyChallenge(
        id: 'weekly_recipes',
        title: 'Recipe Week',
        description: 'Create or import 10 recipes this week',
        targetCount: 10,
        xpReward: 500,
        goldReward: 100,
        gemReward: 10,
        startDate: start,
        endDate: end,
      ),
      WeeklyChallenge(
        id: 'weekly_cook',
        title: 'Cooking Week',
        description: 'Cook 7 different recipes this week',
        targetCount: 7,
        xpReward: 400,
        goldReward: 75,
        gemReward: 10,
        startDate: start,
        endDate: end,
      ),
      WeeklyChallenge(
        id: 'weekly_plan',
        title: 'Planning Week',
        description: 'Plan 14 meals this week',
        targetCount: 14,
        xpReward: 350,
        goldReward: 75,
        gemReward: 10,
        startDate: start,
        endDate: end,
      ),
      WeeklyChallenge(
        id: 'weekly_photo',
        title: 'Photography Week',
        description: 'Add photos to 5 recipes this week',
        targetCount: 5,
        xpReward: 300,
        goldReward: 50,
        gemReward: 5,
        startDate: start,
        endDate: end,
      ),
    ];

    return challenges[weekOfYear % challenges.length];
  }
}