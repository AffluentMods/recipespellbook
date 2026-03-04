import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../services/community_service.dart';

/// Displays a community image from the server with caching, loading shimmer,
/// and error fallback.
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
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _placeholder(context);
    }

    final url = CommunityService.communityImageUrl(publicationId, imagePath!);

    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: (_, __) => _shimmer(context),
      errorWidget: (_, __, ___) => _placeholder(context),
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
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.menu_book_outlined,
        size: 32,
        color: theme.colorScheme.outline.withValues(alpha: 0.5),
      ),
    );
  }
}
