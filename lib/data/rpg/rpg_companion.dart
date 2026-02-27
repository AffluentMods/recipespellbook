// lib/data/rpg/rpg_companion.dart
// Cooking Companion data model for Recipe Spellbook RPG system

import 'package:flutter/material.dart';

// ============ COMPANION TYPES ============

/// Evolution paths based on what the user cooks most
enum CompanionType {
  ember,        // Default start - warm orange flame wisp
  hearthSpirit, // Baking focus - golden warm glow
  bladeSprite,  // Savory/knife-heavy focus - silvery sharp
  gardenWisp,   // Vegetarian/healthy focus - green leafy
  spiceDjinn,   // Spicy/international focus - red swirling
  frostFairy,   // Desserts/cold focus - icy blue crystalline
}

enum CompanionMood {
  happy,    // Bouncy particles, fast movement
  sleepy,   // Slow drift, dim glow
  excited,  // Rapid sparkles, bright
  neutral,  // Gentle float, medium glow
  proud,    // Pulsing glow, steady
}

enum ParticleShape {
  circle,   // Default for ember
  diamond,  // For bladeSprite
  star,     // For hearthSpirit
  leaf,     // For gardenWisp
  crystal,  // For frostFairy
}

// ============ COMPANION TYPE EXTENSION ============

extension CompanionTypeExtension on CompanionType {
  String get displayName {
    switch (this) {
      case CompanionType.ember: return 'Ember';
      case CompanionType.hearthSpirit: return 'Hearth Spirit';
      case CompanionType.bladeSprite: return 'Blade Sprite';
      case CompanionType.gardenWisp: return 'Garden Wisp';
      case CompanionType.spiceDjinn: return 'Spice Djinn';
      case CompanionType.frostFairy: return 'Frost Fairy';
    }
  }

  String get description {
    switch (this) {
      case CompanionType.ember:
        return 'A flickering flame wisp, eager to learn the ways of the kitchen.';
      case CompanionType.hearthSpirit:
        return 'A warm golden spirit born from the heart of the oven.';
      case CompanionType.bladeSprite:
        return 'A swift silvery sprite, honed by countless savory creations.';
      case CompanionType.gardenWisp:
        return 'A gentle green wisp nourished by fresh vegetables and herbs.';
      case CompanionType.spiceDjinn:
        return 'A fiery djinn swirling with the heat of bold spices.';
      case CompanionType.frostFairy:
        return 'A crystalline fairy chilled by frozen treats and sweet desserts.';
    }
  }

  String get emoji {
    switch (this) {
      case CompanionType.ember: return '🔥';
      case CompanionType.hearthSpirit: return '🍞';
      case CompanionType.bladeSprite: return '🔪';
      case CompanionType.gardenWisp: return '🌿';
      case CompanionType.spiceDjinn: return '🌶️';
      case CompanionType.frostFairy: return '🧊';
    }
  }

  Color get primaryColor {
    switch (this) {
      case CompanionType.ember: return const Color(0xFFFF6B35);
      case CompanionType.hearthSpirit: return const Color(0xFFDAA520);
      case CompanionType.bladeSprite: return const Color(0xFFC0C0C0);
      case CompanionType.gardenWisp: return const Color(0xFF4CAF50);
      case CompanionType.spiceDjinn: return const Color(0xFFFF4444);
      case CompanionType.frostFairy: return const Color(0xFF81D4FA);
    }
  }

  Color get secondaryColor {
    switch (this) {
      case CompanionType.ember: return const Color(0xFFFFD700);
      case CompanionType.hearthSpirit: return const Color(0xFFFFF8E7);
      case CompanionType.bladeSprite: return const Color(0xFF4682B4);
      case CompanionType.gardenWisp: return const Color(0xFF8BC34A);
      case CompanionType.spiceDjinn: return const Color(0xFFFF5722);
      case CompanionType.frostFairy: return const Color(0xFFE3F2FD);
    }
  }

