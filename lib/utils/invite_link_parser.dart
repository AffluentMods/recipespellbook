/// One parser for every invite / share link shape the app understands, so the
/// OS deep-link handler and the manual "paste an invite link" dialogs always
/// agree on what a link means.
///
/// Accepted shapes:
/// ```text
/// https://recipespellbook.app/s/CODE             → share code
/// recipespellbook://s/CODE                       → share code
/// recipespellbook://import?code=CODE             → share code (web "Open in App")
/// https://recipespellbook.app/community/ID       → community publication
/// recipespellbook://community?id=ID              → community publication
/// recipespellbook://community/ID                 → community publication
/// https://recipespellbook.app/family/join/CODE   → family invite
/// recipespellbook://family/join/CODE             → family invite
/// CODE (pasted on its own)                       → bare code (ambiguous)
/// ```
///
/// Anything else — including `recipespellbook://kroger-callback?code=…` and
/// links to other sites — parses to null.
library;

/// What an invite link points at.
enum InviteTargetKind {
  /// A `/s/<code>` share link: a shared recipe, cookbook or shopping list
  /// (either a one-time copy or a live-collaboration invite).
  shareCode,

  /// A published community cookbook / recipe.
  communityId,

  /// A family invite code.
  familyInviteCode,

  /// A code pasted on its own. It could be a share code or a family code, so
  /// the caller has to resolve it (try as a share code first, then as a
  /// family code).
  bareCode,
}

/// The typed result of parsing an invite link.
class InviteTarget {
  final InviteTargetKind kind;
  final String value;

  const InviteTarget(this.kind, this.value);
  const InviteTarget.shareCode(String code) : this(InviteTargetKind.shareCode, code);
  const InviteTarget.communityId(String id) : this(InviteTargetKind.communityId, id);
  const InviteTarget.familyInviteCode(String code) : this(InviteTargetKind.familyInviteCode, code);
  const InviteTarget.bareCode(String code) : this(InviteTargetKind.bareCode, code);

  /// In-app route for this target, or null for a [InviteTargetKind.bareCode]
  /// that still needs resolving.
  String? get route => switch (kind) {
        InviteTargetKind.shareCode => '/s/${Uri.encodeComponent(value)}',
        InviteTargetKind.communityId => '/community/${Uri.encodeComponent(value)}',
        InviteTargetKind.familyInviteCode => '/family/join/${Uri.encodeComponent(value)}',
        InviteTargetKind.bareCode => null,
      };

  @override
  bool operator ==(Object other) =>
      other is InviteTarget && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);

  @override
  String toString() => 'InviteTarget(${kind.name}, $value)';
}

abstract final class InviteLinkParser {
  /// Custom URL scheme registered by the app on every platform.
  static const customScheme = 'recipespellbook';

  /// Website domain that hosts share / invite pages (universal / app links).
  static const webHost = 'recipespellbook.app';

  // Share codes are 6-char base64url; family codes are 8-char hex; community
  // ids are cuids. Accept the union, bounded so junk isn't sent to the server.
  static final _codePattern = RegExp(r'^[A-Za-z0-9_-]{3,64}$');
  static final _familyCodePattern = RegExp(r'^[0-9A-Fa-f]{8}$');

  // Any scheme://… token inside free text.
  static final _urlPattern = RegExp(r'[a-zA-Z][a-zA-Z0-9+.\-]*://\S+');
  // Our domain pasted without a scheme ("recipespellbook.app/s/abc123").
  static final _schemelessPattern =
      RegExp(r'(?:[A-Za-z0-9-]+\.)*recipespellbook\.app/\S+', caseSensitive: false);
  // "Code: ABCD1234" as it appears in the family share message.
  static final _labelledCodePattern = RegExp(
      r'\bcode\s*[:#]?\s*([A-Za-z0-9_-]{3,64})(?![A-Za-z0-9_-])',
      caseSensitive: false);
  // Trailing characters that ride along when a link is pasted from a sentence.
  static final _trailingPunctuation = RegExp('[.,;:!?)\\]}>\'"…”’]+\$');

  // First path segments under /community/ that are app pages, not ids.
  static const _reservedCommunitySegments = {'creator', 'publish', 'my-publications'};

  /// Whether [code] is a plausible invite / share code.
  static bool isValidCode(String code) => _codePattern.hasMatch(code);

  /// Whether [code] has the shape of a family invite code (8 hex chars).
  static bool looksLikeFamilyCode(String code) => _familyCodePattern.hasMatch(code);

