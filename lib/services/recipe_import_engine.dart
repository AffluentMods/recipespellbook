import 'dart:convert';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'web_page_decoder.dart';
import '../models/imported_recipe.dart';

/// Consolidated recipe import engine.
/// Replaces both RecipeParser and RecipeScraperService.
///
/// Handles: URL scraping (JSON-LD, microdata, CSS selectors, generic HTML),
/// text parsing (structured, markdown, Obsidian/YAML frontmatter),
/// OCR text cleanup, file parsing (JSON, MD, TXT), and bulk HTML import.
class RecipeImportEngine {
  // Full Chrome UA — incomplete UAs (e.g. just Mozilla/5.0... AppleWebKit) get
  // flagged by Cloudflare/Akamai as bots and return 4xx/5xx codes.
  static const _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36';

  // Platform-specific user agents (some sites block generic crawlers)
  static const _mobileUserAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';

  /// Standard browser-like headers to bypass basic bot detection.
  /// Used as the base for all default fetches; specific platforms can override.
  static const _browserHeaders = {
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
    // Only advertise gzip — Dart's http client auto-decompresses gzip but NOT
    // brotli/deflate. Advertising 'br' makes CDNs (e.g. Instagram) return a
    // brotli body we can't decode, which crashed the parser with
    // "Unexpected extension byte".
    'Accept-Encoding': 'gzip',
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'none',
    'Sec-Fetch-User': '?1',
    'Upgrade-Insecure-Requests': '1',
  };

  // ========== PLATFORM DETECTION ==========

  static _Platform _detectPlatform(String url) {
    final host = _hostOf(url);
    if (_isOnSite(host, 'instagram.com') || _isOnSite(host, 'instagr.am')) return _Platform.instagram;
    if (_isOnSite(host, 'tiktok.com')) return _Platform.tiktok;
    if (_isPinterestHost(host)) return _Platform.pinterest;
    if (_isOnSite(host, 'youtube.com') || _isOnSite(host, 'youtu.be')) return _Platform.youtube;
    if (_isOnSite(host, 'squarespace.com') || host.contains('.squarespace.')) return _Platform.squarespace;
    return _Platform.generic;
  }

  /// The host of [url] in lower case, or '' when it has none. Platforms are
  /// told apart by host, so a blog whose address merely mentions Instagram or
  /// ends in "pin.it" is not mistaken for one.
  static String _hostOf(String url) =>
      Uri.tryParse(url.trim())?.host.toLowerCase() ?? '';

  static bool _isOnSite(String host, String site) =>
      host == site || host.endsWith('.$site');

  /// Pinterest runs one site per country (pinterest.co.uk, pinterest.de,
  /// br.pinterest.com) next to pinterest.com and its pin.it short links.
  static bool _isPinterestHost(String host) =>
      host == 'pin.it' ||
      RegExp(r'(?:^|\.)pinterest\.[a-z]{2,3}(?:\.[a-z]{2})?$').hasMatch(host);

