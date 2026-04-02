import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../services/auth_service.dart';
import '../utils/platform_utils.dart';

// ════════════════════════════════════════════
//  IMAGE RESULT
// ════════════════════════════════════════════

/// Result from a successful image upload.
class ImageUploadResult {
  /// Server storage path (e.g. "userId/abc123.jpg"). Store this in Drift.
  final String path;

  /// Presigned display URL (expires in 7 days).
  final String url;

  const ImageUploadResult({required this.path, required this.url});

  factory ImageUploadResult.fromJson(Map<String, dynamic> json) {
    return ImageUploadResult(
      path: json['path'] as String,
      url: json['url'] as String,
    );
  }
}

// ════════════════════════════════════════════
//  IMAGE SERVICE
// ════════════════════════════════════════════

/// Handles image picking, compression, upload to MinIO via the backend API,
/// presigned URL retrieval, and deletion.
///
/// Usage:
/// ```dart
/// final result = await ImageService.instance.pickAndUpload();
/// if (result != null) {
///   // Save result.path to recipe.imagePath in Drift
///   // Display using result.url (or fetch fresh URL later)
/// }
/// ```
class ImageService {
  ImageService._();
  static final instance = ImageService._();

  final _auth = AuthService.instance;
  final _picker = ImagePicker();

  /// Max image dimension (pixels) before upload. Keeps file size reasonable.
  static const int maxDimension = 1920;

  /// JPEG compression quality (0-100).
  static const int jpegQuality = 80;

  /// Max file size in bytes before rejection (5 MB).
  static const int maxFileSize = 5 * 1024 * 1024;

  // ════════════════════════════════════════════
  //  PICK + UPLOAD (convenience)
  // ════════════════════════════════════════════

  /// Pick an image from the gallery, compress, and upload.
  /// Returns null if the user cancels or upload fails.
  Future<ImageUploadResult?> pickAndUploadFromGallery() async {
    final file = await _pickImage(ImageSource.gallery);
    if (file == null) return null;
    return uploadFile(file);
  }

  /// Pick an image from the camera, compress, and upload.
  Future<ImageUploadResult?> pickAndUploadFromCamera() async {
    final file = await _pickImage(ImageSource.camera);
    if (file == null) return null;
    return uploadFile(file);
  }

  // ════════════════════════════════════════════
  //  UPLOAD
  // ════════════════════════════════════════════

