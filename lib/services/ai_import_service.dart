import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

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
  /// Accepts single recipe objects, arrays of recipe objects,
  /// and v3 export format ({ "recipes": [...], "links": {...}, "version": "3.0" }).
  static String? validate(String jsonString) {
    try {
      final cleaned = _cleanJson(jsonString);
      final decoded = jsonDecode(cleaned);

      // Support arrays of recipes (bulk import)
      if (decoded is List) {
        if (decoded.isEmpty) {
          return 'Recipe array is empty — need at least one recipe.';
        }
        for (var r = 0; r < decoded.length; r++) {
          if (decoded[r] is! Map<String, dynamic>) {
            return 'Recipe #${r + 1} is not a valid JSON object.';
          }
          final err = _validateSingleRecipe(decoded[r] as Map<String, dynamic>, recipeIndex: r + 1);
          if (err != null) return err;
        }
        return null;
      }

      if (decoded is! Map<String, dynamic>) {
        return 'Expected a JSON object with recipe data (or an array of recipes). Got ${decoded.runtimeType}.';
      }

      // Support v3 export format with "recipes" array and "links"
      if (decoded.containsKey('recipes') && decoded['recipes'] is List) {
        final recipes = decoded['recipes'] as List;
        if (recipes.isEmpty) {
          return 'Recipe array is empty — need at least one recipe.';
        }
        for (var r = 0; r < recipes.length; r++) {
          if (recipes[r] is! Map<String, dynamic>) {
            return 'Recipe #${r + 1} is not a valid JSON object.';
          }
          final err = _validateSingleRecipe(recipes[r] as Map<String, dynamic>, recipeIndex: r + 1);
          if (err != null) return err;
        }
        return null;
      }

      return _validateSingleRecipe(decoded);
    } on FormatException catch (e) {
      return 'Invalid JSON: ${e.message}';
    } catch (e) {
      return 'Error parsing recipe: $e';
    }
  }

  /// Validate a single recipe map. [recipeIndex] is used for error messages in bulk mode.
  static String? _validateSingleRecipe(Map<String, dynamic> recipe, {int? recipeIndex}) {
    final prefix = recipeIndex != null ? 'Recipe #$recipeIndex: ' : '';

    // Required: title
    if (recipe['title'] == null ||
        (recipe['title'] as String).trim().isEmpty) {
      return '${prefix}Missing required field: "title"';
    }

    // Required: at least one ingredient
    if (recipe['ingredients'] == null || recipe['ingredients'] is! List) {
      return '${prefix}Missing required field: "ingredients" (must be an array)';
    }
    final ingredients = recipe['ingredients'] as List;
    if (ingredients.isEmpty) {
      return '$prefix"ingredients" array is empty — need at least one ingredient.';
    }
    for (var i = 0; i < ingredients.length; i++) {
      final ing = ingredients[i];
      if (ing is! Map<String, dynamic>) {
        return '${prefix}Ingredient #${i + 1} is not a valid object.';
      }
      if (ing['name'] == null || (ing['name'] as String).trim().isEmpty) {
        return '${prefix}Ingredient #${i + 1} is missing a "name" field.';
      }
    }

    // Required: at least one step
    if (recipe['steps'] == null || recipe['steps'] is! List) {
      return '${prefix}Missing required field: "steps" (must be an array)';
    }
    final steps = recipe['steps'] as List;
    if (steps.isEmpty) {
      return '$prefix"steps" array is empty — need at least one step.';
    }
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      if (step is! Map<String, dynamic>) {
        return '${prefix}Step #${i + 1} is not a valid object.';
      }
      if (step['instruction'] == null ||
          (step['instruction'] as String).trim().isEmpty) {
        return '${prefix}Step #${i + 1} is missing an "instruction" field.';
      }
    }

    return null; // Valid!
  }

  /// Parse and import recipe(s) from JSON string into the database.
  /// Supports single recipe objects, arrays of recipes,
  /// and v3 export format ({ "recipes": [...], "links": {...} }).
  /// Returns a list of created recipe IDs.
  static Future<List<String>> importAllFromJson(
      String jsonString,
      AppDatabase db, {
        required String cookbookId,
      }) async {
    final cleaned = _cleanJson(jsonString);
    final decoded = jsonDecode(cleaned);

    final List<Map<String, dynamic>> recipeMaps;
    Map<String, List<String>>? links;

    if (decoded is List) {
      recipeMaps = decoded.cast<Map<String, dynamic>>();
    } else if (decoded is Map<String, dynamic> && decoded.containsKey('recipes') && decoded['recipes'] is List) {
      // v3 export format with recipes array and links
      recipeMaps = (decoded['recipes'] as List).cast<Map<String, dynamic>>();
      if (decoded['links'] is Map) {
        links = (decoded['links'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as List).cast<String>()),
        );
      }
    } else {
      recipeMaps = [decoded as Map<String, dynamic>];
    }

    // Import all recipes and track title -> id mapping
    final ids = <String>[];
    final titleToId = <String, String>{};
    for (final data in recipeMaps) {
      final id = await _importSingleRecipe(data, db, cookbookId: cookbookId);
      ids.add(id);
      titleToId[data['title'] as String] = id;
    }

    // Restore ingredient links if present
    if (links != null && links.isNotEmpty && ids.isNotEmpty) {
      final mainRecipeId = ids.first;
      final ingredients = await (db.select(db.ingredients)
        ..where((t) => t.recipeId.equals(mainRecipeId)))
          .get();

      for (final entry in links.entries) {
        final ingredientName = entry.key;
        final linkedTitles = entry.value;

        // Find the ingredient by name
        final ing = ingredients.where(
          (i) => i.name.toLowerCase() == ingredientName.toLowerCase(),
        ).firstOrNull;
        if (ing == null) continue;

        for (final linkedTitle in linkedTitles) {
          final linkedId = titleToId[linkedTitle];
          if (linkedId == null) continue;

          // Create the link
          await db.into(db.recipeLinks).insertOnConflictUpdate(
            RecipeLinksCompanion.insert(
              sourceRecipeId: mainRecipeId,
              ingredientId: ing.id,
              linkedRecipeId: linkedId,
            ),
          );
        }
      }
    }

    return ids;
  }

  /// Parse and import a recipe from JSON string into the database.
  /// Returns the created recipe's ID.
  static Future<String> importFromJson(
      String jsonString,
      AppDatabase db, {
        required String cookbookId,
      }) async {
    final cleaned = _cleanJson(jsonString);
    final decoded = jsonDecode(cleaned);

    // Support arrays — import first recipe for backwards compatibility
    final Map<String, dynamic> data;
    if (decoded is List) {
      data = decoded.first as Map<String, dynamic>;
    } else {
      data = decoded as Map<String, dynamic>;
    }

    return _importSingleRecipe(data, db, cookbookId: cookbookId);
  }

  /// Import a single recipe map into the database. Returns the recipe ID.
  static Future<String> _importSingleRecipe(
      Map<String, dynamic> data,
      AppDatabase db, {
        required String cookbookId,
      }) async {
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
      lastViewedAt: Value(now),
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

    // Strip single-line comments (// ...)
    s = s.replaceAll(RegExp(r'//[^\n]*'), '');

    // Strip block comments (/* ... */)
    s = s.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');

    // Remove trailing commas before } or ]
    s = s.replaceAll(RegExp(r',\s*([}\]])'), r'$1');

    // Extract JSON if AI added text before/after (find first { or [)
    if (!s.startsWith('{') && !s.startsWith('[')) {
      final firstBrace = s.indexOf('{');
      final firstBracket = s.indexOf('[');
      if (firstBrace >= 0 || firstBracket >= 0) {
        final start = (firstBrace >= 0 && firstBracket >= 0)
            ? (firstBrace < firstBracket ? firstBrace : firstBracket)
            : (firstBrace >= 0 ? firstBrace : firstBracket);
        s = s.substring(start);
        // Find matching closing character
        final isArray = s.startsWith('[');
        final endChar = isArray ? ']' : '}';
        final lastEnd = s.lastIndexOf(endChar);
        if (lastEnd > 0) s = s.substring(0, lastEnd + 1);
      }
    }

    return s.trim();
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
  /// IDs must match CourseData in course_category_data.dart
  static String? _resolveCourseId(String? name) {
    if (name == null) return null;
    final lower = name.toLowerCase().trim();
    const courseMap = {
      'appetizer': 'appetizer',
      'starter': 'appetizer',
      'beverage': 'beverage',
      'drink': 'beverage',
      'breakfast': 'breakfast',
      'brunch': 'brunch',
      'dessert': 'dessert',
      'main': 'main',
      'main dish': 'main',
      'main course': 'main',
      'entrée': 'main',
      'entree': 'main',
      'dinner': 'main',
      'lunch': 'main',
      'sauce': 'sauce',
      'side': 'side',
      'side dish': 'side',
      'snack': 'snack',
    };
    return courseMap[lower] ?? name;
  }

  /// Try to map a category name to a known category ID.
  /// IDs must match CategoryData in course_category_data.dart
  static String? _resolveCategoryId(String? name) {
    if (name == null) return null;
    final lower = name.toLowerCase().trim();
    const catMap = {
      'bean': 'bean',
      'beans': 'bean',
      'legume': 'bean',
      'legumes': 'bean',
      'beverage': 'beverage',
      'beverages': 'beverage',
      'drink': 'beverage',
      'drinks': 'beverage',
      'bread': 'bread',
      'breads': 'bread',
      'burrito': 'burrito-taco',
      'taco': 'burrito-taco',
      'burrito/taco': 'burrito-taco',
      'mexican': 'burrito-taco',
      'casserole': 'casserole',
      'bake': 'casserole',
      'chicken': 'chicken-steak-meat',
      'steak': 'chicken-steak-meat',
      'meat': 'chicken-steak-meat',
      'chicken/steak/meat': 'chicken-steak-meat',
      'beef': 'chicken-steak-meat',
      'pork': 'chicken-steak-meat',
      'poultry': 'chicken-steak-meat',
      'dessert': 'dessert',
      'desserts': 'dessert',
      'sweets': 'dessert',
      'fish': 'fish',
      'seafood': 'fish',
      'fruit': 'fruit',
      'fruits': 'fruit',
      'muffin': 'muffin',
      'muffins': 'muffin',
      'cupcake': 'muffin',
      'pasta': 'pasta',
      'noodles': 'pasta',
      'noodle': 'pasta',
      'rice': 'rice',
      'grain': 'rice',
      'grains': 'rice',
      'salad': 'salad',
      'salads': 'salad',
      'sandwich': 'sandwich',
      'sandwiches': 'sandwich',
      'wrap': 'sandwich',
      'wraps': 'sandwich',
      'sauce': 'sauce',
      'sauces': 'sauce',
      'dip': 'sauce',
      'dips': 'sauce',
      'condiment': 'sauce',
      'soup': 'soup',
      'soups': 'soup',
      'stew': 'soup',
      'chili': 'soup',
      'vegetable': 'vegetable',
      'vegetables': 'vegetable',
      'veggie': 'vegetable',
      'vegan': 'vegetable',
      'vegetarian': 'vegetable',
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
''';
  }

  // ══════════════════════════════════════════
  //  RECIPE AI IMPORT
  // ══════════════════════════════════════════

  /// Generate the recipe prompt template for users to copy.
  static String generateRecipePrompt() {
    return '''Convert the following recipe(s) into this exact JSON format. You may import one recipe or many recipes at once. This works with any format — text, spreadsheets, screenshots, emails, websites, or anything else.

{
  "title": "Recipe Name",
  "description": "Brief description of the dish",
  "servings": "4",
  "prepTimeMinutes": 15,
  "cookTimeMinutes": 30,
  "course": "Main Dish",
  "category": "Pasta",
  "cuisine": "Italian",
  "tags": ["quick", "weeknight", "comfort food"],
  "sourceUrl": "",
  "notes": "",
  "ingredients": [
    {
      "amount": null,
      "unit": null,
      "name": "For the dough",
      "notes": "__header__"
    },
    {
      "amount": "2",
      "unit": "cups",
      "name": "all-purpose flour",
      "notes": "sifted"
    }
  ],
  "steps": [
    {
      "instruction": "Preheat the oven to 375 degrees\u00b0F (190\u00b0C).",
      "durationMinutes": 5
    }
  ]
}

For a SINGLE recipe, output the JSON object above.
For MULTIPLE recipes, wrap them in a JSON array:
[
  { "title": "Recipe 1", ... },
  { "title": "Recipe 2", ... }
]

Rules:
- You can import any number of recipes at once (1, 5, 20, 100+) — just wrap them in a JSON array
- Each recipe in the array uses the exact same format shown above
- "amount" is a string (supports fractions like "1/2", "1 1/2") or null
- "unit" is a string (cups, tbsp, tsp, oz, lb, g, kg, ml, etc.) or null if not applicable (e.g. "3 eggs")
- "notes" on ingredients is for prep details like "diced", "room temperature", "melted"
- HEADERS: If a recipe has ingredient sections (e.g. "For the sauce", "For the dough"), add a header ingredient with "notes": "__header__" and "name" set to the section title. Set amount and unit to null for headers.
- Only add headers if the recipe clearly has separate sections. Do NOT add headers if there is only one group of ingredients.
- "durationMinutes" on steps is optional (null if not specified)
- "course" must be one of: Appetizer, Beverage, Breakfast, Brunch, Dessert, Main Dish, Sauce, Side Dish, Snack
- "category" must be one of: Bean, Beverage, Bread, Burrito/Taco, Casserole, Chicken/Steak/Meat, Dessert, Fish, Fruit, Muffin, Pasta, Rice, Salad, Sandwich, Sauce, Soup, Vegetable
- "cuisine" is a free-text string like "Italian", "Mexican", "Japanese", "American", etc.
- "tags" is an array of short descriptive tags like "quick", "weeknight", "comfort food", "spicy", "gluten-free"
- Pick the single best-matching course and category for each recipe
- Keep step instructions clear and concise
- Output valid JSON only — no markdown, no backticks, no commentary
''';
  }
}