  /// Normalize URL for better scraping (strip tracking, fix mobile URLs, etc.)
  static String _normalizeUrl(String url) {
    var normalized = url.trim();

    // Fix missing scheme
    if (!normalized.startsWith('http')) {
      normalized = 'https://$normalized';
    }

    // Instagram: convert /reel/ and /p/ share URLs to clean form
    if (_isOnSite(_hostOf(normalized), 'instagram.com')) {
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

  /// Decode an HTTP body as text.
  ///
  /// `http`'s `response.body` getter decodes the bytes as Latin-1 (ISO-8859-1)
  /// whenever the server omits `charset` from `Content-Type`, which most
  /// recipe sites do, turning UTF-8 accents into mojibake ("é" into "Ã©").
  /// [WebPageDecoder] reads UTF-8 first and then the charset the page
  /// declares, and never throws on a malformed or compressed body.
  static String _decodeBody(http.Response resp) => _decodePage(resp).text;

  static DecodedPage _decodePage(http.Response resp) => WebPageDecoder.decode(
      resp.bodyBytes,
      contentType: resp.headers['content-type']);

  /// Fetch a URL with browser-like headers. If the response is rejected
  /// (4xx/5xx, often WAF bot detection like 403, 451, 455, 503), retry once
  /// with the mobile UA which more sites accept by default.
  static Future<http.Response> _fetchWithFallback(String url, _Platform platform) async {
    final primaryHeaders = _headersForPlatform(platform);
    var resp = await http
        .get(Uri.parse(url), headers: primaryHeaders)
        .timeout(const Duration(seconds: 20));

    // If primary succeeded or got a "real" non-bot error (404, 410), don't retry.
    if (resp.statusCode == 200) return resp;
    if (resp.statusCode == 404 || resp.statusCode == 410) return resp;

    // Already used the mobile UA — nothing else to try.
    final usedMobile = primaryHeaders['User-Agent'] == _mobileUserAgent;
    if (usedMobile) return resp;

    // Retry with mobile UA + browser headers. Sites blocking desktop crawlers
    // often let mobile Safari through.
    try {
      final fallbackResp = await http.get(
        Uri.parse(url),
        headers: {
          ..._browserHeaders,
          'User-Agent': _mobileUserAgent,
        },
      ).timeout(const Duration(seconds: 20));
      if (fallbackResp.statusCode == 200) return fallbackResp;
      // Return whichever has a body
      return fallbackResp.bodyBytes.isNotEmpty ? fallbackResp : resp;
    } catch (_) {
      return resp;
    }
  }

  /// Get appropriate headers for a given platform.
  /// All variants include the standard browser-like headers so bot-detection
  /// WAFs (Cloudflare/Akamai/etc.) accept the request.
  static Map<String, String> _headersForPlatform(_Platform platform) {
    switch (platform) {
      case _Platform.instagram:
      case _Platform.tiktok:
      case _Platform.pinterest:
        // Social media often serves better meta tags to mobile user agents
        return {
          ..._browserHeaders,
          'User-Agent': _mobileUserAgent,
        };
      default:
        return {
          ..._browserHeaders,
          'User-Agent': _userAgent,
        };
    }
  }

  // ========== SECTION HEADER PATTERNS ==========

  // A header is told by its words alone. Heading marks, emphasis, an emoji in
  // front and the colon at the end are taken off first, see [_undressed],
  // so "## Ingredients", "**Ingredients:**" and "🛒 INGREDIENTS" all arrive
  // here as "ingredients". The words are known in the languages the app is
  // translated into: a recipe is pasted or photographed in whatever language
  // its cook reads.

  // What may follow the word for "ingredients": a bracket ("(serves 4)",
  // "（2人分）"), whom or what the list is for ("for the filling", "für 4
  // Personen") or a name after a dash.
  static const _headerTail = r'(?:\s*[(（](?<bracket>[^()（）]{0,40})[)）]'
      r'|\s+(?<whom>for|für|fuer|pour|para|per|voor|dla|на)\s+(?<what>[^.!?。]{1,40})'
      r'|\s*[-–\u2014/]\s*(?<name>[^.!?。]{1,30}))?';

  static final _ingredientHeader = RegExp(
      r'^(?:(?:the\s+)?ingredients?(?:\s+(?:list|needed))?'
      r'|zutaten(?:liste)?|ingredientes|ingr[ée]dients|ingredienti|ingredi[ëe]nten|sk[łl]adniki'
      r'|ингредиенты|材料|食材|用料|原料|配料|재료)'
      '$_headerTail'
      r'$'
      r"|^(?:(?:what|things)\s+)?you(?:['’]?ll|\s+will)?\s+need$"
      r'|^shopping\s+list$',
      caseSensitive: false);

  static final _methodHeader = RegExp(
      r'^(?:(?:(?:cooking|baking|preparation|recipe|step[-\s]by[-\s]step)\s+)?(?:instructions?|directions?|method|steps?|procedure)'
      r'|preparation(?:\s+(?:method|steps?))?|method\s+of\s+preparation|step[-\s]by[-\s]step'
      r'|how\s+to\s+(?:make|prepare|cook)(?:\s+(?:it|this))?|to\s+make|to\s+prepare|what\s+to\s+do'
      // German, Spanish, French, Italian, Portuguese, Dutch and Polish.
      r"|zubereitung|anleitung|zubereitungsschritte|so\s+geht['’]?s|so\s+wird['’]?s\s+gemacht"
      r'|preparaci[óo]n|elaboraci[óo]n|instrucciones|pasos|procedimiento|modo\s+de\s+preparaci[óo]n|m[ée]todo'
      r'|pr[ée]paration|[ée]tapes|m[ée]thode|r[ée]alisation'
      r'|preparazione|procedimento|istruzioni|metodo'
      r'|modo\s+de\s+prepar(?:o|ar)|modo\s+de\s+fazer|preparo|prepara[çc][ãa]o|instru[çc][õo]es'
      r'|bereiding(?:swijze)?|instructies|werkwijze|methode'
      r'|przygotowanie|spos[óo]b\s+przygotowania|wykonanie'
      // Russian, Japanese, Chinese and Korean.
      r'|приготовление|способ\s+приготовления|как\s+готовить'
      r'|作り方|作りかた|手順|調理方法|做法|步骤|步驟|制作方法|製作方法|만드는\s*(?:법|방법)|조리법|조리\s*방법)$',
      caseSensitive: false);

  static final _notesHeader = RegExp(
      r"^(?:(?:(?:recipe|kitchen|chef['’]?s?|cook['’]?s?|baker['’]?s?)\s+)?(?:notes?|tips?|hints?|variations?)"
      r'(?:\s*(?:and|&)\s*(?:notes?|tips?|variations?))?'
      // What a recipe card prints after the method, or before the
      // ingredients, is neither a step nor an ingredient: "Nutrition",
      // "Nutrition Facts (per serving)", "Equipment".
      r'|nutrition(?:al)?(?:\s+(?:facts|info(?:rmation)?|values?))?(?:\s*\([^)]{0,30}\))?|equipment(?:\s+needed)?'
      r'|macros?\s+per\s+serving'
      r'|storage|storing|to\s+store|to\s+freeze|make[-\s]ahead|substitutions?|serving\s+suggestions?'
      r'|notizen|hinweise?|tipps?|anmerkung(?:en)?|notas?|consejos|remarques?|astuces?|conseils?|consigli'
      r'|dicas?|observa[çc][õo]es|notities|opmerkingen|uwagi|wskaz[óo]wki'
      r'|примечани[ея]|советы?|заметки|メモ|コツ|ポイント|备注|備註|小贴士|小貼士|提示|메모|팁)$',
      caseSensitive: false);

  // Heading marks and whatever else dresses a header: rules, brackets, a
  // bullet. Not a digit, so "1. Ingredients" stays a list item.
  static final _headerDress = RegExp(r'^[\s#=~\-–\u2014_|\[\]<>*•·]+|[\s=~\-–\u2014_|\[\]<>*•·]+$');
  static final _colonAtEnd = RegExp(r'\s*[:：]+$');

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
    final host = _hostOf(url);
    return const ['vm.tiktok.com', 'vt.tiktok.com', 'pin.it', 'bit.ly', 'tinyurl.com']
        .any((site) => _isOnSite(host, site));
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

      final json = jsonDecode(_decodeBody(response)) as Map<String, dynamic>;
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
    final rawCaption = json['title']?.toString();
    if (rawCaption == null || rawCaption.length < 30) return null;
    // Hashtags and "follow for more" lines would otherwise end up as steps.
    final caption = _withoutCaptionNoise(rawCaption);
    if (caption.length < 30) return null;

    final authorName = json['author_name']?.toString() ?? '';

    // Try structured text parsing on the caption
    final parsed = _parseStructuredText(_withMethodHeading(caption));
    if (parsed.ingredients.isNotEmpty || parsed.instructions.isNotEmpty) {
      // Clean up the title (caption's first line or author-based)
      final cleanTitle = _captionTitle(caption)
          ?? _extractSocialTitle(caption)
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
    // so the user can at least see the text
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
    final title = _pinTitle(json['title']?.toString() ?? 'Pinterest Recipe');
    final description = _pinDescription(json['description']?.toString());

    // Pinterest oEmbed sometimes includes the original source URL in the description
    // or we can try to extract it from the pin page later
    String? originalSourceUrl;
    if (description != null) {
      final urlMatch = RegExp(r'https?://[^\s<>"{}|\\^`\[\]]+', caseSensitive: false)
          .firstMatch(description);
      if (urlMatch != null) {
        // A link at the end of a sentence drags its full stop along.
        final link = urlMatch.group(0)!;
        var end = link.length;
        while (end > 0 && '.,;:!?)'.contains(link[end - 1])) {
          end--;
        }
        final found = link.substring(0, end);
        // Only follow if it's not a Pinterest URL (avoid loops)
        if (!_isPinterestHost(_hostOf(found))) {
          originalSourceUrl = found;
        }
      }
    }

    // Whatever the description holds, the link to the original recipe goes
    // back with it: the caller tries that page first, and it is the better
    // source whenever it can be read.
    if (description != null && description.length > 50) {
      final parsed = _parseStructuredText(description);
      if (parsed.ingredients.isNotEmpty || parsed.instructions.isNotEmpty) {
        parsed.title = _cleanSocialTitle(title);
        parsed.imageUrl = thumbnail;
        parsed.sourceUrl = originalSourceUrl ?? url;
        return parsed;
      }

      final result = _parseSocialCaption(description, title, thumbnail);
      if (result != null) {
        result.sourceUrl = originalSourceUrl ?? url;
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
    // The pin page names the site it was saved from in its meta tags. Those
    // are there even when the page body is only a script.
    for (final key in ['og:see_also', 'pinterestapp:source']) {
      final source = _getMetaContent(document, key);
      if (source != null && _isFollowableSource(source)) return source;
    }

    // Look for the "Visit" or source link
    for (final selector in [
      'a[data-test-id="pin-action-link"]',
      'a[rel="nofollow noopener"][target="_blank"]',
      'a.linkModuleActionButton',
    ]) {
      final el = document.querySelector(selector);
      final href = el?.attributes['href'];
      if (href == null) continue;
      // Pinterest often wraps URLs in a redirect: /redirect/?url=...
      if (href.contains('/redirect/') && href.contains('url=')) {
        final redirectUrl = Uri.tryParse(href)?.queryParameters['url'];
        if (redirectUrl != null && _isFollowableSource(redirectUrl)) return redirectUrl;
      }
      if (_isFollowableSource(href)) return href;
    }
    return null;
  }

  /// A public web address outside Pinterest. A link back into Pinterest
  /// would only loop, and a pin must not be able to send the app to the
  /// device's own network: bare names, IP addresses and local names are not
  /// followed.
  static bool _isFollowableSource(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;
    final host = uri.host.toLowerCase();
    // A public name ends in a top-level domain, and those start with a
    // letter. An IP address does not, however it is written.
    if (!RegExp(r'\.[a-z][a-z0-9-]*$').hasMatch(host)) return false;
    if (host.endsWith('.local') || host.endsWith('.internal') || host.endsWith('.localhost')) {
      return false;
    }
    return !_isPinterestHost(host);
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
    final (ImportedRecipe?, String?) result;
    try {
      result = await _importFromUrl(url, isRecursiveCall);
    } catch (e) {
      throw Exception('Failed to parse recipe: $e');
    }
    // The engine's own failures are already one sentence for the person
    // importing, so they go out as they are instead of being wrapped like
    // the unexpected errors above.
    final (recipe, failure) = result;
    if (recipe == null) throw Exception(failure ?? _noRecipeFound);
    return recipe;
  }

  static const _noRecipeFound = 'No recipe found on that page.';

  /// Does the import. Returns the recipe, or the sentence that tells the
  /// person why there is none.
  static Future<(ImportedRecipe?, String?)> _importFromUrl(String url, bool isRecursiveCall) async {
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
          if (sourceUrl != null && _isFollowableSource(sourceUrl)) {
            try {
              final sourceRecipe = await parseFromUrl(sourceUrl, isRecursiveCall: true);
              if (sourceRecipe.ingredients.isNotEmpty) {
                // Use the full recipe from the source, but keep Pinterest image as fallback
                sourceRecipe.imageUrl ??= oembedRecipe.imageUrl;
                sourceRecipe.sourceUrl = normalized; // Keep Pinterest as the share source
                return (sourceRecipe, null);
              }
            } catch (_) {
              // The source could not be read. Use the oEmbed data.
            }
          }
        }

        // For TikTok or Pinterest without a followable source: use oEmbed data directly
        if (oembedRecipe.ingredients.isNotEmpty || oembedRecipe.instructions.isNotEmpty) {
          oembedRecipe.sourceUrl = normalized;
          _detectCourseAndCategory(oembedRecipe);
          return (oembedRecipe, null);
        }
        // oEmbed returned a shell (title + image only). Fall through to HTML scraping.
      }
    }

    // 3. Standard HTML scraping pipeline.
    // Try the platform's preferred headers first; if the upstream rejects us
    // (often a WAF returning 4xx/5xx), retry with mobile UA before giving up.
    final response = await _fetchWithFallback(normalized, platform);
    if (response.statusCode != 200) return (null, _statusFailure(response.statusCode));

    final notAPage = _notAWebPage(response);
    if (notAPage != null) return (null, notAPage);

    final page = _decodePage(response);
    // Set for a page in a charset the app has no table for. Its ASCII can
    // still be read, and recipe data is often nothing else (other letters
    // written as \u escapes), so such a page is only given up on when the
    // recipe it yields holds text that could not be read, or it yields none.
    final unreadable = page.unreadableCharset == null
        ? null
        : 'That page uses a text encoding (${page.unreadableCharset}) this app cannot read.';

    if (_isPlainText(response, page.text)) {
      final recipe = _recipeFromPlainText(page.text);
      if (recipe == null) return (null, unreadable ?? _noRecipeFound);
      if (unreadable != null && _hasUnreadableText(recipe)) return (null, unreadable);
      recipe.sourceUrl = normalized;
      recipe.imageUrl = _absoluteUrl(recipe.imageUrl, normalized);
      // A course the data names stands. The guess only fills in for none.
      final ownCourse = recipe.suggestedCourse;
      _detectCourseAndCategory(recipe);
      recipe.suggestedCourse = ownCourse ?? recipe.suggestedCourse;
      return (recipe, null);
    }

    final document = html_parser.parse(page.text);

    // Standard extraction pipeline
    final marked = _tryPageMarkup(document);
    // The course the site itself files the recipe under, when it says.
    final siteCourse = marked?.suggestedCourse;
    var recipe = marked;

    // Platform-specific fallbacks (social media extracts from meta tags)
    if (!_hasContent(recipe)) {
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
            sourceRecipe.imageUrl ??= _absoluteUrl(_findBestImage(document), normalized);
            sourceRecipe.sourceUrl = normalized;
            return (sourceRecipe, null);
          }
        } catch (_) {}
      }
    }

    // An ordinary site with no recipe markup, or with only half of it: read
    // the post itself. Not for the social platforms, whose page body is
    // nothing but scripts.
    final ordinarySite = platform == _Platform.generic || platform == _Platform.squarespace;
    if (ordinarySite && !_isComplete(recipe)) {
      recipe = _fillMissing(recipe, _tryGenericHtml(document));
    }

    if (recipe == null || !_hasContent(recipe)) {
      return (null, unreadable ?? _noRecipeFailure(document, platform));
    }
    if (unreadable != null && _hasUnreadableText(recipe)) return (null, unreadable);

    recipe.sourceUrl = normalized;
    recipe.imageUrl = _absoluteUrl(recipe.imageUrl, normalized) ??
        _absoluteUrl(_findBestImage(document), normalized);
    _detectCourseAndCategory(recipe);
    if (siteCourse != null && identical(recipe, marked)) recipe.suggestedCourse = siteCourse;

    return (recipe, null);
  }

  /// Give the user a clue what went wrong rather than a raw status code.
  static String _statusFailure(int code) {
    if (code == 403 || code == 401 || code == 451 || code == 455) {
      return 'The site blocked our request. Try copying the recipe text and using "Paste" instead.';
    } else if (code == 404 || code == 410) {
      return 'Page not found. Check the URL.';
    } else if (code == 429) {
      return 'The site is rate-limiting us. Try again in a minute.';
    } else if (code >= 500 && code < 600) {
      return 'The site is having issues right now (HTTP $code). Try again later.';
    }
    return 'Failed to fetch URL (HTTP $code)';
  }

  /// Why a response cannot be a recipe page (it is a PDF, a photo, an
  /// archive, or far too large), or null when it is worth reading.
  ///
  /// Decided by what the bytes are, not by a list of allowed content types:
  /// plenty of recipe pages are served with a wrong one.
  static String? _notAWebPage(http.Response response) {
    final bytes = response.bodyBytes;
    final type = (response.headers['content-type'] ?? '').toLowerCase();
    bool startsWith(List<int> magic) {
      if (bytes.length < magic.length) return false;
      for (var i = 0; i < magic.length; i++) {
        if (bytes[i] != magic[i]) return false;
      }
      return true;
    }

    String? kind;
    if (type.startsWith('application/pdf') || startsWith(const [0x25, 0x50, 0x44, 0x46, 0x2D])) {
      kind = 'a PDF';
    } else if (type.startsWith('image/')) {
      kind = 'an image';
    } else if (type.startsWith('video/')) {
      kind = 'a video';
    } else if (type.startsWith('audio/')) {
      kind = 'an audio file';
    } else if (type.startsWith('application/zip') || startsWith(const [0x50, 0x4B, 0x03, 0x04])) {
      kind = 'a ZIP file';
    } else if (bytes.take(1024).contains(0)) {
      // Text never holds a zero byte. Photos, videos and documents do.
      kind = 'a file';
    }
    if (kind != null) return 'No recipe found because that link is $kind, not a web page.';

    if (bytes.length > 8 * 1024 * 1024) {
      return 'No recipe found because that page is too large to read.';
    }
    return null;
  }

  /// What the decoder leaves where a character was in a charset it has no
  /// table for.
  static const _unreadableMark = '\uFFFD';

  /// Whether [recipe] holds text the decoder could not read.
  static bool _hasUnreadableText(ImportedRecipe recipe) => [
        recipe.title,
        recipe.description,
        recipe.notes,
        recipe.servings,
        recipe.cuisine,
        ...recipe.ingredients,
        ...recipe.instructions,
        ...?recipe.tags,
      ].any((text) => text != null && text.contains(_unreadableMark));

  /// What to tell the person when a page was read and held no recipe.
  static String _noRecipeFailure(Document document, _Platform platform) {
    if (_isLoginWall(document)) {
      return 'That page needs a login, so we could not read the recipe.';
    }
    if (platform == _Platform.youtube) {
      return "No recipe found in that video's description.";
    }
    return _noRecipeFound;
  }

  /// A login or sign-up form standing where the content should be. Instagram
  /// and Facebook answer visitors without a session this way.
  static bool _isLoginWall(Document document) {
    final title = (document.querySelector('title')?.text ?? '').trim().toLowerCase();
    final ogTitle = (_getMetaContent(document, 'og:title') ?? title).trim().toLowerCase();
    if (title == 'instagram' && ogTitle == 'instagram') return true;
    final description = _getMetaContent(document, 'og:description') ??
        _getMetaContent(document, 'description') ??
        '';
    if (description.toLowerCase().startsWith('create an account or log in')) return true;
    return RegExp(r'^(?:log ?in(?:to)?|sign ?in|sign ?up)\b').hasMatch(title);
  }

  /// A recipe kept as a text or Markdown file (a raw file on GitHub, a .txt
  /// on someone's site) has no tags to read. Its lines are the recipe. The
  /// same goes for a recipe an address answers as JSON.
  static bool _isPlainText(http.Response response, String body) {
    if (_looksLikeJson(body)) return true;
    if (!RegExp(r'<[a-zA-Z!/?]').hasMatch(body)) return true;
    final type = (response.headers['content-type'] ?? '').toLowerCase();
    if (!type.startsWith('text/plain') && !type.contains('markdown')) return false;
    // Some servers send real pages as text/plain. Those are still pages.
    final head = body.length > 2000 ? body.substring(0, 2000) : body;
    return !RegExp(r'<(?:!doctype\s+html|html|head|body)\b', caseSensitive: false).hasMatch(head);
  }

  static ImportedRecipe? _recipeFromPlainText(String text) {
    if (_looksLikeJson(text)) {
      // A recipe in JSON that names its ingredients or steps needs no
      // further proof.
      final json = _decodeJson(text);
      final fromJson = _jsonRecipes(json).firstOrNull;
      // JSON is read as JSON or not at all: as lines of text it would only
      // give a recipe made of brackets and quotes. Text that merely opens
      // and closes with a bracket, as Markdown full of links can, is no JSON
      // and is read as the text it is.
      if (fromJson != null || json != null) return fromJson;
    }

    // A text file has no menus or comments around its recipe, so what reads
    // as its ingredients needs no heading to be believed.
    final recipe = parseFromText(text);
    final lines = text.split('\n').map((line) => line.trim());
    final believable = _readsLikeRecipe(
      recipe,
      ingredientsHeading: true,
      methodHeading: lines.any(_isMethodHeading),
    );
    return believable ? recipe : null;
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

  /// Parse text a person typed or pasted, which may hold several recipes.
  ///
  /// The lines are read as written. None of the clean-up [parseOcrTextMulti]
  /// does for a photo is applied: nothing is trimmed from a line and short
  /// lines, numbers and capitals are kept. Only whole lines of web page
  /// furniture are left out (menus, share buttons, cookie banners), because
  /// recipes are often pasted straight from a page. JSON and front matter are
  /// read as [parseFromText] reads them.
  static List<ImportedRecipe> parseTextMulti(String text) {
    text = _withoutCodeFence(text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\t', ' '));

    if (_looksLikeJson(text)) {
      final fromJson = parseFromFileBulk(text, 'pasted.json');
      if (fromJson.isNotEmpty) return fromJson;
    }

    if (_splitFrontMatter(text) != null) {
      return [_parseObsidianMarkdown(text)];
    }

    final written = _linesOf(text).where((l) => !_isPageFurniture(l.trim())).join('\n');
    return _parseMulti(written, scanned: false);
  }

  /// Text pasted out of a chat often arrives inside a code fence. Take the
  /// fence off so its first line is not read as the title.
  static String _withoutCodeFence(String text) {
    final trimmed = text.trim();
    final firstBreak = trimmed.indexOf('\n');
    if (!trimmed.startsWith('```') || !trimmed.endsWith('```') || firstBreak == -1) return text;
    return trimmed.substring(firstBreak + 1, trimmed.length - 3).trimRight();
  }

  /// Parse from a file's content, using filename extension for format hints.
  static ImportedRecipe parseFromFile(String content, String filename) {
    final ext = filename.toLowerCase().split('.').last;

    switch (ext) {
      case 'json':
      case 'crumb': // Crouton
      // Try app-specific JSON formats first, then generic
        return _tryAppJson(content)
            ?? _tryParseJson(content)
            ?? ImportedRecipe(title: 'Imported Recipe', ingredients: [], instructions: []);
      case 'md':
      case 'markdown':
        final text = content
            .replaceAll('\r\n', '\n')
            .replaceAll('\r', '\n')
            .replaceAll('\t', ' ');
        // A note is named after its file unless it says otherwise.
        final fileTitle = _fileTitle(filename);
        // Use Obsidian parser when YAML frontmatter is present
        if (_splitFrontMatter(text) != null) {
          return _parseObsidianMarkdown(text, fileTitle: fileTitle);
        }
        return _parseMarkdown(text, fileTitle: fileTitle);
      case 'mmf':
      case 'mk':
      // MealMaster format — return first recipe found
        final recipes = _parseMealMaster(content);
        return recipes.isNotEmpty
            ? recipes.first
            : ImportedRecipe(title: 'Imported Recipe', ingredients: [], instructions: []);
      case 'mxp':
      // MasterCook — delegate to file importers
        final mxpRecipes = _parseMasterCookMxp(content);
        return mxpRecipes.isNotEmpty
            ? mxpRecipes.first
            : ImportedRecipe(title: 'Imported Recipe', ingredients: [], instructions: []);
      case 'txt':
      default:
      // Try MealMaster detection on .txt files too
        if (_looksLikeMealMaster(content)) {
          final recipes = _parseMealMaster(content);
          if (recipes.isNotEmpty) return recipes.first;
        }
        // Try MasterCook detection
        if (_looksLikeMasterCook(content)) {
          final recipes = _parseMasterCookMxp(content);
          if (recipes.isNotEmpty) return recipes.first;
        }
        return _namedByFile(parseFromText(content), filename);
    }
  }

  /// Parse a file that may contain MULTIPLE recipes (MealMaster, RecipeKeeper HTML, etc.)
  /// Returns all found recipes. Used by bulk import flow.
  static List<ImportedRecipe> parseFromFileBulk(String content, String filename) {
    final ext = filename.toLowerCase().split('.').last;

    switch (ext) {
      case 'json':
      case 'crumb': // Crouton
      // JSON arrays can contain multiple recipes
        final appRecipes = _tryAppJsonBulk(content);
        if (appRecipes.isNotEmpty) return appRecipes;
        final single = _tryParseJson(content);
        return single != null && (single.ingredients.isNotEmpty || single.instructions.isNotEmpty) ? [single] : [];
      case 'html':
      case 'htm':
        return parseFromHtml(content);
      case 'mmf':
      case 'mk':
        return _parseMealMaster(content);
      case 'mxp':
        return _parseMasterCookMxp(content);
      case 'txt':
        // A file that only resembles one of these formats yields nothing
        // there and is read as plain text.
        if (_looksLikeMealMaster(content)) {
          final recipes = _parseMealMaster(content);
          if (recipes.isNotEmpty) return recipes;
        }
        if (_looksLikeMasterCook(content)) {
          final recipes = _parseMasterCookMxp(content);
          if (recipes.isNotEmpty) return recipes;
        }
        final recipe = _namedByFile(parseFromText(content), filename);
        return (recipe.ingredients.isNotEmpty || recipe.instructions.isNotEmpty) ? [recipe] : [];
      default:
        final recipe = parseFromFile(content, filename);
        return (recipe.ingredients.isNotEmpty || recipe.instructions.isNotEmpty) ? [recipe] : [];
    }
  }

  // The banner MasterCook writes over each recipe it exports, and the
  // heading of its ingredient table.
  static final _masterCookBanner = RegExp(r'\*\s*Exported\s+from\s+MasterCook', caseSensitive: false);
  static final _masterCookTable =
      RegExp(r'^[ \t]*Amount\s+Measure\s+Ingredient\s+--\s+Preparation Method', multiLine: true, caseSensitive: false);

  /// Check if text looks like MasterCook format. Only what MasterCook itself
  /// writes counts: "Serving Size: 8" stands in many a plain recipe and on
  /// every nutrition label.
  static bool _looksLikeMasterCook(String content) {
    return _masterCookBanner.hasMatch(content) || _masterCookTable.hasMatch(content);
  }

  /// Parse MasterCook .mxp format text.
  /// Delegates to the MasterCook importer for the actual parsing logic.
  static List<ImportedRecipe> _parseMasterCookMxp(String content) {
    // Inline MasterCook parsing (same logic as MasterCookImporter)
    // to avoid circular dependency with file_importers package.
    final recipes = <ImportedRecipe>[];

    final blocks = content.split(RegExp(
      r'(?:^\s*\*\s*EXPORTED\s+FROM\s+MASTERCOOK\s*\*\s*$|'
      r'^-\s*-\s*-\s*-\s*-\s*-\s*-\s*-\s*-.*$)',
      multiLine: true,
      caseSensitive: false,
    ));

    for (final block in blocks) {
      final trimmed = block.trim();
      if (trimmed.isEmpty || trimmed.length < 20) continue;

      String? title;
      String? servings;
      List<String>? tags;
      final ingredients = <String>[];
      final instructions = <String>[];

      final lines = trimmed.split('\n');
      var inInstructions = false;

      for (final rawLine in lines) {
        final line = rawLine.trim();
        if (line.isEmpty) {
          if (ingredients.isNotEmpty && !inInstructions) inInstructions = true;
          continue;
        }

        // Header fields
        if (line.toLowerCase().startsWith('recipe by')) continue;
        if (line.toLowerCase().startsWith('serving size') && line.contains(':')) {
          servings = RegExp(r':\s*(\d+)').firstMatch(line)?.group(1);
          continue;
        }
        if (line.toLowerCase().startsWith('categories') && line.contains(':')) {
          tags = line.substring(line.indexOf(':') + 1).trim()
              .split(RegExp(r'\s{2,}'))
              .map((c) => c.trim())
              .where((c) => c.isNotEmpty)
              .toList();
          continue;
        }
        if (line.toLowerCase().contains('amount') &&
            line.toLowerCase().contains('measure')) {
          continue;
        }
        if (RegExp(r'^[-\s]+$').hasMatch(line) && line.contains('---')) continue;
        if (line.startsWith('*')) continue;

        // Title
        if (title == null && !inInstructions && ingredients.isEmpty) {
          title = line;
          continue;
        }

        // Ingredients vs instructions
        if (!inInstructions) {
          if (RegExp(r'^\s*[\d½¼¾⅓⅔⅛]').hasMatch(rawLine) ||
              rawLine.startsWith('     ')) {
            ingredients.add(line);
          } else {
            inInstructions = true;
            instructions.add(line);
          }
        } else {
          instructions.add(line);
        }
      }

      if (title != null && (ingredients.isNotEmpty || instructions.isNotEmpty)) {
        recipes.add(ImportedRecipe(
          title: title,
          ingredients: ingredients,
          instructions: instructions,
          servings: servings,
          tags: tags,
          sourceApp: 'mastercook',
        ));
      }
    }

    return recipes;
  }

  /// Parse OCR text from a multi-recipe document (e.g. cookbook PDF).
  ///
  /// The text is split where a new recipe shows itself after the method of
  /// the one before: by the header of its ingredient list, by a line that
  /// numbers it ("Recipe 12") or by its nutrition line ("Macros per serving
  /// X cal Yg protein..."). The printed lines of a wrapped step or
  /// ingredient are put back together.
  ///
  /// Optional [pageImagePaths] and [pageStartLines] map each recipe to a
  /// cover image extracted from the PDF page where the recipe starts.
  /// [pageImageScores] (parallel to [pageImagePaths]) lets us pick the best
  /// photo when a recipe spans multiple pages. Pages with `null` paths had
  /// no extractable photo — we look at the next 1-2 pages in that case.
  ///
  /// If only one recipe is detected, returns a single-element list.
  static List<ImportedRecipe> parseOcrTextMulti(
    String text, {
    List<String?>? pageImagePaths,
    List<int>? pageStartLines,
    List<double>? pageImageScores,
  }) {
    return _parseMulti(
      text,
      scanned: true,
      pageImagePaths: pageImagePaths,
      pageStartLines: pageStartLines,
      pageImageScores: pageImageScores,
    );
  }

  /// Splits [text] where one recipe ends and the next begins, and parses each
  /// part. [scanned] text is cleaned of screen clutter first and gets a
  /// quality score. Typed text is read as written.
  ///
  /// A recipe shows itself by the header of its ingredient list, by a line
  /// that numbers it ("Recipe 12") or by its nutrition line. A new recipe
  /// begins at the first of these that comes after a method, and takes the
  /// title and the facts printed above it along.
  static List<ImportedRecipe> _parseMulti(
    String text, {
    required bool scanned,
    List<String?>? pageImagePaths,
    List<int>? pageStartLines,
    List<double>? pageImageScores,
  }) {
    // The whole text as one recipe, when there is no reason to split it.
    ImportedRecipe whole() => scanned ? parseOcrText(text) : parseFromText(text);

    // Every line, the blank ones too: each recipe is cut out with its
    // paragraphs intact.
    final allLines = scanned ? _cleanOcrText(text).split('\n') : _linesOf(text);
    // Where each line with something on it stands in the text.
    final at = [
      for (var i = 0; i < allLines.length; i++)
        if (allLines[i].trim().isNotEmpty) i,
    ];
    final lines = [for (final i in at) allLines[i].trim()];
    // Typed lines still carry their Markdown and list markers, which would
    // hide "**Recipe 2**" and "- Serves 4" from the patterns below.
    final plain = scanned ? lines : lines.map(_withoutMarkup).toList();
    final sections = [for (final line in lines) _detectSectionHeader(line)];

    // ── Phase 1: the lines a recipe shows itself by ──
    bool isMacros(int i) => _macrosLine.hasMatch(plain[i]);
    bool isNumber(int i) => _recipeNumberLine.hasMatch(plain[i]);
    // The header of the whole list. "Ingredients for the filling:" heads one
    // group of a list and opens no recipe.
    bool isListHeader(int i) => sections[i] == _Section.ingredients && _groupInHeader(lines[i]) == null;
    // For each line, the header of a method nearest above it, or -1.
    final methodAbove = List<int>.filled(lines.length + 1, -1);
    for (var i = 0; i < lines.length; i++) {
      methodAbove[i + 1] = sections[i] == _Section.instructions ? i : methodAbove[i];
    }
    bool methodBetween(int from, int to) => methodAbove[to] > from;

    final named = [
      for (var i = 0; i < lines.length; i++)
        if (isNumber(i) || isListHeader(i)) i,
    ];
    // A nutrition line counts where it stands right over the list of its
    // recipe, with nothing but facts between. Under a method it closes the
    // recipe above, and the title of the next one comes after it. Where no
    // list has a header the nutrition lines are all there is to go by.
    bool factsBetween(int from, int to) {
      if (to - from > 6) return false;
      for (var i = from + 1; i < to; i++) {
        if (!isMacros(i) && _extractMetadata(lines[i]) == null) return false;
      }
      return true;
    }

    final marks = <int>[];
    var namedBelow = named.length;
    for (var i = 0; i < lines.length; i++) {
      if (namedBelow > 0 && named[named.length - namedBelow] == i) {
        namedBelow--;
        marks.add(i);
      } else if (isMacros(i)) {
        final next = namedBelow > 0 ? named[named.length - namedBelow] : -1;
        if (named.length < 2 || (next >= 0 && factsBetween(i, next))) marks.add(i);
      }
    }

    // ── Phase 2: one recipe may show itself several times over ──
    //
    // "Recipe 3", a nutrition line and "Ingredients" follow one another at
    // the top of one recipe. The next recipe begins at the first mark that
    // has a method between itself and the mark before it.
    final heads = <int>[];
    var lastMark = -1;
    for (final mark in marks) {
      if (heads.isEmpty || methodBetween(lastMark, mark)) heads.add(mark);
      lastMark = mark;
    }
    // A mark with no method under it opens no recipe of its own.
    if (heads.isNotEmpty && methodAbove[lines.length] < heads.last) heads.removeLast();
    if (heads.length < 2) {
      return [whole()];
    }

    // ── Phase 3: move each boundary up to where its recipe begins ──
    //
    // Above the list stand the facts ("Serves 4", "Prep time: 10 min") and
    // above those the title, perhaps with a line or two of introduction
    // under it. The steps of the recipe before are where the search stops.
    int topOf(int mark, int floor) {
      var top = mark;
      while (top > floor && (isMacros(top - 1) || _extractMetadata(lines[top - 1]) != null)) {
        top--;
      }
      var best = -1;
      var bestScore = -1;
      for (var i = top - 1; i >= floor && i >= top - 8; i--) {
        if (sections[i] != _Section.unknown || _isNumbered(lines[i]) || _readsAsStep(plain[i])) break;
        if (!_titleShaped(plain[i])) continue;
        // A title stands apart, is set in capitals and is short. Of two
        // lines as good as each other the upper one is the title.
        final apart = i == 0 || at[i] - at[i - 1] > 1;
        final score =
            (apart ? 2 : 0) + (_titleCased(plain[i]) ? 2 : 0) + (plain[i].split(_spaces).length <= 6 ? 1 : 0);
        if (score >= bestScore) {
          best = i;
          bestScore = score;
        }
      }
      return best >= 0 ? best : top;
    }

    final boundaries = <int>[];
    for (final head in heads) {
      // The header of the method before, and the first step under it,
      // belong to the recipe before.
      final floor = boundaries.isEmpty ? 0 : methodAbove[head] + 2;
      final top = isNumber(head) || floor > head ? head : topOf(head, floor);
      if (boundaries.isEmpty || top > boundaries.last) boundaries.add(top);
    }

    // ── Phase 4: split text at boundaries and parse each segment ──
    // We track the START line of each segment so we can map back to a PDF page
    // for cover image assignment.
    final segments = <_RecipeSegment>[];
    for (var i = 0; i < boundaries.length; i++) {
      final start = boundaries[i];
      final end = i + 1 < boundaries.length ? at[boundaries[i + 1]] : allLines.length;
      final segment = allLines.sublist(at[start], end).join('\n');
      if (segment.trim().length > 60) {
        segments.add(_RecipeSegment(text: segment, startLine: start));
      }
    }

    if (segments.length < 2) {
      return [whole()];
    }

    // ── Phase 5: parse each segment, recover titles, and assign cover image ──
    final recipes = <ImportedRecipe>[];
    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      try {
        final recipe = _parseStructuredText(seg.text, wrapped: scanned);

        // Skip segments with no real content (e.g. orphaned TOC fragments)
        if (recipe.ingredients.isEmpty && recipe.instructions.isEmpty) continue;

        // Recover title if the parser couldn't figure it out OR latched onto
        // an obviously-wrong line like the macros/ingredients header.
        if (_titleNeedsRecovery(recipe.title)) {
          final recovered = _recoverTitleFromSegment(
              scanned ? seg.text : seg.text.split('\n').map(_withoutMarkup).join('\n'));
          if (recovered != null) {
            recipe.title = recovered;
            // A title printed under the list was read as the end of it,
            // with the introduction that follows the title.
            final inList = recipe.ingredients.indexOf(recovered);
            if (inList > 0 && !recipe.ingredients.skip(inList).any(_startsWithAmount.hasMatch)) {
              final introduction = recipe.ingredients.sublist(inList + 1).join(' ');
              recipe.ingredients.removeRange(inList, recipe.ingredients.length);
              if (introduction.isNotEmpty) recipe.description ??= introduction;
            }
            _detectCourseAndCategory(recipe);
          }
        }

        // Assign cover image: find the PDF page whose line range contains
        // the segment's start line. Cookbook recipes often span multiple pages
        // (text page + photo page), so look across the start page and the
        // next 2 pages — pick the one with the highest extraction score.
        if (pageImagePaths != null && pageStartLines != null && pageImagePaths.length == pageStartLines.length) {
          final startPageIdx = _findPageForLine(seg.startLine, pageStartLines);
          if (startPageIdx != null) {
            String? bestPath;
            double bestScore = -1;
            // Look at start page + next 2 pages, but stop if we hit the next
            // recipe's page (otherwise we'd steal its photo)
            final maxLookahead = (i + 1 < segments.length)
                ? _findPageForLine(segments[i + 1].startLine, pageStartLines) ?? pageImagePaths.length
                : pageImagePaths.length;
            final endPageIdx = (startPageIdx + 3).clamp(0, maxLookahead);
            for (var p = startPageIdx; p < endPageIdx && p < pageImagePaths.length; p++) {
              final path = pageImagePaths[p];
              if (path == null) continue;
              final score = (pageImageScores != null && p < pageImageScores.length)
                  ? pageImageScores[p]
                  : 0.0;
              if (score > bestScore) {
                bestScore = score;
                bestPath = path;
              }
            }
            if (bestPath != null) recipe.imagePath = bestPath;
          }
        }

        if (scanned) {
          recipe.parseConfidence = _scoreParseConfidence(recipe, seg.text);
          recipe.rawOcrText = seg.text;
        }
        recipes.add(recipe);
      } catch (_) {
        continue;
      }
    }

    if (recipes.isEmpty) {
      return [whole()];
    }

    return recipes;
  }

  // A nutrition line: "Macros per serving", "Nutrition facts", "501 calories
  // 40g protein".
  static final _macrosLine = RegExp(
      r'^(?:macros?\s+per\s+serving|nutrition\s*(?:facts|info|per)|\d+\s*(?:cal|kcal)(?:ories)?\b)',
      caseSensitive: false);
  // "Recipe 12", "Recipe 3: Lemon Loaf".
  static final _recipeNumberLine = RegExp(r'^recipe\s+\d+', caseSensitive: false);

  // Words a title leaves in lower case: "Mac and Cheese", "Coq au Vin".
  static const _smallWords = {
    'a', 'an', 'and', 'as', 'at', 'au', 'aux', 'by', 'con', 'de', 'del', 'di', 'du', 'e', 'en', 'et', 'for', 'from',
    'in', 'la', 'le', 'of', 'on', 'or', 'the', 'to', 'with', 'y',
  };
  static final _upperOrDigitStart = RegExp(r'^[\p{Lu}\p{N}]', unicode: true);

  /// True when every word of [text] that counts opens with a capital or a
  /// figure: "Garlic Butter Shrimp", "GUACAMOLE", "Mac and Cheese".
  static bool _titleCased(String text) {
    final words = text.split(_spaces).map((w) => w.replaceFirst(_leadingSymbols, '')).where((w) => w.isNotEmpty);
    var counted = 0;
    for (final word in words) {
      if (counted > 0 && _smallWords.contains(word.toLowerCase())) continue;
      if (!_upperOrDigitStart.hasMatch(word)) return false;
      counted++;
    }
    return counted > 0;
  }

  /// True when [line] has the shape of a recipe's name: short, opening with
  /// a capital or a figure, with no full stop at its end. A fact, an
  /// ingredient and a short order ("Serve warm") have other shapes.
  static bool _titleShaped(String line) {
    if (line.length < 2 || line.length > 60 || !_hasLetter(line)) return false;
    if (_lowerStart.hasMatch(line) || RegExp(r'[.,:;!?]$').hasMatch(line)) return false;
    if (','.allMatches(line).length >= 2 || _recipeCounter.hasMatch(line)) return false;
    if (_readsAsAmountLine(line) || _extractMetadata(line) != null) return false;
    return !_startsWithActionVerb(line.toLowerCase()) || _titleCased(line);
  }

  /// A typed line without its heading marks, list marker and emphasis.
  static String _withoutMarkup(String line) =>
      _cleanMarkdown(_cleanListMarkers(line.trim().replaceFirst(RegExp(r'^#{1,6}\s*'), '')));

  /// Public version: returns true if the title looks like a parser default
  /// or clearly a non-title line (macros header, ingredient line, etc.).
  /// UI code can use this to decide whether to substitute a fallback title.
  static bool isTitleSuspicious(String title) => _titleNeedsRecovery(title);

  /// Returns true if the parser's auto-picked title looks wrong (empty, default,
  /// or clearly a section header / numeric / measurement line). Used to decide
  /// whether to run the segment-based title recovery.
  static bool _titleNeedsRecovery(String title) {
    final t = title.trim();
    if (t.isEmpty || t == 'Untitled Recipe' || t == 'Imported Recipe') return true;

    final lower = t.toLowerCase();
    // Macros / nutrition / serving header lines
    if (RegExp(r'^macros?\s+per\s+serving').hasMatch(lower)) return true;
    if (RegExp(r'^nutrition\s+(facts|info|per)').hasMatch(lower)) return true;
    if (RegExp(r'^\d+\s*(cal|kcal)(ories)?\b').hasMatch(lower)) return true;

    // Ingredients/instructions section headers
    if (RegExp(r'^ingredients?\s*[\(:]').hasMatch(lower)) return true;
    if (RegExp(r'^(how\s+to\s+make|instructions?|method|directions?|steps?|preparation)\s*[:\s]*$').hasMatch(lower)) return true;

    // Yields/serves/makes
    if (RegExp(r'^(serves?|yield[s]?|makes|servings?)\s*[:\s\d]').hasMatch(lower)) return true;

    // Time lines
    if (RegExp(r'^(prep|cook|total|active|cooking)\s+time\s*:').hasMatch(lower)) return true;

    // Looks like an ingredient line (starts with a measurement)
    if (RegExp(r'^\d+\s*(g|ml|oz|lb|lbs|tbsp|tsp|cup|cups|kg|tablespoon|teaspoon|cloves?)\b', caseSensitive: false).hasMatch(t)) return true;

    // Pure number (page number)
    if (RegExp(r'^\d+\s*$').hasMatch(t)) return true;

    return false;
  }

  /// Given a line index and the per-page line offsets, return the index of
  /// the page that contains that line. Uses simple binary search.
  static int? _findPageForLine(int lineIdx, List<int> pageStartLines) {
    if (pageStartLines.isEmpty) return null;
    // Find the largest pageStartLines[i] <= lineIdx
    int lo = 0, hi = pageStartLines.length - 1;
    int result = 0;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (pageStartLines[mid] <= lineIdx) {
        result = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return result;
  }

  /// Try to recover a recipe title from a multi-recipe segment.
  /// Uses several heuristics: line right before "How to make"/etc., short
  /// title-cased line near the top, line between Ingredients and How-to.
  ///
  /// Strategy: collect ALL candidate lines that look title-shaped, then pick
  /// the one that scores best — shorter, more title-case, fewer descriptive
  /// markers. Single-pass-and-take-first picks descriptions too often.
  static String? _recoverTitleFromSegment(String segment) {
    final lines = segment.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    bool looksLikeTitle(String s) {
      // Real cookbook titles are 3-50 chars (most are 15-35).
      // Anything longer is almost certainly a description.
      if (s.isEmpty || s.length > 50 || s.length < 3) return false;
      // Don't blanket-reject leading digits — "5 Ingredient Cookies",
      // "20-Minute Pasta", "3-Hour Pulled Pork" are valid titles. But reject
      // pure numbers (page) and ingredient measurements (handled below).
      // Reject sentence-style punctuation at end
      if (RegExp(r'[.,:!?;]$').hasMatch(s)) return false;
      // Reject lines with multiple commas — descriptions
      if (','.allMatches(s).length >= 2) return false;
      // Section headers
      if (RegExp(r'^(ingredients?|how to make|macros|how to|method|instructions?|directions?|steps?|preparation|prep time|cook time|total time|serves?|yields?|makes|note[s]?|tip[s]?|nutrition)', caseSensitive: false).hasMatch(s)) return false;
      if (_detectSectionHeader(s) != _Section.unknown) return false;
      // Description-opener phrases — strong signal it's not a title
      if (RegExp(r'^(one\s+of|a\s+(popular|simple|classic|delicious|quick|healthy|new|tasty|fresh|favorite)|an\s+|the\s+(most|best|easiest|tastiest|perfect)|if\s+you|when\s+you|truly|made\s+with|packed\s+with|perfect\s+for|great\s+for)\b', caseSensitive: false).hasMatch(s)) return false;
      // Ingredient-quantity lines
      if (RegExp(r'^\d+\s*(g|ml|oz|tbsp|tsp|cup|cups|kg|lb|lbs|tablespoon|teaspoon|cloves?)\b', caseSensitive: false).hasMatch(s)) return false;
      // Mostly numbers/punctuation. Letters of every alphabet count.
      final letterCount = _anyLetter.allMatches(s).length;
      if (letterCount < s.length * 0.5) return false;
      // URLs / pure numbers (page numbers)
      if (s.contains('://') || s.contains('www.')) return false;
      if (RegExp(r'^\d+\s*$').hasMatch(s)) return false;
      return true;
    }

    /// Score a candidate title — higher is better. Used to pick the best
    /// among multiple title-shaped lines.
    int scoreCandidate(String s) {
      int score = 0;
      // Prefer 15-35 chars (most cookbook titles); penalize longer
      final len = s.length;
      if (len >= 15 && len <= 35) {
        score += 30;
      } else if (len >= 10 && len <= 45) {
        score += 20;
      } else {
        score += 10;
      }

      // Shorter is generally better (within reason)
      score += (50 - len).clamp(0, 50);

      // Title-case words: count words where first letter is uppercase
      final words = s.split(RegExp(r'\s+')).where((w) => w.length > 1).toList();
      if (words.isEmpty) return 0;
      final titleCaseWords = words.where((w) {
        final first = w.codeUnitAt(0);
        return first >= 0x41 && first <= 0x5A; // A-Z
      }).length;
      final titleCaseRatio = titleCaseWords / words.length;
      // Strong title-case (most words capitalized) = much higher score
      if (titleCaseRatio >= 0.75) {
        score += 40;
      } else if (titleCaseRatio >= 0.5) score += 20;

      // Word count: 2-5 words is ideal for a title
      if (words.length >= 2 && words.length <= 5) {
        score += 20;
      } else if (words.length >= 6 && words.length <= 7) {
        score += 5;
      }

      return score;
    }

    /// Find the best-scoring candidate in a range of lines (inclusive start, exclusive end).
    String? bestInRange(int start, int end) {
      String? best;
      int bestScore = -1;
      for (var i = start; i < end && i < lines.length; i++) {
        if (i < 0) continue;
        final line = lines[i];
        if (!looksLikeTitle(line)) continue;
        final score = scoreCandidate(line);
        if (score > bestScore) {
          bestScore = score;
          best = line;
        }
      }
      return best;
    }

    // Strategy A: best-scoring candidate in 8 lines BEFORE "How to make"
    final howToIdx = lines.indexWhere((l) => _detectSectionHeader(l) == _Section.instructions);
    if (howToIdx > 0) {
      final result = bestInRange(howToIdx - 8, howToIdx);
      if (result != null) return result;
    }

    // Strategy B: best candidate between Ingredients and How-to
    final ingIdx = lines.indexWhere((l) => _detectSectionHeader(l) == _Section.ingredients);
    if (ingIdx >= 0 && howToIdx > ingIdx) {
      final result = bestInRange(ingIdx + 1, howToIdx);
      if (result != null) return result;
    }

    // Strategy C: best candidate near the start of the segment (first 12 lines,
    // skipping the macros line)
    final macrosIdx = lines.indexWhere((l) => RegExp(r'^macros?\s+per\s+serving', caseSensitive: false).hasMatch(l));
    final startFrom = macrosIdx >= 0 ? macrosIdx + 1 : 0;
    final result = bestInRange(startFrom, startFrom + 12);
    if (result != null) return result;

    return null;
  }

  /// Parse OCR text with extra cleanup for camera/scan artifacts.
  /// Returns recipe with confidence scoring for quality assessment.
  static ImportedRecipe parseOcrText(String text) {
    final cleaned = _cleanOcrText(text);
    final recipe = _parseStructuredText(cleaned, wrapped: true);

    // Score parse confidence
    final confidence = _scoreParseConfidence(recipe, cleaned);
    recipe.parseConfidence = confidence;
    recipe.rawOcrText = text;

    return recipe;
  }

  /// Score parse confidence from 0.0 to 1.0 based on quality signals.
  static double _scoreParseConfidence(ImportedRecipe recipe, String cleanedText) {
    double score = 0.0;

    // Section headers found (+0.2): the text has clear structure. A header
    // counts in whatever language it is written.
    final headers = {for (final line in cleanedText.split('\n')) _detectSectionHeader(line)};
    if (headers.contains(_Section.ingredients)) score += 0.1;
    if (headers.contains(_Section.instructions)) score += 0.1;

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

    // How much of the text ended up in the two lists (+0.25). Measured in
    // characters: the printed lines of a wrapped step are one entry now.
    final total = cleanedText.replaceAll(_spaces, '').length;
    var classified = 0;
    for (final line in [...recipe.ingredients, ...recipe.instructions]) {
      classified += line.replaceAll(_spaces, '').length;
    }
    if (total > 0) {
      final classifyRatio = (classified / total).clamp(0.0, 1.0);
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
  /// Tries app-specific formats → JSON-LD → microdata → CSS selectors → the
  /// text of the page itself.
  static List<ImportedRecipe> parseFromHtml(String html) {
    final document = html_parser.parse(html);

    // 0. Try app-specific HTML formats (RecipeKeeper, CopyMeThat, etc.)
    final appRecipes = _tryAppSpecificHtml(document, html);
    if (appRecipes.isNotEmpty) return appRecipes;

    // 1. Try JSON-LD (can contain multiple recipes)
    var recipes = _jsonLdRecipes(document).where(_hasContent).toList();

    // 2. Try single extraction (microdata, selectors, then the post itself)
    if (recipes.isEmpty) {
      var single = _tryPageMarkup(document);
      if (!_isComplete(single)) {
        single = _fillMissing(single, _tryGenericHtml(document));
      }
      if (single != null && _hasContent(single)) recipes = [single];
    }

    // A file has no address to resolve a relative image against, and an
    // image that cannot be downloaded only shows up as a failed download.
    for (final recipe in recipes) {
      recipe.imageUrl = _absoluteUrl(recipe.imageUrl);
    }
    return recipes;
  }

  // ========== WEB SCRAPING ==========

  static bool _hasContent(ImportedRecipe? recipe) =>
      recipe != null &&
      (recipe.ingredients.isNotEmpty || recipe.instructions.isNotEmpty);

  static bool _isComplete(ImportedRecipe? recipe) =>
      recipe != null &&
      recipe.ingredients.isNotEmpty &&
      recipe.instructions.isNotEmpty;

  /// What the page's own markup says about its recipe: JSON-LD, then
  /// microdata, then the classes recipe plugins use. A later source only
  /// supplies what the earlier ones lack, so a page that marks up its
  /// ingredients one way and its steps another still gives a whole recipe.
  static ImportedRecipe? _tryPageMarkup(Document document) {
    var recipe = _tryJsonLd(document);
    if (!_isComplete(recipe)) {
      recipe = _fillMissing(recipe, _tryMicrodata(document));
    }
    if (!_isComplete(recipe)) {
      // Half a recipe is only completed from markup that is surely about it.
      // Any other list on the page may belong to something else.
      recipe = _fillMissing(recipe,
          _tryCommonSelectors(document, pluginsOnly: _hasContent(recipe)));
    }
    return recipe;
  }

  /// Completes [recipe] from [other], a second reading of the same page: the
  /// ingredients or steps it lacks, and the details it did not find.
  static ImportedRecipe? _fillMissing(ImportedRecipe? recipe, ImportedRecipe? other) {
    if (recipe == null) return other;
    if (other == null) return recipe;
    if (recipe.ingredients.isEmpty) recipe.ingredients = other.ingredients;
    if (recipe.instructions.isEmpty) recipe.instructions = other.instructions;
    if (recipe.title == 'Imported Recipe') recipe.title = other.title;
    recipe.description ??= other.description;
    recipe.imageUrl ??= other.imageUrl;
    recipe.servings ??= other.servings;
    recipe.prepTimeMinutes ??= other.prepTimeMinutes;
    recipe.cookTimeMinutes ??= other.cookTimeMinutes;
    return recipe;
  }

  static ImportedRecipe? _tryJsonLd(Document document) {
    final recipes = _jsonLdRecipes(document);
    if (recipes.isEmpty) return null;
    // A page can carry a bare Recipe entry (a teaser, a related post) next to
    // the full one, so prefer the first that has something to cook.
    return recipes.firstWhere(_hasContent, orElse: () => recipes.first);
  }

  /// Every Recipe entry in the page's JSON-LD blocks, in page order.
  static List<ImportedRecipe> _jsonLdRecipes(Document document) {
    final recipes = <ImportedRecipe>[];
    final scripts =
        document.querySelectorAll('script[type="application/ld+json"]');

    for (final script in scripts) {
      final entries = <Map<String, dynamic>>[];
      _collectJsonLdRecipes(_decodeJsonLd(script.text), entries, 0);
      for (final entry in entries) {
        try {
          recipes.add(_recipeFromJsonLd(entry));
        } catch (_) {
          // One malformed entry must not cost the page its other recipes.
        }
      }
    }
    return recipes;
  }

  /// Decodes one JSON-LD block, or returns null when it cannot be read.
  ///
  /// Blocks built by hand or by a shop template are often not quite JSON: a
  /// raw line break or tab inside a string, a backslash before an apostrophe,
  /// a comma before a closing bracket, an HTML comment around the data. Those
  /// are repaired rather than letting the whole recipe go missing without a
  /// word.
  static dynamic _decodeJsonLd(String source) {
    final text = source.trim();
    if (text.isEmpty) return null;
    try {
      return jsonDecode(text);
    } on FormatException {
      try {
        return jsonDecode(_repairJson(text));
      } on FormatException {
        return null;
      }
    }
  }

  static String _repairJson(String block) {
    // Only what lies between the first opening and the last closing bracket
    // is data, which drops a wrapper such as <!-- -->. CDATA markers have
    // brackets of their own, so they are taken out first.
    final source = block.replaceAll(RegExp(r'<!\[CDATA\[|\]\]>'), '');
    final start = source.indexOf(RegExp(r'[{\[]'));
    final end = source.lastIndexOf(RegExp(r'[}\]]'));
    if (start < 0 || end <= start) return source;

    const quote = 0x22, backslash = 0x5C, comma = 0x2C, slash = 0x2F, star = 0x2A;
    final repaired = StringBuffer();
    var inString = false;
    var escaped = false;
    // A comma is only written once it is known what follows it: before a
    // closing bracket it is one too many.
    var commaPending = false;
    for (var i = start; i <= end; i++) {
      final c = source.codeUnitAt(i);
      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (c == backslash) {
          // JSON escapes only a handful of characters. A backslash before any
          // other ("Mom\'s", from a template that escapes apostrophes) is one
          // too many and is dropped.
          final next = i < end ? source[i + 1] : '';
          if (next.isEmpty || !r'"\/bfnrtu'.contains(next)) continue;
          escaped = true;
        } else if (c == quote) {
          inString = false;
        } else if (c < 0x20) {
          // JSON allows no raw control character inside a string. A line
          // break and a tab stay what they are; a carriage return is the
          // other half of a line break and is dropped.
          if (c == 0x09) {
            repaired.write(r'\t');
          } else if (c != 0x0D) {
            repaired.write(c == 0x0A ? r'\n' : ' ');
          }
          continue;
        }
      } else if (c == comma) {
        commaPending = true;
        continue;
      } else if (c == slash && i < end && source.codeUnitAt(i + 1) == slash) {
        // A comment, which JSON does not have and files edited by hand do.
        // It runs to the end of its line.
        final lineEnd = source.indexOf('\n', i);
        i = lineEnd < 0 || lineEnd > end ? end : lineEnd - 1;
        continue;
      } else if (c == slash && i < end && source.codeUnitAt(i + 1) == star) {
        final close = source.indexOf('*/', i + 2);
        i = close < 0 || close > end ? end : close + 1;
        continue;
      } else if (c > 0x20) {
        if (commaPending && c != 0x7D && c != 0x5D) repaired.writeCharCode(comma);
        commaPending = false;
        inString = c == quote;
      }
      repaired.writeCharCode(c);
    }
    return repaired.toString();
  }

  /// Finds Recipe entries wherever a site nests them: at the top, in a list,
  /// under "@graph", as the "mainEntity" of the page, or as the items of an
  /// ItemList when one page holds several recipes.
  static void _collectJsonLdRecipes(
      dynamic node, List<Map<String, dynamic>> found, int depth,
      {bool inItemList = false}) {
    if (depth > 6) return;
    if (node is List) {
      for (final item in node) {
        _collectJsonLdRecipes(item, found, depth + 1, inItemList: inItemList);
      }
    } else if (node is Map<String, dynamic>) {
      if (_isRecipeType(node['@type'])) {
        // An ItemList mostly points at recipes on other pages, by name and
        // link. Only an entry that carries its recipe belongs to this page.
        final carriesRecipe =
            node['recipeIngredient'] != null || node['recipeInstructions'] != null;
        if (!inItemList || carriesRecipe) found.add(node);
      } else {
        for (final key in const ['@graph', 'mainEntity', 'item']) {
          _collectJsonLdRecipes(node[key], found, depth + 1, inItemList: inItemList);
        }
        _collectJsonLdRecipes(node['itemListElement'], found, depth + 1, inItemList: true);
      }
    }
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
    author = _jsonLdText(author);

    // Build notes from author + nutrition
    final nutritionNotes = _nutritionLine(json['nutrition']);
    final notesParts = <String>[];
    if (author != null && author.isNotEmpty) notesParts.add('By $author');
    if (nutritionNotes != null) notesParts.add(nutritionNotes);

    // Extract tags from keywords + recipeCategory
    final categories = _jsonLdNames(json['recipeCategory']);
    final tags = <String>[
      ...categories,
      ..._jsonLdNames(json['keywords']).where((k) => k.length < 40),
    ];

    // The site's own category says which course this is ("Main Course",
    // "Dessert") more reliably than a guess from the title.
    String? siteCourse;
    for (final category in categories) {
      siteCourse ??= mapToCourseId(category);
    }

    final (prepTime, cookTime) = _splitTotalTime(
      _parseTimeValue(json['prepTime']),
      _parseTimeValue(json['cookTime']) ?? _parseTimeValue(json['performTime']),
      _parseTimeValue(json['totalTime']),
    );
    final cuisine = _jsonLdNames(json['recipeCuisine']).join(', ');

    return ImportedRecipe(
      title: _jsonLdText(json['name']) ?? 'Imported Recipe',
      description: _jsonLdText(json['description']),
      imageUrl: _extractImage(json['image']),
      ingredients: _filterIngredientProse(
          _jsonLdLines(json['recipeIngredient'] ?? json['ingredients'])),
      instructions: _extractJsonInstructions(json['recipeInstructions']),
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      servings: _jsonLdText(_extractServings(json['recipeYield'])),
      cuisine: cuisine.isNotEmpty ? cuisine : null,
      tags: tags.isNotEmpty ? tags.toSet().toList() : null,
      suggestedCourse: siteCourse,
      notes: notesParts.isNotEmpty ? notesParts.join('\n') : null,
    );
  }

  /// The nutrition facts of schema.org data as one line for the notes.
  static String? _nutritionLine(dynamic nutrition) {
    if (nutrition is! Map) return null;
    const labels = {
      'calories': 'Calories',
      'proteinContent': 'Protein',
      'carbohydrateContent': 'Carbs',
      'fatContent': 'Fat',
      'fiberContent': 'Fiber',
    };
    final parts = <String>[];
    labels.forEach((key, label) {
      final amount = _jsonLdText(nutrition[key]);
      if (amount != null) parts.add('$label: $amount');
    });
    return parts.isEmpty ? null : 'Nutrition: ${parts.join(' | ')}';
  }

  /// A JSON-LD value as clean text: entities decoded, tags removed, runs of
  /// whitespace collapsed. Null when nothing is left.
  static String? _jsonLdText(dynamic value) {
    if (value is List && value.isNotEmpty) value = value.first;
    if (value is! String && value is! num) return null;
    final text = _cleanHtmlText(_htmlToText(value.toString())) ?? '';
    return text.isEmpty ? null : text;
  }

  /// The names in a field that sites write either as a list or as one comma
  /// separated string (categories, keywords, cuisines).
  static List<String> _jsonLdNames(dynamic value) {
    final names = <String>[];
    for (final item in value is List ? value : [value]) {
      if (item is! String) continue;
      for (final name in (_jsonLdText(item) ?? '').split(',')) {
        if (name.trim().isNotEmpty) names.add(name.trim());
      }
    }
    return names;
  }

  /// The lines of a list field. An entry may itself be HTML holding several.
  static List<String> _jsonLdLines(dynamic data) {
    final lines = <String>[];
    for (final item in _toStringList(data)) {
      for (final line in _htmlToText(item).split('\n')) {
        final clean = _cleanHtmlText(line) ?? '';
        if (clean.isNotEmpty) lines.add(clean);
      }
    }
    return lines;
  }

  static final _markup = RegExp(r'&[#\w]+;|</?[a-zA-Z][^<>]*>');
  static final _anyTag = RegExp(r'</?[a-zA-Z][^<>]*>');
  static final _blockMarkup =
      RegExp(r'<\s*(?:p|br|li|div|tr|h[1-6])\b', caseSensitive: false);

  /// The plain text of a string that may carry HTML, as JSON-LD written by
  /// recipe plugins often does: entities ("&amp;", "&frac12;") are decoded
  /// and tags removed, with a line break wherever a paragraph, a list item
  /// or a <br> ended.
  static String _htmlToText(String value) {
    var text = value;
    // Twice, because some sites escape their HTML a second time ("&amp;amp;",
    // "&lt;p&gt;").
    for (var pass = 0; pass < 2 && _markup.hasMatch(text); pass++) {
      // The HTML parser takes minutes over tens of thousands of tags. No
      // recipe text has that many, so one that does has its tags cut without
      // a tree being built, a line break in place of each that starts a line.
      // Only its entities are then left for the parser.
      if ('<'.allMatches(text).take(2001).length > 2000) {
        text = text
            .replaceAllMapped(
                _anyTag, (tag) => _blockMarkup.matchAsPrefix(tag[0]!) == null ? '' : '\n')
            .replaceAll('<', '&lt;');
      }
      // Without block tags the string's own line breaks are the only ones.
      final keepLines = !_blockMarkup.hasMatch(text);
      text = _blockLines(html_parser.parseFragment(text), keepLines: keepLines)
          .join('\n');
    }
    // "1&frasl;2" decodes to a fraction slash no ingredient parser expects.
    return text.replaceAll('\u00A0', ' ').replaceAll('\u2044', '/');
  }

  /// A site that publishes only a total time, or a total and one of its
  /// parts, still means a recipe that takes that long. The app keeps two
  /// parts, so the missing one is what is left of the total.
  static (int?, int?) _splitTotalTime(int? prep, int? cook, int? total) {
    if (total == null) return (prep, cook);
    if (cook == null) {
      if (prep == null) return (null, total);
      if (total > prep) return (prep, total - prep);
    } else if (prep == null && total > cook) {
      return (total - cook, cook);
    }
    return (prep, cook);
  }

  static bool _isRecipeType(dynamic type) {
    if (type == null) return false;
    return type.toString().toLowerCase().contains('recipe');
  }

  /// Drop "ingredient" lines that are almost certainly prose — tips,
  /// notes, or instructions that some recipe sites stuff into their
  /// recipeIngredient data (e.g. "As the curd cooks, whisk slowly…",
  /// "These bars keep well in the fridge for 4 days…").
  ///
  /// Deliberately CONSERVATIVE so real ingredients are never removed: a
  /// line is only dropped when it is long AND has no leading quantity
  /// AND reads like a sentence. Real ingredients are short and/or start
  /// with a quantity, so they pass through untouched.
  static List<String> _filterIngredientProse(List<String> lines) {
    bool looksLikeProse(String raw) {
      final s = raw.trim();
      if (s.length <= 120) return false; // ingredients are short
      // A leading quantity (digit or vulgar fraction in the first chars)
      // strongly indicates a genuine ingredient.
      final head = s.length >= 24 ? s.substring(0, 24) : s;
      if (RegExp(r'[0-9¼½¾⅓⅔⅛⅜⅝⅞]').hasMatch(head)) return false;
      // Sentence-like punctuation mid-line or a trailing period.
      return RegExp(r'[.!?]\s').hasMatch(s) || s.endsWith('.');
    }
    final filtered = lines.where((l) => !looksLikeProse(l)).toList();
    // Safety net: never let the filter empty out the whole list (in case
    // a recipe genuinely has unusual long ingredient lines). If it would,
    // keep the originals rather than returning nothing.
    return filtered.isEmpty ? lines : filtered;
  }

  static ImportedRecipe? _tryMicrodata(Document document) {
    // A page can mark up related recipes too. The one being imported is the
    // first that lists ingredients or steps.
    final items = document.querySelectorAll('[itemtype*="schema.org/Recipe"]');
    for (final item in items.take(8)) {
      final recipe = _recipeFromMicrodata(item, document);
      if (recipe != null) return recipe;
    }
    return null;
  }

  static ImportedRecipe? _recipeFromMicrodata(Element item, Document document) {
    // "ingredients" is the name the property had before schema.org renamed
    // it. Older recipe plugins still write it.
    final ingredients = <String>[];
    for (final element in _microdataProps(
        item, '[itemprop~="recipeIngredient"], [itemprop~="ingredients"]')) {
      ingredients.addAll(_microdataLines(element));
    }

    final instructions = <String>[];
    final methods = _microdataProps(item, '[itemprop~="recipeInstructions"]');
    for (final element in methods) {
      // Steps marked up one by one each carry their own text.
      final texts = element.querySelectorAll('[itemprop~="text"]');
      if (texts.isNotEmpty) {
        instructions.addAll(texts
            .map((e) => _stepText(_blockLines(e).join(' ')))
            .where((step) => step.isNotEmpty));
        continue;
      }
      // Otherwise a property on its own wraps the whole method, and each of
      // its lines is a step. One of several is one step, unless it holds a
      // list or paragraphs of its own (a section of the method). A line that
      // only numbers the step is left out.
      final lines = _microdataLines(element, everyLine: true)
          .map(_stepText)
          .where((line) => line.isNotEmpty)
          .toList();
      final holdsList =
          methods.length == 1 || element.querySelector('li, p, tr, br') != null;
      if (holdsList) {
        instructions.addAll(lines);
      } else if (lines.isNotEmpty) {
        instructions.add(lines.join(' '));
      }
    }

    if (ingredients.isEmpty && instructions.isEmpty) return null;

    String? first(String name, {bool isTime = false}) {
      for (final element in _microdataProps(item, '[itemprop~="$name"]')) {
        // Times are written for machines in an attribute ("PT15M") and for
        // people in the text ("15 mins"). The attribute is the exact one.
        final exact = isTime
            ? _cleanHtmlText(element.attributes['datetime'] ?? element.attributes['content'])
            : null;
        final value = (exact != null && exact.isNotEmpty) ? exact : _microdataText(element);
        if (value != null) return value;
      }
      return null;
    }

    String? image;
    for (final element in _microdataProps(item, '[itemprop~="image"]')) {
      image = _imageAddress(element) ??
          _imageAddress(element.querySelector('img, [itemprop~="url"], [itemprop~="contentUrl"]'));
      if (image != null) break;
    }

    final (prepTime, cookTime) = _splitTotalTime(
      _parseTimeValue(first('prepTime', isTime: true)),
      _parseTimeValue(first('cookTime', isTime: true)),
      _parseTimeValue(first('totalTime', isTime: true)),
    );

    return ImportedRecipe(
      title: _extractBestTitle(document, recipeItem: item),
      description: first('description'),
      imageUrl: image,
      ingredients: _filterIngredientProse(ingredients),
      instructions: instructions,
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      servings: first('recipeYield') ?? first('yield'),
    );
  }

  /// The elements matching [selector] that describe [item] itself, not an
  /// item nested inside it (its author, a rating, the nutrition block).
  /// When a list and its entries both carry the property, only the list is
  /// returned, so nothing is read twice.
  static List<Element> _microdataProps(Element item, String selector) {
    final found = item.querySelectorAll(selector).toSet();
    bool belongs(Element element) {
      for (var parent = element.parent;
          parent != null && parent != item;
          parent = parent.parent) {
        if (parent.attributes.containsKey('itemscope')) return false;
        if (found.contains(parent)) return false;
      }
      return true;
    }

    return found.where(belongs).toList();
  }

  /// What a microdata property says: its text, or its content attribute when
  /// it is a <meta> with no text.
  static String? _microdataText(Element element) {
    final text = _blockLines(element).join(' ');
    if (text.isNotEmpty) return text;
    final content = _cleanHtmlText(element.attributes['content']) ?? '';
    return content.isEmpty ? null : content;
  }

  /// The lines an ingredient or instruction property holds. Usually one, but
  /// some pages put the property on the whole list.
  ///
  /// An ingredient laid out in blocks of its own (amount, then name) is still
  /// one line, so only list markup splits it. With [everyLine] any block
  /// does.
  static List<String> _microdataLines(Element element, {bool everyLine = false}) {
    final lines = _blockLines(element);
    if (lines.isEmpty) {
      final content = _microdataText(element);
      return content == null ? [] : [content];
    }
    final holdsList = lines.length > 1 &&
        (everyLine || element.querySelector('li, p, tr, br') != null);
    return holdsList ? lines : [lines.join(' ')];
  }

  static String? _microdataName(Element item) {
    for (final element in _microdataProps(item, '[itemprop~="name"]')) {
      final name = _microdataText(element);
      if (name != null) return name;
    }
    return null;
  }

  static ImportedRecipe? _tryCommonSelectors(Document document, {bool pluginsOnly = false}) {
    // Recipe plugins. Their class names mean nothing else, so one list on
    // its own is still part of a recipe.
    const pluginSelectors = [
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
    ];

    // Class names themes and hand-built pages use. These are looser, so a
    // match has to look like a recipe before it is taken for one.
    const themeSelectors = [
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

    List<String> texts(String selector, int minLength, {bool skipLinks = false}) {
      return document
          .querySelectorAll(selector)
          .where((e) => !skipLinks || !_isLinkOnly(e))
          .map((e) => _blockLines(e).join(' '))
          .where((s) => s.length > minLength)
          .toList();
    }

    for (final (ingSelector, instSelector) in pluginSelectors) {
      final ings = texts(ingSelector, 2);
      final insts = texts(instSelector, 5);

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
    if (pluginsOnly) return null;

    for (final (ingSelector, instSelector) in themeSelectors) {
      // "ul li" and "ol li" match every list in a post: related links, a
      // table of contents, a top ten. Lists of links are left out.
      final anyList = ingSelector.endsWith(' ul li');
      final ings = texts(ingSelector, 2, skipLinks: anyList);
      final insts = texts(instSelector, 5, skipLinks: anyList);

      // Steps alone prove nothing here, and ingredients alone only when they
      // are written with amounts. Any-list matches need both.
      if (ings.isEmpty) continue;
      final amounts = ings.where(_amountLed.hasMatch).length >= 2;
      if (anyList ? (insts.isEmpty || !amounts) : (insts.isEmpty && !amounts)) {
        continue;
      }

      return ImportedRecipe(
        title: _extractBestTitle(document),
        ingredients: ings,
        instructions: insts,
      );
    }
    return null;
  }

  /// A list item that is nothing but a link, as in a list of related posts.
  static bool _isLinkOnly(Element item) {
    final links = item.querySelectorAll('a');
    return links.length == 1 &&
        _cleanHtmlText(links.first.text) == _cleanHtmlText(item.text);
  }

  /// Extract the best recipe title from a document
  static String _extractBestTitle(Document document, {Element? recipeItem}) {
    // WPRM title
    final wprm = document.querySelector('.wprm-recipe-name');
    if (wprm != null && wprm.text.trim().isNotEmpty) return wprm.text.trim();

    // Tasty Recipes title
    final tasty = document.querySelector('.tasty-recipes-title');
    if (tasty != null && tasty.text.trim().isNotEmpty) return tasty.text.trim();

    // Mediavine title
    final mv = document.querySelector('.mv-create-title');
    if (mv != null && mv.text.trim().isNotEmpty) return mv.text.trim();

    // Recipe schema name. Only the recipe's own: themes mark every menu entry
    // and the author with itemprop="name" as well.
    final item = recipeItem ??
        document.querySelector('[itemtype*="schema.org/Recipe"]');
    final schema = item == null ? null : _microdataName(item);
    if (schema != null) return schema;

    // og:title (usually cleaner than page <title>)
    final ogTitle = document.querySelector('meta[property="og:title"]')?.attributes['content'];
    if (ogTitle != null && ogTitle.isNotEmpty) return ogTitle;

    // Standard heading. Blog platforms give the post's own title a class, and
    // on older themes the h1 is the name of the site.
    final h1 = document.querySelector('.entry-title, .post-title') ??
        document.querySelector('h1');
    if (h1 != null && h1.text.trim().isNotEmpty) return h1.text.trim();

    // Fallback to <title>
    return document.querySelector('title')?.text.trim() ?? 'Imported Recipe';
  }

  static ImportedRecipe? _tryGenericHtml(Document document) {
    // The post itself where the theme marks it, the whole page last. A page
    // can open with teasers that are articles too, so each is tried in turn.
    final roots = <Node>[
      ...document
          .querySelectorAll(
              'article, main, [role="main"], .entry-content, .post-content, .post-body')
          .take(6),
      if (document.body != null) document.body!,
    ];

    ImportedRecipe? recipe;
    for (final root in roots) {
      final candidate = _recipeFromLines(_blockLines(root));
      if (candidate == null) continue;
      if (_isComplete(candidate)) {
        recipe = candidate;
        break;
      }
      recipe ??= candidate;
    }
    if (recipe == null) return null;

    recipe.title = _extractBestTitle(document);
    recipe.description ??= _getMetaContent(document, 'og:description') ??
        _getMetaContent(document, 'description');
    return recipe;
  }

  /// Reads a recipe out of the visible lines of a page that has no recipe
  /// markup. Returns null when the lines do not read like a recipe.
  static ImportedRecipe? _recipeFromLines(List<String> lines) {
    // The recipe starts at its ingredients heading. A table of contents has
    // that heading too, followed by the next heading rather than ingredients.
    var start = -1;
    for (var i = 0; i + 1 < lines.length; i++) {
      if (_isIngredientsHeading(lines[i]) && !_isRecipeHeading(lines[i + 1])) {
        start = i;
        break;
      }
    }
    // With no heading, at the first line written like an ingredient.
    if (start < 0) start = lines.indexWhere(_measuredLine.hasMatch);
    if (start < 0) return null;

    // It ends where the page turns to other things.
    var end = lines.indexWhere(
        (line) => line.length < 80 && _afterRecipeHeading.hasMatch(line), start);
    if (end < 0) end = lines.length;
    // The text parser knows fewer headings than are recognised here ("How to
    // make banana bread", "Zutaten"), so each goes in under the plain name it
    // does know. A nutrition box is left out, up to the next of them.
    final body = <String>[];
    var inNutritionBox = false;
    for (final line in lines.sublist(start, end)) {
      final heading = _isIngredientsHeading(line)
          ? 'Ingredients'
          : (_isMethodHeading(line) ? 'Instructions' : (_isNotesHeading(line) ? 'Notes' : null));
      if (heading != null) {
        body.add(heading);
        inNutritionBox = false;
      } else if (line.length < 80 && _nutritionHeading.hasMatch(line)) {
        inNutritionBox = true;
      } else if (!inNutritionBox && !(line.length < 200 && _siteFurniture.hasMatch(line))) {
        body.add(line);
      }
    }
    final ingredientsHeading = body.contains('Ingredients');
    final methodHeading = body.contains('Instructions');

    final method = _unheadedMethodStart(body);
    if (method > 0) body.insert(method, 'Instructions');

    // The text parser takes the first line it is given for the title, which
    // would cost the recipe its first ingredient. It gets a stand-in, and the
    // caller sets the real title.
    final recipe = _parseStructuredText(['Recipe', ...body].join('\n'));
    final believable = _readsLikeRecipe(recipe,
        ingredientsHeading: ingredientsHeading, methodHeading: methodHeading);
    if (!believable) return null;
    // Guessed from the stand-in title, so not worth keeping.
    recipe.suggestedCourse = null;
    recipe.suggestedCategory = null;

    // Right above the recipe stand its yield and times, and further up the
    // paragraph that introduces it. The rest up there is the site's own
    // furniture.
    final intro = lines.sublist(0, start);
    final details = _parseStructuredText([
      'Recipe',
      ...intro.skip(intro.length > 12 ? intro.length - 12 : 0).where((line) => line.length < 80),
    ].join('\n'));
    recipe.servings ??= details.servings;
    recipe.prepTimeMinutes ??= details.prepTimeMinutes;
    recipe.cookTimeMinutes ??= details.cookTimeMinutes;
    final opening = intro.where((line) => line.length >= 60 && line.length < 500);
    if (opening.isNotEmpty) recipe.description = opening.first;
    return recipe;
  }

  /// Whether [recipe], read from the plain lines of a page or a text file, is
  /// believable: at least two ingredients written with an amount and a unit,
  /// or, under an ingredients heading of the text's own, a method under its
  /// own heading too or at least two ingredients that open with an amount.
  /// Anything less is a login page, an article or a list of links, and
  /// importing it would hand the person garbage to clean up.
  static bool _readsLikeRecipe(
    ImportedRecipe recipe, {
    required bool ingredientsHeading,
    required bool methodHeading,
  }) {
    if (recipe.ingredients.where(_measuredLine.hasMatch).length >= 2) return true;
    if (!ingredientsHeading) return false;
    if (methodHeading && _isComplete(recipe)) return true;
    return recipe.ingredients.where(_amountLed.hasMatch).length >= 2;
  }

  /// Where the method starts in a recipe that heads its ingredients but not
  /// its method, or -1. That is the first numbered step, or the first line
  /// that reads like a sentence: ingredient lines are short and do not end in
  /// a full stop.
  static int _unheadedMethodStart(List<String> lines) {
    final heading = lines.indexWhere(_isIngredientsHeading);
    if (heading < 0 || lines.any(_isMethodHeading)) return -1;
    // Numbers right under the heading number the ingredients themselves.
    final first = lines.indexWhere((line) => line.isNotEmpty, heading + 1);
    final numberedIngredients = first >= 0 && _listNumber.hasMatch(lines[first]);
    final method = lines.indexWhere(
        (line) =>
            (!numberedIngredients && _numberedStep.hasMatch(line)) ||
            (line.length > 50 && _sentenceStop.hasMatch(line)),
        heading + 2);
    // Sentences under a notes heading are the notes.
    final notes = lines.indexWhere(_isNotesHeading, heading + 1);
    return (notes >= 0 && notes < method) ? -1 : method;
  }

  static final _listNumber = RegExp(r'^\d{1,3}[.)]\s');
  static final _numberedStep = RegExp(
      r'^(?:\d{1,3}[.)]|step \d{1,3}[.:)]?)\s{1,3}\p{L}',
      caseSensitive: false,
      unicode: true);

  // The digits and spaces in the two patterns below are counted, not open
  // ended: they are tried on every line of a page, and a line of a hundred
  // thousand digits must cost no more than a short one.

  /// An ingredient line as recipes write them: an amount and a unit ("2 cups
  /// flour", "250 g butter"), or a fraction ("1/2 onion", "½ lemon").
  static final _measuredLine = RegExp(
      r'^\s{0,8}(?:\d{1,4}\s{0,3}/\s{0,3}\d{1,4}|[½¼¾⅓⅔⅛⅜⅝⅞]|'
      r'\d{1,5}(?:[.,]\d{1,3})?\s{0,3}(?:\d{1,3}/\d{1,3}|[½¼¾⅓⅔⅛⅜⅝⅞])?\s{0,3}(?:-\s{0,3}\d{1,5}\s{0,3})?'
      r'(?:cups?|tbsps?|tbs|tsps?|tablespoons?|teaspoons?|oz|ounces?|lbs?|pounds?|'
      r'g|grams?|kg|ml|l|lit(?:er|re)s?|dl|cloves?|pinch|cans?|sticks?|slices?)\b)',
      caseSensitive: false);

  /// A line that opens with an amount, with or without a unit ("3 eggs").
  /// Proof of an ingredient only where the page says these are ingredients.
  static final _amountLed = RegExp(r'^\s{0,8}[\d½¼¾⅓⅔⅛⅜⅝⅞]');

  // The headings are known in the languages the app itself speaks, as far as
  // those are written in Latin letters.
  static final _ingredientsHeading = RegExp(
      r"^(?:ingredients?|what you(?:['’]?ll)? need|you['’]?ll need|shopping list|"
      r'zutaten|ingredientes|ingrédients|ingredienti|ingrediënten|benodigdheden|składniki)'
      r'(?![\p{L}\p{N}])[^.!?]*$',
      caseSensitive: false,
      unicode: true);
  static final _methodHeading = RegExp(
      r'^(?:instructions?|directions?|method|steps?|preparation|procedure|'
      r'zubereitung|anleitung|preparación|elaboración|instrucciones|pasos|préparation|étapes|'
      r'preparazione|procedimento|istruzioni|bereiding|bereidingswijze|werkwijze|instructies|'
      r'przygotowanie|sposób przygotowania|wykonanie|modo de preparo|modo de preparação|'
      r'preparo|preparação|instruções|how to make(?![\p{L}\p{N}])[^.!?]*)$',
      caseSensitive: false,
      unicode: true);
  static final _notesHeading = RegExp(
      r"^(?:(?:recipe |chef['’]?s |cook['’]?s )?(?:notes?|tips?|variations?)|"
      r'tipps?|hinweise?|notas|consejos|astuces|conseils|consigli|opmerkingen|uwagi|wskazówki|dicas)$',
      caseSensitive: false,
      unicode: true);
  static final _nutritionHeading = RegExp(r'^nutrition\b', caseSensitive: false);

  /// Headings and lines under which a page has left the recipe behind. The
  /// last two are only that when they stand alone, as blogs print them over
  /// their like button and their list of related posts.
  static final _afterRecipeHeading = RegExp(
      r'^(?:(?:you (?:might|may) also (?:like|enjoy|love)|related (?:recipes|posts|articles)|'
      r'more recipes|leave a (?:comment|reply)|comments|\d{1,6} (?:comments?|responses|replies|thoughts)|'
      r'share this|about the author|reader interactions|did you make this|'
      r'posted (?:in|by|on|at|under)|filed under|tagged)\b|(?:tags|categories|labels):|'
      r'(?:like this|related):?$)',
      caseSensitive: false);

  /// Lines a site prints under its content whatever the page is about: a
  /// copyright notice, a bar of links ("Home | About | Contact").
  static final _siteFurniture = RegExp(
      r'^(?:©|copyright\b|all rights reserved\b)|^[^|\d]{1,40}(?:\s\|\s[^|\d]{1,40})+$',
      caseSensitive: false);

  static final _headingDecoration = RegExp(r'^[#*_\s]+|[*_:\s]+$');
  static final _sentenceStop = RegExp(r'[.!?]$');

  /// A heading line without its decoration: Markdown marks, a closing colon.
  static String _headingText(String line) =>
      line.replaceAll(_headingDecoration, '');

  static bool _isIngredientsHeading(String line) =>
      line.length < 60 && _ingredientsHeading.hasMatch(_headingText(line));

  static bool _isMethodHeading(String line) =>
      line.length < 60 && _methodHeading.hasMatch(_headingText(line));

  static bool _isNotesHeading(String line) =>
      line.length < 60 && _notesHeading.hasMatch(_headingText(line));

  static bool _isRecipeHeading(String line) =>
      _isIngredientsHeading(line) || _isMethodHeading(line) || _isNotesHeading(line);

  // Elements whose text is never part of a recipe: code, the furniture
  // around a page, form controls.
  static const _skippedElements = {
    'script', 'style', 'noscript', 'template', 'svg', 'head', 'nav',
    'header', 'footer', 'aside', 'iframe', 'button', 'select', 'textarea',
  };

  // Ids and classes of the usual blocks beside a post that are not the post.
  static const _skippedBlocks = {
    'comments', 'comment-list', 'commentlist', 'comments-area',
    'comment-respond', 'respond', 'sidebar', 'widget-area', 'footer',
    'site-footer',
  };

  static const _blockElements = {
    'p', 'div', 'li', 'ul', 'ol', 'br', 'hr', 'h1', 'h2', 'h3', 'h4', 'h5',
    'h6', 'tr', 'table', 'section', 'article', 'blockquote', 'dl', 'dd', 'dt',
    'pre', 'form', 'main', 'body', 'figure', 'figcaption',
  };

  static final _whitespace = RegExp(r'\s+');
  static final _preformatted = RegExp(r'white-space\s*:\s*pre');

  /// The text under [root], one entry per line as a reader sees them.
  ///
  /// `Element.text` glues "Ingredients" to the first ingredient when a page
  /// has no whitespace between its tags, and includes scripts, menus and
  /// footers. This walk breaks the line wherever a block element starts or
  /// ends and leaves out what is not content. With [keepLines], line breaks
  /// inside the text itself count too.
  static List<String> _blockLines(Node root, {bool keepLines = false}) {
    final text = StringBuffer();
    _writeBlockText(root, text, keepLines, 0);
    return text
        .toString()
        .split('\n')
        // A fraction slash (U+2044) is written as the plain one amounts use.
        .map((line) => line.replaceAll(_whitespace, ' ').replaceAll('\u2044', '/').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  static void _writeBlockText(Node node, StringBuffer text, bool keepLines, int depth) {
    if (node is Text) {
      text.write(keepLines ? node.data : node.data.replaceAll(_whitespace, ' '));
      return;
    }
    // Deeper than any real page nests. Stops a hostile one from overflowing
    // the stack.
    if (depth > 400) return;

    var keep = keepLines;
    var block = false;
    var cell = false;
    if (node is Element) {
      // The node the caller asked for is read whatever it is.
      if (depth > 0 && _isFurnitureElement(node)) return;
      final tag = node.localName;
      block = _blockElements.contains(tag);
      cell = tag == 'td' || tag == 'th';
      // <pre> and pre-wrap styling show their line breaks as written.
      keep = keep ||
          tag == 'pre' ||
          _preformatted.hasMatch(node.attributes['style'] ?? '');
    }

    if (block) text.write('\n');
    Node? previous;
    for (final child in node.nodes) {
      // "1<sup>1</sup>/<sub>2</sub> cups" is one and a half cups. Run
      // together it would read as eleven halves.
      final isFractionAfterWhole = child is Element &&
          child.localName == 'sup' &&
          previous is Text &&
          _endsInDigit.hasMatch(previous.data) &&
          _digitsOnly.hasMatch(child.text);
      if (isFractionAfterWhole) text.write(' ');
      _writeBlockText(child, text, keep, depth + 1);
      previous = child;
    }
    if (block) text.write('\n');
    if (cell) text.write(' ');
  }

  static final _endsInDigit = RegExp(r'\d$');
  static final _digitsOnly = RegExp(r'^\d{1,3}$');

  static bool _isFurnitureElement(Element element) {
    if (_skippedElements.contains(element.localName)) return true;
    if (element.attributes.containsKey('hidden')) return true;
    return _skippedBlocks.contains(element.id) ||
        element.classes.any(_skippedBlocks.contains);
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
    // Without a session Instagram often answers with its login page, whose
    // description is an advert for Instagram and not a caption.
    if (_isLoginWall(document)) return null;

    final description = _getMetaContent(document, 'og:description')
        ?? _getMetaContent(document, 'description');
    final rawTitle = _getMetaContent(document, 'og:title') ?? 'Instagram Recipe';
    final image = _getMetaContent(document, 'og:image');

    // Both tags wrap the caption: og:title in the account's name,
    // og:description in the likes, the account and the date. Either can be
    // cut short, so the longer caption is the one to read.
    final fromTitle = _instagramCaption(rawTitle);
    var caption = description == null
        ? fromTitle
        : _instagramCaption(description) ?? description;
    if (fromTitle != null && (caption == null || fromTitle.length > caption.length)) {
      caption = fromTitle;
    }
    if (caption == null) return null;
    caption = _withoutCaptionNoise(caption);
    if (caption.length < 30) return null;

    // The caption opens with the name of the dish. The account's name in
    // og:title is not it.
    final cleanTitle = _captionTitle(caption)
        ?? _extractSocialTitle(rawTitle)
        ?? _extractSocialTitle(caption)
        ?? _cleanSocialTitle(rawTitle);

    // Try to parse the caption as a recipe
    final parsed = _parseStructuredText(_withMethodHeading(caption));
    if (parsed.ingredients.isEmpty && parsed.instructions.isEmpty) {
      // The caption has no structure. Try splitting on common patterns.
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

    final cleanCaption = _withoutCaptionNoise(caption);
    final parsed = _parseStructuredText(_withMethodHeading(cleanCaption));
    if (parsed.ingredients.isEmpty && parsed.instructions.isEmpty) {
      return _parseSocialCaption(cleanCaption, title, image);
    }
    parsed.title = _cleanSocialTitle(title);
    parsed.imageUrl = image;
    return parsed;
  }

  /// Pinterest: Often has structured data or links to the original recipe
  static ImportedRecipe? _tryPinterest(Document document) {
    // Pinterest sometimes includes recipe schema in their page
    // Also check for the "original source" link which points to the real recipe
    // (canonicalUrl and ogUrl checked by JSON-LD/microdata path)

    // If Pinterest has recipe schema, it's already handled by JSON-LD/microdata
    // This fallback extracts from pin description
    final description = _pinDescription(_getMetaContent(document, 'og:description')
        ?? _getMetaContent(document, 'description'));
    final title = _pinTitle(_getMetaContent(document, 'og:title') ?? 'Pinterest Recipe');
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

  static final _pinDate = RegExp(r'^[A-Z][a-z]{2,8}\.? \d{1,2}, \d{4} - ');
  static final _pinPlaceholder = RegExp(
      r'This Pin was (?:discovered|created) by .{0,120}?your own Pins on Pinterest\.?',
      caseSensitive: false);

  /// A pin's description without what Pinterest adds to it: the date in
  /// front, and the sentence that stands in when the pin has no description
  /// ("This Pin was discovered by ... Discover (and save!) your own Pins on
  /// Pinterest."). Null when nothing of the pin's own is left.
  static String? _pinDescription(String? description) {
    if (description == null) return null;
    final text = description
        .replaceFirst(_pinDate, '')
        .replaceFirst(_pinPlaceholder, '')
        .trim();
    return text.isEmpty ? null : text;
  }

  /// A pin's title without the keywords Pinterest lists behind it ("Lemon
  /// Bars | Recipe | Lemon bars, Desserts").
  static String _pinTitle(String title) {
    final keywords = title.indexOf(' | ');
    return keywords > 3 ? title.substring(0, keywords) : title;
  }

  /// YouTube: Recipe is often in the video description
  static ImportedRecipe? _tryYoutube(Document document) {
    final title = _getMetaContent(document, 'og:title') ?? 'YouTube Recipe';
    final image = _getMetaContent(document, 'og:image');

    // The meta tags only hold the first line or two of the description. The
    // whole of it is in the player data the page carries in a script.
    final description = _youtubeDescription(document)
        ?? _getMetaContent(document, 'og:description')
        ?? _getMetaContent(document, 'description');
    if (description == null || description.length < 50) return null;

    // Descriptions are full of links to gear and other channels, and of
    // chapter marks ("1:23 Mixing"). None of those lines is the recipe.
    final lines = _withoutCaptionNoise(description)
        .split('\n')
        .map((line) => line.trim())
        .where((line) =>
            line.isNotEmpty &&
            !line.contains('://') &&
            !_chapterMark.hasMatch(line))
        .toList();

    // Most videos are not recipes, so the description has to read like one.
    final parsed = _recipeFromLines(lines);
    if (parsed == null) return null;
    parsed.title = _cleanSocialTitle(title);
    parsed.imageUrl = image;
    return parsed;
  }

  static final _chapterMark = RegExp(r'^\d{1,2}:\d{2}');
  static final _youtubeDescriptionKey = RegExp(r'"shortDescription"\s*:\s*"');

  /// The full video description, from the player data in the page's scripts.
  static String? _youtubeDescription(Document document) {
    for (final script in document.querySelectorAll('script')) {
      final source = script.text;
      final key = _youtubeDescriptionKey.firstMatch(source);
      if (key == null) continue;
      // The value is a JSON string. It ends at the first quote that is not
      // escaped.
      var end = key.end;
      while (end < source.length && source.codeUnitAt(end) != 0x22) {
        end += source.codeUnitAt(end) == 0x5C ? 2 : 1;
      }
      if (end >= source.length) return null;
      try {
        return jsonDecode(source.substring(key.end - 1, end + 1)) as String;
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  /// Squarespace: Try specific Squarespace blog patterns when JSON-LD and standard selectors miss
  static ImportedRecipe? _trySquarespace(Document document) {
    // Squarespace recipe blogs often use plain content blocks
    // Look for content with recipe-like structure in .sqs-block-content
    // Only the blocks themselves. The layout around them holds the same text
    // again, and reading both doubles every line.
    final blocks = document.querySelectorAll('.sqs-block-content');
    if (blocks.isEmpty) return null;

    // Read the blocks line by line and try structured parsing. Their plain
    // text would run every paragraph into the next.
    final parsed = _recipeFromLines([
      for (final block in blocks) ..._blockLines(block),
    ]);
    if (parsed == null) return null;

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
          && line.length < 80) {
        continue;
      }

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
    // A title is short. What comes after is not read, which also keeps the
    // patterns below quick on a line that never ends.
    final start = title.length > 300 ? title.substring(0, 300) : title;
    return start
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
    // The lengths are capped: an account name is short, and a pattern that
    // may start anywhere and run to the end takes very long on a long line.
    final instagramQuoteMatch = RegExp(
      r'(?:^|\b)\w[\w.]{0,60}\s{1,10}on\s{1,10}Instagram:\s{0,10}["""\u201C]([^"""\u201D]{1,5000})["""\u201D]',
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

  static final _instagramWrapper = RegExp(
      r'^.{0,200}?(?:\bon Instagram|\b\d{4}):\s{0,5}["“]',
      caseSensitive: false);

  /// The caption inside one of Instagram's meta tags, or null when [text] is
  /// not in either wrapped form:
  ///   og:title        Name on Instagram: "caption"
  ///   og:description  12K likes, 340 comments - name on February 3, 2025: "caption".
  static String? _instagramCaption(String text) {
    final opening = _instagramWrapper.firstMatch(text);
    if (opening == null) return null;
    // Without the closing quote and the full stop og:description puts after
    // it. A caption that was cut short has neither and is left as it is.
    final caption = text.substring(opening.end).trimRight();
    final body = caption.endsWith('.')
        ? caption.substring(0, caption.length - 1).trimRight()
        : caption;
    final isClosed = body.endsWith('"') || body.endsWith('”');
    return isClosed ? body.substring(0, body.length - 1) : caption;
  }

  static final _emoji = RegExp(
      r'[\u{1F000}-\u{1FAFF}\u{2190}-\u{21FF}\u{2300}-\u{23FF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{FE0F}\u{200D}]',
      unicode: true);
  static final _hashtagsOnly = RegExp(
      r'^(?:[#@][\p{L}\p{N}_]+(?:\.[\p{L}\p{N}_]+)*[\s,.]*)+$',
      unicode: true);
  static final _bareLink = RegExp(r'^(?:https?://|www\.)\S+$', caseSensitive: false);

  static final _captionLineOpening = RegExp(r'^[^\p{L}\p{N}#@]+', unicode: true);

  // Only what a line opens with counts. "Follow" and "comment" in the middle
  // of a sentence are ordinary words in a step ("follow the package
  // directions"), and so is "save" before anything but the post itself
  // ("save the pasta water").
  static final _callToAction = RegExp(
      r"^(?:(?:don['’]?t forget|remember|make sure|be sure) to |please )?(?:"
      r'save (?:this (?:recipe|post|reel|video|one)|(?:this|it) for (?:later|next time)|for later)\b|'
      r'follow (?:me|us|along|for more|@)|'
      r'comment\b.{0,60}\b(?:recipe|below|link)\b|'
      r'tag (?:a|someone|your)\b|'
      r'share this (?:recipe|post|reel|video|with)\b|'
      r'subscribe\b|'
      r'(?:full )?recipe (?:is )?(?:linked )?in (?:my |the )?bio\b|'
      r'link in (?:my |the )?bio\b|'
      r'dm me\b|'
      r'like this (?:recipe|post|reel|video)\b|'
      r'(?:like|share)(?:,| and| &| \+) ?(?:like|share|subscribe|follow|save|comment)\b|'
      // How a video description signs off.
      r'thanks? (?:you )?(?:so much )?for watching\b|'
      r'music(?: by\b|:)|'
      r'(?:filmed|shot|edited) (?:on|with|by)\b|'
      r'business (?:inquiries|enquiries)\b)',
      caseSensitive: false);

  /// A caption line that is about the account and not the dish: hashtags, a
  /// bare link, or a call to follow, save or comment.
  static bool _isCaptionNoise(String line) {
    // Past the emoji or bullet the line opens with.
    final text = line.replaceFirst(_captionLineOpening, '');
    return text.isEmpty ||
        _hashtagsOnly.hasMatch(text) ||
        _bareLink.hasMatch(text) ||
        _callToAction.hasMatch(text);
  }

  /// [caption] without its noise lines and without the hashtags that trail
  /// the other lines.
  static String _withoutCaptionNoise(String caption) {
    final kept = <String>[];
    for (final raw in caption.split('\n')) {
      final line = _withoutTrailingHashtags(raw).trim();
      if (line.isEmpty) {
        kept.add('');
      } else if (!_isCaptionNoise(line)) {
        kept.add(line);
      }
    }
    return kept.join('\n').trim();
  }

  /// [line] without the hashtags it ends in ("so good #pasta #dinner").
  ///
  /// Read from the end, a tag at a time. A pattern for "a run of tags at the
  /// end" has to try that from every space in the line, which takes minutes
  /// on a line that is long enough.
  static String _withoutTrailingHashtags(String line) {
    bool isSpace(int index) {
      final unit = line.codeUnitAt(index);
      return unit <= 0x20 || unit == 0xA0 || unit == 0x3000;
    }

    var end = line.length;
    while (true) {
      var tagEnd = end;
      while (tagEnd > 0 && isSpace(tagEnd - 1)) {
        tagEnd--;
      }
      var tagStart = tagEnd;
      while (tagStart > 0 && !isSpace(tagStart - 1) && line.codeUnitAt(tagStart - 1) != 0x23) {
        tagStart--;
      }
      // A tag is a word with a "#" in front and a space before that.
      final isTag = tagStart < tagEnd &&
          tagStart >= 2 &&
          line.codeUnitAt(tagStart - 1) == 0x23 &&
          isSpace(tagStart - 2);
      if (!isTag) return line.substring(0, end);
      end = tagStart - 2;
    }
  }

  /// [caption] with its method under a heading of its own. Captions often
  /// head the ingredients and then just carry on with the steps, which would
  /// all be read as more ingredients.
  static String _withMethodHeading(String caption) {
    final lines = caption.split('\n');
    final method = _unheadedMethodStart(lines);
    if (method < 0) return caption;
    lines.insert(method, 'Instructions:');
    return lines.join('\n');
  }

  /// The name of the dish from the first line of a caption: up to the first
  /// emoji or the end of the first sentence, without hashtags and mentions.
  static String? _captionTitle(String caption) {
    var title = caption
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');
    // The name of a dish is short. What comes after is not read.
    if (title.length > 300) title = title.substring(0, 300);
    title = title.replaceFirst(RegExp(r'^[^\p{L}\p{N}]+', unicode: true), '');

    final emoji = _emoji.firstMatch(title);
    if (emoji != null && emoji.start > 3) title = title.substring(0, emoji.start);
    title = title
        .replaceAll(_emoji, ' ')
        .replaceAll(RegExp(r'[#@][\p{L}\p{N}_.]+', unicode: true), ' ');

    final sentenceEnd = RegExp(r'[.!?](?:\s|$)').firstMatch(title);
    if (sentenceEnd != null && sentenceEnd.start > 3) {
      title = title.substring(0, sentenceEnd.start);
    }
    title = title
        .replaceAll(RegExp(r'''^["'“”\s]+|["'“”\s:,;|\-#@]+$'''), '')
        .replaceAll(_whitespace, ' ')
        .trim();
    return (title.length > 3 && title.length < 150) ? title : null;
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
      final src = _imageAddress(document.querySelector(selector));
      if (src != null) return src;
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
      // An inline placeholder with no real address behind it.
      if (dataSrc == null && src.startsWith('data:')) continue;

      if (area > bestArea) {
        bestArea = area;
        bestSrc = dataSrc ?? src;
      } else if (bestSrc == null && width >= 300) {
        bestSrc = dataSrc ?? src;
      }
    }

    return bestSrc;
  }

  /// The address an image element points at, whichever attribute holds it.
  /// Lazy-loading themes keep the real one in data-src and put an inline
  /// placeholder in src; microdata uses content or href.
  static String? _imageAddress(Element? element) {
    if (element == null) return null;
    for (final name in const ['data-src', 'data-lazy-src', 'src', 'content', 'href']) {
      final value = element.attributes[name]?.trim() ?? '';
      if (value.isNotEmpty && !value.startsWith('data:')) return value;
    }
    return null;
  }

  /// [value] as an address the app can download an image from: absolute,
  /// http or https. A relative one is resolved against [pageUrl] when the
  /// page has an address. Anything else gives null, since a recipe without a
  /// photo is better than one whose photo fails to download.
  static String? _absoluteUrl(String? value, [String? pageUrl]) {
    var address = value?.trim().replaceAll('&amp;', '&') ?? '';
    if (address.isEmpty || address.contains(_unreadableMark)) return null;
    // "//cdn.example/photo.jpg" leaves the scheme to the page it is on.
    if (address.startsWith('//') && pageUrl == null) address = 'https:$address';
    try {
      var uri = Uri.parse(address);
      if (!uri.hasScheme && pageUrl != null) {
        uri = Uri.parse(pageUrl).resolveUri(uri);
        address = uri.toString();
      }
      final isWeb = uri.scheme == 'http' || uri.scheme == 'https';
      return isWeb && uri.host.isNotEmpty ? address : null;
    } catch (_) {
      return null;
    }
  }

  // ========== APP-SPECIFIC HTML PARSERS ==========

  /// Detect and parse app-specific HTML export formats
  static List<ImportedRecipe> _tryAppSpecificHtml(Document document, String rawHtml) {
    // RecipeKeeper: single HTML with all recipes, each in <div class="recipe-details">
    if (document.querySelector('.recipe-details') != null ||
        rawHtml.contains('RecipeKeeper') ||
        document.querySelectorAll('[class*="recipe-details"]').length > 1) {
      final recipes = _parseRecipeKeeperHtml(document);
      if (recipes.isNotEmpty) return recipes;
    }

    // CopyMeThat: HTML export with <div class="recipe"> blocks. The file only
    // names the app in a lower-case meta tag, so it is also known by its
    // structure: a name and the two lists, each under its own id.
    final hasCopyMeThatIds = rawHtml.contains('copymethat_class_id_version') ||
        (document.querySelector('div.recipe #name') != null &&
            document.querySelector('div.recipe #recipeIngredients, div.recipe #recipeInstructions') != null);
    final namesCopyMeThat = rawHtml.contains('CopyMeThat') ||
        rawHtml.contains('copymeThat') ||
        document.querySelector('.recipeGroup') != null;
    if (hasCopyMeThatIds || namesCopyMeThat) {
      final recipes = _parseCopyMeThatHtml(document);
      if (recipes.isNotEmpty) return recipes;
      // A file that names the app but has none of the ids is read by its
      // headings and lists. A page that only happens to share the ids is
      // left to the other parsers.
      if (namesCopyMeThat) return _parseCopyMeThatByLists(document);
    }

    return [];
  }

  static final _zeroWidth = RegExp(r'[\u200B-\u200D\uFEFF]');

  /// Parse RecipeKeeper's monolithic HTML export.
  /// RecipeKeeper exports ALL recipes into a single (often 600KB+) HTML file.
  /// Structure: multiple <div class="recipe-details"> each containing the recipe,
  /// its fields marked with itemprop attributes (recipeIngredients,
  /// recipeDirections, recipeYield and so on).
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
        // A field is found by its itemprop. The class names are what files
        // without the itemprop attributes still have.
        Element? field(String property, String classes) =>
            block.querySelector('[itemprop="$property"]') ??
            block.querySelector(classes);

        // A value is the content of a <meta>, or the text of anything else.
        String? valueOf(Element? element) {
          if (element == null) return null;
          final value = element.localName == 'meta'
              ? _cleanHtmlText(element.attributes['content']) ?? ''
              : _blockLines(element).join(' ');
          return value.isEmpty ? null : value;
        }

        List<String> valuesOf(String selector) {
          final values = <String>[];
          for (final element in block.querySelectorAll(selector)) {
            for (final value in (valueOf(element) ?? '').split(',')) {
              if (value.trim().isNotEmpty) values.add(value.trim());
            }
          }
          return values;
        }

        // Ingredients, directions and notes hold one <p> or <li> per line,
        // or plain text with <br> or bare line breaks between the lines.
        List<String> linesOf(Element? box) => box == null
            ? []
            : _blockLines(box, keepLines: box.querySelector('p, li, br') == null);

        // Title. The export writes zero-width spaces in front of some.
        final title = (valueOf(field('name', '.recipe-title, h2, h1, .title')) ?? '')
            .replaceAll(_zeroWidth, '')
            .trim();

        final ingredients = linesOf(field('recipeIngredients', '.recipe-ingredients, [class*="ingredient"]'));

        final instructions = <String>[];
        for (final line in linesOf(field('recipeDirections',
            '.recipe-directions, .recipe-instructions, [class*="direction"], [class*="instruction"]'))) {
          final step = _stepText(line);
          if (step.isNotEmpty) instructions.add(step);
        }

        final notes = linesOf(field('recipeNotes', '.recipe-notes, [class*="note"]')).join('\n');

        // Source: the link when there is one, otherwise what was typed
        // ("Grandma's notebook").
        final sourceEl = field('recipeSource', '[class*="source"], [class*="url"]');
        final sourceLink = sourceEl?.localName == 'a' ? sourceEl : sourceEl?.querySelector('a[href]');
        final source = sourceLink?.attributes['href']?.trim() ?? valueOf(sourceEl) ?? '';

        // The course becomes one of the app's own courses when it matches
        // one. Categories, collections and a course the app does not have
        // are kept as tags.
        final courses = valuesOf('[itemprop="recipeCourse"]');
        String? courseId;
        for (final course in courses) {
          courseId ??= mapToCourseId(course);
        }
        final tags = <String>{
          ...valuesOf('[itemprop="recipeCategory"], [itemprop="recipeCollection"]'),
          if (courseId == null) ...courses,
        };
        if (tags.isEmpty) tags.addAll(valuesOf('[class*="category"], [class*="course"]'));

        final rating = int.tryParse(valueOf(block.querySelector('[itemprop="recipeRating"]')) ?? '');

        // The photos are files beside the export, which an HTML file picked
        // on its own cannot reach. Only a real web address is kept.
        final imageEl = block.querySelector('img.recipe-photo') ?? block.querySelector('img');

        if (ingredients.isNotEmpty || instructions.isNotEmpty) {
          recipes.add(ImportedRecipe(
            title: title.isEmpty ? 'Imported Recipe' : title,
            ingredients: ingredients,
            instructions: instructions,
            notes: notes.isEmpty ? null : notes,
            servings: valueOf(field('recipeYield', '[class*="serving"], [class*="yield"]')),
            prepTimeMinutes: _parseTimeValue(valueOf(field('prepTime', '[class*="prep"]'))),
            cookTimeMinutes: _parseTimeValue(valueOf(field('cookTime', '[class*="cook"]'))),
            imageUrl: _absoluteUrl(imageEl?.attributes['src']),
            sourceUrl: source.isEmpty ? null : source,
            suggestedCourse: courseId,
            rating: (rating != null && rating >= 1 && rating <= 5) ? rating : null,
            sourceApp: 'recipekeeper',
            tags: tags.isEmpty ? null : tags.toList(),
          ));
        }
      } catch (_) {
        // Skip malformed recipe blocks
      }
    }

    return recipes;
  }

  /// Parse CopyMeThat HTML export.
  /// Structure: one <div class="recipe"> per recipe. Its fields are told
  /// apart by id (#name, #recipeIngredients, #recipeInstructions and so on),
  /// and the same ids repeat in every recipe, so each is looked up inside its
  /// own block.
  static List<ImportedRecipe> _parseCopyMeThatHtml(Document document) {
    final recipes = <ImportedRecipe>[];

    for (final block in document.querySelectorAll('div.recipe')) {
      final recipe = _copyMeThatRecipe(block);
      if (recipe != null) recipes.add(recipe);
    }
    return recipes;
  }

  /// CopyMeThat files without the ids: recipe blocks with a heading for the
  /// title, a <ul> of ingredients and an <ol> of directions.
  static List<ImportedRecipe> _parseCopyMeThatByLists(Document document) {
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
            imageUrl: _absoluteUrl(imageEl?.attributes['src']),
            sourceUrl: sourceEl?.attributes['href'],
            sourceApp: 'copymeThat',
          ));
        }
      } catch (_) {}
    }

    return recipes;
  }

  /// One recipe of a CopyMeThat export, or null when [block] is not one.
  static ImportedRecipe? _copyMeThatRecipe(Element block) {
    String? text(String selector) {
      final element = block.querySelector(selector);
      final value = element == null ? '' : _blockLines(element).join(' ');
      return value.isEmpty ? null : value;
    }

    // One <li> per line. Empty spacer items separate groups and are skipped;
    // a sub-header naming a group ("Filling") is written "Filling:", the
    // form the app turns into a heading.
    List<String> lines(String selector) {
      final found = <String>[];
      for (final item in block.querySelectorAll(selector)) {
        final line = _blockLines(item).join(' ');
        if (line.isEmpty) continue;
        final isHeader = item.className.contains('subheader');
        found.add(isHeader && !line.endsWith(':') ? '$line:' : line);
      }
      return found;
    }

    final ingredients = lines('#recipeIngredients li');
    final instructions = lines('#recipeInstructions li');
    if (ingredients.isEmpty && instructions.isEmpty) return null;

    final notes = lines('#recipeNotes li, li.recipeNote').join('\n');
    final tags = lines('span.recipeCategory');
    final rating = int.tryParse(text('#ratingValue') ?? '');
    final source = block.querySelector('#original_link');
    final sourceUrl = source?.attributes['href']?.trim() ?? '';

    return ImportedRecipe(
      title: text('#name') ?? text('h1, h2, .title') ?? 'Imported Recipe',
      description: text('#description'),
      ingredients: ingredients,
      instructions: instructions,
      notes: notes.isEmpty ? null : notes,
      servings: text('#recipeYield'),
      prepTimeMinutes: _parseTimeValue(text('[meta="prepTime"]')),
      cookTimeMinutes: _parseTimeValue(text('[meta="cookTime"]')),
      rating: (rating != null && rating >= 1 && rating <= 5) ? rating : null,
      tags: tags.isEmpty ? null : tags,
      sourceUrl: sourceUrl.isNotEmpty ? sourceUrl : text('#original_link'),
      // The photos are files beside the export. Only a real web address is
      // kept, a relative path would just fail to download.
      imageUrl: _absoluteUrl(block.querySelector('img.recipeImage')?.attributes['src']),
      sourceApp: 'copymeThat',
    );
  }

  // ========== APP-SPECIFIC JSON PARSERS ==========

  /// The first recipe in a JSON text, in whichever of the formats below it
  /// is written.
  static ImportedRecipe? _tryAppJson(String content) =>
      _tryAppJsonBulk(content).firstOrNull;

  /// Every recipe in a JSON text: one recipe, a list of them, or an export
  /// that wraps its recipes in an object.
  static List<ImportedRecipe> _tryAppJsonBulk(String content) {
    final recipes = _jsonRecipes(_decodeJson(content));
    // A file has no address to resolve a relative image against, and an
    // image that cannot be downloaded only shows up as a failed download.
    for (final recipe in recipes) {
      recipe.imageUrl = _absoluteUrl(recipe.imageUrl);
    }
    return recipes;
  }

  /// The recipes in decoded JSON. Only an entry that lists ingredients or
  /// steps is one, so the settings file of an export, or any other JSON that
  /// is no recipe, gives nothing.
  static List<ImportedRecipe> _jsonRecipes(dynamic json) {
    final recipes = <ImportedRecipe>[];
    void addEach(dynamic entries, {bool fromMealie = false}) {
      if (entries is! List) return;
      for (final entry in entries) {
        if (entry is! Map<String, dynamic>) continue;
        try {
          final recipe = fromMealie ? _parseMealieRecipe(entry) : _tryAppJsonSingle(entry);
          if (_hasContent(recipe)) recipes.add(recipe!);
        } catch (_) {
          // One malformed entry must not cost the file its other recipes.
        }
      }
    }

    if (json is List) {
      addEach(json);
    } else if (json is Map<String, dynamic>) {
      if (_isMealieBackup(json)) {
        // Its rows are Mealie recipes, whatever other keys they carry.
        addEach(_mealieBackupRecipes(json), fromMealie: true);
        return recipes;
      }
      // An export that wraps its recipes: {"recipes": [...]}
      addEach(json['recipes'] ?? json['items'] ?? json['data']);
      // Mealie export: {"groups": [{"recipes": [...]}]}
      final groups = json['groups'];
      if (recipes.isEmpty && groups is List) {
        for (final group in groups) {
          if (group is Map) addEach(group['recipes']);
        }
      }
      // Single recipe, bare or wrapped: {"recipe": {...}}
      if (recipes.isEmpty) addEach([json]);
      if (recipes.isEmpty) addEach([json['recipe']]);
    }
    return recipes;
  }

  /// One JSON object read as a recipe: in the format of the app that wrote
  /// it when its keys give that away, otherwise by the names recipe data
  /// commonly uses. Null when it lists neither ingredients nor steps.
  static ImportedRecipe? _tryAppJsonSingle(Map<String, dynamic> json) {
    final readers = <ImportedRecipe Function(Map<String, dynamic>)>[
      if (_isCroutonRecipe(json)) _parseCroutonRecipe,
      if (json['steps'] is List && json.containsKey('working_time')) _parseTandoorRecipe,
      if (_isMealieRecipe(json)) _parseMealieRecipe,
      if (json.containsKey('whpiRecipeId') || json.containsKey('recipeItems')) _parseSamsungFoodRecipe,
      if (_isMelaRecipe(json)) parseMelaRecipe,
      _buildRecipeFromJsonMap,
    ];
    // Keys that look like an app's can turn up in other data. What one
    // reader does not find is left to the next, and in the end to the common
    // names.
    ImportedRecipe? recipe;
    for (final read in readers) {
      final found = read(json);
      if (recipe == null || !_hasContent(recipe)) {
        recipe = found;
      } else {
        if (recipe.ingredients.isEmpty) recipe.ingredients = found.ingredients;
        if (recipe.instructions.isEmpty) recipe.instructions = found.instructions;
      }
      if (_isComplete(recipe)) break;
    }
    return _hasContent(recipe) ? recipe : null;
  }

  /// [rows] sorted by the number each carries under [key], which is the
  /// order the app that wrote them shows them in. Rows without one follow
  /// in file order.
  static List<dynamic> _rowsInOrder(dynamic rows, String key) {
    if (rows is! List) return const [];
    final byOrder = [
      for (var i = 0; i < rows.length; i++)
        (rows[i] is Map && rows[i][key] is num ? rows[i][key] as num : null, i),
    ];
    byOrder.sort((a, b) {
      final (orderA, indexA) = a;
      final (orderB, indexB) = b;
      if (orderA == null || orderB == null) {
        if (orderA != null) return -1;
        if (orderB != null) return 1;
      } else if (orderA != orderB) {
        return orderA.compareTo(orderB);
      }
      return indexA.compareTo(indexB);
    });
    return [for (final (_, index) in byOrder) rows[index]];
  }

  static final _notAsciiLettersOrDigits = RegExp(r'[^a-z0-9]+');

  /// Where a recipe is from: its link when the export has one, otherwise the
  /// name it gives (a site, a book, "Grandma"). With both, the name comes
  /// back as a line for the notes, unless the link already says it the way
  /// "seriouseats.com" says "Serious Eats".
  static (String?, String?) _sourceAndNote(String? link, String? name) {
    if (link == null || name == null) return (link ?? name, null);
    String letters(String text) => text.toLowerCase().replaceAll(_notAsciiLettersOrDigits, '');
    final inLink = letters(name).isNotEmpty && letters(link).contains(letters(name));
    return (link, inLink ? null : 'Source: $name');
  }

  /// A detail the app has no field for, as a paragraph for the notes.
  static String? _labelledNote(String label, String? text) {
    if (text == null) return null;
    return text.contains('\n') ? '$label:\n$text' : '$label: $text';
  }

  /// [parts] as notes, a blank line between them. Null when there are none.
  static String? _joinNotes(List<String?> parts) {
    final notes = parts.nonNulls.join('\n\n');
    return notes.isEmpty ? null : notes;
  }

  /// The first of [names] (categories, tags) that names one of the app's
  /// courses.
  static String? _courseAmong(Iterable<String?> names) {
    for (final name in names.nonNulls) {
      final course = mapToCourseId(name);
      if (course != null) return course;
    }
    return null;
  }

  /// The first picture in a list that holds data: base64 text, or an object
  /// that carries it under "data". The text is megabytes long, so it is
  /// handed on as it is.
  static String? _firstImageData(dynamic images) {
    if (images is! List) return null;
    for (final image in images) {
      final data = image is Map ? image['data'] : image;
      if (data is String && data.trim().isNotEmpty) return data;
    }
    return null;
  }

  /// What a Crouton recipe is known by: an ingredient list in its shape, the
  /// amount and the food each in an object of their own, or steps in its
  /// shape next to a key only Crouton writes.
  static bool _isCroutonRecipe(Map<String, dynamic> json) {
    if (json.containsKey('ingredientSections') || json.containsKey('stepSections')) return true;
    final ingredients = json['ingredients'];
    if (ingredients is List && ingredients.any((row) => row is Map && row['ingredient'] is Map)) {
      return true;
    }
    final steps = json['steps'];
    return (json.containsKey('cookingDuration') || json.containsKey('folderIDs')) &&
        steps is List &&
        steps.any((row) => row is Map && row['step'] is String);
  }

  /// The units a .crumb file names, as a cook writes them. Any other
  /// ("PINCH", "CAN") reads well enough in lower case.
  static const _croutonUnits = {
    'ITEM': '',
    'CUP': 'cup',
    'TABLESPOON': 'tbsp',
    'TEASPOON': 'tsp',
    'GRAMS': 'g',
    'KGS': 'kg',
    'MILLS': 'ml',
    'LITRES': 'l',
    'DECILITER': 'dl',
    'OUNCE': 'oz',
    'POUND': 'lb',
  };

  /// Parse Crouton app JSON format (.crumb).
  /// Structure: { name, serves, duration and cookingDuration (minutes),
  /// webLink, sourceName, notes, images (base64), ingredients: [{order,
  /// quantity: {amount, quantityType}, ingredient: {name}}], steps: [{order,
  /// step, isSection}] }. A quantityType of SECTION makes the row the title
  /// of a group. The layout with ingredientSections and stepSections, each
  /// section holding its rows, is read as well.
  static ImportedRecipe _parseCroutonRecipe(Map<String, dynamic> json) {
    final ingredients = <String>[];
    void addIngredient(dynamic row, int depth) {
      if (row is String) {
        if (row.trim().isNotEmpty) ingredients.add(row.trim());
        return;
      }
      if (row is! Map || depth > 2) return;
      final group = row['ingredients'] ?? row['items'];
      if (group is List) {
        final title = _jsonString(row['name']);
        if (title != null) ingredients.add(_groupTitle(title));
        for (final item in _rowsInOrder(group, 'order')) {
          addIngredient(item, depth + 1);
        }
        return;
      }
      final quantity = row['quantity'];
      final type = quantity is Map ? _jsonString(quantity['quantityType'])?.toUpperCase() : null;
      final name = _jsonName(row['ingredient']) ?? _jsonString(row['name']);
      if (type == 'SECTION') {
        if (name != null) ingredients.add(_groupTitle(name));
        return;
      }
      final line = [
        _jsonAmount(quantity is Map ? quantity['amount'] : quantity),
        type == null
            ? _jsonString(row['unit'])
            : _croutonUnits[type] ?? type.toLowerCase().replaceAll('_', ' '),
        name,
      ].nonNulls.where((part) => part.isNotEmpty).join(' ');
      if (line.isNotEmpty) ingredients.add(line);
    }

    for (final row in _rowsInOrder(json['ingredientSections'] ?? json['ingredients'], 'order')) {
      addIngredient(row, 0);
    }

    final steps = <(String, bool)>[];
    void addStep(dynamic row, int depth) {
      if (row is String) {
        steps.add((row, false));
        return;
      }
      if (row is! Map || depth > 2) return;
      final group = row['steps'] ?? row['items'];
      if (group is List) {
        for (final item in _rowsInOrder(group, 'order')) {
          addStep(item, depth + 1);
        }
      }
      final text = _jsonString(row['step']) ??
          _jsonString(row['text']) ??
          _jsonString(row['instruction']);
      if (text != null) steps.add((text, row['isSection'] == true));
    }

    for (final row in _rowsInOrder(json['stepSections'] ?? json['steps'], 'order')) {
      addStep(row, 0);
    }

    final (sourceUrl, sourceNote) = _sourceAndNote(
      _jsonString(json['webLink']) ?? _jsonString(json['url']) ?? _jsonString(json['sourceUrl']),
      _jsonString(json['sourceName']),
    );
    final tags = _jsonNames(json['tags']);

    return ImportedRecipe(
      title: _jsonString(json['name']) ?? _jsonString(json['title']) ?? 'Crouton Recipe',
      description: _jsonString(json['description']),
      ingredients: ingredients,
      instructions: _stepsWithTitles(steps),
      servings: _jsonServings(json['serves'] ?? json['servings'] ?? json['yield']),
      prepTimeMinutes: _jsonTime(json, const ['duration', 'prepTime', 'prep_time']),
      cookTimeMinutes: _jsonTime(json, const ['cookingDuration', 'cookTime', 'cook_time']),
      imageUrl: _extractImage(json['image'] ?? json['imageUrl']),
      imageData: _firstImageData(json['images']),
      sourceUrl: sourceUrl,
      notes: _joinNotes([
        _jsonString(json['notes']),
        sourceNote,
        // The key is spelled the way Crouton spells it.
        _labelledNote('Nutrition', _jsonString(json['neutritionalInfo'])),
      ]),
      tags: tags.isEmpty ? null : tags,
      suggestedCourse: _courseAmong(tags),
      sourceApp: 'crouton',
    );
  }

  /// Parse Tandoor recipe manager JSON format.
  /// Structure: { name, steps: [{name, instruction, ingredients: [{food:
  /// {name}, unit: {name}, amount, note, no_amount, is_header}]}],
  /// working_time and waiting_time (minutes), servings, servings_text,
  /// keywords: [{name}], source_url }
  static ImportedRecipe _parseTandoorRecipe(Map<String, dynamic> json) {
    final ingredients = <String>[];
    final steps = <(String, bool)>[];

    final rows = json['steps'];
    for (final step in rows is List ? rows : const []) {
      if (step is! Map) continue;

      // Ingredients within each step
      final stepIngredients = step['ingredients'];
      for (final ingredient in stepIngredients is List ? stepIngredients : const []) {
        if (ingredient is! Map) continue;
        final note = _jsonString(ingredient['note']);
        // A header row is the title of a group, and keeps it in its note.
        if (ingredient['is_header'] == true) {
          if (note != null) ingredients.add(_groupTitle(note));
          continue;
        }
        final food = _jsonName(ingredient['food']);
        // "No amount" hides the unit along with the amount. An amount of
        // zero is none either.
        final shown = ingredient['no_amount'] != true;
        final line = [
          if (shown) _jsonAmount(ingredient['amount']),
          if (shown) _jsonName(ingredient['unit']),
          food,
          if (note != null) food == null ? note : '($note)',
        ].nonNulls.join(' ');
        if (line.isNotEmpty) ingredients.add(line);
      }

      // A step may carry a name, which Tandoor shows as a heading over it
      // unless that is switched off.
      final name = _jsonString(step['name']);
      if (name != null && step['show_as_header'] != false) steps.add((name, true));
      final instruction = _jsonString(step['instruction']);
      if (instruction != null) steps.add((instruction, false));
    }

    final servings = _jsonAmount(json['servings']);
    final servingsText = _jsonString(json['servings_text']);
    final tags = _jsonNames(json['keywords']);

    return ImportedRecipe(
      title: _jsonString(json['name']) ?? 'Tandoor Recipe',
      description: _jsonString(json['description']),
      ingredients: ingredients,
      instructions: _stepsWithTitles(steps),
      servings: servings != null && servingsText != null
          ? '$servings $servingsText'
          : servings ?? servingsText,
      // Tandoor keeps both times in minutes.
      prepTimeMinutes: _jsonTime(json, const ['working_time']),
      cookTimeMinutes: _jsonTime(json, const ['waiting_time']),
      imageUrl: _extractImage(json['image']),
      sourceUrl: _jsonString(json['source_url']),
      tags: tags.isEmpty ? null : tags,
      suggestedCourse: _courseAmong(tags),
      sourceApp: 'tandoor',
    );
  }

  /// What a Mealie recipe is known by. Its ZIP export writes every key in
  /// snake_case. The JSON download of one recipe writes them in camelCase,
  /// which makes its ingredients look like schema.org data, so that one is
  /// told by the keys only Mealie has.
  static bool _isMealieRecipe(Map<String, dynamic> json) {
    if (json['recipe_ingredient'] is List || json['recipe_instructions'] is List) return true;
    final ingredients = json['recipeIngredient'];
    if (ingredients is! List) return false;
    return json.containsKey('orgURL') ||
        ingredients.any((row) =>
            row is Map &&
            (row.containsKey('display') ||
                row.containsKey('disableAmount') ||
                row.containsKey('referenceId')));
  }

  /// Parse Mealie recipe JSON format.
  /// Structure: { name, recipe_ingredient: [{title, quantity, unit: {name},
  /// food: {name}, note, display}], recipe_instructions: [{title, text}],
  /// notes: [{title, text}], tags and recipe_category: [{name}], org_url,
  /// recipe_yield, prep_time, perform_time and total_time ("15 minutes") },
  /// with every key in camelCase instead when the recipe was downloaded on
  /// its own (recipeIngredient, orgURL).
  static ImportedRecipe _parseMealieRecipe(Map<String, dynamic> json) {
    // The same field under either spelling.
    dynamic field(String snake, String camel) => json[snake] ?? json[camel];

    // A title on an ingredient or a step opens a group with that name.
    final ingredients = <String>[];
    final ingredientRows = field('recipe_ingredient', 'recipeIngredient');
    for (final row in ingredientRows is List ? ingredientRows : const []) {
      if (row is Map) {
        final title = _jsonString(row['title']);
        if (title != null) ingredients.add(_groupTitle(title));
        final line = _mealieIngredient(row);
        if (line.isNotEmpty) ingredients.add(line);
      } else if (row is String && row.trim().isNotEmpty) {
        ingredients.add(row.trim());
      }
    }

    final steps = <(String, bool)>[];
    final stepRows = field('recipe_instructions', 'recipeInstructions');
    for (final row in stepRows is List ? stepRows : const []) {
      if (row is Map) {
        final title = _jsonString(row['title']);
        if (title != null) steps.add((title, true));
        final text = _jsonString(row['text']);
        if (text != null) steps.add((text, false));
      } else if (row is String) {
        steps.add((row, false));
      }
    }

    final categories = _jsonNames(field('recipe_category', 'recipeCategory'));
    final tags = <String>{..._jsonNames(json['tags']), ...categories};

    // Newer versions count the servings. Older ones only have the yield as
    // it was typed ("6 servings", "1 loaf").
    final yieldText = _jsonString(field('recipe_yield', 'recipeYield'));
    final yieldAmount = _jsonAmount(field('recipe_yield_quantity', 'recipeYieldQuantity'));
    final servings = _jsonAmount(field('recipe_servings', 'recipeServings')) ??
        (yieldAmount != null && yieldText != null
            ? '$yieldAmount $yieldText'
            : yieldText ?? yieldAmount);

    final (prepTime, cookTime) = _splitTotalTime(
      _jsonTime(json, const ['prep_time', 'prepTime']),
      _jsonTime(json, const ['perform_time', 'performTime', 'cook_time', 'cookTime']),
      _jsonTime(json, const ['total_time', 'totalTime']),
    );

    return ImportedRecipe(
      title: _jsonString(json['name']) ?? 'Mealie Recipe',
      description: _jsonString(json['description']),
      ingredients: ingredients,
      instructions: _stepsWithTitles(steps),
      servings: servings,
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      // Mealie's "image" is a key into its own store, not an address. Only
      // an address is worth passing on.
      imageUrl: _absoluteUrl(_jsonString(json['image'])),
      sourceUrl: _jsonString(field('org_url', 'orgURL')) ?? _jsonString(json['url']),
      notes: _joinNotes([_jsonNotes(json['notes']), _nutritionLine(json['nutrition'])]),
      tags: tags.isEmpty ? null : tags.toList(),
      suggestedCourse: _courseAmong([...categories, ...tags]),
      rating: _jsonRating(json['rating']),
      sourceApp: 'mealie',
    );
  }

  /// One Mealie ingredient as a line. Mealie writes the line itself under
  /// "display". Older exports do not, and they keep an ingredient nobody
  /// split into amount, unit and food whole in its note, next to an amount
  /// of 1 that means nothing.
  static String _mealieIngredient(Map row) {
    final display = _jsonString(row['display']);
    if (display != null) return _plainFractions(display);

    final amount = _jsonAmount(row['quantity']);
    final unit = _jsonName(row['unit']);
    final food = _jsonName(row['food']);
    final note = _jsonString(row['note']);
    final isSplit = (unit != null || food != null) &&
        (row['disable_amount'] ?? row['disableAmount']) != true;
    if (isSplit) {
      return [amount, unit, food, if (note != null) '($note)'].nonNulls.join(' ');
    }
    final line = note ?? _jsonString(row['original_text'] ?? row['originalText']) ?? food ?? '';
    return amount == null || amount == '1' || line.isEmpty ? line : '$amount $line';
  }

  static const _raisedDigits = '⁰¹²³⁴⁵⁶⁷⁸⁹';
  static const _loweredDigits = '₀₁₂₃₄₅₆₇₈₉';
  static final _raisedFraction =
      RegExp('([$_raisedDigits]{1,4})/([$_loweredDigits]{1,4})');

  /// A fraction printed with raised and lowered digits, the way Mealie
  /// prints one ("¹/₂ cup"), in the plain digits that read as an amount.
  static String _plainFractions(String line) =>
      line.replaceAllMapped(_raisedFraction, (fraction) {
        final over = fraction[1]!.split('').map(_raisedDigits.indexOf).join();
        final under = fraction[2]!.split('').map(_loweredDigits.indexOf).join();
        return '$over/$under';
      });

  /// A Mealie backup (database.json) holds no recipes as such but the tables
  /// of its database: one list of rows per table, the ingredients and the
  /// steps of all recipes each in a list of their own.
  static bool _isMealieBackup(Map<String, dynamic> json) =>
      json['recipes'] is List &&
      (json['recipes_ingredients'] is List || json['recipe_instructions'] is List);

  /// The recipes of a Mealie backup, each put back together from the rows
  /// that carry its id, in the shape Mealie exports a single recipe in.
  static List<Map<String, dynamic>> _mealieBackupRecipes(Map<String, dynamic> json) {
    // An id as the key rows are looked up by. Ids are text or numbers.
    String? keyOf(dynamic id) => id is String || id is num ? '$id' : null;

    // The rows of a table by the recipe they belong to, in Mealie's order.
    Map<String, List<Map>> byRecipe(dynamic table) {
      final rows = <String, List<Map>>{};
      for (final row in _rowsInOrder(table, 'position')) {
        final recipe = row is Map ? keyOf(row['recipe_id']) : null;
        if (recipe != null) (rows[recipe] ??= []).add(row);
      }
      return rows;
    }

    // The names in a table of units, foods, tags or categories, by row id.
    Map<String, String> names(dynamic table) {
      final found = <String, String>{};
      for (final row in table is List ? table : const []) {
        final id = row is Map ? keyOf(row['id']) : null;
        final name = id == null ? null : _jsonString(row['name']);
        if (name != null) found[id!] = name;
      }
      return found;
    }

    // What a table that links recipes to tags gives each recipe, by name.
    Map<String, List<String>> linked(dynamic links, String key, Map<String, String> byId) {
      final found = <String, List<String>>{};
      for (final link in links is List ? links : const []) {
        final recipe = link is Map ? keyOf(link['recipe_id']) : null;
        final name = recipe == null ? null : byId[keyOf(link[key])];
        if (name != null) (found[recipe!] ??= []).add(name);
      }
      return found;
    }

    final units = names(json['ingredient_units']);
    final foods = names(json['ingredient_foods']);
    final ingredients = byRecipe(json['recipes_ingredients']);
    final steps = byRecipe(json['recipe_instructions']);
    final notes = byRecipe(json['notes']);
    final tags = linked(json['recipes_to_tags'], 'tag_id', names(json['tags']));
    final categories =
        linked(json['recipes_to_categories'], 'category_id', names(json['categories']));

    final recipes = <Map<String, dynamic>>[];
    final rows = json['recipes'];
    for (final row in rows is List ? rows : const []) {
      final id = row is Map<String, dynamic> ? keyOf(row['id']) : null;
      if (id == null) continue;
      recipes.add({
        ...row,
        'recipe_ingredient': [
          for (final ingredient in ingredients[id] ?? const <Map>[])
            {
              ...ingredient,
              'unit': units[keyOf(ingredient['unit_id'])],
              'food': foods[keyOf(ingredient['food_id'])],
            },
        ],
        'recipe_instructions': steps[id],
        'notes': notes[id],
        'tags': tags[id],
        'recipe_category': categories[id],
      });
    }
    return recipes;
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
  /// Each Paprika recipe JSON has: name, ingredients and directions (one per
  /// line), description, notes, servings, prep_time, cook_time and
  /// total_time (as typed, "1 hr 20 min"), source (the name of the site or
  /// book) and source_url (its link), categories (a list of names), rating
  /// (0-5, 0 for unrated), difficulty, nutritional_info, image_url and
  /// photo_data (base64).
  static ImportedRecipe parsePaprikaRecipe(Map<String, dynamic> json) {
    final tags = _jsonNames(json['categories']);
    final (prepTime, cookTime) = _splitTotalTime(
      _jsonTime(json, const ['prep_time']),
      _jsonTime(json, const ['cook_time']),
      _jsonTime(json, const ['total_time']),
    );
    final (sourceUrl, sourceNote) =
        _sourceAndNote(_jsonString(json['source_url']), _jsonString(json['source']));

    return ImportedRecipe(
      title: _jsonString(json['name']) ?? _jsonString(json['title']) ?? 'Paprika Recipe',
      description: _jsonString(json['description']),
      ingredients: _jsonLines(json['ingredients']),
      instructions: _withoutStepNumbers(_jsonLines(json['directions'])),
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      servings: _jsonServings(json['servings']),
      sourceUrl: sourceUrl,
      notes: _joinNotes([
        _jsonString(json['notes']),
        sourceNote,
        _labelledNote('Difficulty', _jsonString(json['difficulty'])),
        _labelledNote('Nutrition', _jsonString(json['nutritional_info'])),
      ]),
      imageUrl: _absoluteUrl(_jsonString(json['image_url'])),
      // The main photo is in photo_data. Any others are in photos.
      imageData: _firstImageData([json['photo_data']]) ?? _firstImageData(json['photos']),
      tags: tags.isEmpty ? null : tags,
      suggestedCourse: _courseAmong(tags),
      rating: _jsonRating(json['rating']),
      sourceApp: 'paprika',
    );
  }

  /// What a Mela recipe is known by: a title and a short text next to the
  /// pictures or categories Mela keeps in the same file. Its ingredients and
  /// instructions are one text each, never a list.
  static bool _isMelaRecipe(Map<String, dynamic> json) {
    if (!json.containsKey('text')) return false;
    if (!json.containsKey('title') && !json.containsKey('name')) return false;
    if (json['ingredients'] is List || json['instructions'] is List) return false;
    final text = json['text'];
    return json.containsKey('images') ||
        json.containsKey('categories') ||
        (text is String && text.contains('---'));
  }

  static final _markdownHeading = RegExp(r'^#+[ \t]*', multiLine: true);
  static final _markdownLink = RegExp(r'\[([^\[\]\n]{1,300})\]\([^()\s]{0,2000}\)');
  static final _markdownEmphasis =
      RegExp(r'\*\*([^*\n]{1,300})\*\*|\*([^*\s][^*\n]{0,300})\*');

  /// Mela text without the little Markdown Mela allows in it: a link is the
  /// words it shows, bold and italics are plain, and a heading loses its
  /// "#". Null when nothing is left.
  static String? _melaText(dynamic value) {
    final text = _jsonString(value)
        ?.replaceAll(_markdownHeading, '')
        .replaceAllMapped(_markdownLink, (link) => link.group(1)!)
        .replaceAllMapped(_markdownEmphasis, (marked) => marked.group(1) ?? marked.group(2)!)
        .trim();
    return text == null || text.isEmpty ? null : text;
  }

  /// The lines of a Mela ingredient or instruction text. A line that starts
  /// with "#" is the title of a group.
  static List<String> _melaLines(dynamic value) {
    final lines = <String>[];
    for (final raw in _jsonLines(value)) {
      final line = _melaText(raw);
      if (line != null) lines.add(raw.startsWith('#') ? _groupTitle(line) : line);
    }
    return lines;
  }

  /// Parse Mela recipe JSON format.
  /// Mela writes: title, text (a short description), ingredients and
  /// instructions (one per line), yield, prepTime, cookTime, totalTime,
  /// notes, nutrition, link, images (base64 array) and categories.
  static ImportedRecipe parseMelaRecipe(Map<String, dynamic> json) {
    var description = _melaText(json['text']);
    var ingredients = _melaLines(json['ingredients']);
    var instructions = _withoutStepNumbers(_melaLines(json['instructions']));

    // Mela always writes the two fields, empty or not. A file without them
    // comes from a converter that keeps the whole recipe in "text", the
    // ingredients above a line of dashes and the steps below it.
    final text = _jsonString(json['text']);
    if (text != null && !json.containsKey('ingredients') && !json.containsKey('instructions')) {
      if (text.contains('---')) {
        final parts = text.split('---');
        ingredients = _jsonLines(parts.first)
            .where((line) => line != '-')
            .map((line) => line.startsWith('- ') ? line.substring(2) : line)
            .toList();
        instructions = _withoutStepNumbers(_jsonLines(parts.sublist(1).join('\n')));
      } else {
        // No separator. The text is parsed as a recipe when it reads like
        // one, and is left to be the description when it does not.
        final parsed = _recipeFromLines(_jsonLines(text));
        ingredients = parsed?.ingredients ?? ingredients;
        instructions = parsed?.instructions ?? instructions;
      }
      // Text that was read as the recipe is not its description as well.
      if (ingredients.isNotEmpty || instructions.isNotEmpty) description = null;
    }

    final tags = _jsonNames(json['categories']);
    final (prepTime, cookTime) = _splitTotalTime(
      _jsonTime(json, const ['prepTime']),
      _jsonTime(json, const ['cookTime']),
      _jsonTime(json, const ['totalTime']),
    );

    return ImportedRecipe(
      title: _jsonString(json['title']) ?? _jsonString(json['name']) ?? 'Mela Recipe',
      description: description,
      ingredients: ingredients,
      instructions: instructions,
      servings: _jsonServings(json['yield']),
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      notes: _joinNotes([
        _melaText(json['notes']),
        _labelledNote('Nutrition', _melaText(json['nutrition'])),
      ]),
      imageData: _firstImageData(json['images']),
      sourceUrl: _jsonString(json['link']),
      tags: tags.isEmpty ? null : tags,
      suggestedCourse: _courseAmong(tags),
      sourceApp: 'mela',
    );
  }

  // ========== MEALMASTER FORMAT (.mmf / .mk) ==========

  // The line Meal-Master opens a recipe with ("MMMMM----- Recipe via
  // Meal-Master (tm) v8.05", "---------- Recipe via Meal-Master"), and the
  // two fields every recipe of its starts with.
  static final _mealMasterBanner =
      RegExp(r'^(?:MMMMM-{2,}|(?:MMMMM|-{5})[^\n]{0,40}Meal-?Master)', multiLine: true, caseSensitive: false);
  static final _mealMasterFields =
      RegExp(r'^[ \t]*Title:[ \t]*\S[^\n]*\n[ \t]*Categories:', multiLine: true, caseSensitive: false);

  /// Only what Meal-Master itself writes counts. Five capital Ms in a row
  /// also end a recipe that calls itself "YUMMMMM".
  static bool _looksLikeMealMaster(String content) {
    return _mealMasterBanner.hasMatch(content) || _mealMasterFields.hasMatch(content);
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
          tags: categories?.split(',').map((c) => c.trim()).where((c) => c.isNotEmpty).toList(),
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

  /// Reads one recipe out of [text], line by line.
  ///
  /// [wrapped] is for text recognised from a photo or a PDF. It arrives as
  /// one entry for each printed line, so a step or an ingredient that ran
  /// over several lines on the page is put back together. Text a person
  /// typed is taken as written.
  ///
  /// [titleKnown] says the caller has the title already, from front matter,
  /// and the first line of [text] must not be used up as one. [titleIfNone]
  /// is the name of the file the text came from. It names the recipe unless
  /// the text carries a heading, and a first line is only read as the title
  /// where it says the same as the file.
  static ImportedRecipe _parseStructuredText(
    String text, {
    bool wrapped = false,
    bool titleKnown = false,
    String? titleIfNone,
  }) {
    final lines = _linesOf(text).toList();
    // The section each line opens, for the lines that are headers.
    final opens = [for (final line in lines) _detectSectionHeader(line)];
    // Headers still to come. Where a text names its method or its
    // ingredients, nothing above that header is sorted there by guesswork.
    int methodHeadersAhead = opens.where((s) => s == _Section.instructions).length;
    int ingredientHeadersAhead = opens.where((s) => s == _Section.ingredients).length;

    String title = 'Untitled Recipe';
    String? description;
    String? servings;
    String? introServings;
    int? prepTime;
    int? cookTime;
    int? totalTime;
    List<String> ingredients = [];
    List<String> instructions = [];
    List<String> notes = [];
    // Lines the writer put under an Ingredients or a Method header. They are
    // kept unless they are plainly not content. Lines sorted by guesswork are
    // held to the stricter checks.
    final listed = <String>{};
    // Sub-headings that stay in the two lists: "For the sauce:".
    final headings = <String>{};

    _Section currentSection = _Section.unknown;
    bool foundTitle = titleKnown;
    // How many more lines may be tried as the title. Blank lines and facts
    // do not use them up.
    int titleLinesLeft = 5;
    // Where a summary box may next begin. See [_summaryBox].
    int boxesFrom = 0;
    // A sub-heading waits here for the line under it, which settles the
    // list it belongs to.
    String? pendingHeading;
    // The list the line above went to, for as long as nothing came between.
    List<String>? lastList;
    // The same for the description.
    bool descriptionAbove = false;
    // The printed line above this one, as it was filed. A step put together
    // from several lines ends with it.
    String lineAbove = '';
    // A blank line, a rule or a header stood above this line.
    bool gapAbove = true;
    // The items of the list being read carry numbers.
    bool numberedList = false;
    // In text with no headers: the first step has been read.
    bool methodBegun = false;

    void file(List<String> list, String line, {bool underHeader = true}) {
      final heading = pendingHeading;
      if (heading != null && !identical(list, notes)) {
        list.add(heading);
        headings.add(heading);
      }
      pendingHeading = null;
      list.add(line);
      if (underHeader) listed.add(line);
      lastList = list;
      lineAbove = line;
      descriptionAbove = false;
    }

    // Adds [more] to the last entry of [list]: the rest of a wrapped line.
    void carryOn(List<String> list, String more) {
      final joined = _joinWrapped(list.last, more);
      if (listed.contains(list.last)) listed.add(joined);
      list[list.length - 1] = joined;
      lineAbove = more;
    }

    // True while the entry being read is the last one of [list] and may
    // take another printed line. An entry that has grown past any real one
    // takes no more, and the line starts an entry of its own. Text that is
    // one endless run of lines would otherwise be read ever more slowly,
    // each line being added to all those before it.
    bool open(List<String> list) => identical(lastList, list) && list.last.length < _longestEntry;

    // The next line that is not blank or a rule, or -1.
    int below(int from) {
      for (var at = from + 1; at < lines.length; at++) {
        final next = lines[at].trim();
        if (next.isNotEmpty && !_ruleLine.hasMatch(next)) return at;
      }
      return -1;
    }

    bool amountsAt(int at) =>
        at >= 0 &&
        opens[at] == _Section.unknown &&
        _readsAsAmountLine(_cleanMarkdown(_cleanListMarkers(lines[at].trim())));

    // True when line [at] is where a method begins that no header
    // announces.
    bool methodStartsAt(int at, {required bool newParagraph}) {
      if (at < 0 || methodHeadersAhead > 0 || opens[at] != _Section.unknown) return false;
      final raw = lines[at].trim();
      final cleaned = _cleanMarkdown(_cleanListMarkers(raw));
      if (cleaned.isEmpty || _startsWithAmount.hasMatch(cleaned)) return false;
      if (_readsAsStep(cleaned)) return true;
      // Numbers begin where the list above had none: "1. Peel the banana".
      if (_isNumbered(raw) && !numberedList && cleaned.split(_spaces).length >= 3) return true;
      // After a gap, running text is the method, in whatever language it
      // is written. Unless the list goes on below it.
      if (!newParagraph) return false;
      if (!_readsAsProse(cleaned) && cleaned.length < 70) return false;
      return !amountsAt(below(at));
    }

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      if (line.isEmpty || _ruleLine.hasMatch(line)) {
        gapAbove = true;
        continue;
      }
      // A picture on a line of its own: an Obsidian embed, a Markdown image.
      if (_pictureLine.hasMatch(line)) continue;

      final newParagraph = gapAbove;
      gapAbove = false;

      // A summary box prints each label over its value. Read each pair as
      // one line. Not among the steps, where a short line and the one after
      // it are two halves of a sentence.
      if (i >= boxesFrom &&
          currentSection != _Section.instructions &&
          !_digitOrFraction.hasMatch(line)) {
        final box = _summaryBox(lines, i);
        if (box != null && box.$1.isEmpty) {
          boxesFrom = box.$2 + 1;
        } else if (box != null) {
          // A label may read like a header: "Preparation" over "15 mins".
          for (final taken in opens.getRange(i, box.$2 + 1)) {
            if (taken == _Section.instructions) methodHeadersAhead--;
            if (taken == _Section.ingredients) ingredientHeadersAhead--;
          }
          lines.replaceRange(i, box.$2 + 1, box.$1);
          opens.replaceRange(i, box.$2 + 1, List.filled(box.$1.length, _Section.unknown));
          line = lines[i];
        }
      }

      // A printed line that carries on the sentence above it, whatever word
      // it happens to open with: "...whisk together all of the dry" /
      // "ingredients and make a well in the center".
      if (wrapped && !newParagraph && opens[i] == _Section.unknown) {
        final List<String>? proseList = identical(lastList, ingredients) ? null : lastList;
        final room = proseList != null ? open(proseList) : descriptionAbove && description!.length < _longestEntry;
        if (room && _runsOn(lineAbove, line)) {
          final more = _cleanMarkdown(line);
          if (proseList != null) {
            carryOn(proseList, more);
          } else {
            description = _joinWrapped(description!, more);
            lineAbove = more;
          }
          continue;
        }
      }

      // Check for section headers FIRST
      final newSection = opens[i];
      if (newSection != _Section.unknown) {
        if (newSection == _Section.instructions) methodHeadersAhead--;
        if (newSection == _Section.ingredients) ingredientHeadersAhead--;
        currentSection = newSection;
        pendingHeading = null;
        lastList = null;
        descriptionAbove = false;
        gapAbove = true;
        numberedList = false;
        titleLinesLeft = 0;
        if (newSection == _Section.ingredients) {
          // "Ingredients (4 servings)", "Zutaten für 4 Personen".
          servings ??= _servingsInHeader(line);
          // "Ingredients for the crust:" names the group it lists.
          pendingHeading = _groupInHeader(line);
        }
        continue;
      }

      // Skip what a social caption leaves behind: a line of hashtags, a short
      // "follow me" line. One lone hashtag at the top is left alone, it may
      // be a heading typed without its space.
      if ((line.length < 80 && _followLine.hasMatch(line)) ||
          (line.startsWith('#') && _hashtagLine.hasMatch(line) && (foundTitle || line.contains(' ')))) {
        continue;
      }
      // And what a recipe card leaves behind: the "1x 2x 3x" buttons that
      // scale it, which copy as lines of the ingredient list.
      if (_scaleButtonsLine.hasMatch(line)) continue;

      // A sub-heading names a part of the dish: "For the sauce:". It stays
      // in the list it stands in and heads the lines under it there. By
      // itself it never moves those lines to another list.
      final heading = currentSection == _Section.notes ? null : _subHeading(line);
      if (heading != null) {
        final next = below(i);
        var heads = currentSection != _Section.unknown;
        if (currentSection == _Section.instructions) {
          // A second list of ingredients may follow the method. Then
          // amounts stand under the sub-heading.
          if (amountsAt(next)) {
            currentSection = _Section.ingredients;
            numberedList = false;
          }
        } else if (currentSection == _Section.unknown) {
          // No header has been read yet. "For the dough:" opens the list
          // itself. A line that only ends in a colon does so when amounts
          // or the method follow it, and on the first line it is the title.
          final methodBelow = methodStartsAt(next, newParagraph: true);
          if (heading.part ? (heading.marked || foundTitle) : (foundTitle && (amountsAt(next) || (methodBelow && ingredients.isNotEmpty)))) {
            heads = true;
            currentSection = methodBelow ? _Section.instructions : _Section.ingredients;
            numberedList = false;
          }
        }
        if (heads) {
          pendingHeading = heading.text;
          lastList = null;
          descriptionAbove = false;
          gapAbove = true;
          titleLinesLeft = 0;
          continue;
        }
      }

      // Extract metadata (servings, times). This comes before the title so
      // that "Serves 4" on the first line is not taken for it. The first
      // value found is kept: a later line must not overwrite it.
      final facts = _extractMetadata(
        line,
        section: currentSection,
        contentBegun: ingredients.isNotEmpty || instructions.isNotEmpty,
      );
      if (facts != null) {
        servings ??= facts.values.servings;
        prepTime ??= facts.values.prepTime;
        cookTime ??= facts.values.cookTime;
        totalTime ??= facts.totalTime;
        // A fact the app has no field for ("Chill Time: 2 hrs", "Makes 1 1/2
        // cups") is kept as a note.
        for (final fact in facts.forNotes) {
          if (!notes.contains(fact)) notes.add(fact);
        }
        lastList = null;
        descriptionAbove = false;
        continue;
      }

      // Extract title. Only above the first header and the first line of
      // content: text that starts at its ingredients has no title, and its
      // first ingredient must not be used up as one.
      final hashed = _hashedHeading.firstMatch(line);
      if (!foundTitle && currentSection == _Section.unknown) {
        if (hashed != null) {
          title = _cleanMarkdown(hashed.group(1)!);
          foundTitle = true;
          continue;
        }

        if (titleLinesLeft > 0 && ingredients.isEmpty && instructions.isEmpty && !_isListItem(line)) {
          titleLinesLeft--;
          // Detect social media caption patterns and extract recipe name
          final socialTitle = _extractSocialTitle(line);
          if (socialTitle != null) {
            title = socialTitle;
            foundTitle = true;
            continue;
          }

          // What stands under the line, the facts aside.
          var next = below(i);
          while (next >= 0 && opens[next] == _Section.unknown && _extractMetadata(lines[next].trim()) != null) {
            next = below(next);
          }
          if (line.length < 150 && _canBeTitle(line, headerBelow: next >= 0 && opens[next] != _Section.unknown)) {
            final name = _cleanMarkdown(line).replaceFirst(_colonAtEnd, '');
            // A file is named after its recipe. A first line only comes
            // before that name when it is set as a title, in bold.
            if (titleIfNone == null || _boldLine.hasMatch(line) || _sameName(name, titleIfNone)) {
              title = name;
              foundTitle = true;
              continue;
            }
          }
        }
      }
      // Any other heading is one this reader has no use for.
      if (hashed != null) continue;

      String cleanedLine = _cleanListMarkers(line);
      cleanedLine = _cleanMarkdown(cleanedLine);

      if (cleanedLine.isEmpty) continue;

      final marked = _isListItem(line);
      final numbered = _isNumbered(line);

      // "501 calories 40g protein 52g carbs" is what the dish holds, not
      // what goes into it.
      if (!marked && currentSection != _Section.notes && _calorieLine.hasMatch(cleanedLine)) {
        notes.add(cleanedLine);
        lastList = null;
        descriptionAbove = false;
        continue;
      }

      // Where the method begins when no header says so: under the list of
      // ingredients, at the first line that reads as a step.
      if (currentSection == _Section.ingredients &&
          ingredients.isNotEmpty &&
          methodStartsAt(i, newParagraph: newParagraph)) {
        currentSection = _Section.instructions;
        numberedList = false;
        lastList = null;
      }

      // Route to appropriate section
      switch (currentSection) {
        case _Section.ingredients:
          if (wrapped &&
              !marked &&
              open(ingredients) &&
              _goesOnIngredient(ingredients.last, lineAbove, cleanedLine, newParagraph: newParagraph)) {
            carryOn(ingredients, cleanedLine);
          } else {
            file(ingredients, cleanedLine);
            if (numbered) numberedList = true;
          }
          break;
        case _Section.instructions:
          // "Step 2" on a line of its own numbers the step under it.
          if (_stepLabel.hasMatch(cleanedLine)) {
            numberedList = true;
            lastList = null;
            break;
          }
          if (wrapped &&
              !marked &&
              open(instructions) &&
              _goesOnStep(lineAbove, cleanedLine, newParagraph: newParagraph, numbered: numberedList)) {
            carryOn(instructions, cleanedLine);
          } else {
            file(instructions, cleanedLine);
            if (numbered) numberedList = true;
          }
          break;
        case _Section.notes:
          if (wrapped &&
              !marked &&
              open(notes) &&
              _goesOnStep(lineAbove, cleanedLine, newParagraph: newParagraph, numbered: false)) {
            carryOn(notes, cleanedLine);
          } else {
            file(notes, cleanedLine, underHeader: false);
          }
          break;
        case _Section.unknown:
          // No header has been read: the line is sorted by what it reads
          // like.
          if (wrapped && !marked && !newParagraph) {
            // The rest of an introduction printed as one paragraph, or of
            // an ingredient or a step that was wrapped.
            if (descriptionAbove && description!.length < _longestEntry && !_startsWithAmount.hasMatch(cleanedLine)) {
              description = _joinWrapped(description, cleanedLine);
              lineAbove = cleanedLine;
              break;
            }
            if (open(ingredients) && _goesOnIngredient(ingredients.last, lineAbove, cleanedLine, newParagraph: false)) {
              carryOn(ingredients, cleanedLine);
              break;
            }
          }

          final step = _readsAsStep(cleanedLine);
          final bool ingredient;
          if (step) {
            ingredient = false;
          } else if (ingredientHeadersAhead > 0) {
            // The text names its ingredients further down. Above that
            // header only a line of amounts is one.
            ingredient = _startsWithAmount.hasMatch(cleanedLine) && _looksLikeIngredient(cleanedLine);
          } else {
            // "Salt and pepper to taste" under a list of amounts belongs
            // to the list.
            ingredient = _looksLikeIngredient(cleanedLine) ||
                (identical(lastList, ingredients) && !newParagraph && _mayEndList(cleanedLine));
          }
          if (ingredient) {
            file(ingredients, cleanedLine, underHeader: false);
            if (numbered) numberedList = true;
            break;
          }

          // "This hearty chili serves 6 and freezes well." The sentence
          // stays, and its number is used if no yield line turns up.
          if (ingredients.isEmpty && instructions.isEmpty) {
            final inProse = _proseYield.firstMatch(cleanedLine);
            if (inProse != null) introServings ??= _servingsNamed(inProse, cleanedLine);
          }

          // A step, unless the text names its method further down: then
          // what stands up here is the introduction. An introduction also
          // comes before the first ingredient and gives no orders.
          final begun = ingredients.isNotEmpty || methodBegun;
          final bool instruction;
          if (methodHeadersAhead > 0) {
            instruction = false;
          } else if (step) {
            instruction = true;
          } else if (!begun) {
            instruction = false;
          } else {
            instruction = _looksLikeInstruction(cleanedLine) ||
                (methodBegun && _readsAsProse(cleanedLine)) ||
                (ingredients.length >= 2 && methodStartsAt(i, newParagraph: newParagraph));
          }
          if (instruction) {
            if (wrapped &&
                !marked &&
                open(instructions) &&
                _goesOnStep(lineAbove, cleanedLine, newParagraph: newParagraph, numbered: numberedList)) {
              carryOn(instructions, cleanedLine);
              break;
            }
            if (!methodBegun) numberedList = false;
            methodBegun = true;
            file(instructions, cleanedLine, underHeader: false);
            if (numbered) numberedList = true;
          } else if (description == null &&
              cleanedLine.length > 20 &&
              cleanedLine.length < 500) {
            description = cleanedLine;
            descriptionAbove = true;
            lineAbove = cleanedLine;
            lastList = null;
          } else if (descriptionAbove &&
              !marked &&
              !newParagraph &&
              _readsAsProse(cleanedLine) &&
              description!.length + cleanedLine.length < 500) {
            // The introduction goes on with a sentence on a line of its own.
            description = '$description $cleanedLine';
            lineAbove = cleanedLine;
          }
          break;
      }
    }

    servings ??= introServings;
    // A total time stands in for the cook time only when none was given.
    if (cookTime == null && totalTime != null) {
      final rest = totalTime - (prepTime ?? 0);
      if (rest > 0) cookTime = rest;
    }

    // Text with no list at all, only a sentence that tells how the dish is
    // made: that sentence is the method and introduces nothing.
    if (ingredients.isEmpty && instructions.isEmpty && description != null && _looksLikeInstruction(description)) {
      instructions = [description];
      description = null;
    }

    // Aggressive fallback
    if (ingredients.isEmpty && instructions.isEmpty) {
      final aggressive = _aggressiveParse(text);
      ingredients = aggressive.ingredients;
      instructions = aggressive.instructions;
    }

    // Safety net for social captions (Instagram/TikTok) that dumped the whole
    // recipe into the instruction block: if we ended up with steps but no
    // ingredients, pull the clearly-ingredient lines (quantity-led, carries a
    // unit, not imperative) out of the instructions and into ingredients.
    if (ingredients.isEmpty && instructions.length >= 3) {
      final moved = <String>[];
      final kept = <String>[];
      for (final line in instructions) {
        if (_isLikelyIngredientLine(line)) {
          moved.add(line);
        } else {
          kept.add(line);
        }
      }
      if (moved.length >= 2) {
        ingredients = moved;
        instructions = kept;
      }
    }

    final recipe = ImportedRecipe(
      title: foundTitle ? title : (titleIfNone ?? title),
      description: description,
      servings: servings,
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      ingredients: _withoutIdleHeadings(_cleanIngredients(ingredients, listed, headings), headings),
      instructions: _withoutIdleHeadings(_cleanInstructions(instructions, listed, headings), headings),
      notes: notes.isNotEmpty ? notes.join('\n') : null,
    );

    _detectCourseAndCategory(recipe);
    return recipe;
  }

  // No step, ingredient or introduction is as long as this.
  static const _longestEntry = 4000;

  /// The lines of [text]. A line longer than any entry of a recipe, such as
  /// a page pasted as one paragraph or a file with no line breaks in it, is
  /// cut after a full stop, or at a space where it has none. No pattern that
  /// reads a line then meets one of a length it was not made for.
  static List<String> _linesOf(String text) {
    final lines = text.split('\n');
    if (lines.every((line) => line.length <= _longestEntry)) return lines;

    const half = _longestEntry ~/ 2;
    final cut = <String>[];
    for (final line in lines) {
      var from = 0;
      while (line.length - from > _longestEntry) {
        // The break is looked for in the second half of the stretch, which
        // keeps every piece a good length.
        final window = line.substring(from + half, from + _longestEntry);
        var stop = window.lastIndexOf('. ');
        if (stop < 0) stop = window.lastIndexOf(' ');
        var end = stop < 0 ? from + _longestEntry : from + half + stop + 1;
        // Not between the two halves of one character.
        if (stop < 0 && (line.codeUnitAt(end) & 0xFC00) == 0xDC00) end--;
        cut.add(line.substring(from, end));
        from = end;
      }
      cut.add(line.substring(from));
    }
    return cut;
  }

  static final _startsWithAmount = RegExp(r'^\.?[\d½¼¾⅓⅔⅛⅜⅝⅞]');
  static final _spaces = RegExp(r'\s+');

  // A rule drawn across the text: "---", "===", "* * *". Three marks make
  // one, and whatever marks and spaces follow them. Written so, the longest
  // rule is matched in one pass, with nothing kept for each of its marks.
  static final _ruleLine = RegExp(r'^(?:[-=_*]\s*){3}[-=_*\s]*$');
  // A count of calories at the head of a line.
  static final _calorieLine = RegExp(r'^\d{1,4}\s*(?:k?cal|calories)\b', caseSensitive: false);
  // An Obsidian embed or a Markdown image and nothing else.
  static final _pictureLine = RegExp(r'^!\[\[[^\]]*\]\]$|^!\[[^\]]*\]\([^)]*\)$');
  static final _hashedHeading = RegExp(r'^#{1,6}\s+(.+)$');

  // A line of nothing but hashtags: "#chicken #dinner #easyrecipes".
  static final _hashtagLine = RegExp(r'^(?:#[\p{L}\p{N}_]+[\s,]*)+$', unicode: true);

  // "Follow @tastykitchen for more recipes!", "Subscribe for more", "Full
  // recipe at the link in bio". "Follow the package directions" is a step.
  static final _followLine = RegExp(
      r'^(?:follow|subscribe)\b[^@]*(?<![\w.])@[\w.]{2,}'
      r'|^(?:follow|subscribe)(?:\s+(?:me|us|along))?\s+for\s+more\b'
      r'|\blink\s+in\s+(?:my\s+|the\s+|our\s+)?bio\b',
      caseSensitive: false);

  // "1x", "1x 2x 3x", "Scale 1x 2x 3x".
  static final _scaleButtonsLine = RegExp(r'^(?:scale\s*:?\s*)?(?:\d(?:[./]\d)?\s?[x×]\s*)+$', caseSensitive: false);

  // A yield inside an ingredients header: "Ingredients (4 servings)",
  // "Ingredients (serves 4)", "Ingredients (for 4 people)".
  static final _headerYield = RegExp(
      r'[(（]\s*(?:(?:serves|makes|yields?|for)\s+(\d{1,3}(?:\s*(?:-|–|to)\s*\d{1,3})?)\b(?![.,/]\d|\s+\d/\d|\s?[½¼¾⅓⅔])'
      r'|(\d{1,3}(?:\s*(?:-|–|to)\s*\d{1,3})?)\s*(?:servings?|portions?|people|persons?))',
      caseSensitive: false);

  // The same as other languages write it, with or without a bracket: "für 4
  // Personen", "pour 4 à 6 personnes", "4 porções", "2人分". Group 1 is a
  // count told after "for", group 2 a count of people or portions.
  static final _headerYieldAbroad = RegExp(
      r'(?:\bfor|\bfür|\bfuer|\bpour|\bpara|\bper|\bvoor|\bdla|на)\s+(?:ca\.?\s+|environ\s+|circa\s+|about\s+)?'
      r'(\d{1,3}(?:\s*(?:-|–|bis|à|a|o|tot|do|to)\s*\d{1,3})?)(?!\s*(?:g|kg|ml|cl|dl|l)\b|[.,]\d|-)'
      r'|(\d{1,3}(?:\s*(?:-|–|bis|à|a|o|tot|do|to)\s*\d{1,3})?)\s*'
      r'(?:servings?|portions?|people|persons?|personen|portionen|stück|stücke|personnes|personas|porciones|raciones'
      r'|comensales|persone|porzioni|pessoas|porções|porties|osób|osoby|porcj[ei]|порци[ийя]|персон[ыа]?|человек'
      r'|人分|人前|人份|인분)',
      caseSensitive: false);

  // A yield told in a sentence: "serves 6", "makes about 24 cookies",
  // "about 4 servings".
  static final _proseYield = RegExp(
      r'\b(?:serves|feeds|makes|yields)\s+(?:(?:about|around|roughly|approximately|up\s+to)\s+)?'
      r'(\d{1,3}(?:\s*(?:-|–|to)\s*\d{1,3})?)\b(?![.,/]\d|\s+\d/\d|\s?[½¼¾⅓⅔])'
      r'|\b(\d{1,3}(?:\s*(?:-|–|to)\s*\d{1,3})?)\s+(?:servings|portions)\b',
      caseSensitive: false);

  /// The servings in a header or a sentence that [found] names, or null when
  /// what it names is a measure: "makes about 2 cups".
  static String? _servingsNamed(RegExpMatch found, String line) {
    if (_measureUnit.matchAsPrefix(line, found.end) != null) return null;
    return _servingsFrom(found.group(1) ?? found.group(2)!);
  }

  /// The servings an ingredients header tells, in any of its languages, or
  /// null when it tells none.
  static String? _servingsInHeader(String line) {
    final inEnglish = _headerYield.firstMatch(line);
    if (inEnglish != null) return _servingsNamed(inEnglish, line);
    final abroad = _headerYieldAbroad.firstMatch(line);
    return abroad == null ? null : _servingsFrom(abroad.group(1) ?? abroad.group(2)!);
  }

  /// The group an ingredients header names, as a sub-heading: "For the
  /// crust:" out of "Ingredients for the crust:". Null when it names none.
  static String? _groupInHeader(String line) {
    final found = _ingredientHeader.firstMatch(_undressed(line).replaceFirst(_colonAtEnd, ''));
    if (found == null) return null;
    final whom = found.namedGroup('whom');
    final name = whom == null ? found.namedGroup('name') : '$whom ${found.namedGroup('what')}';
    // "Ingredients for 4 people" tells a yield.
    if (name == null || _digitOrFraction.hasMatch(name)) return null;
    final group = name.trim();
    return group.length < 2 ? null : '${group[0].toUpperCase()}${group.substring(1)}:';
  }

  // "For the sauce", "For serving", "To serve", "To make the glaze": how a
  // recipe names its parts. "For 4 people" is a yield.
  static final _partOfDish = RegExp(
      r'^(?:for\s+(?!\d)\S|to\s+(?:serve|garnish|finish|decorate|assemble|top|coat|glaze|make|prepare|cook|fry)\b)',
      caseSensitive: false);
  // A whole line set in bold: "**For the frosting:**", "__Topping__".
  static final _boldLine = RegExp(r'^(?:\*\*[^*]+\*\*|__[^_]+__)\s*[:：]?$');
  // "Step 2", "2." and "3)" number a step. They are not its heading.
  static final _stepLabel = RegExp(r'^(?:step\s*)?\d{1,2}\s*[.:)]?$', caseSensitive: false);
  static final _sentenceMark = RegExp(r'[.!?;,]');
  static final _upperStart = RegExp(r'^\p{Lu}', unicode: true);
  static final _lowerStart = RegExp(r'^\p{Ll}', unicode: true);

  /// The sub-heading [line] is, with a colon at its end, or null. A
  /// sub-heading names a part of the dish inside a list: "For the sauce:",
  /// "To serve", "### Filling", "**Topping**", "Dressing:".
  ///
  /// [part] is true for a line that says so in its words ("For the..."),
  /// which is a sub-heading wherever it stands. [marked] is true when it
  /// carries a colon or is set as a heading or in bold. A line that is only
  /// marked heads a group where a list is being read, and may be a title
  /// anywhere else.
  static ({String text, bool part, bool marked})? _subHeading(String line) {
    if (line.length > 64 || _isNumbered(line)) return null;
    final dressed = _boldLine.hasMatch(line) || (line.startsWith('#') && _hashedHeading.hasMatch(line));
    final plain = _undressed(line);
    final colon = _colonAtEnd.hasMatch(plain);
    final text = colon ? plain.replaceFirst(_colonAtEnd, '') : plain;
    if (text.length < 2 || text.length > 47 || !_hasLetter(text)) return null;
    if (_startsWithAmount.hasMatch(text) || _sentenceMark.hasMatch(text)) return null;
    final words = text.split(_spaces).length;
    if (words > 7 || _stepLabel.hasMatch(text)) return null;
    // A label that lost its value is no sub-heading: "Prep Time:".
    if (_bareTimeLabel.hasMatch(text) || _bareYieldLabel.hasMatch(text)) return null;

    final part = _partOfDish.hasMatch(text);
    final marked = colon || dressed;
    if (!marked) {
      if (!part) return null;
      // Without a colon it takes a capital and few words. "For the glaze
      // whisk sugar and lemon juice" is a step.
      final most = text.toLowerCase().startsWith('to') ? 4 : 5;
      if (words > most || !_upperStart.hasMatch(text)) return null;
    }
    return (text: '$text:', part: part, marked: marked);
  }

  /// [list] without the sub-headings that divide nothing: one with no item
  /// under it, and one that stands alone at the top and so heads the whole
  /// list.
  static List<String> _withoutIdleHeadings(List<String> list, Set<String> headings) {
    if (headings.isEmpty) return list;
    final kept = <String>[];
    for (var i = 0; i < list.length; i++) {
      final itemBelow = i + 1 < list.length && !headings.contains(list[i + 1]);
      if (itemBelow || !headings.contains(list[i])) kept.add(list[i]);
    }
    if (kept.where(headings.contains).length == 1 && headings.contains(kept.first)) kept.removeAt(0);
    return kept;
  }

  // "Recipe 2" counts the recipes of a collection. It names none of them.
  static final _recipeCounter = RegExp(r'^recipe\s*(?:#|no\.?\s*)?\d{1,4}[.:)]?$', caseSensitive: false);
  static final _unitWords = {for (final unit in _measurementUnits) unit.toLowerCase()};
  // What stands in front of the first letter of a word: "(Serves",
  // "20-Minute".
  static final _upToLetter = RegExp(r'^[^\p{L}]+', unicode: true);

  /// True when [line], found near the top of a text, can be the name of
  /// the dish. An order to the cook is a step, and a line that opens with an
  /// amount is an ingredient unless it reads as a name: "3 Cup Chicken"
  /// above its Ingredients header ([headerBelow]), "5 Ingredient Peanut
  /// Butter Cookies".
  static bool _canBeTitle(String line, {required bool headerBelow}) {
    final name = _cleanMarkdown(line);
    if (!_hasLetter(name) || _recipeCounter.hasMatch(name)) return false;
    if (name.runes.length < 2 && !_nonLatinLetter.hasMatch(name)) return false;
    // "Stir Fry Chicken" is a name, "Stir fry the chicken" is a step.
    if (!_startsWithAmount.hasMatch(name)) return !_readsAsStep(name) || _titleCased(name);
    if (headerBelow) return true;

    // The words after the amount: a unit makes it an ingredient, capitals
    // make it a name.
    final words = name.split(_spaces).map((w) => w.replaceFirst(_upToLetter, '')).where((w) => w.isNotEmpty).toList();
    if (words.length < 2 || _unitWords.contains(words.first.toLowerCase().replaceAll(_wordEdges, ''))) return false;
    return words.where(_upperStart.hasMatch).length >= words.length - 1;
  }

  // Words that open an ingredient as readily as an order: "Brown sugar",
  // "Cream cheese", "Oil for frying", "Roast chicken", "Top round".
  static const _verbOrFood = {
    'bread', 'brown', 'cool', 'cream', 'crisp', 'cube', 'dip', 'drizzle', 'drop', 'dry', 'dust', 'fillet',
    'garnish', 'glaze', 'layer', 'mash', 'mince', 'oil', 'pack', 'pat', 'puree', 'roast', 'roll', 'rub', 'season',
    'slice', 'spoon', 'spread', 'sprinkle', 'squeeze', 'stuff', 'taste', 'toast', 'top', 'warm', 'whip',
  };

  // What comes after such a word when it is an order: "Cream the butter",
  // "Top with cheese", "Roast for 40 minutes".
  static final _orderGoesOn = RegExp(
      r'^(?:the|a|an|all|both|each|your|some|in|into|on|onto|over|with|together|until|well|everything|it|them|out'
      r'|up|off|down|gently|lightly|evenly|generously|thoroughly|immediately|to\s+taste'
      r'|for\s+(?:about\s+|around\s+|another\s+|at\s+least\s+|up\s+to\s+)?(?:\d|a\s+(?:few|couple)|one|two|three|four|five|ten|several))\b',
      caseSensitive: false);

  // How a step may open before it comes to its verb: "In a large bowl,
  // whisk...", "Once cool, slice".
  static const _stepOpeners = {
    'in', 'into', 'on', 'using', 'with', 'when', 'once', 'while', 'meanwhile', 'after', 'before', 'then', 'next',
    'finally', 'first', 'now', 'if', 'to', 'carefully', 'gradually', 'slowly', 'gently', 'lightly', 'quickly',
  };

  // A full stop, or its like, at the end of a line.
  static final _sentenceEnding = RegExp(r'[.!。！]["”’)\]]?$');

  /// True when [text] tells the cook to do something: "Mix the flour and
  /// sugar.", "Bake 20 minutes", "In a large bowl, whisk the eggs". It opens
  /// with a cooking verb, or comes to one, and reads on like a sentence.
  /// "Brown sugar 100 g", "Oil for frying" and "Drizzle of honey" open with
  /// the same words and are ingredients.
  static bool _readsAsStep(String text) {
    if (text.isEmpty || _startsWithAmount.hasMatch(text)) return false;
    final words = text.toLowerCase().split(_spaces);
    final first = words.first.replaceAll(_wordEdges, '');
    final sentence = _sentenceEnding.hasMatch(text);

    if (_actionVerbs.contains(first)) {
      if (words.length < 2) return false;
      final second = words[1].replaceAll(_wordEdges, '');
      if (second == 'of') return false;
      if (_verbOrFood.contains(first) && !_orderGoesOn.hasMatch(text.substring(words.first.length).trimLeft())) {
        return false;
      }
      return sentence || words.length >= 3;
    }
    if (_stepOpeners.contains(first)) {
      // "To serve: lime wedges" lists what to serve with.
      if (words.first.endsWith(':') || (words.length > 1 && words[1].endsWith(':'))) return false;
      return (sentence || words.length >= 6) &&
          words.skip(1).any((word) => _actionVerbs.contains(word.replaceAll(_wordEdges, '')));
    }
    return false;
  }

  /// True when [text] is a sentence of running text in any language: it
  /// ends like one and has the length of one.
  static bool _readsAsProse(String text) =>
      _sentenceEnding.hasMatch(text) &&
      (text.split(_spaces).length >= 4 || (_nonLatinLetter.hasMatch(text) && text.runes.length >= 8));

  // "20 minutes", "1 hour" at the head of a line.
  static final _opensWithDuration = RegExp('^$_durationPattern', caseSensitive: false);

  /// True when [text] is an ingredient by its amount: "8 oz cream cheese",
  /// "2 eggs". Not "2 minutes per side in a hot pan."
  static bool _readsAsAmountLine(String text) =>
      _startsWithAmount.hasMatch(text) && !_opensWithDuration.hasMatch(text) && _looksLikeIngredient(text);

  /// True when [text] can stand at the end of a list of amounts without one
  /// of its own: "Salt and pepper to taste", "lemon juice".
  static bool _mayEndList(String text) =>
      text.length < 60 &&
      text.split(_spaces).length <= 7 &&
      _hasLetter(text) &&
      !_sentenceEnding.hasMatch(text) &&
      !text.endsWith('?') &&
      !_startsWithActionVerb(text.toLowerCase());

  // ----- Lines that were wrapped on the page -----

  // A sentence that has come to its end. A colon ends one too: a list
  // follows it.
  static final _sentenceClosed = RegExp(r'[.!?:。！？]["”’)\]]?$');
  // A line that breaks off in the middle: at a comma, or at a word that
  // cannot be the last one.
  static final _hangingEnd = RegExp(
      r'(?:[,;(/&-]|\b(?:and|or|the|a|an|of|with|to|in|into|on|onto|over|for|at|by|from|until|then|plus|about|per))$',
      caseSensitive: false);
  // The tail of an ingredient that ran onto a second line: "finely chopped",
  // "peeled and diced", "to serve", "plus more for dusting".
  static final _ingredientTail = RegExp(
      r'^(?:(?:(?:very|finely|roughly|thinly|coarsely|freshly|lightly|thickly|well)\s+)?[a-z]{2,}ed'
      r'(?:\s+(?:and|or)\s+(?:(?:finely|roughly|thinly|coarsely)\s+)?[a-z]{2,}ed)*'
      r'|to\s+(?:taste|serve|garnish|finish|decorate)'
      r'|for\s+(?:frying|greasing|dusting|serving|drizzling|garnish|brushing|sprinkling|the\s+pan|deep[-\s]frying)'
      r'|at\s+room\s+temperature|optional|divided|plus\s+(?:more|extra)\b.{0,40}|or\s+(?:more|to\s+taste)\b.{0,20}'
      r'|as\s+needed|if\s+(?:desired|needed|using))[.)]?$');
  // A word cut in two at the end of a line: "mix-" / "ture".
  static final _brokenWord = RegExp(r'([\p{L}\p{N}]+)-$', unicode: true);
  // What stands before a hyphen that belongs to the word: "all-purpose",
  // "extra-virgin", "medium-high".
  static const _hyphenHeads = {
    'all', 'extra', 'self', 'semi', 'non', 'low', 'full', 'half', 'well', 'medium', 'high', 'bite', 'oven', 'room',
    'deep', 'stir', 'pan', 'slow', 'quick', 'heavy', 'light', 'gluten', 'dairy', 'sugar', 'fat', 'store', 'free',
  };

  /// [above] with the printed line [more] that carries it on. A word that
  /// was cut in two at the line end is made whole again.
  static String _joinWrapped(String above, String more) {
    if (!above.endsWith('-') || !_lowerStart.hasMatch(more)) return '$above $more';
    // The cut word is the end of [above], however long that has grown.
    final broken = _brokenWord.firstMatch(above.length > 40 ? above.substring(above.length - 40) : above);
    if (broken == null) return '$above $more';
    final head = broken.group(1)!.toLowerCase();
    final keepsHyphen = _hyphenHeads.contains(head) || _digitOrFraction.hasMatch(head);
    return keepsHyphen ? '$above$more' : '${above.substring(0, above.length - 1)}$more';
  }

  /// True when the printed [line] carries on the sentence of the line
  /// [above] it: that sentence is not finished and the line opens in lower
  /// case.
  static bool _runsOn(String above, String line) {
    if (!_lowerStart.hasMatch(line) || _sentenceClosed.hasMatch(above)) return false;
    // A short line above an order is a list of steps typed without
    // capitals: "mix flour and sugar" / "add eggs".
    return above.length >= 20 || _hangingEnd.hasMatch(above) || !_startsWithActionVerb(line.toLowerCase());
  }

  /// True when the printed [line] belongs to the step that the line [above]
  /// it is part of, rather than being a step of its own. [numbered] says the
  /// steps of this method carry numbers, [newParagraph] that a gap stood
  /// between the two lines.
  static bool _goesOnStep(String above, String line, {required bool newParagraph, required bool numbered}) {
    final closed = _sentenceClosed.hasMatch(above);
    final lower = _lowerStart.hasMatch(line);
    // Across a gap only an unfinished sentence goes on.
    if (newParagraph) return !closed && lower;
    // Where the steps are numbered, a line with no number is the rest of
    // the step above it.
    if (numbered) return true;
    if (_hangingEnd.hasMatch(above)) return true;
    if (lower) return closed ? !_startsWithActionVerb(line.toLowerCase()) : _runsOn(above, line);
    if (closed) return false;
    // The sentence above is open and this line opens with a capital or a
    // figure: a name or an amount in the middle of it ("Stir in the grated"
    // / "Parmesan", "and cook" / "5 minutes per side"), or the next line of
    // a list written without full stops. A line that was wrapped is a long
    // one, and a list of amounts is no sentence.
    if (above.length < 25) return false;
    if (_startsWithAmount.hasMatch(line)) return !_startsWithAmount.hasMatch(above);
    final first = line.toLowerCase().split(_spaces).first.replaceAll(_wordEdges, '');
    return !_actionVerbs.contains(first) && !_stepOpeners.contains(first);
  }

  // An ingredient that stops at a word which tells of the next one: "1 cup
  // all-purpose" / "flour", "freshly ground black" / "pepper". After a comma
  // the same word ends the line: "pecans, toasted".
  static final _describingEnd = RegExp(
      r'(?<!,)\s(?:all-purpose|plain|self-raising|self-rising|whole|wholemeal|olive|vegetable|extra-virgin|virgin'
      r'|unsalted|salted|black|white|brown|red|green|yellow|light|dark|fresh|freshly|dried|ground|granulated'
      r'|powdered|icing|caster|baking|heavy|double|single|sour|sweet|unsweetened|sweetened|semi-sweet|bittersweet'
      r'|hot|cold|warm|boneless|skinless|kosher|sea|coarse|fine|finely|roughly|thinly|large|medium|small'
      r'|low-sodium|smoked|toasted|roasted)$',
      caseSensitive: false);

  /// True when the printed [line] is the rest of the [ingredient] that the
  /// line [above] it belongs to.
  static bool _goesOnIngredient(String ingredient, String above, String line, {required bool newParagraph}) {
    // A bracket left open runs on, whatever follows: "(about" / "14 ounces)".
    final open = '('.allMatches(ingredient).length > ')'.allMatches(ingredient).length;
    if (open && !newParagraph) return true;
    if (_startsWithAmount.hasMatch(line)) return false;
    final hanging = open || _hangingEnd.hasMatch(above);
    if (newParagraph) return hanging && _lowerStart.hasMatch(line);
    if (hanging || _ingredientTail.hasMatch(line)) return true;
    return _describingEnd.hasMatch(above) && _lowerStart.hasMatch(line) && line.split(_spaces).length <= 3;
  }

  /// True when [a] and [b] name the same thing, whatever their capitals,
  /// spaces and hyphens: "Thai Green Curry" and "thai-green-curry".
  static bool _sameName(String a, String b) =>
      a.toLowerCase().replaceAll(_notLettersOrDigits, '') == b.toLowerCase().replaceAll(_notLettersOrDigits, '');

  // How a picture opens in Markdown: "![alt](".
  static final _pictureOpening = RegExp(r'!\[[^\]\[\n]{0,300}\]\(');
  static final _linkAtStart = RegExp(r'^https?://\S+');

  /// What the first picture of a Markdown [text] points to: all that stands
  /// between its brackets. With [linked] it is the first picture that is a
  /// link, without the caption that may follow the link. Null when the text
  /// has no such picture.
  ///
  /// The closing bracket is looked for on the same line and close by. A
  /// text full of unclosed brackets is then not read to its end from every
  /// one of them.
  static String? _pictureIn(String text, {bool linked = false}) {
    for (final opening in _pictureOpening.allMatches(text)) {
      final limit = opening.end + 2000;
      final rest = text.substring(opening.end, limit < text.length ? limit : text.length);
      final close = rest.indexOf(')');
      if (close <= 0) continue;
      final target = rest.substring(0, close);
      if (target.contains('\n')) continue;
      if (!linked) return target;
      final link = _linkAtStart.stringMatch(target);
      if (link != null) return link;
    }
    return null;
  }

  /// Reads a Markdown file that has no front matter. [fileTitle] is what the
  /// name of the file says the recipe is called.
  static ImportedRecipe _parseMarkdown(String text, {String? fileTitle}) {
    // Strip code fences
    text = text.replaceAll(RegExp(r'~~~[\s\S]*?~~~', multiLine: true), '');
    final recipe = _parseStructuredText(text, titleIfNone: fileTitle);
    recipe.imageUrl ??= _pictureIn(text, linked: true);
    return recipe;
  }

  // ========== OBSIDIAN / YAML FRONTMATTER ==========

  // Front matter opens with a line of exactly three dashes at the very top
  // and is closed by another. A longer rule of dashes is only a rule.
  static final _frontMatterBlock = RegExp(r'^\s*---[ \t]*\n([\s\S]*?)\n---[ \t]*(?:\n|$)');
  static final _yamlKey = RegExp(r'^[\p{L}_][\p{L}\p{N}_ .\-]*:(?:\s|$)', unicode: true);
  static final _yamlItem = RegExp(r'^\s*-\s+(.*)$');

  /// The front matter of [text] and the note under it, or null when the text
  /// has none. Two rules with a title between them are not front matter:
  /// every line of the real thing is a key, an item of a list, the indented
  /// rest of a value or a comment.
  static ({String yaml, String body})? _splitFrontMatter(String text) {
    final block = _frontMatterBlock.firstMatch(text);
    if (block == null) return null;
    final yaml = block.group(1)!;
    var keys = 0;
    for (final line in yaml.split('\n')) {
      if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
      if (_yamlItem.hasMatch(line) || line.startsWith(' ')) continue;
      // A key stands at the head of its line, however long the value is.
      if (!_yamlKey.hasMatch(line.length > 200 ? line.substring(0, 200) : line)) return null;
      keys++;
    }
    return keys == 0 ? null : (yaml: yaml, body: text.substring(block.end));
  }

  /// [value] without the quotes around it. A lone quote has no pair to take
  /// off and stands for nothing.
  static String _unquoted(String value) {
    final v = value.trim();
    if (v == '"' || v == "'") return '';
    final quoted = v.length > 1 && ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'")));
    return quoted ? v.substring(1, v.length - 1).trim() : v;
  }

  /// The items of a list written on one line: "[dinner, beef]" or "dinner,
  /// beef".
  static List<String> _inlineList(String value) {
    var list = value.trim();
    if (list.startsWith('[') && list.endsWith(']')) list = list.substring(1, list.length - 1);
    return list.split(',').map(_unquoted).where((item) => item.isNotEmpty).toList();
  }

  // A rating told in stars.
  static final _starSign = RegExp(r'[★⭐]');
  // "4", "4.5", "4/5", "8 / 10".
  static final _ratingFigure = RegExp(r'(\d+(?:[.,]\d+)?)(?:\s*/\s*(\d+))?');

  /// A rating as a number of stars out of five, from "4", "4.5", "8/10" or
  /// "★★★★". Null when [value] tells none.
  static int? _starsOutOfFive(String value) {
    double? stars;
    final signs = _starSign.allMatches(value).length;
    final figure = _ratingFigure.firstMatch(value);
    if (signs > 0) {
      stars = signs.toDouble();
    } else if (figure != null) {
      stars = double.tryParse(figure.group(1)!.replaceAll(',', '.'));
      final outOf = double.tryParse(figure.group(2) ?? '');
      if (stars != null && outOf != null && outOf > 0) stars = stars / outOf * 5;
    }
    // A figure of hundreds of digits is no number any more, and no rating.
    if (stars == null || !stars.isFinite) return null;
    final rounded = stars.round();
    return rounded >= 1 && rounded <= 5 ? rounded : null;
  }

  static final _webLink = RegExp(r'''https?://[^\s)\]>"']+''');

  /// Reads a note that opens with front matter. [fileTitle] is what the name
  /// of the file says the recipe is called. A title in the front matter and
  /// a heading in the note both come before it.
  static ImportedRecipe _parseObsidianMarkdown(String text, {String? fileTitle}) {
    String? title;
    String? description;
    String? imageUrl;
    String? sourceUrl;
    int? rating;
    int? prepTime;
    int? cookTime;
    int? totalTime;
    String? servingsStr;
    List<String>? tags;
    String? cuisine;
    String? course;
    var yamlIngredients = const <String>[];
    var yamlSteps = const <String>[];

    final frontMatter = _splitFrontMatter(text);
    String bodyText = text;

    if (frontMatter != null) {
      bodyText = frontMatter.body.trim();

      // Parse YAML into a simple key→value map, collecting multi-line lists
      final yamlMap = <String, String>{};
      final yamlLists = <String, List<String>>{};
      String? currentListKey;

      for (final line in frontMatter.yaml.split('\n')) {
        if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;

        // An item of a list, indented or not, and the lines of a value
        // that was written as a block under its key.
        final listKey = currentListKey;
        final item = _yamlItem.firstMatch(line);
        if (listKey != null && (item != null || line.startsWith(' '))) {
          final value = _unquoted(item?.group(1) ?? line);
          if (value.isNotEmpty) yamlLists.putIfAbsent(listKey, () => []).add(value);
          continue;
        }

        final colonIdx = line.indexOf(':');
        if (colonIdx == -1) continue;

        // "Prep Time", "prep-time", "prep_time" and "prepTime" are one key.
        final key = line.substring(0, colonIdx).toLowerCase().replaceAll(RegExp(r'[\s\-_]+'), '');
        final value = _unquoted(line.substring(colonIdx + 1));

        // Empty value after colon means next lines are a list
        if (value.isEmpty || value == '|' || value == '>') {
          currentListKey = key;
          continue;
        }
        currentListKey = null;
        // What a key tells is short. A value that is not is cut down to a
        // length the readers of times, ratings and links are made for.
        yamlMap[key] = value.length > _longestEntry ? value.substring(0, _longestEntry) : value;
      }

      String? firstOf(List<String> keys) {
        for (final key in keys) {
          final value = yamlMap[key];
          if (value != null) return value;
        }
        return null;
      }

      // Extract values from parsed YAML
      title = firstOf(['title', 'name']);
      description = firstOf(['description', 'summary']) ?? yamlLists['description']?.join(' ');
      imageUrl = firstOf(['cover', 'image', 'photo']);
      cuisine = yamlMap['cuisine'];

      // Map course/type to a known course ID
      final rawCourse = firstOf(['type', 'course', 'category']);
      if (rawCourse != null) {
        course = mapToCourseId(rawCourse);
      }

      final rawPrep = firstOf(['preptime', 'prep']);
      if (rawPrep != null) prepTime = _parseTimeString(rawPrep);
      final rawCook = firstOf(['cooktime', 'cook']);
      if (rawCook != null) cookTime = _parseTimeString(rawCook);
      final rawTotal = firstOf(['totaltime', 'total', 'time']);
      if (rawTotal != null) totalTime = _parseTimeString(rawTotal);

      final rawServings = firstOf(['servings', 'serves', 'yield', 'yields', 'makes', 'portions']);
      if (rawServings != null) {
        // Extract first number only (e.g. "4–6 taquitos" → "4", "16 pieces" → "16")
        final firstNum = RegExp(r'\d+').firstMatch(rawServings);
        servingsStr = firstNum?.group(0) ?? rawServings;
      }

      // Where the recipe came from: a link, or a name as it was written.
      final rawSource = firstOf(['source', 'sourceurl', 'url', 'link']);
      if (rawSource != null) {
        final named = _cleanMarkdown(rawSource);
        sourceUrl = _webLink.firstMatch(rawSource)?.group(0) ?? (named.isEmpty ? null : named);
      }

      final rawRating = firstOf(['rating', 'stars']);
      if (rawRating != null) rating = _starsOutOfFive(rawRating);

      // Tags: support both inline [a, b] and multi-line YAML list
      final rawTags = firstOf(['tags', 'tag']);
      tags = yamlLists['tags'] ?? yamlLists['tag'] ?? (rawTags == null ? null : _inlineList(rawTags));

      // A recipe kept entirely in front matter, as Jekyll sites keep them.
      yamlIngredients = yamlLists['ingredients'] ?? const [];
      yamlSteps = yamlLists['directions'] ??
          yamlLists['instructions'] ??
          yamlLists['steps'] ??
          yamlLists['method'] ??
          const [];
    }

    // Remove Obsidian-specific blocks
    bodyText = bodyText.replaceAll(RegExp(r'```button[\s\S]*?```'), '');
    bodyText = bodyText.replaceAll(RegExp(r'```dataview[\s\S]*?```'), '');
    bodyText = _withoutTemplateTags(bodyText);

    // Extract image from Obsidian ![[...]] or standard ![](...) syntax. The
    // name of an embed ends at the next bracket or line, so a note full of
    // unclosed brackets is not searched to its end from every one of them.
    if (imageUrl == null) {
      final obsidianImg = RegExp(r'!\[\[([^\]\[\n]{1,300})\]\]').firstMatch(bodyText);
      imageUrl = obsidianImg?.group(1) ?? _pictureIn(bodyText);
    }

    // Parse body as structured text to get ingredients/instructions. With
    // the title in hand, its first line is content and not a second title.
    final parsed = _parseStructuredText(bodyText, titleKnown: title != null, titleIfNone: fileTitle);

    // With both lists in the front matter, the note under it is a note.
    final inFrontMatter = yamlIngredients.isNotEmpty && yamlSteps.isNotEmpty;
    final bodyAsNote = _linesOf(bodyText)
        .map((line) => _cleanMarkdown(_cleanListMarkers(line.trim().replaceFirst(RegExp(r'^#{1,6}\s*'), ''))))
        .where((line) => line.isNotEmpty && !_ruleLine.hasMatch(line))
        .join('\n');

    final prep = prepTime ?? parsed.prepTimeMinutes;
    var cook = cookTime ?? parsed.cookTimeMinutes;
    // A total time stands in for the cook time only when none was given.
    if (cook == null && totalTime != null && totalTime > (prep ?? 0)) cook = totalTime - (prep ?? 0);

    final recipe = ImportedRecipe(
      title: title ?? parsed.title,
      description: description ?? (inFrontMatter ? null : parsed.description),
      imageUrl: imageUrl ?? parsed.imageUrl,
      prepTimeMinutes: prep,
      cookTimeMinutes: cook,
      servings: servingsStr ?? parsed.servings,
      ingredients: yamlIngredients.isNotEmpty ? yamlIngredients : parsed.ingredients,
      instructions: yamlSteps.isNotEmpty ? yamlSteps : parsed.instructions,
      notes: inFrontMatter ? (bodyAsNote.isEmpty ? null : bodyAsNote) : parsed.notes,
      tags: tags,
      cuisine: cuisine,
      sourceUrl: sourceUrl,
      rating: rating,
    );
    // The course is guessed from the title the recipe ends up with. One the
    // front matter states comes first.
    _detectCourseAndCategory(recipe);
    if (course != null) recipe.suggestedCourse = course;
    return recipe;
  }

  /// [text] without the "<% ... %>" tags a template leaves in a note. The
  /// text is gone through once: where a tag is never closed, nothing after
  /// it is one either.
  static String _withoutTemplateTags(String text) {
    var open = text.indexOf('<%');
    if (open < 0) return text;
    final kept = StringBuffer();
    var from = 0;
    while (open >= 0) {
      final close = text.indexOf('%>', open + 2);
      if (close < 0) break;
      kept.write(text.substring(from, open));
      from = close + 2;
      open = text.indexOf('<%', from);
    }
    kept.write(text.substring(from));
    return kept.toString();
  }

  // Names a file is given when nobody names it.
  static final _namelessFile = RegExp(
      r'^(?:untitled|new\s+(?:note|recipe|document|file)|recipes?|notes?|index|readme|pasted|document|draft|scan'
      r'|export|import|backup|file|text|temp|tmp|test|page|img|image|photo|screenshot)[\s\d()._-]*$',
      caseSensitive: false);

  /// What the name of a file says its recipe is called: "Thai Green Curry"
  /// for "Food/Mains/Thai Green Curry.md". Null for a name that says
  /// nothing, such as "Untitled.md" or "2024-03-05.md".
  static String? _fileTitle(String filename) {
    var name = filename.split(RegExp(r'[\\/]')).last;
    final dot = name.lastIndexOf('.');
    if (dot > 0) name = name.substring(0, dot);
    // "thai-green-curry" is a name in the spelling of a link.
    if (!name.contains(' ') && name == name.toLowerCase()) {
      name = name
          .split(RegExp(r'[-_]+'))
          .where((word) => word.isNotEmpty)
          .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
          .join(' ');
    }
    name = name.trim();
    return _hasLetter(name) && !_namelessFile.hasMatch(name) ? name : null;
  }

  /// [recipe] with the name of its file for a title, when the text gave it
  /// none.
  static ImportedRecipe _namedByFile(ImportedRecipe recipe, String filename) {
    final fileTitle = _fileTitle(filename);
    if (recipe.title == 'Untitled Recipe' && fileTitle != null) {
      recipe.title = fileTitle;
      _detectCourseAndCategory(recipe);
    }
    return recipe;
  }

  // ========== OCR TEXT CLEANUP ==========

  // What a screenshot or a scanned page carries besides the recipe. Every
  // pattern here describes a whole line. A recipe line that only starts with
  // one of these words, or has one inside it, is never clutter: "Homemade
  // Granola", "Save the pasta water", "5g salt", "Bake the cookies".

  // A phone status bar: clock, carrier, signal and battery, in any order.
  static final _statusBarLine = RegExp(
      r'^(?:(?:\d{1,2}:\d{2}(?:\s*[AP]M)?|5G\+?|4G|3G|LTE|Wi-?Fi|AT&T|T-Mobile|Verizon|Sprint|Vodafone|\d{1,3}\s?%)(?:\s+|$))+$',
      caseSensitive: false);

  // The browser's address bar: a domain or a link on a line of its own.
  static final _addressBarLine = RegExp(
      r'^(?:https?://)?(?:[a-z0-9-]+\.)+(?:com|org|net|edu|gov|info|blog|kitchen|recipes|food|cooking|app|io|tv|co'
      r'|uk|us|ca|au|nz|ie|eu|de|at|ch|be|fr|es|it|nl|se|no|dk|fi|pl|pt|br|mx|ru|jp|kr|cn|in)(?::\d+)?(?:[/?#]\S*)?$',
      caseSensitive: false);

  // A page number with a word in it: "Page 12", "12 of 240".
  static final _pageNumberLine = RegExp(
      r'^(?:page\s+\d{1,4}(?:\s*(?:of|/)\s*\d{1,4})?|\d{1,4}\s+of\s+\d{1,4})$',
      caseSensitive: false);

  // Menus and share buttons: a line made of button labels and nothing else.
  // Matched against the line in lower case with its punctuation taken out.
  static final _buttonLabels = RegExp(
      r'^(?:(?:home|back|menu|search|recipes|saved|tweet|email|subscribe'
      r'|facebook|pinterest|twitter|instagram|whatsapp|youtube|tiktok'
      r'|log ?in|sign ?in|sign ?up|read more|see more|show more|pin it|back to top'
      r'|skip to content|skip to recipe|jump to recipe|jump to video|jump to comments'
      r'|leave a review|leave a comment|i made it|cook mode|prevent your screen from going dark'
      r'|add to (?:shopping list|meal plan|collection|cart|favou?rites)|us customary(?: metric)?'
      r'|privacy policy|cookie policy|terms of use|terms of service|terms (?:and )?conditions|contact us|about us'
      r'|(?:share|save|print|rate|pin)(?: this)?(?: recipe)?(?: on (?:facebook|pinterest|twitter|instagram|whatsapp))?)(?: |$))+$');

  // A breadcrumb trail: "Home > Recipes > Chicken", "Recipes /...".
  static final _breadcrumbLine = RegExp(
      r'^(?:home|recipes)\s*[>›»/|→]\s*\S|^[a-z]+\s*/\.{3}',
      caseSensitive: false);

  // Share and rating counters: "123 shares", "12,640 Reviews", "1.2K likes",
  // "4.9 from 312 votes", "4.8 out of 5", "No ratings yet".
  static final _counterLine = RegExp(
      r'^\d[\d.,]*\s?[km]?\s*(?:shares?|likes?|comments?|pins?|saves?|views?|followers?|reviews?|ratings?|photos?)$'
      r'|^\d(?:[.,]\d+)?\s+from\s+\d[\d.,]*\s+(?:votes?|reviews?|ratings?)$'
      r'|^(?:a\s+star\s+rating\s+of\s+)?\d(?:[.,]\d+)?\s*(?:stars?|out\s+of\s+\d{1,2}(?:\s+stars?)?)\W*$'
      r'|^no\s+(?:ratings|reviews)\s+yet\W*$',
      caseSensitive: false);

  // A cookie banner says who uses cookies and talks about the site in the
  // same breath. "You can use cookies instead of graham crackers" does not.
  static final _usesCookies = RegExp(
      r'\b(?:uses?|using|use\s+of)\s+(?:\w+\s+)?cookies\b',
      caseSensitive: false);
  static final _siteTalk = RegExp(
      r'\b(?:(?:web)?sites?|(?:your|best|browsing|user|online)\s+experience|browsing|consent|privacy|policy'
      r'|personali[sz]\w*|analytics|advertising|ads|traffic|partners)\b',
      caseSensitive: false);
  // The banner's opening words, when the rest of it wrapped onto other lines.
  static final _cookieNoticeLine = RegExp(
      r'^(?:we|(?:this|our)\s+(?:web)?site)\s+uses?\s+cookies\W*$',
      caseSensitive: false);

  // The buttons of a cookie banner. "Cookie options" may head a list of
  // cookies to bake, so the plain words stand with a banner word only.
  static final _consentButtonLine = RegExp(
      r'^(?:(?:accept|reject|decline|deny)(?: all)?(?: cookies)?'
      r'|allow (?:all(?: cookies)?|cookies)'
      r'|cookies? (?:policy|settings|preferences|notice|consent)'
      r'|(?:manage|change|privacy|consent) (?:(?:cookies?|consent|privacy) )?(?:preferences|settings|choices|options)'
      r'|your privacy choices)\W*$',
      caseSensitive: false);

  // Footers. "(c)" needs a year or the word after it, "(c) Fold in the
  // butter" is a lettered step.
  static final _copyrightLine = RegExp(
      r'^(?:©|\(c\)\s*(?:copyright\b|\d{4})|copyright\b|all rights reserved|powered by\s+\S+(?:\s+\S+){0,3}$)',
      caseSensitive: false);

  static final _adLine = RegExp(
      r'^(?:advertisements?|sponsored(?:\s+(?:content|post|links?))?|ads?(?:\s+by\s+\w+)?)\W*$',
      caseSensitive: false);

  // The placeholder a browser shows for a picture that did not load.
  static final _missingImageLine = RegExp(
      r'^(?:(?:the|this)\s+)?(?:requested\s+)?(?:image|photo|picture|page|file|video|link|resource)\b[^.!?]{0,40}\bcould not be found\W*$',
      caseSensitive: false);

  // Bullets and stray marks in front of a line. A fraction, an accented
  // letter, an opening bracket and the point of ".5 cup" are part of the line.
  static final _leadingMarks = RegExp(r'^(?:[^\p{L}\p{N}(\[.]|\.(?!\d))+', unicode: true);
  // So is a quotation mark that the line closes again: "Nice" Cream, «Tarte»
  // aux pommes. A lone one is a speck, and the mark in 9" stands for inches.
  static final _quotedOpening = RegExp(
      r'"(?=\p{L})[^"]*[\p{L}.,!?]"|“(?=\p{L})[^“”]*”|„(?=\p{L})[^„“”]*[“”]|«(?=\p{L})[^«»]*»',
      unicode: true);
  static const _openingQuotes = '"“„«';
  // Most lines open with a plain letter, a digit or a bracket and have
  // nothing in front of them. Seeing that is much quicker than telling the
  // letters and digits of every alphabet from the marks.
  static final _plainStart = RegExp(r'^[A-Za-z0-9(]');

  /// [line] without the bullets and stray marks in front of it.
  static String _withoutLeadingMarks(String line) {
    if (_plainStart.hasMatch(line)) return line;
    final marks = _leadingMarks.matchAsPrefix(line);
    if (marks == null) return line;
    // Only the last of the marks can be a quotation mark with a letter after
    // it.
    final last = marks.end - 1;
    final quoted = _openingQuotes.contains(line[last]) && _quotedOpening.matchAsPrefix(line, last) != null;
    return line.substring(quoted ? last : marks.end);
  }

  /// Menus, share buttons, banners and footers: what rides along when a
  /// recipe is copied out of a web page, or is caught in a screenshot of one.
  static bool _isPageFurniture(String line) {
    if (_breadcrumbLine.hasMatch(line)) return true;
    if (line.length < 80 && _isButtonRow(line.toLowerCase())) return true;
    if (_counterLine.hasMatch(line)) return true;
    if (_consentButtonLine.hasMatch(line)) return true;
    if (_cookieNoticeLine.hasMatch(line)) return true;
    if (line.length < 200 && _usesCookies.hasMatch(line) && _siteTalk.hasMatch(line)) return true;
    if (_copyrightLine.hasMatch(line)) return true;
    return _adLine.hasMatch(line);
  }

  /// True when [lower] is made of button labels and nothing else, whatever
  /// marks stand between them.
  static bool _isButtonRow(String lower) {
    // Letters of every alphabet are kept, so a line in another script with
    // one English word in it is not taken for a button. Telling all those
    // letters apart is slow. A row of buttons also passes with the letters
    // of the labels alone, and that quick look rules out nearly every line.
    return _buttonLabels.hasMatch(lower.replaceAll(_notPlainLettersOrDigits, ' ').trim()) &&
        _buttonLabels.hasMatch(lower.replaceAll(_notLettersOrDigits, ' ').trim());
  }

  static final _notPlainLettersOrDigits = RegExp(r'[^a-z0-9]+');
  static final _notLettersOrDigits = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

  /// Page furniture, and what only a screenshot or a scan carries: the
  /// phone's status bar, the address bar, page numbers and rules.
  static bool _isScreenClutter(String line) {
    if (_statusBarLine.hasMatch(line)) return true;
    // No letter in any alphabet.
    if (!_hasLetter(line)) return true;
    if (_addressBarLine.hasMatch(line)) return true;
    if (_pageNumberLine.hasMatch(line)) return true;
    if (_missingImageLine.hasMatch(line)) return true;
    return _isPageFurniture(line);
  }

  /// True for a short line in capitals with no digits: a running header such
  /// as "DESSERTS", but just as well a title or "OLIVE OIL".
  static bool _isShortCapsLine(String line) {
    return line.length > 3 &&
        line.length < 20 &&
        line == line.toUpperCase() &&
        line != line.toLowerCase() &&
        !RegExp(r'\d').hasMatch(line) &&
        _detectSectionHeader(line) == _Section.unknown;
  }

  // The last word of a wrapped sentence may stand on a line of its own:
  // "it.", "up", "of".
  static final _shortTail = RegExp(r'^[a-z]{1,2}[.,;!?]?$');

  /// [text] without the screen clutter, one line for each printed line. The
  /// paragraphs of the page stay apart: where the recogniser left a blank
  /// line, or a page ended, one blank line is kept.
  static String _cleanOcrText(String text) {
    final lines = _linesOf(text);
    final filtered = <String>[];
    // The page each kept line came from. Pages are divided by a "---" line.
    final pageOf = <int>[];
    // The kept lines that open a paragraph.
    final opensParagraph = <bool>[];
    var page = 0;
    var gap = false;

    for (var line in lines) {
      var trimmed = line.trim();

      if (trimmed.isEmpty) {
        gap = true;
        continue;
      }
      if (trimmed == '---') {
        page++;
        gap = true;
        continue;
      }

      // The number printed under a "Servings" label is kept for it. In a
      // box read row by row, the label is a few lines further up.
      final valueOfLabel = RegExp(r'^\d{1,3}(?:\s*[-–]\s*\d{1,3})?$').hasMatch(trimmed) &&
          filtered.skip(filtered.length > 4 ? filtered.length - 4 : 0).any(_bareYieldLabel.hasMatch);

      if (!valueOfLabel) {
        // One or two characters are specks, unless they are a word in a
        // script that writes one in a single sign, or the last word of the
        // sentence above.
        final tail = !gap && filtered.isNotEmpty && _shortTail.hasMatch(trimmed);
        if (trimmed.length < 3 && !tail && !_nonLatinLetter.hasMatch(trimmed)) continue;
        if (_isScreenClutter(trimmed)) continue;
      }

      trimmed = _withoutLeadingMarks(trimmed);

      if (trimmed.isNotEmpty) {
        filtered.add(trimmed);
        pageOf.add(page);
        opensParagraph.add(gap);
        gap = false;
      }
    }

    // A short line in capitals that opens or closes one page after another is
    // a running header. The first one is kept: a title looks just the same.
    final repeats = <int>{};
    if (page > 0) {
      final firstSeenOn = <String, int>{};
      for (var i = 0; i < filtered.length; i++) {
        final opensPage = i == 0 || pageOf[i - 1] != pageOf[i];
        final closesPage = i == filtered.length - 1 || pageOf[i + 1] != pageOf[i];
        if (!(opensPage || closesPage) || !_isShortCapsLine(filtered[i])) continue;
        if (firstSeenOn.putIfAbsent(filtered[i], () => pageOf[i]) != pageOf[i]) repeats.add(i);
      }
    }

    final cleaned = StringBuffer();
    var apart = false;
    for (var i = 0; i < filtered.length; i++) {
      apart = apart || opensParagraph[i];
      if (repeats.contains(i)) continue;
      if (cleaned.isNotEmpty) cleaned.write(apart ? '\n\n' : '\n');
      cleaned.write(filtered[i]);
      apart = false;
    }
    return cleaned.toString();
  }

  // ========== AGGRESSIVE FALLBACK ==========

  static ImportedRecipe _aggressiveParse(String text) {
    final lines = _linesOf(text)
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

  /// [line] without what a header may be dressed in: heading marks,
  /// emphasis, an emoji in front. A colon at the end stays, wherever the
  /// emphasis put it: "**Ingredients:**" and "**Ingredients**:" both come
  /// back as "Ingredients:".
  static String _undressed(String line) {
    var text = line.trim().replaceAll(_headerDress, '');
    final colon = _colonAtEnd.hasMatch(text);
    if (colon) text = text.replaceFirst(_colonAtEnd, '');
    text = _cleanMarkdown(text.replaceAll(_headerDress, '')).replaceAll(_headerDress, '');
    return colon ? '$text:' : text;
  }

  static _Section _detectSectionHeader(String line) {
    final cleanLine = line.trim();
    // No header runs to the length of a sentence.
    if (cleanLine.isEmpty || cleanLine.length > 80) return _Section.unknown;

    var words = _undressed(cleanLine);
    final colon = _colonAtEnd.hasMatch(words);
    if (colon) words = words.replaceFirst(_colonAtEnd, '');

    final _Section section;
    if (_ingredientHeader.hasMatch(words)) {
      section = _Section.ingredients;
    } else if (_methodHeader.hasMatch(words)) {
      section = _Section.instructions;
    } else if (_notesHeader.hasMatch(words)) {
      section = _Section.notes;
    } else {
      return _Section.unknown;
    }
    // A header stands apart by its capital, its colon or its shortness.
    // Running text may open with the same words: "ingredients for the sauce
    // and stir until smooth".
    if (!colon && _lowerStart.hasMatch(words) && words.split(_spaces).length > 4) return _Section.unknown;
    return section;
  }

  // ========== SCORING ==========

  static bool _looksLikeIngredient(String text) =>
      _ingredientScore(text) > 0.4;

  // The units of measure as one pattern.
  static final _unitsPattern = _measurementUnits.map(RegExp.escape).join('|');
  static final _unitInText = RegExp('\\b(?:$_unitsPattern)\\b', caseSensitive: false);
  static final _amountWithUnit = RegExp('[\\d½¼¾⅓⅔⅛⅜⅝⅞]\\s*-?\\s*(?:$_unitsPattern)\\b', caseSensitive: false);
  // How a line of ingredients may open: with a figure, or with an amount in
  // words.
  static final _opensWithQuantity = RegExp(
      r'^(?:\.?\d|[½¼¾⅓⅔⅛⅜⅝⅞⅕⅖⅗⅘⅙⅚]|(?:a|an|one|two|three|four|five|six|half|pinch|dash|handful)\b)',
      caseSensitive: false);
  static final _opensWithUnit = RegExp('^(?:(?:large|medium|small)\\s+[a-z]|(?:$_unitsPattern)\\s+of\\b)');

  static double _ingredientScore(String text) {
    double score = 0;
    final lower = text.toLowerCase();

    if (text.length < 100) score += 0.1;
    if (text.length < 60) score += 0.1;
    if (text.length > 150) score -= 0.3;

    if (RegExp(r'^\.?\d').hasMatch(text)) score += 0.3;
    if (_unicodeFractions.any((f) => text.startsWith(f))) score += 0.3;
    if (RegExp(r'^\d+/\d+').hasMatch(text)) score += 0.3;

    // A unit counts where an amount stands with it: at the head of the
    // line, or right in front of the unit as in "Butter 200 g". So does a
    // unit that opens the line itself: "Can of tomatoes", "Large onion". A
    // step that mentions "a large skillet" or "180°C" has none of these.
    final unit = _opensWithQuantity.hasMatch(text) ? _unitInText : _amountWithUnit;
    if (unit.hasMatch(lower) || _opensWithUnit.hasMatch(lower)) score += 0.3;

    if (_unicodeFractions.any((f) => text.contains(f))) score += 0.2;
    if (RegExp(r'\d/\d').hasMatch(text)) score += 0.2;
    if (!RegExp(r'\.\s+[A-Z]').hasMatch(text)) score += 0.1;
    if (!_containsActionVerb(text)) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  static bool _looksLikeInstruction(String text) =>
      _instructionScore(text) > 0.4;

  /// Conservative test used to rescue ingredient lines that a messy social
  /// caption dumped into the instruction block: quantity-led, carries a
  /// measurement unit (or is short with no sentence punctuation), and is NOT an
  /// imperative step. Deliberately strict so real instructions aren't demoted.
  static bool _isLikelyIngredientLine(String line) {
    final t = line.trim();
    if (t.length < 3 || t.length > 80) return false;
    if (_startsWithActionVerb(t.toLowerCase())) return false; // "Dip...", "Mix..."
    final startsWithQty = RegExp(r'^\d').hasMatch(t) ||
        _unicodeFractions.any((f) => t.startsWith(f)) ||
        RegExp(r'^(a|an|one|two|three|four|five|six|seven|eight|half)\s',
                caseSensitive: false)
            .hasMatch(t);
    if (!startsWithQty) return false;
    final hasUnit = _unitInText.hasMatch(t);
    final looksProse = RegExp(r'[.!?]\s+\S').hasMatch(t); // multiple sentences
    return hasUnit || (t.length < 45 && !looksProse);
  }

  static double _instructionScore(String text) {
    double score = 0;
    final lower = text.toLowerCase();

    if (text.length > 40) score += 0.2;
    if (text.length > 80) score += 0.1;
    if (text.length < 15) score -= 0.3;

    if (_containsActionVerb(text)) score += 0.4;
    if (_startsWithActionVerb(lower)) score += 0.3;

    if (RegExp(r'\d\s*(minutes?|mins?|hours?|hrs?|seconds?|secs?)')
        .hasMatch(lower)) {
      score += 0.2;
    }

    if (RegExp(r'\d\s*(?:°\s*)?[FCfc]').hasMatch(text)) score += 0.2;
    if (text.endsWith('.')) score += 0.1;
    if (RegExp(r'[.;,]\s+[A-Z]').hasMatch(text)) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  // ========== VALIDATION ==========

  static const _headerWords = [
    'ingredients', 'directions', 'instructions', 'method', 'steps',
    'notes', 'tips', 'recipe', 'servings', 'serves', 'yield',
    'prep time', 'cook time', 'total time', 'nutrition',
  ];

  // Lone words that are the tail of an ingredient, not an ingredient.
  static const _ingredientJunkWords = [
    'medium', 'large', 'small', 'optional', 'fresh', 'dried',
    'chopped', 'minced', 'diced', 'sliced', 'cubed', 'grated',
    'to taste', 'as needed', 'for garnish', 'or more',
    ..._headerWords,
  ];

  // A letter of any alphabet. Recipes are not only written in Latin letters.
  static final _anyLetter = RegExp(r'\p{L}', unicode: true);
  // A letter of another alphabet than the Latin one. Chinese and Japanese put
  // no spaces between words, so word counts say nothing about such a line.
  static final _nonLatinLetter = RegExp(r'(?!\p{Script=Latin})\p{L}', unicode: true);
  static final _plainLetter = RegExp(r'[A-Za-z]');

  /// True when [text] holds a letter of any alphabet. Nearly every line has a
  /// plain one, which is much quicker to find.
  static bool _hasLetter(String text) => _plainLetter.hasMatch(text) || _anyLetter.hasMatch(text);

  /// For a line that was sorted into the ingredients by guesswork.
  static bool _isValidIngredient(String text) {
    if (text.length < 3) return false;
    if (RegExp(r'^\d+$').hasMatch(text)) return false;

    final lower = text.toLowerCase().trim();
    if (_ingredientJunkWords.contains(lower)) return false;
    if (!text.contains(' ') && text.length < 4 && !_nonLatinLetter.hasMatch(text)) return false;
    if (RegExp(r'^[\d\s\.\,\-\/\(\)]+$').hasMatch(text)) return false;
    if (text.endsWith(':')) return false;
    if (!_hasLetter(text)) return false;
    // "15 mins" on its own is the value of a "Prep Time" label that got away.
    if (_bareDuration.hasMatch(text)) return false;

    return true;
  }

  /// For a line the writer put under an Ingredients header. It is kept unless
  /// it is plainly not an ingredient, so "Ice", "Oil" and "卵 3個" stay.
  static bool _isListedIngredient(String text) {
    if (!_hasLetter(text)) return false;
    if (RegExp(r'^[A-Za-z]$').hasMatch(text)) return false;
    if (text.endsWith(':')) return false;
    if (_ingredientJunkWords.contains(text.toLowerCase())) return false;
    if (_bareDuration.hasMatch(text)) return false;

    return true;
  }

  /// For a line that was sorted into the steps by guesswork.
  static bool _isValidInstruction(String text) {
    if (RegExp(r'^\d+\.?$').hasMatch(text)) return false;

    final lower = text.toLowerCase().trim();
    if (_headerWords.contains(lower)) return false;
    // A short order is a whole step: "Stir well.", "Serve cold."
    if (text.length >= 6 && text.contains(' ') && _startsWithActionVerb(lower)) return true;
    if (!text.contains(' ') && _nonLatinLetter.hasMatch(text)) return text.runes.length >= 3;
    if (text.length < 10) return false;
    if (text.split(' ').length < 3) return false;

    return true;
  }

  /// For a line the writer put under a Method header. It is kept when it
  /// reads like a step: it ends like a sentence, opens with a cooking verb,
  /// runs to three words, or is in a script that has no spaces to count.
  static bool _isListedInstruction(String text) {
    if (text.runes.length < 3 || !_hasLetter(text)) return false;
    if (RegExp(r'^(?:step\s*)?\d+\s*[.:)]?$', caseSensitive: false).hasMatch(text)) return false;

    final lower = text.toLowerCase();
    if (_headerWords.contains(lower)) return false;

    return RegExp(r'[.。)]$').hasMatch(text) ||
        _startsWithActionVerb(lower) ||
        text.split(RegExp(r'\s+')).length >= 3 ||
        _nonLatinLetter.hasMatch(text);
  }

  /// [raw] without the lines that are no ingredient. A line in [listed]
  /// stood under an Ingredients header and is judged leniently. The
  /// sub-headings of the list, [headings], stay.
  static List<String> _cleanIngredients(List<String> raw, Set<String> listed, Set<String> headings) {
    return raw
        .map((s) => s.trim())
        .where((s) => headings.contains(s) || (listed.contains(s) ? _isListedIngredient(s) : _isValidIngredient(s)))
        .toList();
  }

  /// The same for the steps of a method.
  static List<String> _cleanInstructions(List<String> raw, Set<String> listed, Set<String> headings) {
    return raw
        .map((s) => s.trim())
        .where((s) => headings.contains(s) || (listed.contains(s) ? _isListedInstruction(s) : _isValidInstruction(s)))
        .toList();
  }

  // ========== COURSE / CATEGORY DETECTION ==========

  /// Maps a display name or raw string to a known course ID.
  /// e.g. "Appetizer" → "appetizer", "Main Dish" → "main",
  /// "Side" → "side", "Beverage" → "beverage"
  static String? mapToCourseId(String raw) {
    final lower = raw.toLowerCase().trim();

    // Direct ID match
    const knownIds = [
      'appetizer', 'beverage', 'breakfast', 'brunch', 'dessert',
      'main', 'sauce', 'side', 'snack',
    ];
    if (knownIds.contains(lower)) return lower;

    // Name/alias → ID mapping (exact matches only)
    const nameMap = {
      'main dish': 'main',
      'main dishes': 'main',
      'main course': 'main',
      'main courses': 'main',
      'entrée': 'main',
      'entrées': 'main',
      'entree': 'main',
      'entrees': 'main',
      'dinner': 'main',
      'dinners': 'main',
      'lunch': 'main',
      'supper': 'main',
      'side dish': 'side',
      'starter': 'appetizer',
      'starters': 'appetizer',
      'appetiser': 'appetizer',
      'appetisers': 'appetizer',
      "hors d'oeuvres": 'appetizer',
      'drink': 'beverage',
      'drinks': 'beverage',
      'cocktail': 'beverage',
      'cocktails': 'beverage',
      'mocktail': 'beverage',
      'smoothie': 'beverage',
      'smoothies': 'beverage',
      'bread': 'snack',
      'breads': 'snack',
      'soup': 'main',
      'soups': 'main',
      'salad': 'side',
      'salads': 'side',
      'dip': 'appetizer',
      'dips': 'appetizer',
      'fish': 'main',
      'seafood': 'main',
      'cake': 'dessert',
      'cakes': 'dessert',
      'pastry': 'dessert',
      'pastries': 'dessert',
      'candy': 'dessert',
      'cookies': 'dessert',
      'sweets': 'dessert',
      'burger': 'main',
      'burgers': 'main',
      'chicken': 'main',
      'beef': 'main',
      'pork': 'main',
      'pasta': 'main',
      'stew': 'main',
      'stews': 'main',
      'curry': 'main',
      'curries': 'main',
      'casserole': 'main',
      'casseroles': 'main',
      'sauces': 'sauce',
      'dressing': 'sauce',
      'dressings': 'sauce',
      'condiment': 'sauce',
      'condiments': 'sauce',
      'marinade': 'sauce',
      'marinades': 'sauce',
    };
    if (nameMap.containsKey(lower)) return nameMap[lower]!;

    // Partial match — but only for unambiguous cases
    // e.g. "Breakfast Burritos" → breakfast, "Dessert Bars" → dessert
    for (final id in knownIds) {
      // Must start with the course name to avoid false positives
      // e.g. "Breakfast Ideas" → breakfast, but "Quick Breakfast" won't match.
      // The course is a word of its own there: "Maine Lobster" is no main
      // and "Sidecar" no side.
      if (lower.startsWith(id) && _courseWordEnd.matchAsPrefix(lower, id.length) != null) return id;
    }

    // Unknown folder — return null so the caller doesn't set a wrong course.
    // The auto-detection in _detectCourseAndCategory can try based on recipe content.
    return null;
  }

  // What may follow the name of a course that opens a longer name: the
  // plural, then no further letter.
  static final _courseWordEnd = RegExp(r'(?:e?s)?(?![a-z])');

  // The dishes a title may name, with the course and the category each one
  // is filed under. Both are ids of CourseData and CategoryData, or null
  // where the dish says nothing about it. A word that opens with "~" also
  // counts as the end of a longer word: "cheesecake", "cornbread",
  // "applesauce". A word given in the plural counts only in the plural:
  // "Lemon Bars" are sweets and a "Taco Bar" is not, "Flour Tortillas" are
  // breads and a Spanish "Tortilla" is an omelette. The kinds marked [light]
  // are sweets, snacks and drinks. A title names one of those only when it
  // names no meat, fish or vegetable with it: "Crab Cakes", "Onion Tart" and
  // "Shrimp Cocktail" are meals.
  static const _dishKinds = <({String? course, String? category, bool light, List<String> words})>[
    (course: 'breakfast', category: null, light: false, words: [
      'pancake', 'hotcake', 'waffle', 'omelet', 'omelette', 'french toast', 'scrambled egg', 'eggs benedict',
      'granola', 'oatmeal', 'porridge', 'overnight oats', 'muesli', 'frittata', 'hash brown', 'shakshuka',
      'biscuits and gravy',
    ]),
    (course: 'appetizer', category: null, light: false, words: [
      'dip', 'bruschetta', 'crostini', 'canape', 'deviled egg', 'spring roll', 'egg roll', 'guacamole', 'hummus',
    ]),
    (course: 'main', category: 'soup', light: false, words: [
      'soup', 'stew', 'chowder', 'bisque', 'broth', 'gazpacho', 'minestrone', 'ramen', 'pho',
    ]),
    (course: 'side', category: 'salad', light: false, words: ['salad', 'slaw', 'coleslaw']),
    (course: 'dessert', category: 'dessert', light: true, words: [
      '~cake', 'cookie', 'brownie', 'blondie', 'pie', 'tart', 'pudding', 'ice cream', 'ice cream sandwich', 'gelato',
      'sorbet', 'mousse', 'fudge', 'cobbler', 'crumble', 'tiramisu', 'donut', 'doughnut', 'macaron', 'macaroon',
      'truffle', 'candy', 'custard', 'flan', 'trifle', 'pavlova', 'meringue', 'shortbread', 'gingerbread', 'sundae',
      'cinnamon roll', 'frosting', 'icing', 'ganache', 'toffee', 'brittle', 'cannoli', 'churro', 'eclair', 'baklava',
      'panna cotta', 'creme brulee', 'popsicle', 'parfait', 'strudel', 'biscotti', 'bars',
    ]),
    (course: 'beverage', category: 'beverage', light: true, words: [
      'smoothie', 'milkshake', 'shake', 'juice', 'lemonade', 'limeade', 'tea', 'coffee', 'latte', 'cappuccino',
      'espresso', 'frappe', 'margarita', 'mojito', 'sangria', 'punch', 'hot chocolate', 'hot cocoa', 'cider',
      'eggnog', 'martini', 'daiquiri', 'spritzer', 'spritz', 'soda', 'kombucha', 'chai', 'lassi', 'horchata',
      'cocktail', 'mocktail', 'mimosa',
    ]),
    (course: 'snack', category: null, light: true, words: [
      'popcorn', 'trail mix', 'chip', 'pretzel', 'granola bar', 'energy ball', 'energy bite', 'energy bar',
      'protein bar', 'rice cake', 'chips and salsa',
    ]),
    (course: 'sauce', category: 'sauce', light: false, words: [
      '~sauce', 'dressing', 'marinade', 'gravy', 'condiment', 'salsa', 'pesto', 'vinaigrette', 'aioli', 'chutney',
      'relish', 'ketchup', 'mayonnaise', 'glaze', 'syrup', 'jam', 'compote', 'curd', 'tzatziki', 'chimichurri',
      'coulis', 'seasoning', 'spice mix', 'spice blend', 'rub',
    ]),
    (course: 'snack', category: 'bread', light: false, words: [
      '~bread', 'focaccia', 'baguette', 'sourdough', 'biscuit', 'scone', 'dinner roll', 'bread roll', 'bun', 'naan',
      'pita', 'tortillas', 'flour tortilla', 'corn tortilla', 'bagel', 'loaf', 'brioche', 'challah', 'ciabatta',
      'crumpet', 'english muffin', 'pizza dough',
    ]),
    (course: 'side', category: 'bread', light: false, words: ['yorkshire pudding']),
    (course: 'snack', category: 'muffin', light: false, words: ['muffin']),
    (course: 'main', category: 'pasta', light: false, words: [
      'pasta', 'spaghetti', 'lasagna', 'lasagne', 'macaroni', 'mac and cheese', 'mac & cheese', 'mac n cheese',
      'fettuccine', 'penne', 'linguine', 'ravioli', 'gnocchi', 'carbonara', 'bolognese', 'alfredo', 'noodle', 'ziti',
      'rigatoni', 'tortellini', 'orzo', 'tagliatelle', 'pappardelle', 'cannelloni', 'manicotti', 'lo mein',
      'chow mein', 'pad thai', 'udon', 'soba',
    ]),
    (course: 'main', category: 'rice', light: false, words: [
      'risotto', 'paella', 'biryani', 'pilaf', 'pilau', 'fried rice', 'jambalaya', 'rice bowl', 'congee',
    ]),
    (course: null, category: 'rice', light: false, words: ['rice']),
    (course: 'main', category: 'burrito-taco', light: false, words: [
      'taco', 'burrito', 'quesadilla', 'enchilada', 'fajita', 'tostada', 'taquito', 'chimichanga', 'nachos', 'tamale',
    ]),
    (course: 'main', category: 'casserole', light: false, words: [
      'casserole', 'pot pie', "shepherd's pie", 'shepherds pie', 'cottage pie', 'hotdish', 'moussaka',
    ]),
    (course: 'main', category: 'sandwich', light: false, words: [
      'sandwich', '~burger', 'wrap', 'panini', 'slider', 'hoagie', 'grilled cheese', 'toastie', 'blt', 'hot dog',
      'gyro', 'banh mi', 'lobster roll', 'sloppy joe', 'reuben', 'tuna melt', 'patty melt', 'french dip',
    ]),
    (course: 'main', category: 'chicken-steak-meat', light: false, words: [
      'chicken', 'turkey', 'beef', 'steak', 'pork', 'lamb', 'sausage', 'meatball', 'meatloaf', 'meat loaf', 'rib',
      'prime rib', 'brisket', 'bacon', 'ham', 'duck', 'veal', 'venison', 'schnitzel', 'kebab', 'kabob', 'carnitas',
      'roast', 'pot roast', 'tenderloin', 'sirloin', 'ribeye', 'filet mignon', 'bratwurst', 'chorizo', 'meat',
      'wing', 'drumstick', 'cutlet', 'black pudding', 'chicken and waffles',
    ]),
    (course: 'main', category: 'fish', light: false, words: [
      'fish', 'salmon', 'tuna', 'cod', 'tilapia', 'halibut', 'trout', 'sea bass', 'shrimp', 'prawn', 'crab',
      'lobster', 'scallop', 'seafood', 'mussel', 'clam', 'oyster', 'calamari', 'squid', 'octopus', 'sardine',
      'mackerel', 'haddock', 'catfish', 'mahi mahi', 'swordfish', 'snapper', 'ceviche', 'sushi', 'poke', 'crab cake',
      'fish cake', 'fishcake', 'crabcake', 'fish and chips',
    ]),
    (course: 'main', category: null, light: false, words: [
      'chili', 'chilli', 'curry', 'stir fry', 'stir-fry', 'pizza', 'quiche', 'calzone', 'dumpling', 'gyoza',
      'potsticker', 'pierogi', 'empanada', 'tagine', 'stuffed pepper', 'cabbage roll', 'goulash', 'stroganoff',
      'tikka masala',
    ]),
    (course: null, category: 'bean', light: false, words: [
      'bean', 'lentil', 'chickpea', 'dal', 'dahl', 'daal', 'falafel',
    ]),
    (course: 'side', category: 'vegetable', light: false, words: [
      'fries', 'french fries', 'mashed potato', 'roasted vegetable', 'baked potato', 'potato wedge', 'onion ring',
    ]),
    (course: null, category: 'vegetable', light: false, words: [
      'vegetable', 'veggie', 'broccoli', 'cauliflower', 'carrot', 'zucchini', 'courgette', 'asparagus',
      'brussels sprout', 'green bean', 'spinach', 'kale', 'cabbage', 'eggplant', 'aubergine', 'mushroom', 'potato',
      'sweet potato', 'squash', 'beet', 'beetroot', 'pea', 'artichoke', 'okra', 'turnip', 'parsnip', 'leek',
      'cucumber', 'bok choy', 'edamame', 'tomato', 'onion',
    ]),
    (course: null, category: 'fruit', light: false, words: ['fruit']),
  ];

  // One pattern for each kind of dish. The words are matched whole, in the
  // singular or the plural: "tea" is not in "steak", nor "pie" in "piece".
  static final _dishPatterns = [
    for (final kind in _dishKinds)
      RegExp('(?:(?<![a-z])(?:${_wordsOf(kind.words, tails: false)})|(?:${_wordsOf(kind.words, tails: true)}))'
          r'(?:e?s)?(?![a-z])'),
  ];

  /// The alternatives of a pattern for [words], the longest first. With
  /// [tails] it is the words marked "~", else the others.
  static String _wordsOf(List<String> words, {required bool tails}) {
    final chosen = [
      for (final word in words)
        if (word.startsWith('~') == tails) RegExp.escape(tails ? word.substring(1) : word),
    ]..sort((a, b) => b.length.compareTo(a.length));
    // A pattern with nothing to choose from must match nothing.
    return chosen.isEmpty ? r'(?!)' : chosen.join('|');
  }

  // Meat, fish and the vegetables of savoury baking. With one of these in
  // its title a dish is a meal, whatever sweet or snack it is named after.
  static final _heartyFood = RegExp(
      r'(?<![a-z])(?:chicken|beef|pork|steak|fish|lamb|turkey|sausage|bacon|ham|salmon|tuna|crab|shrimp|prawn|lobster'
      r'|meat|veal|duck|cod|oyster|clam|onion|tomato|spinach|mushroom|leek|cheddar|parmesan|feta'
      r')(?:e?s)?(?![a-z])|fishcake|crabcake|meatball|meatloaf');

  // Where a title turns from the dish to what comes with it: "Spaghetti
  // with Meat Sauce", "Chicken in White Wine Sauce", "Banana Bread (Vegan)".
  static final _titleAside = RegExp(r'\s+(?:with|in|on|over|for|from|topped|served|w/)\s+|\s*[(,:|]\s*|\s+[-–\u2014]\s+');

  // Courses a text may name outright.
  static const _courseWords = {
    'breakfast': ['breakfast'],
    'brunch': ['brunch'],
    'appetizer': ['appetizer', 'appetiser', "hors d'oeuvre", 'finger food'],
    'dessert': ['dessert'],
    'snack': ['snack'],
    'side': ['side dish'],
    'beverage': ['drink', 'beverage'],
    'main': ['main course', 'main dish', 'entree', 'entrée'],
  };

  /// Suggests a course and a category for [recipe], from the dish its title
  /// names. Only ids the app has are suggested.
  ///
  /// The title counts first. A description speaks of many things ("serve
  /// with a salad"), so it is asked only for a course it names outright,
  /// and only when the title names nothing. A recipe that names nothing
  /// keeps what it had: no suggestion is better than a wrong one.
  static void _detectCourseAndCategory(ImportedRecipe recipe) {
    // A title names its dish in a few words. One that runs on for pages is
    // not searched to its end.
    final name = recipe.title.length > 200 ? recipe.title.substring(0, 200) : recipe.title;
    final title = name.toLowerCase();
    final dish = _dishNamed(title);
    if (dish != null) {
      // "Breakfast Burritos" are a breakfast, and burritos all the same.
      recipe.suggestedCourse = _courseNamed(title) ?? dish.course;
      recipe.suggestedCategory = dish.category;
      return;
    }
    final course = _courseNamed(title) ?? _courseNamed((recipe.description ?? '').toLowerCase());
    if (course != null) recipe.suggestedCourse = course;
  }

  /// The kind of dish [title] names, or null. A title names its dish
  /// last, "Chicken Noodle Soup" is a soup, and before it turns to what the
  /// dish comes with.
  static ({String? course, String? category})? _dishNamed(String title) {
    final aside = _titleAside.firstMatch(title);
    if (aside == null) return _dishIn(title);
    return _dishIn(title.substring(0, aside.start)) ?? _dishIn(title.substring(aside.end));
  }

  // The second half of a pair: "Beef and" before "Broccoli".
  static final _pairedWith = RegExp(r'\s+(?:and|&)\s+$');

  /// The dish [text] names with its last words, or null. Of two names that
  /// end at the same word the longer one counts: a "pot pie" is no pie.
  static ({String? course, String? category})? _dishIn(String text) {
    final hearty = _heartyFood.hasMatch(text);
    ({String? course, String? category})? named;
    var start = -1;
    var end = -1;
    for (var k = 0; k < _dishKinds.length; k++) {
      final kind = _dishKinds[k];
      if (kind.light && hearty) continue;
      for (final found in _dishPatterns[k].allMatches(text)) {
        if (found.end > end || (found.end == end && found.start < start)) {
          start = found.start;
          end = found.end;
          named = (course: kind.course, category: kind.category);
        }
      }
    }
    if (named == null) return null;
    // A pair is named by its first half: "Beef and Broccoli" is beef. The
    // name found may be the end of a longer word, so step back to where
    // that word begins.
    while (start > 0 && _plainLetter.hasMatch(text[start - 1])) {
      start--;
    }
    final pair = _pairedWith.firstMatch(text.substring(0, start));
    return (pair == null ? null : _dishIn(text.substring(0, pair.start))) ?? named;
  }

  /// The course [text] names outright, or null.
  static String? _courseNamed(String text) {
    for (final course in _courseWords.entries) {
      if (_matchesAny(text, course.value)) return course.key;
    }
    return null;
  }

  static final _wholeWords = <String, RegExp>{};

  /// True when [text] holds one of [words] as a whole word, in the singular
  /// or the plural.
  static bool _matchesAny(String text, List<String> words) {
    return words.any((word) =>
        (_wholeWords[word] ??= RegExp('(?<![a-z])${RegExp.escape(word)}(?:e?s)?(?![a-z])')).hasMatch(text));
  }

  // ========== UTILITY HELPERS ==========

  // Punctuation around a word. Letters of every alphabet count as part of
  // the word, so "sauté" is not cut down to "saut".
  static final _wordEdges = RegExp(r'[^\p{L}\p{N}_]', unicode: true);

  static bool _containsActionVerb(String text) {
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    return words.any(
            (word) => _actionVerbs.contains(word.replaceAll(_wordEdges, '')));
  }

  static bool _startsWithActionVerb(String text) {
    final firstWord =
    text.split(RegExp(r'\s+'))[0].replaceAll(_wordEdges, '');
    return _actionVerbs.contains(firstWord);
  }

  // What can stand in front of a list item: a bullet, the checkbox sign that
  // recipe cards copy as, a dash or an arrow, each followed by a space.
  static final _bulletMarker = RegExp(r'^[\-\*•◦▪▫▢☐☑☒□■●○◻◼▸►‣⁃·・–\u2014→✓✔+>＊]\s+');
  static final _numberMarker = RegExp(r'^\d+[\.\)]\s+');
  static final _checkboxMarker = RegExp(r'^\[\s?[xX]?\]\s*');
  // Step numbers typed as emoji in captions: "1️⃣" and "①".
  static final _emojiNumberMarker = RegExp(
      r'^(?:\d\uFE0F?\u20E3|[\u2460-\u2473\u24F5-\u24FE\u2776-\u277F\u2780-\u2793])\s*');
  // A step numbered in words, with its text on the same line: "Step 2: Mix".
  static final _stepMarker = RegExp(r'^step\s*\d{1,2}\s*[:.)\-\u2013]\s*(?=\S)', caseSensitive: false);

  static bool _isListItem(String line) {
    return _bulletMarker.hasMatch(line) || _isNumbered(line) || _checkboxMarker.hasMatch(line);
  }

  /// True when [line] carries a number as a step or a numbered item does.
  static bool _isNumbered(String line) {
    return _numberMarker.hasMatch(line) || _emojiNumberMarker.hasMatch(line) || _stepMarker.hasMatch(line);
  }

  static String _cleanListMarkers(String line) {
    return line
        .replaceFirst(_bulletMarker, '')
        .replaceFirst(_numberMarker, '')
        .replaceFirst(_emojiNumberMarker, '')
        .replaceFirst(_stepMarker, '')
        .replaceFirst(_checkboxMarker, '')
        .trim();
  }

  static String _cleanMarkdown(String text) {
    return text
        // Pictures go first. Read as a link, "![alt](url)" would leave its
        // exclamation mark and its caption behind.
        .replaceAll(RegExp(r'!\[\[[^\]\[]*\]\]|!\[[^\]\[]*\][\[(][^\])]*[\])]'), '')
        .replaceAllMapped(
        RegExp(r'\*\*([^*]+)\*\*'), (m) => m.group(1) ?? '')
        // One half of a pair, when the other half was trimmed off the line.
        .replaceAll('**', '')
        .replaceAllMapped(RegExp(r'\*([^*]+)\*'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'__([^_]+)__'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'_([^_]+)_'), (m) => m.group(1) ?? '')
        // Link text and what it links to both stop at the next opening
        // bracket, so a long run of unclosed links is not searched again
        // from every one of them.
        .replaceAllMapped(
        RegExp(r'\[\[([^\]\[|]+)(?:\|[^\]\[]+)?\]\]'), (m) => m.group(1) ?? '')
        .replaceAllMapped(
        RegExp(r'\[([^\]\[]+)\]\([^)\[]{1,2000}\)'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m.group(1) ?? '')
        // Strip leading emoji characters (food emojis, etc.)
        .replaceFirst(RegExp(r'^(?:[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{200D}]+\s*)', unicode: true), '')
        .trim();
  }

  static String? _cleanHtmlText(String? text) {
    if (text == null) return null;
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Reads a line that says how much a recipe makes or how long it takes:
  /// "Serves 4", "Prep time: 10 min", "Prep: 15 min | Cook: 1 hour 30 minutes".
  ///
  /// Null unless the line is made of nothing else, so "Add the onion and cook
  /// 5 minutes" stays a step and "1 batch pesto (makes 2 cups)" stays an
  /// ingredient. How strictly that is judged depends on where the line
  /// stands: under which [section], and whether the first ingredient or step
  /// has been read ([contentBegun]). At the top of a recipe a line that opens
  /// with its label may run on a little, and "Cook 30 mins" is how some cards
  /// print the cook time. Further down the same words are something to do,
  /// and a line with anything more in it than its facts is left alone.
  ///
  /// A total time comes back beside the other values. It only stands in for
  /// the cook time once every line has been read and none was given. A fact
  /// the app has no field for, a chilling time or a yield told by the cup,
  /// comes back as text so that the caller can keep it as a note. Under a
  /// Method header such a time is left where it was written, between the
  /// steps it belongs to.
  static ({_Metadata values, int? totalTime, List<String> forNotes})? _extractMetadata(
    String line, {
    _Section section = _Section.unknown,
    bool contentBegun = false,
  }) {
    // A numbered item is a step or an ingredient, whatever it says.
    if (_isNumbered(line)) return null;
    if (line.length > 160 || !_digitOrFraction.hasMatch(line)) return null;

    final atTop = section == _Section.unknown && !contentBegun;
    final inMethod = section == _Section.instructions;

    // A yield in another language is a short line of its own: "Für 12
    // Stücke", "Pour 6 personnes", "4人分".
    if (line.length <= 48) {
      final abroad = _yieldAbroad.firstMatch(_withoutLeadingSymbols(_cleanMarkdown(_cleanListMarkers(line))).trim());
      final told = abroad?.group(1) ?? abroad?.group(2);
      // A bare count under a header may be the amount of an ingredient
      // that was read apart from its name: "2 Stück".
      final count = told ?? (atTop ? abroad?.group(3) : null);
      final servings = count == null ? null : _servingsFrom(count);
      if (servings != null) return (values: _Metadata(servings: servings), totalTime: null, forNotes: const []);
    }

    // Every fact names itself with one of a few words. Most lines hold none
    // of them and need no closer look, which keeps a large import quick.
    if (!_factWord.hasMatch(line)) return null;

    final text = _withoutLeadingSymbols(_cleanMarkdown(_cleanListMarkers(line))).trim();
    if (text.isEmpty || text.length > 120) return null;

    // The serving on a nutrition label ("Serving size: 1 slice", "Serving: 1
    // cup | Calories: 250") is not what the recipe makes. "Serving: 4" is.
    final serving = _servingLabel.firstMatch(text);
    if (serving != null) {
      final count = serving.group(1) == null && _wholeCount.hasMatch(serving.group(2)!)
          ? _servingsFrom(serving.group(2)!)
          : null;
      return (values: _Metadata(servings: count), totalTime: null, forNotes: [if (count == null) text]);
    }

    final endsSentence = _sentenceEnd.hasMatch(text);
    // Each fact in a row may carry its own sign: "⏱ 30 min | 🍽 4 servings".
    final segments = text
        .split(_factSeparator)
        .map((s) => _withoutLeadingSymbols(s).trim())
        .where((s) => s.isNotEmpty)
        .toList();

    String? servings;
    int? prepTime;
    int? cookTime;
    int? totalTime;
    int? activeTime;
    int? unlabelledTime;
    final forNotes = <String>[];
    var facts = 0;
    var bareVerb = false;
    var bareVerbIsCook = false;

    for (final segment in segments) {
      var rest = segment;
      var factsHere = 0;

      // The yield, where it opens the segment or follows a comma.
      var yieldFact = _yieldIn(rest);
      final yieldFirst = yieldFact?.match.start == 0;
      if (yieldFact != null) {
        rest = rest.replaceRange(yieldFact.match.start, yieldFact.match.end, ' ');
      }

      var bareVerbHere = false;
      var timeFirst = false;
      final otherTimes = <String>[];
      for (final m in _timeFact.allMatches(rest)) {
        final label = (m.group(1) ?? m.group(3) ?? m.group(4))!.toLowerCase();
        final minutes = _durationMinutes(m.group(6)!);
        // "Cook Time: 30 mins" names itself. "Cook 30 mins", with no "time"
        // and no colon, may be an order.
        final named = m.group(2) != null || m.group(5) != null;
        if (m.start == 0 && named) timeFirst = true;
        if (label.contains('prep')) {
          prepTime ??= minutes;
        } else if (label.contains('cook') || label.contains('bak')) {
          cookTime ??= minutes;
          if (!named && (label == 'cook' || label == 'bake')) {
            bareVerbHere = true;
            bareVerbIsCook = label == 'cook';
          }
        } else if (label.startsWith('total') || label.startsWith('ready') || label == 'time') {
          totalTime ??= minutes;
        } else if (label.startsWith('active') || label.startsWith('hands')) {
          activeTime ??= minutes;
        } else {
          // A resting or chilling time. The line is still a line of facts,
          // but the app has no field for this one.
          if (inMethod) return null;
          if (minutes != null) otherTimes.add(m.group(0)!.trim());
        }
        factsHere++;
      }
      final timesHere = factsHere;
      rest = rest.replaceAll(_timeFact, ' ');

      // The yield, where it follows the times: "Prep 10 min Cook 20 min
      // Servings 4".
      if (yieldFact == null && factsHere > 0) {
        rest = rest.trimLeft();
        yieldFact = _yieldIn(rest);
        if (yieldFact != null) {
          rest = rest.replaceRange(yieldFact.match.start, yieldFact.match.end, ' ');
        }
      }
      if (yieldFact != null) {
        if (yieldFact.servings != null) {
          servings ??= yieldFact.servings;
        } else {
          forNotes.add(segment);
        }
        factsHere++;
      }
      // On its own such a time is noted as it was written, with what comes
      // after it: "Chill time: 2 hours or overnight".
      forNotes.addAll(factsHere == 1 && otherTimes.length == 1 ? [segment] : otherTimes);

      if (factsHere == 0) {
        // A time with no label is the total, as long as the row holds a
        // labelled fact too: "30 min | Serves 4".
        if (_bareDuration.hasMatch(segment)) {
          unlabelledTime ??= _durationMinutes(segment);
          continue;
        }
        // A bar of facts may carry other labels ("Course: Main | Prep: 10
        // min") and, once it has opened with a fact, a word or two ("Serves 4
        // | Vegetarian"). "Easy Chili | Serves 6" opens with a title.
        final label = _otherLabel.hasMatch(segment);
        final tag = facts > 0 && segment.split(RegExp(r'\s+')).length <= 3;
        if (segments.length == 1 || !(label || tag)) return null;
        continue;
      }

      // "Serves 4, 30 minutes": a time with no label beside the yield.
      if (timesHere == 0 && _digitOrFraction.hasMatch(rest)) {
        final beside = _besideYield.firstMatch(rest);
        if (beside != null) unlabelledTime ??= _durationMinutes(beside.group(1)!);
      }

      final leftover = rest
          .toLowerCase()
          .split(_notLetters)
          .where((w) => w.length > 1 && !_metaFiller.contains(w))
          .toList();
      // At the top of a recipe a line that opens with its label may run on a
      // little: "Serves 4 as a main or 6 as a side", "Cook Time: 4 hours on
      // high or 8 hours on low". Further down a time is a fact only when
      // nothing comes after it, and a yield has to be short and in one piece:
      // "Makes 6 pancakes, keep them warm" is a step, and so is "Cook time: 2
      // minutes per side, until golden".
      final wordsAllowed = yieldFirst || (timeFirst && atTop) ? (atTop && !endsSentence ? 6 : 3) : 0;
      if (leftover.length > wordsAllowed) return null;
      final oneClauseOnly = yieldFirst ? !atTop : leftover.isNotEmpty;
      if (oneClauseOnly && _secondClause.hasMatch(rest)) return null;
      if (bareVerbHere) {
        if (leftover.isNotEmpty) return null;
        bareVerb = true;
      }
      facts += factsHere;
    }

    if (facts == 0) return null;
    // On its own "Bake 25 minutes" is a step, and so is "Cook 30 mins"
    // further down. At the top of a recipe "Cook 30 mins" is how some cards
    // print the cook time, and in a row of facts it is one of them.
    if (bareVerb && (endsSentence || (facts == 1 && (!atTop || !bareVerbIsCook)))) return null;

    return (
      values: _Metadata(servings: servings, prepTime: prepTime ?? activeTime, cookTime: cookTime),
      totalTime: totalTime ?? unlabelledTime,
      forNotes: forNotes,
    );
  }

  static final _digitOrFraction = RegExp(r'[\d½¼¾⅓⅔]');
  static final _factWord = RegExp(
      r'serv|yield|makes|portion|feeds|people|person|prep|cook|bak|total|active|hands|ready|time',
      caseSensitive: false);
  static final _notLetters = RegExp(r'[^\p{L}]+', unicode: true);
  static final _leadingSymbols = RegExp(r'^[^\p{L}\p{N}(]+', unicode: true);

  /// [text] without the signs in front of its first letter, digit or bracket.
  static String _withoutLeadingSymbols(String text) =>
      _plainStart.hasMatch(text) ? text : text.replaceFirst(_leadingSymbols, '');

  // The point after "min." or "hrs." closes an abbreviation, not a sentence.
  static final _sentenceEnd = RegExp(r'[!?]$|(?<!\b(?:mins?|hrs?|h|m))\.$', caseSensitive: false);
  // "Serves 4, or 6 as a starter" is still one piece.
  static final _secondClause = RegExp(r'[,;:]\s*(?!or\b)\p{L}', caseSensitive: false, unicode: true);
  // Facts set side by side: "Serves 4 | Prep 10 min • Cook 20 min".
  static final _factSeparator = RegExp(r'\s*[|•·]\s*');
  static final _otherLabel = RegExp(r'^\p{L}[\p{L} ]{0,24}:\s*\S', unicode: true);
  // Group 1 is the word "size", group 2 what follows the label.
  static final _servingLabel = RegExp(r'^(?:serving|portion)(?:(\s+size)\b\s*:?|\s*:)\s*(.*)$', caseSensitive: false);
  static final _wholeCount = RegExp(r'^\d{1,3}(?:\s*(?:-|–|to)\s*\d{1,3})?\W*$');

  // Words that may sit beside a fact without making the line a sentence:
  // "Prep time: 20 minutes, plus 1 hour chilling", "Yield: 8 servings, about
  // 1 cup each".
  static const _metaFiller = <String>{
    'plus', 'chilling', 'resting', 'marinating', 'overnight', 'soaking', 'cooling', 'standing',
    'freezing', 'setting', 'proving', 'rising', 'approx', 'about', 'time', 'each', 'per', 'batch',
    'inactive', 'total', 'active', 'and', 'at', 'least', 'optional',
    'serving', 'servings', 'portion', 'portions', 'people', 'person', 'persons',
    'hour', 'hours', 'hr', 'hrs', 'minute', 'minutes', 'min', 'mins',
  };

  // "Serves 4", "Yield: 12 muffins", "Makes about 24", "Number of servings:
  // 6". The label opens the line or follows a comma, so "(makes 2 cups)"
  // inside an ingredient and "Divide into 4 portions" are left alone. "Serve"
  // and "make" without the final s are orders, not labels. Group 1 is the
  // count, group 2 a fraction after it, group 3 a fraction with no count
  // before it and group 4 the word "dozen".
  static final _yieldLead = RegExp(
      r'(?:^|[,;/]\s*|\s[–\u2014-]\s+)\(?\s*'
      r'(?:(?:(?:number|no\.?)\s+of|total|(?:original\s+)?recipe(?:\s+\(\w{1,4}\))?)\s+|yields?\s*:\s*)?'
      r'(?:serves|servings|yields?|makes|portions|feeds)(?![a-z])\s*(?:[:\-–]\s*)?'
      r'(?:(?:about|approx\.?|approximately|around|roughly|up\s+to)\s+)?'
      r'(?:(\d{1,4}(?:\s*(?:-|–|\u2014|to)\s*\d{1,4}(?!\s*(?:hours?|hrs?|h|minutes?|mins?|m)\b))?)(?!\d)'
      r'([.,]\d{1,3}|\s+\d/\d{1,2}|\s?[½¼¾⅓⅔]|/\d{1,2})?|([½¼¾⅓⅔]))'
      r'(\s+dozen\b)?',
      caseSensitive: false);

  // A yield as other languages put it, on a line of its own. Group 1 is a
  // count that follows the word for "for" or "makes" ("Für 12 Stücke", "Pour
  // 6 personnes"), group 2 one that follows a label ("Portionen: 4") and
  // group 3 a count that stands alone ("4 Portionen", "4人分").
  static const _countAbroad = r'\d{1,3}(?:\s*(?:-|–|bis|à|a|o|tot|do)\s*\d{1,3})?';
  static const _peopleAbroad = 'personen|portionen|stück|stücke|personnes|personas|porciones|raciones|comensales'
      '|persone|porzioni|pessoas|porções|porties|stuks|osób|osoby|porcj[ei]|порци[ийя]|персон[ыа]?|человек'
      '|人分|人前|人份|인분';
  static final _yieldAbroad = RegExp(
      r'^\(?(?:(?:für|fuer|ergibt|pour|para|rinde|per|dosi\s+per|voor|rende|dla|на)\s+'
      r'(?:(?:ca\.?|environ|circa|etwa|unos|unas)\s+)?'
      '($_countAbroad)'
      r'\s*(?:'
      '$_peopleAbroad'
      r')|(?:portionen|porciones|raciones|porzioni|porções|rendimento|rendimiento|dosi|porties|porcje|порции|ergibt)\s*[:：]\s*'
      '($_countAbroad)'
      r'(?:\s+[^\s\d]+)?|'
      '($_countAbroad)'
      r'\s*(?:'
      '$_peopleAbroad'
      r'))\)?$',
      caseSensitive: false);

  // "4 servings", "(4 servings)", "12 servings (1/2 cup each)", "4 people". A
  // word straight after it, or after its brackets, makes the line an
  // ingredient: "2 servings cooked pasta", "1 portion (150 g) noodles".
  static final _yieldCount = RegExp(
      r'(?:^|[,;/]\s*|\s[–\u2014-]\s+)\(?\s*(\d{1,3}(?:\s*(?:-|–|\u2014|to)\s*\d{1,3})?)\s*(?:servings?|portions?|serves|people|persons?)\b'
      r'(?=\s*(?:\([^()]*\)\s*)?(?:$|[,;:.)]))',
      caseSensitive: false);

  // A unit of volume or weight straight after the amount: "Makes 2 cups".
  // In "Makes 4 pint jars" the unit only says how big each one is.
  static final _measureUnit = RegExp(
      r'\s*-?(?:cups?|tablespoons?|tbsps?|teaspoons?|tsps?|quarts?|qts?|pints?|gallons?|lit(?:er|re)s?|l|ml'
      r'|fl\.?\s?oz|oz|ounces?|lbs?|pounds?|g|kg|grams?)\b'
      r'(?![\s-]+(?:jars?|bottles?|cans?|tins?|pans?|loa(?:f|ves)|bags?|containers?|servings?|portions?)\b)',
      caseSensitive: false);

  // What is left of "Serves 4, 30 minutes" once the yield is taken out.
  static final _besideYield = RegExp(
      r'^[\s,;.()–-]*('
      '$_durationPattern'
      r')[\s.)]*$',
      caseSensitive: false);

  /// The yield in [text] and the servings it stands for. The servings are
  /// null for a yield told by volume or weight, "Makes 1 1/2 cups": a fact
  /// about the recipe, but not a number of servings. Null when [text] has no
  /// yield, or one that names a count no recipe makes.
  static ({RegExpMatch match, String? servings})? _yieldIn(String text) {
    final match = _yieldLead.firstMatch(text) ?? _yieldCount.firstMatch(text);
    if (match == null) return null;

    var dozens = false;
    if (match.pattern == _yieldLead) {
      dozens = match.group(4) != null;
      final fraction = match.group(2) ?? match.group(3);
      if (fraction != null || _measureUnit.matchAsPrefix(text, match.end) != null) {
        // "Makes 2 1/2 dozen" is thirty. Any other amount with a fraction or
        // a unit after it is a measure.
        final amount = dozens && fraction != null ? _mixedNumber('${match.group(1) ?? ''}$fraction') : null;
        final count = amount == null ? null : amount * 12;
        final whole = count != null && (count - count.round()).abs() < 0.01;
        return (match: match, servings: whole ? _servingsFrom('${count.round()}') : null);
      }
    }
    final servings = _servingsFrom(match.group(1)!, dozens: dozens);
    return servings == null ? null : (match: match, servings: servings);
  }

  /// "4" or "4-6" from "4", "4 to 6", "4 – 6", and "24" from "2 dozen". Null
  /// for a count no recipe makes.
  static String? _servingsFrom(String count, {bool dozens = false}) {
    final numbers = RegExp(r'\d+')
        .allMatches(count)
        .map((m) => int.parse(m.group(0)!) * (dozens ? 12 : 1))
        .toList();
    if (numbers.any((n) => n < 1 || n > 200)) return null;
    return numbers.join('-');
  }

  static final _mixedNumberPattern = RegExp(r'^(\d{1,4}(?:[.,]\d{1,3})?)?\s*(?:(\d)/(\d{1,2})|([½¼¾⅓⅔]))?$');

  /// "2 1/2" and "2½" as 2.5, "1,5" as 1.5. Null when [text] is not one
  /// number, as in a range.
  static double? _mixedNumber(String text) {
    final m = _mixedNumberPattern.firstMatch(text.trim());
    if (m == null) return null;
    var value = double.tryParse((m.group(1) ?? '').replaceAll(',', '.'));
    if (m.group(2) != null) {
      final below = int.parse(m.group(3)!);
      if (below == 0) return null;
      value = (value ?? 0) + int.parse(m.group(2)!) / below;
    } else if (m.group(4) != null) {
      value = (value ?? 0) + _fractionValues[m.group(4)]!;
    }
    return value;
  }

  // A duration as recipes write it: "45 min", "1 hour 30 minutes", "1 hr,
  // 15 mins", "1.5 hours", "1 1/2 hours", "20-25 minutes". Recipe card plugins
  // repeat the unit ("15 minutes mins"), so that is allowed too.
  static const _durationPart = r'(?:\d+(?:[.,]\d+)?(?:\s+\d/\d|\s?[½¼¾⅓⅔])?|[½¼¾⅓⅔]|\d/\d)'
      r'(?:\s*(?:-|–|\u2014|to)\s*\d+(?:[.,]\d+)?)?'
      r'\s*(?:(?:hours?|hrs?|h)(?![a-z])\.?(?:'
      '$_minutesAfterHours'
      r')?|(?:days?|minutes?|mins?|m)\b\.?)'
      r'(?:\s+(?:hrs?|mins?)\b\.?)?';
  // "1h30" and "1 h 30": minutes written after the hours with no unit of
  // their own. Only where the duration ends there, so that the 6 in "Total 1
  // hour 6 servings" is left for the servings.
  static const _minutesAfterHours = r'\s?[0-5]?\d(?=\s*(?:$|[|•·,;.()]|[–\u2014-]\s))';
  static const _durationPattern = r'(?:(?:about|approx\.?|approximately|around|under|~)\s*)?'
      '$_durationPart'
      r'(?:\s*(?:and\s+|,\s*)?'
      '$_durationPart'
      r'){0,2}';

  // A letter of the Latin alphabet, accents included. The words of a label
  // are matched without regard to case, which is slow to do for the letters
  // of every alphabet at once, and a label that ends in "time" is English.
  static const _latinLetter = r'[A-Za-z\u00C0-\u024F]';

  // A label and its duration. Group 1 is a label the app knows, group 2 the
  // word "time" after it, group 3 any other "... time" label, group 4 a bare
  // "time", group 5 the colon or dash and group 6 the duration.
  static final _timeFact = RegExp(
      '(?<!$_latinLetter)'
      r'(?:(prep(?:aration)?|cook(?:ing)?|bak(?:e|ing)|total|active|hands[\s-]on|ready\s+in)(\s*time)?'
      '|((?:$_latinLetter'
      r'+[\s-]+){1,2}time)'
      r'|(time))'
      r'\s*(?:([:\-–])\s*)?'
      '($_durationPattern)',
      caseSensitive: false);

  // Group 5 is a unit of hours, group 6 the minutes written straight after it
  // and group 7 any other unit.
  static final _durationToken = RegExp(
      r'(\d+(?:[.,]\d+)?)?\s*(?:(?:(\d)/(\d)|([½¼¾⅓⅔]))\s*)?'
      r'(?:(hours?|hrs?|h)(?![a-z])\.?('
      '$_minutesAfterHours'
      r')?|(days?|minutes?|mins?|m)\b)');
  static const _fractionValues = {'½': 0.5, '¼': 0.25, '¾': 0.75, '⅓': 1 / 3, '⅔': 2 / 3};

  /// Minutes in a duration. Hours and minutes are added up, so "3 hours 30
  /// minutes" is 210 and "1h30" is 90, and a range counts as its longer end.
  static int? _durationMinutes(String duration) {
    var total = 0.0;
    for (final m in _durationToken.allMatches(duration.toLowerCase())) {
      var value = double.tryParse((m.group(1) ?? '').replaceAll(',', '.'));
      if (m.group(2) != null && m.group(3) != '0') {
        value = (value ?? 0) + int.parse(m.group(2)!) / int.parse(m.group(3)!);
      } else if (m.group(4) != null) {
        value = (value ?? 0) + _fractionValues[m.group(4)]!;
      }
      if (value == null) continue;
      if (m.group(5) != null) {
        total += value * 60 + (int.tryParse(m.group(6)?.trim() ?? '') ?? 0);
      } else {
        total += value * (m.group(7)!.startsWith('d') ? 1440 : 1);
      }
    }
    final minutes = total.round();
    return minutes > 0 && minutes <= 72 * 60 ? minutes : null;
  }

  // A recipe card copied from a web page prints each label on one line and
  // its value on the next: "Prep Time" / "15 mins", "Servings" / "8".
  static final _bareTimeLabel = RegExp(
      r'^(?:(?:prep(?:aration)?|cook(?:ing)?|bak(?:e|ing)|total|active|ready\s+in)(?:\s+time)?'
      '|(?:$_latinLetter'
      r'+[\s-]+){1,2}time|time)\s*:?$',
      caseSensitive: false);
  static final _bareYieldLabel = RegExp(r'^(?:serves|servings?|yields?|makes|portions?)\s*:?$', caseSensitive: false);
  static final _bareDuration = RegExp('^$_durationPattern\$', caseSensitive: false);
  static final _bareCount = RegExp(
      r'^(?:(?:about|approx\.?)\s+)?\d{1,3}(?:\s*(?:-|–|\u2014|to)\s*\d{1,3})?(?:\s+\S+){0,3}$',
      caseSensitive: false);

  /// The label of a summary box on a line of its own, "Prep Time" or
  /// "Servings:", without its colon. Null for any other line.
  static String? _bareLabel(String line) {
    if (line.length > 40 || _digitOrFraction.hasMatch(line) || !_factWord.hasMatch(line)) return null;
    final name = _withoutLeadingSymbols(_cleanMarkdown(_cleanListMarkers(line))).trim();
    if (!_bareTimeLabel.hasMatch(name) && !_bareYieldLabel.hasMatch(name)) return null;
    return name.replaceFirst(RegExp(r'\s*:$'), '');
  }

  /// [label] and the [value] printed under it as one line, "Prep Time: 15
  /// mins". Null when the value is not of the label's kind: a time label
  /// takes a duration, a yield label takes a count.
  static String? _labelWithValue(String label, String value) {
    if (value.length > 40) return null;
    final figure = _cleanMarkdown(value).trim();
    final isDuration = _bareDuration.hasMatch(figure);
    if (_bareTimeLabel.hasMatch(label) ? !isDuration : isDuration || !_bareCount.hasMatch(figure)) return null;
    return '$label: $figure';
  }

  /// Reads the summary box that opens at [start], if one does. Line by line
  /// a box comes out as label, value, label, value, or as a row of labels
  /// followed by the row of their values. Returns its facts as lines of the
  /// form "Prep Time: 15 mins", and the index of the last line it took up.
  ///
  /// A row of labels whose values do not all fit is not paired by guesswork.
  /// It comes back with no facts and the index of its last label, so that
  /// the labels are not tried again one by one.
  static (List<String>, int)? _summaryBox(List<String> lines, int start) {
    final labels = <String>[];
    var at = start;
    var lastLabel = start;
    // A row holds a handful of labels at most.
    while (at < lines.length && labels.length < 8) {
      final line = lines[at].trim();
      if (line.isNotEmpty) {
        final label = _bareLabel(line);
        if (label == null) break;
        labels.add(label);
        lastLabel = at;
      }
      at++;
    }
    if (labels.isEmpty) return null;

    final facts = <String>[];
    var last = start;
    for (final label in labels) {
      while (at < lines.length && lines[at].trim().isEmpty) {
        at++;
      }
      final fact = at < lines.length ? _labelWithValue(label, lines[at].trim()) : null;
      if (fact == null) return labels.length > 1 ? (const [], lastLabel) : null;
      facts.add(fact);
      last = at++;
    }
    return (facts, last);
  }

  // ========== JSON / TIME / IMAGE HELPERS ==========

  static bool _looksLikeJson(String text) {
    final trimmed = text.trim();
    return (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'));
  }

  /// The recipe in a JSON text, the first when it holds several. Null when
  /// the text is not JSON.
  ///
  /// JSON that holds no recipe gives one without ingredients or steps rather
  /// than null: JSON is read as JSON or not at all, since as lines of text
  /// it would only make a recipe of brackets and quotes.
  static ImportedRecipe? _tryParseJson(String text) {
    final json = _decodeJson(text);
    if (json == null) return null;
    final recipe = _jsonRecipes(json).firstOrNull ??
        _buildRecipeFromJsonMap(json is Map ? json : const {});
    recipe.imageUrl = _absoluteUrl(recipe.imageUrl);
    return recipe;
  }

  /// The data in a JSON text, or null when it is not JSON. Files written or
  /// edited by hand are often not quite JSON, so a text that strict JSON
  /// refuses is repaired and tried once more.
  static dynamic _decodeJson(String text) {
    try {
      return jsonDecode(text);
    } on FormatException {
      try {
        return jsonDecode(_cleanJsonText(text));
      } on FormatException {
        return null;
      }
    }
  }

  /// Text that is nearly JSON, repaired: a comma before a closing bracket,
  /// a comment, a code fence or words around the data, a raw line break
  /// inside a string.
  static String _cleanJsonText(String text) {
    // Python and JavaScript write strings in single quotes. That is only
    // assumed of a text without one double quote, since in real JSON an
    // apostrophe has to stay what it is.
    final quoted = !text.contains('"') && text.contains("'")
        ? text.replaceAll("'", '"')
        : text;
    return _repairJson(quoted);
  }

  /// A recipe from JSON that follows no app's format, read by the names
  /// recipe data commonly uses, the schema.org ones among them.
  static ImportedRecipe _buildRecipeFromJsonMap(Map json) {
    // A recipe this app exported itself carries its extras under "_spellbook"
    // and uses two schema.org fields its own way: the category is the app's
    // category id, and the cuisine is the name of the cookbook.
    final ownExport = json['_spellbook'] is Map;

    final categories = [
      if (!ownExport) ..._jsonLdNames(json['recipeCategory']),
      ..._jsonNames(json['categories']),
    ];
    final rawTags = json['tags'] ?? json['keywords'];
    final tags = <String>{
      // One text holds several tags between commas. A list is already split.
      ...(rawTags is String ? _jsonLdNames(rawTags) : _jsonNames(rawTags)),
      ...categories,
    };

    final (prepTime, cookTime) = _splitTotalTime(
      _jsonTime(json, const ['prepTime', 'prep_time', 'prepTimeMinutes', 'prep_time_minutes']),
      _jsonTime(json, const ['cookTime', 'cook_time', 'cookTimeMinutes', 'cook_time_minutes', 'performTime']),
      _jsonTime(json, const ['totalTime', 'total_time', 'totalTimeMinutes', 'total_time_minutes']),
    );

    final cuisine =
        _jsonLdNames(json['cuisine'] ?? (ownExport ? null : json['recipeCuisine'])).join(', ');
    final (sourceUrl, sourceNote) = _sourceAndNote(
      _jsonString(json['url']) ??
          _jsonString(json['sourceUrl']) ??
          _jsonString(json['source_url']) ??
          _jsonString(json['isBasedOn']),
      _jsonString(json['source']) ?? _jsonString(json['creditText']),
    );
    // An export may carry its picture inside the file, as a data: address.
    final image = _extractImage(json['image'] ?? json['imageUrl'] ?? json['photo']);
    final embedded = image == null ? null : _dataImage.matchAsPrefix(image);

    return ImportedRecipe(
      title: _jsonLdText(json['title']) ?? _jsonLdText(json['name']) ?? 'Imported Recipe',
      description: _jsonLdText(json['description']) ?? _jsonLdText(json['summary']),
      ingredients: [
        for (final line in _jsonLdLines(_jsonContent(json, const ['ingredients', 'recipeIngredient'])))
          // RecipeSage writes the title of a group as a line in square
          // brackets.
          _bracketed.hasMatch(line) ? _groupTitle(line.substring(1, line.length - 1)) : line,
      ],
      instructions: _extractJsonInstructions(
          _jsonContent(json, const ['instructions', 'recipeInstructions', 'directions', 'steps']),
          fromFile: true),
      servings: _jsonServings(
          json['servings'] ?? json['yield'] ?? json['serves'] ?? json['recipeYield']),
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      imageUrl: embedded == null ? image : null,
      imageData: embedded == null ? null : image?.substring(embedded.end),
      sourceUrl: sourceUrl,
      suggestedCourse: _courseAmong(
          [_jsonString(json['course']), _jsonString(json['type']), ...categories]),
      suggestedCategory: ownExport
          ? _jsonString(json['recipeCategory'])
          : _jsonString(json['category'])?.toLowerCase(),
      cuisine: cuisine.isEmpty ? null : cuisine,
      tags: tags.isEmpty ? null : tags.toList(),
      notes: _joinNotes([
        _jsonNotes(json['notes'] ?? json['note'] ?? json['tips']),
        _ownComment(json['comment']),
        sourceNote,
        _nutritionLine(json['nutrition']) ??
            _labelledNote('Nutrition', _jsonString(json['nutrition'])),
      ]),
      rating: _jsonRating(json['rating']) ?? _ownRating(json['aggregateRating']),
    );
  }

  static final _dataImage = RegExp(r'data:image/[a-z0-9.+-]{1,20};base64,', caseSensitive: false);
  static final _bracketed = RegExp(r'^\[[^\[\]]+\]$');

  /// The first of [keys] under which [json] lists something: a list or an
  /// object with entries, or text that is not blank. An empty field under
  /// one name does not hide a filled one under another.
  static dynamic _jsonContent(Map json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      final holdsSomething = value is String
          ? value.trim().isNotEmpty
          : (value is List && value.isNotEmpty) || (value is Map && value.isNotEmpty);
      if (holdsSomething) return value;
    }
    return null;
  }

  /// The cook's own note among the comments of schema.org data. An export
  /// writes it as one text, or as a comment named "Author Notes" the way
  /// RecipeSage does. The comments a recipe site lists are what its readers
  /// wrote, which is no note.
  static String? _ownComment(dynamic comment) {
    if (comment is String) return _jsonString(comment);
    return _joinNotes([
      for (final entry in comment is List ? comment : [comment])
        if (entry is Map && entry['name'] == 'Author Notes') _jsonString(entry['text']),
    ]);
  }

  /// The cook's own rating in schema.org data, which only has a place for a
  /// score and the number of votes behind it. An export writes the cook's
  /// stars there with one vote or none. A score with more votes, or one that
  /// is no whole number, is the average of a site's readers.
  static int? _ownRating(dynamic aggregate) {
    if (aggregate is! Map) return null;
    final votes = aggregate['ratingCount'] ?? aggregate['reviewCount'];
    final count = votes is String ? num.tryParse(votes.trim()) : votes;
    if (count is num && count > 1) return null;
    final value = aggregate['ratingValue'];
    final stars = value is String ? num.tryParse(value.trim()) : value;
    return stars is num && stars == stars.roundToDouble() ? _jsonRating(stars) : null;
  }

  /// [value] when it is text with something in it, trimmed. Exports write an
  /// empty string where a field was left blank.
  static String? _jsonString(dynamic value) {
    if (value is! String) return null;
    final text = value.replaceAll('\r\n', '\n').trim();
    return text.isEmpty ? null : text;
  }

  /// The lines of a field that holds one entry per line, blank lines left
  /// out. A list is read as the lines of its texts.
  static List<String> _jsonLines(dynamic value) {
    final lines = <String>[];
    for (final text in value is List ? value : [value]) {
      if (text is! String) continue;
      for (final line in const LineSplitter().convert(text)) {
        if (line.trim().isNotEmpty) lines.add(line.trim());
      }
    }
    return lines;
  }

  /// The names in a list of categories, tags or keywords, each entry a name
  /// or an object that carries one. A field that is one text instead holds a
  /// name per line.
  static List<String> _jsonNames(dynamic value) {
    final names = <String>{};
    for (final entry in value is List ? value : _jsonLines(value)) {
      final name = _jsonString(entry is Map ? entry['name'] : entry);
      if (name != null) names.add(name);
    }
    return names.toList();
  }

  /// The name of a unit or a food, which is either text or an object with a
  /// name.
  static String? _jsonName(dynamic value) =>
      _jsonString(value is Map ? value['name'] : value);

  static final _trailingZeros = RegExp(r'\.?0+$');

  /// A number as a cook writes it: "2" for 2.0, "0.5", and no more than
  /// three decimals.
  static String _plainNumber(num value) {
    if (value == value.roundToDouble()) return value.round().toString();
    final rounded = value.toStringAsFixed(3).replaceFirst(_trailingZeros, '');
    return rounded == '0' || rounded == '-0' ? value.toString() : rounded;
  }

  /// An amount as a cook writes it, or null for none. Apps store "no amount"
  /// as zero.
  static String? _jsonAmount(dynamic value) {
    final text = _jsonString(value);
    final number = value is num ? value : (text == null ? null : num.tryParse(text));
    if (number == null) return text;
    return number.isFinite && number > 0 ? _plainNumber(number) : null;
  }

  /// How many the recipe serves, as the file says it: a number is written
  /// plainly ("4"), words are kept ("4 servings", "1 loaf").
  static String? _jsonServings(dynamic value) {
    if (value is num) return _jsonAmount(value);
    return _jsonLdText(_extractServings(value));
  }

  /// A rating from one to five stars, or null. Apps store "not rated" as
  /// zero.
  static int? _jsonRating(dynamic value) {
    final rating = value is String ? num.tryParse(value.trim()) : value;
    if (rating is! num || !rating.isFinite) return null;
    final stars = rating.round();
    return stars >= 1 && stars <= 5 ? stars : null;
  }

  /// Notes as text: one text, or a list of notes that may each carry a
  /// title.
  static String? _jsonNotes(dynamic value) {
    if (value is! List) return _jsonString(value);
    final notes = <String>[];
    for (final note in value) {
      final text = note is Map
          ? [_jsonString(note['title']), _jsonString(note['text'])].nonNulls.join(': ')
          : _jsonString(note) ?? '';
      if (text.isNotEmpty) notes.add(text);
    }
    return notes.isEmpty ? null : notes.join('\n');
  }

  /// The first of [keys] under which [json] holds a time that can be read:
  /// a number of minutes, or a time as it was typed or exported.
  static int? _jsonTime(Map json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      final minutes = value is String ? _parseTimeString(value) : _parseTimeValue(value);
      if (minutes != null) return minutes;
    }
    return null;
  }

  static List<String> _toStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      String text(dynamic e) {
        if (e is String) return e.trim();
        if (e is Map) return _jsonIngredient(e);
        return e is num ? e.toString() : '';
      }

      final lines = <String>[];
      for (final e in data) {
        // A group of lines nested one level down is read as its lines, under
        // its name when it has one.
        final group = e is Map ? e['ingredients'] ?? e['items'] : e;
        if (group is List) {
          final title = e is Map ? _jsonString(e['name'] ?? e['title']) : null;
          if (title != null) lines.add(_groupTitle(title));
          lines.addAll(group.map(text));
        } else {
          lines.add(text(e));
        }
      }
      return lines.where((s) => s.isNotEmpty).toList();
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

  /// One ingredient that JSON gives as an object, as the line a cook would
  /// write:
  ///   {"amount": "1 cup", "name": "flour"} is "1 cup flour"
  ///   {"quantity": 2, "unit": "tbsp", "ingredient": "oil"} is "2 tbsp oil"
  ///   {"text": "2 eggs, beaten"} is "2 eggs, beaten"
  static String _jsonIngredient(Map e) {
    // The whole line, when the object carries it.
    for (final key in const ['text', 'display', 'original', 'content']) {
      final line = _jsonString(e[key]);
      if (line != null) return _plainFractions(line);
    }

    final name = _jsonName(e['name'] ?? e['ingredient'] ?? e['item'] ?? e['food']);
    if (name == null) return _jsonWords(e);
    final note = _jsonString(e['note'] ?? e['preparation'] ?? e['prep']);
    return [
      _jsonAmount(e['amount'] ?? e['quantity'] ?? e['qty']),
      _jsonName(e['unit'] ?? e['measure']),
      name,
      if (note != null) '($note)',
    ].nonNulls.join(' ');
  }

  static final _idLike = RegExp(
      r'^(?:https?://|[0-9a-f]{8}-[0-9a-f]{4}-|[0-9a-f]{24,}$)',
      caseSensitive: false);

  /// What an object in a shape this reader does not know says in words: its
  /// texts, without the ids, links and type names stored beside them.
  static String _jsonWords(Map object) {
    final words = <String>[];
    object.forEach((key, value) {
      final name = '$key';
      final isId = name == 'id' ||
          name == 'uuid' ||
          name.startsWith('@') ||
          name.endsWith('Id') ||
          name.endsWith('ID') ||
          name.endsWith('_id');
      final text = isId ? null : _jsonString(value);
      if (text != null && !_idLike.hasMatch(text)) words.add(text);
    });
    return words.join(' ');
  }

  /// The steps in a recipe's instructions, whatever shape they are in: one
  /// text, a list of texts, step objects, or groups of steps under a name.
  ///
  /// Recipe JSON that stands on its own, as a file does ([fromFile]), is
  /// read more fully than the data inside a web page. The name of a group is
  /// kept as a line of its own ("For the frosting:"), the form the app turns
  /// into a heading, and a step object in a shape not known here gives the
  /// words it holds.
  static List<String> _extractJsonInstructions(dynamic data, {bool fromFile = false}) {
    // Each step's text, and true where the text is the title of a group.
    final steps = <(String, bool)>[];

    void collect(dynamic item, int depth) {
      if (depth > 8) return;
      if (item is String) {
        // A text on its own holds a step per line.
        for (final line in _htmlToText(item).split('\n')) {
          if (line.trim().isNotEmpty) steps.add((line, false));
        }
      } else if (item is List) {
        for (final entry in item) {
          collect(entry, depth + 1);
        }
      } else if (item is Map) {
        final text = _stepObjectText(item);
        final group = item['itemListElement'] ?? item['steps'];
        // A group holds its steps, or stands in front of them as a marker of
        // its own (a HowToSection with nothing but a name).
        final type = item['@type'];
        final isGroup = group != null || (type is String && type.endsWith('Section'));
        if (text != null) {
          steps.add((_htmlToText(text), false));
        } else if (isGroup) {
          // Its name is a label, not a step.
          final title = fromFile ? _jsonLdText(item['name'] ?? item['title']) : null;
          if (title != null) steps.add((title, true));
          collect(group, depth + 1);
        } else {
          final label = _jsonString(item['description']) ??
              _jsonString(item['name']) ??
              (fromFile ? _jsonWords(item) : '');
          if (label.isNotEmpty) steps.add((_htmlToText(label), false));
        }
      }
    }

    collect(data, 0);
    // One group is no grouping, so its name ("Instructions") is not kept.
    if (steps.where((step) => step.$2).length == 1 && steps.first.$2) {
      steps.removeAt(0);
    }
    return _stepsWithTitles(steps);
  }

  /// The text of a step that JSON gives as an object, under the names its
  /// text commonly goes by. Null for an object that holds none of them,
  /// such as a group of steps.
  static String? _stepObjectText(Map step) {
    for (final key in const ['text', 'instruction', 'direction', 'content', 'step_text', 'step']) {
      final text = _jsonString(step[key]);
      // "step" is as often the number of the step as its text.
      if (text != null && num.tryParse(text) == null) return text;
    }
    return null;
  }

  /// Steps as the lines the app keeps. [steps] holds each step's text, with
  /// true where the text is the title of a group instead, which becomes the
  /// line the app turns into a heading. A recipe whose one step holds the
  /// whole method is read as the lines of that step.
  static List<String> _stepsWithTitles(List<(String, bool)> steps) {
    final single = steps.where((step) => !step.$2).length == 1;
    final lines = <String>[];
    for (final (text, isTitle) in steps) {
      final parts = isTitle
          ? [_groupTitle(text)]
          : (single ? text.split('\n') : [text]).map(_stepText);
      lines.addAll(parts.where((line) => line.isNotEmpty));
    }
    return lines;
  }

  /// The title of a group of ingredients or steps ("For the sauce") as the
  /// line the app turns into a heading: with one colon at its end.
  static String _groupTitle(String name) {
    var end = name.length;
    while (end > 0 && ': \t'.contains(name[end - 1])) {
      end--;
    }
    return '${name.substring(0, end)}:';
  }

  /// Lines of instructions as steps: without the numbers typed in front of
  /// them, since the app numbers its steps itself.
  static List<String> _withoutStepNumbers(Iterable<String> lines) =>
      lines.map(_stepText).where((step) => step.isNotEmpty).toList();

  static final _bareStepLabel = RegExp(r'^(?:step\s?)?\d+[.):]?$', caseSensitive: false);
  static final _stepNumber = RegExp(
      r'^(?:step\s+\d+\s*[.):\-]?\s+|\d+[.):]\s+|\d+[.)](?=[A-Za-z])|[\-*•]\s+)',
      caseSensitive: false);

  /// One instruction step as clean text, without the "1." or "Step 2:" some
  /// sites write in front. The app numbers the steps itself. "2.5 cm of oil"
  /// keeps its number, and a line that is nothing but the number of a step
  /// ("Step 2", over the step itself) is no step at all.
  static String _stepText(String text) {
    final step = (_cleanHtmlText(text) ?? '').replaceFirst(_stepNumber, '');
    return _bareStepLabel.hasMatch(step) ? '' : step;
  }

  static int? _parseTimeValue(dynamic value) {
    num? minutes;
    if (value is num) {
      minutes = value;
    } else if (value is String) {
      // A number on its own is a number of minutes. A number among words
      // that name no unit of time ("serves 4") is not a time at all.
      final text = value.trim();
      minutes = _isoDurationMinutes(text) ?? num.tryParse(text) ?? _minutesInWords(text);
    }
    if (minutes == null || !minutes.isFinite) return null;
    // No time and zero minutes are the same thing to a cook, and nothing
    // takes longer than a year.
    final rounded = minutes.round();
    return (rounded > 0 && rounded <= _longestMinutes) ? rounded : null;
  }

  static const _longestMinutes = 366 * 24 * 60;

  static final _isoDurationPart = RegExp(r'(\d+(?:[.,]\d+)?)([YMWDHS])');

  /// The minutes in an ISO 8601 duration ("PT1H30M", "P0DT0H20M", "PT1800S"),
  /// or null when [text] is not one. Sites get the format wrong in a few
  /// common ways that are read too: lower case, and a missing "T" ("P15M"
  /// meant as fifteen minutes).
  static int? _isoDurationMinutes(String text) {
    final duration = text.toUpperCase();
    if (!duration.startsWith('P')) return null;
    // "M" is months before the "T" and minutes after it. Without a "T" there
    // is no date part, so it can only be minutes.
    var inTime = !duration.contains('T');
    var minutes = 0.0;
    var parts = 0;
    var position = 1;
    while (position < duration.length) {
      if (duration[position] == 'T') {
        inTime = true;
        position++;
        continue;
      }
      final part = _isoDurationPart.matchAsPrefix(duration, position);
      // Anything after a readable start is ignored ("PT20M-PT30M").
      if (part == null) break;
      final amount = double.parse(part.group(1)!.replaceFirst(',', '.'));
      switch (part.group(2)) {
        case 'W':
          minutes += amount * 7 * 24 * 60;
        case 'D':
          minutes += amount * 24 * 60;
        case 'H':
          minutes += amount * 60;
        case 'M':
          if (inTime) minutes += amount;
        case 'S':
          minutes += amount / 60;
      }
      parts++;
      position = part.end;
    }
    if (parts == 0) return null;
    // A run of digits long enough to overflow is not a time.
    return minutes <= _longestMinutes ? minutes.round() : 0;
  }

  /// A time a person typed into a field for one ("1 hr 30 min", "1.5 hours",
  /// "1:30", "90", "about 20") or that data writes ("PT1H30M"), in minutes.
  /// Null for anything that does not read as a time, rather than a guess.
  ///
  /// This reads more freely than [_parseTimeValue] reads the durations of a
  /// web page, where a clock time or a number among other characters is
  /// more likely to be something else.
  static int? _parseTimeString(String time) {
    final text = time.trim();
    return _parseTimeValue(_clockMinutes(text) ?? _roughMinutes(text) ?? text);
  }

  static final _clock = RegExp(r'^(\d{1,3}):([0-5]\d)(?::[0-5]\d)?$');

  /// The minutes in a time written like a clock: "1:30" is an hour and a
  /// half.
  static int? _clockMinutes(String text) {
    final clock = _clock.firstMatch(text);
    if (clock == null) return null;
    return int.parse(clock.group(1)!) * 60 + int.parse(clock.group(2)!);
  }

  static final _roughTime = RegExp(
      r'^(?:(?:~|≈|ca\.?|circa|about|approx(?:\.|imately)?|around|roughly)\s{0,3})?'
      r'(\d{1,6}(?:\.\d{1,3})?)(?:\s{0,3}(?:[-\u2013]|to)\s{0,3}\d{1,6})?\s{0,3}\+?$',
      caseSensitive: false);

  /// The minutes in a number typed without a unit, and not always on its
  /// own ("about 20", "20-25", "20 to 25", "30+"). A range is read as its
  /// first number.
  static num? _roughMinutes(String text) =>
      num.tryParse(_roughTime.firstMatch(text)?.group(1) ?? '');

  static final _timeInWords = RegExp(
      // An amount: 2, 1.5, 1 1/2, 1½, 1/2 or ½, and not the tail of a longer
      // number.
      r'(?<![\d.,/])(?:(\d{1,4}(?:[.,]\d{1,2})?)(?:\s{0,2}(\d)/([1-9]\d?)|\s{0,2}([½¼¾]))?|'
      r'(\d)/([1-9]\d?)|([½¼¾]))\s{0,3}'
      // Its unit, in full or cut short. A letter after it makes it the start
      // of some other word ("2 medium", "3 hot").
      r'(?:(days?|d)|(hours?|hrs?|hr|h|stunden?|std|heures?|horas?|uur|uren)|'
      r'(minutes?|mins?|min|m|minuten?|minutos?|minuti)|(seconds?|secs?|sec|s))(?![a-z])\.?'
      // "1h30": the minutes after an hour, with their unit left out.
      r'(?:\s{0,2}(\d{1,2})(?![\d.,:/]|\s{0,3}[a-z½¼¾]))?',
      caseSensitive: false);

  /// The minutes in a time written out ("1 hour 15 minutes", "1 1/2 hrs",
  /// "45 min", "1h30"), or null when [text] names no unit of time.
  static int? _minutesInWords(String text) {
    // A time is a few words at most. Anything longer is some other text that
    // happens to mention one.
    if (text.length > 120) return null;
    var minutes = 0.0;
    var found = false;
    for (final part in _timeInWords.allMatches(text)) {
      var amount = double.parse((part.group(1) ?? '0').replaceFirst(',', '.'));
      final over = part.group(2) ?? part.group(5);
      final under = part.group(3) ?? part.group(6);
      if (over != null && under != null) amount += int.parse(over) / int.parse(under);
      amount += _fractionValues[part.group(4) ?? part.group(7)] ?? 0;

      if (part.group(8) != null) {
        minutes += amount * 24 * 60;
      } else if (part.group(9) != null) {
        minutes += amount * 60 + int.parse(part.group(12) ?? '0');
      } else if (part.group(10) != null) {
        minutes += amount;
      } else {
        minutes += amount / 60;
      }
      found = true;
    }
    return found ? minutes.round() : null;
  }

  static String? _extractImage(dynamic image, [int depth = 0]) {
    if (image is String) return image.trim().isEmpty ? null : image.trim();
    // Nothing real nests its picture this deep.
    if (depth > 4) return null;
    if (image is List) {
      // The first entry that holds an address. Sites list several sizes.
      for (final item in image) {
        final found = _extractImage(item, depth + 1);
        if (found != null) return found;
      }
    }
    if (image is Map) return _extractImage(image['url'] ?? image['contentUrl'], depth + 1);
    return null;
  }

  static String? _extractServings(dynamic data) {
    if (data == null) return null;
    if (data is int) return '$data servings';
    if (data is double && data.isFinite) {
      return data == data.roundToDouble() ? '${data.round()} servings' : '$data servings';
    }
    if (data is String) return data;
    if (data is List) {
      // The first entry that says something. Sites list "4" next to
      // "4 servings".
      for (final entry in data) {
        final servings =
            entry is num ? '$entry' : (entry is List ? null : _extractServings(entry));
        if (servings != null && servings.trim().isNotEmpty) return servings;
      }
      return null;
    }
    // QuantitativeValue: {"value": 4, "unitText": "servings"}
    if (data is Map && (data['value'] is num || data['value'] is String)) {
      return '${data['value']} ${data['unitText'] ?? 'servings'}';
    }
    return null;
  }
}

// ========== SUPPORTING TYPES ==========

enum _Section { unknown, ingredients, instructions, notes }

enum _Platform { instagram, tiktok, pinterest, youtube, squarespace, generic }

/// One recipe segment after splitting — text plus its start line in the
/// original OCR document (used to map back to PDF pages for cover images).
class _RecipeSegment {
  final String text;
  final int startLine;
  const _RecipeSegment({required this.text, required this.startLine});
}

class _Metadata {
  final String? servings;
  final int? prepTime;
  final int? cookTime;
  _Metadata({this.servings, this.prepTime, this.cookTime});
}