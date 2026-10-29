/// Text of one scanned cookbook page, in the order a person would read it.
///
/// Pure Dart on purpose: on-device text recognition only runs on phones, so
/// everything that turns recognized boxes into ordered lines lives here where
/// it can be unit tested with hand-built pages.
library;

/// One recognized line. Geometry is in page pixels and is optional so tests and
/// plain-text inputs can omit it.
class PageLine {
  final String text;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  /// Lines of the same recognized paragraph share a block index. Paragraph
  /// boundaries are how wrapped lines get joined back into steps.
  final int block;

  const PageLine(
    this.text, {
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.block = 0,
  });

  bool get hasBox =>
      left != null && top != null && right != null && bottom != null;

  double? get height => hasBox ? bottom! - top! : null;
  double? get width => hasBox ? right! - left! : null;
  double? get centerY => hasBox ? (top! + bottom!) / 2 : null;

  PageLine withBlock(int block) => PageLine(
        text,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        block: block,
      );

  PageLine withText(String text, {double? right}) => PageLine(
        text,
        left: left,
        top: top,
        right: right ?? this.right,
        bottom: bottom,
        block: block,
      );
}

/// A recognized paragraph: its bounding box and its lines, top to bottom.
class PageBlock {
  final double left;
  final double top;
  final double right;
  final double bottom;
  final List<PageLine> lines;

  const PageBlock({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.lines,
  });

  double get width => right - left;
  double get height => bottom - top;
  double get centerX => (left + right) / 2;
}

/// One page: lines in reading order plus the page size when it is known.
class PageText {
  final List<PageLine> lines;
  final double? width;
  final double? height;

  const PageText(this.lines, {this.width, this.height});

  static const empty = PageText([]);

  bool get isEmpty => lines.every((l) => l.text.trim().isEmpty);

  /// Builds a page from plain text. A blank line starts a new paragraph.
  factory PageText.fromPlainText(String text) {
    final out = <PageLine>[];
    var block = 0;
    var pendingBreak = false;
    for (final raw in text.replaceAll('\r\n', '\n').split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) {
        pendingBreak = true;
        continue;
      }
      if (pendingBreak && out.isNotEmpty) block++;
      pendingBreak = false;
      out.add(PageLine(line, block: block));
    }
    return PageText(out);
  }

  /// Builds a page from recognized blocks, sorting them into reading order.
  factory PageText.fromBlocks(
    List<PageBlock> blocks, {
    double? width,
    double? height,
  }) {
    return PageText(
      linesInReadingOrder(blocks),
      width: width,
      height: height,
    );
  }

  String get plainText {
    final buf = StringBuffer();
    int? lastBlock;
    for (final l in lines) {
      if (lastBlock != null && l.block != lastBlock) buf.writeln();
      buf.writeln(l.text);
      lastBlock = l.block;
    }
    return buf.toString().trimRight();
  }
}

/// Sorts recognized blocks into reading order and returns their lines with
/// block indices renumbered in that order.
///
/// Text recognition returns paragraphs roughly top to bottom, which interleaves
/// the columns of a two-column page (ingredients on the left, method on the
/// right) and the two pages of a spread. This finds the vertical gutter, reads
/// the left column before the right one, and lets full-width blocks such as a
/// title break the columns into bands. Where a list stands beside its method,
/// a recipe printed below another is a band of its own as well, and what is
/// printed under both columns is read after both.
List<PageLine> linesInReadingOrder(List<PageBlock> blocks) {
  final cleaned = blocks.where((b) => b.lines.isNotEmpty).toList();
  if (cleaned.isEmpty) return const [];

  final zipped = _zipAmountColumns(cleaned);
  final ordered = _order(zipped, 0, _usualLineHeight(zipped));

  final out = <PageLine>[];
  for (var i = 0; i < ordered.length; i++) {
    for (final line in ordered[i].lines) {
      if (line.text.trim().isEmpty) continue;
      out.add(line.withBlock(i));
    }
  }
  return out;
}