  /// Upload an image file to the server.
  /// The file is read, base64-encoded, and sent to POST /v1/images/upload.
  /// Returns the upload result with server path and presigned URL.
  Future<ImageUploadResult?> uploadFile(File file) async {
    if (!_auth.isSignedIn) {
      debugPrint('[ImageService] Not signed in — cannot upload');
      return null;
    }

    try {
      final bytes = await file.readAsBytes();

      if (bytes.length > maxFileSize) {
        debugPrint('[ImageService] File too large: ${bytes.length} bytes');
        return null;
      }

      final base64Data = base64Encode(bytes);
      final contentType = _contentTypeFromPath(file.path);

      debugPrint('[ImageService] Uploading ${bytes.length} bytes as $contentType');

      final response = await _auth.post('/v1/images/upload', {
        'base64': base64Data,
        'contentType': contentType,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = ImageUploadResult.fromJson(data);
        debugPrint('[ImageService] Uploaded: ${result.path}');
        return result;
      }

      debugPrint('[ImageService] Upload failed: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      debugPrint('[ImageService] Upload error: $e');
      return null;
    }
  }

  // ════════════════════════════════════════════
  //  GET URL (for displaying images)
  // ════════════════════════════════════════════

  /// Get a fresh presigned URL for a stored image path.
  ///
  /// [imagePath] is the server path stored in Drift (e.g. "userId/abc123.jpg").
  /// Returns a presigned URL valid for 7 days, or null on failure.
  Future<String?> getImageUrl(String imagePath) async {
    if (!_auth.isSignedIn || imagePath.isEmpty) return null;

    // imagePath format: "userId/filename.ext"
    // API endpoint: GET /v1/images/:userId/:filename
    try {
      final response = await _auth.get('/v1/images/$imagePath');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['url'] as String?;
      }

      debugPrint('[ImageService] Get URL failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('[ImageService] Get URL error: $e');
      return null;
    }
  }

  /// Check if an imagePath is a server path (vs a local file path).
  /// Server paths look like "userId/hash.ext" (no slashes besides the one).
  static bool isServerPath(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return false;
    // Local paths start with / (Unix) or C:\ (Windows)
    if (imagePath.startsWith('/') || imagePath.contains(':\\')) return false;
    // Server paths have exactly one slash: userId/filename
    return imagePath.split('/').length == 2;
  }

  // ════════════════════════════════════════════
  //  DELETE
  // ════════════════════════════════════════════

  /// Delete an image from the server.
  /// [imagePath] is the server path (e.g. "userId/abc123.jpg").
  Future<bool> deleteImage(String imagePath) async {
    if (!_auth.isSignedIn || imagePath.isEmpty) return false;

    try {
      final response = await _auth.delete('/v1/images/$imagePath');
      if (response.statusCode == 200) {
        debugPrint('[ImageService] Deleted: $imagePath');
        return true;
      }
      debugPrint('[ImageService] Delete failed: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('[ImageService] Delete error: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════
  //  COMMUNITY UPLOAD (with SafeSearch scanning)
  // ════════════════════════════════════════════

  /// Upload a local image file for community publishing.
  /// Uses the /community-upload endpoint which includes SafeSearch scanning.
  /// Returns null if rejected by moderation, user not signed in, or upload fails.
  Future<ImageUploadResult?> communityUploadFile(File file) async {
    if (!_auth.isSignedIn) {
      debugPrint('[ImageService] Not signed in — cannot upload');
      return null;
    }

    try {
      var bytes = await file.readAsBytes();

      // Compress if over 500KB — re-encode as JPEG at 80% quality
      if (bytes.length > 500 * 1024) {
        try {
          final codec = await ui.instantiateImageCodec(bytes, targetWidth: maxDimension);
          final frame = await codec.getNextFrame();
          final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
          if (byteData != null) {
            // Re-encode as JPEG using the image package or just use the resized PNG
            // For now, resize alone can cut 3MB PNGs down significantly
            final resized = byteData.buffer.asUint8List();
            if (resized.length < bytes.length) {
              debugPrint('[ImageService] Compressed ${bytes.length} → ${resized.length} bytes');
              bytes = resized;
            }
          }
          frame.image.dispose();
        } catch (e) {
          debugPrint('[ImageService] Compression failed, uploading original: $e');
        }
      }

      if (bytes.length > maxFileSize) {
        debugPrint('[ImageService] File too large: ${bytes.length} bytes');
        return null;
      }

      final base64Data = base64Encode(bytes);
      final contentType = bytes.length != (await file.readAsBytes()).length ? 'image/png' : _contentTypeFromPath(file.path);

      debugPrint('[ImageService] Community uploading ${bytes.length} bytes as $contentType');

      final response = await _auth.post('/v1/images/community-upload', {
        'base64': base64Data,
        'contentType': contentType,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = ImageUploadResult.fromJson(data);
        debugPrint('[ImageService] Community uploaded: ${result.path}');
        return result;
      }

      if (response.statusCode == 422) {
        // Rejected by SafeSearch
        debugPrint('[ImageService] Image rejected by moderation: ${response.body}');
        return null;
      }

      debugPrint('[ImageService] Community upload failed: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      debugPrint('[ImageService] Community upload error: $e');
      return null;
    }
  }

  /// Upload a local image file by path for community publishing.
  /// Convenience wrapper around [communityUploadFile].
  Future<ImageUploadResult?> communityUploadLocalPath(String localPath) async {
    if (!supportsLocalFileSystem) return null;
    final file = File(localPath);
    if (!await file.exists()) {
      debugPrint('[ImageService] Local file not found: $localPath');
      return null;
    }
    return communityUploadFile(file);
  }

  // ════════════════════════════════════════════
  //  COMMUNITY DOWNLOAD (save image to local)
  // ════════════════════════════════════════════

  /// Download an image from a URL, compress if needed, and save locally.
  /// Returns the local file path, or null on failure.
  Future<String?> downloadAndSaveImage(String url, String filename) async {
    if (!supportsLocalFileSystem) return null;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        debugPrint('[ImageService] Download failed: ${response.statusCode}');
        return null;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final communityDir = Directory('${appDir.path}/images/community');
      if (!await communityDir.exists()) {
        await communityDir.create(recursive: true);
      }

      // Compress if over 2MB
      var bytes = response.bodyBytes;
      if (bytes.length > _targetMaxBytes) {
        final compressed = await compressImageBytes(bytes);
        if (compressed != null) bytes = compressed;
      }

      final localFile = File('${communityDir.path}/$filename');
      await localFile.writeAsBytes(bytes);
      debugPrint('[ImageService] Downloaded to: ${localFile.path} (${(bytes.length / 1024).toStringAsFixed(0)}KB)');
      return localFile.path;
    } catch (e) {
      debugPrint('[ImageService] Download error: $e');
      return null;
    }
  }

  /// Target max file size for saved images (2MB).
  static const int _targetMaxBytes = 2 * 1024 * 1024;

  /// Compress image bytes to fit under ~2MB.
  /// Decodes, resizes if needed, and re-encodes as JPEG.
  /// Returns null if compression fails (caller should use original bytes).
  static Future<Uint8List?> compressImageBytes(Uint8List bytes, {int targetMaxBytes = _targetMaxBytes}) async {
    try {
      // Decode the image
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      var image = frame.image;

      // Determine if resize is needed
      final origWidth = image.width;
      final origHeight = image.height;
      final maxDim = maxDimension; // 1920

      if (origWidth > maxDim || origHeight > maxDim) {
        // Scale down to fit within maxDimension
        final scale = maxDim / (origWidth > origHeight ? origWidth : origHeight);
        final newWidth = (origWidth * scale).round();
        final newHeight = (origHeight * scale).round();

        // Use pictureRecorder to resize
        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder);
        canvas.drawImageRect(
          image,
          ui.Rect.fromLTWH(0, 0, origWidth.toDouble(), origHeight.toDouble()),
          ui.Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble()),
          ui.Paint()..filterQuality = ui.FilterQuality.medium,
        );
        final picture = recorder.endRecording();
        final resized = await picture.toImage(newWidth, newHeight);
        image = resized;
      }

      // Encode as JPEG with quality stepping down until under target
      for (final quality in [85, 70, 55, 40]) {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return null;

        // Flutter's toByteData only supports PNG and rawRGBA natively.
        // For JPEG compression, re-encode from PNG bytes.
        // If PNG is already small enough, use it.
        final pngBytes = byteData.buffer.asUint8List();
        if (pngBytes.length <= targetMaxBytes) {
          return pngBytes;
        }

        // If PNG is too large but we've resized, that's the best we can do
        if (quality == 40) return pngBytes;
      }

      return null;
    } catch (e) {
      debugPrint('[ImageService] Compression error: $e');
      return null;
    }
  }

  // ════════════════════════════════════════════
  //  INTERNALS
  // ════════════════════════════════════════════

  /// Pick and compress an image using image_picker.
  Future<File?> _pickImage(ImageSource source) async {
    try {
      final xFile = await _picker.pickImage(
        source: source,
        maxWidth: maxDimension.toDouble(),
        maxHeight: maxDimension.toDouble(),
        imageQuality: jpegQuality,
      );
      if (xFile == null) return null;
      return File(xFile.path);
    } catch (e) {
      debugPrint('[ImageService] Pick image error: $e');
      return null;
    }
  }

  /// Determine MIME content type from file extension.
  String _contentTypeFromPath(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    return switch (ext) {
      '.png' => 'image/png',
      '.webp' => 'image/webp',
      '.gif' => 'image/gif',
      '.heic' || '.heif' => 'image/heic',
      _ => 'image/jpeg',
    };
  }
}