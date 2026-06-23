/// Text normalization helpers for accent-insensitive search.
///
/// Folds common Latin diacritics to their base letter and lowercases, so
/// "Béarnaise", "bearnaise", and "bérnaise" all compare equal. Used by
/// recipe search and ingredient suggestions.
library;

const Map<String, String> _accentMap = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a', 'ā': 'a', 'ă': 'a', 'ą': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ė': 'e', 'ę': 'e', 'ě': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i', 'į': 'i', 'ı': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o', 'ø': 'o', 'ō': 'o', 'ő': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', 'ū': 'u', 'ů': 'u', 'ű': 'u',
  'ç': 'c', 'ć': 'c', 'č': 'c', 'ĉ': 'c',
  'ñ': 'n', 'ń': 'n', 'ň': 'n',
  'ý': 'y', 'ÿ': 'y',
  'š': 's', 'ś': 's', 'ş': 's',
  'ž': 'z', 'ź': 'z', 'ż': 'z',
  'đ': 'd', 'ď': 'd', 'ð': 'd',
  'ğ': 'g', 'ł': 'l', 'ř': 'r', 'ť': 't',
  'þ': 'th', 'ß': 'ss', 'æ': 'ae', 'œ': 'oe',
};

/// Lowercases [input] and replaces accented Latin characters with their
/// plain ASCII base. Non-Latin characters pass through unchanged.
String foldAccents(String input) {
  final lower = input.toLowerCase();
  // Fast path: pure ASCII needs no folding.
  var hasNonAscii = false;
  for (var i = 0; i < lower.length; i++) {
    if (lower.codeUnitAt(i) > 127) {
      hasNonAscii = true;
      break;
    }
  }
  if (!hasNonAscii) return lower;

  final sb = StringBuffer();
  // All mapped accents are BMP single code units, so split('') is safe.
  for (final ch in lower.split('')) {
    sb.write(_accentMap[ch] ?? ch);
  }
  return sb.toString();
}
