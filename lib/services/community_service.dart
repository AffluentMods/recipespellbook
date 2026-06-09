import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'auth_service.dart';

// ════════════════════════════════════════════
//  CONSTANTS
// ════════════════════════════════════════════

/// Minimum recipes a cookbook needs before it can be published to community.
/// Single source of truth — if you change this, l10n strings using
/// `communityPublishInfo` / `communityNeedMinRecipes` should be regenerated.
const int kMinPublishRecipes = 5;

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
  final int imageCount;
  final int totalImageBytes;
  final double averageRating;
  final int ratingCount;
  final String? tags;
  /// 'cookbook' (default) or 'recipe' (single-recipe upload). On the
  /// display side the latter skips cookbook framing.
  final String kind;
  final DateTime createdAt;
  final CommunityPublisher publisher;

  const CommunityListItem({
    required this.id, required this.title, this.description, this.imagePath,
    required this.recipeCount, required this.downloadCount,
    this.imageCount = 0, this.totalImageBytes = 0,
    this.averageRating = 0, this.ratingCount = 0,
    this.tags,
    this.kind = 'cookbook',
    required this.createdAt, required this.publisher,
  });

  factory CommunityListItem.fromJson(Map<String, dynamic> json) => CommunityListItem(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    imagePath: json['imagePath'] as String?,
    recipeCount: json['recipeCount'] as int? ?? 0,
    downloadCount: json['downloadCount'] as int? ?? 0,
    imageCount: json['imageCount'] as int? ?? 0,
    totalImageBytes: (json['totalImageBytes'] as num?)?.toInt() ?? 0,
    averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
    ratingCount: json['ratingCount'] as int? ?? 0,
    tags: json['tags'] as String?,
    kind: json['kind'] as String? ?? 'cookbook',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    publisher: CommunityPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
  );

  /// Split comma-separated tags into list.
  List<String> get tagList =>
      tags?.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList() ?? [];

  /// Whether this publication has any images.
  bool get hasImages => imageCount > 0;

  /// True when this is a single-recipe upload.
  bool get isSingleRecipe => kind == 'recipe';
}

class CommunityDetail {
  final String id;
  final String title;
  final String? description;
  final String? imagePath;
  final int recipeCount;
  final int downloadCount;
  final int imageCount;
  final int totalImageBytes;
  final double averageRating;
  final int ratingCount;
  final String? tags;
  /// 'cookbook' or 'recipe'. See [CommunityListItem.kind].
  final String kind;
  final DateTime createdAt;
  final CommunityPublisher publisher;
  final List<CommunityRecipe> recipes;

  const CommunityDetail({
    required this.id, required this.title, this.description, this.imagePath,
    required this.recipeCount, required this.downloadCount,
    this.imageCount = 0, this.totalImageBytes = 0,
    this.averageRating = 0, this.ratingCount = 0,
    this.tags,
    this.kind = 'cookbook',
    required this.createdAt, required this.publisher, required this.recipes,
  });

  factory CommunityDetail.fromJson(Map<String, dynamic> json) => CommunityDetail(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    imagePath: json['imagePath'] as String?,
    recipeCount: json['recipeCount'] as int? ?? 0,
    downloadCount: json['downloadCount'] as int? ?? 0,
    imageCount: json['imageCount'] as int? ?? 0,
    totalImageBytes: (json['totalImageBytes'] as num?)?.toInt() ?? 0,
    averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
    ratingCount: json['ratingCount'] as int? ?? 0,
    tags: json['tags'] as String?,
    kind: json['kind'] as String? ?? 'cookbook',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    publisher: CommunityPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
    recipes: (json['recipes'] as List?)?.map((r) => CommunityRecipe.fromJson(r as Map<String, dynamic>)).toList() ?? [],
  );

  List<String> get tagList =>
      tags?.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList() ?? [];

  bool get hasImages => imageCount > 0;

  /// True when this is a single-recipe upload.
  bool get isSingleRecipe => kind == 'recipe';