int _byTop(PageBlock a, PageBlock b) {
  final dy = a.top.compareTo(b.top);
  return dy != 0 ? dy : a.left.compareTo(b.left);
}

/// Top to bottom. Blocks that start on the same row read left to right, even
/// when recognition puts the right-hand one a pixel or two higher.
List<PageBlock> _topToBottom(List<PageBlock> blocks) {
  final sorted = [...blocks]..sort(_byTop);
  var swapped = true;
  for (var pass = 0; swapped && pass < sorted.length; pass++) {
    swapped = false;
    for (var i = 0; i + 1 < sorted.length; i++) {
      final a = sorted[i];
      final b = sorted[i + 1];
      final halfLine = _eps(a) < _eps(b) ? _eps(a) : _eps(b);
      if (b.top - a.top < halfLine && b.right <= a.left) {
        sorted[i] = b;
        sorted[i + 1] = a;
        swapped = true;
      }
    }
  }
  return sorted;
}

/// [bodyLine] is the usual height of a line on the page.
List<PageBlock> _order(List<PageBlock> blocks, int depth, double bodyLine) {
  final sorted = _topToBottom(blocks);
  if (sorted.length < 2 || depth > 2) return sorted;

  final gutter = _findGutter(sorted);
  if (gutter == null) return sorted;

  bool crosses(PageBlock b) => b.left < gutter - _eps(b) && b.right > gutter + _eps(b);

  // A narrow column beside a wide one is a list beside its method, and a
  // page laid out that way may hold one recipe below another. There, what
  // stands wholly above a title, or above a clear gap across both columns,
  // was a recipe of its own and is read before anything below it. Columns of
  // like width are running text or the two pages of a spread, which read
  // down one and then down the other whatever stands in them.
  final narrower = _narrowerColumn([for (final b in sorted) if (!crosses(b)) b], gutter);
  final mayStack = narrower != null;

  final out = <PageBlock>[];
  var left = <PageBlock>[];
  var right = <PageBlock>[];

  void flush() {
    // With the list on the left, what begins below the last line of the
    // method after a clear gap in the list's own column was not the next
    // thing in that column. It was printed under both (a note, the name of
    // whoever sent the recipe in) and is read after both.
    var under = const <PageBlock>[];
    if (narrower == _Side.left && right.isNotEmpty) {
      var end = -double.infinity;
      for (final o in right) {
        if (o.bottom > end) end = o.bottom;
      }
      var lowest = -double.infinity;
      for (var k = 0; k < left.length; k++) {
        final o = left[k];
        if (o.top >= end - _eps(o) && o.top - lowest >= bodyLine * 2) {
          under = left.sublist(k);
          left = left.sublist(0, k);
          break;
        }
        if (o.bottom > lowest) lowest = o.bottom;
      }
    }
    if (left.isNotEmpty) out.addAll(_order(left, depth + 1, bodyLine));
    if (right.isNotEmpty) out.addAll(_order(right, depth + 1, bodyLine));
    out.addAll(under);
    left = <PageBlock>[];
    right = <PageBlock>[];
  }

  void endUnitAbove(int at) {
    final b = sorted[at];
    bool above(PageBlock o) => o.bottom <= b.top + _eps(o);
    final waiting = [...left, ...right];
    if (!waiting.any(above) || !waiting.every((o) => above(o) || o.top >= b.top - _eps(o))) return;
    var lowest = -double.infinity;
    for (final o in waiting) {
      if (above(o) && o.bottom > lowest) lowest = o.bottom;
    }
    if (_tallestLine(b) < bodyLine * 1.3) {
      if (b.top - lowest < bodyLine * 2) return;
      // A gap alone ends nothing when all that is left is more of the wide
      // column: that is the method, running on under a picture.
      final wideIsLeft = narrower == _Side.right;
      if (sorted.skip(at).every((o) => !crosses(o) && (o.centerX < gutter) == wideIsLeft)) return;
    }
    final keepLeft = [for (final o in left) if (!above(o)) o];
    final keepRight = [for (final o in right) if (!above(o)) o];
    left = [for (final o in left) if (above(o)) o];
    right = [for (final o in right) if (above(o)) o];
    flush();
    left = keepLeft;
    right = keepRight;
  }

  for (var i = 0; i < sorted.length; i++) {
    final b = sorted[i];
    if (crosses(b)) {
      flush();
      out.add(b);
      continue;
    }
    if (mayStack) endUnitAbove(i);
    (b.centerX < gutter ? left : right).add(b);
  }
  flush();
  return out;
}

