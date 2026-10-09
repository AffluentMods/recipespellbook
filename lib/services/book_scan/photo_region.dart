/// Finds the food photograph on a scanned cookbook page.
///
/// A recipe page is mostly text. If it also carries a photograph, that is the
/// biggest area with no text in it, and it has colour and detail where paper
/// has neither. The geometry here is pure Dart; the caller supplies the
/// pixels.
library;

import 'dart:math' as math;
import 'dart:typed_data';

/// A rectangle in page pixels.
class PageRect {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const PageRect(this.left, this.top, this.right, this.bottom);

  double get width => right - left;
  double get height => bottom - top;
}

/// A region of a page as fractions of its width and height (0..1), so it stays
/// valid for any decoded size of the same image.
class PhotoRegion {
  final double left;
  final double top;
  final double right;
  final double bottom;

  /// Higher is more photographic. Used to pick the best photo when a recipe
  /// runs over several pages.
  final double score;

  const PhotoRegion({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    this.score = 0,
  });

  double get width => right - left;
  double get height => bottom - top;

  PhotoRegion withScore(double score) =>
      PhotoRegion(left: left, top: top, right: right, bottom: bottom, score: score);
}

/// The largest text-free rectangle on a page, or null when none is big enough
/// or it is shaped like a margin.
///
/// [textBoxes] are the bounding boxes of the recognized paragraphs, in the
/// same pixel space as [pageWidth] and [pageHeight].
///
/// The rectangle is where a photograph could be, not proof of one: the empty
/// half of a page under a short recipe passes too. [photographicScore] is the
/// check that looks at the pixels.
PhotoRegion? largestTextFreeRegion(
  List<PageRect> textBoxes,
  double pageWidth,
  double pageHeight, {
  double minAreaFraction = 0.08,
}) {
  if (pageWidth <= 0 || pageHeight <= 0) return null;

  // A coarse grid is plenty: photographs are big, and it keeps this cheap.
  const gridW = 32;
  const gridH = 32;
  final cellW = pageWidth / gridW;
  final cellH = pageHeight / gridH;
  final taken = List.generate(gridH, (_) => List.filled(gridW, false));

  // Text is padded a little so the crop does not shave a line of type.
  final pad = pageHeight * 0.008;
  for (final box in textBoxes) {
    final l = (box.left - pad).clamp(0.0, pageWidth);
    final t = (box.top - pad).clamp(0.0, pageHeight);
    final r = (box.right + pad).clamp(0.0, pageWidth);
    final b = (box.bottom + pad).clamp(0.0, pageHeight);
    final x0 = (l / cellW).floor().clamp(0, gridW - 1);
    final y0 = (t / cellH).floor().clamp(0, gridH - 1);
    final x1 = (r / cellW).ceil().clamp(0, gridW);
    final y1 = (b / cellH).ceil().clamp(0, gridH);
    for (var y = y0; y < y1; y++) {
      for (var x = x0; x < x1; x++) {
        taken[y][x] = true;
      }
    }
  }

  // Largest empty rectangle, by the histogram method.
  final heights = List<int>.filled(gridW, 0);
  var bestArea = 0;
  var bx0 = 0, by0 = 0, bx1 = 0, by1 = 0;
  for (var y = 0; y < gridH; y++) {
    for (var x = 0; x < gridW; x++) {
      heights[x] = taken[y][x] ? 0 : heights[x] + 1;
    }
    final stack = <int>[];
    for (var x = 0; x <= gridW; x++) {
      final h = x == gridW ? 0 : heights[x];
      while (stack.isNotEmpty && heights[stack.last] > h) {
        final top = stack.removeLast();
        final w = stack.isEmpty ? x : x - stack.last - 1;
        final area = heights[top] * w;
        if (area > bestArea) {
          bestArea = area;
          bx0 = stack.isEmpty ? 0 : stack.last + 1;
          by0 = y - heights[top] + 1;
          bx1 = x;
          by1 = y + 1;
        }
      }
      stack.add(x);
    }
  }
  if (bestArea == 0) return null;

  final w = (bx1 - bx0) / gridW;
  final h = (by1 - by0) / gridH;
  if (w * h < minAreaFraction) return null;

  // A long thin strip is a margin. The bounds are loose on purpose: the
  // rectangle takes in the white paper around a photograph, so a picture set
  // beside a column of text arrives here as a tall half page.
  final aspect = (w * pageWidth) / (h * pageHeight);
  if (aspect < 0.3 || aspect > 3.2) return null;

  return PhotoRegion(
    left: bx0 / gridW,
    top: by0 / gridH,
    right: bx1 / gridW,
    bottom: by1 / gridH,
    score: w * h,
  );
}

