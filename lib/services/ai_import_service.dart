import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

/// Service that parses and imports recipes from AI-generated JSON.
///
/// Expected JSON format (single recipe):
/// ```json
/// {
///   "title": "Chicken Parmesan",
///   "description": "Classic Italian-American comfort food",
///   "servings": "4",
///   "prepTimeMinutes": 20,
///   "cookTimeMinutes": 30,
///   "course": "Entrée",
///   "category": "Italian",
///   "sourceUrl": "https://example.com/recipe",
///   "notes": "Great with spaghetti",
///   "ingredients": [
///     { "amount": "4", "unit": "pieces", "name": "chicken breast", "notes": "pounded thin" },
///     { "amount": "1", "unit": "cup", "name": "breadcrumbs" }
///   ],
///   "steps": [
///     { "instruction": "Preheat oven to 400°F.", "durationMinutes": 5 },
///     { "instruction": "Bread the chicken and pan-fry until golden." }
///   ]
/// }
/// ```
class AiImportService {
  static const _uuid = Uuid();

  /// Validate raw JSON string. Returns error message or null if valid.
  static String? validate(String jsonString) {
    try {
      final cleaned = _cleanJson(jsonString);
      final decoded = jsonDecode(cleaned);

      if (decoded is! Map<String, dynamic>) {
        return 'Expected a JSON object with recipe data. Got ${decoded.runtimeType}.';
      }

      final recipe = decoded;

      // Required: title
      if (recipe['title'] == null ||
          (recipe['title'] as String).trim().isEmpty) {
        return 'Missing required field: "title"';
      }

      // Required: at least one ingredient
      if (recipe['ingredients'] == null || recipe['ingredients'] is! List) {
        return 'Missing required field: "ingredients" (must be an array)';
      }
      final ingredients = recipe['ingredients'] as List;
      if (ingredients.isEmpty) {
        return '"ingredients" array is empty — need at least one ingredient.';
      }
      for (var i = 0; i < ingredients.length; i++) {
        final ing = ingredients[i];
        if (ing is! Map<String, dynamic>) {
          return 'Ingredient #${i + 1} is not a valid object.';
        }
        if (ing['name'] == null || (ing['name'] as String).trim().isEmpty) {
          return 'Ingredient #${i + 1} is missing a "name" field.';
        }
      }

      // Required: at least one step
      if (recipe['steps'] == null || recipe['steps'] is! List) {
        return 'Missing required field: "steps" (must be an array)';
      }
      final steps = recipe['steps'] as List;
      if (steps.isEmpty) {
        return '"steps" array is empty — need at least one step.';
      }
      for (var i = 0; i < steps.length; i++) {
        final step = steps[i];
        if (step is! Map<String, dynamic>) {
          return 'Step #${i + 1} is not a valid object.';
        }
        if (step['instruction'] == null ||
            (step['instruction'] as String).trim().isEmpty) {
          return 'Step #${i + 1} is missing an "instruction" field.';
        }
      }

      return null; // Valid!
    } on FormatException catch (e) {
      return 'Invalid JSON: ${e.message}';
    } catch (e) {
      return 'Error parsing recipe: $e';
    }
  }

