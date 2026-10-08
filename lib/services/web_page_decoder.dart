import 'dart:convert';
import 'dart:typed_data';

/// The text of a fetched web page.
class DecodedPage {
  final String text;

  /// The charset the page declares when it is one this app has no table for
  /// and whose text is not Latin letters (Shift_JIS, GBK, Greek and the like),
  /// and the bytes are not UTF-8 either. Only the ASCII in [text] is real
  /// then: every other byte is U+FFFD, the mark for a character that could
  /// not be read.
  final String? unreadableCharset;

  const DecodedPage(this.text, {this.unreadableCharset});
}

/// Turns the bytes of a web page into text.
///
/// Dart ships decoders for UTF-8 and Latin-1 only, and `http` falls back to
/// Latin-1 whenever a server names no charset, which most recipe sites do.
/// That turns UTF-8 accents into "Ã©" and leaves older pages written in other
/// alphabets unreadable. So the bytes are read here instead: as UTF-8 when
/// they are UTF-8, otherwise in the charset the page declares, using the
/// single-byte tables below.
class WebPageDecoder {
  WebPageDecoder._();

  static DecodedPage decode(List<int> bytes, {String? contentType}) {
    try {
      return DecodedPage(utf8.decode(bytes));
    } on FormatException {
      // Not clean UTF-8. Either a UTF-8 page with a few bad bytes, or a page
      // in an older charset.
    }

    // One stray byte (a curly quote pasted from Word into a comment) must not
    // cost the whole page its accents, so a page that is mostly UTF-8 stays
    // UTF-8 and only the bytes that do not fit are read on their own.
    final (mixed, mostlyUtf8) = _decodeMostlyUtf8(bytes);
    if (mostlyUtf8) return DecodedPage(mixed);

    // The bytes are not UTF-8, so a label that says they are is wrong (a
    // server default, usually). The first label that names another charset
    // is believed: the server's, then the page's own.
    for (final label in _declaredCharsets(bytes, contentType)) {
      final name = _aliases[label];
      if (name == 'utf-8') continue;
      if (name != null) return DecodedPage(_decodeSingleByte(bytes, _tables[name]!));
      // Only the ASCII parts can be read. The rest is marked, so the caller
      // can tell which of the text to trust.
      if (_otherAlphabet.hasMatch(label)) {
        return DecodedPage(_decodeSingleByte(bytes, _unreadable), unreadableCharset: label);
      }
    }

    // No label, or one that means nothing here: read it the way browsers do,
    // as windows-1252. That is also the closest table for the Latin charsets
    // without one of their own (Turkish, Baltic), whose pages come out with a
    // few letters wrong rather than not at all.
    return DecodedPage(_decodeSingleByte(bytes, _tables['windows-1252']!));
  }

  /// The charsets the page is said to be in, lower case: by the Content-Type
  /// header, then by the page itself in a `<meta>` tag or an XML declaration.
  static List<String> _declaredCharsets(List<int> bytes, String? contentType) {
    final fromHeader = _charsetParam.firstMatch(contentType ?? '')?.group(1);

    // The declaration is plain ASCII near the top of the page, so the first
    // few thousand bytes can be read before the charset is known.
    final end = bytes.length < 4096 ? bytes.length : 4096;
    final head = latin1.decode(bytes.sublist(0, end), allowInvalid: true);
    final fromPage = _metaCharset.firstMatch(head)?.group(1) ??
        _xmlEncoding.firstMatch(head)?.group(1);
    return [
      if (fromHeader != null) fromHeader.toLowerCase(),
      if (fromPage != null) fromPage.toLowerCase(),
    ];
  }

  /// Charsets with no table here whose text is not Latin letters: the East
  /// Asian multi-byte ones, Greek, Hebrew, Arabic, Thai and the other
  /// Cyrillic ones. Read as windows-1252 nothing of them is left to read.
  static final _otherAlphabet = RegExp(
      r'^(?:shift[_-]jis|sjis|x-sjis|ms_kanji|windows-31j|euc-|x-euc-|iso-2022-|'
      r'gb|x-gbk|hz-gb|big5|cn-big5|ks_c_5601|ksc_?5601|korean|windows-949|'
      r'utf-16|utf-32|(?:windows-|cp)125[356]|iso-8859-(?:5|6|7|8|11)\b|'
      r'greek|hebrew|arabic|cyrillic|windows-874|tis-620|koi8|ibm866|cp866|'
      r'x-mac-cyrillic)');