/// How photographic [region] of an RGBA image is: null for blank paper or a
/// flat tint, otherwise a score where higher is more photographic.
///
/// [rgba] is [width] x [height] pixels, 4 bytes each. A small decode is
/// enough; this samples a 24 x 24 grid.
///
/// It errs towards null. A missed photograph only means the whole page is
/// used as the recipe's picture; a false one would save a crop of blank paper.
double? photographicScore(Uint8List rgba, int width, int height, PhotoRegion region) {
  final s = _Samples.of(rgba, width, height, region);
  if (s == null) return null;

  // Mostly paper.
  if (s.bright / s.count > 0.7) return null;

  // Paper under a lamp is tinted and shaded, but smoothly and all one hue. A
  // photograph changes from one sample to the next, in brightness or in
  // colour or both.
  final smooth = s.detail < 3.0;
  final oneHue = s.hueSpread < 10.0;
  if (smooth && oneHue) return null;
  // A coloured panel behind a caption: no detail at all, whatever its hue.
  if (s.detail < 1.0) return null;

  final colour = (s.hueSpread / 40).clamp(0.0, 1.0);
  final detail = (s.detail / 24).clamp(0.0, 1.0);
  return region.width * region.height + 0.6 * colour + 0.4 * detail;
}

/// [region] pulled in to the photograph inside it.
///
/// The text-free rectangle usually takes in white paper around the picture:
/// the page margin, the gap above a caption. This trims each side while it is
/// still paper, so the saved image is the photograph and not a photograph in
/// a white frame. Returns [region] unchanged when nothing can be trimmed or
/// when trimming would leave next to nothing.
PhotoRegion tightenToContent(Uint8List rgba, int width, int height, PhotoRegion region) {
  if (width <= 0 || height <= 0 || rgba.length < width * height * 4) return region;
  final x0 = (region.left * width).floor().clamp(0, width - 1);
  final y0 = (region.top * height).floor().clamp(0, height - 1);
  final x1 = (region.right * width).ceil().clamp(x0 + 1, width);
  final y1 = (region.bottom * height).ceil().clamp(y0 + 1, height);

  bool paper(int x, int y) {
    final i = (y * width + x) * 4;
    return rgba[i] > 226 && rgba[i + 1] > 226 && rgba[i + 2] > 226;
  }

  // A row or column counts as paper when nearly all of it is.
  bool paperRow(int y, int from, int to) {
    var n = 0;
    for (var x = from; x < to; x++) {
      if (paper(x, y)) n++;
    }
    return n >= (to - from) * 0.94;
  }

  bool paperColumn(int x, int from, int to) {
    var n = 0;
    for (var y = from; y < to; y++) {
      if (paper(x, y)) n++;
    }
    return n >= (to - from) * 0.94;
  }

  var top = y0;
  var bottom = y1;
  var left = x0;
  var right = x1;
  while (top < bottom - 1 && paperRow(top, left, right)) {
    top++;
  }
  while (bottom - 1 > top && paperRow(bottom - 1, left, right)) {
    bottom--;
  }
  while (left < right - 1 && paperColumn(left, top, bottom)) {
    left++;
  }
  while (right - 1 > left && paperColumn(right - 1, top, bottom)) {
    right--;
  }
  // The rows were judged at the full width; look again now it is narrower.
  while (top < bottom - 1 && paperRow(top, left, right)) {
    top++;
  }
  while (bottom - 1 > top && paperRow(bottom - 1, left, right)) {
    bottom--;
  }

  final keptW = (right - left) / (x1 - x0);
  final keptH = (bottom - top) / (y1 - y0);
  if (keptW < 0.25 || keptH < 0.25) return region;
  if (top == y0 && bottom == y1 && left == x0 && right == x1) return region;

  return PhotoRegion(
    left: left / width,
    top: top / height,
    right: right / width,
    bottom: bottom / height,
    score: region.score,
  );
}

