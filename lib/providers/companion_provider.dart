// lib/providers/companion_provider.dart
// Cooking Companion State Management for Recipe Spellbook RPG system

import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/rpg/rpg_companion.dart';

// ============ COMPANION STATE ============

class CompanionState {
  final CompanionData? companion;
  final String? currentMessage;
  final bool isMessageVisible;
  final bool isLoading;

  const CompanionState({
    this.companion,
    this.currentMessage,
    this.isMessageVisible = false,
    this.isLoading = true,
  });

  CompanionState copyWith({
    CompanionData? companion,
    bool clearCompanion = false,
    String? currentMessage,
    bool clearCurrentMessage = false,
    bool? isMessageVisible,
    bool? isLoading,
  }) {
    return CompanionState(
      companion: clearCompanion ? null : (companion ?? this.companion),
      currentMessage: clearCurrentMessage ? null : (currentMessage ?? this.currentMessage),
      isMessageVisible: isMessageVisible ?? this.isMessageVisible,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ============ COMPANION NOTIFIER ============

class CompanionNotifier extends Notifier<CompanionState> {
  static const _companionKey = 'rpg_companion';

  @override
  CompanionState build() {
    _loadState();
    return const CompanionState(isLoading: true);
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final companionJson = prefs.getString(_companionKey);

    CompanionData? companion;
    if (companionJson != null) {
      try {
        companion = CompanionData.fromJson(jsonDecode(companionJson));
      } catch (_) {
        companion = null;
      }
    }

    if (companion != null) {
      // Determine initial mood based on activity
      final updatedMood = _determineMood(companion);
      companion = companion.copyWith(
        mood: updatedMood,
        lastInteraction: DateTime.now(),
      );
    }

    state = CompanionState(
      companion: companion,
      isLoading: false,
    );

    if (companion != null) {
      await _saveCompanion();
    }
  }

  Future<void> _saveCompanion() async {
    if (state.companion == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_companionKey, jsonEncode(state.companion!.toJson()));
  }

  // ============ COMPANION CREATION ============

  Future<void> createCompanion(String name) async {
    final companion = CompanionData.newCompanion(name);

    state = CompanionState(
      companion: companion,
      currentMessage: 'Hi, I\'m $name! I\'m so excited to cook with you! ${companion.type.emoji}',
      isMessageVisible: true,
      isLoading: false,
    );

    await _saveCompanion();
  }

  // ============ MOOD SYSTEM ============

  CompanionMood _determineMood(CompanionData companion) {
    final now = DateTime.now();

    // Check last cook date for activity-based moods
    if (companion.lastCookDate != null) {
      final timeSinceCook = now.difference(companion.lastCookDate!);

      if (timeSinceCook.inMinutes <= 60) {
        return CompanionMood.excited;
      }
      if (timeSinceCook.inHours <= 24) {
        return CompanionMood.happy;
      }
      if (timeSinceCook.inDays > 3) {
        return CompanionMood.sleepy;
      }
    }

    // Check login streak from rpg profile for proud mood
    // We read from SharedPreferences directly to avoid circular provider deps
    // A streak >= 7 makes the companion proud
    try {
      // Attempt to check streak from stored rpg profile
      _checkStreakForProud().then((isProud) {
        if (isProud && state.companion != null) {
          state = state.copyWith(
            companion: state.companion!.copyWith(mood: CompanionMood.proud),
          );
        }
      });
    } catch (_) {
      // Silently ignore - streak check is best-effort
    }

    return CompanionMood.neutral;
  }

  Future<bool> _checkStreakForProud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('rpg_profile');
      if (profileJson != null) {
        final profileData = jsonDecode(profileJson) as Map<String, dynamic>;
        final loginStreak = profileData['loginStreak'] as int? ?? 0;
        return loginStreak >= 7;
      }
    } catch (_) {
      // Silently ignore
    }
    return false;
  }

  Future<void> updateMood() async {
    if (state.companion == null) return;

    final newMood = _determineMood(state.companion!);
    if (newMood != state.companion!.mood) {
      state = state.copyWith(
        companion: state.companion!.copyWith(mood: newMood),
      );
      await _saveCompanion();
    }
  }

  // ============ COOKING ACTIONS ============

  Future<void> onCookingAction(String? categoryId, String? courseId) async {
    if (state.companion == null) return;

    final companion = state.companion!;
    final updatedCategories = Map<String, int>.from(companion.categoryCooked);

    // Increment category count if provided
    if (categoryId != null && categoryId.isNotEmpty) {
      final key = categoryId.toLowerCase();
      updatedCategories[key] = (updatedCategories[key] ?? 0) + 1;
    }

    // Also track course if provided
    if (courseId != null && courseId.isNotEmpty) {
      final key = courseId.toLowerCase();
      updatedCategories[key] = (updatedCategories[key] ?? 0) + 1;
    }

    state = state.copyWith(
      companion: companion.copyWith(
        categoryCooked: updatedCategories,
        lastCookDate: DateTime.now(),
        lastInteraction: DateTime.now(),
        mood: CompanionMood.excited,
      ),
    );

    await _saveCompanion();

    // Check if companion should evolve
    await checkEvolution();
  }

  // ============ EVOLUTION SYSTEM ============

  Future<void> checkEvolution() async {
    if (state.companion == null) return;

    final companion = state.companion!;
    final categories = companion.categoryCooked;

    // Find the dominant category (must have >= 10 cooked)
    String? dominantCategory;
    int dominantCount = 0;

    for (final entry in categories.entries) {
      if (entry.value >= 10 && entry.value > dominantCount) {
        dominantCategory = entry.key;
        dominantCount = entry.value;
      }
    }

    if (dominantCategory == null) return;

    // Map categories to companion types
    CompanionType? newType;

    // Hearth Spirit - baking focus
    const hearthCategories = ['bread', 'pastry', 'desserts'];
    if (hearthCategories.contains(dominantCategory)) {
      newType = CompanionType.hearthSpirit;
    }

    // Blade Sprite - savory/knife-heavy focus
    const bladeCategories = ['meat', 'poultry', 'fish', 'pasta', 'seafood'];
    if (bladeCategories.contains(dominantCategory)) {
      newType = CompanionType.bladeSprite;
    }

    // Garden Wisp - vegetarian/healthy focus
    const gardenCategories = ['vegetable', 'salad', 'vegan', 'vegetarian'];
    if (gardenCategories.contains(dominantCategory)) {
      newType = CompanionType.gardenWisp;
    }

    // Spice Djinn - spicy/international focus
    const spiceCategories = ['spicy', 'asian', 'mexican', 'indian', 'thai'];
    if (spiceCategories.contains(dominantCategory)) {
      newType = CompanionType.spiceDjinn;
    }

    // Frost Fairy - desserts/cold focus
    const frostCategories = ['dessert', 'ice cream', 'frozen', 'cake'];
    if (frostCategories.contains(dominantCategory)) {
      newType = CompanionType.frostFairy;
    }

    // Apply evolution if type changed
    if (newType != null && newType != companion.type) {
      state = state.copyWith(
        companion: companion.copyWith(type: newType),
        currentMessage:
            '${companion.name} evolved into a ${newType.displayName}! ${newType.emoji}',
        isMessageVisible: true,
      );
      await _saveCompanion();
    }
  }

  // ============ MESSAGE SYSTEM ============

  void showMessage(String message) {
    state = state.copyWith(
      currentMessage: message,
      isMessageVisible: true,
    );
  }

  void dismissMessage() {
    state = state.copyWith(
      clearCurrentMessage: true,
      isMessageVisible: false,
    );
  }

  // ============ MESSAGE GENERATION ============

  String generateGreeting() {
    final companion = state.companion;
    final name = companion?.name ?? 'Chef';
    final random = Random();
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Morning greetings
      final greetings = [
        'Good morning! What shall we cook today, $name... wait, I mean chef!',
        'Rise and shine, chef! $name is ready to cook!',
        'Morning! The kitchen awaits us!',
        'Good morning! I smell breakfast potential!',
        'A new day, a new recipe! Let\'s go, chef!',
      ];
      return greetings[random.nextInt(greetings.length)];
    } else if (hour >= 12 && hour < 17) {
      // Afternoon greetings
      final greetings = [
        'Good afternoon! Hungry yet?',
        'Lunchtime inspiration is calling!',
        'Afternoon, chef! Time for a culinary adventure?',
        'Good afternoon! Let\'s whip up something tasty!',
        'The afternoon is perfect for trying new recipes!',
      ];
      return greetings[random.nextInt(greetings.length)];
    } else if (hour >= 17 && hour < 22) {
      // Evening greetings
      final greetings = [
        'Good evening! Time for dinner?',
        'Evening, chef! What\'s on the menu tonight?',
        'Dinner time approaches! What are we making?',
        'Good evening! I\'ve been thinking about recipes all day!',
        'The evening calls for something special!',
      ];
      return greetings[random.nextInt(greetings.length)];
    } else {
      // Night greetings
      final greetings = [
        'Burning the midnight oil? Me too!',
        'Late night cooking? I\'m here for it!',
        'Can\'t sleep? Let\'s plan tomorrow\'s meals!',
        'A midnight snack recipe, perhaps?',
        'Night owl cooking is the best cooking!',
      ];
      return greetings[random.nextInt(greetings.length)];
    }
  }

  String generateCookingReaction(String recipeName) {
    final random = Random();
    final reactions = [
      'Ooh, $recipeName! That sounds delicious!',
      'A classic! Let me watch and learn.',
      '$recipeName? Excellent choice, chef!',
      'Yum! I can\'t wait to see how this turns out.',
      'Ooh, I love when you make $recipeName!',
    ];
    return reactions[random.nextInt(reactions.length)];
  }

  String generateNudge() {
    final random = Random();
    final nudges = [
      'It\'s been a while... shall we cook something?',
      'I\'m getting hungry just thinking about recipes...',
      'The kitchen misses us!',
      'How about we try something new today?',
    ];
    return nudges[random.nextInt(nudges.length)];
  }
}

// ============ PROVIDERS ============

final companionProvider =
    NotifierProvider<CompanionNotifier, CompanionState>(() {
  return CompanionNotifier();
});

// ============ CONVENIENCE PROVIDERS ============

/// Quick access to companion data (null if not yet created)
final companionDataProvider = Provider<CompanionData?>((ref) {
  return ref.watch(companionProvider).companion;
});
