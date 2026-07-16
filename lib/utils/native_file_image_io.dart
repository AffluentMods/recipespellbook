/// Native (mobile/desktop) implementation — uses dart:io File.
library;
import 'dart:io';
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
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      filterQuality: FilterQuality.medium, // smoother down/upscaling than the default .low
      errorWidget: (_, __, ___) =>
          errorWidget ?? const Icon(Icons.broken_image, size: 48),
    );
  }
  return Image.file(
    File(path),
    fit: fit,
    width: width,
    height: height,
    cacheWidth: cacheWidth,
    cacheHeight: cacheHeight,
    filterQuality: FilterQuality.medium, // smoother resampling than the default .low
    errorBuilder: (_, __, ___) =>
        errorWidget ?? const Icon(Icons.broken_image, size: 48),
  );
}

/// Returns an ImageProvider for a file path (native: FileImage, web: NetworkImage).
ImageProvider buildFileImageProvider(String path) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return NetworkImage(path);
  }
  return FileImage(File(path));
}

/// Check if a local file exists on disk AND has content. A 0-byte file is
/// treated as missing so a corrupted/truncated image falls back to the
/// placeholder tile instead of rendering a broken-image icon.
bool localFileExists(String path) {
  try {
    final f = File(path);
    return f.existsSync() && f.lengthSync() > 0;
  } catch (_) {
    return false;
  }
}