/// The food photograph on a page, or null when the page has none.
///
/// [textBoxes] and the page size are in the pixels text recognition worked
/// in; [rgba] is any smaller decode of the same image, [width] x [height].
PhotoRegion? findPhotograph({
  required List<PageRect> textBoxes,
  required double pageWidth,
  required double pageHeight,
  required Uint8List rgba,
  required int width,
  required int height,
}) {
  final free = largestTextFreeRegion(textBoxes, pageWidth, pageHeight);
  if (free == null) return null;
  final region = tightenToContent(rgba, width, height, free);
  // Too small to be the dish: an ornament, a publisher's mark.
  if (region.width * region.height < 0.05) return null;
  final score = photographicScore(rgba, width, height, region);
  return score == null ? null : region.withScore(score);
}

/// What a 24 x 24 sample of a region looks like.
class _Samples {
  _Samples._(this.count, this.bright, this.detail, this.hueSpread);

  final int count;

  /// Samples that are paper white.
  final int bright;

  /// Mean change in brightness from one sample to the next (0..255).
  final double detail;

  /// How far the samples' colour strays from the region's own tint. Near zero
  /// for paper of any colour, large for a picture.
  final double hueSpread;

  static const _n = 24;

  static _Samples? of(Uint8List rgba, int width, int height, PhotoRegion region) {
    if (width <= 0 || height <= 0 || rgba.length < width * height * 4) return null;
    final x0 = (region.left * width).floor().clamp(0, width - 1);
    final y0 = (region.top * height).floor().clamp(0, height - 1);
    final x1 = (region.right * width).ceil().clamp(x0 + 1, width);
    final y1 = (region.bottom * height).ceil().clamp(y0 + 1, height);

    final luma = Float64List(_n * _n);
    final warm = Float64List(_n * _n); // red against blue
    final green = Float64List(_n * _n); // green against the other two
    var bright = 0;
    var sumWarm = 0.0;
    var sumGreen = 0.0;

    for (var sy = 0; sy < _n; sy++) {
      final y = y0 + ((y1 - y0 - 1) * sy / (_n - 1)).round();
      for (var sx = 0; sx < _n; sx++) {
        final x = x0 + ((x1 - x0 - 1) * sx / (_n - 1)).round();
        final i = (y * width + x) * 4;
        final r = rgba[i];
        final g = rgba[i + 1];
        final b = rgba[i + 2];
        if (r > 232 && g > 232 && b > 232) bright++;
        final k = sy * _n + sx;
        luma[k] = 0.299 * r + 0.587 * g + 0.114 * b;
        warm[k] = (r - b).toDouble();
        green[k] = g - (r + b) / 2;
        sumWarm += warm[k];
        sumGreen += green[k];
      }
    }

    const count = _n * _n;
    final meanWarm = sumWarm / count;
    final meanGreen = sumGreen / count;

    var change = 0.0;
    var pairs = 0;
    var spread = 0.0;
    for (var sy = 0; sy < _n; sy++) {
      for (var sx = 0; sx < _n; sx++) {
        final k = sy * _n + sx;
        if (sx + 1 < _n) {
          change += (luma[k + 1] - luma[k]).abs();
          pairs++;
        }
        if (sy + 1 < _n) {
          change += (luma[k + _n] - luma[k]).abs();
          pairs++;
        }
        final dw = warm[k] - meanWarm;
        final dg = green[k] - meanGreen;
        spread += dw * dw + dg * dg;
      }
    }

    return _Samples._(count, bright, pairs == 0 ? 0 : change / pairs, math.sqrt(spread / count));
  }
}
