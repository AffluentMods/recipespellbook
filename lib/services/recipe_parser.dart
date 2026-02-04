import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

/// Result of parsing a recipe
class ParsedRecipe {
  String title;
  String? description;
  String? imageUrl;
  int? prepTimeMinutes;
  int? cookTimeMinutes;
  String? servings;
  List<String> ingredients;
  List<String> instructions;
  String? sourceUrl;
  String? notes;
  String? suggestedCourse;
  String? suggestedCategory;

  ParsedRecipe({
    required this.title,
    this.description,
    this.imageUrl,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings,
    required this.ingredients,
    required this.instructions,
    this.sourceUrl,
    this.notes,
    this.suggestedCourse,
    this.suggestedCategory,
  });

  Map<String, dynamic> toImportData() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'ingredients': ingredients,
      'instructions': instructions,
      'sourceUrl': sourceUrl,
      'notes': notes,
      'courseId': suggestedCourse,
      'categoryId': suggestedCategory,
    };
  }
}

/// Main recipe parser class
class RecipeParser {
  static const _userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';

  // ========== SECTION HEADER PATTERNS ==========

  static final _ingredientHeaderPatterns = [
    RegExp(r'^#{1,6}\s*ingredients?\s*:?\s*$', caseSensitive: false, multiLine: true),
    RegExp(r'^\*{0,2}ingredients?\*{0,2}\s*:?\s*$', caseSensitive: false, multiLine: true),
    RegExp(r'^ingredients?\s*:?\s*$', caseSensitive: false, multiLine: true),
    RegExp("^what\\s+you'?ll?\\s+need\\s*:?\\s*\$", caseSensitive: false, multiLine: true),
    RegExp("^you'?ll?\\s+need\\s*:?\\s*\$", caseSensitive: false, multiLine: true),
    RegExp(r'^shopping\s+list\s*:?\s*$', caseSensitive: false, multiLine: true),
    RegExp(r'^for\s+the\s+\w+\s*:?\s*$', caseSensitive: false, multiLine: true),
  ];

  static final _instructionHeaderPatterns = [
    RegExp(r'^#{1,6}\s*(instructions?|directions?|method|steps?|preparation|how\s+to\s+make|procedure)\s*:?\s*$', caseSensitive: false, multiLine: true),
    RegExp(r'^\*{0,2}(instructions?|directions?|method|steps?)\*{0,2}\s*:?\s*$', caseSensitive: false, multiLine: true),
    RegExp(r'^(instructions?|directions?|method|steps?|preparation|how\s+to\s+make|to\s+make|procedure)\s*:?\s*$', caseSensitive: false, multiLine: true),
  ];

  static final _notesHeaderPatterns = [
    RegExp("^#{1,6}\\s*(notes?|tips?|variations?|chef'?s?\\s+notes?|cook'?s?\\s+notes?)\\s*:?\\s*\$", caseSensitive: false, multiLine: true),
    RegExp(r'^(notes?|tips?|variations?)\s*:?\s*$', caseSensitive: false, multiLine: true),
  ];

  // ========== MEASUREMENT UNITS ==========

  static final _measurementUnits = [
    'cup', 'cups', 'c',
    'tablespoon', 'tablespoons', 'tbsp', 'tbsps', 'tbs', 'tb', 'T',
    'teaspoon', 'teaspoons', 'tsp', 'tsps', 'ts', 't',
    'fluid ounce', 'fluid ounces', 'fl oz', 'fl. oz',
    'pint', 'pints', 'pt',
    'quart', 'quarts', 'qt',
    'gallon', 'gallons', 'gal',
    'milliliter', 'milliliters', 'ml', 'mL',
    'liter', 'liters', 'litre', 'litres', 'l', 'L',
    'deciliter', 'deciliters', 'dl', 'dL',
    'ounce', 'ounces', 'oz',
    'pound', 'pounds', 'lb', 'lbs',
    'gram', 'grams', 'g',
    'kilogram', 'kilograms', 'kg',
    'milligram', 'milligrams', 'mg',
    'pinch', 'pinches', 'dash', 'dashes',
    'clove', 'cloves', 'slice', 'slices',
    'piece', 'pieces', 'pc', 'pcs',
    'bunch', 'bunches', 'sprig', 'sprigs',
    'head', 'heads', 'stalk', 'stalks',
    'can', 'cans', 'package', 'packages', 'pkg', 'pkgs',
    'jar', 'jars', 'box', 'boxes',
    'bag', 'bags', 'bottle', 'bottles',
    'stick', 'sticks', 'cube', 'cubes',
    'drop', 'drops', 'handful', 'handfuls',
    'large', 'medium', 'small',
  ];