  /// Parse and import a recipe from JSON string into the database.
  /// Returns the created recipe's ID.
  static Future<String> importFromJson(
      String jsonString,
      AppDatabase db, {
        required String cookbookId,
      }) async {
    final cleaned = _cleanJson(jsonString);
    final data = jsonDecode(cleaned) as Map<String, dynamic>;

    final recipeId = 'ai_${_uuid.v4()}';
    final now = DateTime.now();

    // ── Recipe ──
    final title = (data['title'] as String).trim();
    final description = _optString(data['description']);
    final servings = _optString(data['servings']);
    final prepTime = _optInt(data['prepTimeMinutes']);
    final cookTime = _optInt(data['cookTimeMinutes']);
    final sourceUrl = _optString(data['sourceUrl']);
    final notes = _optString(data['notes']);
    final course = _optString(data['course']);
    final category = _optString(data['category']);
    final rating = _optInt(data['rating']);

    // Map course/category names to IDs if they match defaults
    final courseId = _resolveCourseId(course);
    final categoryId = _resolveCategoryId(category);

    await db.into(db.recipes).insert(RecipesCompanion.insert(
      id: recipeId,
      cookbookId: cookbookId,
      title: title,
      description: Value(description),
      servings: Value(servings),
      prepTimeMinutes: Value(prepTime),
      cookTimeMinutes: Value(cookTime),
      sourceUrl: Value(sourceUrl),
      courseId: Value(courseId),
      categoryId: Value(categoryId),
      rating: Value(rating),
      notes: Value(notes),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    // ── Ingredients ──
    final ingredients = data['ingredients'] as List;
    for (var i = 0; i < ingredients.length; i++) {
      final ing = ingredients[i] as Map<String, dynamic>;
      await db.into(db.ingredients).insert(IngredientsCompanion.insert(
        id: '${recipeId}_ing_$i',
        recipeId: recipeId,
        sortOrder: i,
        name: (ing['name'] as String).trim(),
        amount: Value(_optString(ing['amount'])),
        unit: Value(_optString(ing['unit'])),
        notes: Value(_optString(ing['notes'])),
      ));
    }

    // ── Steps ──
    final steps = data['steps'] as List;
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i] as Map<String, dynamic>;
      await db.into(db.steps).insert(StepsCompanion.insert(
        id: '${recipeId}_step_$i',
        recipeId: recipeId,
        sortOrder: i,
        instruction: (step['instruction'] as String).trim(),
        durationMinutes: Value(_optInt(step['durationMinutes'])),
      ));
    }

    return recipeId;
  }

  /// Clean JSON string from common AI output artifacts.
  static String _cleanJson(String raw) {
    var s = raw.trim();

    // Strip markdown code fences: ```json ... ``` or ``` ... ```
    if (s.startsWith('```')) {
      final firstNewline = s.indexOf('\n');
      if (firstNewline != -1) {
        s = s.substring(firstNewline + 1);
      }
      if (s.endsWith('```')) {
        s = s.substring(0, s.length - 3);
      }
      s = s.trim();
    }

    // Strip leading/trailing quotes if the whole thing is wrapped
    if ((s.startsWith('"') && s.endsWith('"')) ||
        (s.startsWith("'") && s.endsWith("'"))) {
      // Only if it's not already a valid JSON object/array
      if (!s.startsWith('{') && !s.startsWith('[')) {
        s = s.substring(1, s.length - 1);
      }
    }

    return s;
  }

