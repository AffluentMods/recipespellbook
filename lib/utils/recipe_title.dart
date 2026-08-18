/// Display-only cleaning of a recipe title. Never mutates stored data — call
/// [normalizeTitle] at render time.
class DisplayTitle {
  /// The cleaned title to show.
  final String title;

  /// A leading source extracted from the raw title (e.g. "Olive Garden"), or
  /// null. Screens MAY render this as a small chip; the field exists so it can
  /// be shown and later made filterable.
  final String? source;

  /// A trailing parenthetical extracted from the raw title, sentence-cased,
  /// or null. "Spaghetti alla Carbonara (Authentic Roman Style)" splits into
  /// title "Spaghetti alla Carbonara" + qualifier "Authentic Roman style".
  /// Screens render this as a quiet second line instead of truncating the
  /// title to fit it (community handoff, feed card).
  final String? qualifier;

  const DisplayTitle({required this.title, this.source, this.qualifier});
}

final _leadingBracket = RegExp(r'^\[([^\]]+)\]\s*');
final _wrapping = RegExp(r'^\((.*)\)$');
final _trailingParen = RegExp(r'\s*\(([^()]+)\)\s*$');

/// Capitalize a qualifier's first letter, preserving the rest as authored.
/// Deliberately NOT full sentence-casing: lowering interior words would mangle
/// proper nouns ("Roman" -> "roman"); the qualifier reads as a subtitle
/// through its small muted styling, not through case-forcing.
String _sentenceCase(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

/// Clean [raw] for display:
///  1. Extract a LEADING `[Source]` group (mid/trailing brackets untouched).
///  2. Strip parens ONLY if they wrap the ENTIRE title — "Chicken (Spicy)" and
///     "Soup (Serves 4)" keep their parens unless [extractQualifier] is set.
///  3. With [extractQualifier], a TRAILING parenthetical splits into
///     [DisplayTitle.qualifier] (Community feed/preview render it as a quiet
///     second line). Default false so non-Community callers keep old behavior.
///  4. Normalize em/en dashes to a hyphen (no em dashes in displayed strings).
/// Never truncates — that's a UI concern (maxLines + ellipsis).
DisplayTitle normalizeTitle(String raw, {bool extractQualifier = false}) {
  var s = raw.trim();
  String? source;
  String? qualifier;

  final m = _leadingBracket.firstMatch(s);
  if (m != null) {
    source = m.group(1)?.trim();
    s = s.substring(m.end).trim();
  }

  final w = _wrapping.firstMatch(s);
  if (w != null) s = w.group(1)!.trim();

  if (extractQualifier) {
    final q = _trailingParen.firstMatch(s);
    if (q != null) {
      qualifier = _sentenceCase(q.group(1)!.trim());
      s = s.substring(0, q.start).trim();
      // A title that was ONLY a parenthetical keeps its text as the title.
      if (s.isEmpty) {
        s = qualifier;
        qualifier = null;
      }
    }
  }

  // — = em dash, – = en dash.
  s = s.replaceAll('—', '-').replaceAll('–', '-');

  return DisplayTitle(
    title: s.trim(),
    source: (source?.isEmpty ?? true) ? null : source,
    qualifier: (qualifier?.isEmpty ?? true) ? null : qualifier,
  );
}