  static final _charsetParam =
      RegExp(r'''charset\s*=\s*["']?([^\s;"']+)''', caseSensitive: false);
  static final _metaCharset = RegExp(
      r'''<meta[^>]{0,200}?charset\s*=\s*["']?\s*([A-Za-z0-9_:.\-]+)''',
      caseSensitive: false);
  static final _xmlEncoding = RegExp(
      r'''^\s*<\?xml[^>]{0,100}?encoding\s*=\s*["']([A-Za-z0-9_:.\-]+)''',
      caseSensitive: false);

  /// Reads [bytes] as UTF-8, and each byte that is not valid UTF-8 as the
  /// windows-1252 character it stands for in an older page: stray bytes are
  /// nearly always text pasted or included from one.
  ///
  /// Also says whether the page is UTF-8 at heart, which it is when more of
  /// its non-ASCII characters were valid UTF-8 than not. Text in an older
  /// charset is the other way round: nearly every accented letter is invalid.
  static (String, bool) _decodeMostlyUtf8(List<int> bytes) {
    // The smallest code point each sequence length may encode. A smaller one
    // was written longer than it needs to be, which UTF-8 forbids.
    const smallest = [0, 0, 0x80, 0x800, 0x10000];
    final western = _tables['windows-1252']!;
    // No character takes more UTF-16 units than it took bytes.
    final units = Uint16List(bytes.length);
    var written = 0;
    var good = 0;
    var bad = 0;
    // A byte order mark in front is not part of the text.
    final hasMark = bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF;
    var i = hasMark ? 3 : 0;
    while (i < bytes.length) {
      final lead = bytes[i] & 0xFF;
      if (lead < 0x80) {
        units[written++] = lead;
        i++;
        continue;
      }

      final length = lead >= 0xF0 ? 4 : (lead >= 0xE0 ? 3 : (lead >= 0xC2 ? 2 : 0));
      var codePoint = -1;
      if (length > 0 && lead <= 0xF4 && i + length <= bytes.length) {
        var value = lead & (0xFF >> (length + 1));
        var complete = true;
        for (var k = 1; k < length; k++) {
          final next = bytes[i + k] & 0xFF;
          if (next & 0xC0 != 0x80) {
            complete = false;
            break;
          }
          value = (value << 6) | (next & 0x3F);
        }
        final isSurrogate = value >= 0xD800 && value <= 0xDFFF;
        if (complete && value >= smallest[length] && value <= 0x10FFFF && !isSurrogate) {
          codePoint = value;
        }
      }

      if (codePoint < 0) {
        units[written++] = western.codeUnitAt(lead - 0x80);
        bad++;
        i++;
      } else if (codePoint < 0x10000) {
        units[written++] = codePoint;
        good++;
        i += length;
      } else {
        // Past the first 65536 characters it takes a pair of units.
        final offset = codePoint - 0x10000;
        units[written++] = 0xD800 + (offset >> 10);
        units[written++] = 0xDC00 + (offset & 0x3FF);
        good++;
        i += length;
      }
    }
    return (String.fromCharCodes(units, 0, written), good > bad);
  }

  static String _decodeSingleByte(List<int> bytes, String high) {
    final units = Uint16List(bytes.length);
    for (var i = 0; i < bytes.length; i++) {
      final b = bytes[i] & 0xFF;
      units[i] = b < 0x80 ? b : high.codeUnitAt(b - 0x80);
    }
    return String.fromCharCodes(units);
  }

