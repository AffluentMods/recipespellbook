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
/// title break the columns into bands.
List<PageLine> linesInReadingOrder(List<PageBlock> blocks) {
  final cleaned = blocks.where((b) => b.lines.isNotEmpty).toList();
  if (cleaned.isEmpty) return const [];

  final zipped = _zipAmountColumns(cleaned);
  final ordered = _order(zipped, 0);

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

List<PageBlock> _order(List<PageBlock> blocks, int depth) {
  final sorted = [...blocks]..sort(_byTop);
  if (sorted.length < 4 || depth > 2) return sorted;

  final gutter = _findGutter(sorted);
  if (gutter == null) return sorted;

  final out = <PageBlock>[];
  var left = <PageBlock>[];
  var right = <PageBlock>[];

  void flush() {
    if (left.isNotEmpty) out.addAll(_order(left, depth + 1));
    if (right.isNotEmpty) out.addAll(_order(right, depth + 1));
    left = <PageBlock>[];
    right = <PageBlock>[];
  }

  for (final b in sorted) {
    final crosses = b.left < gutter - _eps(b) && b.right > gutter + _eps(b);
    if (crosses) {
      flush();
      out.add(b);
    } else if (b.centerX < gutter) {
      left.add(b);
    } else {
      right.add(b);
    }
  }
  flush();
  return out;
}

double _eps(PageBlock b) => (b.height / (b.lines.isEmpty ? 1 : b.lines.length)) * 0.5;

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
    if (left.length < 2 || right.length < 2) continue;
    // A gutter can be interrupted by a title or a caption, not by most of
    // the page.
    if (crossing > blocks.length * 0.34) continue;

    final leftTop = left.map((b) => b.top).reduce((a, b) => a < b ? a : b);
    final leftBottom = left.map((b) => b.bottom).reduce((a, b) => a > b ? a : b);
    final rightTop = right.map((b) => b.top).reduce((a, b) => a < b ? a : b);
    final rightBottom = right.map((b) => b.bottom).reduce((a, b) => a > b ? a : b);
    final overlap = (leftBottom < rightBottom ? leftBottom : rightBottom) -
        (leftTop > rightTop ? leftTop : rightTop);
    final shorter = (leftBottom - leftTop) < (rightBottom - rightTop)
        ? (leftBottom - leftTop)
        : (rightBottom - rightTop);
    // Side by side, not one stacked above the other.
    if (shorter <= 0 || overlap < shorter * 0.3) continue;

    final leftEdge = left.map((b) => b.right).reduce((a, b) => a > b ? a : b);
    final rightEdge = right.map((b) => b.left).reduce((a, b) => a < b ? a : b);
    final gap = rightEdge - leftEdge;
    if (gap <= 0) continue;

    if (crossing < bestCrossing || (crossing == bestCrossing && gap > bestGap)) {
      bestCrossing = crossing;
      bestGap = gap;
      best = (leftEdge + rightEdge) / 2;
    }
  }
  return best;
}

final RegExp _bareAmount = RegExp(
  r'^[\d\s.,/\-–½⅓⅔¼¾⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞]+\s*'
  r'(g|kg|mg|ml|l|dl|cl|oz|lb|lbs|tsp|tbsp|cup|cups|pint|pints|x)?\.?$',
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
