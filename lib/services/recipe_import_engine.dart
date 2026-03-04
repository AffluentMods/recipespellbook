import 'dart:convert';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import '../models/imported_recipe.dart';

/// Consolidated recipe import engine.
/// Replaces both RecipeParser and RecipeScraperService.
///
/// Handles: URL scraping (JSON-LD, microdata, CSS selectors, generic HTML),
/// text parsing (structured, markdown, Obsidian/YAML frontmatter),
/// OCR text cleanup, file parsing (JSON, MD, TXT), and bulk HTML import.
class RecipeImportEngine {
  static const _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';

  // Platform-specific user agents (some sites block generic crawlers)
  static const _mobileUserAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';

  // ========== PLATFORM DETECTION ==========

  static _Platform _detectPlatform(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('instagram.com') || lower.contains('instagr.am')) return _Platform.instagram;
    if (lower.contains('tiktok.com') || lower.contains('vm.tiktok.com')) return _Platform.tiktok;
    if (lower.contains('pinterest.com') || lower.contains('pin.it')) return _Platform.pinterest;
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) return _Platform.youtube;
    if (lower.contains('squarespace.com') || lower.contains('.squarespace.')) return _Platform.squarespace;
    return _Platform.generic;
  }

  /// Normalize URL for better scraping (strip tracking, fix mobile URLs, etc.)
  static String _normalizeUrl(String url) {
    var normalized = url.trim();

    // Fix missing scheme
    if (!normalized.startsWith('http')) {
      normalized = 'https://$normalized';
    }

    // Instagram: convert /reel/ and /p/ share URLs to clean form
    if (normalized.contains('instagram.com')) {
      // Remove query params (tracking) but keep the path
      final uri = Uri.tryParse(normalized);
      if (uri != null) {
        normalized = '${uri.scheme}://${uri.host}${uri.path}';
        if (!normalized.endsWith('/')) normalized += '/';
      }
    }

    // TikTok: expand short URLs are handled by redirect following
    // Pinterest: pin.it redirects are handled by redirect following

    // Strip common tracking parameters
    final uri = Uri.tryParse(normalized);
    if (uri != null && uri.queryParameters.isNotEmpty) {
      final cleanParams = Map<String, String>.from(uri.queryParameters)
        ..removeWhere((k, _) => const {
          'utm_source', 'utm_medium', 'utm_campaign', 'utm_content',
          'utm_term', 'fbclid', 'gclid', 'ref', 'share_id',
          '_branch_match_id', 'feature', 'igshid', 'igsh',
        }.contains(k.toLowerCase()));
      if (cleanParams.isEmpty) {
        normalized = '${uri.scheme}://${uri.host}${uri.path}';
      } else {
        normalized = uri.replace(queryParameters: cleanParams).toString();
      }
    }

    return normalized;
  }

  /// Get appropriate headers for a given platform
  static Map<String, String> _headersForPlatform(_Platform platform) {
    switch (platform) {
      case _Platform.instagram:
      case _Platform.tiktok:
      // Social media often serves better meta tags to mobile user agents
        return {
          'User-Agent': _mobileUserAgent,
          'Accept': 'text/html,application/xhtml+xml',
          'Accept-Language': 'en-US,en;q=0.9',
        };
      case _Platform.pinterest:
      // Pinterest also serves better content to mobile UAs
        return {
          'User-Agent': _mobileUserAgent,
          'Accept': 'text/html,application/xhtml+xml',
          'Accept-Language': 'en-US,en;q=0.9',
        };
      default:
        return {'User-Agent': _userAgent};
    }
  }

  // ========== SECTION HEADER PATTERNS ==========

  static final _ingredientHeaderPatterns = [
    RegExp(r'^#{1,6}\s*ingredients?\s*:?\s*$',
        caseSensitive: false, multiLine: true),
    RegExp(r'^\*{0,2}ingredients?\*{0,2}\s*:?\s*$',
        caseSensitive: false, multiLine: true),
    RegExp(r'^ingredients?\s*:?\s*$',
        caseSensitive: false, multiLine: true),
    RegExp("^what\\s+you'?ll?\\s+need\\s*:?\\s*\$",
        caseSensitive: false, multiLine: true),
    RegExp("^you'?ll?\\s+need\\s*:?\\s*\$",
        caseSensitive: false, multiLine: true),
    RegExp(r'^shopping\s+list\s*:?\s*$',
        caseSensitive: false, multiLine: true),
    RegExp(r'^for\s+the\s+\w+\s*:?\s*$',
        caseSensitive: false, multiLine: true),
  ];

  static final _instructionHeaderPatterns = [
    RegExp(
        r'^#{1,6}\s*(instructions?|directions?|method|steps?|preparation|how\s+to\s+make|procedure)\s*:?\s*$',
        caseSensitive: false,
        multiLine: true),
    RegExp(
        r'^\*{0,2}(instructions?|directions?|method|steps?)\*{0,2}\s*:?\s*$',
        caseSensitive: false,
        multiLine: true),
    RegExp(
        r'^(instructions?|directions?|method|steps?|preparation|how\s+to\s+make|to\s+make|procedure)\s*:?\s*$',
        caseSensitive: false,
        multiLine: true),
  ];

  static final _notesHeaderPatterns = [
    RegExp(
        "^#{1,6}\\s*(notes?|tips?|variations?|chef'?s?\\s+notes?|cook'?s?\\s+notes?)\\s*:?\\s*\$",
        caseSensitive: false,
        multiLine: true),
    RegExp(r'^(notes?|tips?|variations?)\s*:?\s*$',
        caseSensitive: false, multiLine: true),
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

  static final _unicodeFractions = [
    '½', '¼', '¾', '⅓', '⅔', '⅛', '⅜', '⅝', '⅞', '⅕', '⅖', '⅗', '⅘',
    '⅙', '⅚',
  ];

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

  // ========== SHORT URL / OEMBED HELPERS ==========

  /// Whether a URL is a known short-link that needs redirect resolution.
  static bool _isShortUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('vm.tiktok.com') ||
        lower.contains('vt.tiktok.com') ||
        lower.contains('pin.it') ||
        lower.contains('bit.ly') ||
        lower.contains('tinyurl.com');
  }

  /// Resolve a short URL to its final destination by following redirects.
  /// Uses a HEAD request with manual redirect handling to avoid downloading
  /// full JS-rendered pages.
  static Future<String?> _resolveShortUrl(String url) async {
    try {
      final client = http.Client();
      try {
        var currentUrl = url;
        for (var i = 0; i < 10; i++) {
          final request = http.Request('GET', Uri.parse(currentUrl))
            ..followRedirects = false
            ..headers.addAll({
              'User-Agent': _mobileUserAgent,
              'Accept': 'text/html',
            });
          final streamed = await client.send(request).timeout(const Duration(seconds: 10));
          // Drain the response body to free resources
          await streamed.stream.drain();

          if (streamed.statusCode >= 300 && streamed.statusCode < 400) {
            final location = streamed.headers['location'];
            if (location == null) break;
            // Handle relative redirects
            currentUrl = Uri.parse(currentUrl).resolve(location).toString();
          } else {
            // Got a non-redirect response — this is the final URL
            return currentUrl;
          }
        }
        return currentUrl;
      } finally {
        client.close();
      }
    } catch (e) {
      return null;
    }
  }

  /// Try oEmbed API for platforms that support it.
  /// Returns a recipe parsed from oEmbed data, or null.
  static Future<ImportedRecipe?> _tryOEmbed(String url, _Platform platform) async {
    try {
      String oembedUrl;
      switch (platform) {
        case _Platform.tiktok:
          oembedUrl = 'https://www.tiktok.com/oembed?url=${Uri.encodeComponent(url)}';
          break;
        case _Platform.pinterest:
          oembedUrl = 'https://www.pinterest.com/oembed.json?url=${Uri.encodeComponent(url)}';
          break;
        default:
          return null;
      }

      final response = await http.get(
        Uri.parse(oembedUrl),
        headers: {'User-Agent': _userAgent, 'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final thumbnail = json['thumbnail_url']?.toString();

      if (platform == _Platform.tiktok) {
        return _parseTiktokOEmbed(json, url, thumbnail);
      } else if (platform == _Platform.pinterest) {
        return _parsePinterestOEmbed(json, url, thumbnail);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Parse TikTok oEmbed response.
  /// The `title` field contains the full video caption (which has the recipe).
  static ImportedRecipe? _parseTiktokOEmbed(
      Map<String, dynamic> json, String url, String? thumbnail) {
    final caption = json['title']?.toString();
    if (caption == null || caption.length < 30) return null;

    final authorName = json['author_name']?.toString() ?? '';

    // Try structured text parsing on the caption
    final parsed = _parseStructuredText(caption);
    if (parsed.ingredients.isNotEmpty || parsed.instructions.isNotEmpty) {
      // Clean up the title (caption's first line or author-based)
      final cleanTitle = _extractSocialTitle(caption)
          ?? _cleanSocialTitle(parsed.title.isNotEmpty ? parsed.title : 'TikTok Recipe');
      parsed.title = cleanTitle;
      parsed.imageUrl = thumbnail;
      parsed.sourceUrl = url;
      return parsed;
    }

    // Fall back to social caption parser
    final title = json['author_name'] != null
        ? '${json['author_name']}\'s Recipe'
        : 'TikTok Recipe';
    final result = _parseSocialCaption(caption, title, thumbnail);
    if (result != null) {
      result.sourceUrl = url;
      return result;
    }

    // Last resort: return the caption as a single-instruction recipe
    // so the user can at least see the text and use Smart Import
    return ImportedRecipe(
      title: _cleanSocialTitle(authorName.isNotEmpty ? '$authorName\'s Recipe' : 'TikTok Recipe'),
      ingredients: [],
      instructions: [caption],
      imageUrl: thumbnail,
      sourceUrl: url,
    );
  }

  /// Parse Pinterest oEmbed response.
  /// May contain a description with recipe text, plus a link to the original source.
  static ImportedRecipe? _parsePinterestOEmbed(
      Map<String, dynamic> json, String url, String? thumbnail) {
    final title = json['title']?.toString() ?? 'Pinterest Recipe';
    final description = json['description']?.toString();

    // Pinterest oEmbed sometimes includes the original source URL in the description
    // or we can try to extract it from the pin page later
    String? originalSourceUrl;
    if (description != null) {
      final urlMatch = RegExp(r'https?://[^\s<>"{}|\\^`\[\]]+', caseSensitive: false)
          .firstMatch(description);
      if (urlMatch != null) {
        final found = urlMatch.group(0)!;
        // Only follow if it's not a Pinterest URL (avoid loops)
        if (!found.contains('pinterest.com') && !found.contains('pin.it')) {
          originalSourceUrl = found;
        }
      }
    }

    if (description != null && description.length > 50) {
      final parsed = _parseStructuredText(description);
      if (parsed.ingredients.isNotEmpty || parsed.instructions.isNotEmpty) {
        parsed.title = _cleanSocialTitle(title);
        parsed.imageUrl = thumbnail;
        parsed.sourceUrl = url;
        return parsed;
      }

      final result = _parseSocialCaption(description, title, thumbnail);
      if (result != null) {
        result.sourceUrl = url;
        return result;
      }
    }

    // Return a minimal recipe with the original source URL if found
    // The caller can try to follow the source URL for better data
    return ImportedRecipe(
      title: _cleanSocialTitle(title),
      description: description,
      ingredients: [],
      instructions: [],
      imageUrl: thumbnail,
      sourceUrl: originalSourceUrl ?? url,
    );
  }

  /// Try to extract the original recipe source URL from a Pinterest pin page.
  /// Pinterest pins often link to the original recipe blog/website.
  static String? _extractPinterestSourceUrl(Document document) {
    // Look for the "Visit" or source link
    for (final selector in [
      'a[data-test-id="pin-action-link"]',
      'a[rel="nofollow noopener"][target="_blank"]',
      'a.linkModuleActionButton',
    ]) {
      final el = document.querySelector(selector);
      final href = el?.attributes['href'];
      if (href != null && !href.contains('pinterest.com')) {
        // Pinterest often wraps URLs in a redirect: /redirect/?url=...
        if (href.contains('/redirect/') && href.contains('url=')) {
          final uri = Uri.tryParse(href);
          final redirectUrl = uri?.queryParameters['url'];
          if (redirectUrl != null) return Uri.decodeComponent(redirectUrl);
        }
        return href;
      }
    }
    return null;
  }

  // ========== PUBLIC API ==========

  /// Scrape a recipe from a URL. Tries oEmbed → JSON-LD → microdata → CSS selectors → platform-specific → generic HTML.
  static Future<ImportedRecipe> parseFromUrl(String url, {bool isRecursiveCall = false}) async {
    return Future(() async {
      return _parseFromUrlInternal(url, isRecursiveCall: isRecursiveCall);
    }).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Import timed out — the website took too long to respond.'),
    );
  }

  static Future<ImportedRecipe> _parseFromUrlInternal(String url, {bool isRecursiveCall = false}) async {
    try {
      var normalized = _normalizeUrl(url);
      var platform = _detectPlatform(normalized);

      // 1. Resolve short URLs to their final destination
      if (_isShortUrl(normalized)) {
        final resolved = await _resolveShortUrl(normalized);
        if (resolved != null && resolved != normalized) {
          normalized = _normalizeUrl(resolved);
          platform = _detectPlatform(normalized);
        }
      }

      // 2. Try oEmbed for social platforms (works even when HTML scraping fails)
      if (platform == _Platform.tiktok || platform == _Platform.pinterest) {
        final oembedRecipe = await _tryOEmbed(normalized, platform);
        if (oembedRecipe != null) {
          // Pinterest: if we found an original source URL, try scraping that for a real recipe
          if (platform == _Platform.pinterest && !isRecursiveCall) {
            final sourceUrl = oembedRecipe.sourceUrl;
            if (sourceUrl != null &&
                !sourceUrl.contains('pinterest.com') &&
                !sourceUrl.contains('pin.it')) {
              try {
                final sourceRecipe = await parseFromUrl(sourceUrl, isRecursiveCall: true);
                if (sourceRecipe.ingredients.isNotEmpty) {
                  // Use the full recipe from the source, but keep Pinterest image as fallback
                  sourceRecipe.imageUrl ??= oembedRecipe.imageUrl;
                  sourceRecipe.sourceUrl = normalized; // Keep Pinterest as the share source
                  _detectCourseAndCategory(sourceRecipe);
                  return sourceRecipe;
                }
              } catch (_) {
                // Source scrape failed — use oEmbed data
              }
            }
          }

          // For TikTok or Pinterest without a followable source: use oEmbed data directly
          if (oembedRecipe.ingredients.isNotEmpty || oembedRecipe.instructions.isNotEmpty) {
            oembedRecipe.sourceUrl = normalized;
            _detectCourseAndCategory(oembedRecipe);
            return oembedRecipe;
          }
          // oEmbed returned a shell (title + image only) — fall through to try HTML scraping,
          // but remember the image/title for later
        }
      }

      // 3. Standard HTML scraping pipeline
      final headers = _headersForPlatform(platform);
      final response = await http
          .get(Uri.parse(normalized), headers: headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch URL (${response.statusCode})');
      }

      final document = html_parser.parse(response.body);

      // Standard extraction pipeline
      var recipe = _tryJsonLd(document);
      recipe ??= _tryMicrodata(document);
      recipe ??= _tryCommonSelectors(document);

      // Platform-specific fallbacks (social media extracts from meta tags)
      if (recipe == null || (recipe.ingredients.isEmpty && recipe.instructions.isEmpty)) {
        recipe = _tryPlatformSpecific(document, platform) ?? recipe;
      }

      // Pinterest HTML fallback: try to find and follow the original recipe URL
      if (platform == _Platform.pinterest && !isRecursiveCall &&
          (recipe == null || recipe.ingredients.isEmpty)) {
        final sourceUrl = _extractPinterestSourceUrl(document);
        if (sourceUrl != null) {
          try {
            final sourceRecipe = await parseFromUrl(sourceUrl, isRecursiveCall: true);
            if (sourceRecipe.ingredients.isNotEmpty) {
              sourceRecipe.imageUrl ??= _findBestImage(document);
              sourceRecipe.sourceUrl = normalized;
              _detectCourseAndCategory(sourceRecipe);
              return sourceRecipe;
            }
          } catch (_) {}
        }
      }

      recipe ??= _tryGenericHtml(document);
      recipe ??= ImportedRecipe(
          title: 'Imported Recipe', ingredients: [], instructions: []);

      recipe.sourceUrl = normalized;
      recipe.imageUrl ??= _findBestImage(document);
      _detectCourseAndCategory(recipe);

      return recipe;
    } catch (e) {
      throw Exception('Failed to parse recipe: $e');
    }
  }

  /// Parse recipe from plain text, markdown, or JSON string.
  static ImportedRecipe parseFromText(String text) {
    text = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\t', ' ');

    // JSON string
    if (_looksLikeJson(text)) {
      final jsonResult = _tryParseJson(text);
      if (jsonResult != null) return jsonResult;
    }

    // Obsidian/YAML frontmatter
    if (text.trimLeft().startsWith('---')) {
      return _parseObsidianMarkdown(text);
    }

    return _parseStructuredText(text);
  }

  /// Parse from a file's content, using filename extension for format hints.
  static ImportedRecipe parseFromFile(String content, String filename) {
    final ext = filename.toLowerCase().split('.').last;

    switch (ext) {
      case 'json':
      // Try app-specific JSON formats first, then generic
        return _tryAppJson(content)
            ?? _tryParseJson(content)
            ?? ImportedRecipe(title: 'Imported Recipe', ingredients: [], instructions: []);
      case 'md':
      case 'markdown':
        return _parseMarkdown(content);
      case 'mmf':
      case 'mk':
      // MealMaster format — return first recipe found
        final recipes = _parseMealMaster(content);
        return recipes.isNotEmpty
            ? recipes.first
            : ImportedRecipe(title: 'Imported Recipe', ingredients: [], instructions: []);
      case 'txt':
      default:
      // Try MealMaster detection on .txt files too
        if (_looksLikeMealMaster(content)) {
          final recipes = _parseMealMaster(content);
          if (recipes.isNotEmpty) return recipes.first;
        }
        return parseFromText(content);
    }
  }

  /// Parse a file that may contain MULTIPLE recipes (MealMaster, RecipeKeeper HTML, etc.)
  /// Returns all found recipes. Used by bulk import flow.
  static List<ImportedRecipe> parseFromFileBulk(String content, String filename) {
    final ext = filename.toLowerCase().split('.').last;

    switch (ext) {
      case 'json':
      // JSON arrays can contain multiple recipes
        final appRecipes = _tryAppJsonBulk(content);
        if (appRecipes.isNotEmpty) return appRecipes;
        final single = _tryParseJson(content);
        return single != null ? [single] : [];
      case 'html':
      case 'htm':
        return parseFromHtml(content);
      case 'mmf':
      case 'mk':
        return _parseMealMaster(content);
      case 'txt':
        if (_looksLikeMealMaster(content)) return _parseMealMaster(content);
        final recipe = parseFromText(content);
        return (recipe.ingredients.isNotEmpty || recipe.instructions.isNotEmpty) ? [recipe] : [];
      default:
        final recipe = parseFromFile(content, filename);
        return (recipe.ingredients.isNotEmpty || recipe.instructions.isNotEmpty) ? [recipe] : [];
    }
  }

  /// Parse OCR text with extra cleanup for camera/scan artifacts.
  /// Returns recipe with confidence scoring for quality assessment.
  static ImportedRecipe parseOcrText(String text) {
    final cleaned = _cleanOcrText(text);
    final recipe = _parseStructuredText(cleaned);

    // Score parse confidence
    final confidence = _scoreParseConfidence(recipe, cleaned);
    recipe.parseConfidence = confidence;
    recipe.rawOcrText = text; // Keep original for Smart Import fallback

    return recipe;
  }

  /// Score parse confidence from 0.0 to 1.0 based on quality signals.
  static double _scoreParseConfidence(ImportedRecipe recipe, String cleanedText) {
    double score = 0.0;

    // Section headers found (+0.15) — means the text has clear structure
    final hasIngredientHeader = RegExp(
      r'(ingredients?|what you.?ll need)',
      caseSensitive: false,
    ).hasMatch(cleanedText);
    final hasInstructionHeader = RegExp(
      r'(instructions?|directions?|method|steps?|preparation|how to make)',
      caseSensitive: false,
    ).hasMatch(cleanedText);
    if (hasIngredientHeader) score += 0.1;
    if (hasInstructionHeader) score += 0.1;

    // Title identified vs defaulted (+0.1)
    if (recipe.title != 'Untitled Recipe' &&
        recipe.title != 'Imported Recipe' &&
        recipe.title.isNotEmpty) {
      score += 0.1;
    }

    // Ingredients have measurements (+0.2)
    if (recipe.ingredients.isNotEmpty) {
      final withMeasurement = recipe.ingredients.where((ing) {
        return RegExp(r'\d').hasMatch(ing) ||
               RegExp(r'[½¼¾⅓⅔⅛⅜⅝⅞]').hasMatch(ing);
      }).length;
      final measureRatio = withMeasurement / recipe.ingredients.length;
      score += 0.2 * measureRatio;
    }

    // Ratio of classified vs unclassified lines (+0.25)
    final totalLines = cleanedText.split('\n').where((l) => l.trim().isNotEmpty).length;
    final classifiedLines = recipe.ingredients.length + recipe.instructions.length;
    if (totalLines > 0) {
      final classifyRatio = (classifiedLines / totalLines).clamp(0.0, 1.0);
      score += 0.25 * classifyRatio;
    }

    // Reasonable ingredient count 2-50 (+0.15)
    if (recipe.ingredients.length >= 2 && recipe.ingredients.length <= 50) {
      score += 0.15;
    }

    // Has at least one instruction (+0.1)
    if (recipe.instructions.isNotEmpty) {
      score += 0.1;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Parse HTML content and return ALL recipes found (for bulk import).
  /// Tries app-specific formats → JSON-LD → microdata → CSS selectors.
  static List<ImportedRecipe> parseFromHtml(String html) {
    final document = html_parser.parse(html);
    final recipes = <ImportedRecipe>[];

    // 0. Try app-specific HTML formats (RecipeKeeper, CopyMeThat, etc.)
    final appRecipes = _tryAppSpecificHtml(document, html);
    if (appRecipes.isNotEmpty) return appRecipes;

    // 1. Try JSON-LD (can contain multiple recipes)
    final scripts =
    document.querySelectorAll('script[type="application/ld+json"]');
    for (final script in scripts) {
      try {
        dynamic json = jsonDecode(script.text.trim());

        List<dynamic> items;
        if (json is List) {
          items = json;
        } else if (json is Map && json['@graph'] is List) {
          items = json['@graph'] as List;
        } else {
          items = [json];
        }

        for (final item in items) {
          if (item is Map && _isRecipeType(item['@type'])) {
            recipes.add(_recipeFromJsonLd(Map<String, dynamic>.from(item)));
          }
        }
      } catch (_) {}
    }

    if (recipes.isNotEmpty) return recipes;

    // 2. Try single extraction (microdata, selectors)
    final single = _tryMicrodata(document) ?? _tryCommonSelectors(document);
    if (single != null) return [single];

    return recipes;
  }

  // ========== WEB SCRAPING ==========

  static ImportedRecipe? _tryJsonLd(Document document) {
    final scripts =
    document.querySelectorAll('script[type="application/ld+json"]');

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

        return _recipeFromJsonLd(json as Map<String, dynamic>);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  static ImportedRecipe _recipeFromJsonLd(Map<String, dynamic> json) {
    // Extract author
    String? author;
    final authorData = json['author'];
    if (authorData is String) {
      author = authorData;
    } else if (authorData is Map) {
      author = authorData['name']?.toString();
    } else if (authorData is List && authorData.isNotEmpty) {
      final first = authorData.first;
      author = first is Map ? first['name']?.toString() : first?.toString();
    }

    // Extract nutrition notes
    String? nutritionNotes;
    final nutrition = json['nutrition'];
    if (nutrition is Map) {
      final parts = <String>[];
      if (nutrition['calories'] != null) parts.add('Calories: ${nutrition['calories']}');
      if (nutrition['proteinContent'] != null) parts.add('Protein: ${nutrition['proteinContent']}');
      if (nutrition['carbohydrateContent'] != null) parts.add('Carbs: ${nutrition['carbohydrateContent']}');
      if (nutrition['fatContent'] != null) parts.add('Fat: ${nutrition['fatContent']}');
      if (nutrition['fiberContent'] != null) parts.add('Fiber: ${nutrition['fiberContent']}');
      if (parts.isNotEmpty) nutritionNotes = parts.join(' | ');
    }

    // Build notes from author + nutrition
    final notesParts = <String>[];
    if (author != null && author.isNotEmpty) notesParts.add('By $author');
    if (nutritionNotes != null) notesParts.add('Nutrition: $nutritionNotes');

    // Extract tags from keywords + recipeCategory
    final tags = <String>[];
    if (json['recipeCategory'] is List) {
      tags.addAll(List<String>.from(json['recipeCategory']));
    } else if (json['recipeCategory'] != null) {
      tags.add(json['recipeCategory'].toString());
    }
    if (json['keywords'] is String) {
      tags.addAll((json['keywords'] as String)
          .split(',')
          .map((k) => k.trim())
          .where((k) => k.isNotEmpty && k.length < 40));
    } else if (json['keywords'] is List) {
      tags.addAll(List<String>.from(json['keywords']));
    }

    return ImportedRecipe(
      title: _cleanHtmlText(json['name']?.toString()) ?? 'Imported Recipe',
      description: _cleanHtmlText(json['description']?.toString()),
      imageUrl: _extractImage(json['image']),
      ingredients: _toStringList(json['recipeIngredient']),
      instructions: _extractJsonInstructions(json['recipeInstructions']),
      prepTimeMinutes: _parseTimeValue(json['prepTime']),
      cookTimeMinutes: _parseTimeValue(json['cookTime']),
      servings: _extractServings(json['recipeYield']),
      cuisine: json['recipeCuisine']?.toString(),
      tags: tags.isNotEmpty ? tags.toSet().toList() : null,
      notes: notesParts.isNotEmpty ? notesParts.join('\n') : null,
    );
  }

  static bool _isRecipeType(dynamic type) {
    if (type == null) return false;
    return type.toString().toLowerCase().contains('recipe');
  }

  static ImportedRecipe? _tryMicrodata(Document document) {
    final root = document.querySelector('[itemtype*="schema.org/Recipe"]');
    if (root == null) return null;

    final ingredients = root
        .querySelectorAll('[itemprop="recipeIngredient"]')
        .map((e) => _cleanHtmlText(e.text) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    List<String> instructions = [];
    final instructionNodes =
    root.querySelectorAll('[itemprop="recipeInstructions"]');
    for (var node in instructionNodes) {
      final steps = node.querySelectorAll('[itemprop="text"]');
      if (steps.isNotEmpty) {
        instructions.addAll(
            steps.map((e) => _cleanHtmlText(e.text) ?? '').where((s) => s.isNotEmpty));
      } else {
        final text = _cleanHtmlText(node.text);
        if (text != null && text.isNotEmpty) instructions.add(text);
      }
    }

    if (ingredients.isEmpty && instructions.isEmpty) return null;

    return ImportedRecipe(
      title: root.querySelector('[itemprop="name"]')?.text.trim() ??
          document.querySelector('title')?.text.trim() ??
          'Imported Recipe',
      ingredients: ingredients,
      instructions: instructions,
    );
  }

  static ImportedRecipe? _tryCommonSelectors(Document document) {
    final selectors = [
      // ── WordPress Recipe Plugins ──
      // WP Recipe Maker (most popular)
      ('.wprm-recipe-ingredients li', '.wprm-recipe-instructions li'),
      // Tasty Recipes
      ('.tasty-recipes-ingredients li', '.tasty-recipes-instructions li'),
      // Mediavine Create
      ('.mv-create-ingredients li', '.mv-create-instructions li'),
      // WP Delicious (formerly Starter Templates)
      ('.wpd-ingredients li', '.wpd-directions li'),
      // Yoast SEO Recipe (older sites)
      ('.wpseo-recipe-ingredients li', '.wpseo-recipe-instructions li'),
      // Zip Recipes
      ('.zlrecipe-ingredients li', '.zlrecipe-instructions li'),
      // EasyRecipe
      ('.ERSIngredients li', '.ERSInstructions li'),
      // Recipe Card Blocks by developer FLAVOR
      ('.recipe-card-ingredients li', '.recipe-card-instructions li'),
      // Flavor / WP Ultimate Recipe
      ('.wpurp-recipe-ingredients li', '.wpurp-recipe-instructions li'),
      // Cooked
      ('.cooked-ingredients li', '.cooked-directions li'),
      // Jeeves Recipe Plugin
      ('.jetpack-recipe-ingredients li', '.jetpack-recipe-directions li'),
      // Chicory
      ('.chicory-ingredients li', '.chicory-instructions li'),

      // ── Squarespace ──
      // Squarespace recipe blogs often use these patterns
      ('.recipe-ingredients li', '.recipe-instructions li'),
      ('.sqs-block-content ul li', '.sqs-block-content ol li'),
      ('.entry-content ul li', '.entry-content ol li'),

      // ── Blogger / Blogspot ──
      ('.post-body ul li', '.post-body ol li'),

      // ── Generic class names (broad fallbacks) ──
      ('.ingredients li', '.instructions li, .directions li'),
      ('ul[class*="ingredient"] li', 'ol[class*="instruction"] li'),
      ('[class*="ingredient-list"] li', '[class*="instruction-list"] li'),
      ('[class*="ingredient"] li', '[class*="direction"] li, [class*="method"] li'),
      ('[data-ingredient]', '[data-instruction], [data-direction]'),
    ];

    for (final (ingSelector, instSelector) in selectors) {
      final ings = document
          .querySelectorAll(ingSelector)
          .map((e) => _cleanHtmlText(e.text) ?? '')
          .where((s) => s.isNotEmpty && s.length > 2)
          .toList();

      final insts = document
          .querySelectorAll(instSelector)
          .map((e) => _cleanHtmlText(e.text) ?? '')
          .where((s) => s.isNotEmpty && s.length > 5)
          .toList();

      if (ings.isNotEmpty || insts.isNotEmpty) {
        // Try to get a better title than just h1
        final title = _extractBestTitle(document);
        return ImportedRecipe(
          title: title,
          ingredients: ings,
          instructions: insts,
        );
      }
    }
    return null;
  }

  /// Extract the best recipe title from a document
  static String _extractBestTitle(Document document) {
    // WPRM title
    final wprm = document.querySelector('.wprm-recipe-name');
    if (wprm != null && wprm.text.trim().isNotEmpty) return wprm.text.trim();

    // Tasty Recipes title
    final tasty = document.querySelector('.tasty-recipes-title');
    if (tasty != null && tasty.text.trim().isNotEmpty) return tasty.text.trim();

    // Mediavine title
    final mv = document.querySelector('.mv-create-title');
    if (mv != null && mv.text.trim().isNotEmpty) return mv.text.trim();

    // Recipe schema name
    final schema = document.querySelector('[itemprop="name"]');
    if (schema != null && schema.text.trim().isNotEmpty) return schema.text.trim();

    // og:title (usually cleaner than page <title>)
    final ogTitle = document.querySelector('meta[property="og:title"]')?.attributes['content'];
    if (ogTitle != null && ogTitle.isNotEmpty) return ogTitle;

    // Standard heading
    final h1 = document.querySelector('h1');
    if (h1 != null && h1.text.trim().isNotEmpty) return h1.text.trim();

    // Fallback to <title>
    return document.querySelector('title')?.text.trim() ?? 'Imported Recipe';
  }

  static ImportedRecipe? _tryGenericHtml(Document document) {
    final bodyText = document.body?.text ?? '';
    if (bodyText.length < 100) return null;
    return _parseStructuredText(bodyText);
  }

  // ========== PLATFORM-SPECIFIC EXTRACTORS ==========

  /// Try platform-specific extraction for social media and special sites.
  /// Social media pages are mostly JS-rendered, so we extract what we can
  /// from meta tags, captions, and any server-rendered content.
  static ImportedRecipe? _tryPlatformSpecific(Document document, _Platform platform) {
    switch (platform) {
      case _Platform.instagram:
        return _tryInstagram(document);
      case _Platform.tiktok:
        return _tryTiktok(document);
      case _Platform.pinterest:
        return _tryPinterest(document);
      case _Platform.youtube:
        return _tryYoutube(document);
      case _Platform.squarespace:
        return _trySquarespace(document);
      case _Platform.generic:
        return null;
    }
  }

  /// Instagram: Extract from meta description/title (caption usually has the recipe)
  static ImportedRecipe? _tryInstagram(Document document) {
    // Instagram puts the caption in og:description
    final caption = _getMetaContent(document, 'og:description')
        ?? _getMetaContent(document, 'description');
    final rawTitle = _getMetaContent(document, 'og:title') ?? 'Instagram Recipe';
    final image = _getMetaContent(document, 'og:image');

    if (caption == null || caption.length < 50) return null;

    // og:title is typically: "Username on Instagram: "actual recipe name here 🔁 Save this..."
    // _extractSocialTitle handles the quoted-title pattern; fall back to caption, then _cleanSocialTitle
    final cleanTitle = _extractSocialTitle(rawTitle)
        ?? _extractSocialTitle(caption)
        ?? _cleanSocialTitle(rawTitle);

    // Try to parse the caption as a recipe
    final parsed = _parseStructuredText(caption);
    if (parsed.ingredients.isEmpty && parsed.instructions.isEmpty) {
      // Caption wasn't structured — try splitting on common patterns
      final result = _parseSocialCaption(caption, rawTitle, image);
      result?.title = cleanTitle; // override _cleanSocialTitle(title) done internally
      return result;
    }

    parsed.title = cleanTitle;
    parsed.imageUrl = image;
    return parsed;
  }

  /// TikTok: Similar to Instagram — recipe is in the description/caption
  static ImportedRecipe? _tryTiktok(Document document) {
    final caption = _getMetaContent(document, 'og:description')
        ?? _getMetaContent(document, 'description');
    final title = _getMetaContent(document, 'og:title') ?? 'TikTok Recipe';
    final image = _getMetaContent(document, 'og:image');

    if (caption == null || caption.length < 30) return null;

    // TikTok sometimes embeds recipe data in script tags
    final scripts = document.querySelectorAll('script');
    for (final script in scripts) {
      if (script.text.contains('"recipeIngredient"') || script.text.contains('"recipeInstructions"')) {
        try {
          // Find the JSON object containing recipe data
          final jsonMatch = RegExp(r'\{[^{}]*"recipeIngredient"[^{}]*\}', dotAll: true).firstMatch(script.text);
          if (jsonMatch != null) {
            final json = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
            return _recipeFromJsonLd(json);
          }
        } catch (_) {}
      }
    }

    final parsed = _parseStructuredText(caption);
    if (parsed.ingredients.isEmpty && parsed.instructions.isEmpty) {
      return _parseSocialCaption(caption, title, image);
    }
    parsed.title = _cleanSocialTitle(title);
    parsed.imageUrl = image;
    return parsed;
  }

  /// Pinterest: Often has structured data or links to the original recipe
  static ImportedRecipe? _tryPinterest(Document document) {
    // Pinterest sometimes includes recipe schema in their page
    // Also check for the "original source" link which points to the real recipe
    final canonicalUrl = document.querySelector('link[rel="canonical"]')?.attributes['href'];
    final ogUrl = _getMetaContent(document, 'og:url');

    // If Pinterest has recipe schema, it's already handled by JSON-LD/microdata
    // This fallback extracts from pin description
    final description = _getMetaContent(document, 'og:description')
        ?? _getMetaContent(document, 'description');
    final title = _getMetaContent(document, 'og:title') ?? 'Pinterest Recipe';
    final image = _getMetaContent(document, 'og:image');

    if (description == null || description.length < 50) return null;

    final parsed = _parseStructuredText(description);
    if (parsed.ingredients.isNotEmpty || parsed.instructions.isNotEmpty) {
      parsed.title = _cleanSocialTitle(title);
      parsed.imageUrl = image;
      return parsed;
    }

    return _parseSocialCaption(description, title, image);
  }

  /// YouTube: Recipe is often in the video description
  static ImportedRecipe? _tryYoutube(Document document) {
    final title = _getMetaContent(document, 'og:title') ?? 'YouTube Recipe';
    final image = _getMetaContent(document, 'og:image');

    // YouTube puts video description in various places
    final description = _getMetaContent(document, 'og:description')
        ?? _getMetaContent(document, 'description');

    // Also try to find description in page content
    final descEl = document.querySelector('#description-text, .ytd-text-inline-expander, [itemprop="description"]');
    final descText = descEl?.text ?? description;

    if (descText == null || descText.length < 50) return null;

    final parsed = _parseStructuredText(descText);
    if (parsed.ingredients.isEmpty && parsed.instructions.isEmpty) {
      return _parseSocialCaption(descText, title, image);
    }
    parsed.title = _cleanSocialTitle(title);
    parsed.imageUrl = image;
    return parsed;
  }

  /// Squarespace: Try specific Squarespace blog patterns when JSON-LD and standard selectors miss
  static ImportedRecipe? _trySquarespace(Document document) {
    // Squarespace recipe blogs often use plain content blocks
    // Look for content with recipe-like structure in .sqs-block-content
    final blocks = document.querySelectorAll('.sqs-block-content, .sqs-layout');
    if (blocks.isEmpty) return null;

    // Combine all block text and try structured parsing
    final allText = blocks.map((b) => b.text).join('\n');
    if (allText.length < 100) return null;

    final parsed = _parseStructuredText(allText);
    if (parsed.ingredients.isEmpty && parsed.instructions.isEmpty) return null;

    parsed.title = _extractBestTitle(document);
    parsed.imageUrl ??= _findBestImage(document);
    return parsed;
  }

  // ========== SOCIAL MEDIA HELPERS ==========

  /// Parse a social media caption that might contain a recipe.
  /// Captions often use emoji or line breaks to separate ingredients from steps.
  static ImportedRecipe? _parseSocialCaption(String caption, String title, String? image) {
    final lines = caption.split(RegExp(r'\n|\\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.length < 3) return null;

    final ingredients = <String>[];
    final instructions = <String>[];
    var inInstructions = false;

    for (final line in lines) {
      // Skip hashtag lines
      if (line.startsWith('#') && line.split('#').length > 2) continue;
      // Skip "follow me" type lines
      if (RegExp(r'follow|subscribe|link in bio|tag|comment|like', caseSensitive: false).hasMatch(line)
          && line.length < 80) continue;

      final cleaned = line
          .replaceAll(RegExp(r'^[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]+\s*', unicode: true), '') // Leading emoji
          .replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '') // Leading numbers
          .trim();

      if (cleaned.isEmpty) continue;

      // Detect section headers
      if (RegExp(r'^(ingredients?|what you.?ll need|you.?ll need)', caseSensitive: false).hasMatch(cleaned)) {
        inInstructions = false;
        continue;
      }
      if (RegExp(r'^(instructions?|directions?|method|steps?|how to|what to do)', caseSensitive: false).hasMatch(cleaned)) {
        inInstructions = true;
        continue;
      }

      // Use scoring if no clear sections
      if (inInstructions || _instructionScore(cleaned) > 0.4) {
        if (_isValidInstruction(cleaned)) {
          instructions.add(cleaned);
          inInstructions = true;
        }
      } else if (_ingredientScore(cleaned) > 0.3) {
        if (_isValidIngredient(cleaned)) ingredients.add(cleaned);
      } else if (cleaned.length > 20) {
        // Long line without clear signal — guess based on what we've found so far
        if (ingredients.isNotEmpty && instructions.isEmpty) {
          instructions.add(cleaned);
          inInstructions = true;
        }
      }
    }

    if (ingredients.isEmpty && instructions.isEmpty) return null;

    return ImportedRecipe(
      title: _cleanSocialTitle(title),
      ingredients: ingredients,
      instructions: instructions,
      imageUrl: image,
    );
  }

  /// Clean a social media title (remove "on Instagram", "| TikTok", etc.)
  static String _cleanSocialTitle(String title) {
    return title
        .replaceAll(RegExp(r'\s*[|–—]\s*(Instagram|TikTok|Pinterest|YouTube).*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*on\s+(Instagram|TikTok|Pinterest).*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'^(Instagram|TikTok|Pinterest)\s*[|–—:]\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'#\w+'), '') // Remove hashtags
        .replaceAll(RegExp(r'@\w+'), '') // Remove mentions
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Detect social media caption text pasted as plain text and extract recipe name.
  /// Returns null if the text doesn't look like a social media caption.
  static String? _extractSocialTitle(String text) {
    // Pattern: "Username on Instagram: "recipe title here..."
    final instagramQuoteMatch = RegExp(
      r'(?:^|\b)\w[\w.]*\s+on\s+Instagram:\s*["""\u201C]([^"""\u201D]+)["""\u201D]',
      caseSensitive: false,
    ).firstMatch(text);
    if (instagramQuoteMatch != null) {
      var extracted = instagramQuoteMatch.group(1)!.trim();
      // Take only up to first emoji or special marker
      extracted = extracted.replaceAll(RegExp(r'[\u{1F000}-\u{1FFFF}].*', unicode: true), '').trim();
      if (extracted.length > 3 && extracted.length < 150) return extracted;
    }

    // Pattern: "Username on Platform: ..." or "@username ..."
    final socialPrefixMatch = RegExp(
      r'^(?:@\w[\w.]*|[\w.][\w.]*\s+on\s+(?:Instagram|TikTok|Pinterest))\s*[:\-–]\s*["""\u201C]?(.+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (socialPrefixMatch != null) {
      var rest = socialPrefixMatch.group(1)!;
      // Extract up to first sentence-ending punctuation, emoji block, or recipe keyword
      final sentenceEnd = RegExp(
        r'[.!?]\s|[\u{1F000}-\u{1FFFF}]|(?:Dough|Ingredients|Instructions|Directions|Recipe|Save this|Makes?\s+\d)',
        unicode: true,
        caseSensitive: false,
      ).firstMatch(rest);
      if (sentenceEnd != null) {
        rest = rest.substring(0, sentenceEnd.start).trim();
      }
      rest = rest.replaceAll(RegExp(r'^["""\u201C]|["""\u201D]$'), '').trim();
      if (rest.length > 3 && rest.length < 150) return rest;
    }

    // Very long first line (>150 chars) — likely social paste, extract before recipe keywords
    if (text.length > 150) {
      final keywordMatch = RegExp(
        r'(?:Dough|Batter|Filling|Sauce|Frosting|Glaze|Topping|Ingredients|Instructions|Directions|Recipe|Method|Steps)\s*:',
        caseSensitive: false,
      ).firstMatch(text);
      if (keywordMatch != null && keywordMatch.start > 10) {
        var candidate = text.substring(0, keywordMatch.start).trim();
        // Stop at first emoji, period, or social phrase
        final stopMatch = RegExp(
          r'[\u{1F000}-\u{1FFFF}]|[.!?]\s|Save this|They.re\s|And so\s|So easy|So good|Makes?\s+\d',
          unicode: true,
          caseSensitive: false,
        ).firstMatch(candidate);
        if (stopMatch != null && stopMatch.start > 3) {
          candidate = candidate.substring(0, stopMatch.start).trim();
        }
        candidate = _cleanSocialTitle(candidate);
        candidate = candidate.replaceAll(RegExp(r'^["""\u201C]|["""\u201D]$'), '').trim();
        if (candidate.length > 3 && candidate.length < 150) return candidate;
      }
    }

    return null;
  }

  /// Get meta tag content by property or name
  static String? _getMetaContent(Document document, String key) {
    final byProperty = document.querySelector('meta[property="$key"]')?.attributes['content'];
    if (byProperty != null && byProperty.isNotEmpty) return byProperty;
    final byName = document.querySelector('meta[name="$key"]')?.attributes['content'];
    return (byName != null && byName.isNotEmpty) ? byName : null;
  }

  // ========== IMAGE EXTRACTION ==========

  static String? _findBestImage(Document document) {
    // 1. og:image (most reliable)
    final ogImage = _getMetaContent(document, 'og:image');
    if (ogImage != null && ogImage.isNotEmpty) return ogImage;

    // 2. twitter:image
    final twitterImage = document.querySelector('meta[name="twitter:image"]')?.attributes['content']
        ?? document.querySelector('meta[property="twitter:image"]')?.attributes['content'];
    if (twitterImage != null && twitterImage.isNotEmpty) return twitterImage;

    // 3. Recipe-specific image containers
    for (final selector in [
      '.wprm-recipe-image img',
      '.tasty-recipes-image img',
      '.mv-create-image img',
      '.recipe-image img',
      '[itemprop="image"]',
    ]) {
      final el = document.querySelector(selector);
      if (el != null) {
        final src = el.attributes['src'] ?? el.attributes['data-src'] ?? el.attributes['data-lazy-src'];
        if (src != null && src.isNotEmpty) return src;
      }
    }

    // 4. Largest image by dimensions or class hints
    String? bestSrc;
    int bestArea = 0;
    for (final img in document.querySelectorAll('img[src]')) {
      final src = img.attributes['src'] ?? '';
      final dataSrc = img.attributes['data-src'] ?? img.attributes['data-lazy-src'];
      final width = int.tryParse(img.attributes['width'] ?? '0') ?? 0;
      final height = int.tryParse(img.attributes['height'] ?? '0') ?? 0;
      final area = width * height;

      // Skip tiny images, icons, avatars
      if (width > 0 && width < 100) continue;
      if (src.contains('avatar') || src.contains('icon') || src.contains('logo')) continue;

      if (area > bestArea) {
        bestArea = area;
        bestSrc = dataSrc ?? src;
      } else if (bestSrc == null && width >= 300) {
        bestSrc = dataSrc ?? src;
      }
    }

    return bestSrc;
  }

  // ========== APP-SPECIFIC HTML PARSERS ==========

  /// Detect and parse app-specific HTML export formats
  static List<ImportedRecipe> _tryAppSpecificHtml(Document document, String rawHtml) {
    // RecipeKeeper: single HTML with all recipes, each in <div class="recipe-details">
    if (document.querySelector('.recipe-details') != null ||
        rawHtml.contains('RecipeKeeper') ||
        document.querySelectorAll('[class*="recipe-details"]').length > 1) {
      return _parseRecipeKeeperHtml(document);
    }

    // CopyMeThat: HTML export with <div class="recipe"> blocks
    if (rawHtml.contains('CopyMeThat') ||
        rawHtml.contains('copymeThat') ||
        document.querySelector('.recipeGroup') != null) {
      return _parseCopyMeThatHtml(document);
    }

    return [];
  }

  /// Parse RecipeKeeper's monolithic HTML export.
  /// RecipeKeeper exports ALL recipes into a single (often 600KB+) HTML file.
  /// Structure: multiple <div class="recipe-details"> each containing the recipe.
  static List<ImportedRecipe> _parseRecipeKeeperHtml(Document document) {
    final recipes = <ImportedRecipe>[];

    // RecipeKeeper wraps each recipe in .recipe-details
    var recipeBlocks = document.querySelectorAll('.recipe-details');

    // Fallback: try other common RK selectors
    if (recipeBlocks.isEmpty) {
      recipeBlocks = document.querySelectorAll('[class*="recipe-details"], .recipe');
    }

    for (final block in recipeBlocks) {
      try {
        // Title
        final titleEl = block.querySelector('.recipe-title, h2, h1, .title');
        final title = titleEl?.text.trim() ?? 'Imported Recipe';

        // Ingredients
        final ingSection = block.querySelector('.recipe-ingredients, [class*="ingredient"]');
        final ingredients = <String>[];
        if (ingSection != null) {
          // RecipeKeeper uses <li> or <p> or plain text with line breaks
          final listItems = ingSection.querySelectorAll('li');
          if (listItems.isNotEmpty) {
            ingredients.addAll(listItems
                .map((e) => _cleanHtmlText(e.text) ?? '')
                .where((s) => s.isNotEmpty && s.length > 2));
          } else {
            // Plain text separated by <br> or newlines
            ingredients.addAll(ingSection.innerHtml
                .replaceAll(RegExp(r'<br\s*/?>'), '\n')
                .replaceAll(RegExp(r'<[^>]+>'), '')
                .split('\n')
                .map((l) => l.trim())
                .where((l) => l.isNotEmpty && l.length > 2));
          }
        }

        // Instructions
        final instSection = block.querySelector('.recipe-directions, .recipe-instructions, [class*="direction"], [class*="instruction"]');
        final instructions = <String>[];
        if (instSection != null) {
          final listItems = instSection.querySelectorAll('li');
          if (listItems.isNotEmpty) {
            instructions.addAll(listItems
                .map((e) => _cleanHtmlText(e.text) ?? '')
                .where((s) => s.isNotEmpty && s.length > 5));
          } else {
            instructions.addAll(instSection.innerHtml
                .replaceAll(RegExp(r'<br\s*/?>'), '\n')
                .replaceAll(RegExp(r'<[^>]+>'), '')
                .split('\n')
                .map((l) => l.trim())
                .where((l) => l.isNotEmpty && l.length > 5));
          }
        }

        // Notes
        final notesEl = block.querySelector('.recipe-notes, [class*="note"]');
        final notes = notesEl != null ? _cleanHtmlText(notesEl.text) : null;

        // Metadata
        final servingsEl = block.querySelector('[class*="serving"], [class*="yield"]');
        final prepEl = block.querySelector('[class*="prep"]');
        final cookEl = block.querySelector('[class*="cook"]');
        final categoryEl = block.querySelector('[class*="category"], [class*="course"]');
        final imageEl = block.querySelector('img');

        // Source URL
        final sourceEl = block.querySelector('[class*="source"] a, [class*="url"] a');

        if (ingredients.isNotEmpty || instructions.isNotEmpty) {
          recipes.add(ImportedRecipe(
            title: title,
            ingredients: ingredients,
            instructions: instructions,
            notes: notes,
            servings: servingsEl != null ? _cleanHtmlText(servingsEl.text) : null,
            prepTimeMinutes: prepEl != null ? _parseTimeString(_cleanHtmlText(prepEl.text) ?? '') : null,
            cookTimeMinutes: cookEl != null ? _parseTimeString(_cleanHtmlText(cookEl.text) ?? '') : null,
            imageUrl: imageEl?.attributes['src'],
            sourceUrl: sourceEl?.attributes['href'],
            sourceApp: 'recipekeeper',
            tags: categoryEl != null ? [_cleanHtmlText(categoryEl.text) ?? ''] : null,
          ));
        }
      } catch (_) {
        // Skip malformed recipe blocks
      }
    }

    return recipes;
  }

  /// Parse CopyMeThat HTML export.
  /// Structure: recipe blocks in <div class="recipe"> or similar groupings.
  static List<ImportedRecipe> _parseCopyMeThatHtml(Document document) {
    final recipes = <ImportedRecipe>[];

    var blocks = document.querySelectorAll('.recipe, .recipeGroup > div');
    if (blocks.isEmpty) {
      // Try broader selectors
      blocks = document.querySelectorAll('[class*="recipe"]');
    }

    for (final block in blocks) {
      try {
        final titleEl = block.querySelector('h2, h1, .title, [class*="title"]');
        final title = titleEl?.text.trim();
        if (title == null || title.isEmpty) continue;

        final ingredients = <String>[];
        final instructions = <String>[];

        // CopyMeThat often uses <ul> for ingredients and <ol> for directions
        final ingLists = block.querySelectorAll('ul li, [class*="ingredient"] li');
        ingredients.addAll(ingLists
            .map((e) => _cleanHtmlText(e.text) ?? '')
            .where((s) => s.isNotEmpty && s.length > 2));

        final instLists = block.querySelectorAll('ol li, [class*="direction"] li, [class*="instruction"] li');
        instructions.addAll(instLists
            .map((e) => _cleanHtmlText(e.text) ?? '')
            .where((s) => s.isNotEmpty && s.length > 5));

        // If no list items, try parsing all text
        if (ingredients.isEmpty && instructions.isEmpty) {
          final bodyText = block.text;
          if (bodyText.length > 50) {
            final parsed = _parseStructuredText(bodyText);
            ingredients.addAll(parsed.ingredients);
            instructions.addAll(parsed.instructions);
          }
        }

        final notesEl = block.querySelector('[class*="note"]');
        final imageEl = block.querySelector('img');
        final sourceEl = block.querySelector('a[href*="http"]');

        if (ingredients.isNotEmpty || instructions.isNotEmpty) {
          recipes.add(ImportedRecipe(
            title: title,
            ingredients: ingredients,
            instructions: instructions,
            notes: notesEl != null ? _cleanHtmlText(notesEl.text) : null,
            imageUrl: imageEl?.attributes['src'],
            sourceUrl: sourceEl?.attributes['href'],
            sourceApp: 'copymeThat',
          ));
        }
      } catch (_) {}
    }

    return recipes;
  }

  // ========== APP-SPECIFIC JSON PARSERS ==========

  /// Try to detect and parse app-specific JSON formats (single recipe)
  static ImportedRecipe? _tryAppJson(String content) {
    try {
      final json = jsonDecode(content);
      if (json is Map<String, dynamic>) {
        // Crouton format
        if (json.containsKey('ingredientSections') || json.containsKey('stepSections')) {
          return _parseCroutonRecipe(json);
        }
        // Tandoor format
        if (json.containsKey('steps') && json['steps'] is List && json.containsKey('working_time')) {
          return _parseTandoorRecipe(json);
        }
        // Mealie format
        if (json.containsKey('recipe_ingredient') || json.containsKey('recipe_instructions')) {
          return _parseMealieRecipe(json);
        }
        // Samsung Food / Whisk format
        if (json.containsKey('whpiRecipeId') || json.containsKey('recipeItems')) {
          return _parseSamsungFoodRecipe(json);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Try to detect and parse app-specific JSON formats (multiple recipes)
  static List<ImportedRecipe> _tryAppJsonBulk(String content) {
    try {
      final json = jsonDecode(content);

      // Array of recipes
      if (json is List) {
        final recipes = <ImportedRecipe>[];
        for (final item in json) {
          if (item is Map<String, dynamic>) {
            final recipe = _tryAppJsonSingle(item);
            if (recipe != null) recipes.add(recipe);
          }
        }
        if (recipes.isNotEmpty) return recipes;
      }

      // Wrapper object with recipes array
      if (json is Map<String, dynamic>) {
        // Tandoor export: {"recipes": [...]}
        final recipesArray = json['recipes'] ?? json['items'] ?? json['data'];
        if (recipesArray is List) {
          final recipes = <ImportedRecipe>[];
          for (final item in recipesArray) {
            if (item is Map<String, dynamic>) {
              final recipe = _tryAppJsonSingle(item);
              if (recipe != null) recipes.add(recipe);
            }
          }
          if (recipes.isNotEmpty) return recipes;
        }

        // Mealie export: {"groups": [{"recipes": [...]}]}
        final groups = json['groups'];
        if (groups is List) {
          final recipes = <ImportedRecipe>[];
          for (final group in groups) {
            if (group is Map && group['recipes'] is List) {
              for (final item in group['recipes']) {
                if (item is Map<String, dynamic>) {
                  final recipe = _parseMealieRecipe(item);
                  recipes.add(recipe);
                }
              }
            }
          }
          if (recipes.isNotEmpty) return recipes;
        }

        // Single recipe
        final single = _tryAppJsonSingle(json);
        if (single != null) return [single];
      }
    } catch (_) {}
    return [];
  }

  /// Try a single JSON object against all known app formats
  static ImportedRecipe? _tryAppJsonSingle(Map<String, dynamic> json) {
    // Crouton
    if (json.containsKey('ingredientSections') || json.containsKey('stepSections')) {
      return _parseCroutonRecipe(json);
    }
    // Tandoor
    if (json.containsKey('steps') && json['steps'] is List && json.containsKey('working_time')) {
      return _parseTandoorRecipe(json);
    }
    // Mealie
    if (json.containsKey('recipe_ingredient') || json.containsKey('recipe_instructions')) {
      return _parseMealieRecipe(json);
    }
    // Samsung Food / Whisk
    if (json.containsKey('whpiRecipeId') || json.containsKey('recipeItems')) {
      return _parseSamsungFoodRecipe(json);
    }
    // Mela format
    if (json.containsKey('text') && (json.containsKey('title') || json.containsKey('name'))) {
      final text = json['text']?.toString() ?? '';
      if (text.contains('---') || json.containsKey('images') || json.containsKey('categories')) {
        return parseMelaRecipe(json);
      }
    }
    // Generic recipe JSON detection — catches exports from lesser-known apps
    final hasTitle = json.containsKey('title') || json.containsKey('name');
    final hasIngredients = json.containsKey('ingredients') || json.containsKey('recipeIngredient');
    final hasInstructions = json.containsKey('instructions') || json.containsKey('directions') ||
        json.containsKey('steps') || json.containsKey('recipeInstructions');
    if (hasTitle && hasIngredients && hasInstructions) {
      return _buildRecipeFromJsonMap(json);
    }
    return null;
  }

  /// Parse Crouton app JSON format.
  /// Structure: { name, ingredientSections: [{ingredients: [{quantity, unit, name}]}], stepSections: [{steps: [{text}]}] }
  static ImportedRecipe _parseCroutonRecipe(Map<String, dynamic> json) {
    final ingredients = <String>[];
    final instructions = <String>[];

    // Ingredients: nested in sections
    final ingSections = json['ingredientSections'] ?? json['ingredients'];
    if (ingSections is List) {
      for (final section in ingSections) {
        if (section is Map) {
          final sectionName = section['name']?.toString();
          if (sectionName != null && sectionName.isNotEmpty) {
            ingredients.add('— $sectionName —');
          }
          final items = section['ingredients'] ?? section['items'];
          if (items is List) {
            for (final ing in items) {
              if (ing is Map) {
                final qty = ing['quantity']?.toString() ?? '';
                final unit = ing['unit']?.toString() ?? '';
                final name = ing['name']?.toString() ?? ing['ingredient']?.toString() ?? '';
                final parts = [qty, unit, name].where((s) => s.isNotEmpty).join(' ');
                if (parts.isNotEmpty) ingredients.add(parts);
              } else if (ing is String) {
                ingredients.add(ing);
              }
            }
          }
        } else if (section is String) {
          ingredients.add(section);
        }
      }
    }

    // Steps: nested in sections
    final stepSections = json['stepSections'] ?? json['steps'];
    if (stepSections is List) {
      for (final section in stepSections) {
        if (section is Map) {
          final steps = section['steps'] ?? section['items'];
          if (steps is List) {
            for (final step in steps) {
              final text = step is Map ? (step['text'] ?? step['instruction'])?.toString() : step?.toString();
              if (text != null && text.isNotEmpty) instructions.add(text);
            }
          }
          // Single text field
          final text = section['text']?.toString();
          if (text != null && text.isNotEmpty) instructions.add(text);
        } else if (section is String) {
          instructions.add(section);
        }
      }
    }

    return ImportedRecipe(
      title: json['name']?.toString() ?? json['title']?.toString() ?? 'Crouton Recipe',
      description: json['description']?.toString(),
      ingredients: ingredients,
      instructions: instructions,
      servings: json['servings']?.toString() ?? json['yield']?.toString(),
      prepTimeMinutes: _parseTimeValue(json['prepTime'] ?? json['prep_time']),
      cookTimeMinutes: _parseTimeValue(json['cookTime'] ?? json['cook_time']),
      imageUrl: json['image']?.toString() ?? json['imageUrl']?.toString(),
      sourceUrl: json['url']?.toString() ?? json['sourceUrl']?.toString(),
      sourceApp: 'crouton',
    );
  }

  /// Parse Tandoor recipe manager JSON format.
  /// Structure: { name, steps: [{ingredients: [{food: {name}, unit: {name}, amount}], instruction}], working_time, waiting_time }
  static ImportedRecipe _parseTandoorRecipe(Map<String, dynamic> json) {
    final ingredients = <String>[];
    final instructions = <String>[];

    final steps = json['steps'];
    if (steps is List) {
      for (final step in steps) {
        if (step is! Map) continue;

        // Ingredients within each step
        final stepIngs = step['ingredients'];
        if (stepIngs is List) {
          for (final ing in stepIngs) {
            if (ing is! Map) continue;
            final amount = ing['amount']?.toString() ?? '';
            final unit = (ing['unit'] is Map) ? ing['unit']['name']?.toString() ?? '' : '';
            final food = (ing['food'] is Map) ? ing['food']['name']?.toString() ?? '' : ing['food']?.toString() ?? '';
            final note = ing['note']?.toString() ?? '';
            final parts = [amount, unit, food, if (note.isNotEmpty) '($note)']
                .where((s) => s.isNotEmpty && s != '0')
                .join(' ');
            if (parts.isNotEmpty) ingredients.add(parts);
          }
        }

        // Instruction text
        final instruction = step['instruction']?.toString();
        if (instruction != null && instruction.isNotEmpty) instructions.add(instruction);
      }
    }

    // Tandoor uses seconds for time
    int? workingTime = json['working_time'] is int ? json['working_time'] as int : null;
    int? waitingTime = json['waiting_time'] is int ? json['waiting_time'] as int : null;
    if (workingTime != null) workingTime = (workingTime / 60).round();
    if (waitingTime != null) waitingTime = (waitingTime / 60).round();

    // Tags/keywords
    final keywords = json['keywords'];
    List<String>? tags;
    if (keywords is List) {
      tags = keywords.map((k) => k is Map ? k['name']?.toString() ?? '' : k.toString()).where((s) => s.isNotEmpty).toList();
    }

    return ImportedRecipe(
      title: json['name']?.toString() ?? 'Tandoor Recipe',
      description: json['description']?.toString(),
      ingredients: ingredients,
      instructions: instructions,
      servings: json['servings']?.toString(),
      prepTimeMinutes: workingTime,
      cookTimeMinutes: waitingTime,
      imageUrl: json['image']?.toString(),
      sourceUrl: json['source_url']?.toString(),
      tags: tags,
      sourceApp: 'tandoor',
    );
  }

  /// Parse Mealie recipe JSON format.
  /// Structure: { name, recipe_ingredient: [{note, quantity, unit: {name}, food: {name}}], recipe_instructions: [{text}] }
  static ImportedRecipe _parseMealieRecipe(Map<String, dynamic> json) {
    final ingredients = <String>[];
    final instructions = <String>[];

    // Ingredients
    final recipeIngs = json['recipe_ingredient'] ?? json['recipeIngredient'];
    if (recipeIngs is List) {
      for (final ing in recipeIngs) {
        if (ing is Map) {
          final qty = ing['quantity']?.toString() ?? '';
          final unit = (ing['unit'] is Map) ? ing['unit']['name']?.toString() ?? '' : ing['unit']?.toString() ?? '';
          final food = (ing['food'] is Map) ? ing['food']['name']?.toString() ?? '' : ing['food']?.toString() ?? '';
          final note = ing['note']?.toString() ?? '';
          final display = ing['display']?.toString(); // Mealie pre-formats this
          if (display != null && display.isNotEmpty) {
            ingredients.add(display);
          } else {
            final parts = [qty, unit, food, if (note.isNotEmpty) '($note)']
                .where((s) => s.isNotEmpty && s != '0')
                .join(' ');
            if (parts.isNotEmpty) ingredients.add(parts);
          }
        } else if (ing is String) {
          ingredients.add(ing);
        }
      }
    }

    // Instructions
    final recipeInsts = json['recipe_instructions'] ?? json['recipeInstructions'];
    if (recipeInsts is List) {
      for (final inst in recipeInsts) {
        if (inst is Map) {
          final text = inst['text']?.toString();
          if (text != null && text.isNotEmpty) instructions.add(text);
        } else if (inst is String) {
          instructions.add(inst);
        }
      }
    }

    // Tags
    final rawTags = json['tags'] ?? json['recipe_category'];
    List<String>? tags;
    if (rawTags is List) {
      tags = rawTags.map((t) => t is Map ? t['name']?.toString() ?? '' : t.toString()).where((s) => s.isNotEmpty).toList();
    }

    return ImportedRecipe(
      title: json['name']?.toString() ?? 'Mealie Recipe',
      description: json['description']?.toString(),
      ingredients: ingredients,
      instructions: instructions,
      servings: json['recipe_yield']?.toString() ?? json['recipeYield']?.toString(),
      prepTimeMinutes: _parseTimeValue(json['prep_time'] ?? json['prepTime']),
      cookTimeMinutes: _parseTimeValue(json['perform_time'] ?? json['cookTime'] ?? json['total_time']),
      imageUrl: json['image']?.toString(),
      sourceUrl: json['org_url']?.toString() ?? json['url']?.toString(),
      notes: json['notes'] is List
          ? (json['notes'] as List).map((n) => n is Map ? n['text']?.toString() ?? '' : n.toString()).where((s) => s.isNotEmpty).join('\n')
          : json['notes']?.toString(),
      tags: tags,
      sourceApp: 'mealie',
    );
  }

  /// Parse Samsung Food (formerly Whisk) JSON format.
  static ImportedRecipe _parseSamsungFoodRecipe(Map<String, dynamic> json) {
    final ingredients = <String>[];
    final instructions = <String>[];

    // Samsung Food uses recipeItems for ingredients
    final items = json['recipeItems'] ?? json['ingredients'];
    if (items is List) {
      for (final item in items) {
        if (item is Map) {
          final name = item['name']?.toString() ?? item['ingredient']?.toString() ?? '';
          final qty = item['quantity']?.toString() ?? item['amount']?.toString() ?? '';
          final unit = item['unit']?.toString() ?? '';
          final parts = [qty, unit, name].where((s) => s.isNotEmpty).join(' ');
          if (parts.isNotEmpty) ingredients.add(parts);
        } else if (item is String) {
          ingredients.add(item);
        }
      }
    }

    // Instructions
    final steps = json['instructions'] ?? json['steps'] ?? json['directions'];
    if (steps is List) {
      for (final step in steps) {
        final text = step is Map ? (step['text'] ?? step['instruction'] ?? step['description'])?.toString() : step?.toString();
        if (text != null && text.isNotEmpty) instructions.add(text);
      }
    }

    return ImportedRecipe(
      title: json['name']?.toString() ?? json['title']?.toString() ?? 'Samsung Food Recipe',
      description: json['description']?.toString(),
      ingredients: ingredients,
      instructions: instructions,
      servings: json['servings']?.toString() ?? json['yield']?.toString(),
      prepTimeMinutes: _parseTimeValue(json['prepTime'] ?? json['prep_time']),
      cookTimeMinutes: _parseTimeValue(json['cookTime'] ?? json['cook_time']),
      imageUrl: json['image']?.toString() ?? json['imageUrl']?.toString() ?? json['photo']?.toString(),
      sourceUrl: json['url']?.toString() ?? json['sourceUrl']?.toString(),
      sourceApp: 'samsungfood',
    );
  }

  /// Parse Paprika recipe JSON format.
  /// Each Paprika recipe JSON has: name, ingredients (newline-separated),
  /// directions (newline-separated), photo_data (base64), prep_time, cook_time,
  /// source, categories (newline-separated), notes, rating (0-5).
  static ImportedRecipe parsePaprikaRecipe(Map<String, dynamic> json) {
    final ingredientsRaw = json['ingredients']?.toString() ?? '';
    final directionsRaw = json['directions']?.toString() ?? '';

    final ingredients = ingredientsRaw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final instructions = directionsRaw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Parse time strings like "30 min", "1 hr 15 min", "45 minutes"
    int? parseTimeString(String? time) {
      if (time == null || time.trim().isEmpty) return null;
      final t = time.trim().toLowerCase();
      int minutes = 0;
      final hrMatch = RegExp(r'(\d+)\s*(?:hr|hour)s?').firstMatch(t);
      if (hrMatch != null) minutes += (int.tryParse(hrMatch.group(1)!) ?? 0) * 60;
      final minMatch = RegExp(r'(\d+)\s*(?:min|minute)s?').firstMatch(t);
      if (minMatch != null) minutes += int.tryParse(minMatch.group(1)!) ?? 0;
      // If just a number, assume minutes
      if (minutes == 0) {
        final plain = int.tryParse(t);
        if (plain != null) minutes = plain;
      }
      return minutes > 0 ? minutes : null;
    }

    // Parse categories (newline-separated in Paprika)
    final categoriesRaw = json['categories']?.toString() ?? '';
    final tags = categoriesRaw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Rating: Paprika uses 0-5, we store 0-5
    final rating = json['rating'] is int ? json['rating'] as int :
        (json['rating'] is double ? (json['rating'] as double).round() : null);

    return ImportedRecipe(
      title: json['name']?.toString() ?? json['title']?.toString() ?? 'Paprika Recipe',
      description: json['description']?.toString(),
      ingredients: ingredients,
      instructions: instructions,
      prepTimeMinutes: parseTimeString(json['prep_time']?.toString()),
      cookTimeMinutes: parseTimeString(json['cook_time']?.toString()),
      servings: json['servings']?.toString(),
      sourceUrl: json['source']?.toString() ?? json['source_url']?.toString(),
      notes: json['notes']?.toString(),
      imageUrl: json['image_url']?.toString(),
      imageData: json['photo_data']?.toString(), // Base64 photo
      tags: tags.isNotEmpty ? tags : null,
      rating: rating,
      sourceApp: 'paprika',
    );
  }

  /// Parse Mela recipe JSON format.
  /// Mela uses: title, text (markdown with --- separator), images (base64 array), link, categories.
  static ImportedRecipe parseMelaRecipe(Map<String, dynamic> json) {
    final title = json['title']?.toString() ?? 'Mela Recipe';
    final text = json['text']?.toString() ?? '';
    final link = json['link']?.toString();

    // Parse text: ingredients and instructions separated by ---
    List<String> ingredients = [];
    List<String> instructions = [];

    if (text.contains('---')) {
      final parts = text.split('---');
      if (parts.length >= 2) {
        ingredients = parts[0]
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty && l != '-')
            .map((l) => l.startsWith('- ') ? l.substring(2) : l)
            .toList();
        instructions = parts.sublist(1).join('\n')
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .map((l) {
              // Remove markdown numbering
              final numMatch = RegExp(r'^\d+\.\s*').firstMatch(l);
              return numMatch != null ? l.substring(numMatch.end) : l;
            })
            .toList();
      }
    } else {
      // No separator — try structured text parsing
      final parsed = _parseStructuredText(text);
      ingredients = parsed.ingredients;
      instructions = parsed.instructions;
    }

    // Images: take the first one as base64 image data
    String? imageData;
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      imageData = (json['images'] as List).first?.toString();
    }

    // Categories as tags
    List<String>? tags;
    if (json['categories'] is List) {
      tags = (json['categories'] as List)
          .map((c) => c.toString().trim())
          .where((c) => c.isNotEmpty)
          .toList();
      if (tags.isEmpty) tags = null;
    }

    return ImportedRecipe(
      title: title,
      ingredients: ingredients,
      instructions: instructions,
      imageData: imageData,
      sourceUrl: link,
      tags: tags,
      sourceApp: 'mela',
    );
  }

  // ========== MEALMASTER FORMAT (.mmf / .mk) ==========

  static bool _looksLikeMealMaster(String content) {
    return content.contains('MMMMM') ||
        content.contains('---------- Recipe via Meal-Master') ||
        RegExp(r'Title:\s*.+\nCategories:', caseSensitive: false).hasMatch(content);
  }

  /// Parse MealMaster format (*.mmf, *.mk).
  /// Format: recipes delimited by MMMMM markers or ----- Recipe via Meal-Master headers.
  /// Each recipe has: Title, Categories, Yield, then ingredients, then directions.
  static List<ImportedRecipe> _parseMealMaster(String content) {
    final recipes = <ImportedRecipe>[];

    // Split into recipe blocks.
    // MealMaster uses MMMMM lines or "---------- Recipe via Meal-Master" as delimiters
    final blocks = content.split(RegExp(
      r'(?:^MMMMM.*$|^-{5,}\s*Recipe via Meal-Master.*$|^-{5,}\s*Exported from.*$)',
      multiLine: true,
      caseSensitive: false,
    ));

    for (final block in blocks) {
      final trimmed = block.trim();
      if (trimmed.isEmpty || trimmed.length < 20) continue;

      String? title;
      String? categories;
      String? yield_;
      final ingredients = <String>[];
      final instructions = <String>[];

      final lines = trimmed.split('\n');
      var inIngredients = true; // MealMaster: ingredients come before directions
      var hitBlankAfterIngredients = false;

      for (final rawLine in lines) {
        final line = rawLine.trimRight();

        // Header fields
        if (line.trim().toLowerCase().startsWith('title:')) {
          title = line.substring(line.indexOf(':') + 1).trim();
          continue;
        }
        if (line.trim().toLowerCase().startsWith('categories:')) {
          categories = line.substring(line.indexOf(':') + 1).trim();
          continue;
        }
        if (line.trim().toLowerCase().startsWith('yield:') || line.trim().toLowerCase().startsWith('servings:')) {
          yield_ = line.substring(line.indexOf(':') + 1).trim();
          continue;
        }

        // Skip MMMMM section markers within block
        if (RegExp(r'^MMMMM-+').hasMatch(line.trim())) {
          // This is a sub-section marker (e.g., "MMMMM----- FOR THE SAUCE")
          final sectionName = line.replaceAll(RegExp(r'^MMMMM-+\s*'), '').replaceAll(RegExp(r'-+$'), '').trim();
          if (sectionName.isNotEmpty) ingredients.add('— $sectionName —');
          continue;
        }

        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) {
          // Blank line after ingredients = switch to instructions
          if (inIngredients && ingredients.isNotEmpty) {
            hitBlankAfterIngredients = true;
          }
          continue;
        }

        // MealMaster ingredient format: "  1 1/2 c  Flour, all-purpose" or "           -- sifted"
        // Columns: amount (1-7), unit (8-9), ingredient name (11+)
        // Or two-column format with ingredients side by side
        if (inIngredients && !hitBlankAfterIngredients) {
          // Check if line looks like an ingredient (starts with number/space, has measurement)
          if (RegExp(r'^\s{0,7}\d').hasMatch(line) ||
              RegExp(r'^\s{7,}').hasMatch(line) && trimmedLine.length > 2) {
            // MealMaster two-column: ingredient | ingredient
            // Each column is ~41 chars
            if (line.length > 42 && RegExp(r'\d').hasMatch(line.substring(41))) {
              // Two-column
              final col1 = line.substring(0, 41).trim();
              final col2 = line.substring(41).trim();
              if (col1.isNotEmpty) ingredients.add(col1);
              if (col2.isNotEmpty) ingredients.add(col2);
            } else {
              ingredients.add(trimmedLine);
            }
          } else if (trimmedLine.startsWith('--') || trimmedLine.startsWith('-')) {
            // Continuation or note for previous ingredient
            if (ingredients.isNotEmpty) {
              ingredients[ingredients.length - 1] += ' ${trimmedLine.replaceFirst(RegExp(r'^-+\s*'), '')}';
            }
          } else {
            // Doesn't look like ingredient format — must be instructions now
            hitBlankAfterIngredients = true;
            instructions.add(trimmedLine);
          }
        } else {
          // We're in instructions
          inIngredients = false;
          if (trimmedLine.length > 3) {
            instructions.add(trimmedLine);
          }
        }
      }

      // Merge instruction lines into paragraphs (MealMaster wraps at ~80 chars)
      final mergedInstructions = _mergeMealMasterInstructions(instructions);

      if (title != null && (ingredients.isNotEmpty || mergedInstructions.isNotEmpty)) {
        recipes.add(ImportedRecipe(
          title: title,
          ingredients: ingredients,
          instructions: mergedInstructions,
          servings: yield_,
          tags: categories != null
              ? categories.split(',').map((c) => c.trim()).where((c) => c.isNotEmpty).toList()
              : null,
          sourceApp: 'mealmaster',
        ));
      }
    }

    return recipes;
  }

  /// MealMaster wraps instructions at ~80 characters. Merge continuation lines.
  static List<String> _mergeMealMasterInstructions(List<String> raw) {
    if (raw.isEmpty) return raw;

    final merged = <String>[];
    var current = raw.first;

    for (var i = 1; i < raw.length; i++) {
      final line = raw[i];
      // If the current line doesn't end with sentence-ending punctuation
      // and the next line starts lowercase, it's a continuation
      if (!current.endsWith('.') && !current.endsWith('!') && !current.endsWith('?') &&
          line.isNotEmpty && line[0] == line[0].toLowerCase() && line[0] != line[0].toUpperCase()) {
        current += ' $line';
      } else {
        if (current.isNotEmpty) merged.add(current);
        current = line;
      }
    }
    if (current.isNotEmpty) merged.add(current);

    return merged;
  }

  // ========== TEXT PARSING ==========

  static ImportedRecipe _parseStructuredText(String text) {
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

        if (i < 5 &&
            !_isListItem(line) &&
            line.length > 3) {
          // Detect social media caption patterns and extract recipe name
          final socialTitle = _extractSocialTitle(line);
          if (socialTitle != null) {
            title = socialTitle;
            foundTitle = true;
            continue;
          }

          if (line.length < 150) {
            title = _cleanMarkdown(line);
            foundTitle = true;
            continue;
          }
        }
      }

      // Extract metadata (servings, times)
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
          } else if (description == null &&
              cleanedLine.length > 20 &&
              cleanedLine.length < 500) {
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

    final recipe = ImportedRecipe(
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

  static ImportedRecipe _parseMarkdown(String text) {
    // Strip YAML frontmatter and code fences
    text = text.replaceAll(RegExp(r'^---[\s\S]*?---\n', multiLine: true), '');
    text = text.replaceAll(RegExp(r'~~~[\s\S]*?~~~', multiLine: true), '');
    return _parseStructuredText(text);
  }

  // ========== OBSIDIAN / YAML FRONTMATTER ==========

  static ImportedRecipe _parseObsidianMarkdown(String text) {
    String? title;
    String? description;
    String? imageUrl;
    int? prepTime;
    int? cookTime;
    int? servings;
    List<String>? tags;
    String? cuisine;
    String? course;

    // Extract YAML frontmatter between --- markers
    final frontmatterMatch =
    RegExp(r'^---\s*\n([\s\S]*?)\n---', multiLine: true).firstMatch(text);
    String bodyText = text;

    if (frontmatterMatch != null) {
      final yaml = frontmatterMatch.group(1) ?? '';
      bodyText = text.substring(frontmatterMatch.end).trim();

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
            if (value.startsWith('[') && value.endsWith(']')) {
              value = value.substring(1, value.length - 1);
            }
            tags = value
                .split(',')
                .map((t) => t.trim())
                .where((t) => t.isNotEmpty)
                .toList();
            break;
          case 'cuisine':
            cuisine = value;
            break;
          case 'type':
          case 'course':
          case 'category':
            course = value;
            break;
        }
      }
    }

    // Remove Obsidian-specific blocks
    bodyText = bodyText.replaceAll(RegExp(r'```button[\s\S]*?```'), '');
    bodyText = bodyText.replaceAll(RegExp(r'```dataview[\s\S]*?```'), '');
    bodyText = bodyText.replaceAll(RegExp(r'<%[\s\S]*?%>'), '');

    // Extract title from # Header if not in frontmatter
    if (title == null || title.isEmpty) {
      final h1Match =
      RegExp(r'^#\s+(.+)$', multiLine: true).firstMatch(bodyText);
      if (h1Match != null) {
        title = _cleanMarkdown(h1Match.group(1) ?? 'Untitled Recipe');
        bodyText = bodyText.replaceFirst(h1Match.group(0)!, '').trim();
      }
    }

    // Extract image from Obsidian ![[...]] or standard ![](...) syntax
    if (imageUrl == null) {
      final obsidianImg = RegExp(r'!\[\[([^\]]+)\]\]').firstMatch(bodyText);
      final standardImg =
      RegExp(r'!\[[^\]]*\]\(([^)]+)\)').firstMatch(bodyText);
      imageUrl = obsidianImg?.group(1) ?? standardImg?.group(1);
    }

    // Parse body as structured text to get ingredients/instructions
    final parsed = _parseStructuredText(bodyText);

    return ImportedRecipe(
      title: title ?? parsed.title,
      description: description ?? parsed.description,
      imageUrl: imageUrl ?? parsed.imageUrl,
      prepTimeMinutes: prepTime ?? parsed.prepTimeMinutes,
      cookTimeMinutes: cookTime ?? parsed.cookTimeMinutes,
      servings: servings?.toString() ?? parsed.servings,
      ingredients: parsed.ingredients,
      instructions: parsed.instructions,
      notes: parsed.notes,
      tags: tags,
      cuisine: cuisine,
      suggestedCourse: course ?? parsed.suggestedCourse,
      suggestedCategory: parsed.suggestedCategory,
    );
  }

  // ========== OCR TEXT CLEANUP ==========

  static String _cleanOcrText(String text) {
    final lines = text.split('\n');
    final filtered = <String>[];

    for (var line in lines) {
      var trimmed = line.trim();

      if (trimmed.length < 3) continue;

      // Skip phone status bar patterns
      if (RegExp(r'^\d{1,2}:\d{2}(\s*(AM|PM))?(\s|$)', caseSensitive: false)
          .hasMatch(trimmed)) {
        continue;
      }

      // Skip signal/battery/carrier indicators
      if (RegExp(r'^(5G|LTE|4G|WiFi|AT&T|T-Mobile|Verizon|Sprint|Vodafone|\d+%$)',
          caseSensitive: false)
          .hasMatch(trimmed)) {
        continue;
      }

      // Skip lines that are just numbers or symbols
      if (RegExp(r'^[\d\W]+$').hasMatch(trimmed)) continue;

      // Skip "image not found" type messages
      if (trimmed.toLowerCase().contains('could not be found')) continue;

      // Skip breadcrumb-like paths
      if (RegExp(r'^[A-Za-z]+\s*/\.{3}').hasMatch(trimmed)) continue;

      // Skip navigation UI elements
      if (RegExp(r'^(Home|Back|Menu|Search|Share|Save|Print|Rate|Jump to Recipe|Pin It|Tweet|Email)',
          caseSensitive: false)
          .hasMatch(trimmed) &&
          trimmed.length < 30) {
        continue;
      }

      // Skip social media buttons/counters
      if (RegExp(r'^\d+\s*(shares?|likes?|comments?|pins?|saves?|views?|followers?)$',
          caseSensitive: false)
          .hasMatch(trimmed)) {
        continue;
      }

      // Skip cookie/GDPR banners
      if (RegExp(r'(cookie|consent|privacy policy|accept all|we use cookies)',
          caseSensitive: false)
          .hasMatch(trimmed) &&
          trimmed.length < 100) {
        continue;
      }

      // Skip footer/copyright lines
      if (RegExp(r'^(©|\(c\)|Copyright|All rights reserved|Powered by)',
          caseSensitive: false)
          .hasMatch(trimmed)) {
        continue;
      }

      // Skip ad indicators
      if (RegExp(r'^(Advertisement|Sponsored|Ad\b|ADVERTISEMENT)',
          caseSensitive: false)
          .hasMatch(trimmed) &&
          trimmed.length < 30) {
        continue;
      }

      // Skip watermarks (often short capitalized text)
      if (trimmed.length < 20 && trimmed == trimmed.toUpperCase() &&
          !RegExp(r'\d').hasMatch(trimmed) && trimmed.length > 3) {
        // All caps short text without numbers — likely a watermark or header
        // But keep measurement units and section headers
        if (!RegExp(r'^(INGREDIENTS?|INSTRUCTIONS?|DIRECTIONS?|METHOD|NOTES?|SERVES?)$',
            caseSensitive: false)
            .hasMatch(trimmed)) {
          continue;
        }
      }

      // Remove leading garbage characters
      trimmed = trimmed.replaceFirst(RegExp(r'^[^\w\d]+'), '');

      if (trimmed.isNotEmpty) {
        filtered.add(trimmed);
      }
    }

    return filtered.join('\n');
  }

  // ========== AGGRESSIVE FALLBACK ==========

  static ImportedRecipe _aggressiveParse(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    List<String> ingredients = [];
    List<String> instructions = [];

    for (final line in lines) {
      final cleaned = _cleanListMarkers(_cleanMarkdown(line));
      if (cleaned.isEmpty || cleaned.length < 3) continue;

      final iScore = _ingredientScore(cleaned);
      final sScore = _instructionScore(cleaned);

      if (iScore > sScore && iScore > 0.3) {
        if (_isValidIngredient(cleaned)) ingredients.add(cleaned);
      } else if (sScore > 0.3) {
        if (_isValidInstruction(cleaned)) instructions.add(cleaned);
      }
    }

    return ImportedRecipe(
      title: 'Imported Recipe',
      ingredients: ingredients,
      instructions: instructions,
    );
  }

  // ========== SECTION DETECTION ==========

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

  // ========== SCORING ==========

  static bool _looksLikeIngredient(String text) =>
      _ingredientScore(text) > 0.4;

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

  static bool _looksLikeInstruction(String text) =>
      _instructionScore(text) > 0.4;

  static double _instructionScore(String text) {
    double score = 0;
    final lower = text.toLowerCase();

    if (text.length > 40) score += 0.2;
    if (text.length > 80) score += 0.1;
    if (text.length < 15) score -= 0.3;

    if (_containsActionVerb(text)) score += 0.4;
    if (_startsWithActionVerb(lower)) score += 0.3;

    if (RegExp(r'\d+\s*(minutes?|mins?|hours?|hrs?|seconds?|secs?)')
        .hasMatch(lower)) {
      score += 0.2;
    }

    if (RegExp(r'\d+\s*°?\s*[FCfc]').hasMatch(text)) score += 0.2;
    if (text.endsWith('.')) score += 0.1;
    if (RegExp(r'[.;,]\s+[A-Z]').hasMatch(text)) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  // ========== VALIDATION ==========

  static bool _isValidIngredient(String text) {
    if (text.length < 3) return false;
    if (RegExp(r'^\d+$').hasMatch(text)) return false;

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
    if (!text.contains(' ') && text.length < 4) return false;
    if (RegExp(r'^[\d\s\.\,\-\/\(\)]+$').hasMatch(text)) return false;
    if (text.endsWith(':')) return false;
    if (!RegExp(r'[a-zA-Z]').hasMatch(text)) return false;

    return true;
  }

  static bool _isValidInstruction(String text) {
    if (text.length < 10) return false;
    if (RegExp(r'^\d+\.?$').hasMatch(text)) return false;

    final headerWords = [
      'ingredients', 'directions', 'instructions', 'method', 'steps',
      'notes', 'tips', 'recipe', 'servings', 'serves', 'yield',
      'prep time', 'cook time', 'total time', 'nutrition',
    ];
    if (headerWords.contains(text.toLowerCase().trim())) return false;
    if (text.split(' ').length < 3) return false;

    return true;
  }

  static List<String> _cleanIngredients(List<String> raw) {
    return raw.map((s) => s.trim()).where((s) => _isValidIngredient(s)).toList();
  }

  static List<String> _cleanInstructions(List<String> raw) {
    return raw
        .map((s) => s.trim())
        .where((s) => _isValidInstruction(s))
        .toList();
  }

  // ========== COURSE / CATEGORY DETECTION ==========

  static void _detectCourseAndCategory(ImportedRecipe recipe) {
    final allText =
    '${recipe.title} ${recipe.description ?? ''}'.toLowerCase();

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

  // ========== UTILITY HELPERS ==========

  static bool _containsActionVerb(String text) {
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    return words.any(
            (word) => _actionVerbs.contains(word.replaceAll(RegExp(r'[^\w]'), '')));
  }

  static bool _startsWithActionVerb(String text) {
    final firstWord =
    text.split(RegExp(r'\s+'))[0].replaceAll(RegExp(r'[^\w]'), '');
    return _actionVerbs.contains(firstWord);
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
        .replaceAllMapped(
        RegExp(r'\*\*([^*]+)\*\*'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'\*([^*]+)\*'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'__([^_]+)__'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'_([^_]+)_'), (m) => m.group(1) ?? '')
        .replaceAllMapped(
        RegExp(r'\[\[([^\]|]+)(?:\|[^\]]+)?\]\]'), (m) => m.group(1) ?? '')
        .replaceAllMapped(
        RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m.group(1) ?? '')
        .replaceAll(RegExp(r'!\[.*?\][\[(].*?[\])]'), '')
        .trim();
  }

  static String? _cleanHtmlText(String? text) {
    if (text == null) return null;
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static _Metadata? _extractMetadata(String line) {
    String? servings;
    int? prepTime;
    int? cookTime;

    final servingsMatch = RegExp(
        r'(?:serves?|servings?|yields?|makes?|portions?)\s*:?\s*(\d+(?:\s*-\s*\d+)?(?:\s*\w+)?)',
        caseSensitive: false)
        .firstMatch(line);
    if (servingsMatch != null) servings = servingsMatch.group(1);

    final prepMatch = RegExp(
        r'(?:prep(?:aration)?\s*(?:time)?)\s*:?\s*(\d+)\s*(minutes?|mins?|hours?|hrs?)',
        caseSensitive: false)
        .firstMatch(line);
    if (prepMatch != null) {
      final value = int.parse(prepMatch.group(1)!);
      final unit = prepMatch.group(2)!.toLowerCase();
      prepTime = unit.startsWith('h') ? value * 60 : value;
    }

    final cookMatch = RegExp(
        r'(?:cook(?:ing)?\s*(?:time)?)\s*:?\s*(\d+)\s*(minutes?|mins?|hours?|hrs?)',
        caseSensitive: false)
        .firstMatch(line);
    if (cookMatch != null) {
      final value = int.parse(cookMatch.group(1)!);
      final unit = cookMatch.group(2)!.toLowerCase();
      cookTime = unit.startsWith('h') ? value * 60 : value;
    }

    final totalMatch = RegExp(
        r'(?:total\s*(?:time)?|time)\s*:?\s*(\d+)\s*(minutes?|mins?|hours?|hrs?)',
        caseSensitive: false)
        .firstMatch(line);
    if (totalMatch != null && prepTime == null && cookTime == null) {
      final value = int.parse(totalMatch.group(1)!);
      final unit = totalMatch.group(2)!.toLowerCase();
      cookTime = unit.startsWith('h') ? value * 60 : value;
    }

    if (servings != null || prepTime != null || cookTime != null) {
      return _Metadata(
          servings: servings, prepTime: prepTime, cookTime: cookTime);
    }
    return null;
  }

  // ========== JSON / TIME / IMAGE HELPERS ==========

  static bool _looksLikeJson(String text) {
    final trimmed = text.trim();
    return (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'));
  }

  static ImportedRecipe? _tryParseJson(String text) {
    try {
      final json = jsonDecode(text);
      if (json is Map) {
        return _buildRecipeFromJsonMap(json);
      }
    } catch (e) {
      // Try cleaning common JSON artifacts and retry
      try {
        final cleaned = _cleanJsonText(text);
        if (cleaned != text) {
          final json = jsonDecode(cleaned);
          if (json is Map) {
            return _buildRecipeFromJsonMap(json);
          }
        }
      } catch (_) {}
    }
    return null;
  }

  /// Clean common JSON artifacts (trailing commas, comments, etc.)
  static String _cleanJsonText(String text) {
    var s = text.trim();

    // Strip markdown code fences
    if (s.startsWith('```')) {
      final firstNewline = s.indexOf('\n');
      if (firstNewline != -1) s = s.substring(firstNewline + 1);
      if (s.endsWith('```')) s = s.substring(0, s.length - 3);
      s = s.trim();
    }

    // Strip single-line comments (// ...)
    s = s.replaceAll(RegExp(r'//[^\n]*'), '');

    // Strip block comments (/* ... */)
    s = s.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');

    // Remove trailing commas before } or ]
    s = s.replaceAll(RegExp(r',\s*([}\]])'), r'$1');

    // Extract JSON if there's text before/after
    final firstBrace = s.indexOf('{');
    final firstBracket = s.indexOf('[');
    if (firstBrace > 0 || firstBracket > 0) {
      final start = (firstBrace >= 0 && firstBracket >= 0)
          ? (firstBrace < firstBracket ? firstBrace : firstBracket)
          : (firstBrace >= 0 ? firstBrace : firstBracket);
      if (start > 0) {
        s = s.substring(start);
        // Find matching end
        final isArray = s.startsWith('[');
        final endChar = isArray ? ']' : '}';
        final lastEnd = s.lastIndexOf(endChar);
        if (lastEnd > 0) s = s.substring(0, lastEnd + 1);
      }
    }

    // Try replacing single quotes with double quotes as last resort
    // Only if no double quotes exist (to avoid breaking valid JSON)
    if (!s.contains('"') && s.contains("'")) {
      s = s.replaceAll("'", '"');
    }

    return s;
  }

  static ImportedRecipe _buildRecipeFromJsonMap(Map json) {
    return ImportedRecipe(
      title: json['title']?.toString() ??
          json['name']?.toString() ??
          'Imported Recipe',
      description: json['description']?.toString(),
      ingredients: _toStringList(
          json['ingredients'] ?? json['recipeIngredient'] ?? []),
      instructions: _toStringList(json['instructions'] ??
          json['recipeInstructions'] ??
          json['directions'] ??
          json['steps'] ??
          []),
      servings:
      json['servings']?.toString() ?? json['yield']?.toString(),
      prepTimeMinutes:
      _parseTimeValue(json['prepTime'] ?? json['prep_time']),
      cookTimeMinutes:
      _parseTimeValue(json['cookTime'] ?? json['cook_time']),
      imageUrl: json['image']?.toString() ?? json['imageUrl']?.toString(),
      sourceUrl: json['url']?.toString() ?? json['sourceUrl']?.toString(),
    );
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
      return data
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
    }
    return [];
  }

  static List<String> _extractJsonInstructions(dynamic data) {
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
        for (var i in item) {
          recurse(i);
        }
      }
    }

    recurse(data);
    return results;
  }

  static int? _parseTimeValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final isoMatch =
      RegExp(r'P(?:T)?(?:(\d+)H)?(?:(\d+)M)?').firstMatch(value);
      if (isoMatch != null) {
        final h = int.tryParse(isoMatch.group(1) ?? '0') ?? 0;
        final m = int.tryParse(isoMatch.group(2) ?? '0') ?? 0;
        if (h > 0 || m > 0) return h * 60 + m;
      }
      return int.tryParse(value);
    }
    return null;
  }

  static int? _parseTimeString(String time) {
    int totalMinutes = 0;
    final hourMatch = RegExp(r'(\d+)\s*(?:hours?|hr|h)\b', caseSensitive: false)
        .firstMatch(time);
    if (hourMatch != null) {
      totalMinutes += (int.tryParse(hourMatch.group(1)!) ?? 0) * 60;
    }
    final minMatch = RegExp(r'(\d+)\s*(?:minutes?|mins?|m)\b',
        caseSensitive: false)
        .firstMatch(time);
    if (minMatch != null) {
      totalMinutes += int.tryParse(minMatch.group(1)!) ?? 0;
    }
    if (totalMinutes == 0) {
      final numMatch = RegExp(r'(\d+)').firstMatch(time);
      if (numMatch != null) {
        totalMinutes = int.tryParse(numMatch.group(1)!) ?? 0;
      }
    }
    return totalMinutes > 0 ? totalMinutes : null;
  }

  static String? _extractImage(dynamic image) {
    if (image is String) return image;
    if (image is List && image.isNotEmpty) return _extractImage(image.first);
    if (image is Map) return image['url']?.toString();
    return null;
  }

  static String? _extractServings(dynamic data) {
    if (data == null) return null;
    if (data is int) return '$data servings';
    if (data is String) return data;
    if (data is List && data.isNotEmpty) return data.first.toString();
    return null;
  }
}

// ========== SUPPORTING TYPES ==========

enum _Section { unknown, ingredients, instructions, notes, description }

enum _Platform { instagram, tiktok, pinterest, youtube, squarespace, generic }

class _Metadata {
  final String? servings;
  final int? prepTime;
  final int? cookTime;
  _Metadata({this.servings, this.prepTime, this.cookTime});
}