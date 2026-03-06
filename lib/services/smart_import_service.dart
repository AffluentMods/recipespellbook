import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service that calls the Smart Import backend to parse recipes using AI.
///
/// Usage:
/// ```dart
/// final result = await SmartImportService.instance.parseFromText(
///   text: rawRecipeText,
///   existingParse: badParseMap, // optional
/// );
/// if (result.success) {
///   // result.recipe has the structured data
/// }
/// ```
class SmartImportService {
  SmartImportService._();
  static final instance = SmartImportService._();

  /// Base URL for the smart import API.
  /// Injected at build time via --dart-define-from-file.
  static const _baseUrl = String.fromEnvironment(
    'SMART_IMPORT_URL',
    defaultValue: 'https://smart-import.recipespellbook.app',
  );

  /// Auth token for the current user.
  /// Set this after user login / subscription validation.
  String? _authToken;

  void setAuthToken(String token) => _authToken = token;
  void clearAuth() => _authToken = null;

  /// Whether the user has a valid auth token set.
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  // ══════════════════════════════════════════
  //  PUBLIC API
  // ══════════════════════════════════════════

  /// Parse a recipe from raw text (pasted, OCR output, scraped HTML, etc.)
  Future<SmartImportResult> parseFromText({
    required String text,
    Map<String, dynamic>? existingParse,
  }) async {
    return _callApi(
      text: text,
      existingParse: existingParse,
    );
  }

  /// Parse a recipe from an image file (photo of cookbook, screenshot, etc.)
  Future<SmartImportResult> parseFromImage({
    required File imageFile,
    String? additionalText,
    Map<String, dynamic>? existingParse,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final base64 = base64Encode(bytes);
    final mediaType = _guessMediaType(imageFile.path);

    return _callApi(
      imageBase64: base64,
      imageMediaType: mediaType,
      text: additionalText,
      existingParse: existingParse,
    );
  }

  /// Parse a recipe from raw image bytes (e.g. from camera).
  Future<SmartImportResult> parseFromImageBytes({
    required Uint8List bytes,
    String mediaType = 'image/jpeg',
    String? additionalText,
    Map<String, dynamic>? existingParse,
  }) async {
    return _callApi(
      imageBase64: base64Encode(bytes),
      imageMediaType: mediaType,
      text: additionalText,
      existingParse: existingParse,
    );
  }

  /// Parse a recipe from a URL (when the built-in scraper produced bad results).
  Future<SmartImportResult> parseFromUrl({
    required String url,
    Map<String, dynamic>? existingParse,
  }) async {
    return _callApi(
      url: url,
      existingParse: existingParse,
    );
  }

  /// Check how many smart imports the user has remaining this month.
  Future<SmartImportUsage> getUsage() async {
    try {
      final response = await _get('/v1/smart-import/usage');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SmartImportUsage(
          used: data['used'] ?? 0,
          limit: data['limit'] ?? 0,
          tier: data['tier'] ?? 'free',
          remaining: data['remaining'] ?? 0,
        );
      }
      return SmartImportUsage.unavailable();
    } catch (e) {
      debugPrint('Smart import usage check failed: $e');
      return SmartImportUsage.unavailable();
    }
  }

  // ══════════════════════════════════════════
  //  INTERNAL
  // ══════════════════════════════════════════

