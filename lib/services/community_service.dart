import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'auth_service.dart';

// ════════════════════════════════════════════
//  MODELS
// ════════════════════════════════════════════

class CommunityPublisher {
  final String id;
  final String? name;
  final String? avatarUrl;

  const CommunityPublisher({required this.id, this.name, this.avatarUrl});

  factory CommunityPublisher.fromJson(Map<String, dynamic> json) => CommunityPublisher(
    id: json['id'] as String,
    name: json['name'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
  );

  String get displayName => name ?? 'Anonymous Chef';
}

class CommunityListItem {
  final String id;
  final String title;
  final String? description;
  final String? imagePath;
  final int recipeCount;
  final int downloadCount;
  final DateTime createdAt;
  final CommunityPublisher publisher;

  const CommunityListItem({
    required this.id, required this.title, this.description, this.imagePath,
    required this.recipeCount, required this.downloadCount,
    required this.createdAt, required this.publisher,
  });

  factory CommunityListItem.fromJson(Map<String, dynamic> json) => CommunityListItem(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    imagePath: json['imagePath'] as String?,
    recipeCount: json['recipeCount'] as int? ?? 0,
    downloadCount: json['downloadCount'] as int? ?? 0,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    publisher: CommunityPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
  );
}

class CommunityDetail {
  final String id;
  final String title;
  final String? description;
  final String? imagePath;
  final int recipeCount;
  final int downloadCount;
  final DateTime createdAt;
  final CommunityPublisher publisher;
  final List<CommunityRecipe> recipes;

  const CommunityDetail({
    required this.id, required this.title, this.description, this.imagePath,
    required this.recipeCount, required this.downloadCount,
    required this.createdAt, required this.publisher, required this.recipes,
  });

  factory CommunityDetail.fromJson(Map<String, dynamic> json) => CommunityDetail(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    imagePath: json['imagePath'] as String?,
    recipeCount: json['recipeCount'] as int? ?? 0,
    downloadCount: json['downloadCount'] as int? ?? 0,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    publisher: CommunityPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
    recipes: (json['recipes'] as List?)?.map((r) => CommunityRecipe.fromJson(r as Map<String, dynamic>)).toList() ?? [],
  );
}

class CommunityRecipe {
  final String title;
  final String? description;
  final String? servings;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final String? sourceUrl;
  final String? imagePath;
  final int? rating;
  final String? notes;
  final String? nutritionJson;
  final List<CommunityIngredient> ingredients;
  final List<CommunityStep> steps;
  final List<String> tags;

  const CommunityRecipe({
    required this.title, this.description, this.servings,
    this.prepTimeMinutes, this.cookTimeMinutes, this.sourceUrl,
    this.imagePath, this.rating, this.notes, this.nutritionJson,
    required this.ingredients, required this.steps, required this.tags,
  });