double _eps(PageBlock b) => (b.height / (b.lines.isEmpty ? 1 : b.lines.length)) * 0.5;

/// The height of the tallest line of [b].
double _tallestLine(PageBlock b) {
  var tallest = 0.0;
  for (final l in b.lines) {
    final h = l.height;
    if (h != null && h > tallest) tallest = h;
  }
  return tallest > 0 ? tallest : b.height / (b.lines.isEmpty ? 1 : b.lines.length);
}

/// The usual height of a line on the page: the median over every line.
double _usualLineHeight(List<PageBlock> blocks) {
  final heights = <double>[
    for (final b in blocks)
      for (final l in b.lines) l.height ?? b.height / b.lines.length,
  ]..sort();
  return heights.isEmpty ? 0 : heights[heights.length ~/ 2];
}

enum _Side { left, right }

/// The side of [gutter] whose column is clearly the narrower one, or null
/// when the two are of like width.
_Side? _narrowerColumn(List<PageBlock> blocks, double gutter) {
  double width(bool leftSide) {
    var lo = double.infinity;
    var hi = -double.infinity;
    for (final b in blocks) {
      if ((b.centerX < gutter) != leftSide) continue;
      if (b.left < lo) lo = b.left;
      if (b.right > hi) hi = b.right;
    }
    return hi - lo;
  }

  final l = width(true);
  final r = width(false);
  if (!(l > 0) || !(r > 0) || l.isInfinite || r.isInfinite) return null;
  if (l <= r * 0.75) return _Side.left;
  return r <= l * 0.75 ? _Side.right : null;
}

/// The x position of a vertical gap with text on both sides, or null when the
/// page reads as a single column.
double? _findGutter(List<PageBlock> blocks) {
  var minLeft = double.infinity;
  var maxRight = -double.infinity;
  for (final b in blocks) {
    if (b.left < minLeft) minLeft = b.left;
    if (b.right > maxRight) maxRight = b.right;
  }
  final width = maxRight - minLeft;
  if (width <= 0) return null;

  final paragraphs = _paragraphsOf(blocks);
  double? best;
  var bestCrossing = 1 << 30;
  var bestGap = -double.infinity;

  const steps = 40;
  for (var i = 0; i <= steps; i++) {
    final x = minLeft + width * (0.28 + 0.44 * i / steps);
    var crossing = 0;
    final left = <PageBlock>[];
    final right = <PageBlock>[];
    for (final b in blocks) {
      if (b.left < x - _eps(b) && b.right > x + _eps(b)) {
        crossing++;
      } else if (b.centerX < x) {
        left.add(b);
      } else {
        right.add(b);
      }
    }
    if (left.isEmpty || right.isEmpty) continue;
    // A gutter can be interrupted by a title or a caption, not by most of
    // the page.
    if (crossing > blocks.length * 0.34) continue;

    // The gutter runs between paragraphs that stand side by side, however
    // few each side has: an ingredient list is often one paragraph, beside a
    // method of several. A short line that faces nothing (a centred title, a
    // name set flush right under its recipe) does not make a column, nor
    // does it narrow the gutter.
    var leftEdge = -double.infinity;
    var rightEdge = double.infinity;
    for (final a in left) {
      for (final b in right) {
        if (!_standLevel(a, b, paragraphs)) continue;
        if (a.right > leftEdge) leftEdge = a.right;
        if (b.left < rightEdge) rightEdge = b.left;
      }
    }
    final gap = rightEdge - leftEdge;
    if (gap.isNaN || gap.isInfinite || gap <= 0) continue;

    if (crossing < bestCrossing || (crossing == bestCrossing && gap > bestGap)) {
      bestCrossing = crossing;
      bestGap = gap;
      best = (leftEdge + rightEdge) / 2;
    }
  }
  return best;
}