  ParticleShape get particleShape {
    switch (this) {
      case CompanionType.ember: return ParticleShape.circle;
      case CompanionType.hearthSpirit: return ParticleShape.star;
      case CompanionType.bladeSprite: return ParticleShape.diamond;
      case CompanionType.gardenWisp: return ParticleShape.leaf;
      case CompanionType.spiceDjinn: return ParticleShape.circle;
      case CompanionType.frostFairy: return ParticleShape.crystal;
    }
  }
}

// ============ COMPANION MOOD EXTENSION ============

extension CompanionMoodExtension on CompanionMood {
  double get particleSpeed {
    switch (this) {
      case CompanionMood.happy: return 1.5;
      case CompanionMood.sleepy: return 0.3;
      case CompanionMood.excited: return 2.0;
      case CompanionMood.neutral: return 1.0;
      case CompanionMood.proud: return 0.8;
    }
  }

  int get particleCount {
    switch (this) {
      case CompanionMood.happy: return 12;
      case CompanionMood.sleepy: return 5;
      case CompanionMood.excited: return 20;
      case CompanionMood.neutral: return 8;
      case CompanionMood.proud: return 10;
    }
  }

  double get glowIntensity {
    switch (this) {
      case CompanionMood.happy: return 0.8;
      case CompanionMood.sleepy: return 0.2;
      case CompanionMood.excited: return 1.0;
      case CompanionMood.neutral: return 0.5;
      case CompanionMood.proud: return 0.7;
    }
  }

  double get bounceAmplitude {
    switch (this) {
      case CompanionMood.happy: return 3.0;
      case CompanionMood.sleepy: return 1.0;
      case CompanionMood.excited: return 5.0;
      case CompanionMood.neutral: return 2.0;
      case CompanionMood.proud: return 1.5;
    }
  }
}

// ============ COMPANION DATA ============

class CompanionData {
  final String name;
  final CompanionType type;
  final CompanionMood mood;
  final Map<String, int> categoryCooked;
  final DateTime? lastInteraction;
  final DateTime? lastCookDate;
  final DateTime createdAt;

  const CompanionData({
    required this.name,
    this.type = CompanionType.ember,
    this.mood = CompanionMood.neutral,
    this.categoryCooked = const {},
    this.lastInteraction,
    this.lastCookDate,
    required this.createdAt,
  });

  CompanionData copyWith({
    String? name,
    CompanionType? type,
    CompanionMood? mood,
    Map<String, int>? categoryCooked,
    DateTime? lastInteraction,
    DateTime? lastCookDate,
    DateTime? createdAt,
  }) {
    return CompanionData(
      name: name ?? this.name,
      type: type ?? this.type,
      mood: mood ?? this.mood,
      categoryCooked: categoryCooked ?? this.categoryCooked,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      lastCookDate: lastCookDate ?? this.lastCookDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      'mood': mood.name,
      'categoryCooked': categoryCooked,
      'lastInteraction': lastInteraction?.toIso8601String(),
      'lastCookDate': lastCookDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CompanionData.fromJson(Map<String, dynamic> json) {
    return CompanionData(
      name: json['name'] as String? ?? 'Ember',
      type: CompanionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => CompanionType.ember,
      ),
      mood: CompanionMood.values.firstWhere(
        (m) => m.name == json['mood'],
        orElse: () => CompanionMood.neutral,
      ),
      categoryCooked: (json['categoryCooked'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      lastInteraction: json['lastInteraction'] != null
          ? DateTime.parse(json['lastInteraction'] as String)
          : null,
      lastCookDate: json['lastCookDate'] != null
          ? DateTime.parse(json['lastCookDate'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  factory CompanionData.newCompanion(String name) {
    return CompanionData(
      name: name,
      type: CompanionType.ember,
      mood: CompanionMood.neutral,
      categoryCooked: {},
      createdAt: DateTime.now(),
    );
  }
}