  /// Human-readable download size.
  String get downloadSizeLabel {
    if (totalImageBytes <= 0) return 'Text only';
    if (totalImageBytes < 1024 * 1024) {
      return '~${(totalImageBytes / 1024).toStringAsFixed(0)} KB';
    }
    return '~${(totalImageBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class CommunityRecipe {
  /// Server-side recipe id. Needed for "I cooked this" + per-recipe download.
  final String? id;
  final String title;
  final String? description;
  final String? servings;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final String? sourceUrl;
  final String? imagePath;
  final String? categoryId;
  final String? courseId;
  final int? rating;
  final String? notes;
  final String? nutritionJson;
  final List<CommunityIngredient> ingredients;
  final List<CommunityStep> steps;
  final List<String> tags;
  final List<CommunityRecipeLink> recipeLinks;
  /// Distinct-user "I cooked this" count. Surfaced on detail screens.
  final int cookCount;

  const CommunityRecipe({
    this.id,
    required this.title, this.description, this.servings,
    this.prepTimeMinutes, this.cookTimeMinutes, this.sourceUrl,
    this.imagePath, this.categoryId, this.courseId,
    this.rating, this.notes, this.nutritionJson,
    required this.ingredients, required this.steps, required this.tags,
    this.recipeLinks = const [],
    this.cookCount = 0,
  });

  factory CommunityRecipe.fromJson(Map<String, dynamic> json) => CommunityRecipe(
    id: json['id'] as String?,
    title: json['title'] as String? ?? 'Untitled',
    description: json['description'] as String?,
    servings: json['servings'] as String?,
    prepTimeMinutes: json['prepTimeMinutes'] as int?,
    cookTimeMinutes: json['cookTimeMinutes'] as int?,
    sourceUrl: json['sourceUrl'] as String?,
    imagePath: json['imagePath'] as String?,
    categoryId: json['categoryId'] as String?,
    courseId: json['courseId'] as String?,
    rating: json['rating'] as int?,
    notes: json['notes'] as String?,
    nutritionJson: json['nutritionJson'] as String?,
    ingredients: (json['ingredients'] as List?)?.map((i) => CommunityIngredient.fromJson(i as Map<String, dynamic>)).toList() ?? [],
    steps: (json['steps'] as List?)?.map((s) => CommunityStep.fromJson(s as Map<String, dynamic>)).toList() ?? [],
    tags: (json['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
    recipeLinks: (json['recipeLinks'] as List?)?.map((l) => CommunityRecipeLink.fromJson(l as Map<String, dynamic>)).toList() ?? [],
    cookCount: (json['cookCount'] as num?)?.toInt() ?? 0,
  );
}

class CommunityRecipeLink {
  final int ingredientIndex;
  final int linkedRecipeIndex;
  final double scale;

  const CommunityRecipeLink({
    required this.ingredientIndex,
    required this.linkedRecipeIndex,
    this.scale = 1.0,
  });

  factory CommunityRecipeLink.fromJson(Map<String, dynamic> json) => CommunityRecipeLink(
    ingredientIndex: json['ingredientIndex'] as int? ?? 0,
    linkedRecipeIndex: json['linkedRecipeIndex'] as int? ?? 0,
    scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
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
  final String? imagePath;

  const CommunityStep({required this.sortOrder, required this.instruction, this.durationMinutes, this.imagePath});

  factory CommunityStep.fromJson(Map<String, dynamic> json) => CommunityStep(
    sortOrder: json['sortOrder'] as int? ?? 0,
    instruction: json['instruction'] as String? ?? '',
    durationMinutes: json['durationMinutes'] as int?,
    imagePath: json['imagePath'] as String?,
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

/// A single recipe from the community recipe feed.
class CommunityRecipeFeedItem {
  final String? id;
  final String title;
  final String? description;
  final String? imagePath;
  final String? servings;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final String? courseId;
  final int downloadCount;
  final List<String> tags;
  final List<CommunityIngredient> ingredients;
  final List<CommunityStep> steps;
  final CommunityRecipeCookbookInfo cookbook;

  const CommunityRecipeFeedItem({
    this.id, required this.title, this.description, this.imagePath,
    this.servings, this.prepTimeMinutes, this.cookTimeMinutes,
    this.courseId, this.downloadCount = 0, this.tags = const [],
    this.ingredients = const [], this.steps = const [],
    required this.cookbook,
  });

  factory CommunityRecipeFeedItem.fromJson(Map<String, dynamic> json) {
    final cb = json['cookbook'] as Map<String, dynamic>? ?? {};
    final pub = cb['publisher'] as Map<String, dynamic>? ?? {};
    return CommunityRecipeFeedItem(
      id: json['id'] as String?,
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String?,
      imagePath: json['imagePath'] as String?,
      servings: json['servings']?.toString(),
      prepTimeMinutes: json['prepTimeMinutes'] as int?,
      cookTimeMinutes: json['cookTimeMinutes'] as int?,
      downloadCount: json['downloadCount'] as int? ?? 0,
      courseId: json['courseId'] as String?,
      tags: (json['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
      ingredients: (json['ingredients'] as List?)
          ?.map((i) => CommunityIngredient.fromJson(i as Map<String, dynamic>))
          .toList() ?? [],
      steps: (json['steps'] as List?)
          ?.map((s) => CommunityStep.fromJson(s as Map<String, dynamic>))
          .toList() ?? [],
      cookbook: CommunityRecipeCookbookInfo(
        id: cb['id'] as String? ?? '',
        title: cb['title'] as String? ?? '',
        publisherId: pub['id'] as String?,
        publisherName: pub['name'] as String? ?? 'Unknown',
        publisherAvatarUrl: pub['avatarUrl'] as String?,
      ),
    );
  }
}

class CommunityRecipeCookbookInfo {
  final String id;
  final String title;
  final String? publisherId;
  final String publisherName;
  final String? publisherAvatarUrl;

  const CommunityRecipeCookbookInfo({
    required this.id, required this.title,
    this.publisherId,
    required this.publisherName, this.publisherAvatarUrl,
  });
}

class CommunityRecipeFeedResult {
  final List<CommunityRecipeFeedItem> recipes;
  final int page;
  final int total;
  final int totalPages;

  const CommunityRecipeFeedResult({
    required this.recipes, required this.page,
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
  final int imageCount;
  final double averageRating;
  final int ratingCount;
  final String? tags;
  final String kind;
  final String status; // published | pending_review | removed
  final bool isRemoved;
  final DateTime createdAt;

  const MyPublication({
    required this.id, required this.title, this.description, this.imagePath,
    required this.recipeCount, required this.downloadCount,
    this.imageCount = 0, this.averageRating = 0, this.ratingCount = 0,
    this.tags, this.kind = 'cookbook', this.status = 'published',
    required this.isRemoved, required this.createdAt,
  });

  factory MyPublication.fromJson(Map<String, dynamic> json) => MyPublication(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    imagePath: json['imagePath'] as String?,
    recipeCount: json['recipeCount'] as int? ?? 0,
    downloadCount: json['downloadCount'] as int? ?? 0,
    imageCount: json['imageCount'] as int? ?? 0,
    averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
    ratingCount: json['ratingCount'] as int? ?? 0,
    tags: json['tags'] as String?,
    kind: json['kind'] as String? ?? 'cookbook',
    status: json['status'] as String? ?? 'published',
    isRemoved: json['isRemoved'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  bool get isSingleRecipe => kind == 'recipe';
}

/// Server-side state of a "I cooked this" reaction on a community recipe.
class CookedState {
  final bool cooked;
  final int cookCount;
  const CookedState({required this.cooked, required this.cookCount});
}

/// Creator I follow, plus a preview of their latest publication.
class FollowedCreator {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime followedAt;
  final FollowedCreatorPub? latestPublication;

  const FollowedCreator({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.followedAt,
    this.latestPublication,
  });

  factory FollowedCreator.fromJson(Map<String, dynamic> json) => FollowedCreator(
    id: json['id'] as String,
    name: (json['name'] as String?) ?? 'Unknown',
    avatarUrl: json['avatarUrl'] as String?,
    followedAt: DateTime.tryParse(json['followedAt'] as String? ?? '') ?? DateTime.now(),
    latestPublication: json['latestPublication'] is Map<String, dynamic>
        ? FollowedCreatorPub.fromJson(json['latestPublication'] as Map<String, dynamic>)
        : null,
  );
}

/// Lightweight publication preview returned by /me/follows.
class FollowedCreatorPub {
  final String id;
  final String title;
  final String? imagePath;
  final String kind;
  final DateTime createdAt;

  const FollowedCreatorPub({
    required this.id,
    required this.title,
    this.imagePath,
    this.kind = 'cookbook',
    required this.createdAt,
  });

  factory FollowedCreatorPub.fromJson(Map<String, dynamic> json) => FollowedCreatorPub(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    imagePath: json['imagePath'] as String?,
    kind: json['kind'] as String? ?? 'cookbook',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  bool get isSingleRecipe => kind == 'recipe';
}

/// Community tag from the server (legacy curated tags endpoint).
class CommunityTag {
  final String id;
  final String name;
  final String emoji;

  const CommunityTag({required this.id, required this.name, required this.emoji});

  factory CommunityTag.fromJson(Map<String, dynamic> json) => CommunityTag(
    id: json['id'] as String,
    name: json['name'] as String,
    emoji: json['emoji'] as String,
  );
}

/// Dynamic community tag from the trending/search endpoints.
class CommunityTagItem {
  final String tagName;
  final String displayName;
  final String? emoji;
  final bool isCurated;
  final int useCount;

  const CommunityTagItem({
    required this.tagName,
    required this.displayName,
    this.emoji,
    this.isCurated = false,
    this.useCount = 0,
  });

  factory CommunityTagItem.fromJson(Map<String, dynamic> json) => CommunityTagItem(
    tagName: json['tagName'] as String,
    displayName: json['displayName'] as String? ?? json['tagName'] as String,
    emoji: json['emoji'] as String?,
    isCurated: json['isCurated'] as bool? ?? false,
    useCount: json['useCount'] as int? ?? 0,
  );

  String get displayEmoji => emoji ?? '#';
}

/// Upload status returned from the backend.
class UploadStatus {
  final bool canUpload;
  final bool activeUpload;
  final int bytesToday;
  final int dailyLimitBytes;
  final int maxCookbookBytes;

  const UploadStatus({
    required this.canUpload, required this.activeUpload,
    required this.bytesToday, required this.dailyLimitBytes,
    required this.maxCookbookBytes,
  });

  factory UploadStatus.fromJson(Map<String, dynamic> json) => UploadStatus(
    canUpload: json['canUpload'] as bool? ?? true,
    activeUpload: json['activeUpload'] as bool? ?? false,
    bytesToday: (json['bytesToday'] as num?)?.toInt() ?? 0,
    dailyLimitBytes: (json['dailyLimitBytes'] as num?)?.toInt() ?? 2147483647,
    maxCookbookBytes: (json['maxCookbookBytes'] as num?)?.toInt() ?? 524288000,
  );
}

// ════════════════════════════════════════════
//  CREATOR PROFILE
// ════════════════════════════════════════════

class CreatorProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime memberSince;
  final int totalRecipes;
  final int totalDownloads;
  final int totalCookbooks;
  final double averageRating;
  final int followerCount;
  final int followingCount;
  final bool isFollowing;
  final List<CommunityListItem> publications;

  const CreatorProfile({
    required this.id, required this.name, this.avatarUrl,
    required this.memberSince, required this.totalRecipes,
    required this.totalDownloads, required this.totalCookbooks,
    required this.averageRating,
    this.followerCount = 0, this.followingCount = 0, this.isFollowing = false,
    required this.publications,
  });

  factory CreatorProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final stats = json['stats'] as Map<String, dynamic>;
    final pubs = (json['publications'] as List?)
        ?.map((p) => CommunityListItem.fromJson({
          ...p as Map<String, dynamic>,
          'publisher': user,
        }))
        .toList() ?? [];

    return CreatorProfile(
      id: user['id'] as String,
      name: user['name'] as String? ?? 'Anonymous',
      avatarUrl: user['avatarUrl'] as String?,
      memberSince: DateTime.parse(user['memberSince'] as String),
      totalRecipes: stats['totalRecipes'] as int? ?? 0,
      totalDownloads: stats['totalDownloads'] as int? ?? 0,
      totalCookbooks: stats['totalCookbooks'] as int? ?? 0,
      averageRating: (stats['averageRating'] as num?)?.toDouble() ?? 0,
      followerCount: stats['followerCount'] as int? ?? 0,
      followingCount: stats['followingCount'] as int? ?? 0,
      isFollowing: json['isFollowing'] as bool? ?? false,
      publications: pubs,
    );
  }
}

// ════════════════════════════════════════════
//  PUBLISH PROGRESS TRACKING
// ════════════════════════════════════════════

class PublishProgress {
  final String status; // 'preparing' | 'uploading' | 'publishing' | 'done' | 'error'
  final int uploadedImages;
  final int totalImages;
  final int skippedImages;
  final String? errorMessage;
  final String? publicationId;

  const PublishProgress({
    required this.status,
    this.uploadedImages = 0,
    this.totalImages = 0,
    this.skippedImages = 0,
    this.errorMessage,
    this.publicationId,
  });

  PublishProgress copyWith({
    String? status,
    int? uploadedImages,
    int? totalImages,
    int? skippedImages,
    String? errorMessage,
    String? publicationId,
  }) => PublishProgress(
    status: status ?? this.status,
    uploadedImages: uploadedImages ?? this.uploadedImages,
    totalImages: totalImages ?? this.totalImages,
    skippedImages: skippedImages ?? this.skippedImages,
    errorMessage: errorMessage ?? this.errorMessage,
    publicationId: publicationId ?? this.publicationId,
  );
}

/// Global publish progress notifier — listened to by publish screen and my publications.
final publishProgressNotifier = ValueNotifier<PublishProgress?>(null);

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

  /// Build public image URL for community images.
  /// [pubId] — publication ID, [serverPath] — server path like "userId/hash.jpg".
  static String communityImageUrl(String pubId, String serverPath) {
    final base = AuthService.instance.apiBaseUrl;
    return '$base/v1/web/images/community/$pubId/$serverPath';
  }

  // ────────────────────────────────────
  //  Tags
  // ────────────────────────────────────

  List<CommunityTag>? _cachedTags;

  /// Fetch available community tags (legacy curated list).
  Future<List<CommunityTag>> getTags() async {
    if (_cachedTags != null) return _cachedTags!;
    try {
      final r = await _auth.get('/v1/community/tags');
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        _cachedTags = (data['tags'] as List)
            .map((t) => CommunityTag.fromJson(t as Map<String, dynamic>))
            .toList();
        return _cachedTags!;
      }
    } catch (e) {
      debugPrint('[Community] getTags: $e');
    }
    return [];
  }

  /// Fetch trending community tags (dynamic, from CommunityTag table).
  Future<List<CommunityTagItem>> getTrendingTags({int limit = 8, String context = 'all'}) async {
    try {
      final r = await _auth.get('/v1/community/tags/trending?limit=$limit&context=$context');
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return (data['tags'] as List)
            .map((t) => CommunityTagItem.fromJson(t as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[Community] getTrendingTags: $e');
    }
    return [];
  }

  /// Search community tags by name.
  Future<List<CommunityTagItem>> searchTags(String query, {int limit = 10}) async {
    try {
      final r = await _auth.get('/v1/community/tags/search?q=${Uri.encodeComponent(query)}&limit=$limit');
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return (data['tags'] as List)
            .map((t) => CommunityTagItem.fromJson(t as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[Community] searchTags: $e');
    }
    return [];
  }

  // ────────────────────────────────────
  //  Browse
  // ────────────────────────────────────

  /// Fetch the community feed.
  /// [sort]: 'recent', 'popular', 'downloads', 'top_rated'
  Future<CommunityFeedResult?> browse({
    String sort = 'recent',
    int page = 1,
    int limit = 20,
    String? query,
    List<String>? tags,
    bool? hasImages,
    double? minRating,
  }) async {
    try {
      final params = <String, String>{
        'sort': sort,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (query != null && query.isNotEmpty) params['q'] = query;
      if (tags != null && tags.isNotEmpty) params['tags'] = tags.join(',');
      if (hasImages == true) params['hasImages'] = '1';
      if (minRating != null && minRating > 0) params['minRating'] = minRating.toString();

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

  /// Fetch individual recipes from across all community cookbooks.
  /// [sort]: 'recent', 'popular', 'random'
  Future<CommunityRecipeFeedResult?> browseRecipes({
    String sort = 'recent',
    int page = 1,
    int limit = 20,
    String? query,
    List<String>? tags,
    bool? hasImages,
  }) async {
    try {
      final params = <String, String>{
        'sort': sort,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (query != null && query.isNotEmpty) params['q'] = query;
      if (tags != null && tags.isNotEmpty) params['tags'] = tags.join(',');
      if (hasImages == true) params['hasImages'] = '1';

      final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final r = await _auth.get('/v1/community/recipes?$queryString');

      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return CommunityRecipeFeedResult(
          recipes: (data['recipes'] as List)
              .map((p) => CommunityRecipeFeedItem.fromJson(p as Map<String, dynamic>))
              .toList(),
          page: data['page'] as int? ?? 1,
          total: data['total'] as int? ?? 0,
          totalPages: data['totalPages'] as int? ?? 1,
        );
      }
    } catch (e) {
      debugPrint('[Community] browseRecipes: $e');
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
  //  Creator Profile
  // ────────────────────────────────────

  /// Fetch a creator's public profile with their publications.
  Future<CreatorProfile?> getCreatorProfile(String userId) async {
    try {
      final r = await _auth.get('/v1/community/creator/$userId');
      if (r.statusCode == 200) {
        return CreatorProfile.fromJson(jsonDecode(r.body));
      }
    } catch (e) {
      debugPrint('[Community] getCreatorProfile: $e');
    }
    return null;
  }

  // ────────────────────────────────────
  //  Follow / Unfollow
  // ────────────────────────────────────

  /// Follow a creator. Returns updated follow state + follower count.
  Future<({bool following, int followerCount})> followCreator(String userId) async {
    try {
      final r = await _auth.post('/v1/community/creator/$userId/follow', {});
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return (following: data['following'] as bool, followerCount: data['followerCount'] as int);
      }
    } catch (e) {
      debugPrint('[Community] follow: $e');
    }
    return (following: false, followerCount: 0);
  }

  /// Unfollow a creator. Returns updated follow state + follower count.
  Future<({bool following, int followerCount})> unfollowCreator(String userId) async {
    try {
      final r = await _auth.delete('/v1/community/creator/$userId/follow');
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return (following: data['following'] as bool, followerCount: data['followerCount'] as int);
      }
    } catch (e) {
      debugPrint('[Community] unfollow: $e');
    }
    return (following: false, followerCount: 0);
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

  /// Track download of a single community recipe.
  Future<void> trackRecipeDownload(String recipeId) async {
    try {
      await _auth.post('/v1/community/recipes/$recipeId/download', {});
    } catch (e) {
      debugPrint('[Community] trackRecipeDownload: $e');
    }
  }

  // ────────────────────────────────────
  //  "I cooked this" reactions
  // ────────────────────────────────────

  /// Toggle the current user's "cooked" reaction on a community recipe.
  /// Pass [cooked]: true to set, false to clear. Returns the updated
  /// state from the server, or null on failure.
  Future<CookedState?> setRecipeCooked(String recipeId, bool cooked) async {
    try {
      final r = await _auth.post(
        '/v1/community/recipes/$recipeId/cooked',
        {'cooked': cooked},
      );
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body) as Map<String, dynamic>;
        return CookedState(
          cooked: data['cooked'] as bool? ?? cooked,
          cookCount: (data['cookCount'] as num?)?.toInt() ?? 0,
        );
      }
    } catch (e) {
      debugPrint('[Community] setRecipeCooked: $e');
    }
    return null;
  }

  /// Get current "cooked" state for a recipe (and total count). Works
  /// without auth — `cooked` will be false for signed-out callers.
  Future<CookedState?> getRecipeCookedState(String recipeId) async {
    try {
      final r = await _auth.get('/v1/community/recipes/$recipeId/cooked');
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body) as Map<String, dynamic>;
        return CookedState(
          cooked: data['cooked'] as bool? ?? false,
          cookCount: (data['cookCount'] as num?)?.toInt() ?? 0,
        );
      }
    } catch (e) {
      debugPrint('[Community] getRecipeCookedState: $e');
    }
    return null;
  }

  // ────────────────────────────────────
  //  Replace publication recipes (republish-to-update content)
  // ────────────────────────────────────

  /// Atomically replace the recipes of a publication the caller owns.
  /// Keeps download counts, ratings, and follower notifications intact.
  Future<bool> replacePublicationRecipes(
    String publicationId, {
    required List<Map<String, dynamic>> recipes,
    int? imageCount,
    int? totalImageBytes,
    String? imagePath,
  }) async {
    try {
      final r = await _auth.put('/v1/community/$publicationId/recipes', {
        'recipes': recipes,
        if (imageCount != null) 'imageCount': imageCount,
        if (totalImageBytes != null) 'totalImageBytes': totalImageBytes,
        if (imagePath != null) 'imagePath': imagePath,
      });
      return r.statusCode == 200;
    } catch (e) {
      debugPrint('[Community] replacePublicationRecipes: $e');
    }
    return false;
  }

  // ────────────────────────────────────
  //  Publish source mapping (local-only)
  // ────────────────────────────────────
  //
  // Publishing is a snapshot — the server doesn't track which local
  // cookbook / recipe a publication came from. To let "Update published
  // version" push the right content without making the user re-pick, we
  // remember the source locally on the device that published. Stored as
  // a JSON map { publicationId: { "kind": "recipe|cookbook", "sourceId": "..." } }.
  // Falls back gracefully (picker / message) when the mapping is absent,
  // e.g. when republishing from a different device.

  static const _publishSourceKey = 'communityPublishSources';

  static Future<void> recordPublishSource(
    String publicationId, {
    required String kind,
    required String sourceId,
  }) async {
    if (publicationId.isEmpty || sourceId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_publishSourceKey);
      final map = raw != null
          ? (jsonDecode(raw) as Map<String, dynamic>)
          : <String, dynamic>{};
      map[publicationId] = {'kind': kind, 'sourceId': sourceId};
      await prefs.setString(_publishSourceKey, jsonEncode(map));
    } catch (e) {
      debugPrint('[Community] recordPublishSource: $e');
    }
  }

  static Future<({String kind, String sourceId})?> lookupPublishSource(
    String publicationId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_publishSourceKey);
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final entry = map[publicationId];
      if (entry is Map) {
        final kind = entry['kind'] as String?;
        final sourceId = entry['sourceId'] as String?;
        if (kind != null && sourceId != null && sourceId.isNotEmpty) {
          return (kind: kind, sourceId: sourceId);
        }
      }
    } catch (e) {
      debugPrint('[Community] lookupPublishSource: $e');
    }
    return null;
  }

  static Future<void> removePublishSource(String publicationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_publishSourceKey);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map.remove(publicationId) != null) {
        await prefs.setString(_publishSourceKey, jsonEncode(map));
      }
    } catch (e) {
      debugPrint('[Community] removePublishSource: $e');
    }
  }

  // ────────────────────────────────────
  //  Upload Status
  // ────────────────────────────────────

  /// Check if user can upload (rate limits, active uploads).
  Future<UploadStatus?> getUploadStatus() async {
    try {
      final r = await _auth.get('/v1/community/me/upload-status');
      if (r.statusCode == 200) {
        return UploadStatus.fromJson(jsonDecode(r.body));
      }
    } catch (e) {
      debugPrint('[Community] getUploadStatus: $e');
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
  Future<({bool success, String? error, String? publicationId, String? status})> publish({
    required String title,
    String? description,
    String? imagePath,
    required List<Map<String, dynamic>> recipes,
    int imageCount = 0,
    int totalImageBytes = 0,
    String? tags,
    /// 'cookbook' (default) or 'recipe' for single-recipe uploads.
    String kind = 'cookbook',
  }) async {
    try {
      final r = await _auth.post('/v1/community', {
        'title': title,
        if (description != null) 'description': description,
        if (imagePath != null) 'imagePath': imagePath,
        'recipes': recipes,
        'imageCount': imageCount,
        'totalImageBytes': totalImageBytes,
        if (tags != null) 'tags': tags,
        'kind': kind,
      });
      if (r.statusCode == 201) {
        final data = jsonDecode(r.body);
        return (
          success: true,
          error: null,
          publicationId: data['id'] as String?,
          status: data['status'] as String?,
        );
      }
      return (success: false, error: _parseError(r), publicationId: null, status: null);
    } catch (e) {
      return (success: false, error: 'Connection error', publicationId: null, status: null);
    }
  }

  // ────────────────────────────────────
  //  Rate
  // ────────────────────────────────────

  /// Rate a publication (1-5 stars). Returns updated rating info.
  Future<({double averageRating, int ratingCount, int yourRating})?> rate(
    String publicationId,
    int rating,
  ) async {
    try {
      final r = await _auth.post('/v1/community/$publicationId/rate', {
        'rating': rating,
      });
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return (
          averageRating: (data['averageRating'] as num).toDouble(),
          ratingCount: data['ratingCount'] as int,
          yourRating: data['yourRating'] as int,
        );
      }
    } catch (e) {
      debugPrint('[Community] rate: $e');
    }
    return null;
  }

  /// Get my rating for a publication.
  Future<int?> getMyRating(String publicationId) async {
    try {
      final r = await _auth.get('/v1/community/$publicationId/my-rating');
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return data['rating'] as int?;
      }
    } catch (e) {
      debugPrint('[Community] getMyRating: $e');
    }
    return null;
  }

  // ────────────────────────────────────
  //  Update publication
  // ────────────────────────────────────

  /// Update a publication's title, description and/or tags.
  /// Pass empty string for [tags] to clear all tags.
  /// Pass empty string for [description] to clear description.
  Future<bool> updatePublication(String publicationId, {String? title, String? description, String? tags}) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (tags != null) body['tags'] = tags;

      final r = await _auth.patch('/v1/community/$publicationId', body);
      return r.statusCode == 200;
    } catch (e) {
      debugPrint('[Community] updatePublication: $e');
    }
    return false;
  }

  // ────────────────────────────────────
  //  My Publications
  // ────────────────────────────────────

  /// List creators the current user follows. Returns one entry per
  /// followed creator, each with their latest publication preview.
  Future<List<FollowedCreator>> getMyFollows({int limit = 50}) async {
    try {
      final r = await _auth.get('/v1/community/me/follows?limit=$limit');
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return (data['creators'] as List)
            .map((c) => FollowedCreator.fromJson(c as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[Community] getMyFollows: $e');
    }
    return [];
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

  /// Report an account/creator.
  /// Returns a record with success and optional error string.
  Future<({bool success, String? error})> reportAccount(String userId, String reason) async {
    try {
      final r = await _auth.post('/v1/community/creator/$userId/report', {'reason': reason});
      if (r.statusCode == 200) return (success: true, error: null);
      // Parse error
      try {
        final data = jsonDecode(r.body);
        return (success: false, error: data['error'] as String?);
      } catch (_) {}
      return (success: false, error: 'Request failed');
    } catch (_) {
      return (success: false, error: 'Connection error');
    }
  }

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
