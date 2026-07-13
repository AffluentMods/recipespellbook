import 'package:flutter/material.dart';
import '../../services/image_service.dart';
import '../../utils/default_recipe_images.dart';
import '../../utils/native_file_image.dart';
import 'placeholder_image.dart';

/// In-memory cache for file existence checks.
/// Avoids repeated synchronous I/O during widget builds.
///
/// Use [FileExistsCache.exists] anywhere you'd normally call
/// `File(path).existsSync()` in a build method.
class FileExistsCache {
  static final _cache = <String, bool>{};

  /// Returns true if the file exists (cached after first check).
  static bool exists(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return true;
    return _cache[path] ??= localFileExists(path);
  }

  /// Invalidate a path (e.g. after saving a new image).
  static void invalidate(String path) => _cache.remove(path);

  /// Clear the entire cache (e.g. on memory pressure).
  static void clear() => _cache.clear();
}

/// A reusable recipe image widget that:
/// - Caches file-existence checks (no repeated sync I/O in build)
/// - Decodes at thumbnail resolution (massive memory + CPU savings)
/// - Falls back to default asset or placeholder
///
/// Use this anywhere you show a recipe/cookbook thumbnail.
class RecipeImage extends StatelessWidget {
  final String? imagePath;
  final String? recipeId; // for default asset lookup
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const RecipeImage({
    super.key,
    this.imagePath,
    this.recipeId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  /// Standard thumbnail (e.g. 90px cards) — decodes tall enough for 3x-DPR
  /// phones so landscape cards aren't upscaled/blurry.
  const RecipeImage.thumbnail({
    super.key,
    this.imagePath,
    this.recipeId,
    this.width,
    this.height = 90,
    this.fit = BoxFit.cover,
  })  : memCacheWidth = null,
        memCacheHeight = 320; // ~3x of a 90–100px card, aspect preserved

  /// Medium image (e.g. list cards ~120px).
  const RecipeImage.medium({
    super.key,
    this.imagePath,
    this.recipeId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  })  : memCacheWidth = null,
        memCacheHeight = 240; // Only set height — Flutter preserves aspect ratio

  /// Large image (e.g. detail header ~300px).
  const RecipeImage.large({
    super.key,
    this.imagePath,
    this.recipeId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  })  : memCacheWidth = null,
        memCacheHeight = 600; // Only set height — Flutter preserves aspect ratio

  @override
  Widget build(BuildContext context) {
    final path = imagePath;

    // Cloud-synced recipes store a server path ("userId/hash.jpg"). Resolve it
    // to a presigned URL and render it — without this the card falls back to the
    // placeholder even though the recipe has an image (the detail hero handles
    // server paths separately, which is why cards and detail used to disagree).
    if (path != null && path.isNotEmpty && ImageService.isServerPath(path)) {
      return _ServerRecipeImage(
        path: path,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        fallback: _fallback(),
      );
    }

    final hasImage = path != null &&
        path.isNotEmpty &&
        FileExistsCache.exists(path);

    if (hasImage) {
      return buildFileImage(
        path,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: memCacheWidth,
        cacheHeight: memCacheHeight,
        errorWidget: _fallback(),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    final defaultAsset = recipeId != null ? defaultRecipeImageAsset(recipeId!) : null;
    if (defaultAsset != null) {
      return Image.asset(
        defaultAsset,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: memCacheWidth,
        cacheHeight: memCacheHeight,
      );
    }
    return RecipePlaceholderImage(
      width: width,
      height: height,
    );
  }

  /// Call when a new image is saved to invalidate the cache for that path.
  static void invalidatePath(String path) => FileExistsCache.invalidate(path);

  /// Clear the file-existence cache entirely.
  static void clearCache() => FileExistsCache.clear();
}

/// Renders a cloud server-path image ("userId/hash.jpg") in cards/thumbnails.
/// Resolves the presigned URL once (memoized across the session so a grid of
/// cards doesn't refetch), then hands the http URL to [buildFileImage] (which
/// routes it through CachedNetworkImage). Shows [fallback] until resolved / on
/// failure, so it never flashes a spinner in a list.
class _ServerRecipeImage extends StatefulWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Widget fallback;

  const _ServerRecipeImage({
    required this.path,
    required this.fit,
    required this.fallback,
    this.width,
    this.height,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  State<_ServerRecipeImage> createState() => _ServerRecipeImageState();
}

class _ServerRecipeImageState extends State<_ServerRecipeImage> {
  static final Map<String, String> _urlCache = {};
  static final Set<String> _resolving = {};
  String? _url;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _ServerRecipeImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _url = null;
      _resolve();
    }
  }

  void _resolve() {
    final cached = _urlCache[widget.path];
    if (cached != null) {
      _url = cached;
      return;
    }
    if (_resolving.contains(widget.path)) return;
    _resolving.add(widget.path);
    ImageService.instance.getImageUrl(widget.path).then((url) {
      _resolving.remove(widget.path);
      if (url != null) _urlCache[widget.path] = url;
      if (mounted && url != null) setState(() => _url = url);
    }).catchError((_) {
      _resolving.remove(widget.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final url = _url;
    if (url == null) return widget.fallback;
    return buildFileImage(
      url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cacheWidth: widget.memCacheWidth,
      cacheHeight: widget.memCacheHeight,
      errorWidget: widget.fallback,
    );
  }
}
