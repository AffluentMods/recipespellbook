/// Turns the recognized text of photographed cookbook pages into recipes.
///
/// The pages arrive in the order they were scanned. A recipe may run across two
/// pages and one page may hold two recipes, so the pages are first joined into
/// one stream of lines (minus page numbers and running headers) and then cut
/// wherever a new recipe starts. Every recipe is anchored on its ingredient
/// list, because that is the one part every printed recipe has and the part
/// that looks least like prose; the title is then found by looking back from
/// the list.
///
/// Pure Dart, no Flutter and no I/O, so it runs under plain unit tests.
library;

import '../../models/imported_recipe.dart';
import 'page_text.dart';

/// One line of recognized text as the splitter saw it. Drafts keep their lines
/// so a recipe can be split again by hand and so the review screen can show
/// what was read.
class SourceLine {
  final String text;

  /// Index of the scanned page this line came from.
  final int page;

  /// Paragraph id, unique across the whole scan.
  final int block;

  /// First line of its paragraph.
  final bool paragraphStart;

  /// Line height relative to the body text of its page (1.0 is body size).
  /// Null when the scan carried no geometry.
  final double? relHeight;

  final double? left;
  final double? right;
  final double? height;

  /// 1 for a line on the right-hand page when one photo shows a whole spread,
  /// otherwise 0. Added to the photo's page number.
  final int pageOffset;

  const SourceLine(
    this.text, {
    required this.page,
    required this.block,
    this.paragraphStart = false,
    this.relHeight,
    this.left,
    this.right,
    this.height,
    this.pageOffset = 0,
  });

  /// The same line with its page index moved by [by] (used when pages are
  /// added to a scan that already has some).
  SourceLine onPage(int by) => SourceLine(
        text,
        page: page + by,
        block: block,
        paragraphStart: paragraphStart,
        relHeight: relHeight,
        left: left,
        right: right,
        height: height,
        pageOffset: pageOffset,
      );
}

/// Why a draft needs a look before it is saved.
enum BookDraftIssue { noTitle, noIngredients, noSteps }

/// A recipe found in the scan, still editable and not yet saved.
class BookRecipeDraft {
  BookRecipeDraft({
    required this.recipe,
    required this.source,
    required this.startPage,
    required this.endPage,
    this.pageLabel,
    this.titleFound = true,
  });

  final ImportedRecipe recipe;

  /// The recognized lines this recipe was built from, in reading order.
  List<SourceLine> source;

  /// First and last scanned page (indices into the scan) the recipe sits on.
  int startPage;
  int endPage;

  /// The printed page number(s), "142" or "142-143". Null when unknown.
  String? pageLabel;

  /// False when no title could be read and a placeholder is shown instead.
  bool titleFound;

  List<BookDraftIssue> get issues => [
        if (!titleFound || recipe.title.trim().isEmpty) BookDraftIssue.noTitle,
        if (recipe.ingredients.where((i) => !isSectionHeading(i)).isEmpty)
          BookDraftIssue.noIngredients,
        if (recipe.instructions.where((s) => !isSectionHeading(s)).isEmpty)
          BookDraftIssue.noSteps,
      ];

  int get ingredientCount =>
      recipe.ingredients.where((i) => !isSectionHeading(i)).length;

  int get stepCount =>
      recipe.instructions.where((s) => !isSectionHeading(s)).length;
}

/// The result of splitting one scan.
class BookSplitResult {
  final List<BookRecipeDraft> drafts;

  /// The page number for each scanned page (printed, typed in, or worked out
  /// from its neighbours). Null where nothing is known.
  final List<int?> pageNumbers;

  /// How many printed pages each photo shows: 2 for a spread, otherwise 1.
  final List<int> pageSpans;

  /// Lines that did not end up in any recipe: the tail of a recipe whose
  /// first page was not scanned, a contents page, a chapter introduction.
  final int unassignedLines;

  const BookSplitResult({
    required this.drafts,
    required this.pageNumbers,
    this.pageSpans = const [],
    this.unassignedLines = 0,
  });
}

/// An ingredient or step written as "For the sauce:" is a section heading, not
/// an item. The review screen shows it as typed and the saver stores it as a
/// heading row.
bool isSectionHeading(String line) {
  final t = line.trim();
  if (t.length < 2 || !t.endsWith(':')) return false;
  if (BookPageSplitter._startsWithQuantity(t)) return false;
  return t.length <= 48 && !RegExp(r'[.!?]').hasMatch(t.substring(0, t.length - 1));
}

/// Heading text without its trailing colon.
String sectionHeadingTitle(String line) {
  final t = line.trim();
  return t.endsWith(':') ? t.substring(0, t.length - 1).trim() : t;
}

class BookPageSplitter {
  BookPageSplitter._();

  /// Placeholder title for a recipe whose title could not be read. The UI
  /// replaces it with a translated label.
  static const untitled = 'Untitled recipe';

  // ───────────────────────── public API ─────────────────────────

  /// Splits [pages] into recipe drafts.
  ///
  /// [firstPageNumber] is the printed number of the first scanned page when the
  /// user supplied it; printed numbers read from the pages take precedence for
  /// the pages they were found on.
  ///
  /// [pageOffset] is added to every page index in the returned drafts, for a
  /// batch of pages appended to an existing scan. [BookSplitResult.pageNumbers]
  /// and [BookSplitResult.pageSpans] still describe only [pages].
  ///
  /// [photoPages] are the indices of pages known to be mostly photograph. The
  /// few words on such a page are a caption, not part of a method.
  static BookSplitResult split(
    List<PageText> pages, {
    int? firstPageNumber,
    int pageOffset = 0,
    Set<int> photoPages = const {},
  }) {
    final prepared = _prepare(pages, firstPageNumber: firstPageNumber);
    final lines = prepared.lines;
    final drafts = <BookRecipeDraft>[];
    var unassigned = 0;
    final captions = _captionPages(lines, photoPages);

    void add(List<SourceLine> region, int titleLines) {
      if (region.isEmpty) return;
      final draft = _draftFor(region, prepared.pageNumbers, titleLines: titleLines);
      // A title with nothing under it (a contents page, a chapter opener, an
      // essay) is not a recipe.
      if (draft.ingredientCount == 0 && draft.stepCount == 0) {
        unassigned += region.length;
        return;
      }
      drafts.add(draft);
    }

    if (lines.isNotEmpty) {
      final runs = _findRuns(lines);
      if (runs.isEmpty) {
        // No ingredient list anywhere: keep what reads as a method so nothing
        // that was photographed is silently lost.
        final dropped = _captionLines(captions, const [], keepFirstLine: true);
        unassigned += dropped.length;
        final kept = [
          for (var i = 0; i < lines.length; i++)
            if (!dropped.contains(i)) lines[i],
        ];
        add(kept, _leadingTitleLines(kept));
      } else {
        final starts = _recipeStarts(lines, runs, captionPages: captions.keys.toSet());
        final dropped = _captionLines(captions, starts);
        unassigned += starts.first.start;
        for (var r = 0; r < starts.length; r++) {
          final from = starts[r].start;
          final to = r + 1 < starts.length ? starts[r + 1].start : lines.length;
          final region = <SourceLine>[];
          for (var i = from; i < to; i++) {
            if (dropped.contains(i)) {
              unassigned++;
            } else {
              region.add(lines[i]);
            }
          }
          add(region, starts[r].titleLines);
        }
      }
    }

    if (pageOffset != 0) {
      for (final d in drafts) {
        d.source = [for (final l in d.source) l.onPage(pageOffset)];
        d.startPage += pageOffset;
        d.endPage += pageOffset;
      }
    }

    return BookSplitResult(
      drafts: drafts,
      pageNumbers: prepared.pageNumbers,
      pageSpans: prepared.pageSpans,
      unassignedLines: unassigned,
    );
  }

  /// Page numbers for a scan whose pages are consecutive, starting at [first].
  /// Used when the user types the number of the first page.
  static List<int?> consecutivePageNumbers(int first, List<int> pageSpans) {
    final out = <int?>[];
    var n = first;
    for (final span in pageSpans) {
      out.add(n);
      n += span;
    }
    return out;
  }

  /// Joins [second] onto the end of [first]. The second recipe's title becomes
  /// a section heading when it brought its own ingredients, since the usual
  /// reason to merge is a component ("Lemon Icing") that was read as a recipe.
  static BookRecipeDraft merge(BookRecipeDraft first, BookRecipeDraft second) {
    final a = first.recipe;
    final b = second.recipe;
    final heading = second.titleFound && b.title.trim().isNotEmpty ? '${b.title.trim()}:' : null;
    final bHasIngredients = b.ingredients.any((i) => !isSectionHeading(i));
    final bHasSteps = b.instructions.any((s) => !isSectionHeading(s));

    final ingredients = [
      ...a.ingredients,
      if (heading != null && bHasIngredients) heading,
      ...b.ingredients,
    ];
    final instructions = [
      ...a.instructions,
      if (heading != null && bHasIngredients && bHasSteps) heading,
      ...b.instructions,
    ];
    final notes = [a.notes, b.notes].where((n) => n != null && n.trim().isNotEmpty).join('\n\n');
    final description = (a.description?.trim().isNotEmpty ?? false) ? a.description : b.description;

    final merged = ImportedRecipe(
      title: first.titleFound ? a.title : (second.titleFound ? b.title : a.title),
      description: description,
      servings: a.servings ?? b.servings,
      prepTimeMinutes: a.prepTimeMinutes ?? b.prepTimeMinutes,
      cookTimeMinutes: a.cookTimeMinutes ?? b.cookTimeMinutes,
      ingredients: ingredients,
      instructions: instructions,
      notes: notes.isEmpty ? null : notes,
      suggestedCourse: a.suggestedCourse ?? b.suggestedCourse,
      suggestedCategory: a.suggestedCategory ?? b.suggestedCategory,
      imagePath: a.imagePath ?? b.imagePath,
      sourceUrl: a.sourceUrl ?? b.sourceUrl,
    );

    final startPage = first.startPage < second.startPage ? first.startPage : second.startPage;
    final endPage = first.endPage > second.endPage ? first.endPage : second.endPage;

    return BookRecipeDraft(
      recipe: merged,
      source: [...first.source, ...second.source],
      startPage: startPage,
      endPage: endPage,
      pageLabel: _mergeLabels(first.pageLabel, second.pageLabel),
      titleFound: first.titleFound || second.titleFound,
    );
  }

