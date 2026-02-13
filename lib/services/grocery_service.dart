import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  // Secure storage keys (user overrides)
  static const _instacartApiKey = 'grocery_instacart_api_key';
  static const _krogerClientId = 'grocery_kroger_client_id';
  static const _krogerClientSecret = 'grocery_kroger_client_secret';
  static const _krogerAccessToken = 'grocery_kroger_access_token';
  static const _krogerRefreshToken = 'grocery_kroger_refresh_token';
  static const _krogerLocationId = 'grocery_kroger_location_id';

  // ────────────────────────────────────────────
  //  EMBEDDED DEFAULTS (bundled with app)
  //  User-configured keys in secure storage take priority.
  //  Replace with production keys before release.
  // ────────────────────────────────────────────
  static const _defaultInstacartKey = '***REMOVED***';
  static const _defaultKrogerClientId = '***REMOVED***';
  static const _defaultKrogerSecret = '***REMOVED***';

  // ────────────────────────────────────────────
  //  KEY RETRIEVAL (secure storage → embedded default)
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
  //  CONFIGURATION
  // ────────────────────────────────────────────

  /// Always returns true — embedded defaults are available for both providers.
  /// If user has overridden keys in secure storage, those take priority.
  static Future<bool> isConfigured(GroceryProvider provider) async {
    return true;
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
          _krogerClientId,
          _krogerClientSecret,
          _krogerAccessToken,
          _krogerRefreshToken,
          _krogerLocationId,
        ]) {
          await _storage.delete(key: k);
        }
        break;
    }
  }

  // ────────────────────────────────────────────
  //  INSTACART  (Developer Platform)
  //  https://docs.instacart.com/developer_platform_api/
  // ────────────────────────────────────────────

  static Future<List<GroceryProduct>> instacartSearch(String query) async {
    final apiKey = await _getInstacartKey();

    try {
      final uri = Uri.parse(
        'https://connect.instacart.com/v2/fulfillment/catalog'
            '?query=${Uri.encodeComponent(query)}&limit=5',
      );
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      if (resp.statusCode == 200) {
        final list = (jsonDecode(resp.body)['catalog_items'] as List?) ?? [];
        return list
            .map((i) => GroceryProduct(
          id: i['id']?.toString() ?? '',
          name: i['name'] ?? query,
          brand: i['brand'],
          imageUrl: i['image_url'],
          price: (i['price'] as num?)?.toDouble(),
          size: i['size'],
          available: i['available'] ?? true,
        ))
            .toList();
      }
      debugPrint('Instacart search: ${resp.statusCode} ${resp.body}');
    } catch (e) {
      debugPrint('Instacart search error: $e');
    }
    return [];
  }

  static Future<CartAddResult> instacartAddToCart(
      List<Map<String, dynamic>> items) async {
    final apiKey = await _getInstacartKey();
    try {
      final lineItems = items
          .map((it) => {
        'line_num': it['index'] ?? 0,
        'product_id': it['product_id'] ?? '',
        'quantity': it['quantity'] ?? 1,
      })
          .toList();

      final resp = await http.post(
        Uri.parse('https://connect.instacart.com/v2/fulfillment/orders'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'order': {'line_items': lineItems}}),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        return CartAddResult(
          success: true,
          itemsAdded: items.length,
          checkoutUrl: data['checkout_url'],
        );
      }
      return CartAddResult(
        success: false,
        itemsFailed: items.length,
        message: 'API ${resp.statusCode}',
      );
    } catch (e) {
      return CartAddResult(success: false, message: '$e');
    }
  }

  // ────────────────────────────────────────────
  //  KROGER  (Public API)
  //  https://developer.kroger.com/documentation
  // ────────────────────────────────────────────

  static Future<bool> krogerAuthenticate() async {
    final clientId = await _getKrogerClientId();
    final clientSecret = await _getKrogerSecret();
    try {
      final creds = base64Encode(utf8.encode('$clientId:$clientSecret'));
      final resp = await http.post(
        Uri.parse('https://api.kroger.com/v1/connect/oauth2/token'),
        headers: {
          'Authorization': 'Basic $creds',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials&scope=product.compact',
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        await _storage.write(
            key: _krogerAccessToken, value: data['access_token']);
        if (data['refresh_token'] != null) {
          await _storage.write(
              key: _krogerRefreshToken, value: data['refresh_token']);
        }
        return true;
      }
      debugPrint('Kroger auth: ${resp.statusCode} ${resp.body}');
    } catch (e) {
      debugPrint('Kroger auth error: $e');
    }
    return false;
  }

  static Future<List<GroceryProduct>> krogerSearch(String query) async {
    var token = await _storage.read(key: _krogerAccessToken);
    if (token == null) {
      if (!await krogerAuthenticate()) return [];
      token = await _storage.read(key: _krogerAccessToken);
    }
    final locationId = await _storage.read(key: _krogerLocationId);
    try {
      var url = 'https://api.kroger.com/v1/products'
          '?filter.term=${Uri.encodeComponent(query)}&filter.limit=5';
      if (locationId != null) url += '&filter.locationId=$locationId';

      final resp = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      if (resp.statusCode == 401) {
        // Token expired — re-auth and retry once
        if (!await krogerAuthenticate()) return [];
        return krogerSearch(query);
      }
      if (resp.statusCode == 200) {
        final products = (jsonDecode(resp.body)['data'] as List?) ?? [];
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
    } catch (e) {
      debugPrint('Kroger search error: $e');
    }
    return [];
  }

  /// Add to Kroger cart (one-way: API allows add but not remove)
  static Future<CartAddResult> krogerAddToCart(
      List<Map<String, dynamic>> items) async {
    final token = await _storage.read(key: _krogerAccessToken);
    if (token == null) {
      return const CartAddResult(success: false, message: 'Not authenticated');
    }
    try {
      final cartItems = items
          .map((it) =>
      {'upc': it['product_id'], 'quantity': it['quantity'] ?? 1})
          .toList();
      final resp = await http.put(
        Uri.parse('https://api.kroger.com/v1/cart/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'items': cartItems}),
      );
      if (resp.statusCode == 204 || resp.statusCode == 200) {
        return CartAddResult(
          success: true,
          itemsAdded: items.length,
          checkoutUrl: 'https://www.kroger.com/cart',
        );
      }
      return CartAddResult(
        success: false,
        itemsFailed: items.length,
        message: 'API ${resp.statusCode}',
      );
    } catch (e) {
      return CartAddResult(success: false, message: '$e');
    }
  }

  /// Find nearby Kroger-family stores by zip
  static Future<List<Map<String, dynamic>>> krogerSearchLocations(
      String zipCode) async {
    var token = await _storage.read(key: _krogerAccessToken);
    if (token == null) {
      if (!await krogerAuthenticate()) return [];
      token = await _storage.read(key: _krogerAccessToken);
    }
    try {
      final resp = await http.get(
        Uri.parse('https://api.kroger.com/v1/locations'
            '?filter.zipCode.near=$zipCode&filter.limit=5'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
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
      debugPrint('Kroger location error: $e');
    }
    return [];
  }

  // ────────────────────────────────────────────
  //  INGREDIENT NAME CLEANING
  // ────────────────────────────────────────────

  /// Strips prep instructions, quantities, and fractions from ingredient text
  /// to produce a clean search-friendly name.
  ///
  /// "guanciale, cut into ¼-inch batons" → "guanciale"
  /// "2 cups all-purpose flour, sifted" → "all-purpose flour"
  /// "fresh mozzarella, sliced thin" → "fresh mozzarella"
  /// "1½ lb boneless chicken breast, cubed" → "boneless chicken breast"
  static String cleanForSearch(String raw) {
    var s = raw.trim();

    // Remove leading quantities: "2 cups", "1½ lb", "¼ tsp", "1/2 cup"
    s = s.replaceFirst(
      RegExp(
        r'^[\d½¼¾⅓⅔⅛⅜⅝⅞/.\s]+'  // digits, fractions, slashes, dots
        r'(?:'
        r'cups?|tbsp|tsp|tablespoons?|teaspoons?|'
        r'oz|ounces?|lbs?|pounds?|'
        r'g|kg|ml|l|liters?|litres?|'
        r'cloves?|stalks?|heads?|bunche?s?|'
        r'cans?|jars?|bottles?|packages?|pkgs?|'
        r'pieces?|slices?|pinche?s?|dashes?|'
        r'large|medium|small|whole'
        r')?'
        r'\s*',
        caseSensitive: false,
      ),
      '',
    );

    // Cut at comma, semicolon, or parenthetical — prep instructions follow
    // "guanciale, cut into batons" → "guanciale"
    // "flour (sifted)" → "flour"
    s = s.split(RegExp(r'[,;(]')).first.trim();

    // Remove trailing prep phrases after common keywords
    s = s.replaceFirst(
      RegExp(
        r'\s+(?:cut|diced|chopped|sliced|minced|grated|shredded|'
        r'crushed|julienned|cubed|halved|quartered|'
        r'peeled|deveined|trimmed|deboned|'
        r'to taste|for garnish|for serving|as needed|'
        r'at room temperature|room temp|softened|melted|'
        r'freshly ground|freshly cracked|finely|thinly|roughly)\b.*',
        caseSensitive: false,
      ),
      '',
    );

    // Collapse whitespace
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    // If cleaning removed everything, fall back to first 3 words of original
    if (s.isEmpty) {
      s = raw.trim().split(RegExp(r'\s+')).take(3).join(' ');
    }

    return s;
  }

  // ────────────────────────────────────────────
  //  DEEP LINK FALLBACKS (when API not configured)
  // ────────────────────────────────────────────

  static Uri deepLinkUrl(GroceryProvider provider, String query) {
    final q = Uri.encodeComponent(query);
    switch (provider) {
      case GroceryProvider.instacart:
        return Uri.parse('https://www.instacart.com/store/search/$q');
      case GroceryProvider.kroger:
        return Uri.parse(
            'https://www.kroger.com/search?query=$q&searchType=default_search');
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

  static Future<bool> openDeepLink(
      GroceryProvider provider, String query) async {
    final url = deepLinkUrl(provider, cleanForSearch(query));
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Failed to open deep link: $e');
      return false;
    }
  }

  static Future<bool> openStore(GroceryProvider provider) async {
    final url = storeHomepage(provider);
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Failed to open store: $e');
      return false;
    }
  }

  // ────────────────────────────────────────────
  //  HIGH-LEVEL: SEND TO STORE
  // ────────────────────────────────────────────

  /// Best-effort send: uses API when configured, deep link fallback otherwise.
  static Future<CartAddResult> sendToStore({
    required GroceryProvider provider,
    required List<String> ingredientNames,
    void Function(int current, int total, String item)? onProgress,
  }) async {
    if (ingredientNames.isEmpty) {
      return const CartAddResult(success: false, message: 'No items');
    }

    final configured = await isConfigured(provider);
    if (configured) {
      return _sendViaApi(
        provider: provider,
        ingredientNames: ingredientNames,
        onProgress: onProgress,
      );
    }
    return _sendViaDeepLink(
        provider: provider, ingredientNames: ingredientNames);
  }

  static Future<CartAddResult> _sendViaApi({
    required GroceryProvider provider,
    required List<String> ingredientNames,
    void Function(int current, int total, String item)? onProgress,
  }) async {
    final matched = <Map<String, dynamic>>[];
    final failed = <String>[];

    for (var i = 0; i < ingredientNames.length; i++) {
      final name = cleanForSearch(ingredientNames[i]);
      onProgress?.call(i + 1, ingredientNames.length, ingredientNames[i]);

      List<GroceryProduct> results;
      switch (provider) {
        case GroceryProvider.instacart:
          results = await instacartSearch(name);
          break;
        case GroceryProvider.kroger:
          results = await krogerSearch(name);
          break;
      }

      if (results.isNotEmpty) {
        matched.add({
          'product_id': results.first.id,
          'name': results.first.name,
          'quantity': 1,
          'index': i,
        });
      } else {
        failed.add(name);
      }
    }

    if (matched.isEmpty) {
      return CartAddResult(
        success: false,
        itemsFailed: ingredientNames.length,
        failedItems: failed,
        message: 'No products found',
      );
    }

    CartAddResult result;
    switch (provider) {
      case GroceryProvider.instacart:
        result = await instacartAddToCart(matched);
        break;
      case GroceryProvider.kroger:
        result = await krogerAddToCart(matched);
        break;
    }

    return CartAddResult(
      success: result.success,
      itemsAdded: result.itemsAdded,
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
      names.map((n) => '• $n').join('\n');
}