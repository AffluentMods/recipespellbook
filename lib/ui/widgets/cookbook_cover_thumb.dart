import 'package:flutter/material.dart';

import '../../database/database.dart';
import '../../utils/native_file_image.dart';
import 'placeholder_image.dart';
import 'recipe_image.dart' show FileExistsCache;

/// A cookbook's cover as a small rounded square: its own image when the file
/// is there, otherwise the cookbook placeholder (the same rule as the Home
/// shelf and the sidebar).
class CookbookCoverThumb extends StatelessWidget {
  final Cookbook cookbook;
  final double size;

  const CookbookCoverThumb({super.key, required this.cookbook, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final path = cookbook.imagePath;
    final hasImage =
        path != null && path.isNotEmpty && FileExistsCache.exists(path);
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: SizedBox(
        width: size,
        height: size,
        child: hasImage
            ? buildFileImage(
                path,
                fit: BoxFit.cover,
                cacheHeight: (size * 3).round(),
                errorWidget: const CookbookPlaceholderImage(),
              )
            : const CookbookPlaceholderImage(),
      ),
    );
  }
}
