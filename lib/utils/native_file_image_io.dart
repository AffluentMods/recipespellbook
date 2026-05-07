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

/// Check if a local file exists on disk.
bool localFileExists(String path) {
  try {
    return File(path).existsSync();
  } catch (_) {
    return false;
  }
}
