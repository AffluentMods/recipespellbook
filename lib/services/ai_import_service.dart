import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../data/course_category_data.dart';

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
  /// Extract all recipe maps from the JSON string (without validation/import).
  /// Handles single objects, arrays, v3 linked format, and multiple concatenated blobs.
  /// Returns an empty list if parsing fails.
  static List<Map<String, dynamic>> extractRecipes(String jsonString) {
    try {
      final cleaned = _cleanJson(jsonString);
      final (allRecipes, _) = _decodeMultipleBlobs(cleaned);
      return allRecipes;
    } catch (_) {
      return [];
    }
  }

  static String? validate(String jsonString) {
    try {
      final cleaned = _cleanJson(jsonString);
      final (allRecipes, _) = _decodeMultipleBlobs(cleaned);

      if (allRecipes.isEmpty) {
        return 'No recipes found — need at least one recipe.';
      }

      for (var r = 0; r < allRecipes.length; r++) {
        final err = _validateSingleRecipe(allRecipes[r], recipeIndex: r + 1);
        if (err != null) return err;
      }
      return null;
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
  /// v3 export format ({ "recipes": [...], "links": {...} }),
  /// AND multiple concatenated JSON blobs (common AI mistake).
  /// Returns a list of created recipe IDs.
  static Future<List<String>> importAllFromJson(
      String jsonString,
      AppDatabase db, {
        required String cookbookId,
      }) async {
    final cleaned = _cleanJson(jsonString);
    final (allRecipes, linkedBlobs) = _decodeMultipleBlobs(cleaned);

    // Import all recipes and track title -> id mapping
    final ids = <String>[];
    final titleToId = <String, String>{};
    for (final data in allRecipes) {
      final id = await _importSingleRecipe(data, db, cookbookId: cookbookId);
      ids.add(id);
      titleToId[data['title'] as String] = id;
    }

    // Restore ingredient links from each linked blob
    for (final blob in linkedBlobs) {
      final mainRecipeId = titleToId[blob.mainRecipeTitle];
      if (mainRecipeId == null) continue;

      final ingredients = await (db.select(db.ingredients)
        ..where((t) => t.recipeId.equals(mainRecipeId)))
          .get();

      for (final entry in blob.links.entries) {
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
    final (allRecipes, _) = _decodeMultipleBlobs(cleaned);
    if (allRecipes.isEmpty) {
      throw const FormatException('No recipes found in JSON');
    }
    return _importSingleRecipe(allRecipes.first, db, cookbookId: cookbookId);
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
        notes: Value(step['notes'] as String?),
      ));
    }

    return recipeId;
  }

  /// Removes `// line` and `/* block */` comments while leaving the
  /// contents of JSON string literals untouched. Walks the text tracking
  /// in-string state (honoring `\"` escapes) so `//` inside a URL or any
  /// value is preserved.
  static String _stripCommentsOutsideStrings(String s) {
    final out = StringBuffer();
    var inString = false;
    var i = 0;
    final n = s.length;
    while (i < n) {
      final c = s[i];
      if (inString) {
        out.write(c);
        if (c == r'\' && i + 1 < n) {
          // Preserve the escaped character verbatim.
          out.write(s[i + 1]);
          i += 2;
          continue;
        }
        if (c == '"') inString = false;
        i++;
        continue;
      }
      // Not in a string.
      if (c == '"') {
        inString = true;
        out.write(c);
        i++;
        continue;
      }
      if (c == '/' && i + 1 < n && s[i + 1] == '/') {
        // Line comment — skip to end of line (or end of input).
        i += 2;
        while (i < n && s[i] != '\n') {
          i++;
        }
        continue;
      }
      if (c == '/' && i + 1 < n && s[i + 1] == '*') {
        // Block comment — skip to closing */ (or end of input).
        i += 2;
        while (i + 1 < n && !(s[i] == '*' && s[i + 1] == '/')) {
          i++;
        }
        i += 2;
        continue;
      }
      out.write(c);
      i++;
    }
    return out.toString();
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

    // Strip JS-style comments — but ONLY outside string literals. A naive
    // regex like `//[^\n]*` matches the `//` inside a URL (e.g.
    // "https://example.com"); on minified single-line JSON that deletes
    // everything to the end, producing an "unterminated string" error.
    s = _stripCommentsOutsideStrings(s);

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

  /// Split a string that may contain multiple concatenated JSON values
  /// (objects/arrays separated by whitespace or nothing) into individual JSON strings.
  /// Returns a list of trimmed JSON strings. If only one value exists, returns [s].
  static List<String> _splitMultipleJson(String s) {
    final results = <String>[];
    var i = 0;
    while (i < s.length) {
      // Skip whitespace
      while (i < s.length && (s[i] == ' ' || s[i] == '\n' || s[i] == '\r' || s[i] == '\t')) {
        i++;
      }
      if (i >= s.length) break;

      final startChar = s[i];
      if (startChar != '{' && startChar != '[') {
        // Not a JSON value — stop here
        break;
      }

      final openChar = startChar;
      final closeChar = startChar == '{' ? '}' : ']';
      final start = i;
      var depth = 0;
      var inString = false;
      var escape = false;

      while (i < s.length) {
        final c = s[i];
        if (escape) {
          escape = false;
          i++;
          continue;
        }
        if (inString) {
          if (c == r'\') {
            escape = true;
          } else if (c == '"') {
            inString = false;
          }
          i++;
          continue;
        }
        if (c == '"') {
          inString = true;
        } else if (c == openChar) {
          depth++;
        } else if (c == closeChar) {
          depth--;
          if (depth == 0) {
            i++;
            results.add(s.substring(start, i).trim());
            break;
          }
        }
        i++;
      }

      if (depth != 0) {
        // Unbalanced — just return the single input as a fallback
        return [s];
      }
    }
    return results.isEmpty ? [s] : results;
  }

  /// Parse potentially-multiple JSON blobs and return a combined structure.
  /// Merges recipe arrays from all blobs. Links from each {recipes, links} blob
  /// are tracked per-blob with a main recipe reference.
  static (List<Map<String, dynamic>>, List<_LinkedBlob>) _decodeMultipleBlobs(String cleaned) {
    final blobs = _splitMultipleJson(cleaned);
    final allRecipes = <Map<String, dynamic>>[];
    final linkedBlobs = <_LinkedBlob>[];

    void processMapElement(Map<String, dynamic> m) {
      if (m.containsKey('recipes') && m['recipes'] is List) {
        // Linked recipe format
        final blobRecipes = <Map<String, dynamic>>[];
        for (final r in m['recipes'] as List) {
          if (r is Map<String, dynamic>) {
            blobRecipes.add(r);
            allRecipes.add(r);
          }
        }
        Map<String, List<String>>? blobLinks;
        if (m['links'] is Map) {
          blobLinks = (m['links'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, (v as List).cast<String>()),
          );
        }
        if (blobLinks != null && blobRecipes.isNotEmpty) {
          linkedBlobs.add(_LinkedBlob(
            mainRecipeTitle: blobRecipes.first['title'] as String,
            links: blobLinks,
          ));
        }
      } else {
        // Single recipe object
        allRecipes.add(m);
      }
    }

    for (final blob in blobs) {
      final decoded = jsonDecode(blob);
      if (decoded is List) {
        // Array of items — each can be a recipe OR a linked set
        for (final r in decoded) {
          if (r is Map<String, dynamic>) processMapElement(r);
        }
      } else if (decoded is Map<String, dynamic>) {
        processMapElement(decoded);
      }
    }
    return (allRecipes, linkedBlobs);
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
      "instruction": "For the dough",
      "notes": "__header__"
    },
    {
      "instruction": "Combine the 2 cups all-purpose flour with the 1 tsp salt, then cut in the 1/2 cup cold butter.",
      "durationMinutes": 10
    },
    {
      "instruction": "Preheat the oven to 375\u00b0F (190\u00b0C).",
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

For LINKED recipes (a main recipe with sub-recipes as ingredients), use this format:
{
  "recipes": [
    { "title": "Main Recipe", "ingredients": [{"name": "Pastry Cream", ...}, ...], "steps": [...], ... },
    { "title": "Pastry Cream", "ingredients": [...], "steps": [...], ... },
    { "title": "Pie Crust", "ingredients": [...], "steps": [...], ... }
  ],
  "links": {
    "Pastry Cream": ["Pastry Cream"],
    "Pie Crust": ["Pie Crust"]
  }
}
The "links" object maps ingredient names in the main recipe to the titles of sub-recipes they should link to.

For MIXED imports (multiple standalone recipes AND multiple linked sets in one paste), wrap everything into one top-level array. The importer accepts a single array where each element is either a plain recipe object OR a linked set:
[
  { "title": "Simple Recipe 1", ... },
  { "title": "Simple Recipe 2", ... },
  { "recipes": [...], "links": {...} },
  { "recipes": [...], "links": {...} }
]
This is the PREFERRED format for any multi-recipe import.

Rules:
- You can import any number of recipes at once (1, 5, 20, 100+) — just wrap them in a JSON array
- Each recipe in the array uses the exact same format shown above
- If a recipe has components that are themselves recipes (e.g. a cake with separate frosting, filling, crust recipes), use the linked format above
- CRITICAL: Output ONE top-level JSON value. Do NOT output multiple separate JSON blobs separated by blank lines — that is invalid JSON. Combine everything into one array or object.
- "amount" is a string (supports fractions like "1/2", "1 1/2") or null
- "unit" is a string (cups, tbsp, tsp, oz, lb, g, kg, ml, etc.) or null if not applicable (e.g. "3 eggs")
- "notes" on ingredients is for prep details like "diced", "room temperature", "melted"
- INGREDIENT HEADERS: If a recipe has ingredient sections (e.g. "For the sauce", "For the dough"), add a header ingredient with "notes": "__header__" and "name" set to the section title. Set amount and unit to null for headers.
- STEP HEADERS: If the method has distinct phases or sub-recipes (e.g. "Make the sauce", "Cook the pasta", "Assemble"), add a header step with "notes": "__header__" and "instruction" set to the section title (omit or null durationMinutes). Put the steps for each phase directly after its header. Whenever ingredients and steps share the same sections, use the SAME section titles for both so the recipe reads as clean matching sections on the Ingredients and Instructions tabs.
- Only add headers when the recipe clearly has separate sections/phases. Do NOT add headers when there is just one group. For a recipe with 2+ components or sub-recipes that are followed together in one recipe (not linked as separate recipes), USE headers to group both the ingredients and the steps of each component — do not flatten everything into one list.
- "durationMinutes" on steps is optional (null if not specified)
- "course" must be one of: Appetizer, Beverage, Breakfast, Brunch, Dessert, Main Dish, Sauce, Side Dish, Snack
- "category" must be one of: Bean, Beverage, Bread, Burrito/Taco, Casserole, Chicken/Steak/Meat, Dessert, Fish, Fruit, Muffin, Pasta, Rice, Salad, Sandwich, Sauce, Soup, Vegetable
- "cuisine" is a free-text string like "Italian", "Mexican", "Japanese", "American", etc.
- "tags" is an array of short descriptive tags like "quick", "weeknight", "comfort food", "spicy", "gluten-free"
- Pick the single best-matching course and category for each recipe
- Keep step instructions clear and concise
- AMOUNTS IN STEPS: When a step uses an ingredient, include its quantity from the ingredient list inline, so the cook never has to scroll back up. Write "Combine 1/4 cup lime juice and 1/3 cup chopped cilantro" — NOT "Combine lime juice and cilantro". Distribute each ingredient's amount across the step(s) that use it (e.g. if 2 cups flour is added in two stages, say "1 cup" each time). Keep the ingredient list itself unchanged with the full amounts.
- Output valid JSON only — no markdown, no backticks, no commentary
''';
  }

  // ══════════════════════════════════════════
  //  ENHANCE — reformat an EXISTING recipe
  // ══════════════════════════════════════════

  /// Serialize an existing recipe into the enhance JSON shape (course/category
  /// as names, `__header__` markers preserved) so it can be handed to an AI.
  static Map<String, dynamic> serializeRecipeForEnhance(
    Recipe recipe,
    List<Ingredient> ingredients,
    List<Step> steps,
  ) {
    return {
      'title': recipe.title,
      'description': recipe.description ?? '',
      'servings': recipe.servings ?? '',
      'prepTimeMinutes': recipe.prepTimeMinutes,
      'cookTimeMinutes': recipe.cookTimeMinutes,
      'course': recipe.courseId != null ? CourseData.getById(recipe.courseId!)?.name : null,
      'category': recipe.categoryId != null ? CategoryData.getById(recipe.categoryId!)?.name : null,
      'sourceUrl': recipe.sourceUrl ?? '',
      'notes': recipe.notes ?? '',
      'ingredients': ingredients
          .map((i) => {'amount': i.amount, 'unit': i.unit, 'name': i.name, 'notes': i.notes})
          .toList(),
      'steps': steps
          .map((s) => {'instruction': s.instruction, 'durationMinutes': s.durationMinutes, 'notes': s.notes})
          .toList(),
    };
  }

  /// The full copy-paste blob for the "Use Your Own AI" enhance path:
  /// enhance instructions + the recipe JSON, ready to paste into any AI.
  static String buildEnhanceBlob(
    Recipe recipe,
    List<Ingredient> ingredients,
    List<Step> steps,
  ) {
    final json = const JsonEncoder.withIndent('  ')
        .convert(serializeRecipeForEnhance(recipe, ingredients, steps));
    return '${generateEnhancePrompt()}\n\nHERE IS THE RECIPE TO ENHANCE:\n$json';
  }

  /// The enhance system prompt — reformat for readability, faithful to content.
  static String generateEnhancePrompt() {
    return '''You are reformatting an EXISTING recipe to make it clearer and easier to follow. Return the SAME recipe as improved JSON in the exact format below. Output ONE JSON object only — no markdown, no backticks, no commentary.

DO (formatting and structure only):
- Add SECTION HEADERS where the recipe has distinct parts. An ingredient header is an entry with "notes": "__header__", "name" set to the section title, and amount/unit null. A step header is a step with "notes": "__header__" and "instruction" set to the section title. Use the SAME section titles for matching ingredient and step sections (e.g. "For the sauce").
- INLINE the exact ingredient amounts into the steps that use them, so the cook never scrolls back up. Write "Add the 1/2 cup cream and 2 oz vodka" — not "Add the cream and vodka". Distribute an amount across the steps that use it. Keep the ingredient list amounts unchanged.
- Improve wording/clarity of steps and fill in obviously-missing metadata (course, category) — only when clearly implied.

DO NOT (never change the actual recipe):
- Do NOT add, remove, rename, or re-quantify ingredients. Keep every ingredient and its exact amount/unit.
- Do NOT change the method, temperatures, times, or the set of real steps (you may split a run-on step or add headers, but do not invent new cooking actions).
- Do NOT drop the sourceUrl or the user's existing notes.

FORMAT:
{
  "title": "Recipe Name",
  "description": "Brief description",
  "servings": "4",
  "prepTimeMinutes": 15,
  "cookTimeMinutes": 30,
  "course": "Main Dish",
  "category": "Pasta",
  "sourceUrl": "",
  "notes": "",
  "ingredients": [
    { "amount": null, "unit": null, "name": "For the sauce", "notes": "__header__" },
    { "amount": "2", "unit": "cups", "name": "crushed tomatoes", "notes": null }
  ],
  "steps": [
    { "instruction": "For the sauce", "notes": "__header__" },
    { "instruction": "Simmer the 2 cups crushed tomatoes for 20 minutes.", "durationMinutes": 20 }
  ]
}

RULES:
- "amount" is a string ("1/2", "1 1/2") or null. "unit" is a string or null (e.g. "3 eggs" -> unit null).
- "course" must be one of: Appetizer, Beverage, Breakfast, Brunch, Dessert, Main Dish, Sauce, Side Dish, Snack
- "category" must be one of: Bean, Beverage, Bread, Burrito/Taco, Casserole, Chicken/Steak/Meat, Dessert, Fish, Fruit, Muffin, Pasta, Rice, Salad, Sandwich, Sauce, Soup, Vegetable
- Only add headers if the recipe genuinely has separate sections. A simple one-part recipe needs no headers.
- Output valid JSON only — no markdown, no backticks, no commentary.''';
  }

  /// Parse a pasted enhance result into a single recipe map (lenient about
  /// markdown fences / stray text). Throws [FormatException] with a friendly
  /// message if it isn't valid recipe JSON.
  static Map<String, dynamic> parseSingleEnhancedRecipe(String jsonString) {
    final cleaned = _cleanJson(jsonString);
    final (allRecipes, _) = _decodeMultipleBlobs(cleaned);
    if (allRecipes.isEmpty) {
      throw const FormatException("That didn't look like valid recipe JSON.");
    }
    final recipe = allRecipes.first;
    final err = _validateSingleRecipe(recipe);
    if (err != null) throw FormatException(err);
    return recipe;
  }

  /// Apply an enhanced recipe map onto the EXISTING recipe (update in place).
  /// Preserves photos (cover + step images by order), rating/favorite/cook
  /// count, sourceUrl, and merges notes (append). Replaces the content fields.
  static Future<void> applyEnhancement({
    required String recipeId,
    required Map<String, dynamic> enhanced,
    required AppDatabase db,
  }) async {
    final existing = await (db.select(db.recipes)..where((t) => t.id.equals(recipeId))).getSingleOrNull();
    if (existing == null) return;

    final oldSteps = await (db.select(db.steps)
          ..where((t) => t.recipeId.equals(recipeId))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
    // Real (non-header) step images, in order, to re-attach after restructure.
    final oldStepImages =
        oldSteps.where((s) => s.notes != '__header__').map((s) => s.imagePath).toList();

    // Preserve sub-recipe links across the rebuild. Ingredient ids are
    // regenerated, so key each link to a stable "name#occurrence" slot (the Nth
    // ingredient named X). This survives header shifts AND handles duplicate
    // ingredient names (e.g. "salt" in two sections) without mis-attaching.
    final oldIngredients = await (db.select(db.ingredients)
          ..where((t) => t.recipeId.equals(recipeId))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
    final oldLinks =
        await (db.select(db.recipeLinks)..where((t) => t.sourceRecipeId.equals(recipeId))).get();
    final oldIngKey = <String, String>{}; // old ingredientId -> "name#occ"
    final oldOcc = <String, int>{};
    for (final ing in oldIngredients) {
      final name = ing.name.toLowerCase().trim();
      final occ = oldOcc.update(name, (v) => v + 1, ifAbsent: () => 0);
      oldIngKey[ing.id] = '$name#$occ';
    }
    final linksByKey = <String, List<RecipeLink>>{};
    for (final link in oldLinks) {
      final key = oldIngKey[link.ingredientId];
      if (key != null) linksByKey.putIfAbsent(key, () => []).add(link);
    }

    final courseId = _resolveCourseId(_optString(enhanced['course'])) ?? existing.courseId;
    final categoryId = _resolveCategoryId(_optString(enhanced['category'])) ?? existing.categoryId;
    final title = _optString(enhanced['title'])?.trim();

    await db.transaction(() async {
      await (db.update(db.recipes)..where((t) => t.id.equals(recipeId))).write(RecipesCompanion(
        title: Value(title != null && title.isNotEmpty ? title : existing.title),
        description: Value(_optString(enhanced['description']) ?? existing.description),
        servings: Value(_optString(enhanced['servings']) ?? existing.servings),
        prepTimeMinutes: Value(_optInt(enhanced['prepTimeMinutes']) ?? existing.prepTimeMinutes),
        cookTimeMinutes: Value(_optInt(enhanced['cookTimeMinutes']) ?? existing.cookTimeMinutes),
        courseId: Value(courseId),
        categoryId: Value(categoryId),
        notes: Value(_mergeNotes(existing.notes, _optString(enhanced['notes']))),
        updatedAt: Value(DateTime.now()),
        // Preserved (omitted → unchanged): sourceUrl, rating, isFavorite,
        // isPinned, cookCount, imagePath, cookbookId, createdAt.
      ));

      await (db.delete(db.ingredients)..where((t) => t.recipeId.equals(recipeId))).go();
      final ings = (enhanced['ingredients'] as List?) ?? const [];
      final newIdByKey = <String, String>{}; // "name#occ" -> new ingredientId
      final newOcc = <String, int>{};
      for (var i = 0; i < ings.length; i++) {
        final ing = ings[i] as Map<String, dynamic>;
        final name = (_optString(ing['name']) ?? '').trim();
        final id = '${recipeId}_ing_$i';
        await db.into(db.ingredients).insert(IngredientsCompanion.insert(
          id: id,
          recipeId: recipeId,
          sortOrder: i,
          name: name,
          amount: Value(_optString(ing['amount'])),
          unit: Value(_optString(ing['unit'])),
          notes: Value(_normalizeHeaderMarker(_optString(ing['notes']))),
        ));
        final lower = name.toLowerCase();
        final occ = newOcc.update(lower, (v) => v + 1, ifAbsent: () => 0);
        newIdByKey['$lower#$occ'] = id;
      }

      await (db.delete(db.steps)..where((t) => t.recipeId.equals(recipeId))).go();
      final steps = (enhanced['steps'] as List?) ?? const [];
      var realIdx = 0;
      for (var i = 0; i < steps.length; i++) {
        final step = steps[i] as Map<String, dynamic>;
        final isHeader = _normalizeHeaderMarker(_optString(step['notes'])) == '__header__';
        String? img;
        if (!isHeader) {
          if (realIdx < oldStepImages.length) img = oldStepImages[realIdx];
          realIdx++;
        }
        await db.into(db.steps).insert(StepsCompanion.insert(
          id: '${recipeId}_step_$i',
          recipeId: recipeId,
          sortOrder: i,
          instruction: (_optString(step['instruction']) ?? '').trim(),
          durationMinutes: Value(isHeader ? null : _optInt(step['durationMinutes'])),
          imagePath: Value(img),
          notes: Value(isHeader ? '__header__' : null),
        ));
      }

      // Re-attach sub-recipe links to the matching new ingredient slot.
      await (db.delete(db.recipeLinks)..where((t) => t.sourceRecipeId.equals(recipeId))).go();
      for (final entry in linksByKey.entries) {
        final newIngId = newIdByKey[entry.key];
        if (newIngId == null) continue;
        for (final link in entry.value) {
          // insertOnConflictUpdate so a collapsed {source, ingredient, linked}
          // duplicate updates instead of throwing and rolling back the enhance.
          await db.into(db.recipeLinks).insertOnConflictUpdate(RecipeLinksCompanion.insert(
            sourceRecipeId: recipeId,
            ingredientId: newIngId,
            linkedRecipeId: link.linkedRecipeId,
            scale: Value(link.scale),
          ));
        }
      }
    });
  }

  /// Accept both "header" (build-doc schema) and "__header__" (app marker);
  /// emit "__header__". Other notes pass through.
  static String? _normalizeHeaderMarker(String? notes) {
    if (notes == null) return null;
    final t = notes.trim();
    if (t == 'header' || t == '__header__') return '__header__';
    return notes;
  }

  /// Merge notes: keep the original, append the AI's only if it adds something.
  /// Compares whitespace-insensitively in BOTH directions so a reworded or
  /// expanded echo of the original isn't appended to itself (keeps re-enhance
  /// idempotent rather than growing the notes on every pass).
  static String? _mergeNotes(String? original, String? ai) {
    final o = (original ?? '').trim();
    final a = (ai ?? '').trim();
    if (a.isEmpty) return o.isEmpty ? null : o;
    if (o.isEmpty) return a;
    final on = o.replaceAll(RegExp(r'\s+'), ' ');
    final an = a.replaceAll(RegExp(r'\s+'), ' ');
    if (on.contains(an)) return o; // AI notes already covered by the original
    if (an.contains(on)) return a; // AI notes are a superset — take them
    return '$o\n\n$a';
  }
}

/// Internal helper: tracks a linked-recipe blob for restoring links after import.
class _LinkedBlob {
  final String mainRecipeTitle;
  final Map<String, List<String>> links;
  const _LinkedBlob({required this.mainRecipeTitle, required this.links});
}