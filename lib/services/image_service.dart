import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
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

/// Why a community photo upload did not go through.
enum CommunityUploadFailure {
  /// Turned down by the server's image moderation (422). Sending the same
  /// photo again gets the same answer, so it is not retried.
  rejected,

  /// Too many uploads for now (429). [CommunityUploadOutcome.retryAfter]
  /// says when the limit resets.
  rateLimited,

  /// Anything else: offline, timed out, server error, file too large.
  failed,

  /// A format no decoder on this device can read (HEIC or AVIF where the
  /// platform has no decoder for it). It is never sent as it is, so it is
  /// not retried either: the publish goes ahead without it.
  unsupported,
}

/// What [ImageService.communityUploadFile] did with one photo.
class CommunityUploadOutcome {
  /// Set when the photo was stored.
  final ImageUploadResult? result;

  /// Set when it was not.
  final CommunityUploadFailure? failure;

  /// For [CommunityUploadFailure.rateLimited]: time until the limit resets.
  final Duration? retryAfter;

  /// Size of the photo as it was sent (after re-encoding), 0 if not stored.
  final int bytesSent;

  const CommunityUploadOutcome.uploaded(ImageUploadResult this.result, {required this.bytesSent})
      : failure = null,
        retryAfter = null;

  const CommunityUploadOutcome.failed(CommunityUploadFailure this.failure, {this.retryAfter})
      : result = null,
        bytesSent = 0;

  bool get ok => result != null;
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

  /// Whether the last [uploadFile] reached the server and was turned down
  /// (a server error, the daily limit, a photo it will not take), or could
  /// never go up at all (too large even compressed, a file that cannot be
  /// read), as opposed to going through, or not getting there at all
  /// (offline, timed out).
  bool get lastUploadRefused => _lastUploadRefused;
  bool _lastUploadRefused = false;

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
    _lastUploadRefused = false;
    if (!_auth.isSignedIn) {
      debugPrint('[ImageService] Not signed in — cannot upload');
      return null;
    }

