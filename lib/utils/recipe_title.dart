/// Display-only cleaning of a recipe title. Never mutates stored data — call
/// [normalizeTitle] at render time.
class DisplayTitle {
  /// The cleaned title to show.
  final String title;

  /// A leading source extracted from the raw title (e.g. "Olive Garden"), or
  /// null. Screens MAY render this as a small chip; the field exists so it can
  /// be shown and later made filterable.
  final String? source;

  const DisplayTitle({required this.title, this.source});
}

final _leadingBracket = RegExp(r'^\[([^\]]+)\]\s*');
final _wrapping = RegExp(r'^\((.*)\)$');

/// Clean [raw] for display:
///  1. Extract a LEADING `[Source]` group (mid/trailing brackets untouched).
///  2. Strip parens ONLY if they wrap the ENTIRE title — "Chicken (Spicy)" and
///     "Soup (Serves 4)" keep their parens.
///  3. Normalize em/en dashes to a hyphen (no em dashes in displayed strings).
/// Never truncates — that's a UI concern (maxLines + ellipsis).
DisplayTitle normalizeTitle(String raw) {
  var s = raw.trim();
  String? source;

  final m = _leadingBracket.firstMatch(s);
  if (m != null) {
    source = m.group(1)?.trim();
    s = s.substring(m.end).trim();
  }

  final w = _wrapping.firstMatch(s);
  if (w != null) s = w.group(1)!.trim();

  // — = em dash, – = en dash.
  s = s.replaceAll('—', '-').replaceAll('–', '-');

  return DisplayTitle(title: s.trim(), source: (source?.isEmpty ?? true) ? null : source);
}