  /// Cuts [draft] in two at [lineIndex] (an index into [BookRecipeDraft.source]);
  /// that line becomes the first line of the second recipe. Both halves are
  /// read again from the recognized text. Returns null when the cut would
  /// leave either half empty.
  static (BookRecipeDraft, BookRecipeDraft)? splitAt(
    BookRecipeDraft draft,
    int lineIndex,
    List<int?> pageNumbers,
  ) {
    if (lineIndex <= 0 || lineIndex >= draft.source.length) return null;
    final head = draft.source.sublist(0, lineIndex);
    final tail = draft.source.sublist(lineIndex);

    final headHasTitleLine =
        draft.titleFound && _looksLikeTitle(head.first.text) && !_isStrongIngredient(head.first.text);
    final first = _draftFor(
      head,
      pageNumbers,
      titleLines: headHasTitleLine ? _titleSpan(head, 0) : 0,
    );
    if (draft.titleFound) {
      first.recipe.title = draft.recipe.title;
      first.titleFound = true;
    }

    final tailTitle = _looksLikeTitle(tail.first.text) || tail.first.text.trim().split(RegExp(r'\s+')).length <= 8;
    final second = _draftFor(
      tail,
      pageNumbers,
      titleLines: tailTitle && !_isStrongIngredient(tail.first.text) ? _titleSpan(tail, 0) : 0,
    );
    return (first, second);
  }

  /// The "142" / "142-143" label for the pages [source] sits on, or null when
  /// the page numbers are unknown.
  static String? pageLabelOf(List<SourceLine> source, List<int?> pageNumbers) {
    if (source.isEmpty) return null;
    int? at(SourceLine l) {
      if (l.page < 0 || l.page >= pageNumbers.length) return null;
      final n = pageNumbers[l.page];
      return n == null ? null : n + l.pageOffset;
    }

    final a = at(source.first);
    final b = at(source.last);
    if (a == null) return null;
    if (b == null || b <= a) return '$a';
    return '$a-$b';
  }

  // ───────────────────── page preparation ─────────────────────

  static _Prepared _prepare(List<PageText> pages, {int? firstPageNumber}) {
    // 1. Per page: which lines sit at the very top or bottom (candidates for
    //    page numbers and running headers).
    final edgeIdx = <List<int>>[];
    final located = <bool>[];
    for (final page in pages) {
      located.add(_hasGeometry(page));
      edgeIdx.add(_edgeLines(page));
    }

    // 2. Running headers: the same short text at the edge of several pages.
    //    When the scan carries no positions, the first and last line of a page
    //    are usually real content, so a header must also carry a page number
    //    ("142 SOUPS") to count.
    final seen = <String, int>{};
    for (var p = 0; p < pages.length; p++) {
      final keys = <String>{};
      for (final i in edgeIdx[p]) {
        final text = pages[p].lines[i].text;
        if (!located[p] && _folioInText(text) == null) continue;
        final key = _runningKey(text);
        if (key != null) keys.add(key);
      }
      for (final k in keys) {
        seen[k] = (seen[k] ?? 0) + 1;
      }
    }
    final running = <String>{
      for (final e in seen.entries)
        if (e.value >= 2 && pages.length >= 2) e.key,
    };

    // 3. Strip page furniture and read printed page numbers.
    final detected = List<int?>.filled(pages.length, null);
    final spans = List<int>.filled(pages.length, 1);
    final kept = <List<PageLine>>[];
    for (var p = 0; p < pages.length; p++) {
      final page = pages[p];
      final drop = <int>{};
      final folios = <({int number, double? x})>[];
      for (final i in edgeIdx[p]) {
        final text = page.lines[i].text.trim();
        final bare = _bareFolio.firstMatch(text);
        if (bare != null) {
          final n = int.tryParse(bare.group(1)!);
          if (n != null) {
            final l = page.lines[i];
            folios.add((number: n, x: l.hasBox ? (l.left! + l.right!) / 2 : null));
          }
          drop.add(i);
          continue;
        }
        final key = _runningKey(text);
        if (key != null && running.contains(key) && (located[p] || _folioInText(text) != null)) {
          final n = _folioInText(text);
          if (n != null) detected[p] ??= n;
          drop.add(i);
        }
      }
      if (folios.isNotEmpty) {
        folios.sort((a, b) => a.number.compareTo(b.number));
        detected[p] ??= folios.first.number;
        // Two consecutive numbers, one in each half: the photo is a spread.
        final w = page.width;
        if (folios.length >= 2 && w != null && w > 0) {
          final lo = folios.first;
          final hi = folios.last;
          if (hi.number == lo.number + 1 && lo.x != null && hi.x != null && lo.x! < w / 2 && hi.x! > w / 2) {
            detected[p] = lo.number;
            spans[p] = 2;
          }
        }
      }
      kept.add([
        for (var i = 0; i < page.lines.length; i++)
          if (!drop.contains(i) && page.lines[i].text.trim().isNotEmpty) page.lines[i],
      ]);
    }

    final pageNumbers = _resolvePageNumbers(detected, firstPageNumber, spans);

    // 4. Flatten, tagging each line with its page and paragraph.
    final out = <SourceLine>[];
    var blockBase = 0;
    for (var p = 0; p < kept.length; p++) {
      final lines = kept[p];
      final median = _medianHeight(lines);
      int? lastBlock;
      var maxBlock = 0;
      final half = (pages[p].width ?? 0) / 2;
      for (final l in lines) {
        final text = _clean(l.text);
        if (text.isEmpty || _isNoise(text)) continue;
        final start = lastBlock == null || l.block != lastBlock;
        lastBlock = l.block;
        if (l.block > maxBlock) maxBlock = l.block;
        final h = l.height;
        out.add(SourceLine(
          text,
          page: p,
          block: blockBase + l.block,
          paragraphStart: start,
          relHeight: (h != null && median != null && median > 0) ? h / median : null,
          left: l.left,
          right: l.right,
          height: h,
          pageOffset: spans[p] == 2 && l.left != null && l.left! >= half ? 1 : 0,
        ));
      }
      blockBase += maxBlock + 1;
    }
    return _Prepared(out, pageNumbers, spans);
  }