  /// Parse a link delivered by the OS (deep link, universal / app link).
  static InviteTarget? parseUri(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme == customScheme) return _parseCustomScheme(uri);
    if (scheme == 'https' || scheme == 'http') {
      if (!_isOurWebHost(uri.host)) return null;
      return _parsePath(uri.pathSegments);
    }
    return null;
  }

  /// Parse whatever the user pasted or typed: a full link (possibly inside a
  /// message), our domain without a scheme, a bare `/s/<code>` path, or a code
  /// on its own. Returns null when nothing usable is found.
  static InviteTarget? parseText(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    // 1. Links with a scheme, anywhere in the text. The first one that is ours
    //    wins; a text that only contains other sites' links is rejected.
    var sawForeignUrl = false;
    for (final m in _urlPattern.allMatches(text)) {
      final uri = Uri.tryParse(_trimPunctuation(m.group(0)!));
      if (uri == null) continue;
      final target = parseUri(uri);
      if (target != null) return target;
      sawForeignUrl = true;
    }

    // 2. Our domain without a scheme.
    for (final m in _schemelessPattern.allMatches(text)) {
      final uri = Uri.tryParse('https://${_trimPunctuation(m.group(0)!)}');
      if (uri == null) continue;
      final target = parseUri(uri);
      if (target != null) return target;
    }
    if (sawForeignUrl) return null;

    // 3. A bare path such as "/s/abc123" or "family/join/ABCD1234".
    if (!text.contains(RegExp(r'\s')) && text.contains('/')) {
      return _parsePath(_trimPunctuation(text).split('/'));
    }

    // 4. A labelled code ("Code: ABCD1234") or a code on its own.
    final labelled = _labelledCodePattern.firstMatch(text);
    if (labelled != null) return InviteTarget.bareCode(labelled.group(1)!);
    final bare = _trimPunctuation(text);
    if (_codePattern.hasMatch(bare)) return InviteTarget.bareCode(bare);
    return null;
  }

  // ── Internals ──────────────────────────────────────────────────────

  static InviteTarget? _parseCustomScheme(Uri uri) {
    final host = uri.host.toLowerCase();
    final segs = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    switch (host) {
      case 'import':
        // Web "Open in App" button. `?code=` is only honoured here — other
        // hosts (e.g. kroger-callback) use `code` for unrelated OAuth codes.
        return _target(InviteTargetKind.shareCode, uri.queryParameters['code']);
      case 's':
        return _target(InviteTargetKind.shareCode, segs.isEmpty ? null : segs.first);
      case 'community':
        return _target(
          InviteTargetKind.communityId,
          uri.queryParameters['id'] ?? (segs.isEmpty ? null : segs.first),
        );
      case 'family':
        if (segs.length >= 2 && segs.first.toLowerCase() == 'join') {
          return _target(InviteTargetKind.familyInviteCode, segs[1]);
        }
        return _target(InviteTargetKind.familyInviteCode, uri.queryParameters['code']);
      case '':
        // Host-less form: recipespellbook:///s/<code>
        return _parsePath(segs);
      default:
        return null;
    }
  }

  static InviteTarget? _parsePath(List<String> rawSegments) {
    var segs = rawSegments.where((s) => s.isNotEmpty).toList();
    // The Flutter web build is served under /app/ — accept links copied from it.
    if (segs.isNotEmpty && segs.first.toLowerCase() == 'app') segs = segs.sublist(1);
    if (segs.length < 2) return null;
    switch (segs.first.toLowerCase()) {
      case 's':
        return _target(InviteTargetKind.shareCode, segs[1]);
      case 'family':
        if (segs.length >= 3 && segs[1].toLowerCase() == 'join') {
          return _target(InviteTargetKind.familyInviteCode, segs[2]);
        }
        return null;
      case 'community':
        if (_reservedCommunitySegments.contains(segs[1].toLowerCase())) return null;
        return _target(InviteTargetKind.communityId, segs[1]);
      default:
        return null;
    }
  }

  static InviteTarget? _target(InviteTargetKind kind, String? raw) {
    if (raw == null) return null;
    final value = _trimPunctuation(raw.trim());
    if (!_codePattern.hasMatch(value)) return null;
    return InviteTarget(kind, value);
  }

  static bool _isOurWebHost(String host) {
    final h = host.toLowerCase();
    return h == webHost || h.endsWith('.$webHost');
  }

  static String _trimPunctuation(String s) => s.replaceFirst(_trailingPunctuation, '');
}
