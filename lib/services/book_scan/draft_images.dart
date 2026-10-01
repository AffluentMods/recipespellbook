/// Chooses the picture for each recipe found in a scan.
library;

import 'book_page_splitter.dart';
import 'photo_region.dart';
import 'scanned_page.dart';

/// The image a draft will be saved with: a scanned page, optionally cut down
/// to the food photograph on it.
class DraftImage {
  /// Index of the page in the scan.
  final int page;

  /// The photograph on that page, or null to use the whole page.
  final PhotoRegion? crop;

  const DraftImage(this.page, [this.crop]);
}

/// A page that is all photograph: a picture facing its recipe.
bool isPhotoPage(ScannedPage page) {
  final photo = page.photo;
  if (photo == null) return false;
  final lines = page.text.lines.where((l) => l.text.trim().isNotEmpty).length;
  return lines <= 3 && photo.width * photo.height >= 0.45;
}

/// The indices of the pages in [pages] that are all photograph.
Set<int> photoPagesOf(List<ScannedPage> pages) => {
      for (var p = 0; p < pages.length; p++)
        if (isPhotoPage(pages[p])) p,
    };

/// Picks an image for every draft, in order:
///
///  1. a full-page photograph whose caption names the recipe;
///  2. the best photograph on one of the recipe's own pages;
///  3. a full-page photograph facing the recipe, if no other recipe has
///     taken it;
///  4. the first page of the recipe, uncropped.
///
/// [pageNumbers] are the printed page numbers, where known. They say which
/// way a photograph faces: a left-hand page (even) faces the page after it, a
/// right-hand page the one before.
///
/// The result lines up with [drafts]. A draft whose pages are out of range
/// gets its first page clamped into range.
List<DraftImage> assignDraftImages(
  List<BookRecipeDraft> drafts,
  List<ScannedPage> pages, {
  List<int?> pageNumbers = const [],
}) {
  final out = List<DraftImage?>.filled(drafts.length, null);
  if (pages.isEmpty) {
    return [for (final _ in drafts) const DraftImage(0)];
  }

  int clamp(int i) => i < 0 ? 0 : (i >= pages.length ? pages.length - 1 : i);

  final photoPages = photoPagesOf(pages);
  final claimed = <int>{};

  // 1. Captions.
  for (final p in photoPages) {
    final caption = pages[p].text.lines.map((l) => l.text).join(' ').toLowerCase();
    if (caption.trim().isEmpty) continue;
    var best = -1;
    var bestHits = 0;
    for (var d = 0; d < drafts.length; d++) {
      if (out[d] != null || !drafts[d].titleFound) continue;
      final words = _titleWords(drafts[d].recipe.title);
      if (words.length < 2) continue;
      final hits = words.where(caption.contains).length;
      if (hits == words.length && hits > bestHits) {
        bestHits = hits;
        best = d;
      }
    }
    if (best >= 0) {
      out[best] = DraftImage(p, pages[p].photo);
      claimed.add(p);
    }
  }

  // 2. A photograph on the recipe's own pages.
  for (var d = 0; d < drafts.length; d++) {
    if (out[d] != null) continue;
    final from = clamp(drafts[d].startPage);
    final to = clamp(drafts[d].endPage);
    int? bestPage;
    var bestScore = -1.0;
    for (var p = from; p <= to; p++) {
      final photo = pages[p].photo;
      if (photo == null || claimed.contains(p)) continue;
      if (photo.score > bestScore) {
        bestScore = photo.score;
        bestPage = p;
      }
    }
    if (bestPage != null) {
      out[d] = DraftImage(bestPage, pages[bestPage].photo);
      if (photoPages.contains(bestPage)) claimed.add(bestPage);
    }
  }

  // 3. A facing photograph.
  //
  // The draft with nothing yet that sits on [page]: the one that starts
  // there, else one that runs onto it.
  int? draftOn(int page) {
    if (page < 0 || page >= pages.length) return null;
    int? covering;
    for (var d = 0; d < drafts.length; d++) {
      if (out[d] != null) continue;
      if (drafts[d].startPage == page) return d;
      if (drafts[d].startPage <= page && page <= drafts[d].endPage) covering ??= d;
    }
    return covering;
  }

  // With no page numbers to go by, the scan itself hints at the book's
  // layout: one that opens on a photograph prints its pictures first.
  final photosLead = photoPages.contains(0);
  final unclaimed = photoPages.where((p) => !claimed.contains(p)).toList()..sort();
  for (final p in unclaimed) {
    final number = p < pageNumbers.length ? pageNumbers[p] : null;
    final facesNext = number != null ? number.isEven : photosLead;
    final sides = [
      facesNext ? p + 1 : p - 1,
      // Only a guess gets a second try on the other side.
      if (number == null) facesNext ? p - 1 : p + 1,
    ];

    // The neighbour in the scan is the facing page only if its number is the
    // next one along; a page may have been skipped between them.
    bool isFacing(int side) {
      if (number == null || side < 0 || side >= pageNumbers.length) return true;
      final other = pageNumbers[side];
      if (other == null) return true;
      return other == (side > p ? number + 1 : number - 1);
    }

    for (final side in sides) {
      if (!isFacing(side)) continue;
      final d = draftOn(side);
      if (d == null) continue;
      out[d] = DraftImage(p, pages[p].photo);
      claimed.add(p);
      break;
    }
  }

  // 4. The recipe's first page.
  return [
    for (var d = 0; d < drafts.length; d++) out[d] ?? DraftImage(clamp(drafts[d].startPage)),
  ];
}

const _stopWords = {'the', 'and', 'with', 'for', 'from', 'a', 'an', 'of', 'in', 'on', 'to'};

List<String> _titleWords(String title) => title
    .toLowerCase()
    .split(RegExp(r'[^a-zà-ÿ]+'))
    .where((w) => w.length > 2 && !_stopWords.contains(w))
    .toList();