  static String? _optString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int? _optInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString());
  }

  /// Try to map a course name to a known course ID.
  static String? _resolveCourseId(String? name) {
    if (name == null) return null;
    final lower = name.toLowerCase().trim();
    const courseMap = {
      'appetizer': 'course_appetizer',
      'starter': 'course_appetizer',
      'entrée': 'course_entree',
      'entree': 'course_entree',
      'main': 'course_entree',
      'main course': 'course_entree',
      'side': 'course_side',
      'side dish': 'course_side',
      'dessert': 'course_dessert',
      'beverage': 'course_beverage',
      'drink': 'course_beverage',
      'breakfast': 'course_breakfast',
      'brunch': 'course_brunch',
      'lunch': 'course_lunch',
      'dinner': 'course_dinner',
      'snack': 'course_snack',
      'sauce': 'course_sauce',
      'salad': 'course_salad',
      'soup': 'course_soup',
    };
    return courseMap[lower] ?? name;
  }

  /// Try to map a category name to a known category ID.
  static String? _resolveCategoryId(String? name) {
    if (name == null) return null;
    final lower = name.toLowerCase().trim();
    const catMap = {
      'appetizer': 'cat_appetizer',
      'beverages': 'cat_beverage',
      'desserts': 'cat_dessert',
      'dessert': 'cat_dessert',
      'entrée': 'cat_entree',
      'entree': 'cat_entree',
      'sides': 'cat_side',
      'side': 'cat_side',
      'sauces': 'cat_sauce',
      'sauce': 'cat_sauce',
    };
    return catMap[lower] ?? name;
  }

  // ══════════════════════════════════════════
  //  SHOPPING LIST AI IMPORT
  // ══════════════════════════════════════════

  /// Validate a shopping list JSON string.
  static String? validateShoppingList(String jsonString) {
    try {
      final cleaned = _cleanJson(jsonString);
      final decoded = jsonDecode(cleaned);

      if (decoded is! List) {
        // Also accept { "items": [...] } wrapper
        if (decoded is Map<String, dynamic> && decoded['items'] is List) {
          return _validateShoppingItems(decoded['items'] as List);
        }
        return 'Expected a JSON array of items, or an object with an "items" array.';
      }

      return _validateShoppingItems(decoded);
    } on FormatException catch (e) {
      return 'Invalid JSON: ${e.message}';
    } catch (e) {
      return 'Error parsing shopping list: $e';
    }
  }

  static String? _validateShoppingItems(List items) {
    if (items.isEmpty) {
      return 'Items array is empty — need at least one item.';
    }
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item is! Map<String, dynamic>) {
        return 'Item #${i + 1} is not a valid object.';
      }
      if (item['name'] == null || (item['name'] as String).trim().isEmpty) {
        return 'Item #${i + 1} is missing a "name" field.';
      }
    }
    return null; // Valid
  }

  /// Parse AI shopping list JSON into a list of structured items.
  /// Returns list of maps with: name, amount, unit, category, note.
  static List<Map<String, String?>> parseShoppingList(String jsonString) {
    final cleaned = _cleanJson(jsonString);
    final decoded = jsonDecode(cleaned);

    List items;
    if (decoded is List) {
      items = decoded;
    } else if (decoded is Map<String, dynamic> && decoded['items'] is List) {
      items = decoded['items'] as List;
    } else {
      return [];
    }

    return items.map((item) {
      final map = item as Map<String, dynamic>;
      return <String, String?>{
        'name': (map['name'] as String?)?.trim(),
        'amount': _optString(map['amount']),
        'unit': _optString(map['unit']),
        'category': _resolveShoppingCategory(_optString(map['category'])),
        'note': _optString(map['note']),
      };
    }).where((m) => m['name'] != null && m['name']!.isNotEmpty).toList();
  }

  /// Map AI-provided category names to app category IDs.
  static String _resolveShoppingCategory(String? name) {
    if (name == null || name.isEmpty) return 'other';
    final lower = name.toLowerCase().trim();
    const catMap = {
      'produce': 'produce',
      'fruits': 'produce',
      'vegetables': 'produce',
      'fruit': 'produce',
      'vegetable': 'produce',
      'fresh produce': 'produce',
      'dairy': 'dairy',
      'dairy & eggs': 'dairy',
      'eggs': 'dairy',
      'milk': 'dairy',
      'cheese': 'dairy',
      'meat': 'meat',
      'poultry': 'meat',
      'meat & poultry': 'meat',
      'seafood': 'seafood',
      'fish': 'seafood',
      'bakery': 'bakery',
      'bread': 'bakery',
      'bakery & bread': 'bakery',
      'deli': 'deli',
      'frozen': 'frozen',
      'frozen foods': 'frozen',
      'breakfast': 'breakfast',
      'cereal': 'breakfast',
      'breakfast & cereal': 'breakfast',
      'canned': 'canned',
      'canned goods': 'canned',
      'canned & jarred': 'canned',
      'pasta': 'pasta',
      'pasta & rice': 'pasta',
      'noodles': 'pasta',
      'grains': 'grains',
      'rice': 'grains',
      'grains & rice': 'grains',
      'baking': 'baking',
      'baking supplies': 'baking',
      'cooking & baking': 'baking',
      'condiments': 'condiments',
      'sauces': 'condiments',
      'condiments & sauces': 'condiments',
      'oil': 'oil',
      'oils': 'oil',
      'oils & vinegars': 'oil',
      'cooking oil': 'oil',
      'spices': 'spices',
      'herbs': 'spices',
      'spices & seasonings': 'spices',
      'herbs & spices': 'spices',
      'seasonings': 'spices',
      'snacks': 'snacks',
      'chips': 'snacks',
      'snacks & chips': 'snacks',
      'beverages': 'beverages',
      'drinks': 'beverages',
      'alcohol': 'alcohol',
      'beer': 'alcohol',
      'wine': 'alcohol',
      'spirits': 'alcohol',
      'beer & wine': 'alcohol',
      'baby': 'baby',
      'baby care': 'baby',
      'beauty': 'beauty',
      'personal care': 'beauty',
      'health': 'beauty',
      'health & beauty': 'beauty',
      'household': 'household',
      'cleaning': 'household',
      'household supplies': 'household',
      'pet': 'pet',
      'pets': 'pet',
      'pet supplies': 'pet',
      'international': 'international',
      'ethnic': 'international',
      'world foods': 'international',
      'other': 'other',
    };
    return catMap[lower] ?? 'other';
  }

  /// Generate the shopping list prompt template.
  static String generateShoppingListPrompt() {
    return '''Convert the following shopping list into this exact JSON format. Output ONLY the JSON array, no extra text or explanation.

[
  {
    "name": "chicken breast",
    "amount": "2",
    "unit": "lb",
    "category": "Meat",
    "note": "boneless skinless"
  },
  {
    "name": "broccoli",
    "amount": "1",
    "unit": "bunch",
    "category": "Produce",
    "note": ""
  }
]

Rules:
- "name" is the item name (required)
- "amount" is a string (supports fractions like "1/2") or null if not specified
- "unit" is a string (lb, oz, cups, bunch, bag, can, bottle, box, etc.) or null if none
- "category" must be one of: Produce, Dairy, Meat, Seafood, Bakery, Deli, Frozen, Breakfast, Canned, Pasta, Grains, Baking, Condiments, Oil, Spices, Snacks, Beverages, Alcohol, Baby, Beauty, Household, Pet, International, Other
- "note" is for extra details like "organic", "large", brand preferences, etc.
- Combine duplicate items (e.g. if "eggs" appears twice, combine into one entry)
- Output valid JSON only — no markdown, no backticks, no commentary

Here is the shopping list:

''';
  }

  // ══════════════════════════════════════════
  //  RECIPE AI IMPORT
  // ══════════════════════════════════════════

  /// Generate the recipe prompt template for users to copy.
  static String generateRecipePrompt() {
    return '''Convert the following recipe into this exact JSON format. Output ONLY the JSON object, no extra text or explanation.

{
  "title": "Recipe Name",
  "description": "Brief description of the dish",
  "servings": "4",
  "prepTimeMinutes": 15,
  "cookTimeMinutes": 30,
  "course": "Entrée",
  "category": "Italian",
  "sourceUrl": "",
  "notes": "",
  "ingredients": [
    {
      "amount": "2",
      "unit": "cups",
      "name": "all-purpose flour",
      "notes": "sifted"
    }
  ],
  "steps": [
    {
      "instruction": "Preheat the oven to 375°F (190°C).",
      "durationMinutes": 5
    }
  ]
}

Rules:
- "amount" is a string (supports fractions like "1/2", "1 1/2")
- "unit" is a string (cups, tbsp, tsp, oz, lb, g, kg, ml, etc.) or null if not applicable (e.g. "3 eggs")
- "notes" on ingredients is for prep details like "diced", "room temperature", "melted"
- "durationMinutes" on steps is optional (null if not specified)
- "course" options: Appetizer, Entrée, Side, Dessert, Beverage, Breakfast, Lunch, Dinner, Snack, Sauce, Salad, Soup
- Keep step instructions clear and concise
- Output valid JSON only — no markdown, no backticks, no commentary

Here is the recipe:

''';
  }
}