  /// Specks and stray marks: a line with nothing to read in it. A lone number
  /// is kept, because it may be a step number set in the margin.
  static bool _isNoise(String text) {
    final t = text.trim();
    final alnum = t.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ0-9]'), '');
    if (alnum.isEmpty) return true;
    if (RegExp(r'^\d{1,2}[.)]?$').hasMatch(t)) return false;
    if (alnum.length <= 2 && !RegExp(r'\d').hasMatch(alnum)) {
      return !RegExp(r'^(?:or|OR|Or)$').hasMatch(t);
    }
    return false;
  }

  static bool _hasGeometry(PageText page) {
    final h = page.height;
    return h != null && h > 0 && page.lines.isNotEmpty && page.lines.every((l) => l.hasBox);
  }

  /// Indices of the lines that sit in the top or bottom margin of [page].
  static List<int> _edgeLines(PageText page) {
    final n = page.lines.length;
    if (n == 0) return const [];
    final out = <int>[];
    if (_hasGeometry(page)) {
      final h = page.height!;
      for (var i = 0; i < n; i++) {
        final y = page.lines[i].centerY! / h;
        if (y < 0.085 || y > 0.915) out.add(i);
      }
      return out;
    }
    // No geometry: the first and last line are the only safe guesses.
    out.add(0);
    if (n > 1) out.add(n - 1);
    return out;
  }

  static final RegExp _bareFolio = RegExp(r'^[^\w]{0,3}(\d{1,4})[^\w]{0,3}$');

  /// A printed page number sitting beside a running header ("142 SOUPS").
  static int? _folioInText(String text) {
    final lead = RegExp(r'^(\d{1,4})\b').firstMatch(text.trim());
    if (lead != null) return int.tryParse(lead.group(1)!);
    final trail = RegExp(r'\b(\d{1,4})$').firstMatch(text.trim());
    if (trail != null) return int.tryParse(trail.group(1)!);
    return null;
  }

  /// Normalised text used to spot the same header on several pages, or null
  /// when the line could not be a running header.
  static String? _runningKey(String text) {
    final t = text.trim();
    if (t.length > 48 || _wordCount(t) > 7) return null;
    if (RegExp(r'[.!?]$').hasMatch(t)) return null;
    if (_isIngredientHeader(t) || _isMethodHeader(t) || _isNotesHeader(t)) return null;
    if (_parseMeta(t) != null) return null;
    final key = t.toLowerCase().replaceAll(RegExp(r'[\d\W_]+'), ' ').trim();
    if (key.length < 3) return null;
    return key;
  }

  static double? _medianHeight(List<PageLine> lines) {
    final hs = [
      for (final l in lines)
        if (l.height != null && l.height! > 0) l.height!,
    ]..sort();
    if (hs.isEmpty) return null;
    return hs[hs.length ~/ 2];
  }

  /// Works out a page number for every scanned page from the printed numbers
  /// that could be read.
  static List<int?> _resolvePageNumbers(List<int?> detected, int? firstPageNumber, List<int> spans) {
    final n = detected.length;
    final known = List<int?>.from(detected);
    // Position of each photo counted in printed pages, so a spread counts
    // for two.
    final pos = List<int>.filled(n, 0);
    for (var i = 1; i < n; i++) {
      pos[i] = pos[i - 1] + spans[i - 1];
    }

    // A misread number breaks the run. Readings that agree on "printed number
    // minus position" outvote one that is out of order.
    final idx = [for (var i = 0; i < n; i++) if (known[i] != null) i];
    if (idx.length >= 3) {
      final votes = <int, int>{};
      for (final i in idx) {
        votes[known[i]! - pos[i]] = (votes[known[i]! - pos[i]] ?? 0) + 1;
      }
      final best = votes.entries.reduce((a, b) => a.value >= b.value ? a : b);
      if (best.value >= 2) {
        for (var k = 0; k < idx.length; k++) {
          final i = idx[k];
          if (known[i] == null || known[i]! - pos[i] == best.key) continue;
          int? prev;
          for (var j = k - 1; j >= 0; j--) {
            if (known[idx[j]] != null) {
              prev = known[idx[j]];
              break;
            }
          }
          int? next;
          for (var j = k + 1; j < idx.length; j++) {
            if (known[idx[j]] != null) {
              next = known[idx[j]];
              break;
            }
          }
          final outOfOrder = (prev != null && known[i]! <= prev) || (next != null && known[i]! >= next);
          if (outOfOrder) known[i] = null;
        }
      }
    }

    if (firstPageNumber != null && n > 0 && known[0] == null) {
      known[0] = firstPageNumber;
    }

    final out = List<int?>.filled(n, null);
    for (var i = 0; i < n; i++) {
      if (known[i] != null) {
        out[i] = known[i];
        continue;
      }
      int? before;
      for (var j = i - 1; j >= 0; j--) {
        if (known[j] != null) {
          before = j;
          break;
        }
      }
      int? after;
      for (var j = i + 1; j < n; j++) {
        if (known[j] != null) {
          after = j;
          break;
        }
      }
      if (before != null) {
        var guess = known[before]! + (pos[i] - pos[before]);
        if (after != null && guess >= known[after]!) {
          guess = known[after]! - (pos[after] - pos[i]);
          if (guess <= known[before]!) guess = known[before]!;
        }
        out[i] = guess;
      } else if (after != null) {
        final guess = known[after]! - (pos[after] - pos[i]);
        out[i] = guess > 0 ? guess : null;
      }
    }
    return out;
  }

  /// Tidies one recognized line: bullets, odd spacing, look-alike characters.
  static String _clean(String raw) {
    var t = raw.replaceAll(' ', ' ').trim();
    t = t.replaceFirst(RegExp(r'^[•·▪■●○□☐◦‣⁃*»›]+\s*'), '');
    t = t.replaceFirst(RegExp(r'^[-–—]\s+(?=\S)'), '');
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    // Recognition often reads the fraction slash as a plain one with spaces.
    t = t.replaceAllMapped(RegExp(r'\b(\d)\s*/\s*(\d)\b'), (m) => '${m[1]}/${m[2]}');
    return t.trim();
  }

  // ───────────────────── caption pages ─────────────────────

  /// Words a photograph's caption uses to point at its recipe.
  static final RegExp _captionMarker = RegExp(
    r"\b(?:pictured|photograph(?:ed)?|opposite|overleaf|(?:previous|following|facing)\s+page|"
    r"(?:see|recipe(?:\s+on)?|on)\s+(?:page|p\.)\s*\d|pages?\s+\d{1,4}|pp?\.\s?\d{1,4}|"
    r"clockwise|from\s+(?:the\s+)?(?:left|top)|left\s+to\s+right|top\s+to\s+bottom)\b",
    caseSensitive: false,
  );

  /// Pages that carry only a caption: a full-page photograph facing its
  /// recipe, or a chapter opener. Maps the page index to its line indices.
  ///
  /// Their words would otherwise be glued onto the end of the recipe before
  /// them. A page stays out of this when anything on it reads as part of a
  /// recipe (an amount, a step, a yield) or carries on the method from the
  /// page before.
  static Map<int, List<int>> _captionPages(List<SourceLine> lines, Set<int> photoPages) {
    final byPage = <int, List<int>>{};
    for (var i = 0; i < lines.length; i++) {
      byPage.putIfAbsent(lines[i].page, () => <int>[]).add(i);
    }

    final out = <int, List<int>>{};
    byPage.forEach((page, idx) {
      if (idx.length > 3) return;
      var chars = 0;
      for (final i in idx) {
        chars += lines[i].text.length;
      }
      if (chars > 160) return;

      var marked = false;
      var prose = false;
      var instruction = false;
      for (final i in idx) {
        final t = lines[i].text;
        if (_isStrongIngredient(t) ||
            _isNumberedStep(t) ||
            _parseMeta(t) != null ||
            _isIngredientHeader(t) ||
            _isMethodHeader(t) ||
            _isNotesHeader(t) ||
            _isComponentHeader(t) ||
            _inlineNote.hasMatch(t) ||
            _inlineIngredients.hasMatch(t)) {
          return;
        }
        if (_captionMarker.hasMatch(t)) marked = true;
        if (_isProse(t)) prose = true;
        if (_startsLikeInstruction(t)) instruction = true;
      }
      if (marked) {
        out[page] = idx;
        return;
      }

      // The tail of a sentence begun on the page before.
      final first = idx.first;
      if (first > 0 && !_endsSentence(lines[first - 1].text) && !_startsUpper(lines[first].text)) return;
      // "Serve warm with cream" is the last line of a method.
      if (instruction) return;
      // Without a photograph to go by, a whole sentence is more likely a note.
      if (prose && !photoPages.contains(page)) return;
      out[page] = idx;
    });
    return out;
  }

  /// The lines to leave out of every recipe: caption pages, except one whose
  /// words were chosen as a recipe's title (a title printed on the photograph
  /// that faces its recipe).
  static Set<int> _captionLines(
    Map<int, List<int>> captions,
    List<_Start> starts, {
    bool keepFirstLine = false,
  }) {
    final titles = <int>{
      for (final s in starts)
        for (var k = 0; k < (s.titleLines < 1 ? 1 : s.titleLines); k++) s.start + k,
      if (keepFirstLine) 0,
    };
    final out = <int>{};
    for (final idx in captions.values) {
      if (idx.any(titles.contains)) continue;
      out.addAll(idx);
    }
    return out;
  }

  // ───────────────────── line classification ─────────────────────

  static final RegExp _ingredientHeader = RegExp(
    r"^(?:the\s+)?(?:ingredients?|what\s+you(?:'ll|’ll|\s+will)?\s+need|you(?:'ll|’ll|\s+will)\s+need|shopping\s+list)\b[^.!?]{0,30}:?$",
    caseSensitive: false,
  );

  static final RegExp _methodHeader = RegExp(
    r"^(?:the\s+)?(?:method|directions?|instructions?|preparation|procedure|steps?|how\s+to\s+make(?:\s+it)?|to\s+make|to\s+prepare|what\s+to\s+do|cooking\s+instructions?)\s*:?$",
    caseSensitive: false,
  );

  static final RegExp _notesHeader = RegExp(
    r"^(?:(?:cook|chef|baker)(?:'|’)?s?(?:'|’)?\s+|recipe\s+|kitchen\s+)?(?:notes?|tips?|variations?|hints?)\s*:?$"
    r"|^(?:to\s+store|storage|storing|make[\s-]ahead|get\s+ahead|freezing|to\s+freeze|substitutions?|serving\s+suggestions?)\s*:?$",
    caseSensitive: false,
  );

  static final RegExp _inlineNote = RegExp(
    r"^(?:(?:cook|chef|baker)(?:'|’)?s?(?:'|’)?\s+)?(?:notes?|tips?|variations?|hints?|make[\s-]ahead|to\s+store|storage)\s*[:\-–]\s+(\S.+)$",
    caseSensitive: false,
  );

  static final RegExp _componentHeader = RegExp(
    r"^(?:for|to)\s+(?:the\s+|a\s+|an\s+)?[a-z][a-z ,&'’/-]{1,34}:?$",
    caseSensitive: false,
  );

  static final RegExp _colonHeader = RegExp(r"^[A-Za-z][A-Za-z '’&/-]{1,34}:$");

  /// "Ingredients: 50 g basil, 30 g pine nuts, ..." set as a paragraph.
  static final RegExp _inlineIngredients = RegExp(
    r"^ingredients?\s*[:\-–]\s*(\S.*)$",
    caseSensitive: false,
  );

  static final RegExp _prepNote = RegExp(
    r"^(?:(?:very\s+)?(?:finely|roughly|thinly|coarsely|freshly|lightly)\s+)?"
    r"(?:chopped|sliced|diced|minced|grated|peeled|crushed|cubed|halved|quartered|shredded|trimmed|drained|rinsed|beaten|melted|softened|toasted|zested|juiced|cored|seeded|deseeded|optional|to\s+taste|to\s+serve|for\s+frying|at\s+room\s+temperature)\b",
    caseSensitive: false,
  );

  /// Splits a run-in ingredient paragraph into its items.
  static List<String> _splitInlineIngredients(String text) {
    final pieces = <String>[];
    final buf = StringBuffer();
    var depth = 0;
    for (final ch in text.split('')) {
      if (ch == '(') depth++;
      if (ch == ')' && depth > 0) depth--;
      if ((ch == ',' || ch == ';') && depth == 0) {
        pieces.add(buf.toString());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    pieces.add(buf.toString());

    final out = <String>[];
    for (var piece in pieces) {
      piece = piece.trim().replaceFirst(RegExp(r'^and\s+', caseSensitive: false), '');
      piece = piece.replaceFirst(RegExp(r'[.\s]+$'), '');
      if (piece.length < 2) continue;
      // "1 onion, finely chopped": the note belongs to the item before it.
      if (out.isNotEmpty && !_startsWithQuantity(piece) && _prepNote.hasMatch(piece)) {
        out[out.length - 1] = '${out.last}, $piece';
      } else {
        out.add(piece);
      }
    }
    return out;
  }

  static bool _isIngredientHeader(String t) => _ingredientHeader.hasMatch(t.trim());
  static bool _isMethodHeader(String t) => _methodHeader.hasMatch(t.trim());
  static bool _isNotesHeader(String t) => _notesHeader.hasMatch(t.trim());

  /// "For the sauce", "To serve", "Topping:" and similar component headings.
  static bool _isComponentHeader(String t) {
    final s = t.trim();
    if (s.length > 44) return false;
    if (_isIngredientHeader(s) || _isMethodHeader(s) || _isNotesHeader(s)) return false;
    if (_colonHeader.hasMatch(s)) return true;
    if (!_componentHeader.hasMatch(s)) return false;
    // "to taste", "for frying" are trailing ingredient notes, not headings.
    return !RegExp(r'^(?:to\s+taste|for\s+(?:frying|greasing|dusting|drizzling|brushing|deep[\s-]frying))$',
            caseSensitive: false)
        .hasMatch(s.replaceAll(':', ''));
  }

  static final RegExp _quantityStart = RegExp(
    r"^(?:\d|[½⅓⅔¼¾⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞]"
    r"|(?:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|half|several)\s"
    r"|(?:a|an)\s+(?:pinch|handful|dash|knob|splash|bunch|few|little|squeeze|drizzle|sprig|couple|good|generous|small|large|big|pat|slice|thumb|piece|can|tin|jar|packet|bag|cup|glass|quarter|half|dozen|scant|heaped|heaping)\b)",
    caseSensitive: false,
  );

  static bool _startsWithQuantity(String t) => _quantityStart.hasMatch(t.trim());

  static final RegExp _unit = RegExp(
    r"\d\s?(?:g|kg|mg|ml|l|dl|cl|oz|lb|lbs)\b"
    r"|\b(?:cups?|tablespoons?|tbsps?|tbs|tbl|teaspoons?|tsps?|fl\.?\s?oz|ounces?|pounds?|grams?|kilos?|kilograms?|millilit(?:er|re)s?|lit(?:er|re)s?|pints?|quarts?|gallons?|sticks?|cloves?|pinch(?:es)?|dash(?:es)?|bunch(?:es)?|sprigs?|slices?|cans?|tins?|jars?|packets?|packages?|handfuls?|heads?|stalks?|rashers?|fillets?)\b",
    caseSensitive: false,
  );

  /// Unquantified ingredients that still read as list items ("sea salt").
  static final RegExp _pantryLead = RegExp(
    r"^(?:(?:sea|kosher|flaky|table|coarse|fine)\s+)?salt\b"
    r"|^(?:freshly\s+|fresh\s+)?(?:ground\s+|cracked\s+)?(?:black\s+|white\s+)?pepper\b"
    r"|^(?:(?:extra[\s-]virgin\s+)?olive|vegetable|sunflower|rapeseed|canola|coconut|sesame|groundnut|neutral|cooking)\s+oil\b"
    r"|^oil\b|^butter\b|^(?:ice\s+)?water\b|^ice\b|^(?:the\s+)?(?:juice|zest|grated\s+zest)\s+of\b"
    r"|^(?:pinch|handful|knob|splash|dash|squeeze|drizzle|sprig|bunch)\s+of\b"
    r"|^(?:cooking|nonstick|non-stick)\s+spray\b",
    caseSensitive: false,
  );

  /// "... to serve", "... for dusting": how books mark an optional extra.
  static final RegExp _pantryTail = RegExp(
    r"\bto\s+(?:serve|garnish|taste|finish|decorate)$"
    r"|\bfor\s+(?:dusting|frying|greasing|serving|drizzling|garnish|brushing|sprinkling|the\s+pan)$",
    caseSensitive: false,
  );

  static final RegExp _cookingWords = RegExp(
    r"\b(?:minutes?|mins|hours?|hrs|until|preheat|meanwhile)\b|°",
    caseSensitive: false,
  );

  /// "Fat 12g", "320 kcal", "30 g protein": a nutrition panel, which looks a
  /// lot like an ingredient list.
  static final RegExp _nutrition = RegExp(
    r"\b(?:calories|kcal|energy|protein|carb(?:ohydrate)?s?|saturate[sd]?|fibre|fiber|sodium|cholesterol|fat|sugars)\b\s*:?\s*\d"
    r"|\d\s?(?:kcal|kj|calories|cals?)\b"
    r"|^\d+(?:[.,]\d+)?\s?m?g\s+(?:of\s+)?(?:protein|carb(?:ohydrate)?s?|fat|saturate[sd]?(?:\s+fat)?|fibre|fiber|sodium|cholesterol)\b"
    r"|^(?:nutrition(?:al)?(?:\s+(?:information|info|facts))?|per\s+serving)\b",
    caseSensitive: false,
  );

  static bool _isNutrition(String t) => _nutrition.hasMatch(t.trim());

  static int _wordCount(String t) => t.trim().isEmpty ? 0 : t.trim().split(RegExp(r'\s+')).length;

  static bool _endsSentence(String t) => RegExp(r'[.!?]["”’)]?$').hasMatch(t.trim());

  /// Running text: a sentence or a wrapped line of one.
  static bool _isProse(String t) {
    final s = t.trim();
    final words = _wordCount(s);
    if (s.length >= 64) return true;
    if (words >= 7 && _endsSentence(s)) return true;
    if (RegExp(r'[a-z]{3,}[.!?]\s+[A-Z]').hasMatch(s)) return true;
    return false;
  }

  /// A line that is clearly an ingredient: it leads with an amount.
  static bool _isStrongIngredient(String t) {
    final s = t.trim();
    if (!_startsWithQuantity(s)) return false;
    if (s.length > 120) return false;
    if (_isNumberedStep(s)) return false;
    if (_parseMeta(s) != null) return false;
    if (_cookingWords.hasMatch(s) && !_unit.hasMatch(s)) return false;
    if (_isNutrition(s)) return false;
    if (_wordCount(s) >= 7 && _endsSentence(s) && !_unit.hasMatch(s)) return false;
    if (RegExp(r'^\d{1,4}$').hasMatch(s)) return false;
    return true;
  }

  /// A short line that could be an ingredient with no amount ("sea salt").
  static bool _isWeakIngredient(String t) {
    final s = t.trim();
    if (s.length < 2 || s.length > 72) return false;
    if (_wordCount(s) > 10) return false;
    if (_endsSentence(s)) return false;
    if (_isIngredientHeader(s) || _isMethodHeader(s) || _isNotesHeader(s)) return false;
    if (_parseMeta(s) != null) return false;
    if (_isNumberedStep(s)) return false;
    if (!RegExp(r'[A-Za-z]').hasMatch(s)) return false;
    if (_isShortInstruction(s)) return false;
    if (_isNutrition(s)) return false;
    // "Assemble", "To finish": a heading for the next part of the method.
    if (_wordCount(s) <= 2 && _startsWithVerb(s) && !_pantryLead.hasMatch(s)) return false;
    return true;
  }

  static bool _isPantry(String t) {
    final s = t.trim();
    if (_pantryLead.hasMatch(s)) return true;
    return _pantryTail.hasMatch(s) && !_isShortInstruction(s);
  }

  static final RegExp _afterVerb = RegExp(
    r"^(?:the|a|an|all|in|into|until|for|with|together|over|on|to|each|your|well|and|it|them|everything|\d)\b",
    caseSensitive: false,
  );

  /// A terse instruction with no full stop ("Mix all ingredients",
  /// "Bake 20 min"), as opposed to a short ingredient ("warm water").
  static bool _isShortInstruction(String t) {
    final s = t.trim();
    if (_pantryLead.hasMatch(s)) return false;
    final m = RegExp(r"^[^A-Za-zÀ-ÿ]*([A-Za-zÀ-ÿ]+)\s+(.*)$").firstMatch(s);
    if (m == null) return false;
    if (!_verbs.contains(m.group(1)!.toLowerCase())) return false;
    return _afterVerb.hasMatch(m.group(2)!.trim());
  }

  static const _verbs = <String>{
    'add', 'adjust', 'arrange', 'assemble', 'bake', 'baste', 'beat', 'blanch', 'blend', 'boil', 'braise',
    'bring', 'broil', 'brown', 'brush', 'butter', 'carve', 'check', 'chill', 'chop', 'coat',
    'combine', 'cook', 'cool', 'cover', 'cream', 'crush', 'cut', 'decorate', 'dice', 'dip',
    'discard', 'dissolve', 'divide', 'drain', 'drizzle', 'drop', 'dry', 'dust', 'fill', 'finish',
    'flip', 'fold', 'freeze', 'fry', 'garnish', 'glaze', 'grate', 'grease', 'grill',
    'grind', 'halve', 'heat', 'keep', 'knead', 'ladle', 'layer', 'leave', 'let',
    'line', 'make', 'marinate', 'mash', 'measure', 'melt', 'mince', 'mix', 'pat', 'peel',
    'place', 'poach', 'pour', 'preheat', 'prepare', 'press', 'process', 'pulse', 'purée', 'puree',
    'put', 'reduce', 'refrigerate', 'remove', 'repeat', 'rest', 'return', 'rinse', 'roast', 'roll',
    'rub', 'sauté', 'saute', 'scatter', 'scoop', 'scrape', 'sear', 'season', 'serve', 'set',
    'shake', 'shape', 'shred', 'sift', 'simmer', 'skim', 'slice', 'soak', 'spoon', 'spread',
    'sprinkle', 'squeeze', 'stand', 'steam', 'stir', 'strain', 'stuff', 'take', 'taste', 'thread',
    'tip', 'toast', 'top', 'toss', 'transfer', 'trim', 'turn', 'using', 'warm', 'wash', 'whip',
    'whisk', 'wipe', 'wrap',
  };

  static const _leadIns = <String>{
    'in', 'when', 'once', 'meanwhile', 'while', 'after', 'using', 'with', 'now', 'then', 'next',
    'finally', 'first', 'to', 'if', 'working', 'carefully', 'gradually', 'slowly', 'gently',
    'lightly', 'quickly',
  };

  static String _firstWord(String t) {
    final m = RegExp(r"^[^A-Za-zÀ-ÿ]*([A-Za-zÀ-ÿ]+)").firstMatch(t);
    return (m?.group(1) ?? '').toLowerCase();
  }

  static bool _startsWithVerb(String t) => _verbs.contains(_firstWord(t));

  static bool _startsLikeInstruction(String t) {
    final w = _firstWord(t);
    return _verbs.contains(w) || _leadIns.contains(w);
  }

  static final RegExp _stepPunct = RegExp(r'^(?:step\s*)?(\d{1,2})\s*[.):]\s*(?=[A-Za-zÀ-ÿ“"])', caseSensitive: false);
  static final RegExp _stepWord = RegExp(r'^step\s+(\d{1,2}|one|two|three|four|five|six|seven|eight|nine|ten)\b\s*[.):\-–]?\s*', caseSensitive: false);
  static final RegExp _stepBare = RegExp(r'^(\d{1,2})\s+(?=[A-ZÀ-Ý])');

  /// "1. Heat the oil", "2) Add", "Step 3: Stir", or "1 Heat the oil".
  static bool _isNumberedStep(String t) {
    final s = t.trim();
    if (_stepWord.hasMatch(s)) return true;
    if (_stepPunct.hasMatch(s)) {
      final rest = s.replaceFirst(_stepPunct, '');
      // "1. 2 cups flour" style numbered ingredient lists are not steps.
      return !_startsWithQuantity(rest) || _startsLikeInstruction(rest);
    }
    final bare = _stepBare.firstMatch(s);
    if (bare != null) {
      final rest = s.substring(bare.end);
      if (_unit.hasMatch(s.split(RegExp(r'\s+')).take(3).join(' '))) return false;
      return _startsLikeInstruction(rest) && (rest.length >= 18 || _endsSentence(rest));
    }
    return false;
  }

  static String _stripStepNumber(String t) {
    var s = t.trim();
    s = s.replaceFirst(_stepWord, '');
    s = s.replaceFirst(_stepPunct, '');
    final bare = _stepBare.firstMatch(s);
    if (bare != null && _startsLikeInstruction(s.substring(bare.end))) {
      s = s.substring(bare.end);
    }
    return s.trim();
  }

  /// Evidence that a line belongs to a method: a numbered step, running
  /// text, or a terse instruction ("Mix well.").
  static bool _isMethodText(String t) {
    if (_isNumberedStep(t) || _isMethodHeader(t) || _isProse(t)) return true;
    if (_isStrongIngredient(t) || _parseMeta(t) != null) return false;
    final words = _wordCount(t);
    if (_startsLikeInstruction(t) && (words >= 4 || (words >= 2 && _endsSentence(t)))) return true;
    return _endsSentence(t) && words >= 4;
  }

  static bool _isAllCaps(String t) {
    final letters = t.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ]'), '');
    return letters.length >= 3 && letters == letters.toUpperCase();
  }

  static bool _startsUpper(String t) {
    final first = RegExp(r'[A-Za-zÀ-ÿ]').firstMatch(t)?.group(0) ?? '';
    return first.isNotEmpty && first == first.toUpperCase() && first != first.toLowerCase();
  }

  static const _smallWords = <String>{
    'a', 'an', 'and', 'as', 'at', 'but', 'by', 'de', 'di', 'du', 'en', 'for', 'from', 'in',
    'la', 'le', 'of', 'on', 'or', 'the', 'to', 'with', 'al', 'alla', 'con', 'e', 'et', 'y',
    'au', 'aux', 'n',
  };

  static bool _isTitleCase(String t) {
    final words = t.trim().split(RegExp(r'\s+')).where((w) => RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(w)).toList();
    if (words.isEmpty) return false;
    var significant = 0;
    var capitalised = 0;
    for (var i = 0; i < words.length; i++) {
      final w = words[i].replaceAll(RegExp(r"^[^A-Za-zÀ-ÿ]+"), '');
      if (w.isEmpty) continue;
      if (i > 0 && _smallWords.contains(w.toLowerCase())) continue;
      significant++;
      if (w[0] == w[0].toUpperCase() && w[0] != w[0].toLowerCase()) capitalised++;
    }
    if (significant < 2) return false;
    return capitalised >= significant * 0.75;
  }

  /// Shaped like a recipe title: short, no sentence punctuation, starts with a
  /// capital, and not one of the things a recipe page is otherwise made of.
  static bool _looksLikeTitle(String t) {
    final s = t.trim();
    if (s.length < 3 || s.length > 72) return false;
    final words = _wordCount(s);
    if (words > 11) return false;
    if (RegExp(r'[.,;:]$').hasMatch(s)) return false;
    if (_startsWithQuantity(s)) return false;
    if (_isIngredientHeader(s) || _isMethodHeader(s) || _isNotesHeader(s)) return false;
    if (_isComponentHeader(s)) return false;
    if (_parseMeta(s) != null) return false;
    if (_isNumberedStep(s)) return false;
    final letters = s.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ]'), '').length;
    if (letters < s.replaceAll(' ', '').length * 0.7) return false;
    final first = RegExp(r'[A-Za-zÀ-ÿ]').firstMatch(s)?.group(0) ?? '';
    if (first.isEmpty || first != first.toUpperCase()) return false;
    if (RegExp(r'[a-z]{3,}[.!?]\s+[A-Z]').hasMatch(s)) return false;
    return true;
  }

  // ───────────────────────── metadata ─────────────────────────

  static final RegExp _yieldLead = RegExp(
    r"^(serves|serve|servings?|makes|yields?|yield|portions?|feeds)\b\s*:?\s*(?:about\s+|approx\.?\s+|approximately\s+|around\s+|up\s+to\s+)?(\d+(?:\s*(?:-|–|to)\s*\d+)?)(\s+[a-z][a-z -]{1,24})?",
    caseSensitive: false,
  );

  static final RegExp _yieldTrail = RegExp(
    r"^(\d+(?:\s*(?:-|–|to)\s*\d+)?)\s+(servings?|portions?)\b",
    caseSensitive: false,
  );

  static final RegExp _timeLabel = RegExp(
    r"\b(prep(?:aration)?|cook(?:ing)?|total|active|hands[\s-]on|ready\s+in|bak(?:e|ing)|chill(?:ing)?|rest(?:ing)?|marinat(?:e|ing)|stand(?:ing)?|freez(?:e|ing)|time)(?:\s+time)?\s*:?\s*(?:about\s+|approx\.?\s+|approximately\s+)?"
    r"((?:\d+(?:[.,]\d+)?\s?[½¼¾]?|[½¼¾])\s*(?:hours?|hrs?|h|minutes?|mins?|m)\b(?:\s*(?:and\s+)?\d+\s*(?:minutes?|mins?|m)\b)?)",
    caseSensitive: false,
  );

  static const _metaFiller = <String>{
    'plus', 'chilling', 'resting', 'marinating', 'overnight', 'soaking', 'cooling', 'standing',
    'freezing', 'setting', 'proving', 'rising', 'approx', 'about', 'time', 'each', 'per', 'batch',
    'inactive', 'total', 'active', 'and', 'at', 'least', 'optional',
  };

  /// Reads a yield / time line. Null unless the line is made of nothing else,
  /// so "Cook 20 minutes, stirring, until soft" stays a step.
  static _Meta? _parseMeta(String text) {
    final s = text.trim();
    if (s.length > 96) return null;
    var rest = s;
    String? servings;
    int? prep;
    int? cook;
    int? total;
    var yieldMatched = false;
    var timeMatched = false;

    final yl = _yieldLead.firstMatch(rest);
    if (yl != null) {
      final count = yl.group(2)!.replaceAll(RegExp(r'\s*(?:–|to)\s*'), '-').replaceAll(' ', '');
      final verb = yl.group(1)!.toLowerCase();
      final unit = (yl.group(3) ?? '').trim();
      // "Makes 12 cookies" keeps its unit; "Serves 4 as a starter" does not.
      final keepUnit = unit.isNotEmpty &&
          (verb.startsWith('make') || verb.startsWith('yield')) &&
          !RegExp(r'^(?:as|for|to|generously|people|servings?|portions?|prep|cook|total)\b', caseSensitive: false)
              .hasMatch(unit);
      servings = keepUnit ? '$count $unit' : count;
      // Leave anything after the count in place when it is not a unit, so a
      // time that follows on the same line is still read.
      final cut = keepUnit ? yl.end : yl.end - (yl.group(3)?.length ?? 0);
      rest = rest.replaceRange(yl.start, cut, ' ');
      yieldMatched = true;
    } else {
      final yt = _yieldTrail.firstMatch(rest);
      if (yt != null) {
        servings = yt.group(1)!.replaceAll(RegExp(r'\s*(?:–|to)\s*'), '-').replaceAll(' ', '');
        rest = rest.replaceRange(yt.start, yt.end, ' ');
        yieldMatched = true;
      }
    }

    final barLike = RegExp(r'[|·•]').hasMatch(s) || _isAllCaps(s);
    final times = _timeLabel.allMatches(rest).toList();
    bool isNounLabel(RegExpMatch m) {
      final l = m.group(1)!.toLowerCase();
      final raw = m.group(0)!.toLowerCase();
      return l.startsWith('prep') ||
          l.startsWith('total') ||
          l.startsWith('active') ||
          l.startsWith('hands') ||
          l.startsWith('ready') ||
          l.endsWith('ing') ||
          raw.contains('time') ||
          raw.contains(':');
    }

    final labelled = times.any(isNounLabel);
    // A time line starts with its label.
    if (times.isNotEmpty && !yieldMatched && times.first.start > 2) return null;

    for (final m in times.reversed) {
      final label = m.group(1)!.toLowerCase();
      final bareVerb =
          !isNounLabel(m) && RegExp(r'^(?:cook|bake|chill|rest|marinate|stand|freeze)$').hasMatch(label);
      // "Bake 25 minutes" on its own is an instruction, not a fact about the
      // recipe, unless it sits in a bar of other facts.
      if (bareVerb && !yieldMatched && !labelled && !barLike) return null;
      final minutes = _minutes(m.group(2)!);
      if (minutes == null) continue;
      if (label.startsWith('prep')) {
        prep = minutes;
      } else if (label.startsWith('cook') || label.startsWith('bak')) {
        cook = minutes;
      } else if (label.startsWith('total') || label.startsWith('ready') || label == 'time') {
        total = minutes;
      } else if (label.startsWith('active') || label.startsWith('hands')) {
        prep ??= minutes;
      }
      rest = rest.replaceRange(m.start, m.end, ' ');
      timeMatched = true;
    }

    if (!yieldMatched && !timeMatched) return null;
    final leftover = rest
        .toLowerCase()
        .split(RegExp(r'[^a-zà-ÿ]+'))
        .where((w) => w.length > 1 && !_metaFiller.contains(w))
        .toList();
    if (yieldMatched) {
      // A line that opens with its yield is a yield line even with a tail
      // ("Serves 4 (or 2 very hungry people)"), as long as it is not prose.
      if (leftover.length > 6 || (_endsSentence(s) && leftover.length > 3)) return null;
    } else if (leftover.isNotEmpty) {
      return null;
    }
    return _Meta(servings: servings, prep: prep, cook: cook, total: total);
  }

  static int? _minutes(String text) {
    var s = text.toLowerCase().replaceAll(',', '.');
    s = s.replaceAll('½', '.5').replaceAll('¼', '.25').replaceAll('¾', '.75');
    s = s.replaceAllMapped(RegExp(r'(\d)\s+\.(\d)'), (m) => '${m[1]}.${m[2]}');
    var total = 0.0;
    var any = false;
    for (final m in RegExp(r'(\d*\.?\d+)\s*(hours?|hrs?|h|minutes?|mins?|m)\b').allMatches(s)) {
      final v = double.tryParse(m.group(1)!);
      if (v == null) continue;
      any = true;
      total += m.group(2)!.startsWith('h') ? v * 60 : v;
    }
    if (!any) return null;
    final r = total.round();
    return r > 0 && r <= 72 * 60 ? r : null;
  }

  // ───────────────────── ingredient runs ─────────────────────

  /// True when [i] is a later line of a prose paragraph, so it cannot be a
  /// title or the start of a list however it happens to begin.
  static bool _insideProse(List<SourceLine> lines, int i) {
    if (lines[i].paragraphStart) return false;
    var first = i;
    while (first > 0 && !lines[first].paragraphStart && lines[first - 1].block == lines[i].block) {
      first--;
    }
    if (first == i) return false;
    final head = lines[first].text;
    if (_isStrongIngredient(head)) return false;
    return _isProse(head) || (head.length >= 44 && _wordCount(head) >= 7);
  }

  /// Whether line [i] stops well short of the widest line of its paragraph,
  /// which is how a paragraph (or a one-line step) ends.
  static bool _endsEarly(List<SourceLine> lines, int i) {
    final block = lines[i].block;
    var from = i;
    while (from > 0 && lines[from - 1].block == block) {
      from--;
    }
    var to = i;
    while (to + 1 < lines.length && lines[to + 1].block == block) {
      to++;
    }
    double width(SourceLine l) =>
        (l.left != null && l.right != null) ? l.right! - l.left! : l.text.length.toDouble();
    var widest = 0.0;
    for (var k = from; k <= to; k++) {
      final w = width(lines[k]);
      if (w > widest) widest = w;
    }
    return widest > 0 && width(lines[i]) < widest * 0.85;
  }

  static bool _isTall(SourceLine l, [double ratio = 1.3]) =>
      l.relHeight != null && l.relHeight! >= ratio;

  static List<_Run> _findRuns(List<SourceLine> lines) {
    final runs = <_Run>[];
    final n = lines.length;
    var i = 0;
    while (i < n) {
      final text = lines[i].text;
      if (_inlineIngredients.hasMatch(text) && !_insideProse(lines, i)) {
        var end = i + 1;
        while (end < n && !lines[end].paragraphStart && lines[end].block == lines[i].block) {
          end++;
        }
        runs.add(_Run(i, end, hasHeader: true, inline: true));
        i = end;
        continue;
      }
      final header = _isIngredientHeader(text) && !_insideProse(lines, i);
      final strongStart = !header && _isStrongIngredient(text) && !_insideProse(lines, i);
      if (!header && !strongStart) {
        i++;
        continue;
      }

      var start = i;
      var k = header ? i + 1 : i;
      var strong = 0;
      var items = 0;
      var lastItem = header ? i : i - 1;

      while (k < n) {
        final t = lines[k].text;
        if (_isMethodHeader(t) || _isNotesHeader(t) || _inlineNote.hasMatch(t)) break;
        if (_isNumberedStep(t)) break;
        final prose = _insideProse(lines, k);
        if (!prose && _isStrongIngredient(t)) {
          strong++;
          items++;
          lastItem = k;
          k++;
          continue;
        }
        if (_parseMeta(t) != null || _isComponentHeader(t) || _isIngredientHeader(t)) {
          k++;
          continue;
        }
        // A wrapped tail of the previous ingredient.
        if (items > 0 && _continuesIngredient(lines, k)) {
          lastItem = k;
          k++;
          continue;
        }
        if (!prose && _isWeakIngredient(t) && !_isTall(lines[k]) && !_isProse(t)) {
          // Short, unpunctuated lines belong to the list once it has begun.
          if (items > 0 || header || _isPantry(t)) {
            items++;
            lastItem = k;
            k++;
            continue;
          }
        }
        break;
      }

      final end = lastItem + 1;
      final qualifies = (header && items >= 1) || strong >= 2 || (strong == 1 && items >= 3);
      if (qualifies) {
        if (!header) {
          // Pull in pantry lines that sit directly above the first amount.
          while (start > 0 &&
              _isPantry(lines[start - 1].text) &&
              _isWeakIngredient(lines[start - 1].text) &&
              !_insideProse(lines, start - 1) &&
              !_isTall(lines[start - 1]) &&
              !_isTitleCase(lines[start - 1].text) &&
              !_isAllCaps(lines[start - 1].text)) {
            start--;
          }
        }
        runs.add(_Run(start, end, hasHeader: header));
        i = end > i ? end : i + 1;
      } else {
        i++;
      }
    }
    return runs;
  }

  static final RegExp _trailingConnector = RegExp(
    r"(?:[,(/&-]|\b(?:and|or|plus|of|for|to|the|a|an|with|in|such\s+as|about))$",
    caseSensitive: false,
  );

  /// Whether line [k] is the wrapped remainder of the ingredient above it.
  static bool _continuesIngredient(List<SourceLine> lines, int k) {
    if (k == 0) return false;
    final cur = lines[k];
    final prev = lines[k - 1];
    final t = cur.text.trim();
    final p = prev.text.trim();
    if (_startsWithQuantity(t) || _isComponentHeader(t) || _parseMeta(t) != null) return false;
    if (_isIngredientHeader(p) || _isComponentHeader(p)) return false;
    if (_trailingConnector.hasMatch(p)) return true;
    if ('('.allMatches(p).length > ')'.allMatches(p).length) return true;
    final first = RegExp(r'[A-Za-zÀ-ÿ]').firstMatch(t)?.group(0) ?? '';
    final lower = first.isNotEmpty && first == first.toLowerCase();
    // A hanging indent is how books mark a wrapped ingredient.
    if (cur.left != null && prev.left != null && cur.height != null && lower) {
      if (cur.left! - prev.left! > cur.height! * 0.6) return true;
    }
    if (lower && _wordCount(t) <= 3 && p.length >= 30 && !_isPantry(t)) return true;
    return false;
  }

  // ───────────────────── recipe boundaries ─────────────────────

  static double _titleScore(List<SourceLine> lines, int i, int runStart) {
    final l = lines[i];
    final t = l.text.trim();
    var score = 0.0;

    if (_isAllCaps(t)) {
      score += 2;
    } else if (_isTitleCase(t)) {
      score += 1.5;
    }

    final rel = l.relHeight;
    if (rel != null) {
      if (rel >= 1.6) {
        score += 4;
      } else if (rel >= 1.3) {
        score += 3;
      } else if (rel >= 1.15) {
        score += 1.5;
      } else if (rel < 0.92) {
        score -= 0.5;
      }
    }

    final aloneInParagraph = l.paragraphStart &&
        (i + 1 >= lines.length || lines[i + 1].paragraphStart || lines[i + 1].block != l.block);
    if (aloneInParagraph) score += 1;

    final words = _wordCount(t);
    if (words >= 2 && words <= 7) score += 0.5;
    if (words == 1 && (rel == null || rel < 1.3)) score -= 0.75;
    if (RegExp(r'\d').hasMatch(t)) score -= 1;

    // What follows a title: a yield line, a headnote, or the list itself.
    var j = i + 1;
    while (j < runStart && j < lines.length && _looksLikeTitle(lines[j].text) && lines[j].block == l.block) {
      j++;
    }
    if (j < lines.length) {
      final next = lines[j].text;
      if (_parseMeta(next) != null) {
        score += 1.5;
      } else if (j >= runStart) {
        score += 1;
      } else if (_isProse(next) || lines[j].text.length >= 40) {
        score += 0.5;
      }
    }

    if (i == 0 || lines[i - 1].page != l.page) score += 1;
    return score;
  }

  /// How many lines, starting at [i], make up one title (a long title wraps).
  static int _titleSpan(List<SourceLine> lines, int i) {
    if (i + 1 >= lines.length) return 1;
    final a = lines[i];
    final b = lines[i + 1];
    if (b.block != a.block || b.paragraphStart) return 1;
    if (!_looksLikeTitle(b.text) && !(_wordCount(b.text) <= 6 && !_endsSentence(b.text) && !_startsWithQuantity(b.text))) {
      return 1;
    }
    if (_parseMeta(b.text) != null || _isIngredientHeader(b.text) || _isMethodHeader(b.text)) return 1;
    if (a.relHeight != null && b.relHeight != null) {
      final ratio = b.relHeight! / a.relHeight!;
      if (ratio < 0.8 || ratio > 1.25) return 1;
    }
    return 2;
  }

  /// For a scan with no ingredient list: does the first line read as a title?
  static int _leadingTitleLines(List<SourceLine> lines) {
    if (lines.isEmpty) return 0;
    final first = lines.first.text;
    if (!_looksLikeTitle(first) || _isStrongIngredient(first)) return 0;
    return _titleSpan(lines, 0);
  }

  static List<_Start> _recipeStarts(
    List<SourceLine> lines,
    List<_Run> runs, {
    Set<int> captionPages = const {},
  }) {
    final starts = <_Start>[];
    double? currentTitleHeight;

    for (var r = 0; r < runs.length; r++) {
      final run = runs[r];
      final gapFrom = r == 0 ? 0 : runs[r - 1].end;
      final gapTo = run.start;

      // Is there method text between the previous list and this one? If not,
      // this is another component of the same recipe ("For the sauce").
      var proseInGap = false;
      var lastProse = -1;
      for (var i = gapFrom; i < gapTo; i++) {
        final t = lines[i].text;
        if (_isMethodText(t)) {
          proseInGap = true;
          lastProse = i;
        }
      }
      if (r > 0 && !proseInGap) continue;

      // Title candidates in the gap.
      var best = -1;
      var bestScore = double.negativeInfinity;
      for (var i = gapFrom; i < gapTo; i++) {
        final t = lines[i].text;
        if (!_looksLikeTitle(t) || _insideProse(lines, i)) continue;
        if (_isStrongIngredient(t)) continue;
        var score = _titleScore(lines, i, gapTo);
        // A caption often repeats the title; the recipe's own heading wins
        // when it has one.
        if (captionPages.contains(lines[i].page)) score -= 1.5;
        if (score > bestScore || (score == bestScore && i > best)) {
          bestScore = score;
          best = i;
        }
      }

      // A sidebar layout prints the list before the title: look just after it.
      if (best < 0 || bestScore < _titleThreshold) {
        final limit = run.end + 3 < lines.length ? run.end + 3 : lines.length;
        for (var i = run.end; i < limit; i++) {
          final t = lines[i].text;
          if (_isProse(t) || _isNumberedStep(t) || _isMethodHeader(t)) break;
          if (_looksLikeTitle(t) && !_insideProse(lines, i) && (_isTall(lines[i]) || _isAllCaps(t))) {
            final score = _titleScore(lines, i, lines.length) + 1;
            if (score > bestScore) {
              bestScore = score;
              best = i;
            }
          }
        }
      }

      final hasTitle = best >= 0 && bestScore >= _titleThreshold;

      if (r > 0 && hasTitle && best < gapTo) {
        // A heading set clearly smaller than the recipe's own title, sitting
        // straight above the list, is a component heading.
        final h = lines[best].height;
        final directlyAbove = best == gapTo - 1 || (best == gapTo - 2 && _parseMeta(lines[gapTo - 1].text) == null);
        if (h != null && currentTitleHeight != null && h < currentTitleHeight * 0.8 && directlyAbove && !_isTall(lines[best])) {
          continue;
        }
      }

      if (r > 0 && !hasTitle) {
        // No title between the method and this list. A yield line or a new
        // page says "new recipe whose title could not be read"; otherwise it
        // is one more component of the recipe above.
        var metaAfterProse = false;
        for (var i = lastProse + 1; i < gapTo; i++) {
          if (_parseMeta(lines[i].text) != null) metaAfterProse = true;
        }
        final pageTurned = lastProse >= 0 && lines[lastProse].page != lines[run.start].page;
        final introduced = gapTo > 0 && _isComponentHeader(lines[gapTo - 1].text);
        if (introduced || (!metaAfterProse && !pageTurned && !run.hasHeader)) continue;

        var start = run.start;
        while (start - 1 > lastProse && start - 1 >= gapFrom && _parseMeta(lines[start - 1].text) != null) {
          start--;
        }
        starts.add(_Start(start, 0));
        currentTitleHeight = null;
        continue;
      }

      if (hasTitle) {
        if (best >= gapTo) {
          // Title printed after the list: the recipe starts at the list.
          starts.add(_Start(run.start, 0));
        } else {
          starts.add(_Start(best, _titleSpan(lines, best)));
        }
        currentTitleHeight = lines[best].height;
      } else {
        // First recipe with no readable title.
        var start = run.start;
        while (start > 0 && _parseMeta(lines[start - 1].text) != null) {
          start--;
        }
        starts.add(_Start(start, 0));
        currentTitleHeight = null;
      }
    }

    if (starts.isEmpty) starts.add(const _Start(0, 0));
    return starts;
  }

  static const double _titleThreshold = 2.0;

  // ───────────────────── structuring one recipe ─────────────────────

  static BookRecipeDraft _draftFor(
    List<SourceLine> region,
    List<int?> pageNumbers, {
    required int titleLines,
  }) {
    _Structured s;
    try {
      s = _structure(region, titleLines: titleLines);
    } catch (_) {
      // A recipe must never be lost to a parsing slip: keep the raw lines.
      s = _Structured(
        title: null,
        steps: [for (final l in region) l.text],
      );
    }

    final startPage = region.first.page;
    final endPage = region.last.page;
    final recipe = ImportedRecipe(
      title: s.title ?? untitled,
      description: s.description,
      servings: s.servings,
      prepTimeMinutes: s.prep,
      cookTimeMinutes: s.cook,
      ingredients: s.ingredients,
      instructions: s.steps,
      notes: s.notes,
      rawOcrText: region.map((l) => l.text).join('\n'),
    );

    return BookRecipeDraft(
      recipe: recipe,
      source: region,
      startPage: startPage,
      endPage: endPage,
      pageLabel: pageLabelOf(region, pageNumbers),
      titleFound: s.title != null,
    );
  }

  static _Structured _structure(List<SourceLine> lines, {required int titleLines}) {
    String? title;
    var i = 0;

    // A title printed after the list (sidebar layout) is lifted out below.
    int? lateTitle;
    final runs = _findRuns(lines);

    if (titleLines > 0) {
      title = _formatTitle(lines.take(titleLines).map((l) => l.text).join(' '));
      i = titleLines;
    } else if (runs.isNotEmpty) {
      final limit = runs.first.end + 3 < lines.length ? runs.first.end + 3 : lines.length;
      for (var k = runs.first.end; k < limit; k++) {
        final t = lines[k].text;
        if (_isProse(t) || _isNumberedStep(t) || _isMethodHeader(t)) break;
        if (_looksLikeTitle(t) && !_insideProse(lines, k) && (_isTall(lines[k]) || _isAllCaps(t))) {
          lateTitle = k;
          title = _formatTitle(t);
          break;
        }
      }
    }

    final runAt = <int, _Run>{for (final r in runs) r.start: r};

    final headnote = <String>[];
    final ingredients = <String>[];
    final steps = <String>[];
    final notes = <String>[];
    final nutrition = <String>[];
    String? servings;
    int? prep;
    int? cook;
    int? total;

    var state = _State.front;

    StringBuffer? step;
    var stepBlock = -1;
    StringBuffer? note;
    StringBuffer? para;
    var paraBlock = -1;
    String? pendingHeading;
    String? pendingStepHeading;
    var forceNewStep = false;

    void applyMeta(_Meta m) {
      servings = m.servings ?? servings;
      prep = m.prep ?? prep;
      cook = m.cook ?? cook;
      total = m.total ?? total;
    }

    void flushStep() {
      if (step != null) {
        final t = step.toString().trim();
        if (t.isNotEmpty) steps.add(t);
      }
      step = null;
    }

    void flushNote() {
      if (note != null) {
        final t = note.toString().trim();
        if (t.isNotEmpty) notes.add(t);
      }
      note = null;
    }

    void flushPara() {
      if (para != null) {
        final t = para.toString().trim();
        if (t.isNotEmpty) headnote.add(t);
      }
      para = null;
    }

    void append(StringBuffer buf, String text) {
      final cur = buf.toString();
      if (cur.isEmpty) {
        buf.write(text);
      } else if (cur.endsWith('-') && cur.length > 2 && RegExp(r'[a-zà-ÿ]-$').hasMatch(cur) && RegExp(r'^[a-zà-ÿ]').hasMatch(text)) {
        // A word broken across lines.
        final joined = cur.substring(0, cur.length - 1) + text;
        buf
          ..clear()
          ..write(joined);
      } else {
        buf.write(' ');
        buf.write(text);
      }
    }

    while (i < lines.length) {
      final line = lines[i];
      final t = line.text;

      if (i == lateTitle) {
        i++;
        continue;
      }

      final run = runAt[i];
      if (run != null) {
        flushPara();
        flushStep();
        flushNote();
        if (pendingHeading != null) {
          ingredients.add('${sectionHeadingTitle(pendingHeading)}:');
          if (steps.isNotEmpty) pendingStepHeading = pendingHeading;
          pendingHeading = null;
        }
        if (run.inline) {
          final joined = StringBuffer();
          for (var k = run.start; k < run.end; k++) {
            append(joined, lines[k].text);
          }
          final body = _inlineIngredients.firstMatch(joined.toString())?.group(1) ?? '';
          ingredients.addAll(_splitInlineIngredients(body));
          state = _State.ingredients;
          i = run.end;
          continue;
        }
        for (var k = run.start; k < run.end; k++) {
          final it = lines[k].text;
          if (_isIngredientHeader(it)) continue;
          final meta = _parseMeta(it);
          if (meta != null) {
            applyMeta(meta);
            continue;
          }
          if (_isComponentHeader(it)) {
            ingredients.add('${sectionHeadingTitle(it)}:');
            continue;
          }
          if (ingredients.isNotEmpty &&
              !isSectionHeading(ingredients.last) &&
              k > run.start &&
              !_isStrongIngredient(it) &&
              _continuesIngredient(lines, k)) {
            final b = StringBuffer(ingredients.last);
            append(b, it);
            ingredients[ingredients.length - 1] = b.toString();
            continue;
          }
          ingredients.add(it);
        }
        state = _State.ingredients;
        i = run.end;
        continue;
      }

      // A lone number is a step number set in the margin.
      if (RegExp(r'^\d{1,2}[.)]?$').hasMatch(t.trim())) {
        if (state == _State.method || state == _State.ingredients) {
          flushStep();
          forceNewStep = true;
          state = _State.method;
        }
        i++;
        continue;
      }

      final meta = _parseMeta(t);
      if (meta != null && !_insideProse(lines, i)) {
        applyMeta(meta);
        i++;
        continue;
      }

      if (_isNutrition(t) && !_insideProse(lines, i) && state != _State.front) {
        flushStep();
        nutrition.add(t);
        i++;
        continue;
      }

      if (_isIngredientHeader(t) && !_insideProse(lines, i)) {
        flushPara();
        flushStep();
        flushNote();
        state = _State.ingredients;
        i++;
        continue;
      }
      if (_isMethodHeader(t) && !_insideProse(lines, i)) {
        flushPara();
        flushStep();
        flushNote();
        state = _State.method;
        i++;
        continue;
      }
      if (_isNotesHeader(t) && !_insideProse(lines, i)) {
        flushPara();
        flushStep();
        flushNote();
        state = _State.notes;
        i++;
        continue;
      }
      final inline = _inlineNote.firstMatch(t);
      if (inline != null && !_insideProse(lines, i)) {
        flushPara();
        flushStep();
        flushNote();
        state = _State.notes;
        note = StringBuffer(inline.group(1)!.trim());
        paraBlock = line.block;
        i++;
        continue;
      }

      // A component heading right before another ingredient list.
      final nextRunSoon = runAt.containsKey(i + 1) || runAt.containsKey(i + 2);
      if (!_insideProse(lines, i) && nextRunSoon) {
        if (_isComponentHeader(t) ||
            (state != _State.front && _looksLikeTitle(t) && _wordCount(t) <= 6 && runAt.containsKey(i + 1))) {
          flushStep();
          flushNote();
          pendingHeading = t;
          i++;
          continue;
        }
      }

      switch (state) {
        case _State.front:
          final instructionStart = _isNumberedStep(t) ||
              (runs.isEmpty && line.paragraphStart && _startsWithVerb(t) && _wordCount(t) >= 4);
          if (instructionStart) {
            flushPara();
            state = _State.method;
            continue; // handle this line as method
          }
          if (para == null || (line.paragraphStart && line.block != paraBlock)) {
            flushPara();
            para = StringBuffer();
            paraBlock = line.block;
          }
          append(para!, t);
          i++;

        case _State.ingredients:
          // Anything after the list that is not a list is the method.
          state = _State.method;
          continue;

        case _State.method:
          if (_isComponentHeader(t) && !_insideProse(lines, i)) {
            flushStep();
            steps.add('${sectionHeadingTitle(t)}:');
            i++;
            break;
          }
          // A short capitalised lead-in above a paragraph ("Make the Dough").
          if (line.paragraphStart &&
              !_insideProse(lines, i) &&
              _wordCount(t) <= 5 &&
              !_endsSentence(t) &&
              (_isTitleCase(t) || _isAllCaps(t) || (_wordCount(t) <= 2 && _startsUpper(t))) &&
              !_isNumberedStep(t) &&
              i + 1 < lines.length &&
              lines[i + 1].paragraphStart &&
              _isProse(lines[i + 1].text)) {
            flushStep();
            steps.add('${_formatTitle(t)}:');
            i++;
            break;
          }
          final numbered = _isNumberedStep(t);
          final text = numbered ? _stripStepNumber(t) : t;
          final endsCleanly = step != null && _endsSentence(step.toString());
          final newParagraph = line.paragraphStart && line.block != stepBlock;
          // Terse methods set one instruction per line inside one paragraph.
          final newLineStep = !newParagraph &&
              endsCleanly &&
              i > 0 &&
              _endsEarly(lines, i - 1) &&
              _startsUpper(text) &&
              _startsLikeInstruction(text);
          if (step == null || numbered || forceNewStep || (newParagraph && endsCleanly) || newLineStep) {
            flushStep();
            if (pendingStepHeading != null) {
              steps.add('${sectionHeadingTitle(pendingStepHeading)}:');
              pendingStepHeading = null;
            }
            step = StringBuffer();
            forceNewStep = false;
          }
          append(step!, text);
          stepBlock = line.block;
          i++;

        case _State.notes:
          if (note == null || (line.paragraphStart && line.block != paraBlock && _endsSentence(note.toString()))) {
            flushNote();
            note = StringBuffer();
          }
          append(note!, t);
          paraBlock = line.block;
          i++;
      }
    }

    flushPara();
    flushStep();
    flushNote();

    // A contributor's name under the method ("Mrs. Ruth Allen") is credit,
    // not a step.
    if (steps.length >= 2) {
      final last = steps.last;
      if (_wordCount(last) <= 5 &&
          !_endsSentence(last) &&
          !isSectionHeading(last) &&
          !_startsLikeInstruction(last) &&
          (_isTitleCase(last) || _isAllCaps(last))) {
        steps.removeLast();
        notes.insert(0, last);
      }
    }
    if (nutrition.isNotEmpty) notes.add(nutrition.join(', '));

    if (cook == null && total != null) {
      final rest = total! - (prep ?? 0);
      cook = rest > 0 ? rest : total;
    }

    return _Structured(
      title: title,
      description: headnote.isEmpty ? null : headnote.join('\n\n'),
      servings: servings,
      prep: prep,
      cook: cook,
      ingredients: ingredients,
      steps: steps,
      notes: notes.isEmpty ? null : notes.join('\n\n'),
    );
  }

  /// Tidies a title. Titles set in capitals are recased so the recipe list
  /// does not shout.
  static String _formatTitle(String raw) {
    var t = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    t = t.replaceAll(RegExp(r'^[^\wÀ-ÿ(]+|[^\wÀ-ÿ)!?]+$'), '');
    if (!_isAllCaps(t)) return t;
    final words = t.toLowerCase().split(' ');
    final out = <String>[];
    for (var i = 0; i < words.length; i++) {
      final w = words[i];
      if (w.isEmpty) continue;
      if (i > 0 && _smallWords.contains(w)) {
        out.add(w);
        continue;
      }
      out.add(w.split('-').map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1)).join('-'));
    }
    return out.join(' ');
  }

  static String? _mergeLabels(String? a, String? b) {
    if (a == null) return b;
    if (b == null) return a;
    final nums = [
      ...RegExp(r'\d+').allMatches(a).map((m) => int.parse(m.group(0)!)),
      ...RegExp(r'\d+').allMatches(b).map((m) => int.parse(m.group(0)!)),
    ];
    if (nums.isEmpty) return a;
    nums.sort();
    return nums.first == nums.last ? '${nums.first}' : '${nums.first}-${nums.last}';
  }
}

