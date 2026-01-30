import 'package:flutter/material.dart';

/// Represents a course (meal type) for recipes
class Course {
  final String id;
  final String name;
  final String emoji;
  final Color lightColor;

  const Course({
    required this.id,
    required this.name,
    required this.emoji,
    this.lightColor = const Color(0xFFE3F2FD),
  });
}

/// Represents a category for recipes
class Category {
  final String id;
  final String name;
  final String emoji;
  final Color lightColor;

  const Category({
    required this.id,
    required this.name,
    required this.emoji,
    this.lightColor = const Color(0xFFE8F5E9),
  });
}

/// Built-in course data - from user's image
class CourseData {
  static const List<Course> courses = [
    Course(id: 'appetizer', name: 'Appetizer', emoji: '🥟', lightColor: Color(0xFFE0F2F1)),
    Course(id: 'beverage', name: 'Beverage', emoji: '🍹', lightColor: Color(0xFFE1F5FE)),
    Course(id: 'breakfast', name: 'Breakfast', emoji: '🍳', lightColor: Color(0xFFFFF8E1)),
    Course(id: 'brunch', name: 'Brunch', emoji: '🥞', lightColor: Color(0xFFFFF3E0)),
    Course(id: 'dessert', name: 'Dessert', emoji: '🍰', lightColor: Color(0xFFFCE4EC)),
    Course(id: 'main', name: 'Main Dish', emoji: '🍖', lightColor: Color(0xFFFFEBEE)),
    Course(id: 'sauce', name: 'Sauce', emoji: '🫗', lightColor: Color(0xFFFFE0B2)),
    Course(id: 'side', name: 'Side Dish', emoji: '🥗', lightColor: Color(0xFFE8F5E9)),
    Course(id: 'snack', name: 'Snack', emoji: '🍿', lightColor: Color(0xFFFFFDE7)),
  ];

  static Course? getById(String id) {
    try {
      return courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Built-in category data - from user's image
class CategoryData {
  static const List<Category> categories = [
    Category(id: 'bean', name: 'Bean', emoji: '🫘', lightColor: Color(0xFFD7CCC8)),
    Category(id: 'beverage', name: 'Beverage', emoji: '🥤', lightColor: Color(0xFFE1F5FE)),
    Category(id: 'bread', name: 'Bread', emoji: '🍞', lightColor: Color(0xFFFFE0B2)),
    Category(id: 'burrito-taco', name: 'Burrito/Taco', emoji: '🌮', lightColor: Color(0xFFFFF9C4)),
    Category(id: 'casserole', name: 'Casserole', emoji: '🍲', lightColor: Color(0xFFFFCCBC)),
    Category(id: 'chicken-steak-meat', name: 'Chicken/Steak/Meat', emoji: '🥩', lightColor: Color(0xFFFFCDD2)),
    Category(id: 'dessert', name: 'Dessert', emoji: '🧁', lightColor: Color(0xFFF8BBD9)),
    Category(id: 'fish', name: 'Fish', emoji: '🐟', lightColor: Color(0xFFB3E5FC)),
    Category(id: 'fruit', name: 'Fruit', emoji: '🍎', lightColor: Color(0xFFC8E6C9)),
    Category(id: 'muffin', name: 'Muffin', emoji: '🧁', lightColor: Color(0xFFFFE0B2)),
    Category(id: 'pasta', name: 'Pasta', emoji: '🍝', lightColor: Color(0xFFFFF9C4)),
    Category(id: 'rice', name: 'Rice', emoji: '🍚', lightColor: Color(0xFFFFFDE7)),
    Category(id: 'salad', name: 'Salad', emoji: '🥗', lightColor: Color(0xFFC8E6C9)),
    Category(id: 'sandwich', name: 'Sandwich', emoji: '🥪', lightColor: Color(0xFFFFE0B2)),
    Category(id: 'sauce', name: 'Sauce', emoji: '🫗', lightColor: Color(0xFFFFCCBC)),
    Category(id: 'soup', name: 'Soup', emoji: '🍜', lightColor: Color(0xFFFFE0B2)),
    Category(id: 'vegetable', name: 'Vegetable', emoji: '🥦', lightColor: Color(0xFFC8E6C9)),
  ];

  static Category? getById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Recipe tags (dietary preferences, cooking style, etc.)
class RecipeTag {
  final String id;
  final String name;
  final String emoji;
  final Color color;

  const RecipeTag({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
  });
}

class TagData {
  static const List<RecipeTag> tags = [
    // Dietary
    RecipeTag(id: 'vegetarian', name: 'Vegetarian', emoji: '🥕', color: Color(0xFF4CAF50)),
    RecipeTag(id: 'vegan', name: 'Vegan', emoji: '🌱', color: Color(0xFF2E7D32)),
    RecipeTag(id: 'gluten-free', name: 'Gluten-Free', emoji: '🌾', color: Color(0xFFFF9800)),
    RecipeTag(id: 'dairy-free', name: 'Dairy-Free', emoji: '🥛', color: Color(0xFF03A9F4)),
    RecipeTag(id: 'low-carb', name: 'Low-Carb', emoji: '🥩', color: Color(0xFFE91E63)),
    RecipeTag(id: 'keto', name: 'Keto', emoji: '🥑', color: Color(0xFF9C27B0)),
    RecipeTag(id: 'paleo', name: 'Paleo', emoji: '🦴', color: Color(0xFF795548)),
    RecipeTag(id: 'nut-free', name: 'Nut-Free', emoji: '🥜', color: Color(0xFFFF5722)),
    // Cooking style
    RecipeTag(id: 'quick', name: 'Quick & Easy', emoji: '⚡', color: Color(0xFFFFEB3B)),
    RecipeTag(id: 'one-pot', name: 'One-Pot', emoji: '🍳', color: Color(0xFF607D8B)),
    RecipeTag(id: 'slow-cooker', name: 'Slow Cooker', emoji: '🫕', color: Color(0xFFFF5722)),
    RecipeTag(id: 'instant-pot', name: 'Instant Pot', emoji: '⏱️', color: Color(0xFF9E9E9E)),
    RecipeTag(id: 'grilling', name: 'Grilling', emoji: '🔥', color: Color(0xFFFF5722)),
    RecipeTag(id: 'baking', name: 'Baking', emoji: '🥧', color: Color(0xFFFFB74D)),
    RecipeTag(id: 'air-fryer', name: 'Air Fryer', emoji: '🌀', color: Color(0xFF00BCD4)),
    // Other
    RecipeTag(id: 'budget', name: 'Budget-Friendly', emoji: '💰', color: Color(0xFF4CAF50)),
    RecipeTag(id: 'meal-prep', name: 'Meal Prep', emoji: '📦', color: Color(0xFF3F51B5)),
    RecipeTag(id: 'healthy', name: 'Healthy', emoji: '💪', color: Color(0xFF8BC34A)),
    RecipeTag(id: 'comfort', name: 'Comfort Food', emoji: '🛋️', color: Color(0xFFFF9800)),
    RecipeTag(id: 'holiday', name: 'Holiday', emoji: '🎄', color: Color(0xFFF44336)),
    RecipeTag(id: 'party', name: 'Party', emoji: '🎉', color: Color(0xFFE91E63)),
    RecipeTag(id: 'kid-friendly', name: 'Kid-Friendly', emoji: '👶', color: Color(0xFF2196F3)),
    RecipeTag(id: 'spicy', name: 'Spicy', emoji: '🌶️', color: Color(0xFFF44336)),
  ];

  static RecipeTag? getById(String id) {
    try {
      return tags.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}