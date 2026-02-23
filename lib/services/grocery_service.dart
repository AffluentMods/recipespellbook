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

  static const _defaultInstacartKey =
      '***REMOVED***';
  static const _defaultKrogerClientId = '***REMOVED***';
  static const _defaultKrogerSecret = '***REMOVED***';

  // Instacart Connect production endpoint
  static const _instacartBase = 'https://connect.instacart.com';

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

  /// Instacart: always true (embedded key, swap to prod when ready).
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
  //  INSTACART  (Connect API — production)
  // ════════════════════════════════════════════

  static Future<List<GroceryProduct>> instacartSearch(String query) async {
    final apiKey = await _getInstacartKey();
    try {
      final uri = Uri.parse(
        '$_instacartBase/v2/fulfillment/catalog'
            '?query=${Uri.encodeComponent(query)}&limit=5',
      );
      debugPrint('[Instacart] Search "$query"');
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      debugPrint('[Instacart] → ${resp.statusCode} (${resp.body.length}b)');

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final List items =
            body['catalog_items'] ?? body['items'] ?? body['products'] ?? [];
        debugPrint('[Instacart] ${items.length} results for "$query"');
        return items
            .map((i) => GroceryProduct(
          id: (i['id'] ?? i['product_id'] ?? '').toString(),
          name: i['name'] ?? i['title'] ?? query,
          brand: i['brand'] ?? i['brand_name'],
          imageUrl: i['image_url'] ?? i['thumbnail_url'],
          price: (i['price'] as num?)?.toDouble() ??
              (i['base_price'] as num?)?.toDouble(),
          size: i['size'] ?? i['unit_size'],
          available: i['available'] ?? i['in_stock'] ?? true,
        ))
            .toList();
      }
      _logResponse('[Instacart]', resp);
    } catch (e) {
      debugPrint('[Instacart] Search error: $e');
    }
    return [];
  }

  static Future<CartAddResult> instacartAddToCart(
      List<Map<String, dynamic>> items) async {
    final apiKey = await _getInstacartKey();
    try {
      final lineItems = items.asMap().entries.map((e) => {
        'line_num': (e.key + 1).toString(),
        'product_id': e.value['product_id']?.toString() ?? '',
        'quantity': e.value['quantity'] ?? 1,
      }).toList();

      debugPrint('[Instacart] Creating order with ${lineItems.length} items');
      final resp = await http.post(
        Uri.parse('$_instacartBase/v2/fulfillment/orders'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'order': {'line_items': lineItems, 'order_type': 'delivery'},
        }),
      );
      debugPrint('[Instacart] Order → ${resp.statusCode}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        final url = data['checkout_url'] ??
            data['order']?['checkout_url'] ??
            data['order']?['url'] ??
            data['url'];
        return CartAddResult(
          success: true,
          itemsAdded: items.length,
          checkoutUrl: url?.toString(),
          message: url != null ? 'Order created' : 'Items added',
        );
      }
      _logResponse('[Instacart]', resp);

      // Fallback: open store search for first product
      if (items.isNotEmpty) {
        final name = items.first['name']?.toString() ?? '';
        return CartAddResult(
          success: false,
          itemsFailed: items.length,
          message: 'API ${resp.statusCode}',
          checkoutUrl: deepLinkUrl(GroceryProvider.instacart, name).toString(),
        );
      }
      return CartAddResult(
          success: false, itemsFailed: items.length, message: 'API ${resp.statusCode}');
    } catch (e) {
      debugPrint('[Instacart] Order error: $e');
      return CartAddResult(success: false, message: '$e');
    }
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

  /// Opens browser → Kroger login → redirects to recipespellbook://kroger-callback?code=XXX
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

  /// Exchange auth code from callback for tokens.
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
    s = s.replaceFirst(
      RegExp(
        r'^[\d½¼¾⅓⅔⅛⅜⅝⅞/.\s]+'
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
    s = s.split(RegExp(r'[,;(]')).first.trim();
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
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
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
    void Function(int current, int total, String item)? onProgress,
  }) async {
    if (ingredientNames.isEmpty) {
      return const CartAddResult(success: false, message: 'No items');
    }

    final configured = await isConfigured(provider);
    debugPrint('[SendToStore] ${provider.name} configured=$configured '
        'items=${ingredientNames.length}');

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
    int consecutiveEmpty = 0;

    for (var i = 0; i < ingredientNames.length; i++) {
      final name = cleanForSearch(ingredientNames[i]);
      onProgress?.call(i + 1, ingredientNames.length, name);

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

        // Safety: if first 3 all miss and nothing matched yet,
        // API probably can't find products → bail to deep link
        if (consecutiveEmpty >= 3 && matched.isEmpty) {
          debugPrint('[SendToStore] 3 consecutive misses, 0 matches → deep link');
          return _sendViaDeepLink(
            provider: provider,
            ingredientNames: ingredientNames,
          );
        }
      }
    }

    if (matched.isEmpty) {
      debugPrint('[SendToStore] 0 matches → deep link');
      return _sendViaDeepLink(
        provider: provider,
        ingredientNames: ingredientNames,
      );
    }

    debugPrint('[SendToStore] ${matched.length} matched, ${failed.length} failed → cart');

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