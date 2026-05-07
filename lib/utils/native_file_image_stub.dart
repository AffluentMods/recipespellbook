/// Web implementation — no local file access.
/// Shows network images or placeholder.
library;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget buildFileImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  int? cacheWidth,
  int? cacheHeight,
  Widget? errorWidget,
}) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return CachedNetworkImage(
      imageUrl: path,
      fit: fit,
      width: width,
      height: height,
      errorWidget: (_, __, ___) =>
          errorWidget ?? const Icon(Icons.broken_image, size: 48),
    );
  }
  // Local file path on web — shouldn't happen, show placeholder
  return errorWidget ?? const Icon(Icons.image_not_supported, size: 48);
}

/// Returns an ImageProvider for a file path (web: NetworkImage or placeholder).
ImageProvider buildFileImageProvider(String path) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return NetworkImage(path);
  }
  // Local paths don't work on web — return a transparent placeholder
  return const AssetImage('assets/images/cookbook_placeholder_normal.png');
}

/// Check if a local file exists — always false on web.
bool localFileExists(String path) => false;
