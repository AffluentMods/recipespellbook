import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../services/community_service.dart';

/// Displays a community image from the server with caching, loading shimmer,
/// and error fallback with gradient placeholder.
///
/// Usage:
/// ```dart
/// CommunityImage(
///   publicationId: 'abc123',
///   imagePath: 'userId/hash.jpg',
///   width: 200,
///   height: 150,
///   fit: BoxFit.cover,
/// )
/// ```
class CommunityImage extends StatelessWidget {
  final String publicationId;
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final int? memCacheWidth;
  final int? memCacheHeight;

  /// Community redesign placeholder: a flat surface fill with a stroked glyph
  /// (one treatment everywhere) instead of the illustration/gradient. Never
  /// derives a colour from the title.
  final bool flatPlaceholder;

  const CommunityImage({
    super.key,
    required this.publicationId,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.memCacheWidth,
    this.memCacheHeight,
    this.flatPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _placeholder(context);
    }

    final url = CommunityService.communityImageUrl(publicationId, imagePath!);

    Widget image = Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        alignment: Alignment.center,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        filterQuality: FilterQuality.medium, // smoother than the default .low
        placeholder: (_, __) => _shimmer(context),
        errorWidget: (_, __, ___) => _placeholder(context),
      ),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  Widget _shimmer(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    if (flatPlaceholder) {
      final theme = Theme.of(context);
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: borderRadius,
        ),
        child: Center(
          child: Icon(
            Icons.restaurant_outlined,
            size: 34,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ),
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.asset(
          'assets/images/recipe_placeholder_normal.png',
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _gradientFallback(context),
        ),
      ),
    );
  }

  Widget _gradientFallback(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: (height != null && height! < 80) ? 24 : 40,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
