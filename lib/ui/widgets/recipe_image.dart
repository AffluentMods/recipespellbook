import 'dart:io';
import 'package:flutter/material.dart';
import '../../utils/default_recipe_images.dart';
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
    return _cache[path] ??= File(path).existsSync();
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

  /// Standard thumbnail (e.g. 90px cards) — decodes at 2x for retina.
  const RecipeImage.thumbnail({
    super.key,
    this.imagePath,
    this.recipeId,
    this.width,
    this.height = 90,
    this.fit = BoxFit.cover,
  })  : memCacheWidth = null,
        memCacheHeight = 180; // 2x for retina

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
    final hasImage = imagePath != null &&
        imagePath!.isNotEmpty &&
        FileExistsCache.exists(imagePath!);

    if (hasImage) {
      return Image.file(
        File(imagePath!),
        width: width,
        height: height,
        fit: fit,
        cacheWidth: memCacheWidth,
        cacheHeight: memCacheHeight,
        errorBuilder: (_, __, ___) => _fallback(),
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
