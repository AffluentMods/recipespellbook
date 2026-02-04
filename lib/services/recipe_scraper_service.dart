import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

class ScrapedRecipe {
  final String title;
  final String? description;
  final String? imageUrl;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? servings;
  final List<String> ingredients;
  final List<String> instructions;
  final String? sourceUrl;
  final List<String>? tags;
  final String? cuisine;
  final String? course;

  ScrapedRecipe({
    required this.title,
    this.description,
    this.imageUrl,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings,
    required this.ingredients,
    required this.instructions,
    this.sourceUrl,
    this.tags,
    this.cuisine,
    this.course,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'prepTime': prepTimeMinutes,
    'cookTime': cookTimeMinutes,
    'servings': servings?.toString(),
    'ingredients': ingredients,
    'instructions': instructions,
    'sourceUrl': sourceUrl,
    'tags': tags,
    'cuisine': cuisine,
    'course': course,
  };
}

class RecipeScraperService {
  static const _userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';

  // ============ PUBLIC METHODS ============

  /// Scrape from URL
  Future<ScrapedRecipe> scrapeRecipe(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch URL: ${response.statusCode}');
      }

      final document = html_parser.parse(response.body);

      // 1. JSON-LD (Best)
      final jsonLdRecipe = _extractJsonLd(document);
      if (jsonLdRecipe != null) return jsonLdRecipe;

      // 2. Microdata
      final microdataRecipe = _extractMicrodata(document);
      if (microdataRecipe != null) return microdataRecipe;

