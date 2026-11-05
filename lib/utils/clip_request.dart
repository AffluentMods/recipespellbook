/// A recipe page sent over from the browser extension (the web clipper in
/// `web_clipper/`), which opens the app with
///
/// ```text
/// recipespellbook://clip?url=<page>[&title=<title>][&data=<recipe>][&z=1]
/// ```
///
/// * `url`: the page, http or https only. Required.
/// * `title`: what the page is called, shown while the recipe loads and used
///   when the recipe itself has no name.
/// * `data`: the schema.org Recipe JSON-LD the browser read off the page, as
///   base64url. The browser sends it only when the whole link stays short
///   enough for the system to pass it on.
/// * `z=1`: `data` was raw DEFLATE compressed before it was encoded.
///
/// The link can come from any page in the browser, so everything in it is
/// checked and bounded: a link without a usable page address is no clip at
/// all, and data that cannot be read is dropped (the page is then fetched).
library;

import 'dart:convert';

import 'package:archive/archive.dart';

class ClipRequest {
  /// In-app route of the screen that imports a clip.
  static const path = '/clip';

  /// Longest page address accepted. Browsers on Windows will not hand on a
  /// longer link to an app anyway.
  static const maxUrlLength = 2048;

  /// Longest title kept. A longer one is cut.
  static const maxTitleLength = 200;

  /// Longest `data` accepted, in characters of base64url.
  static const maxDataLength = 16384;

  /// Most bytes of JSON the data may unpack to.
  static const maxJsonBytes = 256 * 1024;

  /// The page the recipe is on.
  final String url;

  /// What the page is called, when the browser said.
  final String? title;

  /// The `data` parameter as it came, when it could be read.
  final String? data;

  /// Whether [data] is compressed.
  final bool compressed;

  /// The JSON-LD the browser read off the page, when it sent some that reads
  /// as JSON.
  final String? jsonLd;

  const ClipRequest._(this.url, this.title, this.data, this.compressed, this.jsonLd);

  /// Reads the query parameters of a clip link (or of its in-app route).
  /// Null when there is no usable http(s) page address.
  static ClipRequest? fromParameters(Map<String, String> params) {
    final url = _pageUrl(params['url']);
    if (url == null) return null;
    final title = _title(params['title']);
    final compressed = params['z'] == '1';
    final data = params['data']?.trim();
    final json = data == null ? null : _decodeData(data, compressed: compressed);
    return json == null
        ? ClipRequest._(url, title, null, false, null)
        : ClipRequest._(url, title, data, compressed, json);
  }

  /// In-app route that imports this clip.
  String get route => Uri(path: path, queryParameters: {
        'url': url,
        if (title != null) 'title': title!,
        if (data != null) 'data': data!,
        if (data != null && compressed) 'z': '1',
      }).toString();

  @override
  bool operator ==(Object other) =>
      other is ClipRequest &&
      other.url == url &&
      other.title == title &&
      other.data == data &&
      other.compressed == compressed;

  @override
  int get hashCode => Object.hash(url, title, data, compressed);

  @override
  String toString() => 'ClipRequest($url, title: $title, data: ${data?.length ?? 0} chars)';

  // ── Internals ────────────────────────────────────────────────────────

  static final _controlOrSpace = RegExp(r'[\s\x00-\x1F\x7F]');
  static final _base64Url = RegExp(r'^[A-Za-z0-9_-]+={0,2}$');

  static String? _pageUrl(String? raw) {
    if (raw == null) return null;
    final text = raw.trim();
    if (text.isEmpty || text.length > maxUrlLength) return null;
    // An address has no spaces or control characters in it; one that does is
    // something else dressed up as a link.
    if (_controlOrSpace.hasMatch(text)) return null;
    final uri = Uri.tryParse(text);
    if (uri == null) return null;
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') return null;
    if (uri.host.isEmpty || uri.userInfo.isNotEmpty) return null;
    if (isLocalOrPrivateHost(uri.host)) return null;
    return uri.toString();
  }

  static String? _title(String? raw) {
    if (raw == null) return null;
    var text = raw.replaceAll(_controlOrSpace, ' ').replaceAll(RegExp(r' {2,}'), ' ').trim();
    if (text.isEmpty) return null;
    if (text.length > maxTitleLength) {
      text = text.substring(0, maxTitleLength).trimRight();
    }
    return text;
  }

  static String? _decodeData(String data, {required bool compressed}) {
    if (data.isEmpty || data.length > maxDataLength || !_base64Url.hasMatch(data)) {
      return null;
    }
    try {
      List<int> bytes = base64Url.decode(base64Url.normalize(data));
      if (compressed) bytes = Inflate(bytes).getBytes();
      if (bytes.isEmpty || bytes.length > maxJsonBytes) return null;
      final text = utf8.decode(bytes);
      final decoded = jsonDecode(text);
      if (decoded is! Map && decoded is! List) return null;
      return text;
    } catch (_) {
      // Not base64url, not DEFLATE, not UTF-8 or not JSON: the page itself
      // is read instead.
      return null;
    }
  }
}

/// Whether [host] names this device or a private network: such an address
/// is never fetched for a link that came from outside the app.
bool isLocalOrPrivateHost(String host) {
  final h = host.toLowerCase();
  if (h == 'localhost' || h.endsWith('.localhost')) return true;
  if (h.endsWith('.local') || h.endsWith('.internal') || h.endsWith('.lan')) return true;
  // IPv6 literals (the loopback among them) are not recipe sites.
  if (h.contains(':') || h.startsWith('[')) return true;
  final m = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$').firstMatch(h);
  if (m != null) {
    final a = int.parse(m.group(1)!);
    final b = int.parse(m.group(2)!);
    if (a == 0 || a == 127 || a == 10) return true; // this host, loopback, private
    if (a == 192 && b == 168) return true; // private
    if (a == 169 && b == 254) return true; // link-local
    if (a == 172 && b >= 16 && b <= 31) return true; // private
    if (a == 100 && b >= 64 && b <= 127) return true; // carrier-grade NAT
  }
  // A host name without a dot is a machine on the local network.
  return !h.contains('.');
}