  /// The names pages use for the charsets we can read.
  static const _aliases = {
    'utf-8': 'utf-8',
    'utf8': 'utf-8',
    'unicode-1-1-utf-8': 'utf-8',
    // Browsers read every Latin-1 label as windows-1252, which only adds
    // characters (curly quotes, dashes, the euro sign) where Latin-1 has
    // control codes.
    'windows-1252': 'windows-1252',
    'cp1252': 'windows-1252',
    'x-cp1252': 'windows-1252',
    'iso-8859-1': 'windows-1252',
    'iso8859-1': 'windows-1252',
    'iso_8859-1': 'windows-1252',
    'latin1': 'windows-1252',
    'l1': 'windows-1252',
    'ascii': 'windows-1252',
    'us-ascii': 'windows-1252',
    'iso-8859-15': 'iso-8859-15',
    'iso8859-15': 'iso-8859-15',
    'iso_8859-15': 'iso-8859-15',
    'latin9': 'iso-8859-15',
    'l9': 'iso-8859-15',
    'windows-1250': 'windows-1250',
    'cp1250': 'windows-1250',
    'x-cp1250': 'windows-1250',
    'iso-8859-2': 'iso-8859-2',
    'iso8859-2': 'iso-8859-2',
    'iso_8859-2': 'iso-8859-2',
    'latin2': 'iso-8859-2',
    'l2': 'iso-8859-2',
    'windows-1251': 'windows-1251',
    'cp1251': 'windows-1251',
    'x-cp1251': 'windows-1251',
  };

  /// Bytes 0x80 to 0x9F where a charset keeps them as control codes.
  static final _controls =
      String.fromCharCodes([for (var c = 0x80; c <= 0x9F; c++) c]);

  /// Bytes 0x80 to 0xFF of a charset there is no table for.
  static final _unreadable = '\uFFFD' * 128;

  /// For each charset, the characters of bytes 0x80 to 0xFF in order. Below
  /// 0x80 they are all ASCII. Invisible characters and the two dashes are
  /// written as escapes so the rows stay readable.
  static final _tables = <String, String>{
    // Western European.
    'windows-1252':
        '€\u0081‚ƒ„…†‡ˆ‰Š‹Œ\u008DŽ\u008F\u0090‘’“”•\u2013\u2014˜™š›œ\u009DžŸ'
        '\u00A0¡¢£¤¥¦§¨©ª«¬\u00AD®¯°±²³´µ¶·¸¹º»¼½¾¿'
        'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞß'
        'àáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ',
    'iso-8859-15': '$_controls'
        '\u00A0¡¢£€¥Š§š©ª«¬\u00AD®¯°±²³Žµ¶·ž¹º»ŒœŸ¿'
        'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞß'
        'àáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ',
    // Central European (Polish, Czech, Hungarian).
    'windows-1250':
        '€\u0081‚\u0083„…†‡\u0088‰Š‹ŚŤŽŹ\u0090‘’“”•\u2013\u2014\u0098™š›śťžź'
        '\u00A0ˇ˘Ł¤Ą¦§¨©Ş«¬\u00AD®Ż°±˛ł´µ¶·¸ąş»Ľ˝ľż'
        'ŔÁÂĂÄĹĆÇČÉĘËĚÍÎĎĐŃŇÓÔŐÖ×ŘŮÚŰÜÝŢß'
        'ŕáâăäĺćçčéęëěíîďđńňóôőö÷řůúűüýţ˙',
    'iso-8859-2': '$_controls'
        '\u00A0Ą˘Ł¤ĽŚ§¨ŠŞŤŹ\u00ADŽŻ°ą˛ł´ľśˇ¸šşťź˝žż'
        'ŔÁÂĂÄĹĆÇČÉĘËĚÍÎĎĐŃŇÓÔŐÖ×ŘŮÚŰÜÝŢß'
        'ŕáâăäĺćçčéęëěíîďđńňóôőö÷řůúűüýţ˙',
    // Cyrillic.
    'windows-1251':
        'ЂЃ‚ѓ„…†‡€‰Љ‹ЊЌЋЏђ‘’“”•\u2013\u2014\u0098™љ›њќћџ'
        '\u00A0ЎўЈ¤Ґ¦§Ё©Є«¬\u00AD®Ї°±Ііґµ¶·ё№є»јЅѕї'
        'АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'
        'абвгдежзийклмнопрстуфхцчшщъыьэюя',
  };
}
