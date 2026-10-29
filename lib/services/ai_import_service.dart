import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../data/course_category_data.dart';
import '../utils/text_encoding.dart';

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
      final (allRecipes, _) = _decodeMultipleBlobs(jsonString);
      return allRecipes;
    } catch (_) {
      return [];
    }
  }

  static String? validate(String jsonString) {
    try {
      final (allRecipes, _) = _decodeMultipleBlobs(jsonString);

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
    final title = recipe['title'];
    if (title is! String || title.trim().isEmpty) {
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
      final name = ing['name'];
      if (name is! String || name.trim().isEmpty) {
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
      final instruction = step['instruction'];
      if (instruction is! String || instruction.trim().isEmpty) {
        return '${prefix}Step #${i + 1} is missing an "instruction" field.';
      }
    }

    return null; // Valid!
  }

  /// Parse and import recipe(s) from JSON string into the database.
  /// Supports single recipe objects, arrays of recipes,
  /// v3 export format ({ "recipes": [...], "links": {...} }),
  /// AND multiple concatenated JSON blobs (common AI mistake).
  /// Either every recipe is saved or none is: text that [validate] would
  /// turn down throws a [FormatException], a [cookbookId] that does not exist
  /// throws an [ArgumentError], and a failure while saving leaves nothing
  /// behind.
  /// With [only], just the recipes at those positions of the list
  /// [extractRecipes] gives for the same text are saved; a link to a recipe
  /// that was left out is dropped.
  /// Returns a list of created recipe IDs.
  static Future<List<String>> importAllFromJson(
      String jsonString,
      AppDatabase db, {
        required String cookbookId,
        Set<int>? only,
      }) async {
    final (allRecipes, linkedBlobs) = _decodeMultipleBlobs(jsonString);
    final picked = only == null
        ? allRecipes
        : [for (var i = 0; i < allRecipes.length; i++) if (only.contains(i)) allRecipes[i]];
    return _saveRecipes(picked, linkedBlobs, db, cookbookId: cookbookId);
  }

  /// Parse and import a recipe from JSON string into the database.
  /// Returns the created recipe's ID.
  static Future<String> importFromJson(
      String jsonString,
      AppDatabase db, {
        required String cookbookId,
      }) async {
    final (allRecipes, _) = _decodeMultipleBlobs(jsonString);
    final ids = await _saveRecipes(allRecipes.take(1).toList(), const [], db, cookbookId: cookbookId);
    return ids.single;
  }

  /// Write [recipes], the tags they ask for and the links of [linkedBlobs] in
  /// one transaction. Returns the recipe IDs in the order of [recipes].
  static Future<List<String>> _saveRecipes(
      List<Map<String, dynamic>> recipes,
      List<_LinkedBlob> linkedBlobs,
      AppDatabase db, {
        required String cookbookId,
      }) async {
    if (recipes.isEmpty) {
      throw const FormatException('No recipes found in JSON');
    }
    for (var r = 0; r < recipes.length; r++) {
      final err = _validateSingleRecipe(recipes[r], recipeIndex: r + 1);
      if (err != null) throw FormatException(err);
    }

    return db.transaction(() async {
      // The database does not check that a recipe's cookbook exists, and a
      // recipe filed under one that is gone shows up nowhere in the app.
      final cookbook = await (db.select(db.cookbooks)..where((t) => t.id.equals(cookbookId))).getSingleOrNull();
      if (cookbook == null) {
        throw ArgumentError.value(cookbookId, 'cookbookId', 'No such cookbook');
      }

      // The tags that exist, by name, read once for the whole import.
      final tags = await (db.select(db.tags)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();
      final liveTagIds = {for (final tag in tags) tag.id};
      final tagIdByKey = <String, String>{};
      for (final tag in tags) {
        tagIdByKey.putIfAbsent(_tagKey(tag.name), () => tag.id);
      }
      var nextTagOrder = tags.isEmpty ? 0 : tags.last.sortOrder + 1;

      final ids = <String>[];
      // One batch, so a bulk import is a single trip to the database instead
      // of one per row.
      await db.batch((batch) {
        // An existing tag of that name (or the built-in one the name stands
        // for), else a new tag that later recipes of this import reuse.
        String tagIdFor(String name) {
          final key = _tagKey(name);
          final alias = _tagAliases[key];
          var id = tagIdByKey[key] ?? (liveTagIds.contains(alias) ? alias : null);
          if (id == null) {
            id = 'tag_${_uuid.v4()}';
            batch.insert(db.tags, TagsCompanion.insert(
              id: id,
              name: _tagTitle(name),
              sortOrder: Value(nextTagOrder++),
            ));
            tagIdByKey[key] = id;
          }
          return id;
        }

        // Import all recipes. IDs are tracked by the decoded map itself, so
        // two recipes with the same title stay apart.
        final idOf = Map<Map<String, dynamic>, String>.identity();
        final idByTitle = <String, String>{};
        for (final data in recipes) {
          final id = _importSingleRecipe(
            data,
            db,
            batch,
            cookbookId: cookbookId,
            // A bulk import would flood "Jump back in" with recipes nobody
            // has opened yet.
            markViewed: recipes.length == 1,
            tagIdFor: tagIdFor,
          );
          ids.add(id);
          idOf[data] = id;
          idByTitle.putIfAbsent(_titleKey(data['title']), () => id);
        }

        // Restore ingredient links from each linked blob
        for (final blob in linkedBlobs) {
          final main = blob.recipes.first;
          final mainRecipeId = idOf[main];
          if (mainRecipeId == null) continue;

          // A set looks among its own sub-recipes first: two sets can each
          // have a "Frosting". A title from elsewhere in the paste is the
          // fallback.
          final ownByTitle = <String, String>{};
          for (final sub in blob.recipes.skip(1)) {
            final id = idOf[sub];
            if (id != null) ownByTitle.putIfAbsent(_titleKey(sub['title']), () => id);
          }
          final ingredientNames = [
            for (final ing in main['ingredients'] as List) _titleKey((ing as Map)['name']),
          ];

          for (final entry in blob.links.entries) {
            // Find the ingredient by name
            final index = ingredientNames.indexOf(_titleKey(entry.key));
            if (index < 0) continue;

            for (final linkedTitle in entry.value) {
              final key = _titleKey(linkedTitle);
              final linkedId = ownByTitle[key] ?? idByTitle[key];
              if (linkedId == null || linkedId == mainRecipeId) continue;

              // Create the link
              batch.insert(
                db.recipeLinks,
                RecipeLinksCompanion.insert(
                  sourceRecipeId: mainRecipeId,
                  ingredientId: '${mainRecipeId}_ing_$index',
                  linkedRecipeId: linkedId,
                ),
                mode: InsertMode.insertOrReplace,
              );
            }
          }
        }
      });

      return ids;
    });
  }

  /// How a recipe title or ingredient name is compared when links are
  /// restored: without regard to case or the spaces around it.
  static String _titleKey(dynamic text) => text is String ? text.trim().toLowerCase() : '';

  /// Queue the rows of a single recipe map on [batch]. Returns the recipe ID.
  static String _importSingleRecipe(
      Map<String, dynamic> data,
      AppDatabase db,
      Batch batch, {
        required String cookbookId,
        required bool markViewed,
        required String Function(String name) tagIdFor,
      }) {
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

    batch.insert(db.recipes, RecipesCompanion.insert(
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
      lastViewedAt: markViewed ? Value(now) : const Value.absent(),
    ));

    // ── Ingredients ──
    final ingredients = data['ingredients'] as List;
    for (var i = 0; i < ingredients.length; i++) {
      final ing = ingredients[i] as Map<String, dynamic>;
      final (name, prepNotes) = _fitIngredientName((ing['name'] as String).trim(), _optString(ing['notes']));
      batch.insert(db.ingredients, IngredientsCompanion.insert(
        id: '${recipeId}_ing_$i',
        recipeId: recipeId,
        sortOrder: i,
        name: name,
        amount: Value(_optString(ing['amount'])),
        unit: Value(_optString(ing['unit'])),
        notes: Value(prepNotes),
      ));
    }

    // ── Steps ──
    final steps = data['steps'] as List;
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i] as Map<String, dynamic>;
      batch.insert(db.steps, StepsCompanion.insert(
        id: '${recipeId}_step_$i',
        recipeId: recipeId,
        sortOrder: i,
        instruction: (step['instruction'] as String).trim(),
        durationMinutes: Value(_optInt(step['durationMinutes'])),
        notes: Value(_optString(step['notes'])),
      ));
    }

    // ── Tags (the cuisine is kept as one) ──
    final tagIds = {for (final name in (data['tags'] as List?) ?? const []) tagIdFor(name as String)};
    for (final tagId in tagIds) {
      batch.insert(db.recipeTags, RecipeTagsCompanion.insert(recipeId: recipeId, tagId: tagId));
    }

    return recipeId;
  }

  /// Ingredients.name allows up to this many characters.
  static const int _maxIngredientNameLength = 200;

  /// Make an ingredient name fit the table without throwing text away. A name
  /// that long is a name with its preparation run together ("chicken thighs,
  /// trimmed and cut into ..."), so it is cut at the first comma, bracket or
  /// semicolon and the rest goes in front of the notes. With nowhere to cut,
  /// the name is shortened and the notes keep it in full. A section header
  /// has only its name, so that is shortened.
  static (String, String?) _fitIngredientName(String name, String? notes) {
    if (name.length <= _maxIngredientNameLength) return (name, notes);
    // An emoji takes two places in the text: a cut between them would leave
    // half of it behind.
    var end = _maxIngredientNameLength - 1;
    final last = name.codeUnitAt(end - 1);
    if (last >= 0xD800 && last <= 0xDBFF) end--;
    final shortened = '${name.substring(0, end)}…';
    if (notes == '__header__') return (shortened, notes);

    final cut = name.indexOf(RegExp(r'[,(;]'));
    final head = cut > 0 ? name.substring(0, cut).trim() : '';
    if (head.isEmpty || head.length > _maxIngredientNameLength) {
      return (shortened, notes == null ? name : '$name; $notes');
    }
    var rest = name.substring(cut).trim();
    if (!rest.startsWith('(')) rest = rest.substring(1).trim();
    final parts = [if (rest.isNotEmpty) rest, if (notes != null) notes];
    return (head, parts.isEmpty ? null : parts.join('; '));
  }

  /// A tag name longer than this is a sentence, not a tag.
  static const int _maxTagNameLength = 30;

  /// The most tags one recipe brings along, so that an answer full of
  /// made-up tags cannot flood the tag list.
  static const int _maxTagsPerRecipe = 8;

  /// What the prompt's own example tags are called among the built-in tags.
  static const Map<String, String> _tagAliases = {
    'quick': 'tag_quick',
    'easy': 'tag_quick',
    'quick and easy': 'tag_quick',
    'weeknight': 'tag_weeknight',
  };

  static final RegExp _lettersOrDigits = RegExp(r'[\p{L}\p{N}]+', unicode: true);

  /// How tag names are compared: "Gluten-Free", "gluten free" and
  /// "GLUTEN FREE" are the same tag.
  static String _tagKey(String name) =>
      [for (final word in _lettersOrDigits.allMatches(name.toLowerCase())) word[0]!].join(' ');

  /// What parts one tag from the next when several are written as one text:
  /// a comma, a semicolon or a line break, the Chinese, Japanese and Arabic
  /// commas and semicolons included.
  static final RegExp _tagSeparator = RegExp('[,;\n\r\uFF0C\u3001\uFF1B\u060C\u061B]');

  /// A new tag's name as it reads next to the built-in ones:
  /// "date night" becomes "Date Night".
  static String _tagTitle(String name) => name.replaceAllMapped(
        RegExp(r'(^|[\s-])(\p{Ll})', unicode: true),
        (m) => '${m[1]}${m[2]!.toUpperCase()}',
      );

  /// The tags a recipe brings along: its cuisine, then its tags. Several
  /// written as one text ("quick; spicy") are taken apart. Names that repeat,
  /// are empty or too long are left out.
  static List<String> _tagNames(dynamic tags, String? cuisine) {
    final names = <String>[];
    final seen = <String>{};
    for (final raw in [
      if (cuisine != null) cuisine,
      if (tags is List) ...tags.whereType<String>() else if (tags is String) tags,
    ]) {
      for (final part in raw.split(_tagSeparator)) {
        final name = part.trim();
        // The length comes first: a text that long is not worth comparing.
        if (name.length > _maxTagNameLength) continue;
        final key = _tagKey(name);
        if (key.isEmpty || !seen.add(key)) continue;
        names.add(name);
        if (names.length == _maxTagsPerRecipe) return names;
      }
    }
    return names;
  }

  /// The index just past the `// line` or `/* block */` comment that starts
  /// at [i], or [i] itself when no comment starts there. A block comment that
  /// is never closed runs to the end of the text.
  static int _skipComment(String s, int i) {
    if (i + 1 >= s.length || s[i] != '/') return i;
    if (s[i + 1] == '/') {
      final end = s.indexOf('\n', i + 2);
      return end < 0 ? s.length : end;
    }
    if (s[i + 1] == '*') {
      final end = s.indexOf('*/', i + 2);
      return end < 0 ? s.length : end + 2;
    }
    return i;
  }

  /// Whitespace between JSON tokens. Blanks that are not plain spaces count
  /// as well: chat pages indent their code with no-break spaces, an Asian
  /// keyboard types a wide one, and a web page or a right-to-left text can
  /// leave marks in between that do not show at all.
  static bool _isJsonSpace(String c) {
    if (c == ' ' || c == '\n' || c == '\r' || c == '\t') return true;
    final unit = c.codeUnitAt(0);
    return unit == 0x0B ||
        unit == 0x0C ||
        unit == 0x85 ||
        unit == 0xA0 ||
        (unit >= 0x2000 && unit <= 0x200F) ||
        (unit >= 0x2028 && unit <= 0x202F) ||
        (unit >= 0x205F && unit <= 0x206F) ||
        unit == 0x3000 ||
        unit == 0xFEFF;
  }

  /// The quote marks a key may come in: the plain double and single ones, and
  /// the curly ones that a phone or a word processor makes of them.
  static const String _quoteMarks = '"\'\u201C\u201D\u2018\u2019';

  /// Any one of [_quoteMarks], as a regular expression.
  static const String _anyQuote = '[$_quoteMarks]';

  /// The fields that make an object a recipe, or a set of them.
  static const Set<String> _recipeFields = {'title', 'ingredients', 'steps', 'recipes'};

  /// How an object opens when its first key is not in plain double quotes: one
  /// of the format's field names in single or curly quotes, or in none, and
  /// a colon.
  static final RegExp _looseKey = RegExp(
    '$_anyQuote?(?:title|description|servings|prepTimeMinutes|cookTimeMinutes|course|category|cuisine|tags|rating|'
    'sourceUrl|notes|ingredients|steps|recipes|links|version)$_anyQuote?\\s*:',
    caseSensitive: false,
  );

  /// One of [_recipeFields] written as a key: in quotes of any kind, or
  /// followed by its colon.
  static final RegExp _recipeKey = RegExp(
    '$_anyQuote(?:title|ingredients|steps|recipes)$_anyQuote|(?:title|ingredients|steps|recipes)$_anyQuote?\\s*:',
    caseSensitive: false,
  );

  /// A recipe's field the way JSON writes it: the name in quotes, a colon,
  /// and the text or the list that it holds.
  static final RegExp _recipeFieldInJson = RegExp(
    '$_anyQuote(title)$_anyQuote\\s*:\\s*$_anyQuote|$_anyQuote(ingredients|steps|recipes)$_anyQuote\\s*:\\s*\\[',
    caseSensitive: false,
  );

  /// Whether the bracket at [i] opens a JSON value and is not just a bracket
  /// in a sentence ("[optional]", "{the}", ":-["): an object begins with a
  /// key or is empty, a list of recipes begins with an object. The key is a
  /// quoted one, or one of a recipe's own fields however it is quoted: a
  /// recipe typed with the wrong quotes must be read and reported, not passed
  /// over as chat text.
  ///
  /// A bracket the text ends on counts too, as the start of a value that was
  /// cut off, but only where a value can begin: at the end of a sentence it
  /// is a smiley or a remark.
  static bool _opensJsonValue(String s, int i) {
    var j = i + 1;
    while (j < s.length) {
      final past = _isJsonSpace(s[j]) ? j + 1 : _skipComment(s, j);
      if (past == j) break;
      j = past;
    }
    if (j >= s.length) return _canBeginValue(s, i);
    if (s[i] == '[') return s[j] == '{' && _opensJsonValue(s, j);
    return s[j] == '"' || s[j] == '}' || _looseKey.matchAsPrefix(s, j) != null;
  }

  /// Whether a JSON value can begin at [i]: at the start of a line, or
  /// straight after a comma or an opening bracket.
  static bool _canBeginValue(String s, int i) {
    var before = i - 1;
    while (before >= 0 && s[before] != '\n' && s[before] != '\r' && _isJsonSpace(s[before])) {
      before--;
    }
    return before < 0 || '\n\r,[{'.contains(s[before]);
  }

  /// Reads the JSON value that opens at [start], leaving out what a model
  /// tends to add to one: `// line` and `/* block */` comments, and a comma
  /// in front of a closing bracket. Walks the text tracking in-string state
  /// (honoring `\"` escapes), so the contents of string literals are copied
  /// untouched: the `//` of a URL stays, and so does a ", ]" in an
  /// instruction.
  ///
  /// Returns the cleaned value and the index just past it, or null when the
  /// text ends before the value does.
  static (String, int)? _readJsonValue(String s, int start) {
    final out = StringBuffer();
    final openChar = s[start];
    final closeChar = openChar == '{' ? '}' : ']';
    var depth = 0;
    var inString = false;
    // A comma is held back until it is known what follows it: in front of a
    // closing bracket it is a trailing comma and is dropped.
    var heldComma = false;
    var i = start;
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
      final past = _skipComment(s, i);
      if (past > i) {
        i = past;
        continue;
      }
      if (_isJsonSpace(c)) {
        // The decoder only takes the plain kinds of whitespace.
        out.write(c == '\n' || c == '\r' || c == '\t' ? c : ' ');
        i++;
        continue;
      }
      if (c == ',') {
        // A second comma in a row is a mistake of another kind: keep both.
        if (heldComma) out.write(c);
        heldComma = true;
        i++;
        continue;
      }
      if (heldComma) {
        if (c != '}' && c != ']') out.write(',');
        heldComma = false;
      }
      out.write(c);
      if (c == '"') {
        inString = true;
      } else if (c == openChar) {
        depth++;
      } else if (c == closeChar) {
        depth--;
        if (depth == 0) return (out.toString(), i + 1);
      }
      i++;
    }
    return null;
  }

  /// Clean JSON string from common AI output artifacts.
  static String _cleanJson(String raw) => _splitMultipleJson(raw, recipes: false).first;

  /// Find the JSON values (objects/arrays) in a pasted answer and return each
  /// one cleaned, see [_readJsonValue]. Whatever stands between them is passed
  /// over: code fences, headings, "Recipe 2:" labels, commas, a closing
  /// sentence.
  ///
  /// Throws a [FormatException] when a value never closes: a cut-off answer
  /// must not pass for a shorter one. The same when, among [recipes], one of
  /// a recipe's fields stands in the text between the values: that recipe
  /// lost a bracket, and the others must not be imported without it. If no
  /// value is found, returns the text from its first to its last bracket (or
  /// all of it) for the decoder to judge.
  static List<String> _splitMultipleJson(String raw, {bool recipes = true}) {
    // Text mangled on its way to the clipboard (an accented letter showing as
    // two odd characters) is repaired first, so the checks and the import
    // read the same letters.
    final s = repairMojibake(raw);
    final results = <String>[];
    final lastCommentEnd = s.lastIndexOf('*/');
    var i = 0;
    while (i < s.length) {
      final c = s[i];
      if ((c == '{' || c == '[') && _opensJsonValue(s, i)) {
        final value = _readJsonValue(s, i);
        if (value == null) {
          throw const FormatException('A bracket is opened and never closed. The answer may have been cut off.');
        }
        results.add(value.$1);
        i = value.$2;
        continue;
      }
      // A comment between the values may quote a bracket of its own. The "//"
      // of "https://" is not a comment. Neither is a "/*" that is never closed
      // (the "recipes/*.json" of a sentence): as one it would hide every
      // recipe that follows it.
      if (c == '/' &&
          (i == 0 || (s[i - 1] != ':' && s[i - 1] != '/')) &&
          (!s.startsWith('/*', i) || lastCommentEnd >= i + 2)) {
        final past = _skipComment(s, i);
        if (past > i) {
          i = past;
          continue;
        }
      }
      if (recipes && _quoteMarks.contains(c)) {
        final field = _recipeFieldInJson.matchAsPrefix(s, i);
        if (field != null) {
          final where = results.isEmpty ? '' : ', after block ${results.length}';
          throw FormatException(
            '"${field[1] ?? field[2]}" stands outside the brackets of a recipe$where. '
            'A bracket or a quote may be missing, or it is a remark to take out.',
          );
        }
      }
      i++;
    }
    return results.isNotEmpty ? results : [_bracketed(s)];
  }

  /// The text from its first to its last bracket, or all of it when it has
  /// none.
  static String _bracketed(String s) {
    final first = s.indexOf(RegExp(r'[{\[]'));
    final lastBrace = s.lastIndexOf('}');
    final lastBracket = s.lastIndexOf(']');
    final last = lastBrace > lastBracket ? lastBrace : lastBracket;
    return first >= 0 && last > first ? s.substring(first, last + 1) : s.trim();
  }

  /// Whether a block of text that could not be decoded was meant as a recipe,
  /// going by the field names in it.
  static bool _looksLikeRecipeJson(String blob) => _recipeKey.hasMatch(blob);

  /// Whether a decoded object may be a recipe: one of a recipe's fields is
  /// named somewhere in it. Inside a wrapper or spelled with capitals it is
  /// still a recipe that went wrong, to be reported and not passed over. An
  /// object without any of them is a remark, whatever it holds.
  static bool _couldBeRecipe(Map<String, dynamic> m) {
    final pending = <Object?>[m];
    while (pending.isNotEmpty) {
      final next = pending.removeLast();
      if (next is List) {
        pending.addAll(next);
      } else if (next is Map) {
        if (next.keys.any((key) => key is String && _recipeFields.contains(key.toLowerCase()))) return true;
        pending.addAll(next.values);
      }
    }
    return false;
  }

  /// Parse potentially-multiple JSON blobs and return a combined structure.
  /// Merges recipe arrays from all blobs. Links from each {recipes, links} blob
  /// are tracked per-blob with a main recipe reference.
  static (List<Map<String, dynamic>>, List<_LinkedBlob>) _decodeMultipleBlobs(String jsonString) {
    final blobs = _splitMultipleJson(jsonString);
    final allRecipes = <Map<String, dynamic>>[];
    final linkedBlobs = <_LinkedBlob>[];

    void processMapElement(Map<String, dynamic> m) {
      // Next to the recipes, an answer may hold a remark in JSON form (a
      // sample ingredient, {"calories": 200}). That is not a recipe with its
      // fields missing.
      if (blobs.length > 1 && !_couldBeRecipe(m)) return;
      if (m.containsKey('recipes') && m['recipes'] is List) {
        // Linked recipe format
        final blobRecipes = <Map<String, dynamic>>[];
        for (final r in m['recipes'] as List) {
          if (r is Map<String, dynamic>) {
            _normalizeRecipe(r);
            blobRecipes.add(r);
            allRecipes.add(r);
          }
        }
        final blobLinks = <String, List<String>>{};
        final links = m['links'];
        if (links is Map<String, dynamic>) {
          links.forEach((ingredientName, titles) {
            // The titles belong in a list; a single one is often written bare.
            final linkedTitles = titles is List ? titles.whereType<String>().toList() : [if (titles is String) titles];
            if (linkedTitles.isNotEmpty) blobLinks[ingredientName] = linkedTitles;
          });
        }
        if (blobLinks.isNotEmpty && blobRecipes.isNotEmpty) {
          linkedBlobs.add(_LinkedBlob(
            recipes: blobRecipes,
            links: blobLinks,
          ));
        }
      } else {
        // Single recipe object
        _normalizeRecipe(m);
        allRecipes.add(m);
      }
    }

    FormatException? firstError;
    for (var b = 0; b < blobs.length; b++) {
      final dynamic decoded;
      try {
        decoded = jsonDecode(blobs[b]);
      } on FormatException catch (e) {
        // One block of several that cannot be read is only passed over when
        // it is plainly chat text. Dropping one that was meant as a recipe
        // would import the others as if nothing were missing.
        if (blobs.length > 1 && _looksLikeRecipeJson(blobs[b])) {
          throw FormatException('Block ${b + 1} of ${blobs.length} could not be read (${e.message})');
        }
        firstError ??= e;
        continue;
      }
      if (decoded is List) {
        // Array of items — each can be a recipe OR a linked set
        for (final r in decoded) {
          if (r is Map<String, dynamic>) processMapElement(r);
        }
      } else if (decoded is Map<String, dynamic>) {
        processMapElement(decoded);
      }
    }
    if (allRecipes.isEmpty) {
      if (firstError != null) throw firstError;
      // Only pieces of the text could be read and none of them is a recipe,
      // yet it names a recipe's fields: a recipe the reading could not get
      // into. What the decoder makes of the whole text says more about that
      // than "no recipes found".
      final whole = _bracketed(repairMojibake(jsonString));
      if (blobs.length > 1 && _looksLikeRecipeJson(whole)) jsonDecode(whole);
    }
    return (allRecipes, linkedBlobs);
  }

  /// Models do not always keep to the types the prompt asks for: an amount
  /// arrives as a number, a course wrapped in a list. Each field is brought
  /// to the type the rest of the code expects here, once and in place, so the
  /// checks, both previews and the import all read the same values.
  static void _normalizeRecipe(Map<String, dynamic> recipe) {
    void asText(Map<String, dynamic> map, List<String> keys) {
      for (final key in keys) {
        if (map.containsKey(key)) map[key] = _asText(map[key]);
      }
    }

    void asInt(Map<String, dynamic> map, List<String> keys) {
      for (final key in keys) {
        if (map.containsKey(key)) map[key] = _optInt(map[key]);
      }
    }

    // A recipe can sit in several categories, so a list of them stays whole.
    final category = recipe['category'];
    if (category is List) {
      final names = category.whereType<String>().join(', ');
      recipe['category'] = names.isEmpty ? null : names;
    }
    asText(recipe, const ['title', 'description', 'servings', 'course', 'category', 'cuisine', 'sourceUrl', 'notes']);
    asInt(recipe, const ['prepTimeMinutes', 'cookTimeMinutes', 'rating']);
    if (recipe.containsKey('tags') || recipe['cuisine'] != null) {
      recipe['tags'] = _tagNames(recipe['tags'], recipe['cuisine'] as String?);
    }

    final ingredients = recipe['ingredients'];
    if (ingredients is List) {
      for (final ing in ingredients) {
        if (ing is Map<String, dynamic>) asText(ing, const ['amount', 'unit', 'name', 'notes']);
      }
    }
    final steps = recipe['steps'];
    if (steps is List) {
      for (final step in steps) {
        if (step is Map<String, dynamic>) {
          asText(step, const ['instruction', 'notes']);
          asInt(step, const ['durationMinutes']);
        }
      }
    }
  }

  /// The text a field holds, whatever type it arrived as: a number the way
  /// it would be written ("2", not "2.0"), a list by its first text. An
  /// object, or true or false, is no text at all.
  static String? _asText(dynamic value) {
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) {
      if (value.abs() < _exactWholeNumbers && value == value.roundToDouble()) return value.round().toString();
      // Too big to round without changing its digits: only the ".0" goes.
      final text = value.toString();
      return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
    }
    if (value is List) return value.whereType<String>().firstOrNull;
    return null;
  }

  /// Whole numbers below this are read exactly on every platform. A longer one
  /// arrives rounded: turned into an integer it would change once more, and
  /// as a number of minutes it means nothing.
  static const double _exactWholeNumbers = 1e15;

  static String? _optString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int? _optInt(dynamic value) {
    if (value == null) return null;
    final number = value is num ? value : int.tryParse(value.toString());
    return number != null && number.abs() < _exactWholeNumbers ? number.round() : null;
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
    // A recipe can sit in several categories, written "Pasta, Casserole" and
    // stored as "pasta,casserole".
    final ids = <String>{
      for (final part in name.split(','))
        if (part.trim().isNotEmpty) catMap[part.trim().toLowerCase()] ?? part.trim(),
    };
    return ids.isEmpty ? null : ids.join(',');
  }

  /// The built-in course [name] stands for, or null if the app has no such
  /// course.
  static String? _knownCourseId(String? name) {
    final id = _resolveCourseId(name);
    return id != null && CourseData.getById(id) != null ? id : null;
  }

  /// The built-in categories [name] stands for, or null if the app has none
  /// of them.
  static String? _knownCategoryId(String? name) {
    final ids = (_resolveCategoryId(name) ?? '').split(',').where((id) => CategoryData.getById(id) != null);
    return ids.isEmpty ? null : ids.join(',');
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
    final (allRecipes, _) = _decodeMultipleBlobs(jsonString);
    if (allRecipes.isEmpty) {
      throw const FormatException("That didn't look like valid recipe JSON.");
    }
    final recipe = allRecipes.first;
    final err = _validateSingleRecipe(recipe);
    if (err != null) throw FormatException(err);
    // A course or category the app does not have is not applied (see
    // [applyEnhancement]), so the preview must not show it as added.
    if (_knownCourseId(_optString(recipe['course'])) == null) recipe['course'] = null;
    if (_knownCategoryId(_optString(recipe['category'])) == null) recipe['category'] = null;
    return recipe;
  }

  /// Apply an enhanced recipe map onto the EXISTING recipe (update in place).
  /// Preserves photos (cover + each step's image with its cloud copy),
  /// rating/favorite/cook count, sourceUrl, the course and categories it
  /// already has, and merges notes (append). Replaces the content fields.
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
    // Real (non-header) steps, in order, to re-attach their images after restructure.
    final oldRealSteps = oldSteps.where((s) => s.notes != '__header__').toList();

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

    // The prompt only asks for a missing course or category to be filled in.
    // What the recipe already has stays, also when the answer could not have
    // known it (a custom course, several categories), and a name the app does
    // not have is not stored.
    final courseId = _optString(existing.courseId) ?? _knownCourseId(_optString(enhanced['course']));
    final categoryId = _optString(existing.categoryId) ?? _knownCategoryId(_optString(enhanced['category']));
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
        final (name, notes) = _fitIngredientName(
          (_optString(ing['name']) ?? '').trim(),
          _normalizeHeaderMarker(_optString(ing['notes'])),
        );
        final id = '${recipeId}_ing_$i';
        await db.into(db.ingredients).insert(IngredientsCompanion.insert(
          id: id,
          recipeId: recipeId,
          sortOrder: i,
          name: name,
          amount: Value(_optString(ing['amount'])),
          unit: Value(_optString(ing['unit'])),
          notes: Value(notes),
        ));
        final lower = name.toLowerCase();
        final occ = newOcc.update(lower, (v) => v + 1, ifAbsent: () => 0);
        newIdByKey['$lower#$occ'] = id;
      }

      await (db.delete(db.steps)..where((t) => t.recipeId.equals(recipeId))).go();
      final steps = (enhanced['steps'] as List?) ?? const [];
      bool isHeaderStep(dynamic step) => _normalizeHeaderMarker(_optString((step as Map)['notes'])) == '__header__';
      final photos = _matchStepPhotos(oldRealSteps, [
        for (final step in steps)
          if (!isHeaderStep(step)) _optString(step['instruction']) ?? '',
      ]);
      var realIdx = 0;
      for (var i = 0; i < steps.length; i++) {
        final step = steps[i] as Map<String, dynamic>;
        final isHeader = isHeaderStep(step);
        // The local file and its cloud copy travel together: sync sends the
        // cloud copy, and without it other devices would drop the photo.
        final photo = isHeader ? null : photos[realIdx++];
        await db.into(db.steps).insert(StepsCompanion.insert(
          id: '${recipeId}_step_$i',
          recipeId: recipeId,
          sortOrder: i,
          instruction: (_optString(step['instruction']) ?? '').trim(),
          durationMinutes: Value(isHeader ? null : _optInt(step['durationMinutes'])),
          imagePath: Value(photo?.imagePath),
          imageServerPath: Value(photo?.imageServerPath),
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

  /// Recipes with more real steps than this pair their photos by position
  /// only: lining the steps up costs old steps times new steps.
  static const int _maxStepsToAlign = 200;

  /// How far apart two steps are that share no word, when the steps of a
  /// recipe are lined up with their rewritten ones.
  static const int _unrelated = 1000;

  /// The most a second partner for a step costs in that lining-up. A little
  /// over half of [_unrelated]: taking one step out and adding another then
  /// costs slightly more than leaving both in place, so that steps stay put
  /// when the words say nothing either way.
  static const int _extraPartner = 600;

  static final RegExp _lettersAndMarks = RegExp(r'[\p{L}\p{M}]+', unicode: true);

  /// Whether [rune] belongs to a script that is written without spaces
  /// between its words: Thai, Lao, Burmese, Khmer, and everything from the
  /// first Chinese and Japanese block up. That takes Korean in as well, which
  /// suits it: a Korean word carries its endings, so it seldom comes back
  /// letter for letter.
  static bool _isUnspacedScript(int rune) =>
      rune >= 0x2E80 ||
      (rune >= 0x0E00 && rune <= 0x0EFF) ||
      (rune >= 0x1000 && rune <= 0x109F) ||
      (rune >= 0x1780 && rune <= 0x17FF);

  /// The words that tell one step from another: amounts and short filler
  /// words are left out. Text written without spaces has no words to pick
  /// out, so there every two neighbouring letters count as one. A step that
  /// has nothing else keeps its short words ("Do it."), or it would not even
  /// match itself.
  static Set<String> _stepWords(String instruction) {
    final words = <String>{};
    final short = <String>{};
    for (final match in _lettersAndMarks.allMatches(instruction.toLowerCase())) {
      final runes = match[0]!.runes.toList();
      var start = 0;
      while (start < runes.length) {
        // One stretch of letters of the same kind of script.
        final unspaced = _isUnspacedScript(runes[start]);
        var end = start + 1;
        while (end < runes.length && _isUnspacedScript(runes[end]) == unspaced) {
          end++;
        }
        if (unspaced && end - start > 1) {
          for (var i = start; i + 1 < end; i++) {
            words.add(String.fromCharCodes(runes, i, i + 2));
          }
        } else if (end - start > 2) {
          words.add(String.fromCharCodes(runes, start, end));
        } else {
          short.add(String.fromCharCodes(runes, start, end));
        }
        start = end;
      }
    }
    return words.isEmpty ? short : words;
  }

  /// Which old step's photo each new real step carries, keyed by the step's
  /// position among the new real steps.
  ///
  /// With as many real steps as before they pair up by position. When a step
  /// was split or two were merged, the old and new steps are lined up in
  /// order by the words they share, so a photo follows the text it was taken
  /// for instead of sliding onto a neighbour. Where the words say nothing,
  /// position decides again, counted from the first step.
  static Map<int, Step> _matchStepPhotos(List<Step> oldSteps, List<String> newSteps) {
    bool hasPhoto(Step s) => (s.imagePath ?? '').isNotEmpty || (s.imageServerPath ?? '').isNotEmpty;
    final photos = <int, Step>{};
    final m = oldSteps.length;
    final k = newSteps.length;
    if (k == 0 || !oldSteps.any(hasPhoto)) return photos;
    if (m == k || m > _maxStepsToAlign || k > _maxStepsToAlign) {
      for (var i = 0; i < m && i < k; i++) {
        if (hasPhoto(oldSteps[i])) photos[i] = oldSteps[i];
      }
      return photos;
    }

    final oldWords = [for (final step in oldSteps) _stepWords(step.instruction)];
    final newWords = [for (final step in newSteps) _stepWords(step)];

    // A word that most of the old steps and most of the new ones use ("the",
    // "and") says nothing about which step is which.
    Map<String, int> stepsUsing(List<Set<String>> steps) {
      final count = <String, int>{};
      for (final words in steps) {
        for (final word in words) {
          count[word] = (count[word] ?? 0) + 1;
        }
      }
      return count;
    }

    final inOld = stepsUsing(oldWords);
    final inNew = stepsUsing(newWords);
    for (final words in [...oldWords, ...newWords]) {
      words.removeWhere((word) => (inOld[word] ?? 0) * 2 > m && (inNew[word] ?? 0) * 2 > k);
    }

    // How far apart two steps are: 0 when every word of the shorter one is in
    // the other, [_unrelated] when they share none. Whole numbers, so that
    // two ways of lining the steps up that are equally good count as equal.
    final apart = [
      for (final a in oldWords)
        [
          for (final b in newWords)
            a.isEmpty || b.isEmpty
                ? _unrelated
                : _unrelated - _unrelated * a.intersection(b).length ~/ (a.length < b.length ? a.length : b.length),
        ],
    ];

    // The steps are lined up in order, every step with a partner: a split step
    // has several new ones, merged steps share one. What it costs to go on
    // from old step i and new step j to old step a and new step b is how far
    // apart those two are. A second partner for a step costs [_extraPartner]
    // at most, though. At full price, a step that was added and one that was
    // taken out came cheaper as a pair than each as a second partner of its
    // neighbour, and the steps between them were dragged out of place.
    int price(int i, int j, int a, int b) =>
        (a == i || b == j) && apart[a][b] > _extraPartner ? _extraPartner : apart[a][b];

    // For the cheapest way on from (i, j) to the last steps: what it costs,
    // what it would cost at full price, and how many pairs it takes.
    final cost = [for (var i = 0; i < m; i++) List<int>.filled(k, 0)];
    final fullPrice = [for (var i = 0; i < m; i++) List<int>.filled(k, 0)];
    final pairs = [for (var i = 0; i < m; i++) List<int>.filled(k, 0)];

    // The pair to go on to from (i, j), null at the last steps: the one that
    // makes the rest cheapest. Of two that come to the same, it is the one
    // whose way is cheaper at full price (its pairs really are closer), then
    // the one with more pairs (it found more steps again for nothing), then
    // the next step in both lists at once: where the words give no lead, the
    // steps keep their place counted from the first one, the way they do when
    // their number has not changed, and the steps that were added or taken
    // out are made up for at the end.
    (int, int)? onward(int i, int j) {
      (int, int)? best;
      var bestCost = 0;
      var bestFullPrice = 0;
      for (final (a, b) in [(i + 1, j + 1), (i, j + 1), (i + 1, j)]) {
        if (a == m || b == k) continue;
        final total = price(i, j, a, b) + cost[a][b];
        final atFullPrice = apart[a][b] + fullPrice[a][b];
        if (best == null ||
            total < bestCost ||
            (total == bestCost &&
                (atFullPrice < bestFullPrice ||
                    (atFullPrice == bestFullPrice && pairs[a][b] > pairs[best.$1][best.$2])))) {
          best = (a, b);
          bestCost = total;
          bestFullPrice = atFullPrice;
        }
      }
      return best;
    }

    for (var i = m - 1; i >= 0; i--) {
      for (var j = k - 1; j >= 0; j--) {
        final next = onward(i, j);
        if (next == null) continue;
        final (a, b) = next;
        cost[i][j] = price(i, j, a, b) + cost[a][b];
        fullPrice[i][j] = apart[a][b] + fullPrice[a][b];
        pairs[i][j] = 1 + pairs[a][b];
      }
    }

    // Walk that way from the first steps. A photo goes to the closest of the
    // new steps its old step is paired with. Of several that are equally
    // close it is the last, a photo shows how its step ends, but the first
    // when the step shares no word with any of them: nothing says that it
    // moved.
    final target = List<int>.filled(m, 0);
    final closest = List<int>.filled(m, _unrelated + 1);
    for ((int, int)? at = (0, 0); at != null; at = onward(at.$1, at.$2)) {
      final (i, j) = at;
      final distance = apart[i][j];
      if (distance < closest[i] || (distance == closest[i] && distance < _unrelated)) {
        closest[i] = distance;
        target[i] = j;
      }
    }

    // Every step first keeps the photo of the old step that is closest to it.
    // Of two that are equally close it is the later one, merged steps keep
    // the photo of how they end, but the earlier one when neither shares a
    // word with it.
    final keeper = <int, int>{};
    for (var i = 0; i < m; i++) {
      if (!hasPhoto(oldSteps[i])) continue;
      final rival = keeper[target[i]];
      if (rival == null || closest[i] < closest[rival] || (closest[i] == closest[rival] && closest[i] < _unrelated)) {
        keeper[target[i]] = i;
      }
    }
    keeper.forEach((spot, i) => photos[spot] = oldSteps[i]);

    // Only then do the photos that lost their step look for the nearest one
    // that has none, so that no photo is pushed out of its own place. They
    // look on their own side first, which keeps them in order. A photo is
    // only let go when every step has one.
    bool isFree(int spot) => spot >= 0 && spot < k && !photos.containsKey(spot);
    for (var i = 0; i < m; i++) {
      final spot = target[i];
      if (!hasPhoto(oldSteps[i]) || keeper[spot] == i) continue;
      final side = i < keeper[spot]! ? -1 : 1;
      for (var d = 1; d < k; d++) {
        final free = isFree(spot + side * d) ? spot + side * d : (isFree(spot - side * d) ? spot - side * d : null);
        if (free == null) continue;
        photos[free] = oldSteps[i];
        break;
      }
    }
    return photos;
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
  /// The recipes of this set, the main recipe first.
  final List<Map<String, dynamic>> recipes;
  final Map<String, List<String>> links;
  const _LinkedBlob({required this.recipes, required this.links});
}