  factory CommunityRecipe.fromJson(Map<String, dynamic> json) => CommunityRecipe(
    title: json['title'] as String? ?? 'Untitled',
    description: json['description'] as String?,
    servings: json['servings'] as String?,
    prepTimeMinutes: json['prepTimeMinutes'] as int?,
    cookTimeMinutes: json['cookTimeMinutes'] as int?,
    sourceUrl: json['sourceUrl'] as String?,
    imagePath: json['imagePath'] as String?,
    rating: json['rating'] as int?,
    notes: json['notes'] as String?,
    nutritionJson: json['nutritionJson'] as String?,
    ingredients: (json['ingredients'] as List?)?.map((i) => CommunityIngredient.fromJson(i as Map<String, dynamic>)).toList() ?? [],
    steps: (json['steps'] as List?)?.map((s) => CommunityStep.fromJson(s as Map<String, dynamic>)).toList() ?? [],
    tags: (json['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
  );
}

class CommunityIngredient {
  final int sortOrder;
  final String? amount;
  final String? unit;
  final String name;
  final String? notes;

  const CommunityIngredient({required this.sortOrder, this.amount, this.unit, required this.name, this.notes});

  factory CommunityIngredient.fromJson(Map<String, dynamic> json) => CommunityIngredient(
    sortOrder: json['sortOrder'] as int? ?? 0,
    amount: json['amount'] as String?,
    unit: json['unit'] as String?,
    name: json['name'] as String? ?? '',
    notes: json['notes'] as String?,
  );
}

class CommunityStep {
  final int sortOrder;
  final String instruction;
  final int? durationMinutes;

  const CommunityStep({required this.sortOrder, required this.instruction, this.durationMinutes});

  factory CommunityStep.fromJson(Map<String, dynamic> json) => CommunityStep(
    sortOrder: json['sortOrder'] as int? ?? 0,
    instruction: json['instruction'] as String? ?? '',
    durationMinutes: json['durationMinutes'] as int?,
  );
}

class CommunityFeedResult {
  final List<CommunityListItem> publications;
  final int page;
  final int total;
  final int totalPages;

  const CommunityFeedResult({
    required this.publications, required this.page,
    required this.total, required this.totalPages,
  });
}

class MyPublication {
  final String id;
  final String title;
  final String? description;
  final String? imagePath;
  final int recipeCount;
  final int downloadCount;
  final bool isRemoved;
  final DateTime createdAt;

  const MyPublication({
    required this.id, required this.title, this.description, this.imagePath,
    required this.recipeCount, required this.downloadCount,
    required this.isRemoved, required this.createdAt,
  });

  factory MyPublication.fromJson(Map<String, dynamic> json) => MyPublication(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    imagePath: json['imagePath'] as String?,
    recipeCount: json['recipeCount'] as int? ?? 0,
    downloadCount: json['downloadCount'] as int? ?? 0,
    isRemoved: json['isRemoved'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

// ════════════════════════════════════════════
//  SERVICE
// ════════════════════════════════════════════

class CommunityService {
  CommunityService._();
  static final instance = CommunityService._();

  final _auth = AuthService.instance;
  static const _deviceIdKey = 'community_device_id';

  String? _deviceId;

  /// Get or create a persistent device ID for download tracking.
  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString(_deviceIdKey);
    if (_deviceId == null) {
      _deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, _deviceId!);
    }
    return _deviceId!;
  }

  // ────────────────────────────────────
  //  Browse
  // ────────────────────────────────────

  /// Fetch the community feed.
  /// [sort]: 'recent', 'popular', 'downloads'
  Future<CommunityFeedResult?> browse({
    String sort = 'recent',
    int page = 1,
    int limit = 20,
    String? query,
  }) async {
    try {
      final params = <String, String>{
        'sort': sort,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (query != null && query.isNotEmpty) params['q'] = query;

      final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final r = await _auth.get('/v1/community?$queryString');

      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return CommunityFeedResult(
          publications: (data['publications'] as List)
              .map((p) => CommunityListItem.fromJson(p as Map<String, dynamic>))
              .toList(),
          page: data['page'] as int? ?? 1,
          total: data['total'] as int? ?? 0,
          totalPages: data['totalPages'] as int? ?? 1,
        );
      }
    } catch (e) {
      debugPrint('[Community] browse: $e');
    }
    return null;
  }

  /// Fetch full details of a publication.
  Future<CommunityDetail?> getPublication(String id) async {
    try {
      final r = await _auth.get('/v1/community/$id');
      if (r.statusCode == 200) {
        return CommunityDetail.fromJson(jsonDecode(r.body));
      }
    } catch (e) {
      debugPrint('[Community] getPublication: $e');
    }
    return null;
  }

  // ────────────────────────────────────
  //  Download
  // ────────────────────────────────────

  /// Download a published cookbook. Tracks unique download by device.
  /// Returns the full recipe data for local import.
  Future<CommunityDetail?> download(String publicationId) async {
    try {
      final deviceId = await getDeviceId();
      final r = await _auth.post('/v1/community/$publicationId/download', {
        'deviceId': deviceId,
      });
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        // download endpoint returns same shape as detail
        return CommunityDetail.fromJson({
          ...data,
          'recipeCount': (data['recipes'] as List?)?.length ?? 0,
          'downloadCount': 0, // not returned from download endpoint
          'createdAt': DateTime.now().toIso8601String(),
          'publisher': data['publisher'] ?? {'id': '', 'name': 'Unknown'},
        });
      }
    } catch (e) {
      debugPrint('[Community] download: $e');
    }
    return null;
  }

  // ────────────────────────────────────
  //  Publish
  // ────────────────────────────────────

  /// Publish a cookbook to the community feed.
  ///
  /// Sends all cookbook + recipe data inline so the server doesn't need to
  /// look anything up.  [title] is required; [recipes] must be a JSON-ready
  /// list of maps (see CommunityPublishScreen for how they're built).
  Future<({bool success, String? error, String? publicationId})> publish({
    required String title,
    String? description,
    String? imagePath,
    required List<Map<String, dynamic>> recipes,
  }) async {
    try {
      final r = await _auth.post('/v1/community', {
        'title': title,
        if (description != null) 'description': description,
        if (imagePath != null) 'imagePath': imagePath,
        'recipes': recipes,
      });
      if (r.statusCode == 201) {
        final data = jsonDecode(r.body);
        return (success: true, error: null, publicationId: data['id'] as String?);
      }
      return (success: false, error: _parseError(r), publicationId: null);
    } catch (e) {
      return (success: false, error: 'Connection error', publicationId: null);
    }
  }

  /// Get my published cookbooks.
  Future<List<MyPublication>> getMyPublications() async {
    try {
      final r = await _auth.get('/v1/community/me/publications');
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return (data['publications'] as List)
            .map((p) => MyPublication.fromJson(p as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[Community] getMyPublications: $e');
    }
    return [];
  }

  /// Unpublish one of my cookbooks.
  Future<bool> unpublish(String publicationId) async {
    try {
      final r = await _auth.delete('/v1/community/$publicationId');
      return r.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // ────────────────────────────────────
  //  Report
  // ────────────────────────────────────

  /// Report a publication.
  Future<bool> report(String publicationId, String reason, {String? details}) async {
    try {
      final r = await _auth.post('/v1/community/$publicationId/report', {
        'reason': reason,
        if (details != null) 'details': details,
      });
      return r.statusCode == 200;
    } catch (_) {}
    return false;
  }

  String _parseError(dynamic response) {
    try {
      return jsonDecode(response.body)['error'] ?? 'Unknown error';
    } catch (_) { return 'Request failed'; }
  }
}