  static final _unicodeFractions = ['½', '¼', '¾', '⅓', '⅔', '⅛', '⅜', '⅝', '⅞', '⅕', '⅖', '⅗', '⅘', '⅙', '⅚'];

  // ========== PUBLIC METHODS ==========

  static Future<ParsedRecipe> parseFromUrl(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': _userAgent},
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch URL (${response.statusCode})');
      }

      final document = html_parser.parse(response.body);

      var recipe = _tryJsonLd(document);
      recipe ??= _tryMicrodata(document);
      recipe ??= _tryCommonSelectors(document);
      recipe ??= _tryGenericHtml(document);
      recipe ??= ParsedRecipe(title: 'Imported Recipe', ingredients: [], instructions: []);

      recipe.sourceUrl = url;
      recipe.imageUrl ??= _findBestImage(document);
      _detectCourseAndCategory(recipe);

      return recipe;
    } catch (e) {
      throw Exception('Failed to parse recipe: $e');
    }
  }

  static ParsedRecipe parseFromText(String text) {
    text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').replaceAll('\t', ' ');

    if (_looksLikeJson(text)) {
      final jsonResult = _tryParseJson(text);
      if (jsonResult != null) return jsonResult;
    }

    return _parseStructuredText(text);
  }

  static ParsedRecipe parseFromFile(String content, String filename) {
    final ext = filename.toLowerCase().split('.').last;

    switch (ext) {
      case 'json':
        return _tryParseJson(content) ??
            ParsedRecipe(title: 'Imported Recipe', ingredients: [], instructions: []);
      case 'md':
      case 'markdown':
        return _parseMarkdown(content);
      case 'txt':
      default:
        return parseFromText(content);
    }
  }

  // ========== TEXT PARSING ==========

  static ParsedRecipe _parseStructuredText(String text) {
    final lines = text.split('\n');

    String title = 'Untitled Recipe';
    String? description;
    String? servings;
    int? prepTime;
    int? cookTime;
    List<String> ingredients = [];
    List<String> instructions = [];
    List<String> notes = [];

    _Section currentSection = _Section.unknown;
    bool foundTitle = false;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      if (line.isEmpty) continue;
      if (RegExp(r'^[-=_]{3,}$').hasMatch(line)) continue;

      // Check for section headers FIRST
      final newSection = _detectSectionHeader(line);
      if (newSection != _Section.unknown) {
        currentSection = newSection;
        continue;
      }

      // Extract title
      if (!foundTitle) {
        final headerMatch = RegExp(r'^#{1,2}\s+(.+)$').firstMatch(line);
        if (headerMatch != null) {
          title = _cleanMarkdown(headerMatch.group(1)!);
          foundTitle = true;
          continue;
        }

        if (i < 5 && !_isListItem(line) && line.length > 3 && line.length < 150) {
          title = _cleanMarkdown(line);
          foundTitle = true;
          continue;
        }
      }

      // Extract metadata
      final metaResult = _extractMetadata(line);
      if (metaResult != null) {
        if (metaResult.servings != null) servings = metaResult.servings;
        if (metaResult.prepTime != null) prepTime = metaResult.prepTime;
        if (metaResult.cookTime != null) cookTime = metaResult.cookTime;
        continue;
      }

      String cleanedLine = _cleanListMarkers(line);
      cleanedLine = _cleanMarkdown(cleanedLine);

      if (cleanedLine.isEmpty) continue;

      // Route to appropriate section
      switch (currentSection) {
        case _Section.ingredients:
          ingredients.add(cleanedLine);
          break;
        case _Section.instructions:
          instructions.add(cleanedLine);
          break;
        case _Section.notes:
          notes.add(cleanedLine);
          break;
        case _Section.unknown:
          if (_looksLikeIngredient(cleanedLine)) {
            ingredients.add(cleanedLine);
          } else if (_looksLikeInstruction(cleanedLine)) {
            instructions.add(cleanedLine);
          } else if (description == null && cleanedLine.length > 20 && cleanedLine.length < 500) {
            description = cleanedLine;
          }
          break;
        default:
          break;
      }
    }

    // Aggressive fallback
    if (ingredients.isEmpty && instructions.isEmpty) {
      final aggressive = _aggressiveParse(text);
      ingredients = aggressive.ingredients;
      instructions = aggressive.instructions;
    }

    final recipe = ParsedRecipe(
      title: title,
      description: description,
      servings: servings,
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      ingredients: _cleanIngredients(ingredients),
      instructions: _cleanInstructions(instructions),
      notes: notes.isNotEmpty ? notes.join('\n') : null,
    );

    _detectCourseAndCategory(recipe);
    return recipe;
  }

  static ParsedRecipe _parseMarkdown(String text) {
    text = text.replaceAll(RegExp(r'^---[\s\S]*?---\n', multiLine: true), '');
    text = text.replaceAll(RegExp(r'~~~[\s\S]*?~~~', multiLine: true), '');
    return _parseStructuredText(text);
  }

  static ParsedRecipe _aggressiveParse(String text) {
    final lines = text.split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    List<String> ingredients = [];
    List<String> instructions = [];

    for (final line in lines) {
      final cleaned = _cleanListMarkers(_cleanMarkdown(line));
      if (cleaned.isEmpty || cleaned.length < 3) continue;

      final ingredientScore = _ingredientScore(cleaned);
      final instructionScore = _instructionScore(cleaned);

      if (ingredientScore > instructionScore && ingredientScore > 0.3) {
        if (_isValidIngredient(cleaned)) {
          ingredients.add(cleaned);
        }
      } else if (instructionScore > 0.3) {
        if (_isValidInstruction(cleaned)) {
          instructions.add(cleaned);
        }
      }
    }

    return ParsedRecipe(
      title: 'Imported Recipe',
      ingredients: ingredients,
      instructions: instructions,
    );
  }

  // ========== DETECTION HELPERS ==========

  static _Section _detectSectionHeader(String line) {
    final cleanLine = line.trim();

    for (final pattern in _ingredientHeaderPatterns) {
      if (pattern.hasMatch(cleanLine)) return _Section.ingredients;
    }

    for (final pattern in _instructionHeaderPatterns) {
      if (pattern.hasMatch(cleanLine)) return _Section.instructions;
    }

    for (final pattern in _notesHeaderPatterns) {
      if (pattern.hasMatch(cleanLine)) return _Section.notes;
    }

    return _Section.unknown;
  }

  static bool _isListItem(String line) {
    return RegExp(r'^[\-\*•◦▪]\s+').hasMatch(line) ||
        RegExp(r'^\d+[\.\)]\s+').hasMatch(line) ||
        RegExp(r'^\[\s?\]\s+').hasMatch(line);
  }

  static String _cleanListMarkers(String line) {
    return line
        .replaceFirst(RegExp(r'^[\-\*•◦▪]\s+'), '')
        .replaceFirst(RegExp(r'^\d+[\.\)]\s+'), '')
        .replaceFirst(RegExp(r'^\[\s?[xX]?\]\s*'), '')
        .trim();
  }

  static String _cleanMarkdown(String text) {
    return text
        .replaceAllMapped(RegExp(r'\*\*([^*]+)\*\*'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'\*([^*]+)\*'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'__([^_]+)__'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'_([^_]+)_'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'\[\[([^\]|]+)(?:\|[^\]]+)?\]\]'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m.group(1) ?? '')
        .trim();
  }

  /// Validate if a string is a real ingredient (not junk)
  static bool _isValidIngredient(String text) {
    // Too short
    if (text.length < 3) return false;

    // Just a number
    if (RegExp(r'^\d+$').hasMatch(text)) return false;

    // Just a single word that's likely junk
    final junkWords = [
      'medium', 'large', 'small', 'optional', 'fresh', 'dried',
      'chopped', 'minced', 'diced', 'sliced', 'cubed', 'grated',
      'to taste', 'as needed', 'for garnish', 'or more',
      'ingredients', 'directions', 'instructions', 'method', 'steps',
      'notes', 'tips', 'recipe', 'servings', 'serves', 'yield',
      'prep time', 'cook time', 'total time', 'nutrition',
    ];

    final lower = text.toLowerCase().trim();
    if (junkWords.contains(lower)) return false;

    // Single word under 4 characters (likely junk like "oz", "lb", numbers)
    if (!text.contains(' ') && text.length < 4) return false;

    // Contains only special characters or numbers
    if (RegExp(r'^[\d\s\.\,\-\/\(\)]+$').hasMatch(text)) return false;

    // Looks like a header or metadata
    if (text.endsWith(':')) return false;

    // Must contain at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(text)) return false;

    return true;
  }

  /// Validate if a string is a real instruction (not junk)
  static bool _isValidInstruction(String text) {
    // Too short
    if (text.length < 10) return false;

    // Just a number or very short
    if (RegExp(r'^\d+\.?$').hasMatch(text)) return false;

    // Header-like text
    final lower = text.toLowerCase().trim();
    final headerWords = [
      'ingredients', 'directions', 'instructions', 'method', 'steps',
      'notes', 'tips', 'recipe', 'servings', 'serves', 'yield',
      'prep time', 'cook time', 'total time', 'nutrition',
    ];
    if (headerWords.contains(lower)) return false;

    // Must contain at least a few words
    if (text.split(' ').length < 3) return false;

    return true;
  }

  /// Clean and validate ingredient list
  static List<String> _cleanIngredients(List<String> raw) {
    return raw
        .map((s) => s.trim())
        .where((s) => _isValidIngredient(s))
        .toList();
  }

  /// Clean and validate instruction list
  static List<String> _cleanInstructions(List<String> raw) {
    return raw
        .map((s) => s.trim())
        .where((s) => _isValidInstruction(s))
        .toList();
  }

  static bool _looksLikeIngredient(String text) {
    return _ingredientScore(text) > 0.4;
  }

  static double _ingredientScore(String text) {
    double score = 0;
    final lower = text.toLowerCase();

    if (text.length < 100) score += 0.1;
    if (text.length < 60) score += 0.1;
    if (text.length > 150) score -= 0.3;

    if (RegExp(r'^\d').hasMatch(text)) score += 0.3;
    if (_unicodeFractions.any((f) => text.startsWith(f))) score += 0.3;
    if (RegExp(r'^\d+/\d+').hasMatch(text)) score += 0.3;

    for (final unit in _measurementUnits) {
      if (RegExp('\\b$unit\\b', caseSensitive: false).hasMatch(lower)) {
        score += 0.3;
        break;
      }
    }

    if (_unicodeFractions.any((f) => text.contains(f))) score += 0.2;
    if (RegExp(r'\d+/\d+').hasMatch(text)) score += 0.2;
    if (!RegExp(r'\.\s+[A-Z]').hasMatch(text)) score += 0.1;
    if (!_containsActionVerb(text)) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  static bool _looksLikeInstruction(String text) {
    return _instructionScore(text) > 0.4;
  }

  static double _instructionScore(String text) {
    double score = 0;
    final lower = text.toLowerCase();

    if (text.length > 40) score += 0.2;
    if (text.length > 80) score += 0.1;
    if (text.length < 15) score -= 0.3;

    if (_containsActionVerb(text)) score += 0.4;
    if (_startsWithActionVerb(lower)) score += 0.3;

    if (RegExp(r'\d+\s*(minutes?|mins?|hours?|hrs?|seconds?|secs?)').hasMatch(lower)) {
      score += 0.2;
    }

    if (RegExp(r'\d+\s*°?\s*[FCfc]').hasMatch(text)) score += 0.2;
    if (text.endsWith('.')) score += 0.1;
    if (RegExp(r'[.;,]\s+[A-Z]').hasMatch(text)) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  static final _actionVerbs = [
    'add', 'adjust', 'bake', 'baste', 'beat', 'blend', 'boil', 'braise',
    'bread', 'bring', 'broil', 'brown', 'brush', 'carve', 'check', 'chill',
    'chop', 'coat', 'combine', 'cook', 'cool', 'cover', 'cream', 'crisp',
    'crush', 'cube', 'cut', 'dice', 'dip', 'divide', 'drain', 'drizzle',
    'drop', 'dry', 'dust', 'fillet', 'flip', 'fold', 'freeze', 'fry',
    'garnish', 'glaze', 'grate', 'grease', 'grill', 'grind', 'heat',
    'julienne', 'keep', 'knead', 'layer', 'let', 'line', 'make', 'marinate',
    'mash', 'measure', 'melt', 'mince', 'mix', 'moisten', 'oil', 'pack',
    'pat', 'peel', 'place', 'poach', 'pour', 'preheat', 'prepare', 'press',
    'process', 'puree', 'put', 'reduce', 'refrigerate', 'remove', 'rest',
    'return', 'rinse', 'rise', 'roast', 'roll', 'rub', 'saute', 'sauté',
    'scoop', 'scrape', 'sear', 'season', 'serve', 'set', 'shake', 'shape',
    'shred', 'simmer', 'skim', 'slice', 'soak', 'soften', 'spoon', 'spread',
    'sprinkle', 'squeeze', 'steam', 'steep', 'stir', 'strain', 'stuff',
    'taste', 'thaw', 'thread', 'toast', 'top', 'toss', 'transfer', 'trim',
    'turn', 'using', 'warm', 'wash', 'weigh', 'whip', 'whisk', 'wrap',
  ];

  static bool _containsActionVerb(String text) {
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    return words.any((word) => _actionVerbs.contains(word.replaceAll(RegExp(r'[^\w]'), '')));
  }

  static bool _startsWithActionVerb(String text) {
    final firstWord = text.split(RegExp(r'\s+'))[0].replaceAll(RegExp(r'[^\w]'), '');
    return _actionVerbs.contains(firstWord);
  }

  static _Metadata? _extractMetadata(String line) {
    final lower = line.toLowerCase();

    String? servings;
    int? prepTime;
    int? cookTime;

    final servingsMatch = RegExp(
        r'(?:serves?|servings?|yields?|makes?|portions?)\s*:?\s*(\d+(?:\s*-\s*\d+)?(?:\s*\w+)?)',
        caseSensitive: false
    ).firstMatch(line);
    if (servingsMatch != null) servings = servingsMatch.group(1);

    final prepMatch = RegExp(
        r'(?:prep(?:aration)?\s*(?:time)?)\s*:?\s*(\d+)\s*(minutes?|mins?|hours?|hrs?)',
        caseSensitive: false
    ).firstMatch(line);
    if (prepMatch != null) {
      final value = int.parse(prepMatch.group(1)!);
      final unit = prepMatch.group(2)!.toLowerCase();
      prepTime = unit.startsWith('h') ? value * 60 : value;
    }

    final cookMatch = RegExp(
        r'(?:cook(?:ing)?\s*(?:time)?)\s*:?\s*(\d+)\s*(minutes?|mins?|hours?|hrs?)',
        caseSensitive: false
    ).firstMatch(line);
    if (cookMatch != null) {
      final value = int.parse(cookMatch.group(1)!);
      final unit = cookMatch.group(2)!.toLowerCase();
      cookTime = unit.startsWith('h') ? value * 60 : value;
    }

    final totalMatch = RegExp(
        r'(?:total\s*(?:time)?|time)\s*:?\s*(\d+)\s*(minutes?|mins?|hours?|hrs?)',
        caseSensitive: false
    ).firstMatch(line);
    if (totalMatch != null && prepTime == null && cookTime == null) {
      final value = int.parse(totalMatch.group(1)!);
      final unit = totalMatch.group(2)!.toLowerCase();
      cookTime = unit.startsWith('h') ? value * 60 : value;
    }

    if (servings != null || prepTime != null || cookTime != null) {
      return _Metadata(servings: servings, prepTime: prepTime, cookTime: cookTime);
    }

    return null;
  }

  // ========== COURSE/CATEGORY DETECTION ==========

  static void _detectCourseAndCategory(ParsedRecipe recipe) {
    final allText = '${recipe.title} ${recipe.description ?? ''}'.toLowerCase();

    if (_matchesAny(allText, ['breakfast', 'brunch', 'morning', 'pancake', 'waffle', 'omelet', 'omelette', 'scramble', 'french toast'])) {
      recipe.suggestedCourse = 'breakfast';
    } else if (_matchesAny(allText, ['appetizer', 'starter', 'finger food', 'hors d\'oeuvre', 'dip', 'bruschetta'])) {
      recipe.suggestedCourse = 'appetizer';
    } else if (_matchesAny(allText, ['soup', 'stew', 'chowder', 'bisque', 'broth'])) {
      recipe.suggestedCourse = 'soup';
    } else if (_matchesAny(allText, ['salad', 'slaw', 'greens'])) {
      recipe.suggestedCourse = 'salad';
    } else if (_matchesAny(allText, ['dessert', 'cake', 'cookie', 'brownie', 'pie', 'tart', 'pudding', 'ice cream', 'sweet', 'chocolate'])) {
      recipe.suggestedCourse = 'dessert';
    } else if (_matchesAny(allText, ['side dish', 'side', 'vegetable', 'mashed', 'roasted'])) {
      recipe.suggestedCourse = 'side';
    } else if (_matchesAny(allText, ['drink', 'beverage', 'cocktail', 'smoothie', 'juice', 'lemonade', 'tea', 'coffee'])) {
      recipe.suggestedCourse = 'beverage';
    } else if (_matchesAny(allText, ['snack', 'chip', 'popcorn', 'trail mix'])) {
      recipe.suggestedCourse = 'snack';
    } else if (_matchesAny(allText, ['sauce', 'dressing', 'marinade', 'gravy', 'condiment'])) {
      recipe.suggestedCourse = 'sauce';
    } else if (_matchesAny(allText, ['bread', 'roll', 'biscuit', 'muffin', 'scone'])) {
      recipe.suggestedCourse = 'bread';
    } else {
      recipe.suggestedCourse = 'main';
    }

    if (_matchesAny(allText, ['vegetarian', 'veggie', 'meatless'])) {
      recipe.suggestedCategory = 'vegetarian';
    } else if (_matchesAny(allText, ['vegan', 'plant-based', 'plant based'])) {
      recipe.suggestedCategory = 'vegan';
    } else if (_matchesAny(allText, ['gluten-free', 'gluten free', 'gf'])) {
      recipe.suggestedCategory = 'gluten-free';
    } else if (_matchesAny(allText, ['quick', 'easy', '15 minute', '20 minute', '30 minute', 'weeknight', 'simple'])) {
      recipe.suggestedCategory = 'quick-easy';
    } else if (_matchesAny(allText, ['healthy', 'light', 'low-cal', 'nutritious'])) {
      recipe.suggestedCategory = 'healthy';
    } else if (_matchesAny(allText, ['comfort', 'classic', 'traditional', 'homestyle'])) {
      recipe.suggestedCategory = 'comfort-food';
    }
  }

  static bool _matchesAny(String text, List<String> patterns) {
    return patterns.any((p) => text.contains(p));
  }

  // ========== JSON PARSING ==========

  static bool _looksLikeJson(String text) {
    final trimmed = text.trim();
    return (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'));
  }

  static ParsedRecipe? _tryParseJson(String text) {
    try {
      final json = jsonDecode(text);
      if (json is Map) {
        return ParsedRecipe(
          title: json['title'] ?? json['name'] ?? 'Imported Recipe',
          description: json['description'],
          ingredients: _toStringList(json['ingredients'] ?? json['recipeIngredient'] ?? []),
          instructions: _toStringList(json['instructions'] ?? json['recipeInstructions'] ?? json['directions'] ?? json['steps'] ?? []),
          servings: json['servings']?.toString() ?? json['yield']?.toString(),
          prepTimeMinutes: _parseTimeValue(json['prepTime'] ?? json['prep_time']),
          cookTimeMinutes: _parseTimeValue(json['cookTime'] ?? json['cook_time']),
          imageUrl: json['image'] ?? json['imageUrl'],
          sourceUrl: json['url'] ?? json['sourceUrl'],
        );
      }
    } catch (e) {
      // Not valid JSON
    }
    return null;
  }

  static List<String> _toStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) {
        if (e is String) return e.trim();
        if (e is Map) return e['text']?.toString().trim() ?? e.toString();
        return e.toString().trim();
      }).where((s) => s.isNotEmpty).toList();
    }
    if (data is String) {
      return data.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    }
    return [];
  }

  static int? _parseTimeValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final isoMatch = RegExp(r'P(?:T)?(?:(\d+)H)?(?:(\d+)M)?').firstMatch(value);
      if (isoMatch != null) {
        final h = int.tryParse(isoMatch.group(1) ?? '0') ?? 0;
        final m = int.tryParse(isoMatch.group(2) ?? '0') ?? 0;
        if (h > 0 || m > 0) return h * 60 + m;
      }
      return int.tryParse(value);
    }
    return null;
  }

  // ========== HTML PARSING ==========

  static ParsedRecipe? _tryJsonLd(Document document) {
    final scripts = document.querySelectorAll('script[type="application/ld+json"]');

    for (final script in scripts) {
      try {
        final content = script.text.trim();
        if (content.isEmpty) continue;

        dynamic json = jsonDecode(content);

        if (json is Map && json.containsKey('@graph')) {
          json = (json['@graph'] as List).firstWhere(
                (item) => _isRecipeType(item['@type']),
            orElse: () => null,
          );
        } else if (json is List) {
          json = json.firstWhere(
                (item) => _isRecipeType(item['@type']),
            orElse: () => null,
          );
        }

        if (json == null || !_isRecipeType(json['@type'])) continue;

        return ParsedRecipe(
          title: _cleanHtmlText(json['name']?.toString()) ?? 'Imported Recipe',
          description: _cleanHtmlText(json['description']?.toString()),
          imageUrl: _extractImage(json['image']),
          ingredients: _toStringList(json['recipeIngredient']),
          instructions: _extractInstructions(json['recipeInstructions']),
          prepTimeMinutes: _parseTimeValue(json['prepTime']),
          cookTimeMinutes: _parseTimeValue(json['cookTime']),
          servings: _extractServings(json['recipeYield']),
        );
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  static bool _isRecipeType(dynamic type) {
    if (type == null) return false;
    return type.toString().toLowerCase().contains('recipe');
  }

  static ParsedRecipe? _tryMicrodata(Document document) {
    final root = document.querySelector('[itemtype*="schema.org/Recipe"]');
    if (root == null) return null;

    final ingredients = root.querySelectorAll('[itemprop="recipeIngredient"]')
        .map((e) => _cleanHtmlText(e.text) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    List<String> instructions = [];
    final instructionNodes = root.querySelectorAll('[itemprop="recipeInstructions"]');
    for (var node in instructionNodes) {
      final steps = node.querySelectorAll('[itemprop="text"]');
      if (steps.isNotEmpty) {
        instructions.addAll(steps.map((e) => _cleanHtmlText(e.text) ?? '').where((s) => s.isNotEmpty));
      } else {
        final text = _cleanHtmlText(node.text);
        if (text != null && text.isNotEmpty) instructions.add(text);
      }
    }

    if (ingredients.isEmpty && instructions.isEmpty) return null;

    return ParsedRecipe(
      title: root.querySelector('[itemprop="name"]')?.text.trim() ??
          document.querySelector('title')?.text.trim() ??
          'Imported Recipe',
      ingredients: ingredients,
      instructions: instructions,
    );
  }

  static ParsedRecipe? _tryCommonSelectors(Document document) {
    final selectors = [
      ('.wprm-recipe-ingredients li', '.wprm-recipe-instructions li'),
      ('.tasty-recipes-ingredients li', '.tasty-recipes-instructions li'),
      ('.recipe-ingredients li', '.recipe-instructions li'),
      ('.ingredients li', '.instructions li, .directions li'),
      ('ul[class*="ingredient"] li', 'ol[class*="instruction"] li'),
    ];

    for (final (ingSelector, instSelector) in selectors) {
      final ings = document.querySelectorAll(ingSelector)
          .map((e) => _cleanHtmlText(e.text) ?? '')
          .where((s) => s.isNotEmpty && s.length > 2)
          .toList();

      final insts = document.querySelectorAll(instSelector)
          .map((e) => _cleanHtmlText(e.text) ?? '')
          .where((s) => s.isNotEmpty && s.length > 5)
          .toList();

      if (ings.isNotEmpty || insts.isNotEmpty) {
        return ParsedRecipe(
          title: document.querySelector('h1')?.text.trim() ??
              document.querySelector('title')?.text.trim() ??
              'Imported Recipe',
          ingredients: ings,
          instructions: insts,
        );
      }
    }
    return null;
  }

  static ParsedRecipe? _tryGenericHtml(Document document) {
    final bodyText = document.body?.text ?? '';
    if (bodyText.length < 100) return null;
    return _parseStructuredText(bodyText);
  }

  static String? _cleanHtmlText(String? text) {
    if (text == null) return null;
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String? _extractImage(dynamic image) {
    if (image is String) return image;
    if (image is List && image.isNotEmpty) return _extractImage(image.first);
    if (image is Map) return image['url']?.toString();
    return null;
  }

  static List<String> _extractInstructions(dynamic data) {
    if (data == null) return [];
    List<String> results = [];

    void recurse(dynamic item) {
      if (item is String) {
        final cleaned = _cleanHtmlText(item);
        if (cleaned != null && cleaned.isNotEmpty) results.add(cleaned);
      } else if (item is Map) {
        if (item['text'] != null) {
          final text = _cleanHtmlText(item['text'].toString());
          if (text != null && text.isNotEmpty) results.add(text);
        } else if (item['itemListElement'] != null) {
          recurse(item['itemListElement']);
        }
      } else if (item is List) {
        for (var i in item) recurse(i);
      }
    }

    recurse(data);
    return results;
  }

  static String? _extractServings(dynamic data) {
    if (data == null) return null;
    if (data is int) return '$data servings';
    if (data is String) return data;
    if (data is List && data.isNotEmpty) return data.first.toString();
    return null;
  }

  static String? _findBestImage(Document document) {
    final ogImage = document.querySelector('meta[property="og:image"]')?.attributes['content'];
    if (ogImage != null && ogImage.isNotEmpty) return ogImage;

    for (final img in document.querySelectorAll('img[src]')) {
      final src = img.attributes['src'];
      final width = int.tryParse(img.attributes['width'] ?? '0') ?? 0;
      if (src != null && width > 300) return src;
    }

    return null;
  }
}

enum _Section { unknown, ingredients, instructions, notes, description }

class _Metadata {
  final String? servings;
  final int? prepTime;
  final int? cookTime;
  _Metadata({this.servings, this.prepTime, this.cookTime});
}