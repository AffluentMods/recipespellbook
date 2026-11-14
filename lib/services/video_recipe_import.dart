import 'dart:async';
import 'dart:convert';

import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../models/imported_recipe.dart';
import 'limited_fetch.dart';
import 'recipe_import_engine.dart';
import 'web_page_decoder.dart';

// Importing a recipe from a cooking video on YouTube, TikTok or Instagram.
//
// A video page is no recipe page. When the recipe is written down at all,
// it is in the text that comes with the video: the description of a YouTube
// video (or, failing that, its captions) and the caption of a TikTok or an
// Instagram post. That text is fetched here and read by the text importer.
// Everything runs in the app; no server of ours is involved.

/// The sites whose videos are read.
enum VideoPlatform {
  youtube('YouTube'),
  tiktok('TikTok'),
  instagram('Instagram');

  const VideoPlatform(this.displayName);

  /// The site's own name, the same in every language.
  final String displayName;
}

/// Where the text of an imported video recipe came from, so the preview can
/// say so and the person knows to check it.
enum VideoTextSource {
  /// The description of a YouTube video, or the caption of a TikTok or an
  /// Instagram post.
  description,

  /// The captions (subtitles) of a YouTube video.
  captions,
}

/// Why a video could not be read.
enum VideoImportFailure {
  /// The text was read, or there was none, and it holds no recipe.
  noRecipe,

  /// The video is private, removed, or otherwise not shown to visitors.
  unavailable,

  /// The site is turning requests away for now.
  rateLimited,

  /// The site could not be reached: no connection, or no answer at all.
  offline,

  /// The site did not answer in time.
  timedOut,

  /// The site answered with a login or consent page instead of the video.
  /// Instagram does this to most visitors without a session.
  blocked,

  /// The site answered with something the app cannot read.
  unreadable,

  /// A short link that turned out to lead to a page that is not a video.
  /// The link is better read by the web importer.
  notAVideo,
}

/// A video import that failed, with the reason and the site it was on.
class VideoImportException implements Exception {
  const VideoImportException(this.failure, this.platform);

  final VideoImportFailure failure;
  final VideoPlatform platform;

  @override
  String toString() => 'VideoImportException(${failure.name}, ${platform.name})';
}

/// Thrown when an import was stopped with [ImportCancellation.cancel].
class VideoImportCancelled implements Exception {
  const VideoImportCancelled();

  @override
  String toString() => 'VideoImportCancelled';
}

/// Stops a running import. The request that is under way is abandoned at
/// once, so the person never waits for a site that is slow to answer.
class ImportCancellation {
  final _cancelled = Completer<void>();

  bool get isCancelled => _cancelled.isCompleted;

  /// Completes when [cancel] is called.
  Future<void> get whenCancelled => _cancelled.future;

  void cancel() {
    if (!_cancelled.isCompleted) _cancelled.complete();
  }
}

/// A link to one video (or post) on one of the [VideoPlatform]s.
class VideoLink {
  const VideoLink._(this.platform, this.id, this.url);

  final VideoPlatform platform;

  /// The video's id: the YouTube video id, the number of a TikTok video or
  /// the short code of an Instagram post. Null for a TikTok short link,
  /// which only says which video it is once it has been followed.
  final String? id;

  /// The link without tracking parameters, in the form that is kept as the
  /// recipe's source.
  final String url;

  /// A TikTok short link (vm.tiktok.com, vt.tiktok.com, tiktok.com/t/).
  bool get isShortLink => id == null;

  static final _youtubeId = RegExp(r'^[A-Za-z0-9_-]{11}$');
  static final _tiktokVideo = RegExp(r'^/@[^/]+/video/(\d{6,25})/?$');
  static final _tiktokShort = RegExp(r'^/(?:t/)?([A-Za-z0-9_-]{4,30})/?$');
  static final _tiktokShortPath = RegExp(r'^/t/([A-Za-z0-9_-]{4,30})/?$');
  static final _instagramPost = RegExp(r'^(?:/[A-Za-z0-9_.]{1,30})?/(reels?|p|tv)/([A-Za-z0-9_-]{5,40})/?$');