/// Whether two paragraphs on either side of a gap stand beside each other.
/// Two single lines on one row (a title and a yield at the far margin) are a
/// row, not columns.
bool _standLevel(PageBlock a, PageBlock b, Map<PageBlock, _Paragraph> paragraphs) {
  final pa = paragraphs[a]!;
  final pb = paragraphs[b]!;
  if (pa.lines < 2 && pb.lines < 2) return false;
  final overlap = (pa.bottom < pb.bottom ? pa.bottom : pb.bottom) - (pa.top > pb.top ? pa.top : pb.top);
  return overlap >= (_eps(a) > _eps(b) ? _eps(a) : _eps(b));
}

/// A paragraph as it was printed: how far down the page it reaches and how
/// many lines it has.
class _Paragraph {
  double top;
  double bottom;
  int lines;
  _Paragraph(this.top, this.bottom, this.lines);
}

/// The printed paragraph every block belongs to. Recognition may cut one
/// paragraph into several blocks, down to a block for every line of a list.
/// Blocks that stand one under the other at the same left edge, in type of
/// the same size and with no more between them than there is between two
/// lines of a paragraph, are taken to be one.
Map<PageBlock, _Paragraph> _paragraphsOf(List<PageBlock> blocks) {
  final parent = List<int>.generate(blocks.length, (i) => i);
  int root(int i) {
    while (parent[i] != i) {
      i = parent[i] = parent[parent[i]];
    }
    return i;
  }

  for (var i = 0; i < blocks.length; i++) {
    for (var j = i + 1; j < blocks.length; j++) {
      final a = blocks[i];
      final b = blocks[j];
      final halfLine = _eps(a) < _eps(b) ? _eps(a) : _eps(b);
      if (!(halfLine > 0) || (_eps(a) > _eps(b) ? _eps(a) : _eps(b)) > halfLine * 1.25) continue;
      if ((a.left - b.left).abs() > halfLine) continue;
      final gap = a.top <= b.top ? b.top - a.bottom : a.top - b.bottom;
      if (gap.abs() > halfLine) continue;
      parent[root(i)] = root(j);
    }
  }

  final byRoot = <int, _Paragraph>{};
  for (var i = 0; i < blocks.length; i++) {
    final b = blocks[i];
    final p = byRoot[root(i)];
    if (p == null) {
      byRoot[root(i)] = _Paragraph(b.top, b.bottom, b.lines.length);
    } else {
      if (b.top < p.top) p.top = b.top;
      if (b.bottom > p.bottom) p.bottom = b.bottom;
      p.lines += b.lines.length;
    }
  }
  return {for (var i = 0; i < blocks.length; i++) blocks[i]: byRoot[root(i)]!};
}

/// What an amounts column may print after the number: the units the splitter
/// knows, and the everyday ones of the other languages the app is used in.
const String _amountUnits = r'g|kg|mg|ml|l|dl|cl|oz|lb|lbs|x'
    r'|cups?|tablespoons?|tbsps?|tbs|tbl|teaspoons?|tsps?|fl\.?\s?oz|ounces?|pounds?|grams?|kilos?|kilograms?'
    r'|millilit(?:er|re)s?|lit(?:er|re)s?|pints?|quarts?|gallons?|sticks?|cloves?|pinch(?:es)?|dash(?:es)?'
    r'|bunch(?:es)?|sprigs?|slices?|cans?|tins?|jars?|packets?|packages?|handfuls?|heads?|stalks?|rashers?|fillets?'
    r'|el|tl|pck|pkg|prisen?|bund|stk|st[uü]ck|msp|dosen?|becher|tassen?|zehen?'
    r'|c\.?\s?[àa]\s?[sc]|cuill[eè]res?|pinc[eé]es?|gousses?|sachets?|tranches?'
    r'|cucharadas?|cucharaditas?|cdas?|cditas?|tazas?|dientes?|pizcas?|latas?|colher(?:es)?|x[ií]caras?|pitadas?'
    r'|cucchiai[o]?|cucchiain[io]|spicchi[o]?|pizzic(?:o|hi)|bicchier[ei]|bustin[ae]'
    r'|eetlepels?|theelepels?|teentjes?|snufjes?|[lł]y[zż]k[ai]|[lł]y[zż]eczk[ai]|szklank[ai]|szczypt[ay]';

