import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ENUMS & DATA CLASSES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum GroceryProvider { instacart, kroger }

class GroceryProduct {
  final String id;
  final String name;
  final String? brand;
  final String? imageUrl;
  final double? price;
  final String? size;
  final bool available;

  const GroceryProduct({
    required this.id,
    required this.name,
    this.brand,
    this.imageUrl,
    this.price,
    this.size,
    this.available = true,
  });
}

class CartAddResult {
  final bool success;
  final int itemsAdded;
  final int itemsFailed;
  final List<String> failedItems;
  final String? checkoutUrl;
  final String? message;

  const CartAddResult({
    required this.success,
    this.itemsAdded = 0,
    this.itemsFailed = 0,
    this.failedItems = const [],
    this.checkoutUrl,
    this.message,
  });
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  GROCERY SERVICE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class GroceryService {
  static const _storage = FlutterSecureStorage();

  // Secure storage keys
  static const _instacartApiKey = 'grocery_instacart_api_key';
  static const _krogerClientId = 'grocery_kroger_client_id';
  static const _krogerClientSecret = 'grocery_kroger_client_secret';
  static const _krogerSearchToken = 'grocery_kroger_search_token';
  static const _krogerCartToken = 'grocery_kroger_cart_token';
  static const _krogerCartRefreshToken = 'grocery_kroger_cart_refresh_token';
  static const _krogerLocationId = 'grocery_kroger_location_id';
  static const _krogerTokenExpiry = 'grocery_kroger_token_expiry';

  static const _defaultInstacartKey = String.fromEnvironment(
      'INSTACART_API_KEY');
  static const _defaultKrogerClientId = String.fromEnvironment(
      'KROGER_CLIENT_ID');
  static const _defaultKrogerSecret = String.fromEnvironment(
      'KROGER_CLIENT_SECRET');

  // Instacart Developer Platform (IDP) endpoint
  // Development: https://connect.dev.instacart.tools/idp/v1
  // Production:  https://connect.instacart.com/idp/v1
  static const _instacartIdpBase = String.fromEnvironment(
      'INSTACART_IDP_BASE',
      defaultValue: 'https://connect.instacart.com/idp/v1');

  // Kroger OAuth
  static const _krogerRedirectUri = 'recipespellbook://kroger-callback';
  static const _krogerAuthUrl =
      'https://api.kroger.com/v1/connect/oauth2/authorize';
  static const _krogerTokenUrl =
      'https://api.kroger.com/v1/connect/oauth2/token';

  // ────────────────────────────────────────────
  //  KEY RETRIEVAL (secure storage override → embedded default)
  // ────────────────────────────────────────────

  static Future<String> _getInstacartKey() async {
    final stored = await _storage.read(key: _instacartApiKey);
    return (stored != null && stored.isNotEmpty) ? stored : _defaultInstacartKey;
  }

  static Future<String> _getKrogerClientId() async {
    final stored = await _storage.read(key: _krogerClientId);
    return (stored != null && stored.isNotEmpty) ? stored : _defaultKrogerClientId;
  }

  static Future<String> _getKrogerSecret() async {
    final stored = await _storage.read(key: _krogerClientSecret);
    return (stored != null && stored.isNotEmpty) ? stored : _defaultKrogerSecret;
  }

  // ────────────────────────────────────────────
  //  CONFIGURATION STATUS
  // ────────────────────────────────────────────

  /// Instacart: always true (embedded key).
  /// Kroger: true only after user completes OAuth login.
  static Future<bool> isConfigured(GroceryProvider provider) async {
    switch (provider) {
      case GroceryProvider.instacart:
        return true;
      case GroceryProvider.kroger:
        final token = await _storage.read(key: _krogerCartToken);
        return token != null && token.isNotEmpty;
    }
  }

  /// Check if Kroger can at least search (client_credentials — no login).
  static Future<bool> isKrogerSearchReady() async {
    final token = await _storage.read(key: _krogerSearchToken);
    if (token != null) return true;
    return krogerAuthenticateForSearch();
  }

  static Future<void> configureInstacart({required String apiKey}) async {
    await _storage.write(key: _instacartApiKey, value: apiKey);
  }

  static Future<void> configureKroger({
    required String clientId,
    required String clientSecret,
  }) async {
    await _storage.write(key: _krogerClientId, value: clientId);
    await _storage.write(key: _krogerClientSecret, value: clientSecret);
  }

  static Future<void> setKrogerLocation(String locationId) async {
    await _storage.write(key: _krogerLocationId, value: locationId);
  }

  static Future<String?> getKrogerLocationId() async {
    return _storage.read(key: _krogerLocationId);
  }

  static Future<void> disconnect(GroceryProvider provider) async {
    switch (provider) {
      case GroceryProvider.instacart:
        await _storage.delete(key: _instacartApiKey);
        break;
      case GroceryProvider.kroger:
        for (final k in [
          _krogerClientId, _krogerClientSecret,
          _krogerSearchToken, _krogerCartToken,
          _krogerCartRefreshToken, _krogerLocationId,
          _krogerTokenExpiry,
        ]) {
          await _storage.delete(key: k);
        }
        break;
    }
  }

  // ════════════════════════════════════════════
  //  INSTACART  (Developer Platform — IDP API)
  //
  //  Uses the Create Shopping List Page and
  //  Create Recipe Page endpoints to generate
  //  hosted landing pages on Instacart Marketplace.
  //  Instacart handles all product matching.
  // ════════════════════════════════════════════

  /// Create a Shopping List page on Instacart Marketplace.
  /// Returns the hosted URL or null on failure.
  ///
  /// Docs: https://docs.instacart.com/developer_platform_api/api/products/create_shopping_list_page/
  static Future<String?> instacartCreateShoppingListPage({
    required String title,
    required List<Map<String, dynamic>> lineItems,
    String? imageUrl,
    String? partnerLinkbackUrl,
    bool enablePantryItems = true,
    int expiresInDays = 7,
  }) async {
    final apiKey = await _getInstacartKey();
    try {
      final body = <String, dynamic>{
        'title': title,
        'link_type': 'shopping_list',
        'expires_in': expiresInDays,
        'line_items': lineItems,
        'landing_page_configuration': {
          'enable_pantry_items': enablePantryItems,
          if (partnerLinkbackUrl != null)
            'partner_linkback_url': partnerLinkbackUrl,
        },
        if (imageUrl != null) 'image_url': imageUrl,
      };

      debugPrint('[Instacart IDP] Creating shopping list page: '
          '${lineItems.length} items, title="$title"');

      final resp = await http.post(
        Uri.parse('$_instacartIdpBase/products/products_link'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('[Instacart IDP] Shopping list → ${resp.statusCode}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        final url = data['products_link_url']?.toString();
        debugPrint('[Instacart IDP] URL: $url');
        return url;
      }

      _logResponse('[Instacart IDP]', resp);
    } catch (e) {
      debugPrint('[Instacart IDP] Shopping list error: $e');
    }
    return null;
  }

  /// Create a Recipe page on Instacart Marketplace.
  /// Returns the hosted URL or null on failure.
  ///
  /// Docs: https://docs.instacart.com/developer_platform_api/api/products/create_recipe_page/
  static Future<String?> instacartCreateRecipePage({
    required String title,
    required List<Map<String, dynamic>> ingredients,
    List<String>? instructions,
    String? imageUrl,
    String? author,
    int? servings,
    int? cookingTimeMinutes,
    String? partnerLinkbackUrl,
    bool enablePantryItems = true,
    int expiresInDays = 30,
  }) async {
    final apiKey = await _getInstacartKey();
    try {
      final body = <String, dynamic>{
        'title': title,
        'expires_in': expiresInDays,
        'ingredients': ingredients,
        'landing_page_configuration': {
          'enable_pantry_items': enablePantryItems,
          if (partnerLinkbackUrl != null)
            'partner_linkback_url': partnerLinkbackUrl,
        },
        if (imageUrl != null) 'image_url': imageUrl,
        if (author != null) 'author': author,
        if (servings != null) 'servings': servings,
        if (cookingTimeMinutes != null) 'cooking_time': cookingTimeMinutes,
        if (instructions != null && instructions.isNotEmpty)
          'instructions': instructions,
      };

      debugPrint('[Instacart IDP] Creating recipe page: '
          '${ingredients.length} ingredients, title="$title"');

      final resp = await http.post(
        Uri.parse('$_instacartIdpBase/products/recipe'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('[Instacart IDP] Recipe page → ${resp.statusCode}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        final url = data['products_link_url']?.toString();
        debugPrint('[Instacart IDP] URL: $url');
        return url;
      }

      _logResponse('[Instacart IDP]', resp);
    } catch (e) {
      debugPrint('[Instacart IDP] Recipe page error: $e');
    }
    return null;
  }

  /// Build a line_item for the Shopping List API from an ingredient string.
  /// Parses "2 cups flour" into {name: "flour", measurements: [...], display_text: "2 cups flour"}.
  static Map<String, dynamic> buildInstacartLineItem(String ingredientText) {
    final cleaned = cleanForSearch(ingredientText);
    final item = <String, dynamic>{
      'name': cleaned,
      'display_text': ingredientText.trim(),
    };

    // Try to extract quantity and unit from the original text
    final match = RegExp(
      r'^([\d½¼¾⅓⅔⅛⅜⅝⅞/.]+)\s*'
      r'(cups?|tbsp|tsp|tablespoons?|teaspoons?|'
      r'oz|ounces?|lbs?|pounds?|g|kg|ml|l|liters?|'
      r'quarts?|pints?|gallons?)\s+',
      caseSensitive: false,
    ).firstMatch(ingredientText.trim());

    if (match != null) {
      final qtyStr = match.group(1)!;
      final unitStr = match.group(2)!;

      double? qty;
      if (qtyStr.contains('½')) qty = 0.5;
      else if (qtyStr.contains('¼')) qty = 0.25;
      else if (qtyStr.contains('¾')) qty = 0.75;
      else if (qtyStr.contains('⅓')) qty = 0.33;
      else if (qtyStr.contains('⅔')) qty = 0.67;
      else if (qtyStr.contains('⅛')) qty = 0.125;
      else qty = double.tryParse(qtyStr);

      final unit = _normalizeInstacartUnit(unitStr);

      if (qty != null && unit != null) {
        item['line_item_measurements'] = [
          {'quantity': qty, 'unit': unit},
        ];
      }
    }

    return item;
  }

  /// Build an ingredient object for the Recipe Page API.
  static Map<String, dynamic> buildInstacartIngredient(String ingredientText) {
    final cleaned = cleanForSearch(ingredientText);
    final item = <String, dynamic>{
      'name': cleaned,
      'display_text': ingredientText.trim(),
    };

    final match = RegExp(
      r'^([\d½¼¾⅓⅔⅛⅜⅝⅞/.]+)\s*'
      r'(cups?|tbsp|tsp|tablespoons?|teaspoons?|'
      r'oz|ounces?|lbs?|pounds?|g|kg|ml|l|liters?|'
      r'quarts?|pints?|gallons?)\s+',
      caseSensitive: false,
    ).firstMatch(ingredientText.trim());

    if (match != null) {
      final qtyStr = match.group(1)!;
      final unitStr = match.group(2)!;

      double? qty;
      if (qtyStr.contains('½')) qty = 0.5;
      else if (qtyStr.contains('¼')) qty = 0.25;
      else if (qtyStr.contains('¾')) qty = 0.75;
      else if (qtyStr.contains('⅓')) qty = 0.33;
      else if (qtyStr.contains('⅔')) qty = 0.67;
      else if (qtyStr.contains('⅛')) qty = 0.125;
      else qty = double.tryParse(qtyStr);

      final unit = _normalizeInstacartUnit(unitStr);

      if (qty != null && unit != null) {
        item['measurements'] = [
          {'quantity': qty, 'unit': unit},
        ];
      }
    }

    return item;
  }

  /// Normalize unit strings to Instacart's accepted values.
  /// See: https://docs.instacart.com/developer_platform_api/api/units_of_measurement/
  static String? _normalizeInstacartUnit(String raw) {
    final u = raw.toLowerCase().trim();
    if (u.startsWith('cup')) return 'cup';
    if (u.startsWith('tbsp') || u.startsWith('tablespoon')) return 'tbsp';
    if (u.startsWith('tsp') || u.startsWith('teaspoon')) return 'tsp';
    if (u == 'oz' || u.startsWith('ounce')) return 'oz';
    if (u == 'lb' || u == 'lbs' || u.startsWith('pound')) return 'lb';
    if (u == 'g') return 'g';
    if (u == 'kg') return 'kg';
    if (u == 'ml') return 'ml';
    if (u == 'l' || u.startsWith('liter')) return 'l';
    if (u.startsWith('quart')) return 'qt';
    if (u.startsWith('pint')) return 'pt';
    if (u.startsWith('gallon')) return 'gal';
    return null;
  }

  // ════════════════════════════════════════════
  //  KROGER
  // ════════════════════════════════════════════

  // ── Search auth (client_credentials) ──

  static Future<bool> krogerAuthenticateForSearch() async {
    final clientId = await _getKrogerClientId();
    final clientSecret = await _getKrogerSecret();
    try {
      final creds = base64Encode(utf8.encode('$clientId:$clientSecret'));
      debugPrint('[Kroger] Auth (client_credentials)...');
      final resp = await http.post(
        Uri.parse(_krogerTokenUrl),
        headers: {
          'Authorization': 'Basic $creds',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials&scope=product.compact',
      );
      debugPrint('[Kroger] Auth → ${resp.statusCode}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        await _storage.write(key: _krogerSearchToken, value: data['access_token']);
        return true;
      }
      _logResponse('[Kroger]', resp);
    } catch (e) {
      debugPrint('[Kroger] Auth error: $e');
    }
    return false;
  }

  // ── Cart auth (authorization_code — user login) ──

  static Future<bool> krogerStartOAuthLogin() async {
    final clientId = await _getKrogerClientId();
    final authUri = Uri.parse(_krogerAuthUrl).replace(queryParameters: {
      'scope': 'cart.basic:write product.compact',
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': _krogerRedirectUri,
    });
    debugPrint('[Kroger] OAuth URL: $authUri');
    try {
      return await launchUrl(authUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[Kroger] OAuth launch error: $e');
      return false;
    }
  }

  static Future<bool> krogerExchangeAuthCode(String authCode) async {
    final clientId = await _getKrogerClientId();
    final clientSecret = await _getKrogerSecret();
    try {
      final creds = base64Encode(utf8.encode('$clientId:$clientSecret'));
      debugPrint('[Kroger] Exchanging auth code...');
      final resp = await http.post(
        Uri.parse(_krogerTokenUrl),
        headers: {
          'Authorization': 'Basic $creds',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=authorization_code'
            '&code=${Uri.encodeComponent(authCode)}'
            '&redirect_uri=${Uri.encodeComponent(_krogerRedirectUri)}',
      );
      debugPrint('[Kroger] Token exchange → ${resp.statusCode}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        await _storage.write(key: _krogerCartToken, value: data['access_token']);
        if (data['refresh_token'] != null) {
          await _storage.write(
              key: _krogerCartRefreshToken, value: data['refresh_token']);
        }
        final expiresIn = data['expires_in'] as int? ?? 1800;
        final expiry = DateTime.now().add(Duration(seconds: expiresIn));
        await _storage.write(key: _krogerTokenExpiry, value: expiry.toIso8601String());
        debugPrint('[Kroger] Cart tokens saved, expires $expiry');
        return true;
      }
      _logResponse('[Kroger]', resp);
    } catch (e) {
      debugPrint('[Kroger] Token exchange error: $e');
    }
    return false;
  }

  static Future<bool> _krogerRefreshCartToken() async {
    final refreshToken = await _storage.read(key: _krogerCartRefreshToken);
    if (refreshToken == null) return false;
    final clientId = await _getKrogerClientId();
    final clientSecret = await _getKrogerSecret();
    try {
      final creds = base64Encode(utf8.encode('$clientId:$clientSecret'));
      debugPrint('[Kroger] Refreshing cart token...');
      final resp = await http.post(
        Uri.parse(_krogerTokenUrl),
        headers: {
          'Authorization': 'Basic $creds',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=refresh_token'
            '&refresh_token=${Uri.encodeComponent(refreshToken)}',
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        await _storage.write(key: _krogerCartToken, value: data['access_token']);
        if (data['refresh_token'] != null) {
          await _storage.write(
              key: _krogerCartRefreshToken, value: data['refresh_token']);
        }
        final expiresIn = data['expires_in'] as int? ?? 1800;
        final expiry = DateTime.now().add(Duration(seconds: expiresIn));
        await _storage.write(key: _krogerTokenExpiry, value: expiry.toIso8601String());
        debugPrint('[Kroger] Refreshed, expires $expiry');
        return true;
      }
      debugPrint('[Kroger] Refresh failed: ${resp.statusCode}');
    } catch (e) {
      debugPrint('[Kroger] Refresh error: $e');
    }
    return false;
  }

  static Future<String?> _getKrogerCartToken() async {
    final token = await _storage.read(key: _krogerCartToken);
    if (token == null) return null;
    final expiryStr = await _storage.read(key: _krogerTokenExpiry);
    if (expiryStr != null) {
      final expiry = DateTime.tryParse(expiryStr);
      if (expiry != null &&
          DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 2)))) {
        if (await _krogerRefreshCartToken()) {
          return _storage.read(key: _krogerCartToken);
        }
        return null;
      }
    }
    return token;
  }

  // ── Product search ──

  static Future<List<GroceryProduct>> krogerSearch(String query) async {
    var token = await _storage.read(key: _krogerSearchToken);
    if (token == null) {
      if (!await krogerAuthenticateForSearch()) return [];
      token = await _storage.read(key: _krogerSearchToken);
    }
    final locationId = await _storage.read(key: _krogerLocationId);
    try {
      var url = 'https://api.kroger.com/v1/products'
          '?filter.term=${Uri.encodeComponent(query)}&filter.limit=5';
      if (locationId != null) url += '&filter.locationId=$locationId';

      debugPrint('[Kroger] Search "$query"');
      final resp = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      debugPrint('[Kroger] → ${resp.statusCode}');

      if (resp.statusCode == 401) {
        debugPrint('[Kroger] Search token expired, re-auth...');
        if (!await krogerAuthenticateForSearch()) return [];
        return krogerSearch(query);
      }
      if (resp.statusCode == 200) {
        final products = (jsonDecode(resp.body)['data'] as List?) ?? [];
        debugPrint('[Kroger] ${products.length} results for "$query"');
        return products.map((p) {
          final imgs = p['images'] as List?;
          String? imgUrl;
          if (imgs != null && imgs.isNotEmpty) {
            final sizes = imgs.first['sizes'] as List?;
            if (sizes != null && sizes.isNotEmpty) imgUrl = sizes.first['url'];
          }
          final pItems = p['items'] as List?;
          double? price;
          String? size;
          if (pItems != null && pItems.isNotEmpty) {
            price = (pItems.first['price']?['regular'] as num?)?.toDouble();
            size = pItems.first['size'];
          }
          return GroceryProduct(
            id: p['productId']?.toString() ?? '',
            name: p['description'] ?? query,
            brand: p['brand'],
            imageUrl: imgUrl,
            price: price,
            size: size,
          );
        }).toList();
      }
      _logResponse('[Kroger]', resp);
    } catch (e) {
      debugPrint('[Kroger] Search error: $e');
    }
    return [];
  }

  // ── Add to cart ──

  static Future<CartAddResult> krogerAddToCart(
      List<Map<String, dynamic>> items) async {
    final token = await _getKrogerCartToken();
    if (token == null) {
      return const CartAddResult(
        success: false,
        message: 'Not signed in to Kroger. Please connect your account first.',
      );
    }
    try {
      final cartItems = items
          .map((it) => {
        'upc': it['product_id']?.toString() ?? '',
        'quantity': it['quantity'] ?? 1,
      })
          .toList();
      debugPrint('[Kroger] Adding ${cartItems.length} items to cart');
      final resp = await http.put(
        Uri.parse('https://api.kroger.com/v1/cart/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'items': cartItems}),
      );
      debugPrint('[Kroger] Cart → ${resp.statusCode}');

      if (resp.statusCode == 204 || resp.statusCode == 200) {
        return CartAddResult(
          success: true,
          itemsAdded: items.length,
          checkoutUrl: 'https://www.kroger.com/cart',
        );
      }
      if (resp.statusCode == 401) {
        if (await _krogerRefreshCartToken()) return krogerAddToCart(items);
        return const CartAddResult(
          success: false,
          message: 'Session expired. Please reconnect Kroger.',
        );
      }
      _logResponse('[Kroger]', resp);
      return CartAddResult(
        success: false,
        itemsFailed: items.length,
        message: 'API ${resp.statusCode}',
      );
    } catch (e) {
      debugPrint('[Kroger] Cart error: $e');
      return CartAddResult(success: false, message: '$e');
    }
  }

  /// Find nearby Kroger-family stores by zip
  static Future<List<Map<String, dynamic>>> krogerSearchLocations(
      String zipCode) async {
    var token = await _storage.read(key: _krogerSearchToken);
    if (token == null) {
      if (!await krogerAuthenticateForSearch()) return [];
      token = await _storage.read(key: _krogerSearchToken);
    }
    try {
      final resp = await http.get(
        Uri.parse('https://api.kroger.com/v1/locations'
            '?filter.zipCode.near=$zipCode&filter.limit=5'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      if (resp.statusCode == 200) {
        final locs = (jsonDecode(resp.body)['data'] as List?) ?? [];
        return locs
            .map((l) => <String, dynamic>{
          'id': l['locationId'],
          'name': l['name'],
          'address': l['address']?['addressLine1'],
          'city': l['address']?['city'],
          'state': l['address']?['state'],
          'zip': l['address']?['zipCode'],
        })
            .toList();
      }
    } catch (e) {
      debugPrint('[Kroger] Location error: $e');
    }
    return [];
  }

  // ════════════════════════════════════════════
  //  INGREDIENT NAME CLEANING
  // ════════════════════════════════════════════

  static String cleanForSearch(String raw) {
    var s = raw.trim();

    // 1. Strip leading quantity + unit (e.g. "2 cups", "½ lb")
    //    Uses \b after unit to prevent "l" matching inside "large".
    //    Repeats to handle compound amounts like "1 14oz can".
    for (var i = 0; i < 2; i++) {
      final before = s;
      s = s.replaceFirst(
        RegExp(
          r'^[\d½¼¾⅓⅔⅛⅜⅝⅞/.\s]+'
          r'(?:'
          r'cups?|tbsps?|tsps?|tablespoons?|teaspoons?|'
          r'oz|ounces?|lbs?|pounds?|'
          r'grams?|kg|ml|liters?|litres?|'
          r'cloves?|stalks?|heads?|bunche?s?|'
          r'cans?|jars?|bottles?|packages?|pkgs?|containers?|box(?:es)?|bags?|'
          r'pieces?|slices?|pinche?s?|dash(?:es)?|'
          r'large|medium|small|whole'
          r')\b'
          r'\s*',
          caseSensitive: false,
        ),
        '',
      );
      if (s == before) break; // nothing stripped, stop
    }
    // Also strip a bare leading number (e.g. "2 eggs" → "eggs")
    s = s.replaceFirst(RegExp(r'^[\d½¼¾⅓⅔⅛⅜⅝⅞/.]+\s+'), '');

    // 2. Strip parenthetical content — "(15 oz)", "(softened)", etc.
    //    Must come before orphan container so "1 (6oz) can paste" → "can paste" → "paste"
    s = s.replaceAll(RegExp(r'\([^)]*\)'), '').trim();

    // 3. Strip orphaned container words left after qty+unit removal
    //    "can crushed tomatoes" → "crushed tomatoes"  (from "1 14oz can ...")
    //    "jar marinara sauce"  → "marinara sauce"
    s = s.replaceFirst(
      RegExp(
        r'^(?:cans?|jars?|bottles?|box(?:es)?|bags?|containers?|'
        r'packages?|pkgs?|cartons?|tubs?)\s+(?:of\s+)?',
        caseSensitive: false,
      ),
      '',
    );

    // 4. Strip leading "of" — "of flour" → "flour"
    s = s.replaceFirst(RegExp(r'^of\s+', caseSensitive: false), '');

    // 5. Split on comma or semicolon — take first part only
    //    "chicken breast, boneless skinless" → "chicken breast"
    s = s.split(RegExp(r'[,;]')).first.trim();

    // 6. Strip "or ..." alternatives — take only the first option
    //    "milk or half and half" → "milk"
    //    "butter or margarine" → "butter"
    s = s.replaceFirst(
      RegExp(r'\s+or\s+.*', caseSensitive: false),
      '',
    );

    // 7. Strip "/" alternatives — take the first option
    //    "milk/cream" → "milk"
    if (s.contains('/') && !s.startsWith('/')) {
      s = s.split('/').first.trim();
    }

    // 8. Strip ALL leading prep/cooking words (repeating to catch stacked modifiers)
    //    "bone-in skin-on chicken thighs" → "chicken thighs"
    //    "finely chopped fresh onion" → "onion"
    for (var i = 0; i < 3; i++) {
      final before = s;
      s = s.replaceFirst(
        RegExp(
          r'^(?:(?:finely|thinly|roughly|freshly|coarsely)\s+)?'
          r'(?:cut|diced|chopped|sliced|minced|grated|shredded|'
          r'crushed|julienned|cubed|halved|quartered|squeezed|'
          r'peeled|deveined|trimmed|deboned|drained|rinsed|'
          r'thawed|frozen|canned|packed|sifted|fresh|dried|'
          r'bone-in|boneless|skinless|skin-on|'
          r'unsalted|salted|sweetened|unsweetened)\s+',
          caseSensitive: false,
        ),
        '',
      );
      if (s == before) break;
    }

    // 9. Strip TRAILING prep/state words and everything after
    //    "chicken thighs bone-in" → "chicken thighs"
    //    "basil leaves for garnish" → "basil leaves"
    s = s.replaceFirst(
      RegExp(
        r'\s+(?:cut|diced|chopped|sliced|minced|grated|shredded|'
        r'crushed|julienned|cubed|halved|quartered|squeezed|'
        r'peeled|deveined|trimmed|deboned|drained|rinsed|'
        r'to taste|for garnish|for serving|for topping|as needed|'
        r'at room temperature|room temp|softened|melted|chilled|'
        r'freshly ground|freshly cracked|finely|thinly|roughly|'
        r'optional|if desired|divided|plus more|'
        r'bone-in|boneless|skinless|skin-on|'
        r'about|approximately)\b.*',
        caseSensitive: false,
      ),
      '',
    );

    // 10. Collapse whitespace
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 11. Fallback: if everything got stripped, use first 3 words of original
    if (s.isEmpty) s = raw.trim().split(RegExp(r'\s+')).take(3).join(' ');
    return s;
  }

  // ════════════════════════════════════════════
  //  DEEP LINKS
  // ════════════════════════════════════════════

  static Uri deepLinkUrl(GroceryProvider provider, String query) {
    final q = Uri.encodeComponent(query);
    switch (provider) {
      case GroceryProvider.instacart:
        return Uri.parse('https://www.instacart.com/store/search/$q');
      case GroceryProvider.kroger:
        return Uri.parse('https://www.kroger.com/search?query=$q&searchType=default_search');
    }
  }

  static Uri storeHomepage(GroceryProvider provider) {
    switch (provider) {
      case GroceryProvider.instacart:
        return Uri.parse('https://www.instacart.com/');
      case GroceryProvider.kroger:
        return Uri.parse('https://www.kroger.com/');
    }
  }

  static Future<bool> openDeepLink(GroceryProvider provider, String query) async {
    final url = deepLinkUrl(provider, cleanForSearch(query));
    debugPrint('[GroceryService] Deep link: $url');
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[GroceryService] Deep link error: $e');
      return false;
    }
  }

  static Future<bool> openStore(GroceryProvider provider) async {
    try {
      return await launchUrl(storeHomepage(provider),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[GroceryService] Open store error: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════
  //  SEND TO STORE (high-level)
  // ════════════════════════════════════════════

  static Future<CartAddResult> sendToStore({
    required GroceryProvider provider,
    required List<String> ingredientNames,
    String? listTitle,
    void Function(int current, int total, String item)? onProgress,
  }) async {
    if (ingredientNames.isEmpty) {
      return const CartAddResult(success: false, message: 'No items');
    }

    final configured = await isConfigured(provider);
    debugPrint('[SendToStore] ${provider.name} configured=$configured '
        'items=${ingredientNames.length}');

    switch (provider) {
      case GroceryProvider.instacart:
      // IDP API — single call, Instacart handles product matching
        return _sendViaInstacartIdp(
          ingredientNames: ingredientNames,
          title: listTitle ?? 'Shopping List',
          onProgress: onProgress,
        );
      case GroceryProvider.kroger:
        if (configured) {
          return _sendViaKrogerApi(
            ingredientNames: ingredientNames,
            onProgress: onProgress,
          );
        }
        return _sendViaDeepLink(
            provider: provider, ingredientNames: ingredientNames);
    }
  }

  /// Instacart IDP flow: build line items → create page → open URL
  static Future<CartAddResult> _sendViaInstacartIdp({
    required List<String> ingredientNames,
    required String title,
    void Function(int current, int total, String item)? onProgress,
  }) async {
    onProgress?.call(0, 1, 'Creating shopping list on Instacart...');

    final lineItems = ingredientNames
        .map((name) => buildInstacartLineItem(name))
        .toList();

    final url = await instacartCreateShoppingListPage(
      title: title,
      lineItems: lineItems,
    );

    if (url != null) {
      // Don't auto-open — let the dialog's branded CTA button handle the redirect.
      // This ensures the user taps the Instacart-branded button to visit
      // the Shopping List / Recipe landing page URL (per Instacart guidelines).
      // Instacart auto-matches ALL items and adds them to the cart.
      // Unknown items appear as unmatched with alternatives on the hosted page.
      return CartAddResult(
        success: true,
        itemsAdded: ingredientNames.length,
        checkoutUrl: url,
        message: 'Shopping list created on Instacart',
      );
    }

    // IDP API failed — return error instead of falling back to search page.
    // We never want to open a search box; the IDP API handles product matching.
    debugPrint('[SendToStore] IDP API failed, returning error');
    return CartAddResult(
      success: false,
      itemsFailed: ingredientNames.length,
      failedItems: ingredientNames,
      message: 'Could not create Instacart shopping list. Please try again.',
    );
  }

  /// Kroger flow: search per-ingredient → add to cart
  static Future<CartAddResult> _sendViaKrogerApi({
    required List<String> ingredientNames,
    void Function(int current, int total, String item)? onProgress,
  }) async {
    final matched = <Map<String, dynamic>>[];
    final failed = <String>[];
    int consecutiveEmpty = 0;

    for (var i = 0; i < ingredientNames.length; i++) {
      final name = cleanForSearch(ingredientNames[i]);
      onProgress?.call(i + 1, ingredientNames.length, name);

      final results = await krogerSearch(name);

      if (results.isNotEmpty) {
        consecutiveEmpty = 0;
        matched.add({
          'product_id': results.first.id,
          'name': results.first.name,
          'quantity': 1,
          'index': i,
        });
      } else {
        consecutiveEmpty++;
        failed.add(name);

        if (consecutiveEmpty >= 3 && matched.isEmpty) {
          debugPrint('[SendToStore] 3 consecutive misses, 0 matches → deep link');
          return _sendViaDeepLink(
            provider: GroceryProvider.kroger,
            ingredientNames: ingredientNames,
          );
        }
      }
    }

    if (matched.isEmpty) {
      debugPrint('[SendToStore] 0 matches → deep link');
      return _sendViaDeepLink(
        provider: GroceryProvider.kroger,
        ingredientNames: ingredientNames,
      );
    }

    debugPrint('[SendToStore] ${matched.length} matched, ${failed.length} failed → cart');

    final result = await krogerAddToCart(matched);

    return CartAddResult(
      success: result.success,
      itemsAdded: result.itemsAdded > 0 ? result.itemsAdded : matched.length,
      itemsFailed: failed.length + result.itemsFailed,
      failedItems: [...failed, ...result.failedItems],
      checkoutUrl: result.checkoutUrl,
      message: result.message,
    );
  }

  static Future<CartAddResult> _sendViaDeepLink({
    required GroceryProvider provider,
    required List<String> ingredientNames,
  }) async {
    final cleaned = ingredientNames.take(3).map(cleanForSearch).join(' ');
    debugPrint('[SendToStore] Deep link: ${provider.name} "$cleaned"');
    await openDeepLink(provider, cleaned);
    return CartAddResult(
      success: true,
      itemsAdded: ingredientNames.length,
      message: 'Opened in browser',
      checkoutUrl: deepLinkUrl(provider, cleaned).toString(),
    );
  }

  /// Plain text for clipboard
  static String formatForClipboard(List<String> names) =>
      names.map((n) => '\u2022 $n').join('\n');

  // ── Logging helper ──
  static void _logResponse(String tag, http.Response resp) {
    final body = resp.body.length > 250 ? resp.body.substring(0, 250) : resp.body;
    debugPrint('$tag ${resp.statusCode}: $body');
  }
}