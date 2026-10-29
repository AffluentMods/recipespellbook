/// A forgiving reader for the XML that recipe apps export.
///
/// These files are rarely well-formed. MasterCook puts bare ampersands in
/// attribute values and writes its declaration out of order, and Living
/// Cookbook uses attribute names a strict parser rejects. So this reads what is
/// there instead of validating it: anything it does not understand is skipped,
/// an element with no end tag ends with its parent, and nothing here throws.
///
/// Names are compared without case and without a namespace prefix, so
/// `<fdx:Recipe>` and `<recipe>` are the same element.
///
/// The text is walked once from start to end, so a cookbook with hundreds of
/// embedded photos stays fast.
library;

/// One element of a document read by [LooseXml.parse].
class XmlElement {
  XmlElement._(this.name, this.attributes, this._source);

  /// Lower case, without a namespace prefix.
  final String name;

  /// Attribute values by lower-case name, with entities already decoded.
  final Map<String, String> attributes;

  /// True when the element was ended by its own end tag, or was written as
  /// `<name/>`. False when the file stopped first, or when only the end of an
  /// enclosing element closed it.
  bool get closed => _closed;
  bool _closed = false;

  final String _source;

  /// Child elements and runs of text, in the order they were written.
  final List<Object> _content = [];

  /// The trimmed value of the attribute [name] with line endings as `\n`, or
  /// null when it is missing or blank.
  String? attribute(String name) {
    final value =
        attributes[name.toLowerCase()]?.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  /// Every element called [name] inside this one, however deep, in the order
  /// they were written.
  Iterable<XmlElement> all(String name) => _find(name, wholeOnly: false);

  /// The elements called [name] that are [closed] and not inside another of
  /// them that is. These are the records of a document. One the file stops
  /// inside holds only part of what it should, and one found inside a whole
  /// record is that record's own content, not a second record.
  Iterable<XmlElement> whole(String name) => _find(name, wholeOnly: true);

  Iterable<XmlElement> _find(String name, {required bool wholeOnly}) sync* {
    final wanted = name.toLowerCase();
    // An explicit stack rather than recursion: a damaged file can nest
    // thousands of unclosed elements.
    final pending = <Iterator<Object>>[_content.iterator];
    while (pending.isNotEmpty) {
      final level = pending.last;
      if (!level.moveNext()) {
        pending.removeLast();
        continue;
      }
      final node = level.current;
      if (node is! XmlElement) continue;
      final found = node.name == wanted && (node.closed || !wholeOnly);
      if (found) yield node;
      // What a whole record holds is left to whoever reads the record, so no
      // part of the document is gone through once for every record around it.
      if (!found || !wholeOnly) pending.add(node._content.iterator);
    }
  }

  /// The first element called [name] inside this one, or null.
  XmlElement? find(String name) {
    for (final element in all(name)) {
      return element;
    }
    return null;
  }

  /// The trimmed text of the first element called [name] inside this one, or
  /// null when there is none or it is blank.
  String? textOf(String name) {
    final value = find(name)?.text.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  /// The text inside this element and its children, entities decoded and
  /// line endings as `\n`. A `<br>` counts as a line break.
  String get text {
    final out = StringBuffer();
    final pending = <Iterator<Object>>[_content.iterator];
    while (pending.isNotEmpty) {
      final level = pending.last;
      if (!level.moveNext()) {
        pending.removeLast();
        continue;
      }
      final node = level.current;
      if (node is XmlElement) {
        if (node.name == 'br') out.write('\n');
        pending.add(node._content.iterator);
      } else if (node is _TextRun) {
        final raw = _source.substring(node.start, node.end);
        out.write(node.literal ? raw : LooseXml._decodeEntities(raw));
      }
    }
    return out.toString().replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  }
}

/// A stretch of text between tags, kept as a range of the source so a large
/// embedded photo is only copied when someone asks for it.
class _TextRun {
  const _TextRun(this.start, this.end, this.literal);

  final int start;
  final int end;

  /// CDATA: the text is taken as written, entities and all.
  final bool literal;
}

/// Reads a document into [XmlElement]s.
class LooseXml {
  LooseXml._();

  /// Reads [source] and returns a root element holding everything in it.
  static XmlElement parse(String source) {
    final root = XmlElement._('', const {}, source);
    final open = <XmlElement>[root];
    // How many elements of each name are open, so an end tag that matches
    // nothing is dropped without walking the whole stack.
    final openNames = <String, int>{};
    final length = source.length;

    void addText(int start, int end, {bool literal = false}) {
      if (end > start) open.last._content.add(_TextRun(start, end, literal));
    }

    var pos = 0;
    while (pos < length) {
      final lt = source.indexOf('<', pos);
      if (lt < 0) {
        addText(pos, length);
        break;
      }
      addText(pos, lt);

      if (source.startsWith('<!--', lt)) {
        final end = source.indexOf('-->', lt + 4);
        if (end < 0) break;
        pos = end + 3;
      } else if (source.startsWith('<![CDATA[', lt)) {
        final end = source.indexOf(']]>', lt + 9);
        addText(lt + 9, end < 0 ? length : end, literal: true);
        if (end < 0) break;
        pos = end + 3;
      } else if (source.startsWith('<?', lt) || source.startsWith('<!', lt)) {
        // The declaration, the doctype and processing instructions.
        final end = source.indexOf('>', lt + 2);
        if (end < 0) break;
        pos = end + 1;
      } else {
        final next = source.startsWith('</', lt)
            ? _endTag(source, lt, open, openNames)
            : _startTag(source, lt, open, openNames);
        if (next == _unfinished) break;
        if (next == _notATag) {
          // A "<" in running text.
          addText(lt, lt + 1);
          pos = lt + 1;
        } else {
          pos = next;
        }
      }
    }
    return root;
  }

  static const _unfinished = -1;
  static const _notATag = -2;

  /// Reads the start tag at [lt] and adds its element to the innermost open
  /// one. Returns the position after the tag, [_notATag] when the "<" does
  /// not begin a tag, or [_unfinished] when the file ends inside it.
  static int _startTag(
    String source,
    int lt,
    List<XmlElement> open,
    Map<String, int> openNames,
  ) {
    final length = source.length;
    var i = lt + 1;
    if (i >= length || !_isNameStart(source.codeUnitAt(i))) return _notATag;
    while (i < length && !_endsName(source.codeUnitAt(i))) {
      i++;
    }
    final name = _plainName(source.substring(lt + 1, i));
    final attributes = <String, String>{};
    var selfClosing = false;

    while (true) {
      while (i < length && _isSpace(source.codeUnitAt(i))) {
        i++;
      }
      if (i >= length) return _unfinished;
      final c = source.codeUnitAt(i);
      if (c == _gt) {
        i++;
        break;
      }
      if (c == _slash) {
        selfClosing = i + 1 < length && source.codeUnitAt(i + 1) == _gt;
        i += selfClosing ? 2 : 1;
        if (selfClosing) break;
        continue;
      }
      // Another "<" before the tag ended: the first one was only text.
      if (c == _lt) return _notATag;

      final nameStart = i;
      while (i < length && !_endsName(source.codeUnitAt(i)) && source.codeUnitAt(i) != _equals) {
        i++;
      }
      final key = source.substring(nameStart, i).toLowerCase();
      while (i < length && _isSpace(source.codeUnitAt(i))) {
        i++;
      }
      var value = '';
      if (i < length && source.codeUnitAt(i) == _equals) {
        i++;
        while (i < length && _isSpace(source.codeUnitAt(i))) {
          i++;
        }
        if (i >= length) return _unfinished;
        final quote = source.codeUnitAt(i);
        if (quote == _doubleQuote || quote == _singleQuote) {
          final end = _closingQuote(source, i, quote == _doubleQuote ? '"' : "'");
          if (end < 0) return _unfinished;
          value = source.substring(i + 1, end);
          i = end + 1;
        } else {
          final valueStart = i;
          while (i < length && !_isSpace(source.codeUnitAt(i)) && source.codeUnitAt(i) != _gt) {
            i++;
          }
          value = source.substring(valueStart, i);
          // name=value/> : the slash closes the tag, it is not part of the value.
          if (value.endsWith('/') && i < length && source.codeUnitAt(i) == _gt) {
            value = value.substring(0, value.length - 1);
            i--;
          }
        }
      }
      if (key.isNotEmpty) attributes.putIfAbsent(key, () => _decodeEntities(value));
    }

    final element = XmlElement._(name, attributes, source);
    open.last._content.add(element);
    if (selfClosing) {
      element._closed = true;
    } else {
      open.add(element);
      openNames[name] = (openNames[name] ?? 0) + 1;
    }
    return i;
  }

  /// The position of the quote that ends the attribute value opened by the
  /// quote [mark] at [open], or -1 when the file stops first.
  ///
  /// MasterCook does not always escape an inch mark inside a value
  /// (`name="pie shell (9")"`), so the first quote is not always the end. A
  /// quote ends the value when the rest of the tag still makes sense: the tag
  /// closes before another quote appears, or the next quote opens a value
  /// after an "=".
  static int _closingQuote(String source, int open, String mark) {
    final first = source.indexOf(mark, open + 1);
    var end = first;
    // A value holds a few stray quotes at most. Looking further would only
    // slow down a file that is damaged.
    for (var tries = 0; end >= 0 && tries < 16; tries++) {
      if (_tagGoesOn(source, end + 1)) return end;
      end = source.indexOf(mark, end + 1);
    }
    return first;
  }

  static bool _tagGoesOn(String source, int from) {
    for (var i = from; i < source.length; i++) {
      final c = source.codeUnitAt(i);
      if (c == _gt) return true;
      if (c == _doubleQuote || c == _singleQuote) {
        var before = i - 1;
        while (before >= from && _isSpace(source.codeUnitAt(before))) {
          before--;
        }
        return before >= from && source.codeUnitAt(before) == _equals;
      }
    }
    return true;
  }

  /// Reads the end tag at [lt] and ends the innermost open element of that
  /// name, and with it anything still open inside. An end tag with no
  /// matching start is ignored. Returns as [_startTag] does.
  static int _endTag(
    String source,
    int lt,
    List<XmlElement> open,
    Map<String, int> openNames,
  ) {
    final length = source.length;
    var i = lt + 2;
    if (i >= length) return _unfinished;
    if (!_isNameStart(source.codeUnitAt(i))) return _notATag;
    while (i < length && !_endsName(source.codeUnitAt(i)) && source.codeUnitAt(i) != _lt) {
      i++;
    }
    final name = _plainName(source.substring(lt + 2, i));
    while (i < length && _isSpace(source.codeUnitAt(i))) {
      i++;
    }
    if (i >= length) return _unfinished;
    if (source.codeUnitAt(i) != _gt) return _notATag;

    if ((openNames[name] ?? 0) > 0) {
      while (true) {
        final element = open.removeLast();
        openNames[element.name] = openNames[element.name]! - 1;
        if (element.name == name) {
          element._closed = true;
          break;
        }
      }
    }
    return i + 1;
  }

  static String _plainName(String raw) {
    final name = raw.trim();
    return name.substring(name.lastIndexOf(':') + 1).toLowerCase();
  }

  static const _named = {
    'amp': '&',
    'lt': '<',
    'gt': '>',
    'quot': '"',
    'apos': "'",
    'nbsp': ' ',
  };

  static final _entity = RegExp(r'&(#[xX][0-9a-fA-F]{1,6}|#[0-9]{1,7}|[A-Za-z]{2,8});');

  /// Turns `&amp;`, `&#176;` and the like into the characters they stand
  /// for. Anything that is not a known entity is left as written.
  static String _decodeEntities(String text) {
    if (!text.contains('&')) return text;
    return text.replaceAllMapped(_entity, (m) {
      final body = m[1]!;
      if (body.codeUnitAt(0) != 0x23) return _named[body] ?? m[0]!;
      final hex = body.codeUnitAt(1) == 0x78 || body.codeUnitAt(1) == 0x58;
      final code = int.tryParse(body.substring(hex ? 2 : 1), radix: hex ? 16 : 10);
      if (code == null || code == 0 || code > 0x10FFFF || (code >= 0xD800 && code <= 0xDFFF)) {
        return m[0]!;
      }
      return String.fromCharCode(code);
    });
  }

  static const _lt = 0x3C;
  static const _gt = 0x3E;
  static const _slash = 0x2F;
  static const _equals = 0x3D;
  static const _doubleQuote = 0x22;
  static const _singleQuote = 0x27;

  static bool _isSpace(int c) => c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D;

  static bool _isNameStart(int c) =>
      (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A) || c == 0x5F || c > 0x7F;

  static bool _endsName(int c) => _isSpace(c) || c == _gt || c == _slash;
}