enum _State { front, ingredients, method, notes }

class _Prepared {
  final List<SourceLine> lines;
  final List<int?> pageNumbers;
  final List<int> pageSpans;
  const _Prepared(this.lines, this.pageNumbers, this.pageSpans);
}

/// A contiguous ingredient list: lines `[start, end)`.
class _Run {
  final int start;
  final int end;
  final bool hasHeader;

  /// The list is a run-in paragraph ("Ingredients: a, b, c") to be split on
  /// its commas.
  final bool inline;
  const _Run(this.start, this.end, {this.hasHeader = false, this.inline = false});
}

/// Where a recipe begins and how many of its first lines are the title.
class _Start {
  final int start;
  final int titleLines;
  const _Start(this.start, this.titleLines);
}

class _Meta {
  final String? servings;
  final int? prep;
  final int? cook;
  final int? total;
  const _Meta({this.servings, this.prep, this.cook, this.total});
}

class _Structured {
  final String? title;
  final String? description;
  final String? servings;
  final int? prep;
  final int? cook;
  final List<String> ingredients;
  final List<String> steps;
  final String? notes;

  const _Structured({
    required this.title,
    this.description,
    this.servings,
    this.prep,
    this.cook,
    this.ingredients = const [],
    this.steps = const [],
    this.notes,
  });
}