      // 3. Generic/Fallbacks
      return _extractGeneric(document, url);
    } catch (e) {
      throw Exception('Failed to scrape recipe: $e');
    }
  }

  /// Parse raw text - handles Markdown, Obsidian, plain text
  ScrapedRecipe parseText(String text) {
    // 1. Check if it's Obsidian/Markdown with YAML frontmatter
    if (text.trimLeft().startsWith('---')) {
      return _parseObsidianMarkdown(text);
    }

    // 2. Check if it's standard Markdown with headers
    if (text.contains(RegExp(r'^#{1,6}\s+', multiLine: true))) {
      return _parseMarkdown(text);
    }

    // 3. Plain text parsing
    return _parsePlainText(text);
  }

  /// Parse OCR text (from camera/gallery) - with smart cleanup
  ScrapedRecipe parseOcrText(String text) {
    // OCR text often has garbage at the start (status bar, time, etc.)
    final cleanedText = _cleanOcrText(text);
    return _parsePlainText(cleanedText);
  }

  // ============ OBSIDIAN/YAML FRONTMATTER PARSING ============

  ScrapedRecipe _parseObsidianMarkdown(String text) {
    String? title;
    String? description;
    String? imageUrl;
    int? prepTime;
    int? cookTime;
    int? servings;
    List<String>? tags;
    String? cuisine;
    String? course;
    List<String> ingredients = [];
    List<String> instructions = [];

    // Extract YAML frontmatter between --- markers
    final frontmatterMatch = RegExp(r'^---\s*\n([\s\S]*?)\n---', multiLine: true).firstMatch(text);
    String bodyText = text;

    if (frontmatterMatch != null) {
      final yaml = frontmatterMatch.group(1) ?? '';
      bodyText = text.substring(frontmatterMatch.end).trim();

      // Parse YAML fields line by line
      for (final line in yaml.split('\n')) {
        final colonIdx = line.indexOf(':');
        if (colonIdx == -1) continue;

        final key = line.substring(0, colonIdx).trim().toLowerCase();
        var value = line.substring(colonIdx + 1).trim();

        // Remove surrounding quotes
        if ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))) {
          value = value.substring(1, value.length - 1);
        }

        switch (key) {
          case 'title':
          case 'name':
            title = value;
            break;
          case 'description':
          case 'summary':
            description = value;
            break;
          case 'cover':
          case 'image':
          case 'photo':
            imageUrl = value;
            break;
          case 'prep time':
          case 'preptime':
          case 'prep':
            prepTime = _parseTimeString(value);
            break;
          case 'cook time':
          case 'cooktime':
          case 'cook':
            cookTime = _parseTimeString(value);
            break;
          case 'servings':
          case 'serves':
          case 'yield':
            servings = int.tryParse(value.replaceAll(RegExp(r'[^\d]'), ''));
            break;
          case 'tags':
          // Handle [tag1, tag2] or tag1, tag2 format
            if (value.startsWith('[') && value.endsWith(']')) {
              value = value.substring(1, value.length - 1);
            }
            tags = value.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
            break;
          case 'cuisine':
            cuisine = value;
            break;
          case 'type':
          case 'course':
          case 'category':
            course = value;
            break;
          case 'effort':
          // Could map to difficulty but not standard field
            break;
        }
      }
    }

    // Remove Obsidian-specific elements
    // Remove button blocks
    bodyText = bodyText.replaceAll(RegExp(r'```button[\s\S]*?```'), '');
    // Remove dataview blocks
    bodyText = bodyText.replaceAll(RegExp(r'```dataview[\s\S]*?```'), '');
    // Remove templater blocks
    bodyText = bodyText.replaceAll(RegExp(r'<%[\s\S]*?%>'), '');

    // Extract title from # Header if not in frontmatter
    if (title == null || title.isEmpty) {
      final h1Match = RegExp(r'^#\s+(.+)$', multiLine: true).firstMatch(bodyText);
      if (h1Match != null) {
        title = _cleanMarkdown(h1Match.group(1) ?? 'Untitled Recipe');
        // Remove the title line from body
        bodyText = bodyText.replaceFirst(h1Match.group(0)!, '').trim();
      }
    }

    // Extract image from Obsidian ![[...]] or standard ![](...) syntax
    if (imageUrl == null) {
      final obsidianImg = RegExp(r'!\[\[([^\]]+)\]\]').firstMatch(bodyText);
      final standardImg = RegExp(r'!\[[^\]]*\]\(([^)]+)\)').firstMatch(bodyText);
      imageUrl = obsidianImg?.group(1) ?? standardImg?.group(1);
    }

    // Extract description - first paragraph after title/image, before any ## header
    if (description == null || description.isEmpty) {
      // Remove image lines first
      final noImages = bodyText.replaceAll(RegExp(r'!\[.*?\][\[(].*?[\])]'), '');
      // Find first substantial paragraph before ## headers
      final descMatch = RegExp(r'^([^#\n][^\n]{20,})$', multiLine: true).firstMatch(noImages);
      if (descMatch != null) {
        description = _cleanMarkdown(descMatch.group(1)?.trim() ?? '');
      }
    }

    // Parse sections by ## headers
    final sections = _extractMarkdownSections(bodyText);
    ingredients = sections['ingredients'] ?? [];
    instructions = sections['instructions'] ?? [];

    // If no sections found, fall back to detecting lists
    if (ingredients.isEmpty && instructions.isEmpty) {
      final parsed = _parsePlainText(bodyText);
      ingredients = parsed.ingredients;
      instructions = parsed.instructions;
    }

    return ScrapedRecipe(
      title: title ?? 'Untitled Recipe',
      description: description,
      imageUrl: imageUrl,
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      servings: servings,
      ingredients: ingredients,
      instructions: instructions,
      tags: tags,
      cuisine: cuisine,
      course: course,
    );
  }

  // ============ STANDARD MARKDOWN PARSING ============

  ScrapedRecipe _parseMarkdown(String text) {
    String? title;
    String? description;
    String? imageUrl;
    List<String> ingredients = [];
    List<String> instructions = [];

    // Extract title from first H1
    final h1Match = RegExp(r'^#\s+(.+)$', multiLine: true).firstMatch(text);
    if (h1Match != null) {
      title = _cleanMarkdown(h1Match.group(1) ?? '');
    }

    // Extract image
    final imgMatch = RegExp(r'!\[[^\]]*\]\(([^)]+)\)').firstMatch(text);
    imageUrl = imgMatch?.group(1);

    // Parse sections
    final sections = _extractMarkdownSections(text);
    ingredients = sections['ingredients'] ?? [];
    instructions = sections['instructions'] ?? [];

    // If no sections found, try to detect lists
    if (ingredients.isEmpty && instructions.isEmpty) {
      final allLists = _extractAllLists(text);
      if (allLists.length >= 2) {
        ingredients = allLists[0];
        instructions = allLists[1];
      } else if (allLists.length == 1) {
        // Single list - try to split by content type
        final list = allLists[0];
        for (final item in list) {
          if (_looksLikeIngredient(item)) {
            ingredients.add(item);
          } else {
            instructions.add(item);
          }
        }
      }
    }

    return ScrapedRecipe(
      title: title ?? 'Untitled Recipe',
      description: description,
      imageUrl: imageUrl,
      ingredients: ingredients,
      instructions: instructions,
    );
  }

  /// Extract sections by ## headers
  Map<String, List<String>> _extractMarkdownSections(String text) {
    final Map<String, List<String>> sections = {
      'ingredients': [],
      'instructions': [],
      'notes': [],
    };

    // Find all ## or ### headers
    final headerPattern = RegExp(
      r'^#{1,3}\s+([^\n]+)',
      multiLine: true,
    );

    final matches = headerPattern.allMatches(text).toList();

    for (int i = 0; i < matches.length; i++) {
      final headerText = matches[i].group(1)?.toLowerCase().trim() ?? '';
      final start = matches[i].end;
      final end = (i + 1 < matches.length) ? matches[i + 1].start : text.length;
      final content = text.substring(start, end).trim();

      // Determine section type by header text
      String? sectionType;
      if (headerText.contains('ingredient')) {
        sectionType = 'ingredients';
      } else if (headerText.contains('direction') ||
          headerText.contains('instruction') ||
          headerText.contains('method') ||
          headerText.contains('step') ||
          headerText.contains('preparation')) {
        sectionType = 'instructions';
      } else if (headerText.contains('note') || headerText.contains('tip')) {
        sectionType = 'notes';
      }

      if (sectionType != null) {
        final items = _parseListItems(content);
        sections[sectionType]!.addAll(items.map(_cleanMarkdown));
      }
    }

    return sections;
  }

  // ============ PLAIN TEXT PARSING ============

  ScrapedRecipe _parsePlainText(String text) {
    String? title;
    List<String> ingredients = [];
    List<String> instructions = [];

    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    if (lines.isEmpty) {
      return ScrapedRecipe(title: 'Untitled Recipe', ingredients: [], instructions: []);
    }

    // First substantial non-header line is likely title
    for (final line in lines) {
      if (!_isHeader(line) && line.length > 3 && !_looksLikeIngredient(line)) {
        title = _cleanMarkdown(line);
        break;
      }
    }

    // Look for section keywords
    int ingredientStart = -1;
    int instructionStart = -1;

    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();
      if (_isIngredientHeader(lower) && ingredientStart == -1) {
        ingredientStart = i + 1;
      } else if (_isInstructionHeader(lower) && instructionStart == -1) {
        instructionStart = i + 1;
      }
    }

    // Extract sections based on detected headers
    if (ingredientStart != -1 && instructionStart != -1) {
      if (ingredientStart < instructionStart) {
        // Ingredients come first
        for (int i = ingredientStart; i < instructionStart - 1 && i < lines.length; i++) {
          final line = lines[i];
          if (!_isHeader(line) && (_looksLikeIngredient(line) || line.isNotEmpty)) {
            ingredients.add(_cleanListItem(line));
          }
        }
        for (int i = instructionStart; i < lines.length; i++) {
          final line = lines[i];
          if (!_isHeader(line) && line.isNotEmpty) {
            instructions.add(_cleanListItem(line));
          }
        }
      } else {
        // Instructions come first (unusual but handle it)
        for (int i = instructionStart; i < ingredientStart - 1 && i < lines.length; i++) {
          final line = lines[i];
          if (!_isHeader(line) && line.isNotEmpty) {
            instructions.add(_cleanListItem(line));
          }
        }
        for (int i = ingredientStart; i < lines.length; i++) {
          final line = lines[i];
          if (!_isHeader(line) && (_looksLikeIngredient(line) || line.isNotEmpty)) {
            ingredients.add(_cleanListItem(line));
          }
        }
      }
    } else {
      // No clear sections - auto-detect by content
      bool foundInstructions = false;
      for (final line in lines.skip(1)) { // Skip title
        if (_isHeader(line)) continue;

        if (_looksLikeIngredient(line) && !foundInstructions) {
          ingredients.add(_cleanListItem(line));
        } else if (_looksLikeInstruction(line) || foundInstructions) {
          foundInstructions = true;
          instructions.add(_cleanListItem(line));
        } else if (line.length < 60 && !line.contains('.')) {
          // Short lines without periods are likely ingredients
          ingredients.add(_cleanListItem(line));
        } else {
          foundInstructions = true;
          instructions.add(_cleanListItem(line));
        }
      }
    }

    return ScrapedRecipe(
      title: title ?? 'Untitled Recipe',
      ingredients: ingredients,
      instructions: instructions,
    );
  }

  // ============ OCR TEXT CLEANING ============

  String _cleanOcrText(String text) {
    var cleaned = text;
    final lines = cleaned.split('\n');
    final filteredLines = <String>[];

    for (var line in lines) {
      var trimmed = line.trim();

      // Skip empty or very short lines
      if (trimmed.length < 3) continue;

      // Skip phone status bar patterns
      // Time patterns: 1:24, 12:45 AM, etc at start of line
      if (RegExp(r'^\d{1,2}:\d{2}(\s*(AM|PM))?(\s|$)', caseSensitive: false).hasMatch(trimmed)) {
        continue;
      }

      // Skip signal/battery indicators
      if (RegExp(r'^5G|^LTE|^4G|^\d+%$').hasMatch(trimmed)) continue;

      // Skip lines that are just numbers or symbols
      if (RegExp(r'^[\d\W]+$').hasMatch(trimmed)) continue;

      // Skip "image not found" type messages
      if (trimmed.toLowerCase().contains('could not be found')) continue;
      if (trimmed.toLowerCase().contains('image not') && trimmed.toLowerCase().contains('found')) continue;

      // Skip breadcrumb-like paths (Recipes /... Recipe Name)
      if (RegExp(r'^[A-Za-z]+\s*/\.{3}').hasMatch(trimmed)) continue;

      // Remove leading garbage characters
      trimmed = trimmed.replaceFirst(RegExp(r'^[^\w\d]+'), '');

      if (trimmed.isNotEmpty) {
        filteredLines.add(trimmed);
      }
    }

    return filteredLines.join('\n');
  }

  // ============ HEADER DETECTION ============

  bool _isHeader(String line) {
    final lower = line.toLowerCase().trim();
    return _isIngredientHeader(lower) || _isInstructionHeader(lower) ||
        lower == 'notes' || lower == 'tips' || lower.startsWith('#');
  }

  bool _isIngredientHeader(String lower) {
    return lower == 'ingredients' ||
        lower == 'ingredients:' ||
        lower.startsWith('## ingredient') ||
        lower.startsWith('# ingredient');
  }

  bool _isInstructionHeader(String lower) {
    return lower == 'instructions' ||
        lower == 'directions' ||
        lower == 'method' ||
        lower == 'steps' ||
        lower == 'preparation' ||
        lower == 'instructions:' ||
        lower == 'directions:' ||
        lower.startsWith('## direction') ||
        lower.startsWith('## instruction') ||
        lower.startsWith('## method') ||
        lower.startsWith('## step') ||
        lower.startsWith('# direction') ||
        lower.startsWith('# instruction');
  }

  // ============ CONTENT TYPE DETECTION ============

  bool _looksLikeIngredient(String line) {
    final trimmed = line.trim();
    // Starts with number, fraction, or bullet
    if (RegExp(r'^[\d½⅓⅔¼¾⅛⅜⅝⅞/]').hasMatch(trimmed)) return true;
    // Has measurement unit
    if (RegExp(r'\b(cups?|tbsp|tsp|tablespoons?|teaspoons?|oz|ounces?|lb|lbs?|pounds?|g|grams?|kg|ml|l|liters?|cloves?|pinch|dash|bunch|can|package|pkg)\b', caseSensitive: false).hasMatch(trimmed)) {
      return true;
    }
    // Starts with bullet
    if (RegExp(r'^[-•*◦○●]\s').hasMatch(trimmed)) return true;
    return false;
  }

  bool _looksLikeInstruction(String line) {
    final trimmed = line.trim();
    // Starts with step number
    if (RegExp(r'^\d+[.)]\s').hasMatch(trimmed)) return true;
    // Starts with bold step header like "**Step 1:**" or "**Mix dough:**"
    if (RegExp(r'^\*\*[^*]+:\*\*').hasMatch(trimmed)) return true;
    // Starts with action verb
    final actionVerbs = [
      'add', 'mix', 'stir', 'cook', 'bake', 'heat', 'combine', 'pour', 'place',
      'set', 'let', 'remove', 'serve', 'preheat', 'bring', 'whisk', 'fold',
      'chop', 'dice', 'slice', 'cut', 'melt', 'saute', 'sauté', 'fry', 'boil',
      'simmer', 'roast', 'grill', 'season', 'sprinkle', 'cover', 'transfer',
      'reduce', 'gradually', 'slowly', 'carefully', 'gently', 'in a'
    ];
    final firstWord = trimmed.split(RegExp(r'[\s:]')).first.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
    if (actionVerbs.contains(firstWord)) return true;
    // Long line with period (likely a sentence)
    if (trimmed.length > 50 && trimmed.contains('.')) return true;
    return false;
  }

  // ============ CLEANING HELPERS ============

  String _cleanListItem(String line) {
    return line
        .replaceFirst(RegExp(r'^[-•*◦○●]\s*'), '')
        .replaceFirst(RegExp(r'^\d+[.)]\s*'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Clean markdown formatting - FIXED: use replaceAllMapped instead of r'$1'
  String _cleanMarkdown(String text) {
    var s = text;

    // Remove bold **text** -> text
    s = s.replaceAllMapped(RegExp(r'\*\*([^*]+)\*\*'), (m) => m.group(1) ?? '');

    // Remove italic *text* -> text
    s = s.replaceAllMapped(RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)'), (m) => m.group(1) ?? '');

    // Remove WikiLinks [[Page|Display]] -> Display, [[Page]] -> Page
    s = s.replaceAllMapped(RegExp(r'\[\[([^\]|]+)\|([^\]]+)\]\]'), (m) => m.group(2) ?? '');
    s = s.replaceAllMapped(RegExp(r'\[\[([^\]]+)\]\]'), (m) => m.group(1) ?? '');

    // Remove Markdown links [Text](url) -> Text
    s = s.replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m.group(1) ?? '');

    // Remove inline code `code` -> code
    s = s.replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m.group(1) ?? '');

    // Remove emoji at start (common in Obsidian titles like "🧈 Brioche")
    s = s.replaceFirst(RegExp(r'^[\p{Emoji}\s]+', unicode: true), '');

    // Remove image references
    s = s.replaceAll(RegExp(r'!\[.*?\][\[(].*?[\])]'), '');

    return s.trim();
  }

  List<String> _parseListItems(String content) {
    final List<String> items = [];
    final lines = content.split('\n');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('---')) continue; // Horizontal rule
      if (line.startsWith('#')) continue; // Header
      if (line.startsWith('!')) continue; // Image

      final cleanLine = _cleanListItem(line);
      if (cleanLine.isNotEmpty && cleanLine.length > 1) {
        items.add(cleanLine);
      }
    }
    return items;
  }

  List<List<String>> _extractAllLists(String text) {
    final lists = <List<String>>[];
    var currentList = <String>[];
    bool inList = false;

    for (final line in text.split('\n')) {
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        if (currentList.isNotEmpty) {
          lists.add(currentList);
          currentList = [];
          inList = false;
        }
        continue;
      }

      final isListItem = RegExp(r'^[-•*]\s|^\d+[.)]\s').hasMatch(trimmed);

      if (isListItem) {
        inList = true;
        currentList.add(_cleanListItem(trimmed));
      } else if (inList && !trimmed.startsWith('#')) {
        // Continuation of previous item or end of list
        if (currentList.isNotEmpty) {
          lists.add(currentList);
          currentList = [];
        }
        inList = false;
      }
    }

    if (currentList.isNotEmpty) {
      lists.add(currentList);
    }

    return lists;
  }

  int? _parseTimeString(String time) {
    int totalMinutes = 0;

    // Handle "1 hour 30 min", "1h 30m", "90 minutes", "30 min"
    final hourMatch = RegExp(r'(\d+)\s*(?:hours?|hr|h)\b', caseSensitive: false).firstMatch(time);
    if (hourMatch != null) {
      totalMinutes += (int.tryParse(hourMatch.group(1)!) ?? 0) * 60;
    }

    final minMatch = RegExp(r'(\d+)\s*(?:minutes?|mins?|m)\b', caseSensitive: false).firstMatch(time);
    if (minMatch != null) {
      totalMinutes += int.tryParse(minMatch.group(1)!) ?? 0;
    }

    // Just a number assumes minutes
    if (totalMinutes == 0) {
      final numMatch = RegExp(r'(\d+)').firstMatch(time);
      if (numMatch != null) {
        totalMinutes = int.tryParse(numMatch.group(1)!) ?? 0;
      }
    }

    return totalMinutes > 0 ? totalMinutes : null;
  }

  // ============ WEB SCRAPING LOGIC ============

  ScrapedRecipe? _extractJsonLd(Document document) {
    final scripts = document.querySelectorAll('script[type="application/ld+json"]');

    for (final script in scripts) {
      try {
        final content = script.text;
        if (content.isEmpty) continue;
        dynamic json = jsonDecode(content);

        // Handle @graph wrapper
        if (json is Map && json.containsKey('@graph')) {
          final graph = json['@graph'] as List;
          json = graph.firstWhere(
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

        return ScrapedRecipe(
          title: _cleanText(json['name']?.toString()) ?? 'Untitled Recipe',
          description: _cleanText(json['description']?.toString()),
          imageUrl: _extractImage(json['image']),
          ingredients: _parseList(json['recipeIngredient']),
          instructions: _parseJsonInstructions(json['recipeInstructions']),
          prepTimeMinutes: _parseDuration(json['prepTime']?.toString()),
          cookTimeMinutes: _parseDuration(json['cookTime']?.toString()),
          servings: _parseServings(json['recipeYield']),
        );
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  bool _isRecipeType(dynamic type) {
    if (type == null) return false;
    if (type is String) return type == 'Recipe' || type.contains('Recipe');
    if (type is List) return type.any((t) => t.toString().contains('Recipe'));
    return false;
  }

  ScrapedRecipe? _extractMicrodata(Document document) {
    final root = document.querySelector('[itemtype*="schema.org/Recipe"]');
    if (root == null) return null;

    final title = root.querySelector('[itemprop="name"]')?.text ??
        document.querySelector('title')?.text ??
        'Untitled Recipe';

    final ingredients = root.querySelectorAll('[itemprop="recipeIngredient"]')
        .map((e) => e.text.trim())
        .toList();

    final instructionNodes = root.querySelectorAll('[itemprop="recipeInstructions"]');
    List<String> instructions = [];
    if (instructionNodes.isNotEmpty) {
      for (var node in instructionNodes) {
        final steps = node.querySelectorAll('[itemprop="text"]');
        if (steps.isNotEmpty) {
          instructions.addAll(steps.map((e) => e.text.trim()));
        } else {
          instructions.add(node.text.trim());
        }
      }
    }

    return ScrapedRecipe(
      title: title.trim(),
      ingredients: ingredients,
      instructions: instructions,
    );
  }

  ScrapedRecipe _extractGeneric(Document document, String url) {
    final title = document.querySelector('h1')?.text.trim() ??
        document.querySelector('title')?.text.trim() ??
        'Untitled Recipe';

    final ingredientSelectors = [
      '.wprm-recipe-ingredients li',
      '.tasty-recipes-ingredients li',
      '.ingredients li',
      'ul[class*="ingredient"] li',
      '[class*="ingredient-list"] li',
    ];

    List<String> ingredients = [];
    for (var selector in ingredientSelectors) {
      final elements = document.querySelectorAll(selector);
      if (elements.isNotEmpty) {
        ingredients = elements.map((e) => e.text.trim()).toList();
        break;
      }
    }

    final instructionSelectors = [
      '.wprm-recipe-instructions li',
      '.tasty-recipes-instructions li',
      '.instructions li',
      '.directions li',
      'ol[class*="instruction"] li',
      '[class*="instruction-list"] li',
    ];

    List<String> instructions = [];
    for (var selector in instructionSelectors) {
      final elements = document.querySelectorAll(selector);
      if (elements.isNotEmpty) {
        instructions = elements.map((e) => e.text.trim()).toList();
        break;
      }
    }

    // Fallback to text parsing if no structured data found
    if (ingredients.isEmpty || instructions.isEmpty) {
      final bodyText = document.body?.text ?? '';
      final manualParse = parseText(bodyText);
      if (ingredients.isEmpty) ingredients = manualParse.ingredients;
      if (instructions.isEmpty) instructions = manualParse.instructions;
    }

    return ScrapedRecipe(
      title: title,
      ingredients: ingredients,
      instructions: instructions,
      sourceUrl: url,
    );
  }

  // ============ JSON UTILS ============

  String? _cleanText(String? text) {
    if (text == null) return null;
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  List<String> _parseList(dynamic list) {
    if (list == null) return [];
    if (list is List) return list.map((e) => e.toString().trim()).toList();
    if (list is String) return [list.trim()];
    return [];
  }

  List<String> _parseJsonInstructions(dynamic data) {
    if (data == null) return [];
    List<String> results = [];

    void recurse(dynamic item) {
      if (item is String) {
        final cleaned = item.trim();
        if (cleaned.isNotEmpty) results.add(cleaned);
      } else if (item is Map) {
        if (item['@type'] == 'HowToStep' || item['type'] == 'HowToStep') {
          if (item['text'] != null) results.add(item['text'].toString().trim());
        } else if (item['@type'] == 'HowToSection' || item['type'] == 'HowToSection') {
          if (item['itemListElement'] != null) recurse(item['itemListElement']);
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

  String? _extractImage(dynamic image) {
    if (image is String) return image;
    if (image is List && image.isNotEmpty) return _extractImage(image.first);
    if (image is Map) return image['url']?.toString();
    return null;
  }

  int? _parseDuration(String? duration) {
    if (duration == null) return null;
    // ISO 8601 duration: PT1H30M
    final regex = RegExp(r'P(?:T(?:(\d+)H)?(?:(\d+)M)?)?');
    final match = regex.firstMatch(duration);
    if (match != null) {
      final h = int.tryParse(match.group(1) ?? '0') ?? 0;
      final m = int.tryParse(match.group(2) ?? '0') ?? 0;
      if (h > 0 || m > 0) return h * 60 + m;
    }
    return null;
  }

  int? _parseServings(dynamic yieldData) {
    if (yieldData == null) return null;
    final str = yieldData.toString();
    final match = RegExp(r'(\d+)').firstMatch(str);
    return match != null ? int.parse(match.group(1)!) : null;
  }
}