import 'dart:convert';

/// Windows-1252 code points for the byte range 0x80-0x9F -- the only bytes where
/// CP1252 differs from Latin-1. Maps the *mojibake character* back to the raw
/// byte it originally stood for, so we can reverse "UTF-8 bytes decoded as
/// CP1252/Latin-1" corruption.
const Map<int, int> _cp1252Reverse = {
  0x20AC: 0x80, 0x201A: 0x82, 0x0192: 0x83, 0x201E: 0x84, 0x2026: 0x85,
  0x2020: 0x86, 0x2021: 0x87, 0x02C6: 0x88, 0x2030: 0x89, 0x0160: 0x8A,
  0x2039: 0x8B, 0x0152: 0x8C, 0x017D: 0x8E, 0x2018: 0x91, 0x2019: 0x92,
  0x201C: 0x93, 0x201D: 0x94, 0x2022: 0x95, 0x2013: 0x96, 0x2014: 0x97,
  0x02DC: 0x98, 0x2122: 0x99, 0x0161: 0x9A, 0x203A: 0x9B, 0x0153: 0x9C,
  0x017E: 0x9E, 0x0178: 0x9F,
};

// Telltale lead-byte artifacts of UTF-8-decoded-as-CP1252/Latin-1 mojibake.
// Built from code points so the source stays pure-ASCII (no literal glyphs):
//   U+00C2 / U+00C3  lead every 2-byte sequence (accents, degree, copyright...)
//   U+00E2 U+20AC    leads the 3-byte punctuation family (em dash, curly
//                    quotes, ellipsis).
final List<String> _mojibakeMarkers = [
  String.fromCharCode(0x00C2),               // "A-circumflex"
  String.fromCharCode(0x00C3),               // "A-tilde"
  String.fromCharCodes(const [0x00E2, 0x20AC]), // "a-hat euro"
];

bool _hasMojibake(String s) {
  for (final m in _mojibakeMarkers) {
    if (s.contains(m)) return true;
  }
  return false;
}

int _markerCount(String s) {
  var n = 0;
  for (final m in _mojibakeMarkers) {
    var i = 0;
    while ((i = s.indexOf(m, i)) != -1) {
      n++;
      i += m.length;
    }
  }
  return n;
}

/// Repair text that was UTF-8 but got decoded as Windows-1252 / Latin-1,
/// producing mojibake such as an em dash showing as three stray characters, a
/// right single quote, or an accented letter turning into two garbled glyphs.
///
/// Deliberately conservative -- returns the input UNCHANGED unless it clearly
/// contains mojibake AND re-decoding yields valid UTF-8 with fewer mojibake
/// markers. Anything it can't safely reverse (a code point outside CP1252, or
/// bytes that aren't valid UTF-8) is left exactly as-is, so clean text and text
/// that only partially matches are never corrupted.
String repairMojibake(String input) {
  if (input.isEmpty || !_hasMojibake(input)) return input;

  final bytes = <int>[];
  for (final rune in input.runes) {
    if (rune <= 0xFF) {
      bytes.add(rune);
    } else {
      final b = _cp1252Reverse[rune];
      if (b == null) return input; // not a CP1252 char -- can't reverse safely
      bytes.add(b);
    }
  }

  try {
    final decoded = utf8.decode(bytes); // throws on invalid UTF-8
    return _markerCount(decoded) < _markerCount(input) ? decoded : input;
  } catch (_) {
    return input;
  }
}
