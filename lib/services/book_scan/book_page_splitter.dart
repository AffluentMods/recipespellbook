/// Turns the recognized text of photographed cookbook pages into recipes.
///
/// The pages arrive in the order they were scanned. A recipe may run across two
/// pages and one page may hold two recipes, so the pages are first joined into
/// one stream of lines (minus page numbers and running headers) and then cut
/// wherever a new recipe starts. Every recipe is anchored on its ingredient
/// list, because that is the one part every printed recipe has and the part
/// that looks least like prose; the title is then found by looking back from
/// the list. A page that opens with a heading of its own and holds no list (a
/// chapter introduction, a recipe that is all method) is cut off from the
/// recipe before it and judged by itself.
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

  /// The pages (indices into [pageNumbers]) whose number was not read off the
  /// page itself: it was counted on from a neighbour, or from the first page
  /// number the caller passed in. A counted number is a guess. When pages
  /// were skipped between two scans it is wrong, so it must not be trusted
  /// the way a printed one is.
  final Set<int> countedPageNumbers;

  /// How many printed pages each photo shows: 2 for a spread, otherwise 1.
  final List<int> pageSpans;

  /// Lines that did not end up in any recipe: the tail of a recipe whose
  /// first page was not scanned, a contents page, a chapter introduction.
  final int unassignedLines;

  const BookSplitResult({
    required this.drafts,
    required this.pageNumbers,
    this.countedPageNumbers = const {},
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
  /// batch of pages appended to an existing scan. [BookSplitResult.pageNumbers],
  /// [BookSplitResult.countedPageNumbers] and [BookSplitResult.pageSpans] still
  /// describe only [pages].
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
      final captionPages = captions.keys.toSet();
      // With no ingredient list anywhere, what reads as a method is still
      // kept, so nothing that was photographed is silently lost.
      final anchored = runs.isEmpty
          ? [_Start(0, _leadingTitleLines(lines))]
          : _recipeStarts(lines, runs, captionPages: captionPages);
      final dropped = _captionLines(captions, anchored);
      final starts = [...anchored, ..._pageTopStarts(lines, runs, anchored, captionPages)]
        ..sort((a, b) => a.start.compareTo(b.start));
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
      countedPageNumbers: prepared.countedPageNumbers,
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
    // A recipe has one description, and the first recipe's stays it. The
    // second one's is kept with the notes, since it has nowhere else to go
    // and may well be method text that was cut off from the first.
    final aDescribed = a.description?.trim().isNotEmpty ?? false;
    final bDescribed = b.description?.trim().isNotEmpty ?? false;
    final notes = [a.notes, if (aDescribed && bDescribed) b.description, b.notes]
        .where((n) => n != null && n.trim().isNotEmpty)
        .join('\n\n');
    final raw = [a.rawOcrText, b.rawOcrText].where((t) => t != null && t.isNotEmpty).join('\n');

    final merged = ImportedRecipe(
      title: first.titleFound ? a.title : (second.titleFound ? b.title : a.title),
      description: aDescribed ? a.description : b.description,
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
      rawOcrText: raw.isEmpty ? null : raw,
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

    final headHasTitleLine = draft.titleFound && _isTitleLine(head, 0) && !_isAmountLine(head, 0);
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
      titleLines: tailTitle && !_isAmountLine(tail, 0) ? _titleSpan(tail, 0) : 0,
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
    final bodyHeight = <double?>[];
    for (final page in pages) {
      located.add(_hasGeometry(page));
      edgeIdx.add(_edgeLines(page));
      bodyHeight.add(_medianHeight(page.lines));
    }

    // 2. Running heads and feet: the same short text at the same edge of
    //    another page, printed about as large. A caption that repeats a title
    //    sits at the other edge or in another size, and a contents entry is
    //    nowhere near the title it lists.
    //    When the scan carries no positions, the first and last line of a page
    //    are usually real content, so a header must also carry a page number
    //    ("142 SOUPS") to count.
    final seen = <String, List<_MarginLine>>{};
    for (var p = 0; p < pages.length; p++) {
      for (final i in edgeIdx[p]) {
        final text = pages[p].lines[i].text;
        if (!located[p] && _folioInText(text) == null) continue;
        final key = _marginKey(pages[p], i);
        if (key != null) (seen[key] ??= []).add(_marginLine(pages[p], p, i, edgeIdx[p].length, bodyHeight[p]));
      }
    }

    bool repeats(String key, _MarginLine here) {
      final all = seen[key] ?? const <_MarginLine>[];
      bool alike(_MarginLine o) =>
          o.size == null || here.size == null || (o.size! < here.size! * 1.5 && here.size! < o.size! * 1.5);
      if (!all.any((o) => o.page != here.page && alike(o))) return false;
      // A title in the margin band comes round twice when its page is
      // scanned twice. A title towers over the text of every page it is on,
      // which a running head does not do on a page that has a title.
      final judged = all.where((o) => o.titleSized != null);
      return judged.isEmpty || judged.any((o) => !o.titleSized!);
    }

    // A number beside a running head is not the page number when it is the
    // same on every page: "5 Ingredients" says 5 on each of them.
    bool sameNumberThroughout(String key) {
      final numbers = [
        for (final o in seen[key] ?? const <_MarginLine>[])
          if (o.number != null) o.number,
      ];
      return numbers.length >= 2 && numbers.toSet().length == 1;
    }

    // 3. Strip page furniture and read printed page numbers.
    final detected = List<int?>.filled(pages.length, null);
    final spans = List<int>.filled(pages.length, 1);
    final kept = <List<PageLine>>[];
    for (var p = 0; p < pages.length; p++) {
      final page = pages[p];
      final drop = <int>{};
      final folios = <({int number, PageLine line})>[];
      for (final i in edgeIdx[p]) {
        final bare = _bareFolio.firstMatch(page.lines[i].text.trim());
        if (bare == null) continue;
        final n = int.tryParse(bare.group(1)!);
        if (n != null) folios.add((number: n, line: page.lines[i]));
        drop.add(i);
      }
      int? beside;
      for (final i in edgeIdx[p]) {
        if (drop.contains(i)) continue;
        final text = page.lines[i].text.trim();
        final key = _marginKey(page, i);
        if (key == null) continue;
        final here = _marginLine(page, p, i, edgeIdx[p].length, bodyHeight[p]);
        if (repeats(key, here) && (located[p] || _folioInText(text) != null)) {
          if (!sameNumberThroughout(key)) beside ??= _folioBeside(text);
          drop.add(i);
        } else if (located[p] && _isLoneFurniture(page, i, edgeIdx[p].length, bodyHeight[p], folios)) {
          beside ??= _folioBeside(text);
          drop.add(i);
        }
      }
      // The number that stands alone is the page number. One found beside a
      // running head only stands in when there is no other.
      detected[p] = beside;
      if (folios.isNotEmpty) {
        folios.sort((a, b) => a.number.compareTo(b.number));
        detected[p] = folios.first.number;
        // Two consecutive numbers, one in each half: the photo is a spread.
        final w = page.width;
        if (folios.length >= 2 && w != null && w > 0) {
          final lo = folios.first;
          final hi = folios.last;
          double? centre(PageLine l) => l.hasBox ? (l.left! + l.right!) / 2 : null;
          final loX = centre(lo.line);
          final hiX = centre(hi.line);
          if (hi.number == lo.number + 1 && loX != null && hiX != null && loX < w / 2 && hiX > w / 2) {
            spans[p] = 2;
          }
        }
      }
      kept.add([
        for (var i = 0; i < page.lines.length; i++)
          if (!drop.contains(i) && page.lines[i].text.trim().isNotEmpty) page.lines[i],
      ]);
    }

    final resolved = _resolvePageNumbers(detected, firstPageNumber, spans);
    final pageNumbers = resolved.numbers;

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
    return _Prepared(out, pageNumbers, resolved.counted, spans);
  }

  /// What a line in the margin is matched on from page to page: its words and
  /// which edge it sits at. Null when the line could not be a running header.
  static String? _marginKey(PageText page, int i) {
    final key = _runningKey(page.lines[i].text);
    if (key == null) return null;
    final atHead = _hasGeometry(page) ? page.lines[i].centerY! / page.height! < 0.5 : i == 0;
    return '${atHead ? 'head' : 'foot'}|$key';
  }

  /// How line [i] in the margin of page [p] stands on its page. [inMargins] is
  /// how many of the page's lines sit in its margins and [median] the usual
  /// height of a line on it.
  static _MarginLine _marginLine(PageText page, int p, int i, int inMargins, double? median) {
    final line = page.lines[i];
    final number = _folioInText(line.text);
    final h = line.height;
    if (!_hasGeometry(page) || h == null || h <= 0) return _MarginLine(p, number: number);
    bool? titleSized;
    if (page.lines.length - inMargins >= _bodyLines && median != null) {
      titleSized = h >= median * 1.3 && page.lines.every((o) => o.height == null || o.height! <= h);
    }
    return _MarginLine(p, size: h / page.height!, titleSized: titleSized, number: number);
  }

  /// How many lines outside the margins make a page of text, as opposed to a
  /// photograph with a caption.
  static const int _bodyLines = 3;

  /// A running head or foot that is seen only once, which is all a scan of
  /// one or two pages gives. With positions known it can still be told from
  /// the text: a short capitalised line in the margin, in a block of its own,
  /// that stands level with the page number or is set clearly smaller than
  /// the text. [folios] are the page numbers found on the page and [median]
  /// is the usual height of a line on it.
  static bool _isLoneFurniture(
    PageText page,
    int i,
    int inMargins,
    double? median,
    List<({int number, PageLine line})> folios,
  ) {
    final line = page.lines[i];
    final text = line.text.trim();
    final h = line.height;
    if (h == null || h <= 0 || median == null) return false;
    // A photograph's caption is all the text its page has.
    if (page.lines.length - inMargins < _bodyLines) return false;
    if (_runningKey(text) == null) return false;
    // The page number is often read as part of the line ("142 SOUPS").
    final worded = RegExp(r'^(\d{1,4}\s+)?[A-ZÀ-Ý]').firstMatch(text);
    if (worded == null) return false;
    if (page.lines.where((o) => o.block == line.block).length != 1) return false;
    // A title may share the top of the page with its number.
    if (h >= median * 1.15) return false;

    // Capitals have no tails, so their boxes come out short at any size.
    if (h <= median * (_isAllCaps(text) ? 0.6 : 0.8)) return true;
    // At the size of the text, a line that leads with a number is a step.
    if (worded.group(1) != null) return false;
    for (final folio in folios) {
      final fh = folio.line.height;
      if (fh == null || fh <= 0) continue;
      final level = (folio.line.centerY! - line.centerY!).abs() <= (h > fh ? h : fh) * 0.6;
      if (level && h <= fh * 1.3) return true;
    }
    return false;
  }

  /// The page number read as part of a running head ("142 SOUPS",
  /// "Soups 143"). Null when the number counts something else ("CHAPTER 3")
  /// or is a year ("Summer 2019").
  static int? _folioBeside(String text) {
    final t = text.trim();
    if (RegExp(
      r'\b(?:chapter|part|week|day|book|volume|vol|section|lesson|menu|recipe|course|step|no|number)\.?\s+\d{1,4}$',
      caseSensitive: false,
    ).hasMatch(t)) {
      return null;
    }
    final n = _folioInText(t);
    return n == null || (n >= 1900 && n <= 2100) ? null : n;
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
  /// that could be read, and says which of them were not read but counted.
  static ({List<int?> numbers, Set<int> counted}) _resolvePageNumbers(
    List<int?> detected,
    int? firstPageNumber,
    List<int> spans,
  ) {
    final n = detected.length;
    final known = List<int?>.from(detected);
    // Position of each photo counted in printed pages, so a spread counts
    // for two.
    final pos = List<int>.filled(n, 0);
    for (var i = 1; i < n; i++) {
      pos[i] = pos[i - 1] + spans[i - 1];
    }

    // A misread number breaks the run. When other readings agree with each
    // other on "printed number minus position", one that agrees with none of
    // them, is out of order and looks like what its place calls for with a
    // digit wrong or missing is taken for a misreading. Readings that agree
    // with each other are never touched (the scan went back in the book), nor
    // is a number that was also read on another page (a page scanned twice),
    // nor one that is nothing like its neighbours (one recipe from elsewhere
    // in the book).
    final idx = [for (var i = 0; i < n; i++) if (known[i] != null) i];
    if (idx.length >= 3) {
      final votes = <int, int>{};
      final read = <int, int>{};
      for (final i in idx) {
        votes[known[i]! - pos[i]] = (votes[known[i]! - pos[i]] ?? 0) + 1;
        read[known[i]!] = (read[known[i]!] ?? 0) + 1;
      }
      if (votes.values.any((v) => v >= 2)) {
        for (var k = 0; k < idx.length; k++) {
          final i = idx[k];
          final value = known[i]!;
          if (votes[value - pos[i]]! > 1 || read[value]! > 1) continue;
          int? prev;
          for (var j = k - 1; j >= 0 && prev == null; j--) {
            if (known[idx[j]] != null) prev = idx[j];
          }
          int? next;
          for (var j = k + 1; j < idx.length && next == null; j++) {
            if (known[idx[j]] != null) next = idx[j];
          }
          final outOfOrder = (prev != null && value < known[prev]!) || (next != null && value > known[next]!);
          if (!outOfOrder) continue;
          final expected = prev != null ? known[prev]! + (pos[i] - pos[prev]) : known[next!]! - (pos[next] - pos[i]);
          if (_looksMisread(value, expected)) known[i] = null;
        }
      }
    }

    final printed = {
      for (var i = 0; i < n; i++)
        if (known[i] != null) i,
    };
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
        // Squeezed in between two numbers that leave no room for it. Where
        // the scan goes back in the book there is nothing to squeeze into.
        if (after != null && known[after]! > known[before]! && guess >= known[after]!) {
          guess = known[after]! - (pos[after] - pos[i]);
          if (guess <= known[before]!) guess = known[before]!;
        }
        out[i] = guess;
      } else if (after != null) {
        final guess = known[after]! - (pos[after] - pos[i]);
        out[i] = guess > 0 ? guess : null;
      }
    }
    return (
      numbers: out,
      counted: {
        for (var i = 0; i < n; i++)
          if (out[i] != null && !printed.contains(i)) i,
      },
    );
  }

  /// Whether [read] could be [expected] read wrongly: one digit taken for
  /// another (148 for 143), one too many (1143), or only part of the number
  /// made out (14 or 3 for 143).
  static bool _looksMisread(int read, int expected) {
    final a = '$read';
    final b = '$expected';
    if (a.length < b.length) return b.contains(a);
    if (a.length == b.length) {
      var differing = 0;
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i]) differing++;
      }
      return differing == 1;
    }
    if (a.length - b.length != 1) return false;
    for (var cut = 0; cut < a.length; cut++) {
      if (a.substring(0, cut) + a.substring(cut + 1) == b) return true;
    }
    return false;
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
  static Set<int> _captionLines(Map<int, List<int>> captions, List<_Start> starts) {
    final titles = <int>{
      for (final s in starts)
        for (var k = 0; k < (s.titleLines < 1 ? 1 : s.titleLines); k++) s.start + k,
    };
    final out = <int>{};
    for (final idx in captions.values) {
      if (idx.any(titles.contains)) continue;
      out.addAll(idx);
    }
    return out;
  }

  // ───────────────────── line classification ─────────────────────

  // The two headings every recipe page is built around are also known in the
  // other languages the app is used in (German, French, Spanish, Italian,
  // Portuguese, Dutch, Polish), since a heading that is not recognised reads
  // as the last ingredient.
  static final RegExp _ingredientHeader = RegExp(
    r"^(?:the\s+)?(?:ingr[eé]dients?|what\s+you(?:'ll|’ll|\s+will)?\s+need|you(?:'ll|’ll|\s+will)\s+need|shopping\s+list"
    r"|zutaten|ingredientes?|ingredienti|ingredi[eë]nten|sk[lł]adniki)\b[^.!?]{0,30}:?$",
    caseSensitive: false,
  );

  static final RegExp _methodHeader = RegExp(
    r"^(?:the\s+)?(?:method|directions?|instructions?|pr[eé]paration|procedure|steps?|how\s+to\s+make(?:\s+it)?|to\s+make|to\s+prepare|what\s+to\s+do|cooking\s+instructions?"
    r"|zubereitung|anleitung|[eé]tapes|r[eé]alisation|preparaci[oó]n|elaboraci[oó]n|procedimiento|instrucciones"
    r"|preparazione|procedimento|istruzioni|preparo|prepara[cç][aã]o|modo\s+de\s+(?:preparo|preparaci[oó]n|prepara[cç][aã]o|fazer)"
    r"|bereiding|bereidingswijze|werkwijze|przygotowanie|spos[oó]b\s+przygotowania|wykonanie)\s*:?$",
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

  /// What is done to an ingredient, with how: "finely chopped", "to taste".
  static const String _prep = r"(?:(?:very\s+)?(?:finely|roughly|thinly|coarsely|freshly|lightly)\s+)?"
      r"(?:chopped|sliced|diced|minced|grated|peeled|crushed|cubed|halved|quartered|shredded|trimmed|drained|rinsed|beaten|melted|softened|toasted|zested|juiced|cored|seeded|deseeded|optional|to\s+taste|to\s+serve|for\s+frying|at\s+room\s+temperature)";

  static final RegExp _prepNote = RegExp("^$_prep\\b", caseSensitive: false);

  /// A line of nothing else ("finely chopped", "peeled and diced.", or
  /// "chopped (180g)" with the weight that is left), which only ever finishes
  /// the item above it.
  static final RegExp _prepOnly = RegExp(
    "^$_prep(?:(?:\\s*,\\s*|\\s+(?:and|or|then)\\s+)$_prep)*(?:\\s*\\([^()]*\\))?[.,;]?\$",
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

  static final RegExp _numberWord = RegExp(
    r"^(?:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|half|several|a|an)\s+(\S+)",
    caseSensitive: false,
  );

  static bool _startsWithQuantity(String t) {
    final s = t.trim();
    if (!_quantityStart.hasMatch(s)) return false;
    // "One Pot Pasta", "A Good Roast Chicken": a number word counts what
    // follows it, and a capitalised word that is not a unit is a name.
    final next = _numberWord.firstMatch(s)?.group(1);
    if (next == null) return true;
    final capitalised = next[0] != next[0].toLowerCase();
    return !capitalised || _unit.hasMatch(next);
  }

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

  /// "Butter a 20 cm tin", "Oil the tray": the pantry word is a verb here.
  static final RegExp _pantryVerb = RegExp(
    r"^(?:butter|oil|salt|pepper|ice|water)\s+(?:a|an|the|each|both|your|all)\b",
    caseSensitive: false,
  );

  static bool _leadsWithPantry(String t) => _pantryLead.hasMatch(t) && !_pantryVerb.hasMatch(t);

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

  /// The words a line of a nutrition panel is made of, besides its figures.
  static final RegExp _nutritionWords = RegExp(
    r"\b(?:calories|cals?|kcal|kj|energy|protein|carb(?:ohydrate)?s?|saturate[sd]?|fibre|fiber|sodium|cholesterol|fat|sugars?|salt"
    r"|nutrition(?:al)?|information|info|facts|values?|per|each|serving|portion|contains|provides|of|which|total|and|about|approx"
    r"|dietary|(?:mono|poly)?unsaturate[sd]|trans|added|starch|daily|dv|rda|gda|g|mg)\b",
    caseSensitive: false,
  );

  static final RegExp _nutrientName = RegExp(
    r"\b(?:calories|cals?|kcal|kj|energy|protein|carb(?:ohydrate)?s?|saturate[sd]?|fibre|fiber|sodium|cholesterol|fat|sugars?|salt"
    r"|nutrition(?:al)?|serving|portion)\b",
    caseSensitive: false,
  );

  static final RegExp _energyFigure = RegExp(r"\d\s?(?:kcal|kj|calories|cals?)\b", caseSensitive: false);

  /// What only a nutrition panel says. Fat, protein, sugar and salt are also
  /// things to cook with, so on their own they settle nothing unless the
  /// figure comes after the name ("Fat 12g").
  static final RegExp _nutritionOnly = RegExp(
    r"\b(?:calories|cals?|kcal|kj|energy|carb(?:ohydrate)?s?|saturate[sd]?|fibre|fiber|sodium|cholesterol|sugars)\b"
    r"|^(?:total\s+)?(?:fat|protein)\b\s*:?\s*\d"
    r"|^(?:nutrition(?:al)?|(?:per|each)\s+(?:serving|portion))\b",
    caseSensitive: false,
  );

  /// "Fat 12g", "320 kcal", "30 g protein", "Per serving": a line made of
  /// nothing but nutrition figures. A panel of them looks a lot like an
  /// ingredient list. A name after the nutrient makes the line an ingredient
  /// ("30 g protein powder", "150 g fat-free natural yogurt").
  static bool _readsAsNutrition(String t) {
    final s = t.trim();
    if (_energyFigure.hasMatch(s)) return true;
    if (!_nutrientName.hasMatch(s)) return false;
    final rest = s.replaceAll(RegExp(r'\d'), ' ').replaceAll(_nutritionWords, ' ');
    return !RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(rest);
  }

  /// A nutrition line that could not be an ingredient.
  static bool _isNutritionFigure(String t) => _readsAsNutrition(t) && _nutritionOnly.hasMatch(t.trim());

  /// How many lines of a panel are looked through for one that settles it.
  static const int _panelReach = 12;

  /// Whether line [i] belongs to a nutrition panel. "30 g protein" and
  /// "5 g salt" may as well be ingredients, so they count only in the company
  /// of a line that could not be ("320 kcal", "Carbs 12 g", "Per serving").
  static bool _isNutritionAt(List<SourceLine> lines, int i) {
    if (!_readsAsNutrition(lines[i].text)) return false;
    if (_nutritionOnly.hasMatch(lines[i].text.trim())) return true;
    for (final step in const [-1, 1]) {
      for (var j = i + step, seen = 0; j >= 0 && j < lines.length && seen < _panelReach; j += step, seen++) {
        final t = lines[j].text;
        if (lines[j].page != lines[i].page || !_readsAsNutrition(t)) break;
        if (_nutritionOnly.hasMatch(t.trim())) return true;
      }
    }
    return false;
  }

  static int _wordCount(String t) => t.trim().isEmpty ? 0 : t.trim().split(RegExp(r'\s+')).length;

  static bool _endsSentence(String t) => RegExp(r'[.!?]["”’)]?$').hasMatch(t.trim());

  /// One sentence ending and the next beginning inside a line. A word of
  /// three letters or more ends the first one, which three letters before
  /// the stop are enough to tell, and looking for no more keeps a very long
  /// line from being searched over and over.
  static final RegExp _sentenceBreak = RegExp(r'[a-z]{3}[.!?]\s+[A-Z]');

  /// Running text: a sentence or a wrapped line of one.
  static bool _isProse(String t) {
    final s = t.trim();
    final words = _wordCount(s);
    if (s.length >= 64) return true;
    if (words >= 7 && _endsSentence(s)) return true;
    if (_sentenceBreak.hasMatch(s)) return true;
    return false;
  }

  /// A line that stops in the middle of a phrase, so whatever the next line
  /// starts with carries it on.
  static final RegExp _midPhrase = RegExp(
    r"\b(?:and|or|of|for|to|the|a|an|with|in|into|on|at|about|until|over|from|by)$",
    caseSensitive: false,
  );

  /// How many lines a sentence is followed over before giving up.
  static const int _sentenceReach = 12;

  /// The sentence that opens on line [k] and wraps over the lines below it,
  /// joined, with the line it closes on. Null when it never reaches a full
  /// stop.
  ///
  /// A method set in a narrow column is made of short lines, the same as an
  /// ingredient list. What tells them apart is that the method's lines add up
  /// to a sentence and a list's do not.
  static ({String text, int end})? _sentenceFrom(List<SourceLine> lines, int k) {
    final buf = StringBuffer();
    for (var j = k; j < lines.length && j < k + _sentenceReach; j++) {
      final text = lines[j].text.trim();
      if (j > k) {
        final prev = lines[j - 1];
        final first = RegExp(r'[A-Za-zÀ-ÿ0-9]').firstMatch(text)?.group(0) ?? '';
        final lower = first.isNotEmpty && first == first.toLowerCase() && first != first.toUpperCase();
        final sameParagraph = lines[j].page == prev.page && lines[j].block == prev.block && !lines[j].paragraphStart;
        // Into another paragraph or over the page, only a sentence that
        // plainly runs on is followed. Inside a paragraph a capital or a
        // number starts something new, unless the line above stops in the
        // middle of a phrase.
        if (!lower && !(sameParagraph && _midPhrase.hasMatch(prev.text.trim()))) return null;
        buf.write(' ');
      }
      buf.write(text);
      if (_endsSentence(text) || _sentenceBreak.hasMatch(text)) return (text: buf.toString(), end: j);
    }
    return null;
  }

  /// Whether line [i] opens running text rather than a list item.
  static bool _opensProse(List<SourceLine> lines, int i) {
    final text = lines[i].text;
    if (_isPantry(text)) return false;
    final sentence = _sentenceFrom(lines, i);
    if (sentence == null) return false;
    if (_startsWithQuantity(text)) {
      if (_wordCount(sentence.text) < 7 || _unit.hasMatch(sentence.text)) return false;
      // In a list that ends every item with a full stop, the next item
      // follows straight on.
      final after = sentence.end + 1;
      return after >= lines.length ||
          lines[after].block != lines[sentence.end].block ||
          !_isStrongIngredient(lines[after].text);
    }
    if (_startsLikeInstruction(text)) return true;
    return _wordCount(sentence.text) >= 7;
  }

  /// "Strong white flour 500 g", "spaghetti 320 g": some books print the name
  /// first and the amount after it.
  static final RegExp _amountAtEnd = RegExp(
    r"^[A-Za-zÀ-ÿ][^.!?:;]*[\s,(](?:\d+(?:[.,/]\d+)?|[½⅓⅔¼¾⅛⅜⅝⅞])\s?"
    r"(?:g|kg|mg|ml|l|dl|cl|oz|lb|lbs|tsp|tbsp|tbs|cups?|teaspoons?|tablespoons?)\)?\.?$",
    caseSensitive: false,
  );

  static bool _endsWithAmount(String t) {
    final s = t.trim();
    return _amountAtEnd.hasMatch(s) && _wordCount(s) <= 7 && !_startsLikeInstruction(s);
  }

  /// A line that is clearly an ingredient: it leads with an amount, or ends
  /// with one.
  static bool _isStrongIngredient(String t) {
    final s = t.trim();
    if (!_startsWithQuantity(s) && !_endsWithAmount(s)) return false;
    if (s.length > 120) return false;
    if (_isNumberedStep(s)) return false;
    if (_parseMeta(s) != null) return false;
    if (_cookingWords.hasMatch(s) && !_unit.hasMatch(s)) return false;
    if (_isNutritionFigure(s)) return false;
    if (_wordCount(s) >= 7 && _endsSentence(s) && !_unit.hasMatch(s)) return false;
    // A number on its own, "1." and "1)" included, is a step or page number.
    if (RegExp(r'^\d{1,4}[.)]?$').hasMatch(s)) return false;
    return true;
  }

  /// A title that begins with a number ("3 Bean Salad", "15 Minute Pasta")
  /// reads like the first ingredient. What gives it away is its size or,
  /// where sizes are not known, that it is capitalised like a title and
  /// stands in a paragraph of its own.
  static bool _isNumberLedTitle(List<SourceLine> lines, int i) {
    final l = lines[i];
    final t = l.text.trim();
    if (!_startsWithQuantity(t) || !_looksLikeTitle(t, numberLed: true)) return false;

    // A line with an amount-led neighbour that looks the same is one of a
    // list, however large the list is set.
    bool alike(int j) {
      if (j < 0 || j >= lines.length) return false;
      final o = lines[j];
      if (!_startsWithQuantity(o.text)) return false;
      if (l.height != null && o.height != null) return o.height! >= l.height! * 0.8;
      return _isTitleCase(o.text) || _isAllCaps(o.text);
    }

    if (alike(i - 1) || alike(i + 1)) return false;
    if (_isTall(l)) return true;
    if (l.relHeight != null && l.relHeight! < 1.15) return false;
    if (!(_isTitleCase(t) || _isAllCaps(t)) || _unit.hasMatch(t) || t.contains(',')) return false;
    return l.paragraphStart && (i + 1 >= lines.length || lines[i + 1].paragraphStart || lines[i + 1].block != l.block);
  }

  /// A line that leads with an amount and is not a title for all that.
  static bool _isAmountLine(List<SourceLine> lines, int i) =>
      _isStrongIngredient(lines[i].text) && !_isNumberLedTitle(lines, i) && !_isNutritionAt(lines, i);

  /// A line that can be a recipe's title where it stands.
  static bool _isTitleLine(List<SourceLine> lines, int i) =>
      _looksLikeTitle(lines[i].text) || _isNumberLedTitle(lines, i);

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
    if (_isNutritionFigure(s)) return false;
    // "Assemble", "To finish": a heading for the next part of the method.
    // Headings are capitalised, which "warm water" in a list is not.
    if (_wordCount(s) <= 2 && _startsWithVerb(s) && _startsUpper(s) && !_leadsWithPantry(s)) return false;
    return true;
  }

  static bool _isPantry(String t) {
    final s = t.trim();
    if (_leadsWithPantry(s)) return true;
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
    if (_leadsWithPantry(s)) return false;
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
      // "2 Slices bread" is an ingredient. "2 Slice the bread" is a step,
      // although a slice is also a unit.
      if (_unit.hasMatch(s.split(RegExp(r'\s+')).take(3).join(' ')) && !_isShortInstruction(rest)) return false;
      return _startsLikeInstruction(rest) && (rest.length >= 18 || _endsSentence(rest));
    }
    return false;
  }

  /// The number a numbered step carries, or null when it is spelled out.
  static int? _stepNumberOf(String t) {
    final s = t.trim();
    final m = _stepWord.firstMatch(s) ?? _stepPunct.firstMatch(s) ?? _stepBare.firstMatch(s);
    return m == null ? null : int.tryParse(m.group(1)!);
  }

  /// Whether [t] opens with the number after [last], the step before it, set
  /// without a full stop. In a method that numbers its steps that is the next
  /// step whatever word follows the number ("2 Soften the onions"), where a
  /// number in front of a word that is not known to open an instruction would
  /// otherwise be left in the text.
  static bool _countsOn(String t, int last) {
    final s = t.trim();
    final bare = _stepBare.firstMatch(s);
    if (bare == null || last < 1 || int.tryParse(bare.group(1)!) != last + 1) return false;
    return !_unit.hasMatch(s.split(RegExp(r'\s+')).take(3).join(' '));
  }

  /// [t] without its step number. A number with no full stop after it is
  /// taken off when an instruction follows, or when [bare] says it is one.
  static String _stripStepNumber(String t, {bool bare = false}) {
    var s = t.trim();
    s = s.replaceFirst(_stepWord, '');
    s = s.replaceFirst(_stepPunct, '');
    final number = _stepBare.firstMatch(s);
    if (number != null && (bare || _startsLikeInstruction(s.substring(number.end)))) {
      s = s.substring(number.end);
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

  /// The same for a line where it stands. A sentence set in short lines is
  /// method text although no line of it says so: "Everything goes into the
  /// pan" / "at once and simmers until" / "thick."
  static bool _isMethodAt(List<SourceLine> lines, int i) => _isMethodText(lines[i].text) || _opensProse(lines, i);

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
  /// A line that leads with an amount is turned away unless [numberLed] says
  /// the caller has other reasons to take it for a title.
  static bool _looksLikeTitle(String t, {bool numberLed = false}) {
    final s = t.trim();
    if (s.length < 3 || s.length > 72) return false;
    final words = _wordCount(s);
    if (words > 11) return false;
    if (RegExp(r'[.,;:]$').hasMatch(s)) return false;
    if (!numberLed && _startsWithQuantity(s)) return false;
    if (_isIngredientHeader(s) || _isMethodHeader(s) || _isNotesHeader(s)) return false;
    if (_isComponentHeader(s)) return false;
    if (_parseMeta(s) != null) return false;
    if (_isNumberedStep(s)) return false;
    final letters = s.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ]'), '').length;
    if (letters < s.replaceAll(' ', '').length * 0.7) return false;
    final first = RegExp(r'[A-Za-zÀ-ÿ]').firstMatch(s)?.group(0) ?? '';
    if (first.isEmpty || first != first.toUpperCase()) return false;
    if (_sentenceBreak.hasMatch(s)) return false;
    return true;
  }

  // ───────────────────────── metadata ─────────────────────────

  /// A count the way a yield prints it: 12, 1.5, 1½, 2 1/2.
  static const String _count = r"(?:\d+(?:[.,]\d+)?(?:\s?[½⅓⅔¼¾⅛⅜⅝⅞]|\s+\d/\d)?|[½⅓⅔¼¾⅛⅜⅝⅞])";

  /// One count or a range of them.
  static const String _countRange = "$_count(?:\\s*(?:-|–|to)\\s*$_count)?";

  static final RegExp _yieldLead = RegExp(
    r"^(serves|serve|servings?|makes|yields?|yield|portions?|feeds)\b\s*:?\s*(?:about\s+|approx\.?\s+|approximately\s+|around\s+|up\s+to\s+)?"
    "($_countRange)"
    r"(\s+[a-z][a-z -]{1,24})?",
    caseSensitive: false,
  );

  static final RegExp _yieldTrail = RegExp(
    "^($_countRange)"
    r"\s+(servings?|portions?)\b",
    caseSensitive: false,
  );

  /// "6 to 8" as "6-8", "1 ½" as "1½". The space inside "2 1/2" stays.
  static String _tidyCount(String raw) => raw
      .replaceAll(RegExp(r'\s*(?:-|–|to)\s*'), '-')
      .replaceAllMapped(RegExp(r'(\d)\s+([½⅓⅔¼¾⅛⅜⅝⅞])'), (m) => '${m[1]}${m[2]}')
      .trim();

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
      final count = _tidyCount(yl.group(2)!);
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
        servings = _tidyCount(yt.group(1)!);
        rest = rest.replaceRange(yt.start, yt.end, ' ');
        yieldMatched = true;
      }
    }

    final barLike = RegExp(r'[|·•]').hasMatch(s);
    // Capitals also mark a fact ("COOK 35 MINS"), but a sentence in capitals
    // is one more line of a method printed that way ("BAKE 1 HOUR AT 350.").
    final inCapitals = _isAllCaps(s) && !_endsSentence(s);
    var byCapitals = false;
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
      if (bareVerb && !yieldMatched && !labelled && !barLike) {
        if (!inCapitals) return null;
        byCapitals = true;
      }
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
    // "BAKE 1 HOUR AT 350": the oven setting makes it an instruction.
    if (byCapitals && RegExp(r'\d').hasMatch(rest)) return null;
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
    return _Meta(servings: servings, prep: prep, cook: cook, total: total, byCapitals: byCapitals);
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
    if (_opensProse(lines, first)) return true;
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

  /// A short line in a paragraph of its own, straight above a paragraph of
  /// running text: when capitalised, a heading for that part of the method.
  static bool _headsAParagraph(List<SourceLine> lines, int i) {
    final l = lines[i];
    final t = l.text;
    if (!l.paragraphStart || i + 1 >= lines.length || !lines[i + 1].paragraphStart) return false;
    if (_wordCount(t) > 5 || _endsSentence(t) || _isNumberedStep(t) || _insideProse(lines, i)) return false;
    return _isProse(lines[i + 1].text) || _opensProse(lines, i + 1);
  }

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
      // "You will need a deep tin and a" opens a sentence, not a list.
      final header = _isIngredientHeader(text) && !_insideProse(lines, i) && !_opensProse(lines, i);
      final strongStart = !header && _isAmountLine(lines, i) && !_insideProse(lines, i) && !_opensProse(lines, i);
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
        // The method has begun, however short its lines are.
        if (_opensProse(lines, k)) break;
        if (_isNumberLedTitle(lines, k) || _isNutritionAt(lines, k)) break;
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
        // "Making the Pastry" above the first paragraph of the method.
        if (_headsAParagraph(lines, k) && (_isTitleCase(t) || _isAllCaps(t)) && !_isPantry(t)) break;
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

  /// An item of a list that stops on a word which needs another after it:
  /// "cut into", "juice of", "plus extra for". "Skin on" and "bone in" end an
  /// item, so those two words are not among them.
  static final RegExp _endsMidPhrase = RegExp(r"\b(?:and|or|plus|of|for|to|the|a|an|with|into|about|such\s+as)$");

  /// A line that begins in the middle of a phrase: "and cut into chunks",
  /// "plus extra to serve", "or to taste". No item of a list starts this way.
  static final RegExp _startsMidPhrase = RegExp(r"^(?:and|or|plus|with|without|into|in|of|from|until|then|about|such\s+as)\b");

  /// Whether line [k] is the wrapped remainder of the ingredient above it.
  static bool _continuesIngredient(List<SourceLine> lines, int k) {
    if (k == 0) return false;
    final cur = lines[k];
    final prev = lines[k - 1];
    final t = cur.text.trim();
    final p = prev.text.trim();
    if (_isComponentHeader(t) || _parseMeta(t) != null) return false;
    if (_isIngredientHeader(p) || _isComponentHeader(p)) return false;
    // What stops in the middle of a phrase or of a bracket is carried on by
    // whatever comes next, an amount included: "cut into" over "2cm chunks",
    // "juice of" over "2 lemons".
    if (_endsMidPhrase.hasMatch(p) || '('.allMatches(p).length > ')'.allMatches(p).length) return true;
    if (_startsWithQuantity(t)) return false;
    if (_startsMidPhrase.hasMatch(t)) return true;
    // "spaghetti 320 g" is an item, in a list that prints the name first. A
    // weight in brackets is a note on the item above ("cubed (about 300 g)").
    if (_endsWithAmount(t) && !t.endsWith(')')) return false;
    if (_trailingConnector.hasMatch(p)) return true;
    // "2 tablespoons" names nothing yet: what it measures is on this line.
    if (_isBareAmount(p)) return true;
    final first = RegExp(r'[A-Za-zÀ-ÿ]').firstMatch(t)?.group(0) ?? '';
    final lower = first.isNotEmpty && first == first.toLowerCase();
    // A hanging indent is how books mark a wrapped ingredient.
    if (cur.left != null && prev.left != null && cur.height != null && lower) {
      if (cur.left! - prev.left! > cur.height! * 0.6) return true;
    }
    if (lower && _prepOnly.hasMatch(t)) return true;
    if (!lower) return false;
    // "sea salt" is an item of its own wherever it stands, unless the name
    // began on the line above.
    if (_isPantry(t) && !_nameRunsOver(p, t)) return false;
    // With nothing else to mark it, only what could not have fitted on the
    // line above was wrapped off it.
    return _filledItsLine(lines, k - 1, t.split(RegExp(r'\s+')).first);
  }

  /// An amount and its unit with nothing after them: "2 tablespoons", "400 g".
  static bool _isBareAmount(String t) {
    final s = t.trim();
    if (!_startsWithQuantity(s) || !_unit.hasMatch(s)) return false;
    return !RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(s.replaceAll(_unit, ' '));
  }

  /// Whether the end of line [above] cut a pantry name in two: "freshly
  /// ground black" over "pepper", "extra-virgin olive" over "oil".
  static bool _nameRunsOver(String above, String below) {
    final words = above.split(RegExp(r'\s+'));
    for (var n = 1; n <= 3 && n <= words.length; n++) {
      final head = words.sublist(words.length - n).join(' ');
      final name = _pantryLead.matchAsPrefix('$head $below');
      if (name != null && name.end > head.length + 1) return true;
    }
    return false;
  }

  /// Whether line [p] ran to the edge of its column, so that [word] had to
  /// drop onto the next line, which stands flush under it. The column is
  /// taken to be as wide as the widest line that shares its left edge, in its
  /// own paragraph and on down the page. Without positions there is no column
  /// to measure, and no line counts as full.
  static bool _filledItsLine(List<SourceLine> lines, int p, String word) {
    final line = lines[p];
    final chars = line.text.trim().length;
    if (chars == 0 || line.left == null || line.right == null || line.right! <= line.left!) return false;
    final own = line.right! - line.left!;
    final perChar = own / chars;

    // How far [l] reaches across this column, or null when it sits in another.
    double? reach(SourceLine l) {
      if (l.page != line.page || l.left == null || l.right == null) return null;
      if (l.left! < line.left! - perChar * 2 || l.left! > line.left! + own / 2) return null;
      return l.right! - line.left!;
    }

    // A list that indents the rest of a wrapped item says so every time, and
    // a line that stands flush in it is an item of its own. Only an indent
    // under an amount tells: a method indents too, under its step numbers
    // and where its paragraphs open.
    final height = line.height;
    bool hangs(int j) =>
        height != null &&
        j > 0 &&
        lines[j].left! - line.left! > height * 0.6 &&
        !_startsUpper(lines[j].text) &&
        _isStrongIngredient(lines[j - 1].text);

    var widest = own;
    for (var j = p - 1; j >= 0 && j >= p - _columnReach && lines[j].block == line.block; j--) {
      final r = reach(lines[j]);
      if (r == null) continue;
      if (hangs(j)) return false;
      if (r > widest) widest = r;
    }
    for (var j = p + 1; j < lines.length && j <= p + _columnReach; j++) {
      final r = reach(lines[j]);
      if (r == null) break;
      if (hangs(j)) return false;
      if (r > widest) widest = r;
    }
    final needed = (word.length + 1) * perChar;
    if (own + needed <= widest - perChar / 2) return false;
    // A long line is taken at its word. A short one may simply be the longest
    // of a list of short items, unless the text that begins to the right of
    // it, the next column, left the word no room.
    if (chars >= 30) return true;
    double? beside;
    bool onThisPage(int j) => j >= 0 && j < lines.length && lines[j].page == line.page;
    for (final step in const [-1, 1]) {
      for (var j = p + step; onThisPage(j); j += step) {
        final left = lines[j].left;
        if (left != null && left >= line.right! && (beside == null || left < beside)) beside = left;
      }
    }
    return beside != null && line.right! + needed > beside - _gutter * perChar;
  }

  /// How many lines up and down the page a column is measured over.
  static const int _columnReach = 40;

  /// The most characters the gap between two columns is taken to be wide.
  static const int _gutter = 8;

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
    if (_isStrongIngredient(b.text)) return 1;
    if (a.relHeight != null && b.relHeight != null) {
      final ratio = b.relHeight! / a.relHeight!;
      if (ratio < 0.8 || ratio > 1.25) return 1;
    }
    return 2;
  }

  /// For a scan with no ingredient list: does the first line read as a title?
  static int _leadingTitleLines(List<SourceLine> lines) {
    if (lines.isEmpty) return 0;
    if (!_isTitleLine(lines, 0) || _isAmountLine(lines, 0)) return 0;
    return _titleSpan(lines, 0);
  }

  static List<_Start> _recipeStarts(
    List<SourceLine> lines,
    List<_Run> runs, {
    Set<int> captionPages = const {},
  }) {
    final starts = <_Start>[];
    double? currentTitleHeight;
    // The line after a title that was found below its list. That title is
    // spoken for, so the search for the next recipe's title begins past it.
    var titleUsedTo = 0;

    for (var r = 0; r < runs.length; r++) {
      final run = runs[r];
      final gapTo = run.start;
      var gapFrom = r == 0 ? 0 : runs[r - 1].end;
      if (titleUsedTo > gapFrom) gapFrom = titleUsedTo < gapTo ? titleUsedTo : gapTo;

      // Is there method text between the previous list and this one? If not,
      // this is another component of the same recipe ("For the sauce").
      var proseInGap = false;
      var lastProse = -1;
      for (var i = gapFrom; i < gapTo; i++) {
        if (_isMethodAt(lines, i)) {
          proseInGap = true;
          lastProse = i;
        }
      }
      if (r > 0 && !proseInGap) continue;

      // Title candidates in the gap.
      var best = -1;
      var bestScore = double.negativeInfinity;
      for (var i = gapFrom; i < gapTo; i++) {
        if (!_isTitleLine(lines, i) || _insideProse(lines, i)) continue;
        if (_isAmountLine(lines, i)) continue;
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
          if (_isTitleLine(lines, i) && !_insideProse(lines, i) && (_isTall(lines[i]) || _isAllCaps(t))) {
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
          // Title printed after the list: the recipe starts at the list, or
          // at the yield line above it.
          var start = run.start;
          while (start > gapFrom && _parseMeta(lines[start - 1].text) != null) {
            start--;
          }
          starts.add(_Start(start, 0));
          titleUsedTo = best + _titleSpan(lines, best);
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

  /// Where the text of a recipe must stop at the top of a page, because the
  /// page begins something else: a chapter introduction, a contents page, an
  /// essay, or a recipe that has no ingredient list.
  ///
  /// Such a page opens with a heading, carries no list before the next recipe
  /// starts, and does not pick up a sentence from the page before it. Each is
  /// returned as a start of its own, so it is judged like any other region: a
  /// title with a method under it becomes a draft and anything else is counted
  /// as unassigned. Without this it would all be read as more steps of the
  /// recipe before it.
  static List<_Start> _pageTopStarts(
    List<SourceLine> lines,
    List<_Run> runs,
    List<_Start> starts,
    Set<int> captionPages,
  ) {
    final out = <_Start>[];
    for (var f = 0; f < lines.length; f++) {
      if (f > 0 && lines[f].page == lines[f - 1].page) continue;
      if (captionPages.contains(lines[f].page)) continue;

      _Start? recipe;
      var end = lines.length;
      for (final s in starts) {
        if (s.start > f) {
          end = s.start;
          break;
        }
        recipe = s;
      }
      if (recipe != null && recipe.start == f) continue;
      if (runs.any((r) => r.start < end && r.end > f)) continue;

      final titleHeight = recipe != null && recipe.titleLines > 0 ? lines[recipe.start].height : null;
      if (!_opensWithHeading(lines, f, titleHeight)) continue;

      if (f > 0) {
        // A sentence left hanging on the page before runs on over the heading.
        final before = lines[f - 1].text.trim();
        if (!_endsSentence(before) && (_wordCount(before) >= 6 || _midPhrase.hasMatch(before) || before.endsWith(','))) {
          continue;
        }
      }

      // A recipe whose list ends its page has its method here, whatever
      // heading the method was given.
      var listEnd = -1;
      for (final r in runs) {
        if (r.end <= f) listEnd = r.end;
      }
      if (listEnd >= 0) {
        var method = false;
        for (var k = listEnd; k < f && !method; k++) {
          method = _isMethodAt(lines, k);
        }
        if (!method) continue;
      }

      // So does a numbered method that carries on counting.
      int? lastNumber;
      for (var k = f - 1; k >= 0 && k >= (recipe?.start ?? 0) && lastNumber == null; k--) {
        if (_isNumberedStep(lines[k].text)) lastNumber = _stepNumberOf(lines[k].text);
      }
      int? nextNumber;
      for (var k = f; k < end && nextNumber == null; k++) {
        if (_isNumberedStep(lines[k].text)) nextNumber = _stepNumberOf(lines[k].text);
      }
      if (lastNumber != null && nextNumber == lastNumber + 1) continue;

      out.add(_Start(f, _titleSpan(lines, f)));
    }
    return out;
  }

  /// Whether the page that starts at line [f] opens with a heading of its own:
  /// a line shaped like a title, in a paragraph by itself, and printed like
  /// one. Where sizes are known that means larger than the text, and not
  /// clearly smaller than the title of the recipe before it ([titleHeight]),
  /// which is how a heading inside a method is set. Where they are not, it
  /// means capitalised like a title.
  static bool _opensWithHeading(List<SourceLine> lines, int f, double? titleHeight) {
    final l = lines[f];
    final t = l.text;
    if (!_isTitleLine(lines, f) || _isAmountLine(lines, f) || _startsLikeInstruction(t)) return false;
    final end = f + _titleSpan(lines, f);
    if (end < lines.length && lines[end].block == l.block && !lines[end].paragraphStart) return false;
    if (l.relHeight == null) return _isTitleCase(t) || _isAllCaps(t);
    if (!_isTall(l)) return false;
    return titleHeight == null || l.height == null || l.height! >= titleHeight * 0.8;
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
    var lateTitleFrom = -1;
    var lateTitleTo = -1;
    final runs = _findRuns(lines);

    if (titleLines > 0) {
      title = _formatTitle(lines.take(titleLines).map((l) => l.text).join(' '));
      i = titleLines;
    } else if (runs.isNotEmpty) {
      final limit = runs.first.end + 3 < lines.length ? runs.first.end + 3 : lines.length;
      for (var k = runs.first.end; k < limit; k++) {
        final t = lines[k].text;
        if (_isProse(t) || _isNumberedStep(t) || _isMethodHeader(t)) break;
        if (_isTitleLine(lines, k) && !_insideProse(lines, k) && (_isTall(lines[k]) || _isAllCaps(t))) {
          lateTitleFrom = k;
          lateTitleTo = k + _titleSpan(lines, k);
          title = _formatTitle(lines.sublist(k, lateTitleTo).map((l) => l.text).join(' '));
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
    var lastStepNumber = 0;
    // Where the text goes back to once a note is over, and whether the note
    // came on the same line as its label ("Note: ...").
    var afterNote = _State.method;
    var noteInline = false;

    bool noStepsYet() => steps.every(isSectionHeading);

    // Whether step [number] is where the method starts, or where a numbered
    // method carries on after a note. A fresh count from 1 under a note is a
    // list of tips.
    bool takesUpTheMethod(int? number) => noStepsYet() || (lastStepNumber > 0 && number == lastStepNumber + 1);

    // The stretch of the page the lists stand in, when positions are known,
    // and the first paragraph ahead of them that stands in another column and
    // reads as an instruction.
    double? listLeft;
    double? listRight;
    for (final r in runs) {
      for (var k = r.start; k < r.end; k++) {
        final l = lines[k];
        if (l.left == null || l.right == null) continue;
        if (listLeft == null || l.left! < listLeft) listLeft = l.left;
        if (listRight == null || l.right! > listRight) listRight = l.right;
      }
    }
    int? methodAhead;

    bool besideTheList(SourceLine l) =>
        listLeft != null &&
        listRight != null &&
        l.left != null &&
        l.right != null &&
        (l.right! <= listLeft || l.left! >= listRight);

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

      if (i >= lateTitleFrom && i < lateTitleTo) {
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
      final lone = RegExp(r'^(\d{1,2})[.)]?$').firstMatch(t.trim());
      if (lone != null) {
        final number = int.parse(lone.group(1)!);
        if (state == _State.method || state == _State.ingredients || (state == _State.notes && takesUpTheMethod(number))) {
          flushStep();
          flushNote();
          forceNewStep = true;
          state = _State.method;
          lastStepNumber = number;
        }
        i++;
        continue;
      }

      final meta = _parseMeta(t);
      // "BAKE 1 HOUR" is a fact above the list and a step below it.
      if (meta != null && !_insideProse(lines, i) && !(meta.byCapitals && state != _State.front)) {
        applyMeta(meta);
        i++;
        continue;
      }

      if (_isNutritionAt(lines, i) && !_insideProse(lines, i) && state != _State.front) {
        flushStep();
        nutrition.add(t);
        i++;
        continue;
      }

      if (_isIngredientHeader(t) && !_insideProse(lines, i) && !_opensProse(lines, i)) {
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
      final inline = _inlineNote.firstMatch(t);
      if ((inline != null || _isNotesHeader(t)) && !_insideProse(lines, i)) {
        flushPara();
        flushStep();
        flushNote();
        if (state != _State.notes) afterNote = state == _State.front ? _State.front : _State.method;
        noteInline = inline != null;
        state = _State.notes;
        if (inline != null) {
          note = StringBuffer(inline.group(1)!.trim());
          paraBlock = line.block;
        }
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
            if (methodAhead == null && besideTheList(line) && _startsLikeInstruction(t)) {
              methodAhead = headnote.length;
            }
          }
          append(para!, t);
          i++;

        case _State.ingredients:
          // Anything after the list that is not a list is the method.
          state = _State.method;
          continue;

        case _State.method:
          // "To make the dressing, whisk the oil," opens a sentence; a heading
          // stands on its own.
          if (_isComponentHeader(t) && !_insideProse(lines, i) && !_opensProse(lines, i)) {
            flushStep();
            steps.add('${sectionHeadingTitle(t)}:');
            i++;
            break;
          }
          // A short capitalised lead-in above a paragraph ("Make the Dough").
          if (_headsAParagraph(lines, i) &&
              (_isTitleCase(t) || _isAllCaps(t) || (_wordCount(t) <= 2 && _startsUpper(t)))) {
            flushStep();
            steps.add('${_formatTitle(t)}:');
            i++;
            break;
          }
          final endsCleanly = step != null && _endsSentence(step.toString());
          final newParagraph = line.paragraphStart && line.block != stepBlock;
          final countsOn = (step == null || endsCleanly) && _countsOn(t, lastStepNumber);
          final numbered = countsOn || _isNumberedStep(t);
          if (numbered) lastStepNumber = _stepNumberOf(t) ?? lastStepNumber + 1;
          final text = numbered ? _stripStepNumber(t, bare: countsOn) : t;
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
          // A note is not the end of the recipe. The method starts or carries
          // on after it at the step number that comes next.
          if ((_isNumberedStep(t) || _countsOn(t, lastStepNumber)) &&
              !_insideProse(lines, i) &&
              takesUpTheMethod(_stepNumberOf(t))) {
            flushNote();
            state = _State.method;
            continue;
          }
          final written = note?.toString() ?? '';
          final newParagraph = line.paragraphStart && line.block != paraBlock;
          if (written.isNotEmpty && newParagraph && (_endsSentence(written) || _startsUpper(t))) {
            // A note printed ahead of the method is one paragraph long. So is
            // a labelled one in the middle of it, when an instruction follows.
            if (noStepsYet() || (noteInline && _startsLikeInstruction(t))) {
              flushNote();
              state = afterNote;
              continue;
            }
          }
          if (note == null || (newParagraph && _endsSentence(written))) {
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

    // A list set to the right of its method is read after it, which leaves
    // the whole method in front of the list. With nothing after the list,
    // the method is what stands beside it.
    final ahead = methodAhead;
    if (ahead != null && ahead < headnote.length && noStepsYet() && ingredients.isNotEmpty) {
      steps.addAll(headnote.sublist(ahead));
      headnote.removeRange(ahead, headnote.length);
    }

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

  /// The page label of two drafts joined: the range their numbers cover.
  ///
  /// A label may have been typed by hand, so it can hold anything. When one
  /// of them has no number that can be read (roman numerals, a run of digits
  /// too long to be a number) the first label is kept as it stands.
  static String? _mergeLabels(String? a, String? b) {
    if (a == null || a.trim().isEmpty) return b;
    if (b == null || b.trim().isEmpty) return a;
    List<int> numbersIn(String label) => [
          for (final m in RegExp(r'\d+').allMatches(label)) int.tryParse(m.group(0)!),
        ].whereType<int>().toList();
    final first = numbersIn(a);
    final second = numbersIn(b);
    if (first.isEmpty || second.isEmpty) return a;
    final nums = [...first, ...second]..sort();
    return nums.first == nums.last ? '${nums.first}' : '${nums.first}-${nums.last}';
  }
}

enum _State { front, ingredients, method, notes }

class _Prepared {
  final List<SourceLine> lines;
  final List<int?> pageNumbers;
  final Set<int> countedPageNumbers;
  final List<int> pageSpans;
  const _Prepared(this.lines, this.pageNumbers, this.countedPageNumbers, this.pageSpans);
}

/// One sighting of a line in the top or bottom margin of a page.
class _MarginLine {
  final int page;

  /// Line height as a share of the page height. Null without positions.
  final double? size;

  /// Whether the line towers over the text of its page, the way a title
  /// does. Null when the page has no text to measure it against.
  final bool? titleSized;

  /// A number printed beside the words ("142 SOUPS").
  final int? number;

  const _MarginLine(this.page, {this.size, this.titleSized, this.number});
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

  /// Nothing but its capitals says the line is a fact ("COOK 35 MINS") and
  /// not a terse instruction.
  final bool byCapitals;
  const _Meta({this.servings, this.prep, this.cook, this.total, this.byCapitals = false});
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