final RegExp _bareAmount = RegExp(
  r'^[\d\s.,/\-–½⅓⅔¼¾⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞]+'
  '(?:$_amountUnits)?'
  r'\.?$',
  caseSensitive: false,
);

/// Some books print ingredients as a table: amounts in one narrow column and
/// names in the next. Recognition returns those as two paragraphs, which reads
/// as every amount followed by every name. Rows that line up are joined back
/// into "amount name" lines.
List<PageBlock> _zipAmountColumns(List<PageBlock> blocks) {
  bool isAmountColumn(PageBlock b) {
    if (b.lines.length < 2) return false;
    final amounts = b.lines.where((l) => _bareAmount.hasMatch(l.text.trim())).length;
    return amounts >= b.lines.length * 0.7;
  }

  // Pair each amounts column with the nearest block to its right whose rows
  // line up with it.
  final partnerOf = <int, int>{};
  final taken = <int>{};
  for (var i = 0; i < blocks.length; i++) {
    final a = blocks[i];
    if (!isAmountColumn(a)) continue;
    int? partner;
    var partnerGap = double.infinity;
    for (var j = 0; j < blocks.length; j++) {
      if (j == i || taken.contains(j) || partnerOf.containsKey(j)) continue;
      final b = blocks[j];
      if (isAmountColumn(b)) continue;
      if (b.left < a.right) continue;
      final gap = b.left - a.right;
      if (gap > a.width * 6 + 80) continue;
      final overlap = (a.bottom < b.bottom ? a.bottom : b.bottom) - (a.top > b.top ? a.top : b.top);
      if (overlap < a.height * 0.6) continue;
      if (gap < partnerGap) {
        partnerGap = gap;
        partner = j;
      }
    }
    if (partner != null) {
      partnerOf[i] = partner;
      taken.add(partner);
    }
  }
  if (partnerOf.isEmpty) return blocks;

  final out = <PageBlock>[];
  for (var i = 0; i < blocks.length; i++) {
    if (taken.contains(i)) continue;
    final a = blocks[i];
    final partner = partnerOf[i];
    if (partner == null) {
      out.add(a);
      continue;
    }

    final b = blocks[partner];
    final remaining = [...b.lines];
    final merged = <PageLine>[];
    for (final amount in a.lines) {
      PageLine? match;
      final ay = amount.centerY;
      if (ay != null) {
        for (final name in remaining) {
          if (name.top == null || name.bottom == null) continue;
          if (ay >= name.top! && ay <= name.bottom!) {
            match = name;
            break;
          }
        }
      }
      if (match == null) {
        merged.add(amount);
      } else {
        remaining.remove(match);
        merged.add(amount.withText('${amount.text.trim()} ${match.text.trim()}', right: match.right));
      }
    }
    // Names with no amount beside them (salt, to taste) keep their own line.
    merged.addAll(remaining);
    merged.sort((x, y) => (x.top ?? 0).compareTo(y.top ?? 0));

    out.add(PageBlock(
      left: a.left,
      top: a.top < b.top ? a.top : b.top,
      right: b.right,
      bottom: a.bottom > b.bottom ? a.bottom : b.bottom,
      lines: merged,
    ));
  }
  return out;
}