  /// The video [input] links to, or null when it is no link to a video this
  /// importer reads. A link without a scheme is read as https.
  static VideoLink? parse(String input) {
    var text = input.trim();
    if (text.isEmpty || text.contains(RegExp(r'\s'))) return null;
    if (!RegExp(r'^https?://', caseSensitive: false).hasMatch(text)) {
      // Another scheme is never a video link.
      if (RegExp(r'^[a-zA-Z][a-zA-Z0-9+.\-]*:').hasMatch(text)) return null;
      text = 'https://$text';
    }
    final uri = Uri.tryParse(text);
    if (uri == null || uri.host.isEmpty) return null;
    final host = uri.host.toLowerCase();
    final path = uri.path;

    bool on(String site) => host == site || host == 'www.$site' || host == 'm.$site';

    // YouTube: youtube.com/watch?v=ID, youtu.be/ID, youtube.com/shorts/ID.
    if (on('youtube.com')) {
      if (path == '/watch' || path == '/watch/') {
        final id = uri.queryParameters['v'];
        if (id != null && _youtubeId.hasMatch(id)) {
          return VideoLink._(VideoPlatform.youtube, id, 'https://www.youtube.com/watch?v=$id');
        }
        return null;
      }
      final shorts = RegExp(r'^/shorts/([A-Za-z0-9_-]{11})/?$').firstMatch(path);
      if (shorts != null) {
        final id = shorts.group(1)!;
        return VideoLink._(VideoPlatform.youtube, id, 'https://www.youtube.com/shorts/$id');
      }
      return null;
    }
    if (host == 'youtu.be' || host == 'www.youtu.be') {
      final id = path.length > 1 ? path.substring(1).replaceFirst(RegExp(r'/$'), '') : '';
      if (_youtubeId.hasMatch(id)) {
        return VideoLink._(VideoPlatform.youtube, id, 'https://www.youtube.com/watch?v=$id');
      }
      return null;
    }

    // TikTok: tiktok.com/@name/video/123, and the short links that lead there.
    if (on('tiktok.com')) {
      final video = _tiktokVideo.firstMatch(path);
      if (video != null) {
        return VideoLink._(VideoPlatform.tiktok, video.group(1), 'https://www.tiktok.com${path.replaceFirst(RegExp(r'/$'), '')}');
      }
      final short = _tiktokShortPath.firstMatch(path);
      if (short != null) {
        return VideoLink._(VideoPlatform.tiktok, null, 'https://www.tiktok.com/t/${short.group(1)}/');
      }
      return null;
    }
    if (host == 'vm.tiktok.com' || host == 'vt.tiktok.com') {
      final short = _tiktokShort.firstMatch(path);
      if (short == null) return null;
      return VideoLink._(VideoPlatform.tiktok, null, 'https://$host/${short.group(1)}/');
    }

    // Instagram: instagram.com/reel/CODE/ and instagram.com/p/CODE/.
    if (on('instagram.com') || host == 'instagr.am' || host == 'www.instagr.am') {
      final post = _instagramPost.firstMatch(path);
      if (post == null) return null;
      final kind = post.group(1) == 'reels' ? 'reel' : post.group(1)!;
      final code = post.group(2)!;
      return VideoLink._(VideoPlatform.instagram, code, 'https://www.instagram.com/$kind/$code/');
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is VideoLink && other.platform == platform && other.id == id && other.url == url;

  @override
  int get hashCode => Object.hash(platform, id, url);

  @override
  String toString() => 'VideoLink(${platform.name}, $id, $url)';
}

/// The text that came with a video, and what is known about the video.
class VideoText {
  const VideoText({
    required this.link,
    this.title,
    this.author,
    this.thumbnailUrl,
    this.description = '',
    this.captions,
  });

  /// The video, after a short link has been followed.
  final VideoLink link;
  final String? title;
  final String? author;
  final String? thumbnailUrl;

  /// The description of a YouTube video, or the caption of a post.
  final String description;

  /// The captions of a YouTube video, a line for each cue, when they were
  /// read.
  final String? captions;

  VideoText withCaptions(String? captions) => VideoText(
        link: link,
        title: title,
        author: author,
        thumbnailUrl: thumbnailUrl,
        description: description,
        captions: captions,
      );
}

/// What reading a video gave: a recipe, or the text it was looked for in.
class VideoImportResult {
  const VideoImportResult({required this.video, this.recipe, this.source});

  final VideoText video;

  /// The recipe, with the video as its source and the video's picture as
  /// its photo. Null when the text holds no recipe the text importer can
  /// read.
  final ImportedRecipe? recipe;

  /// Where [recipe] was read from.
  final VideoTextSource? source;

  /// Whether there is enough text for the AI import to work with.
  bool get hasTextForAi => (video.description.trim().length + (video.captions?.trim().length ?? 0)) >= 40;

  /// The video's text, labelled, for the AI import to read the recipe out
  /// of. The captions are cut short where they would make the prompt too long
  /// to paste.
  String get textForAi {
    const maxCaptions = 20000;
    final buffer = StringBuffer();
    if ((video.title ?? '').trim().isNotEmpty) buffer.writeln('Title: ${video.title!.trim()}');
    if ((video.author ?? '').trim().isNotEmpty) buffer.writeln('By: ${video.author!.trim()}');
    buffer.writeln('Link: ${video.link.url}');
    if (video.description.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(video.link.platform == VideoPlatform.youtube ? 'Description:' : 'Caption:')
        ..writeln(video.description.trim());
    }
    final captions = video.captions?.trim() ?? '';
    if (captions.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Captions (what is said in the video):')
        ..writeln(captions.length > maxCaptions ? captions.substring(0, maxCaptions) : captions);
    }
    return buffer.toString().trim();
  }
}

/// Reads the recipe of a video: fetches the video's text and hands it to the
/// text importer.
///
/// Every request uses the headers and user agent of the web importer
/// ([RecipeImportEngine.pageHeaders]), has a timeout of its own, and is
/// abandoned the moment [cancellation] is cancelled. The whole import gives
/// up after [overallTimeout], so it never hangs.
class VideoRecipeImporter {
  VideoRecipeImporter({
    http.Client? client,
    this.cancellation,
    this.requestTimeout = const Duration(seconds: 15),
    this.overallTimeout = const Duration(seconds: 45),
  }) : _client = client;

  final http.Client? _client;
  final ImportCancellation? cancellation;
  final Duration requestTimeout;
  final Duration overallTimeout;

  /// The most of a page or caption file that is read. A video page is a
  /// megabyte or two.
  static const maxPageBytes = 16 * 1024 * 1024;

  /// Reads the recipe of the video [link] points to. Throws a
  /// [VideoImportException] when the video cannot be read, and
  /// [VideoImportCancelled] when [cancellation] stopped it. A video that was
  /// read but holds no written recipe is no failure: the result then has no
  /// recipe, and its text can go to the AI import.
  Future<VideoImportResult> import(VideoLink link) async {
    if (cancellation?.isCancelled ?? false) throw const VideoImportCancelled();
    final client = _client ?? http.Client();
    try {
      return await _guard(link.platform, _import(link, client), overallTimeout);
    } finally {
      if (_client == null) client.close();
    }
  }

  Future<VideoImportResult> _import(VideoLink link, http.Client client) async {
    switch (link.platform) {
      case VideoPlatform.youtube:
        return _importYoutube(link, client);
      case VideoPlatform.tiktok:
        return _importTiktok(link, client);
      case VideoPlatform.instagram:
        return _importInstagram(link, client);
    }
  }

  // ========== YOUTUBE ==========

  Future<VideoImportResult> _importYoutube(VideoLink link, http.Client client) async {
    const platform = VideoPlatform.youtube;
    final response = await _get(
      client,
      platform,
      Uri.parse('https://www.youtube.com/watch?v=${link.id}'),
      headers: {
        ...RecipeImportEngine.pageHeaders(),
        // Says the cookie question has been answered, so visitors in the EU
        // get the video instead of the consent page.
        'Cookie': 'SOCS=CAI; CONSENT=YES+cb',
      },
    );
    _checkStatus(response.statusCode, platform);
    final (video, player) = _youtubeWatchPage(link, _text(response));

    final fromDescription = _recipe(video.description, video, VideoTextSource.description,
        title: video.title);
    if (fromDescription != null) return fromDescription;

    // The description holds no recipe. Some cooks put the ingredients on
    // screen or read them out, and the captions have those.
    final track = youtubeCaptionTrack(player);
    String? captions;
    if (track != null) {
      try {
        const captionsTimeout = Duration(seconds: 10);
        final answer = await _get(client, platform, track,
            timeout: requestTimeout < captionsTimeout ? requestTimeout : captionsTimeout);
        if (answer.statusCode == 200) captions = youtubeCaptionLines(_text(answer));
      } on VideoImportCancelled {
        rethrow;
      } catch (_) {
        // The captions are only a second chance. Without them the
        // description is all there is.
      }
    }
    final withCaptions = video.withCaptions(captions);
    if (captions != null && captions.isNotEmpty) {
      final fromCaptions = _recipe(captions, withCaptions, VideoTextSource.captions, title: video.title);
      if (fromCaptions != null) return fromCaptions;
    }
    return VideoImportResult(video: withCaptions);
  }

  /// The text and details of a YouTube video, from its watch page [html].
  /// Throws a [VideoImportException] for a page that holds no video: a
  /// consent page, a private or removed video, or YouTube's check for bots.
  static VideoText youtubeVideoText(VideoLink link, String html) => _youtubeWatchPage(link, html).$1;

  /// [youtubeVideoText], with the player data it was read from.
  static (VideoText, Map<String, dynamic>) _youtubeWatchPage(VideoLink link, String html) {
    const platform = VideoPlatform.youtube;
    final player = youtubePlayerResponse(html);
    if (player == null) {
      // The cookie question, or "Before you continue to YouTube".
      if (html.contains('consent.youtube.com') || html.contains('consent.google.com')) {
        throw const VideoImportException(VideoImportFailure.blocked, platform);
      }
      throw const VideoImportException(VideoImportFailure.unreadable, platform);
    }

    final status = _map(player['playabilityStatus']);
    final details = _map(player['videoDetails']);
    if (details == null) {
      final reason = '${status?['reason'] ?? ''} ${status?['status'] ?? ''}'.toLowerCase();
      // "Sign in to confirm you're not a bot": YouTube has seen too many
      // requests from this address.
      if (reason.contains('bot')) {
        throw const VideoImportException(VideoImportFailure.rateLimited, platform);
      }
      throw const VideoImportException(VideoImportFailure.unavailable, platform);
    }

    final thumbnails = [
      ..._list(_map(details['thumbnail'])?['thumbnails']),
      ..._list(_map(_map(_map(player['microformat'])?['playerMicroformatRenderer'])?['thumbnail'])?['thumbnails']),
    ].map(_map).whereType<Map<String, dynamic>>().where((t) => t['url'] is String).toList()
      ..sort((a, b) => _number(b['width']).compareTo(_number(a['width'])));
    final thumbnail = thumbnails.isNotEmpty
        ? (thumbnails.first['url'] as String).split('?').first
        : 'https://i.ytimg.com/vi/${link.id}/hqdefault.jpg';

    final video = VideoText(
      link: link,
      title: _string(details['title']),
      author: _string(details['author']),
      thumbnailUrl: thumbnail,
      description: _string(details['shortDescription']) ?? '',
    );
    return (video, player);
  }

  static final _playerResponseStart = RegExp(r'''ytInitialPlayerResponse['"]?\]?\s*=\s*\{''');

  /// The player data a YouTube watch page carries in a script
  /// (`var ytInitialPlayerResponse = {...};`), or null when it has none.
  static Map<String, dynamic>? youtubePlayerResponse(String html) {
    for (final match in _playerResponseStart.allMatches(html)) {
      final start = match.end - 1;
      final end = _jsonObjectEnd(html, start);
      if (end < 0) continue;
      try {
        final value = jsonDecode(html.substring(start, end + 1));
        if (value is Map<String, dynamic>) return value;
      } on FormatException {
        continue;
      }
    }
    return null;
  }

  /// Where the JSON object that opens at [start] closes, or -1. Braces inside
  /// strings do not count.
  static int _jsonObjectEnd(String text, int start) {
    var depth = 0;
    var inString = false;
    for (var i = start; i < text.length; i++) {
      final unit = text.codeUnitAt(i);
      if (inString) {
        if (unit == 0x5C) {
          i++; // An escaped character.
        } else if (unit == 0x22) {
          inString = false;
        }
      } else if (unit == 0x22) {
        inString = true;
      } else if (unit == 0x7B) {
        depth++;
      } else if (unit == 0x7D) {
        depth--;
        if (depth == 0) return i;
      }
    }
    return -1;
  }

  /// The address of the captions to read for a video, from its [player]
  /// data, asking for them as JSON. Captions written by the channel come
  /// before the ones YouTube generates from the speech. Null when the video
  /// has none, or the address is not YouTube's own.
  static Uri? youtubeCaptionTrack(Map<String, dynamic>? player) {
    final tracks = _list(_map(_map(player?['captions'])?['playerCaptionsTracklistRenderer'])?['captionTracks'])
        .map(_map)
        .whereType<Map<String, dynamic>>()
        .where((track) => track['baseUrl'] is String)
        .toList();
    if (tracks.isEmpty) return null;
    final track = tracks.firstWhere((t) => t['kind'] != 'asr', orElse: () => tracks.first);
    final uri = Uri.tryParse(track['baseUrl'] as String);
    if (uri == null || uri.scheme != 'https') return null;
    final host = uri.host.toLowerCase();
    if (host != 'youtube.com' && !host.endsWith('.youtube.com')) return null;
    return uri.replace(queryParameters: {...uri.queryParametersAll, 'fmt': ['json3']});
  }

  static final _captionMarkup = RegExp(r'<[^>]*>');
  static final _captionCue = RegExp(r'<(text|p)\b[^>]*>([\s\S]*?)</\1>');
  static final _soundCue = RegExp(r'^[\[(][^\])]{1,30}[\])]$|^[♪♫\s]+$');

  /// The lines of a captions file, a line for each cue. Reads the JSON
  /// YouTube gives when asked for it, and the XML it gives otherwise. Cues
  /// that only name a sound ("[Music]") are left out.
  static String youtubeCaptionLines(String body) {
    final cues = <String>[];
    final trimmed = body.trimLeft();
    if (trimmed.startsWith('{')) {
      try {
        final json = jsonDecode(trimmed);
        for (final event in _list(_map(json)?['events'])) {
          final segments = _list(_map(event)?['segs']);
          // The pieces carry the spaces between the words, so they are
          // joined as they are.
          cues.add(segments.map((s) => _map(s)?['utf8']).whereType<String>().join());
        }
      } on FormatException {
        return '';
      }
    } else {
      for (final match in _captionCue.allMatches(body)) {
        cues.add(_decodeEntities(match.group(2)!.replaceAll(_captionMarkup, '')));
      }
    }
    return cues
        .map((cue) => cue.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((cue) => cue.isNotEmpty && !_soundCue.hasMatch(cue))
        .join('\n');
  }

  /// [text] with its character references read. YouTube escapes some cues
  /// twice ("&amp;#39;"), so it is read again while any are left.
  static String _decodeEntities(String text) {
    var decoded = text;
    for (var i = 0; i < 2 && RegExp(r'&(?:#\d+|#x[0-9a-fA-F]+|[a-zA-Z]+);').hasMatch(decoded); i++) {
      decoded = html_parser.parseFragment(decoded).text ?? decoded;
    }
    return decoded;
  }

  // ========== TIKTOK ==========

  Future<VideoImportResult> _importTiktok(VideoLink link, http.Client client) async {
    const platform = VideoPlatform.tiktok;
    var video = link;
    if (link.isShortLink) video = await _followShortLink(client, link);

    final response = await _get(
      client,
      platform,
      Uri.parse('https://www.tiktok.com/oembed?url=${Uri.encodeComponent(video.url)}'),
      headers: {...RecipeImportEngine.pageHeaders(), 'Accept': 'application/json'},
    );
    // TikTok answers 400 or 404 for a video that is private or removed.
    if (response.statusCode == 400) {
      throw const VideoImportException(VideoImportFailure.unavailable, platform);
    }
    _checkStatus(response.statusCode, platform);
    final text = tiktokVideoText(video, _text(response));
    return _recipe(text.description, text, VideoTextSource.description, fallbackTitle: 'TikTok recipe') ??
        VideoImportResult(video: text);
  }

  /// The caption, the account and the cover picture of a TikTok video, from
  /// its oEmbed answer [json].
  static VideoText tiktokVideoText(VideoLink link, String json) {
    const platform = VideoPlatform.tiktok;
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      throw const VideoImportException(VideoImportFailure.unreadable, platform);
    }
    final data = _map(decoded);
    if (data == null) throw const VideoImportException(VideoImportFailure.unreadable, platform);
    // An error can also come back as a normal answer: {"code":400,"message":...}.
    if (data['title'] == null && data['code'] != null) {
      throw const VideoImportException(VideoImportFailure.unavailable, platform);
    }
    return VideoText(
      link: link,
      title: null,
      author: _string(data['author_name']) ?? _string(data['author_unique_id']),
      thumbnailUrl: _string(data['thumbnail_url']),
      description: _string(data['title']) ?? '',
    );
  }

  /// Follows a TikTok short link to the video it stands for. Each hop is a
  /// request of its own, so a short link that loops is given up on.
  Future<VideoLink> _followShortLink(http.Client client, VideoLink link) async {
    const platform = VideoPlatform.tiktok;
    var current = Uri.parse(link.url);
    for (var hop = 0; hop < 6; hop++) {
      final request = http.Request('GET', current)
        ..followRedirects = false
        ..headers.addAll(RecipeImportEngine.pageHeaders(mobile: true));
      final response = await _guard(platform, client.send(request), requestTimeout);
      // Only the address it leads to is wanted, not the page.
      unawaited(response.stream.drain<void>().catchError((_) {}));
      final status = response.statusCode;
      if (status >= 300 && status < 400) {
        final location = response.headers['location'];
        if (location == null) break;
        current = current.resolve(location);
        final found = VideoLink.parse(current.toString());
        if (found != null && found.platform == platform && !found.isShortLink) return found;
        continue;
      }
      _checkStatus(status, platform);
      final found = VideoLink.parse(current.toString());
      if (found != null && found.platform == platform && !found.isShortLink) return found;
      // A page that is not a video, such as a photo post. The web importer
      // can still read it.
      if (current.path.length > 1) throw const VideoImportException(VideoImportFailure.notAVideo, platform);
      break;
    }
    // TikTok sends dead short links to its home page.
    throw const VideoImportException(VideoImportFailure.unavailable, platform);
  }

  // ========== INSTAGRAM ==========

  Future<VideoImportResult> _importInstagram(VideoLink link, http.Client client) async {
    const platform = VideoPlatform.instagram;
    final response = await _get(
      client,
      platform,
      Uri.parse(link.url),
      headers: RecipeImportEngine.pageHeaders(mobile: true),
    );
    if (response.statusCode == 404 || response.statusCode == 410) {
      throw const VideoImportException(VideoImportFailure.unavailable, platform);
    }
    if (response.statusCode == 429) {
      throw const VideoImportException(VideoImportFailure.rateLimited, platform);
    }
    // Anything else that is not the post is Instagram keeping it to people
    // who are logged in.
    if (response.statusCode != 200) {
      throw const VideoImportException(VideoImportFailure.blocked, platform);
    }
    final text = instagramVideoText(link, _text(response));
    return _recipe(text.description, text, VideoTextSource.description, fallbackTitle: 'Instagram recipe') ??
        VideoImportResult(video: text);
  }

  /// The caption of an Instagram post from its page [html], read from the
  /// meta tags. Throws a [VideoImportException] when Instagram answered with
  /// its login page or left the caption out, as it often does.
  static VideoText instagramVideoText(VideoLink link, String html) {
    final post = RecipeImportEngine.instagramPostText(html);
    if (post == null) {
      throw const VideoImportException(VideoImportFailure.blocked, VideoPlatform.instagram);
    }
    return VideoText(
      link: link,
      author: post.author,
      thumbnailUrl: post.image,
      description: post.caption,
    );
  }

  // ========== SHARED ==========

  /// The recipe in [text], as the text importer reads it, with the video as
  /// its source and the video's picture as its photo. Null when there is no
  /// recipe in the text.
  static VideoImportResult? _recipe(
    String text,
    VideoText video,
    VideoTextSource source, {
    String? title,
    String? fallbackTitle,
  }) {
    if (text.trim().isEmpty) return null;
    final recipe = RecipeImportEngine.parseVideoText(text, title: title, fallbackTitle: fallbackTitle);
    if (recipe == null) return null;
    recipe.sourceUrl = video.link.url;
    recipe.imageUrl = video.thumbnailUrl ?? recipe.imageUrl;
    return VideoImportResult(video: video, recipe: recipe, source: source);
  }

  Future<http.Response> _get(
    http.Client client,
    VideoPlatform platform,
    Uri url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    // Read no further than a page can be: a link to the film itself is not
    // downloaded.
    return _guard(
        platform,
        getLimited(
          url,
          headers: headers ?? RecipeImportEngine.pageHeaders(),
          client: client,
          maxBytes: maxPageBytes,
          timeout: timeout ?? requestTimeout,
        ),
        timeout ?? requestTimeout);
  }

  /// Runs [work], turning what can go wrong on the way into a
  /// [VideoImportException], and stopping at once when the import is
  /// cancelled.
  Future<T> _guard<T>(VideoPlatform platform, Future<T> work, Duration timeout) async {
    final cancel = cancellation;
    if (cancel != null && cancel.isCancelled) {
      // Whatever [work] comes to is of no interest now.
      work.ignore();
      throw const VideoImportCancelled();
    }
    try {
      final timed = work.timeout(timeout);
      if (cancel == null) return await timed;
      return await Future.any([
        timed,
        cancel.whenCancelled.then<T>((_) => throw const VideoImportCancelled()),
      ]);
    } on VideoImportCancelled {
      rethrow;
    } on VideoImportException {
      rethrow;
    } on TimeoutException {
      throw VideoImportException(VideoImportFailure.timedOut, platform);
    } on http.ClientException {
      throw VideoImportException(VideoImportFailure.offline, platform);
    } catch (e) {
      // SocketException and HandshakeException are not ClientExceptions on
      // every platform. They all mean the site could not be reached.
      final text = e.toString().toLowerCase();
      if (text.contains('socket') || text.contains('host lookup') || text.contains('network') ||
          text.contains('connection') || text.contains('handshake') || text.contains('xmlhttprequest')) {
        throw VideoImportException(VideoImportFailure.offline, platform);
      }
      rethrow;
    }
  }

  static void _checkStatus(int status, VideoPlatform platform) {
    if (status == 200) return;
    if (status == 429) throw VideoImportException(VideoImportFailure.rateLimited, platform);
    if (status == 404 || status == 410) throw VideoImportException(VideoImportFailure.unavailable, platform);
    if (status == 401 || status == 403 || status == 451) {
      throw VideoImportException(VideoImportFailure.blocked, platform);
    }
    throw VideoImportException(VideoImportFailure.unreadable, platform);
  }

  static String _text(http.Response response) =>
      WebPageDecoder.decode(response.bodyBytes, contentType: response.headers['content-type']).text;

  static Map<String, dynamic>? _map(Object? value) => value is Map<String, dynamic> ? value : null;

  static List<Object?> _list(Object? value) => value is List ? value : const [];

  static String? _string(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  static num _number(Object? value) => value is num ? value : 0;
}
