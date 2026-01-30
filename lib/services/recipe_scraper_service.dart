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
  });
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

  /// Parse raw text (Markdown, Obsidian, pasted text)
  ScrapedRecipe parseText(String text) {
    // 1. Clean Obsidian-specific junk (Metadata blocks ~~~ ... ~~~)
    String cleanText = text.replaceAll(RegExp(r'~~~[\s\S]*?~~~'), '').trim();

    // 2. Extract Title (First line or # Header)
    String title = 'Untitled Recipe';
    final lines = cleanText.split('\n');

    // Look for first H1 (# Title) or just first non-empty line
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      if (line.startsWith('# ')) {
        title = line.replaceAll('# ', '').trim();
        break;
      }
      // If we haven't found a # header in the first 5 lines, assume first line is title
      if (lines.indexOf(line) < 5) {
        title = line.trim();
        break;
      }
    }

    // 3. Extract Image (Markdown syntax ![[...]] or ![](...) )
    String? imageUrl;
    final obsidianImgMatch = RegExp(r'!\[\[(.*?)\]\]').firstMatch(cleanText);
    final standardImgMatch = RegExp(r'!\[.*?\]\((.*?)\)').firstMatch(cleanText);

    if (obsidianImgMatch != null) {
      imageUrl = obsidianImgMatch.group(1);
    } else if (standardImgMatch != null) {
      imageUrl = standardImgMatch.group(1);
    }

    // 4. Identify Sections (Ingredients vs Instructions)
    List<String> ingredients = [];
    List<String> instructions = [];

    // Split by common headers
    final sectionRegex = RegExp(
        r'(?:^|\n)(#{1,6}\s*|\*{2})?(Ingredients|Directions|Instructions|Method|Preparation|Steps)(?:\*{2})?[:\s]*',
        caseSensitive: false,
        multiLine: true
    );

    final matches = sectionRegex.allMatches(cleanText).toList();

    if (matches.isEmpty) {
      // Fallback: If no headers, try to auto-detect list items vs paragraphs
      instructions = _parseListItems(cleanText);
    } else {
      // We have sections
      for (int i = 0; i < matches.length; i++) {
        final match = matches[i];
        final sectionName = match.group(2)?.toLowerCase() ?? '';
        final start = match.end;
        final end = (i + 1 < matches.length) ? matches[i+1].start : cleanText.length;

        final content = cleanText.substring(start, end).trim();

        if (sectionName.contains('ingredient')) {
          ingredients.addAll(_parseListItems(content));
        } else {
          instructions.addAll(_parseListItems(content));
        }
      }
    }

    // Cleanup Markdown formatting
    ingredients = ingredients.map(_cleanMarkdown).toList();
    instructions = instructions.map(_cleanMarkdown).toList();

    return ScrapedRecipe(
      title: _cleanMarkdown(title),
      imageUrl: imageUrl,
      ingredients: ingredients,
      instructions: instructions,
    );
  }

  // ============ HELPERS ============

  String _cleanMarkdown(String text) {
    // Remove bold/italic (**text**, *text*)
    var s = text.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    s = s.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');

    // Remove WikiLinks [[Page Name]] -> Page Name
    s = s.replaceAll(RegExp(r'\[\[(.*?)\]\]'), r'$1');

    // Remove Markdown Links [Text](url) -> Text
    s = s.replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1');

    return s.trim();
  }

  List<String> _parseListItems(String content) {
    final List<String> items = [];
    final lines = content.split('\n');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('---')) continue; // Ignore horizontal rules

      // Strip bullet points (- , * , 1. )
      final cleanLine = line.replaceFirst(RegExp(r'^(\-|\*|\d+\.)\s+'), '');
      if (cleanLine.isNotEmpty) {
        items.add(cleanLine);
      }
    }
    return items;
  }

  // ============ WEB SCRAPING LOGIC ============

  ScrapedRecipe? _extractJsonLd(Document document) {
    final scripts = document.querySelectorAll('script[type="application/ld+json"]');

    for (final script in scripts) {
      try {
        final content = script.text;
        if (content.isEmpty) continue;
        dynamic json = jsonDecode(content);

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
    if (type is String) return type == 'Recipe';
    if (type is List) return type.contains('Recipe');
    return false;
  }

  ScrapedRecipe? _extractMicrodata(Document document) {
    final root = document.querySelector('[itemtype*="schema.org/Recipe"]');
    if (root == null) return null;

    // FIX: Use document.querySelector('title') instead of document.title
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
    // FIX: Use document.querySelector('title') instead of document.title
    final title = document.querySelector('h1')?.text.trim() ??
        document.querySelector('title')?.text.trim() ??
        'Untitled Recipe';

    final ingredientSelectors = [
      '.wprm-recipe-ingredients li',
      '.tasty-recipes-ingredients li',
      '.ingredients li',
      'ul[class*="ingredient"] li',
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
    ];

    List<String> instructions = [];
    for (var selector in instructionSelectors) {
      final elements = document.querySelectorAll(selector);
      if (elements.isNotEmpty) {
        instructions = elements.map((e) => e.text.trim()).toList();
        break;
      }
    }

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

  // ============ UTILS ============

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
        results.add(item.trim());
      } else if (item is Map) {
        if (item['@type'] == 'HowToStep' || item['type'] == 'HowToStep') {
          if (item['text'] != null) results.add(item['text'].toString().trim());
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
    if (image is Map) return image['url'];
    return null;
  }

  int? _parseDuration(String? duration) {
    if (duration == null) return null;
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