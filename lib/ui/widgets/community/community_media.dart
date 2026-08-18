import 'package:flutter/material.dart';

import '../community_image.dart';

/// The one media component for every image in the Community tab
/// (community handoff, foundations). Declares its aspect ratio, always
/// covers (never letterboxes), and carries the standard scrim when content
/// sits on top of the image.
///
/// Ratios:
///  - [CommunityMedia.hero]   3:2  (recipe feed photo)
///  - [CommunityMedia.cover]  4:3  (cookbook cover card)
///  - [CommunityMedia.banner] 16:9 (detail banner, publication cover)
///  - [CommunityMedia.thumb]  1:1  (row thumbnail, 52px)
class CommunityMedia extends StatelessWidget {
  static const heroRatio = 3 / 2;
  static const coverRatio = 4 / 3;
  static const bannerRatio = 16 / 9;

  /// Standard scrim over media that has text or a control on it: transparent
  /// through the top 30%, then darkens toward the bottom. Fixed colours by
  /// design — it sits on photos, not on themed surfaces.
  static const scrimGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.3, 1.0],
    colors: [Color(0x00000000), Color(0xE00B0B0C)],
  );

  final String publicationId;
  final String? imagePath;
  final double aspectRatio;
  final BorderRadius borderRadius;
  final bool scrim;
  final int? memCacheWidth;
  final int? memCacheHeight;

  /// Extra widgets layered over the media (chips, buttons). Rendered above
  /// the scrim.
  final List<Widget> overlays;

  const CommunityMedia({
    super.key,
    required this.publicationId,
    required this.imagePath,
    required this.aspectRatio,
    this.borderRadius = BorderRadius.zero,
    this.scrim = false,
    this.memCacheWidth,
    this.memCacheHeight,
    this.overlays = const [],
  });

  /// 3:2 recipe feed photo, 16px radius.
  const CommunityMedia.hero({
    super.key,
    required this.publicationId,
    required this.imagePath,
    this.scrim = true,
    this.memCacheWidth,
    this.memCacheHeight,
    this.overlays = const [],
  })  : aspectRatio = heroRatio,
        borderRadius = const BorderRadius.all(Radius.circular(16));

  /// 4:3 cookbook cover, 16px top corners only.
  const CommunityMedia.cover({
    super.key,
    required this.publicationId,
    required this.imagePath,
    this.scrim = true,
    this.memCacheWidth,
    this.memCacheHeight,
    this.overlays = const [],
  })  : aspectRatio = coverRatio,
        borderRadius = const BorderRadius.vertical(top: Radius.circular(16));

  /// 16:9 banner (cookbook detail, publication cover), square corners.
  const CommunityMedia.banner({
    super.key,
    required this.publicationId,
    required this.imagePath,
    this.scrim = true,
    this.memCacheWidth,
    this.memCacheHeight,
    this.overlays = const [],
  })  : aspectRatio = bannerRatio,
        borderRadius = BorderRadius.zero;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CommunityImage(
              publicationId: publicationId,
              imagePath: imagePath,
              fit: BoxFit.cover,
              flatPlaceholder: true,
              memCacheWidth: memCacheWidth,
              memCacheHeight: memCacheHeight,
            ),
            if (scrim)
              const DecoratedBox(
                decoration: BoxDecoration(gradient: scrimGradient),
              ),
            ...overlays,
          ],
        ),
      ),
    );
  }

  /// 1:1 row thumbnail at a fixed [size] (52 by default), 10px radius.
  static Widget thumb({
    required String publicationId,
    required String? imagePath,
    double size = 52,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: CommunityImage(
          publicationId: publicationId,
          imagePath: imagePath,
          fit: BoxFit.cover,
          flatPlaceholder: true,
          memCacheWidth: (size * 3).toInt(),
          memCacheHeight: (size * 3).toInt(),
        ),
      ),
    );
  }
}
