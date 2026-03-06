/// Cross-platform image display — uses dart:io File on native, network on web.
///
/// Usage:
///   import 'package:recipespellbook/utils/native_file_image.dart';
///   buildFileImage(recipe.imagePath!, fit: BoxFit.cover)
///   localFileExists(path)
export 'native_file_image_stub.dart'
    if (dart.library.io) 'native_file_image_io.dart';