    try {
      var bytes = await file.readAsBytes();
      const contentType = 'image/jpeg';

      // Always re-encode, so no photo goes up with its camera metadata
      // (GPS location included). Over 1MB it is also compressed. Both paths
      // produce a real JPEG. A format the image package cannot read (HEIC,
      // AVIF) goes through the platform's own decoder; one nothing here can
      // read is never sent as it is.
      var reencoded = bytes.length > 1024 * 1024
          ? await compressImageBytes(bytes)
          : await _decodeResizeJpeg(bytes, maxDimension: maxDimension, quality: 90);
      if (reencoded == null || reencoded.isEmpty) {
        final viaPlatform = await _platformReencodeJpeg(bytes, maxDimension: maxDimension, quality: 90);
        reencoded = viaPlatform != null && viaPlatform.length > 1024 * 1024
            ? await compressImageBytes(viaPlatform) ?? viaPlatform
            : viaPlatform;
      }
      if (reencoded == null || reencoded.isEmpty) {
        // It would fail the same way every time: as good as refused.
        _lastUploadRefused = true;
        debugPrint('[ImageService] Photo format cannot be read here; not uploaded');
        return null;
      }
      debugPrint('[ImageService] Re-encoded ${bytes.length} → ${reencoded.length} bytes');
      bytes = reencoded;

      if (bytes.length > maxFileSize) {
        // It will be just as large next time: as good as refused.
        _lastUploadRefused = true;
        debugPrint('[ImageService] File too large after compression: ${bytes.length} bytes');
        return null;
      }

      final base64Data = base64Encode(bytes);

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

      _lastUploadRefused = true;
      debugPrint('[ImageService] Upload failed: ${response.statusCode}${kDebugMode ? ' ${response.body}' : ''}');
      return null;
    } catch (e) {
      // Offline or timed out: it goes up later. Anything else (a file that
      // cannot be read, an answer that cannot be understood) fails the same
      // way every time, so it counts as refused.
      _lastUploadRefused = !_isConnectionError(e);
      debugPrint('[ImageService] Upload error: $e');
      return null;
    }
  }

  /// Whether [e] means the server could not be reached, rather than that
  /// something is wrong with what was sent.
  static bool _isConnectionError(Object e) {
    if (e is TimeoutException || e is SocketException || e is http.ClientException) return true;
    final msg = e.toString();
    return msg.contains('SocketException') ||
        msg.contains('HandshakeException') ||
        msg.contains('Connection refused') ||
        msg.contains('Connection reset') ||
        msg.contains('Failed host lookup');
  }

  // ════════════════════════════════════════════
  //  GET URL (for displaying images)
  // ════════════════════════════════════════════

  /// Validate + percent-encode a stored server path ("userId/filename") before
  /// it goes into a request URL. A stored value can originate from server /
  /// community / share payloads, so without this a crafted path (`../auth/x`,
  /// `x?admin=1`, `x#…`) could retarget the authenticated request. Rejects
  /// anything that isn't exactly two non-empty segments and encodes each one.
  static String? _safeImagePathForUrl(String imagePath) {
    if (!isServerPath(imagePath) || imagePath.contains('..')) return null;
    final parts = imagePath.split('/');
    if (parts.length != 2 || parts.any((s) => s.isEmpty)) return null;
    return parts.map(Uri.encodeComponent).join('/');
  }

  /// Get a fresh presigned URL for a stored image path.
  ///
  /// [imagePath] is the server path stored in Drift (e.g. "userId/abc123.jpg").
  /// Returns a presigned URL valid for 7 days, or null on failure.
  Future<String?> getImageUrl(String imagePath) async {
    if (!_auth.isSignedIn || imagePath.isEmpty) return null;

    // imagePath format: "userId/filename.ext"
    // API endpoint: GET /v1/images/:userId/:filename
    final safePath = _safeImagePathForUrl(imagePath);
    if (safePath == null) {
      debugPrint('[ImageService] Rejected malformed image path');
      return null;
    }
    try {
      final response = await _auth.get('/v1/images/$safePath');

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

  /// How a run of many photo links waits: between requests, and for the
  /// server's Retry-After. Tests replace it.
  @visibleForTesting
  static Future<void> Function(Duration) wait = Future<void>.delayed;

  /// The most photos one presign-batch request asks for.
  static const _batchSize = 200;

  /// Fresh links for many stored photos at once, by path; a photo without
  /// one (not found, not this account's, not reachable) is missing from the
  /// result. A backup of a library in the cloud needs one for every photo,
  /// and a request per photo ran into the server's limit of 1,000 requests
  /// in 15 minutes: photos were left out and the app was locked out.
  ///
  /// Asks POST /v1/images/presign-batch, 200 photos a request. A server
  /// without it (404) gets one request per photo, the first 100 at once and
  /// then one every 1.2 seconds, which stays under that limit. A 429 waits for its
  /// Retry-After and tries again, up to [maxWait] in all; after that the
  /// rest is left without a link.
  Future<Map<String, String>> getImageUrls(
    List<String> imagePaths, {
    Duration maxWait = const Duration(minutes: 3),
  }) async {
    final urls = <String, String>{};
    if (!_auth.isSignedIn) return urls;
    final paths = <String>[
      for (final path in imagePaths.toSet())
        if (_safeImagePathForUrl(path) != null) path,
    ];
    var waited = Duration.zero;

    /// Sends [request] until it is not a 429; null when waiting would go
    /// past [maxWait] or it could not be sent.
    Future<http.Response?> send(Future<http.Response> Function() request) async {
      while (true) {
        final http.Response response;
        try {
          response = await request();
        } catch (e) {
          debugPrint('[ImageService] Links: $e');
          return null;
        }
        if (response.statusCode != 429) return response;
        final retryAfter = Duration(seconds: int.tryParse(response.headers['retry-after'] ?? '') ?? 30);
        if (waited + retryAfter > maxWait) return null;
        waited += retryAfter;
        await wait(retryAfter);
      }
    }

    var batched = true;
    for (var i = 0; i < paths.length && batched; i += _batchSize) {
      final chunk = paths.sublist(i, (i + _batchSize).clamp(0, paths.length));
      final response = await send(() => _auth.post('/v1/images/presign-batch', {'paths': chunk}));
      if (response == null) return urls;
      if (response.statusCode == 404) {
        batched = false; // an older server
        break;
      }
      if (response.statusCode != 200) {
        debugPrint('[ImageService] presign-batch failed: ${response.statusCode}');
        return urls;
      }
      try {
        final got = (jsonDecode(response.body) as Map)['urls'];
        if (got is Map) {
          got.forEach((path, url) {
            if (path is String && url is String) urls[path] = url;
          });
        }
      } catch (_) {}
    }
    if (batched) return urls;

    for (final (i, path) in paths.indexed) {
      if (i >= 100) await wait(const Duration(milliseconds: 1200));
      final response = await send(() => _auth.get('/v1/images/${_safeImagePathForUrl(path)}'));
      if (response == null) break;
      if (response.statusCode != 200) continue;
      try {
        final url = (jsonDecode(response.body) as Map)['url'];
        if (url is String) urls[path] = url;
      } catch (_) {}
    }
    return urls;
  }

  /// The photo at [url] as bytes (https only, size-capped, must be an
  /// image), or null. Works where there are no files, such as on the web.
  Future<Uint8List?> downloadImageBytes(String url, {Duration timeout = const Duration(seconds: 20)}) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
    final client = http.Client();
    try {
      return await _fetchImageBytes(client, uri).timeout(timeout);
    } catch (e) {
      debugPrint('[ImageService] Download error: $e');
      return null;
    } finally {
      client.close();
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

    final safePath = _safeImagePathForUrl(imagePath);
    if (safePath == null) {
      debugPrint('[ImageService] Rejected malformed image path');
      return false;
    }
    try {
      final response = await _auth.delete('/v1/images/$safePath');
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
  /// The outcome tells a moderation rejection and a rate limit apart from
  /// other failures, and carries the bytes actually sent.
  Future<CommunityUploadOutcome> communityUploadFile(File file) async {
    const failed = CommunityUploadOutcome.failed(CommunityUploadFailure.failed);
    if (!_auth.isSignedIn) {
      debugPrint('[ImageService] Not signed in — cannot upload');
      return failed;
    }

    try {
      var bytes = await file.readAsBytes();
      const contentType = 'image/jpeg';
      final origLen = bytes.length;

      // Always re-encode as JPEG: published photos must not carry camera
      // metadata (GPS location included). Large files get the usual
      // quality; small ones a higher one so they don't get visibly worse.
      // Crucially: NEVER upscale — small images stay at their native
      // resolution. The previous implementation forced every image up
      // to 1920px wide via `instantiateImageCodec(targetWidth:…)`,
      // which is what made uploaded photos look "zoomed and stretched".
      // A photo nothing here can decode (HEIC or AVIF where the platform
      // has no decoder) is never sent as it is: its original bytes keep the
      // camera metadata, and the server only takes JPEG, PNG, WebP and GIF.
      final reencoded = await reencodeJpeg(bytes, quality: bytes.length > 500 * 1024 ? 82 : 90);
      if (reencoded == null || reencoded.isEmpty) {
        debugPrint('[ImageService] Community upload: photo format cannot be read here');
        return const CommunityUploadOutcome.failed(CommunityUploadFailure.unsupported);
      }
      bytes = reencoded;

      if (bytes.length > maxFileSize) {
        // One last pass at lower quality if we're still over the cap.
        final shrunk = await _decodeResizeJpeg(bytes,
            maxDimension: maxDimension, quality: 65);
        if (shrunk != null && shrunk.length < bytes.length) {
          bytes = shrunk;
        }
      }

      if (bytes.length > maxFileSize) {
        debugPrint('[ImageService] File too large: ${bytes.length} bytes');
        return failed;
      }

      final base64Data = base64Encode(bytes);

      debugPrint('[ImageService] Community uploading ${bytes.length} bytes as $contentType (orig $origLen)');

      final response = await _auth.post('/v1/images/community-upload', {
        'base64': base64Data,
        'contentType': contentType,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = ImageUploadResult.fromJson(data);
        debugPrint('[ImageService] Community uploaded: ${result.path}');
        return CommunityUploadOutcome.uploaded(result, bytesSent: bytes.length);
      }

      if (response.statusCode == 422) {
        // Rejected by SafeSearch
        debugPrint('[ImageService] Image rejected by moderation${kDebugMode ? ': ${response.body}' : ''}');
        return const CommunityUploadOutcome.failed(CommunityUploadFailure.rejected);
      }

      if (response.statusCode == 429) {
        final wait = rateLimitReset(response.headers);
        debugPrint('[ImageService] Community upload rate limited, resets in ${wait.inSeconds}s');
        return CommunityUploadOutcome.failed(CommunityUploadFailure.rateLimited, retryAfter: wait);
      }

      debugPrint('[ImageService] Community upload failed: ${response.statusCode}${kDebugMode ? ' ${response.body}' : ''}');
      return failed;
    } catch (e) {
      debugPrint('[ImageService] Community upload error: $e');
      return failed;
    }
  }

  /// Upload a local image file by path for community publishing.
  /// Convenience wrapper around [communityUploadFile].
  Future<CommunityUploadOutcome> communityUploadLocalPath(String localPath) async {
    const failed = CommunityUploadOutcome.failed(CommunityUploadFailure.failed);
    if (!supportsLocalFileSystem) return failed;
    final file = File(localPath);
    if (!await file.exists()) {
      debugPrint('[ImageService] Local file not found: $localPath');
      return failed;
    }
    return communityUploadFile(file);
  }

  /// Time until a 429 resets, from the standard rate limit headers:
  /// `RateLimit-Reset` (seconds, or a Unix time from some servers), then
  /// `Retry-After` (seconds), then the combined `RateLimit: ..., reset=N`.
  /// Falls back to a minute when none is readable; never more than an hour.
  @visibleForTesting
  static Duration rateLimitReset(Map<String, String> headers, {DateTime? now}) {
    String? header(String name) {
      for (final e in headers.entries) {
        if (e.key.toLowerCase() == name) return e.value.trim();
      }
      return null;
    }

    int? seconds = int.tryParse(header('ratelimit-reset') ?? '');
    if (seconds != null && seconds > 1000000000) {
      final nowSeconds = (now ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
      seconds = seconds - nowSeconds;
    }
    seconds ??= int.tryParse(header('retry-after') ?? '');
    if (seconds == null) {
      final combined = RegExp(r'reset=(\d+)').firstMatch(header('ratelimit') ?? '');
      if (combined != null) seconds = int.tryParse(combined.group(1)!);
    }
    return Duration(seconds: (seconds ?? 60).clamp(1, 3600));
  }

  // ════════════════════════════════════════════
  //  COMMUNITY DOWNLOAD (save image to local)
  // ════════════════════════════════════════════

  /// Download an image from a URL, compress if needed, and save locally.
  /// Returns the local file path, or null on failure. A download that takes
  /// longer than [timeout] is abandoned. The file goes into [directory], or
  /// the app's community images folder when that is null.
  Future<String?> downloadAndSaveImage(
    String url,
    String filename, {
    Duration timeout = const Duration(seconds: 20),
    Directory? directory,
  }) async {
    if (!supportsLocalFileSystem) return null;

    // Sanitize the filename: base name only, no separators or traversal, so a
    // caller-influenced value (e.g. a publication id with `../`) can't write
    // outside the community image dir and overwrite app files (the Drift DB,
    // cached config).
    final safeName = p.basename(filename);
    if (safeName != filename ||
        safeName.isEmpty ||
        safeName == '.' ||
        safeName.contains('..') ||
        safeName.contains('/') ||
        safeName.contains('\\')) {
      debugPrint('[ImageService] Rejected unsafe download filename');
      return null;
    }

    // Only fetch over https from a proper host — never cleartext or other
    // schemes (data:, file:).
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      debugPrint('[ImageService] Rejected non-https download URL');
      return null;
    }

    final client = http.Client();
    try {
      // The timeout covers the whole transfer; closing the client in
      // `finally` then drops the connection.
      var bytes = await _fetchImageBytes(client, uri).timeout(timeout);
      if (bytes == null) return null;

      final communityDir =
          directory ?? Directory(p.join((await getApplicationDocumentsDirectory()).path, 'images', 'community'));
      if (!await communityDir.exists()) {
        await communityDir.create(recursive: true);
      }

      // Compress if over 2MB
      if (bytes.length > _targetMaxBytes) {
        final compressed = await compressImageBytes(bytes);
        if (compressed != null) bytes = compressed;
      }

      final localFile = File(p.join(communityDir.path, safeName));
      await localFile.writeAsBytes(bytes);
      debugPrint('[ImageService] Downloaded to: ${localFile.path} (${(bytes.length / 1024).toStringAsFixed(0)}KB)');
      return localFile.path;
    } catch (e) {
      debugPrint('[ImageService] Download error: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// Whether [path] is a photo this device does not hold but can fetch: a
  /// cloud path ("userId/hash.jpg", synced from another device) or an https
  /// address. (Photos are never fetched over plain http.)
  static bool isRemotePhoto(String? path) => path != null && (isServerPath(path) || path.startsWith('https://'));

  /// A file on this device with the photo at [path], a cloud path or an
  /// https address ([isRemotePhoto]), for sending it on (a Community
  /// publish, a share link) through the same upload as a local photo. It is
  /// kept in the temporary folder under a name made from [path], so asking
  /// again returns the same file instead of fetching it again. Null when it
  /// cannot be fetched.
  Future<String?> localCopyOfRemotePhoto(String path) async {
    if (!supportsLocalFileSystem || !isRemotePhoto(path)) return null;
    try {
      final dir = Directory(p.join((await getTemporaryDirectory()).path, 'remote_photos'));
      final name = 'remote_${sha1.convert(utf8.encode(path)).toString().substring(0, 32)}.jpg';
      final file = File(p.join(dir.path, name));
      if (await file.exists() && await file.length() > 0) return file.path;
      final url = isServerPath(path) ? await getImageUrl(path) : path;
      if (url == null) return null;
      if (!await dir.exists()) await dir.create(recursive: true);
      return await downloadAndSaveImage(url, name, directory: dir);
    } catch (e) {
      debugPrint('[ImageService] Remote photo fetch failed: $e');
      return null;
    }
  }

  /// GET [uri] as image bytes, or null for a bad status, an oversize body or
  /// something that is not an image.
  Future<Uint8List?> _fetchImageBytes(http.Client client, Uri uri) async {
    final streamed = await client.send(http.Request('GET', uri));
    if (streamed.statusCode != 200) {
      debugPrint('[ImageService] Download failed: ${streamed.statusCode}');
      return null;
    }
    // Reject oversize responses up-front by Content-Length when present…
    final declared = streamed.contentLength;
    if (declared != null && declared > _maxDownloadBytes) {
      debugPrint('[ImageService] Download too large: $declared bytes');
      return null;
    }

    // …and enforce a hard cap while streaming, so a lying/chunked response
    // can't exhaust memory or disk.
    final chunks = <int>[];
    await for (final chunk in streamed.stream) {
      chunks.addAll(chunk);
      if (chunks.length > _maxDownloadBytes) {
        debugPrint('[ImageService] Download exceeded cap — aborting');
        return null;
      }
    }
    final bytes = Uint8List.fromList(chunks);

    // Confirm the payload is actually a decodable image before persisting it
    // under a .jpg name.
    if (_sniffImageMime(bytes) == null) {
      debugPrint('[ImageService] Downloaded bytes are not a recognised image');
      return null;
    }
    return bytes;
  }

  /// Download several images with [downloadAndSaveImage], at most
  /// [concurrency] at a time, trying each failed one [retries] more times.
  /// The result lines up with [jobs]; null is a photo that could not be
  /// downloaded. [onProgress] gets the number finished so far.
  Future<List<String?>> downloadAndSaveImages(
    List<({String url, String filename})> jobs, {
    int concurrency = 4,
    int retries = 1,
    Duration timeout = const Duration(seconds: 20),
    void Function(int done)? onProgress,
  }) async {
    final results = List<String?>.filled(jobs.length, null);
    var next = 0;
    var done = 0;

    Future<void> worker() async {
      while (next < jobs.length) {
        final i = next++;
        String? path;
        for (var attempt = 0; attempt <= retries && path == null; attempt++) {
          path = await downloadAndSaveImage(jobs[i].url, jobs[i].filename, timeout: timeout);
        }
        results[i] = path;
        onProgress?.call(++done);
      }
    }

    final workers = jobs.isEmpty ? 0 : concurrency.clamp(1, jobs.length);
    await Future.wait([for (var w = 0; w < workers; w++) worker()]);
    return results;
  }

  /// Target max file size for saved images (2MB).
  static const int _targetMaxBytes = 2 * 1024 * 1024;

  /// Hard ceiling on a single image download (20MB) — bounds memory/disk use
  /// regardless of what the remote server claims.
  static const int _maxDownloadBytes = 20 * 1024 * 1024;

  /// Detect a real image type from magic bytes (JPEG/PNG/GIF/WEBP). Returns the
  /// mime, or null if the bytes aren't a recognised image.
  static String? _sniffImageMime(Uint8List b) {
    if (b.length < 12) return null;
    if (b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) return 'image/jpeg';
    if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return 'image/png';
    if (b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x38) return 'image/gif';
    if (b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 &&
        b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) {
      return 'image/webp';
    }
    return null;
  }

  /// Decode → optionally downscale → re-encode as real JPEG. Never
  /// upscales: an image already smaller than [maxDimension] on both
  /// axes is encoded at its native resolution. Returns null on decode
  /// failure (caller should fall back to original bytes).
  ///
  /// This is the core helper used by both upload and download paths.
  /// Runs on a background isolate so it never jank-blocks the UI.
  static Future<Uint8List?> _decodeResizeJpeg(
    Uint8List bytes, {
    required int maxDimension,
    required int quality,
  }) async {
    try {
      return await compute(_decodeResizeJpegSync, _ImgWork(
        bytes: bytes,
        maxDimension: maxDimension,
        quality: quality,
      ));
    } catch (e) {
      debugPrint('[ImageService] decodeResizeJpeg error: $e');
      return null;
    }
  }

  /// [bytes] as a JPEG with no metadata, at most [maxDimension] on its
  /// longer side (never upscaled). Formats the image package cannot read
  /// (HEIC, AVIF) go through the platform's own decoder. Null when nothing
  /// on this device can read them: such a photo must not be sent as it is.
  static Future<Uint8List?> reencodeJpeg(
    Uint8List bytes, {
    int maxDimension = ImageService.maxDimension,
    required int quality,
  }) async {
    final out = await _decodeResizeJpeg(bytes, maxDimension: maxDimension, quality: quality);
    if (out != null && out.isNotEmpty) return out;
    return _platformReencodeJpeg(bytes, maxDimension: maxDimension, quality: quality);
  }

  /// [bytes] decoded by the platform's image decoder (which reads HEIC and
  /// AVIF on the phones and Macs that support them), scaled down to at most
  /// [maxDimension] on its longer side, then encoded as a JPEG. The decoded
  /// pixels carry no metadata. Null when the platform cannot read it either.
  static Future<Uint8List?> _platformReencodeJpeg(
    Uint8List bytes, {
    required int maxDimension,
    required int quality,
  }) async {
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? image;
    try {
      buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      final width = descriptor.width;
      final height = descriptor.height;
      if (width <= 0 || height <= 0) return null;
      final longer = width > height ? width : height;
      final scale = longer > maxDimension ? maxDimension / longer : 1.0;
      codec = await descriptor.instantiateCodec(
        targetWidth: (width * scale).round().clamp(1, width),
        targetHeight: (height * scale).round().clamp(1, height),
      );
      image = (await codec.getNextFrame()).image;
      final rgba = await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
      if (rgba == null) return null;
      return await compute(
        _encodeRgbaJpegSync,
        _RgbaWork(
          rgba: rgba.buffer.asUint8List(rgba.offsetInBytes, rgba.lengthInBytes),
          width: image.width,
          height: image.height,
          quality: quality,
        ),
      );
    } catch (e) {
      debugPrint('[ImageService] Platform decode failed: $e');
      return null;
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
  }

  /// Compress image bytes to fit under ~2MB by re-encoding as JPEG with
  /// progressively lower quality. Used by the download path.
  static Future<Uint8List?> compressImageBytes(
    Uint8List bytes, {
    int targetMaxBytes = _targetMaxBytes,
  }) async {
    // Try normal quality first; step down if still too big.
    for (final quality in const [82, 70, 55, 40]) {
      final out = await _decodeResizeJpeg(bytes,
          maxDimension: maxDimension, quality: quality);
      if (out == null) return null;
      if (out.length <= targetMaxBytes || quality == 40) {
        return out;
      }
    }
    return null;
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

}

// ════════════════════════════════════════════
//  ISOLATE WORKERS (top-level functions)
// ════════════════════════════════════════════

/// Argument container for the isolate-side decode/resize/encode.
class _ImgWork {
  final Uint8List bytes;
  final int maxDimension;
  final int quality;
  const _ImgWork({
    required this.bytes,
    required this.maxDimension,
    required this.quality,
  });
}

/// Decoded pixels (straight RGBA) for [_encodeRgbaJpegSync].
class _RgbaWork {
  final Uint8List rgba;
  final int width;
  final int height;
  final int quality;
  const _RgbaWork({required this.rgba, required this.width, required this.height, required this.quality});
}

/// Pixels the platform decoded, encoded as a JPEG. Top-level for `compute()`.
Uint8List _encodeRgbaJpegSync(_RgbaWork work) {
  final image = img.Image.fromBytes(
    width: work.width,
    height: work.height,
    bytes: work.rgba.buffer,
    bytesOffset: work.rgba.offsetInBytes,
    numChannels: 4,
  );
  return Uint8List.fromList(img.encodeJpg(image, quality: work.quality));
}

/// Synchronous decode → optional downscale → JPEG encode.
/// Top-level so it can run via `compute()`. Never upscales: if both
/// width and height are already at or below maxDimension, the image is
/// encoded at native resolution.
///
/// The output carries no metadata: the camera's rotation is applied to the
/// pixels, then the EXIF block (GPS location, device, timestamps) is dropped.
/// The encoder would otherwise copy it into the new file.
Uint8List? _decodeResizeJpegSync(_ImgWork work) {
  final raw = img.decodeImage(work.bytes);
  if (raw == null) return null;
  final decoded = img.bakeOrientation(raw);

  img.Image working = decoded;
  final w = decoded.width;
  final h = decoded.height;
  final maxDim = work.maxDimension;
  if (w > maxDim || h > maxDim) {
    if (w >= h) {
      working = img.copyResize(
        decoded,
        width: maxDim,
        interpolation: img.Interpolation.cubic,
      );
    } else {
      working = img.copyResize(
        decoded,
        height: maxDim,
        interpolation: img.Interpolation.cubic,
      );
    }
  }

  working.exif.clear();
  return Uint8List.fromList(img.encodeJpg(working, quality: work.quality));
}