  Future<SmartImportResult> _callApi({
    String? text,
    String? imageBase64,
    String? imageMediaType,
    String? url,
    Map<String, dynamic>? existingParse,
  }) async {
    if (!isAuthenticated) {
      return SmartImportResult.error(
        'Not authenticated. Sign in with a subscription to use Smart Import.',
      );
    }

    try {
      final body = <String, dynamic>{};

      if (text != null && text.isNotEmpty) {
        body['text'] = text;
      }
      if (imageBase64 != null) {
        body['image_base64'] = imageBase64;
        body['image_media_type'] = imageMediaType ?? 'image/jpeg';
      }
      if (url != null && url.isNotEmpty) {
        body['url'] = url;
      }
      if (existingParse != null) {
        body['existing_parse'] = existingParse;
      }

      final response = await _post('/v1/smart-import', body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SmartImportResult(
          success: true,
          recipe: data['recipe'] as Map<String, dynamic>,
          modelUsed: data['model_used'] ?? '',
          usageThisMonth: data['usage_this_month'] ?? 0,
          usageLimit: data['usage_limit'] ?? 0,
          tokensUsed: data['tokens_used'],
        );
      }

      // Handle specific error codes
      if (response.statusCode == 429) {
        final data = jsonDecode(response.body);
        final detail = data['detail'];
        if (detail is Map) {
          return SmartImportResult.error(
            detail['message'] ?? 'Monthly smart import limit reached.',
            errorCode: 'limit_reached',
            usageThisMonth: detail['used'],
            usageLimit: detail['limit'],
          );
        }
        return SmartImportResult.error('Monthly smart import limit reached.');
      }

      if (response.statusCode == 401) {
        return SmartImportResult.error(
          'Authentication failed. Please sign in again.',
          errorCode: 'auth_failed',
        );
      }

      if (response.statusCode == 502) {
        final data = jsonDecode(response.body);
        return SmartImportResult.error(
          data['detail'] ?? 'AI could not parse this recipe. Try again or edit manually.',
          errorCode: 'ai_error',
        );
      }

      return SmartImportResult.error(
        'Server error (${response.statusCode}). Please try again.',
      );
    } on SocketException {
      return SmartImportResult.error(
        'No internet connection. Smart Import requires an internet connection.',
        errorCode: 'no_connection',
      );
    } on http.ClientException catch (e) {
      return SmartImportResult.error('Connection error: $e');
    } catch (e) {
      debugPrint('Smart import error: $e');
      return SmartImportResult.error('Unexpected error: $e');
    }
  }

  Future<http.Response> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$path');
    return http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_authToken',
      },
      body: jsonEncode(body),
    ).timeout(
      const Duration(seconds: 60), // AI can take a moment
    );
  }

  Future<http.Response> _get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    return http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $_authToken',
      },
    ).timeout(
      const Duration(seconds: 10),
    );
  }

  String _guessMediaType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}

// ══════════════════════════════════════════
//  DATA CLASSES
// ══════════════════════════════════════════

class SmartImportResult {
  final bool success;
  final Map<String, dynamic>? recipe;
  final String? errorMessage;
  final String? errorCode;
  final String? modelUsed;
  final int? usageThisMonth;
  final int? usageLimit;
  final int? tokensUsed;

  const SmartImportResult({
    required this.success,
    this.recipe,
    this.errorMessage,
    this.errorCode,
    this.modelUsed,
    this.usageThisMonth,
    this.usageLimit,
    this.tokensUsed,
  });

  factory SmartImportResult.error(String message, {
    String? errorCode,
    int? usageThisMonth,
    int? usageLimit,
  }) {
    return SmartImportResult(
      success: false,
      errorMessage: message,
      errorCode: errorCode,
      usageThisMonth: usageThisMonth,
      usageLimit: usageLimit,
    );
  }

  /// Remaining imports this month.
  int get remaining =>
      (usageLimit ?? 0) - (usageThisMonth ?? 0);

  /// Whether the user hit their monthly limit.
  bool get isLimitReached => errorCode == 'limit_reached';
}

class SmartImportUsage {
  final int used;
  final int limit;
  final String tier;
  final int remaining;
  final bool available;

  const SmartImportUsage({
    required this.used,
    required this.limit,
    required this.tier,
    required this.remaining,
    this.available = true,
  });

  factory SmartImportUsage.unavailable() {
    return const SmartImportUsage(
      used: 0, limit: 0, tier: 'unknown', remaining: 0, available: false,
    );
  }
}