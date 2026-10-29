import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/imported_recipe.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/sync_provider.dart';
import '../../../services/book_scan/book_page_splitter.dart';
import '../../../services/book_scan/book_scan_platform.dart';
import '../../../services/book_scan/draft_images.dart';
import '../../../services/book_scan/scanned_page.dart';
import '../../../services/collab_service.dart';
import '../../../services/imported_recipe_saver.dart';
import '../../../services/sync_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_controls.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/sheet_chrome.dart';
import 'book_scan_edit_screen.dart';
import 'book_scan_widgets.dart';

enum _Stage { intro, reading, review, saving }

/// Separator between facts on one line. The space before the dot does not
/// break, so a wrapped line never starts with the dot.
const _dot = ' · ';

/// One recipe in the review queue, with the picture it will be saved with.
class _Item {
  _Item(this.key, this.draft, this.image);

  /// Stable for the life of the scan: list keys and image file names.
  final String key;
  BookRecipeDraft draft;
  DraftImage image;

  /// The user changed this recipe by hand.
  bool edited = false;

  /// Edited, merged or cut in two by the user, so it is no longer what
  /// reading the pages gives. A later reading leaves it as the user made it.
  bool byHand = false;

  /// The page label was typed by the user and is not worked out again.
  bool ownLabel = false;

  /// Swiped far enough to be discarded. The card is still sliding out of the
  /// list, but the recipe is no longer one to add.
  bool leaving = false;

  /// Added to the cookbook. It stays on screen until the save is over.
  bool saved = false;
}

/// What a page says about where it belongs, taken from its own text when it
/// is read: the number printed on it, its lines, and the recipes that begin
/// on it.
class _PageFacts {
  _PageFacts._(this._page, this.number, this.span, this.lines, this.titles);

  /// [beside] are pages read shortly before it, for [lookBeside].
  factory _PageFacts.of(ScannedPage page, {Iterable<ScannedPage> beside = const []}) {
    // Read on its own, a page has only what is printed on it to go by.
    final alone = BookPageSplitter.split([page.text]);
    final lines = <String>{};
    for (final line in page.text.lines) {
      final letters = _lettersOf(line.text);
      if (letters.length >= 3) lines.add(letters);
    }
    final facts = _PageFacts._(
      page,
      alone.pageNumbers.isEmpty ? null : alone.pageNumbers.first,
      alone.pageSpans.isEmpty ? 1 : alone.pageSpans.first,
      lines,
      {
        for (final draft in alone.drafts)
          if (draft.titleFound) _lettersOf(draft.recipe.title),
      }..remove(''),
    );
    beside.forEach(facts.lookBeside);
    return facts;
  }

  final ScannedPage _page;

  /// The printed page number, or null when none was read.
  int? number;

  /// Looks for the page's number with [neighbour] next to it, when the page
  /// did not give one on its own.
  ///
  /// Many books set the number beside a running title, "142 Soups", and such
  /// a line only shows as a page number once another page carries the same
  /// title. Read with that page in front of it and then behind, a number of
  /// its own comes out the same both times. One that is only counted on from
  /// the neighbour does not.
  ///
  /// The neighbour has to come out with another number than the page. Two
  /// pages that begin with the very same line, "2 cups plain flour", look
  /// like a running title with a 2 beside it, and that is not a page number.
  void lookBeside(ScannedPage neighbour) {
    if (number != null || neighbour.failed || !_numberMayShareALine) return;
    final inFront = BookPageSplitter.split([_page.text, neighbour.text]).pageNumbers;
    final behind = BookPageSplitter.split([neighbour.text, _page.text]).pageNumbers;
    if (inFront.length != 2 || behind.length != 2) return;
    final own = inFront.first;
    if (own != null && own == behind.last && own != inFront.last) number = own;
  }

  /// Whether a line at the head or the foot of the page has a number at one
  /// end of it and words beside. Where none has, [lookBeside] has nothing to
  /// find, and is spared reading the page twice over with every neighbour.
  late final bool _numberMayShareALine = () {
    final lines = _page.text.lines;
    final height = _page.text.height;
    for (var i = 0; i < lines.length; i++) {
      final y = lines[i].centerY;
      final atEdge = i == 0 ||
          i == lines.length - 1 ||
          (y != null && height != null && height > 0 && (y < height * 0.1 || y > height * 0.9));
      if (atEdge && _numberBesideWords.hasMatch(lines[i].text.trim())) return true;
    }
    return false;
  }();

  static final _numberBesideWords = RegExp(r'^\W{0,3}\d{1,4}\b.*\p{L}|\p{L}.*\b\d{1,4}\W{0,3}$', unicode: true);

  /// How many printed pages the photo shows: 2 for a spread, otherwise 1.
  final int span;

  /// The lines with something to read in them, reduced to their letters and
  /// digits so that spacing and stray marks do not matter.
  final Set<String> lines;

  /// The titles of the recipes that begin on the page, reduced the same way.
  final Set<String> titles;

  static final _notLetters = RegExp(r'[^\p{L}\p{N}]', unicode: true);

  static String _lettersOf(String text) => text.toLowerCase().replaceAll(_notLetters, '');

  /// Whether this is a second photo of the page [earlier] shows, and may take
  /// its place.
  ///
  /// Taking a page's place throws its first reading away, so in doubt the
  /// answer is no, and the photo is kept as a page of its own.
  bool retakes(_PageFacts earlier) {
    // Two different numbers are two pages, however alike they read.
    if (number != null && earlier.number != null && number != earlier.number) return false;
    // A photo that shows much less than the earlier one did, one page of a
    // spread for instance, would take the rest of it away.
    if (lines.length * 3 < earlier.lines.length * 2) return false;

    final sameRecipes = titles.isEmpty || earlier.titles.isEmpty || titles.any(earlier.titles.contains);
    if (number != null && number == earlier.number && sameRecipes) {
      // The same number over the same recipes is half the proof, so a first
      // photo that read badly still counts: the longer lines are enough, the
      // ones that tell one page from another, and half of those of the page
      // that has fewer.
      final mine = _longer(lines);
      final theirs = _longer(earlier.lines);
      final fewer = mine.length <= theirs.length ? mine : theirs;
      final shared = mine.where(theirs.contains).length;
      return shared >= 3 && shared * 2 >= fewer.length;
    }
    // With less to go by the text has to prove it alone, and recipes set to
    // one pattern can differ in a single short line. Only a photo that reads
    // the same, all but line for line, is the same page.
    final shared = lines.where(earlier.lines.contains).length;
    final most = lines.length > earlier.lines.length ? lines.length : earlier.lines.length;
    return shared >= 4 && shared * 10 >= most * 9;
  }

  static Set<String> _longer(Set<String> lines) => {
        for (final line in lines)
          if (line.length >= 8) line,
      };
}

/// Scan this book: photograph cookbook pages in one sitting and turn them
/// into recipes filed under [cookbookId].
///
/// Three steps on one screen: a short introduction, the pages being read, and
/// a review queue where each recipe can be corrected, merged, split or thrown
/// away before everything is added at once.
///
/// Pops with the number of recipes added.
class BookScanScreen extends ConsumerStatefulWidget {
  final String cookbookId;

  /// The cookbook's name, used in the source line ("My Cookbook, p. 142").
  final String bookTitle;

  /// Opens the device side of the scan. Tests pass their own.
  final Future<BookScanBackend> Function()? openBackend;

  /// Runs after recipes were saved, with their ids. Defaults to marking them
  /// for a shared cookbook and starting a sync, where what was added is
  /// synced at all. Tests pass their own.
  final Future<void> Function(List<String> recipeIds)? afterSave;

  const BookScanScreen({
    super.key,
    required this.cookbookId,
    required this.bookTitle,
    this.openBackend,
    this.afterSave,
  });

  @override
  ConsumerState<BookScanScreen> createState() => _BookScanScreenState();
}

class _BookScanScreenState extends ConsumerState<BookScanScreen> {
  _Stage _stage = _Stage.intro;
  BookScanBackend? _backend;
  Future<BookScanBackend>? _backendOpening;
  BookScanError? _error;
  bool _opening = false;

  /// Pages an earlier scan left on the device without ever reading them.
  List<String> _lostPages = const [];

  /// The cookbook the recipes go to. Sync can move it to a new id during the
  /// review, and the user is asked for another one when it is gone.
  late String _cookbookId = widget.cookbookId;
  StreamSubscription<SyncRekey>? _cookbookMoves;

  /// The scan, in the order of the book as far as that is known.
  final List<ScannedPage> _pages = [];
  final Map<ScannedPage, _PageFacts> _facts = Map.identity();
  List<int?> _pageNumbers = [];
  List<int> _pageSpans = [];
  int? _firstPageOverride;

  final List<_Item> _items = [];
  int _nextKey = 0;

  /// Recipes that have left the queue: discarded, or added to the cookbook.
  /// Reading their pages again does not bring them back.
  final List<_Item> _gone = [];

  int _readDone = 0;
  int _readTotal = 0;
  int _readRun = 0;

  /// Where a reading began, to go back to when it is cancelled.
  _Stage _readFrom = _Stage.intro;

  /// The page images being read, for the picture shown while waiting.
  List<String> _readPaths = const [];

  /// A save is under way. [_stage] says so too, but only this is never
  /// written by anything else.
  bool _saving = false;
  int _saveDone = 0;
  int _saveTotal = 0;

  /// How many recipes this scan has added so far.
  int _added = 0;

  Set<String> _existingTitles = const {};

  @override
  void initState() {
    super.initState();
    _cookbookMoves = SyncService.instance.rekeys.listen(_followCookbook);
    _loadExistingTitles();
    _findLostPages();
  }

  @override
  void dispose() {
    _cookbookMoves?.cancel();
    final backend = _backend;
    _backend = null;
    if (backend != null) unawaited(backend.close());
    super.dispose();
  }

  /// The first sync of an account can give a cookbook an id of its own. The
  /// recipes of this scan have to follow it there.
  void _followCookbook(SyncRekey move) {
    if (move.entity == 'cookbooks' && move.from == _cookbookId) _cookbookId = move.to;
  }

  /// Whether recipes may be added to [cookbookId]: always for the user's own
  /// cookbooks, and for a shared one only with the right to.
  bool _mayAddTo(String cookbookId) {
    final collab = CollabService.instance;
    return !collab.isCollabCookbook(cookbookId) || collab.canEditCookbook(cookbookId);
  }

  Future<void> _loadExistingTitles() async {
    try {
      final recipes = await ref.read(recipeDaoProvider).getAllRecipes(cookbookId: _cookbookId);
      if (!mounted) return;
      setState(() => _existingTitles = {for (final r in recipes) r.title.trim().toLowerCase()});
    } catch (_) {
      // Only used for a hint on the cards.
    }
  }

  /// Android can close the app underneath the scanner. The pages it took are
  /// then still on the device, and reading them beats scanning them again.
  Future<void> _findLostPages() async {
    try {
      final backend = await _ensureBackend();
      final lost = await backend.lostPages();
      if (!mounted || lost.isEmpty) return;
      setState(() => _lostPages = lost);
    } catch (_) {
      // Nothing to offer; scanning works as it always does.
    }
  }

  Future<BookScanBackend> _ensureBackend() {
    final existing = _backend;
    if (existing != null) return Future.value(existing);
    // One session however many ask: the look for lost pages may still be
    // opening it when the user starts a scan.
    return _backendOpening ??= _openBackend().whenComplete(() => _backendOpening = null);
  }

  Future<BookScanBackend> _openBackend() async {
    final open = widget.openBackend ?? BookScanSession.open;
    final backend = await open();
    if (!mounted) {
      unawaited(backend.close());
      throw const BookScanException(BookScanError.scannerFailed);
    }
    return _backend = backend;
  }

  // ───────────────────────── capture ─────────────────────────

  /// Opens the scanner or the photo picker and reads what comes back.
  ///
  /// With [forUnread] the pages are meant for the places of the ones that
  /// could not be read.
  Future<void> _capture({required bool fromPhotos, bool forUnread = false}) async {
    if (_opening || _saving || _stage == _Stage.reading) return;
    setState(() {
      _opening = true;
      _error = null;
    });
    List<String>? paths;
    try {
      final backend = await _ensureBackend();
      paths = fromPhotos ? await backend.pickPhotos() : await backend.capturePages(maxPages: 60);
    } on BookScanException catch (e) {
      _captureFailed(e.error, fromPhotos: fromPhotos, forUnread: forUnread);
      return;
    } catch (_) {
      _captureFailed(BookScanError.scannerFailed, fromPhotos: fromPhotos, forUnread: forUnread);
      return;
    }
    if (!mounted) return;
    setState(() => _opening = false);
    if (paths == null || paths.isEmpty) return;
    await _read(paths, forUnread: forUnread);
  }

  void _captureFailed(BookScanError error, {required bool fromPhotos, required bool forUnread}) {
    if (!mounted) return;
    setState(() {
      _error = error;
      _opening = false;
    });
    // The first screen has a place for the reason. Later there is none, so it
    // is said in passing, with the way round a scanner that will not open.
    if (_stage == _Stage.intro) return;
    final l10n = AppLocalizations.of(context)!;
    final message = error == BookScanError.cameraDenied ? l10n.bookScanCameraDenied : l10n.bookScanScannerFailed;
    if (fromPhotos) {
      AppSnackbar.error(context, message);
    } else {
      AppSnackbar.errorWithAction(
        context,
        message,
        actionLabel: l10n.bookScanChoosePhotosShort,
        onAction: () => _capture(fromPhotos: true, forUnread: forUnread),
      );
    }
  }

  Future<void> _read(List<String> paths, {bool forUnread = false}) async {
    final backend = _backend;
    if (backend == null || _saving || _stage == _Stage.reading) return;
    final run = ++_readRun;
    // An Undo still on screen belongs to the queue as it was.
    AppSnackbar.dismiss(context);
    _finishSwipes();

    setState(() {
      _readFrom = _stage;
      _stage = _Stage.reading;
      _readDone = 0;
      _readTotal = paths.length;
      _readPaths = paths;
    });

    final read = <ScannedPage>[];
    final facts = Map<ScannedPage, _PageFacts>.identity();
    for (final path in paths) {
      final page = await backend.readPage(path);
      // After a cancel the stage is no longer this reading's to set. It was
      // put back then, and a save or another reading may have begun since.
      if (!mounted || run != _readRun) return;
      // What the page says of itself is worked out here, a page at a time,
      // and not for all of them at once when the last one is in.
      final before = [..._pages, ...read].where((p) => !p.failed).toList();
      facts[page] = _PageFacts.of(page, beside: before.skip(before.length < 3 ? 0 : before.length - 3));
      read.add(page);
      setState(() => _readDone = read.length);
    }

    final placed = _place(read, facts, forUnread: forUnread);
    _integrate(fresh: placed.fresh, reread: placed.reread);
    HapticFeedback.mediumImpact();
    setState(() => _stage = _Stage.review);
  }

  void _cancelReading() {
    _readRun++;
    setState(() => _stage = _readFrom);
  }

  void _readLostPages() {
    if (_opening || _lostPages.isEmpty) return;
    _read(_lostPages);
  }

  // ───────────────────────── the scan ─────────────────────────

  /// Puts freshly read pages into the scan. Returns all of them as `fresh`,
  /// and as `reread` those that took the place of a page that had been read
  /// before.
  ///
  /// The scan is kept in the order of the book, because that is the order it
  /// is split into recipes in. So a page goes
  ///
  ///  * where the same page stood, when it was scanned before;
  ///  * where a page that could not be read stood, when it is that page;
  ///  * beside the page it follows or comes before, when its number says so;
  ///  * and otherwise at the end, as the next page of the book.
  ({Set<ScannedPage> fresh, Set<ScannedPage> reread}) _place(
    List<ScannedPage> read,
    Map<ScannedPage, _PageFacts> factsOf, {
    required bool forUnread,
  }) {
    // The first pages of a scan had nothing beside them when they were read.
    // The pages that came after them are there now.
    for (var i = 0; i < read.length && i < 2; i++) {
      read.skip(i + 1).take(2).forEach(factsOf[read[i]]!.lookBeside);
    }

    final fresh = Set<ScannedPage>.identity();
    final reread = Set<ScannedPage>.identity();
    // Those put at the end, one after the other as they were photographed.
    final inOrder = Set<ScannedPage>.identity();
    for (final page in read) {
      final facts = factsOf[page]!;
      var at = _pages.indexWhere((old) => facts.retakes(_facts[old]!));
      if (at < 0) at = _unreadPlaceFor(facts, fresh, asked: forUnread);
      if (at >= 0) {
        final old = _pages[at];
        // What it replaces decides what it is: a second reading, when that
        // page had been read, and text new to the scan when it never was.
        if (fresh.remove(old) ? reread.remove(old) : !old.failed) reread.add(page);
        if (inOrder.remove(old)) inOrder.add(page);
        _facts.remove(old);
        _pages[at] = page;
      } else {
        at = _placeBesideNeighbour(facts, inOrder);
        if (at < 0 || at >= _pages.length) {
          _pages.add(page);
          inOrder.add(page);
        } else {
          _pages.insert(at, page);
          _shiftPages(from: at);
        }
      }
      _facts[page] = facts;
      fresh.add(page);
    }
    return (fresh: fresh, reread: reread);
  }

  /// The place of a page that could not be read, which this one stands in
  /// for. -1 when there is none. Nothing is lost by replacing such a page, so
  /// one neighbour's number is proof enough. Pages in [taken] were placed by
  /// this same reading.
  int _unreadPlaceFor(_PageFacts facts, Set<ScannedPage> taken, {required bool asked}) {
    final number = facts.number;
    bool unread(int i) => _pages[i].failed && !taken.contains(_pages[i]);

    if (number != null) {
      for (var i = 0; i < _pages.length; i++) {
        if (!unread(i)) continue;
        final follows = i > 0 && _endsBefore(i - 1, number);
        final precedes = i + 1 < _pages.length && _beginsAt(i + 1, number + facts.span);
        if (follows || precedes) return i;
      }
    }
    if (!asked) return -1;
    // The user was told which pages could not be read and scanned again:
    // these are those pages, in order, unless a number puts one elsewhere.
    for (var i = 0; i < _pages.length; i++) {
      if (unread(i) && (number == null || _fitsAt(i, number, facts.span))) return i;
    }
    return -1;
  }

  /// Whether a page numbered [number] can stand at [i] without going against
  /// the numbers printed on the pages around it.
  bool _fitsAt(int i, int number, int span) {
    for (var b = i - 1; b >= 0; b--) {
      final before = _facts[_pages[b]]!;
      if (before.number == null) continue;
      if (before.number! + before.span > number) return false;
      break;
    }
    for (var a = i + 1; a < _pages.length; a++) {
      final after = _facts[_pages[a]]!.number;
      if (after == null) continue;
      if (number + span > after) return false;
      break;
    }
    return true;
  }

  /// Whether the page at [i] ends right before page [number], and its own
  /// number is one to go by.
  ///
  /// A number can be misread, or be no page number at all: a step number set
  /// in the margin reads just like one. Such a number is out of step with the
  /// pages around it, and no page is placed by it.
  bool _endsBefore(int i, int number) {
    final page = _facts[_pages[i]]!;
    return page.number != null && page.number! + page.span == number && _fitsAt(i, page.number!, page.span);
  }

  /// Whether the page at [i] begins at page [number], and its own number is
  /// one to go by. See [_endsBefore].
  bool _beginsAt(int i, int number) {
    final page = _facts[_pages[i]]!;
    return page.number == number && _fitsAt(i, number, page.span);
  }

  /// Where a page belongs by its printed number: straight after the page it
  /// follows in the book, or straight before the one it precedes. -1 when it
  /// has no number, when no page here is its neighbour, or when its number is
  /// already taken (a misread, or a page too different to be the same one).
  ///
  /// [inOrder] are the pages this same reading has put at the end so far. One
  /// of them without a number was photographed between the two neighbours,
  /// and stays between them: the page is then left at the end as well.
  int _placeBesideNeighbour(_PageFacts facts, Set<ScannedPage> inOrder) {
    final number = facts.number;
    if (number == null || _pages.any((p) => _facts[p]!.number == number)) return -1;
    for (var i = _pages.length - 1; i >= 0; i--) {
      if (!_endsBefore(i, number)) continue;
      final between = _pages.skip(i + 1).any((p) => inOrder.contains(p) && _facts[p]!.number == null);
      return between ? -1 : i + 1;
    }
    final next = number + facts.span;
    for (var i = 0; i < _pages.length; i++) {
      if (_beginsAt(i, next)) return i;
    }
    return -1;
  }

  /// A page was put in at [from]: every recipe that points at a page from
  /// there on now points one further.
  void _shiftPages({required int from}) {
    for (final item in [..._items, ..._gone]) {
      final draft = item.draft;
      draft.source = [for (final line in draft.source) line.page >= from ? line.onPage(1) : line];
      if (draft.startPage >= from) draft.startPage++;
      if (draft.endPage >= from) draft.endPage++;
    }
  }

  /// Reads the whole scan again and brings the review queue in line with it.
  ///
  /// The splitter is given every page, so a recipe that runs on from an
  /// earlier batch is joined up. What the user has decided stands:
  ///
  ///  * a recipe still as it was read takes the new reading, and when the
  ///    reading no longer has it, goes only if a new recipe stands in its
  ///    place;
  ///  * one that was edited, merged or cut in two stays as it is, and gains
  ///    only what a page in [fresh] adds to its end;
  ///  * one that was discarded, or added already, does not come back, unless
  ///    a page in [reread] now gives it differently.
  ///
  /// [fresh] are the pages just read. Those of them in [reread] took the place
  /// of a page that had been read before; the text of the others is new to the
  /// scan.
  void _integrate({required Set<ScannedPage> fresh, required Set<ScannedPage> reread}) {
    final result = BookPageSplitter.split(
      [for (final p in _pages) p.text],
      photoPages: photoPagesOf(_pages),
    );
    _pageSpans = result.pageSpans;
    _pageNumbers = _firstPageOverride != null
        ? BookPageSplitter.consecutivePageNumbers(_firstPageOverride!, _pageSpans)
        : result.pageNumbers;

    // A line is known by its page and its text, which a new reading of an
    // unchanged page gives back exactly.
    String keyOf(SourceLine line) => '${line.page}\n${line.text}';
    final freshPages = <int>{};
    final newPages = <int>{};
    for (var i = 0; i < _pages.length; i++) {
      if (fresh.contains(_pages[i])) freshPages.add(i);
      if (fresh.contains(_pages[i]) && !reread.contains(_pages[i])) newPages.add(i);
    }

    // The lines the user has settled, one way or the other.
    final gone = {
      for (final item in _gone)
        for (final line in item.draft.source) keyOf(line),
    };
    final shaped = {
      for (final item in _items)
        if (item.byHand)
          for (final line in item.draft.source) keyOf(line): item,
    };
    // The recipes a new reading may replace, by the line they begin on.
    final asRead = {
      for (final item in _items)
        if (!item.byHand && item.draft.source.isNotEmpty) keyOf(item.draft.source.first): item,
    };
    final outdated = Set<_Item>.identity()..addAll(asRead.values);

    // The pages on which a recipe is no longer found on the line it began
    // on. What the reading gives there may be that recipe in another shape.
    final starts = {
      for (final draft in result.drafts)
        if (draft.source.isNotEmpty) keyOf(draft.source.first),
    };
    final unsettled = {
      for (final item in [..._items, ..._gone])
        if (!item.byHand && item.draft.source.isNotEmpty && !starts.contains(keyOf(item.draft.source.first)))
          for (final line in item.draft.source) line.page,
    };

    // What this reading adds to the queue: the lines of the new recipes, and
    // the pages they are on.
    final added = <String>{};
    final addedOn = <int>{};

    final queue = List<_Item>.of(_items);
    final pagesOf = <_Item, Set<int>>{};
    final more = <_Item, List<SourceLine>>{};
    var at = 0;
    for (final draft in result.drafts) {
      if (_firstPageOverride != null) {
        draft.pageLabel = BookPageSplitter.pageLabelOf(draft.source, _pageNumbers);
      }
      final first = draft.source.isEmpty ? '' : keyOf(draft.source.first);
      final same = asRead.remove(first);
      if (same != null) {
        same.draft = draft;
        outdated.remove(same);
        at = queue.indexOf(same) + 1;
        continue;
      }

      // Not a recipe the queue has as it was read. It is new unless the user
      // has dealt with it: it is mostly made of the lines of recipes they
      // shaped, or has most of the lines of one, or is line for line a recipe
      // that is gone. Only lines the scan had before can tell: those on a new
      // page are an addition, not a difference. A page that reads differently
      // the second time is offered again, whatever became of its first
      // reading.
      var held = 0;
      var lost = 0;
      var known = 0;
      final heldOf = <_Item, int>{};
      for (final line in draft.source) {
        final key = keyOf(line);
        final holder = shaped[key];
        if (holder != null) {
          held++;
          heldOf[holder] = (heldOf[holder] ?? 0) + 1;
        } else if (gone.contains(key)) {
          lost++;
        }
        if (!newPages.contains(line.page)) known++;
      }
      final dealtWith = held * 2 > known ||
          (known > 0 && held + lost == known) ||
          heldOf.entries.any((of) => of.value * 2 > of.key.draft.source.length);
      if (!dealtWith) {
        queue.insert(at++, _Item('scan_${_nextKey++}', draft, const DraftImage(0)));
        for (final line in draft.source) {
          added.add(keyOf(line));
          addedOn.add(line.page);
        }
        continue;
      }

      // What a page adds after the lines of a recipe that was kept is still
      // part of it, unless a recipe that stood on that page has lost its
      // beginning there: then the lines may be that recipe's. What follows
      // the lines of one that is gone went with it.
      _Item? owner;
      for (final line in draft.source) {
        final key = keyOf(line);
        final holder = shaped[key];
        if (holder != null) {
          owner = holder;
          final after = queue.indexOf(holder) + 1;
          if (after > at) at = after;
        } else if (gone.contains(key)) {
          owner = null;
        } else if (owner != null && freshPages.contains(line.page) && !unsettled.contains(line.page)) {
          final own = pagesOf[owner] ??= {for (final l in owner.draft.source) l.page};
          if (!own.contains(line.page)) (more[owner] ??= []).add(line);
        }
      }
    }

    // A recipe the new reading no longer finds where it began goes when a
    // recipe new to the queue stands in its place: one that has lines of it,
    // or, once its page was read again and gave none of its lines back, one
    // on that page. Otherwise it stays as it was read. A second photo can
    // lose a heading the first one had, and the lines under it then run on
    // from the recipe before: a card is not lost to that.
    final read = {
      for (final draft in result.drafts)
        for (final line in draft.source) keyOf(line),
    };
    queue.removeWhere((item) {
      if (!outdated.contains(item)) return false;
      final lines = item.draft.source;
      if (lines.any((line) => added.contains(keyOf(line)))) return true;
      return lines.any((line) => freshPages.contains(line.page)) &&
          !lines.any((line) => read.contains(keyOf(line))) &&
          lines.any((line) => addedOn.contains(line.page));
    });
    more.forEach(_extend);
    // Whoever did not take the new reading has a page label from an earlier
    // one, when it was not typed in.
    for (final item in queue) {
      if (!item.ownLabel && (item.byHand || outdated.contains(item))) {
        item.draft.pageLabel = BookPageSplitter.pageLabelOf(item.draft.source, _pageNumbers);
      }
    }
    _items
      ..clear()
      ..addAll(queue);
    _assignImages();
  }

  static final _sentenceEnd = RegExp(r'[.!?:]["”’)]?$');
  static final _brokenWord = RegExp(r'\p{Ll}-$', unicode: true);
  static final _lowerStart = RegExp(r'^\p{Ll}', unicode: true);
  static final _upperStart = RegExp(r'^[^\p{L}\p{N}]*\p{Lu}', unicode: true);

  /// Two lines of one paragraph as running text. A word broken across the
  /// lines is made whole again.
  static String _joined(String start, String rest) => _brokenWord.hasMatch(start) && _lowerStart.hasMatch(rest)
      ? start.substring(0, start.length - 1) + rest
      : '$start $rest';

  /// Adds lines read from a later page to the end of a recipe the user has
  /// shaped by hand: a step for each paragraph, in the order they were read.
  void _extend(_Item item, List<SourceLine> lines) {
    final steps = <String>[];
    int? block;
    for (final line in lines) {
      if (steps.isEmpty || line.paragraphStart || line.block != block) {
        steps.add(line.text);
      } else {
        steps.last = _joined(steps.last, line.text);
      }
      block = line.block;
    }

    final draft = item.draft;
    final written = draft.recipe.instructions;
    // A step the page break cut off in the middle goes on where it stopped.
    final cutOff = written.isNotEmpty &&
        !_sentenceEnd.hasMatch(written.last.trim()) &&
        !_upperStart.hasMatch(steps.first);
    draft.recipe.instructions = cutOff
        ? [...written.take(written.length - 1), _joined(written.last.trim(), steps.first), ...steps.skip(1)]
        : [...written, ...steps];
    draft.source = [...draft.source, ...lines];
    for (final line in lines) {
      if (line.page < draft.startPage) draft.startPage = line.page;
      if (line.page > draft.endPage) draft.endPage = line.page;
    }
  }

  void _assignImages() {
    final images = assignDraftImages(
      [for (final i in _items) i.draft],
      _pages,
      pageNumbers: _pageNumbers,
    );
    for (var i = 0; i < _items.length; i++) {
      _items[i].image = images[i];
    }
  }

  // ───────────────────────── review actions ─────────────────────────

  Future<void> _edit(_Item item) async {
    final label = item.draft.pageLabel;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BookScanEditScreen(
          draft: item.draft,
          pages: _pages,
          pageNumbers: _pageNumbers,
        ),
      ),
    );
    if (changed == true && mounted) {
      setState(() {
        item.edited = true;
        item.byHand = true;
        if (item.draft.pageLabel != label) item.ownLabel = true;
      });
    }
  }

  void _discard(_Item item) {
    final l10n = AppLocalizations.of(context)!;
    final index = _items.indexOf(item);
    if (index < 0) return;
    setState(() {
      _items.removeAt(index);
      _gone.add(item);
    });
    AppSnackbar.successWithAction(
      context,
      l10n.bookScanDiscarded,
      actionLabel: l10n.actionUndo,
      onAction: () {
        // Nothing comes back into a queue that is being added or read anew.
        if (!mounted || _stage != _Stage.review || !_gone.remove(item)) return;
        setState(() => _items.insert(index.clamp(0, _items.length), item..leaving = false));
      },
    );
  }

  /// A card swiped past the point of no return is discarded, though it stays
  /// in the list while it slides away. What is about to happen to the queue
  /// does not wait for that.
  void _finishSwipes() {
    final leaving = [
      for (final item in _items)
        if (item.leaving) item,
    ];
    if (leaving.isEmpty) return;
    setState(() {
      _items.removeWhere((item) => item.leaving);
      _gone.addAll(leaving);
    });
  }

  void _mergeWithNext(_Item item) {
    final l10n = AppLocalizations.of(context)!;
    final index = _items.indexOf(item);
    if (index < 0 || index + 1 >= _items.length) return;
    final next = _items[index + 1];
    final merged = _Item(
      'scan_${_nextKey++}',
      BookPageSplitter.merge(item.draft, next.draft),
      item.image,
    )
      ..edited = item.edited || next.edited
      ..byHand = true
      ..ownLabel = item.ownLabel || next.ownLabel;
    setState(() {
      _items
        ..removeAt(index + 1)
        ..[index] = merged;
      _assignImages();
    });
    AppSnackbar.successWithAction(
      context,
      l10n.bookScanMerged,
      actionLabel: l10n.actionUndo,
      onAction: () {
        if (!mounted || _stage != _Stage.review) return;
        final at = _items.indexOf(merged);
        if (at < 0) return;
        setState(() {
          _items
            ..[at] = item
            ..insert(at + 1, next);
          _assignImages();
        });
      },
    );
  }

  Future<void> _split(_Item item) async {
    final l10n = AppLocalizations.of(context)!;
    final line = await Responsive.showAdaptiveSheet<int>(
      context,
      builder: (ctx) => _SplitSheet(
        lines: item.draft.source,
        pageNumbers: _pageNumbers,
        edited: item.edited,
      ),
    );
    if (line == null || !mounted) return;
    final halves = BookPageSplitter.splitAt(item.draft, line, _pageNumbers);
    final index = _items.indexOf(item);
    if (halves == null || index < 0) {
      AppSnackbar.error(context, l10n.bookScanSplitFailed);
      return;
    }
    setState(() {
      _items
        ..[index] = (_Item('scan_${_nextKey++}', halves.$1, item.image)..byHand = true)
        ..insert(index + 1, _Item('scan_${_nextKey++}', halves.$2, item.image)..byHand = true);
      _assignImages();
    });
  }

  void _showActions(_Item item) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final index = _items.indexOf(item);
    final hasNext = index >= 0 && index + 1 < _items.length;
    Responsive.showAdaptiveSheet<void>(
      context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Space.sm),
            const SheetHandle(top: 0),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.xl, Space.md, Space.xl, Space.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _titleOf(item, l10n),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.actionEdit),
              onTap: () {
                Navigator.pop(ctx);
                _edit(item);
              },
            ),
            if (hasNext)
              ListTile(
                leading: const Icon(Icons.merge_rounded),
                title: Text(l10n.bookScanMergeNext),
                onTap: () {
                  Navigator.pop(ctx);
                  _mergeWithNext(item);
                },
              ),
            if (item.draft.source.length > 1)
              ListTile(
                leading: const Icon(Icons.call_split_rounded),
                title: Text(l10n.bookScanSplit),
                onTap: () {
                  Navigator.pop(ctx);
                  _split(item);
                },
              ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: c.destructive),
              title: Text(l10n.actionDiscard, style: TextStyle(color: c.destructive)),
              onTap: () {
                Navigator.pop(ctx);
                _discard(item);
              },
            ),
            const SizedBox(height: Space.sm),
          ],
        ),
      ),
    );
  }

  Future<void> _setPageNumbers() async {
    final current = _pageNumbers.isNotEmpty ? _pageNumbers.first : null;
    final first = await showDialog<int>(
      context: context,
      builder: (ctx) => _PageNumberDialog(initial: current),
    );
    if (first == null || !mounted) return;
    setState(() {
      _firstPageOverride = first;
      _pageNumbers = BookPageSplitter.consecutivePageNumbers(
        first,
        _pageSpans.length == _pages.length ? _pageSpans : List.filled(_pages.length, 1),
      );
      for (final item in _items) {
        item.draft.pageLabel = BookPageSplitter.pageLabelOf(item.draft.source, _pageNumbers);
        item.ownLabel = false;
      }
      // Left and right pages may have swapped, and with them which recipe a
      // full-page photograph faces.
      _assignImages();
    });
  }

  // ───────────────────────── save ─────────────────────────

  String _titleOf(_Item item, AppLocalizations l10n) =>
      item.draft.titleFound && item.draft.recipe.title.trim().isNotEmpty
          ? item.draft.recipe.title.trim()
          : l10n.bookScanUntitled;

  /// "The Weeknight Kitchen, p. 142" for the recipe's source field.
  String _sourceOf(_Item item, AppLocalizations l10n) {
    final book = widget.bookTitle.trim();
    final label = item.draft.pageLabel?.trim();
    if (label == null || label.isEmpty) return book;
    return label.contains('-') || label.contains('–')
        ? l10n.bookScanSourcePages(book, label)
        : l10n.bookScanSource(book, label);
  }

  Future<void> _addAll() async {
    final backend = _backend;
    if (backend == null || _saving || _opening || _stage != _Stage.review) return;
    _finishSwipes();
    if (_items.isEmpty) return;
    _saving = true;
    try {
      await _save(backend);
    } finally {
      _saving = false;
    }
  }

  Future<void> _save(BookScanBackend backend) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_mayAddTo(_cookbookId)) {
      AppSnackbar.error(context, l10n.bookScanReadOnly);
      return;
    }
    final cookbooks = ref.read(cookbookDaoProvider);
    final Cookbook? cookbook;
    try {
      cookbook = await _cookbookToAddTo(l10n);
    } catch (e) {
      debugPrint('[BookScan] could not look up the cookbook: $e');
      if (mounted) AppSnackbar.error(context, l10n.bookScanAddFailed(_items.length));
      return;
    }
    if (cookbook == null || !mounted) return;

    // An Undo still on screen has nothing to undo once the recipes go in.
    AppSnackbar.dismiss(context);
    final db = ref.read(databaseProvider);
    final queue = List<_Item>.of(_items);
    setState(() {
      _stage = _Stage.saving;
      _saveDone = 0;
      _saveTotal = queue.length;
    });

    final savedIds = <String>[];
    var failed = 0;
    for (final item in queue) {
      String? imagePath;
      var saved = false;
      var cookbookGone = false;
      try {
        if (item.image.page >= 0 && item.image.page < _pages.length) {
          imagePath = await backend.saveRecipeImage(
            _pages[item.image.page],
            crop: item.image.crop,
            recipeId: item.key,
          );
        }
        // The cookbook can be deleted from another device at any moment, and
        // a recipe saved after that would be in no cookbook at all. So it is
        // looked up once more, as late as can be.
        cookbookGone = await cookbooks.getCookbookById(_cookbookId) == null;
        if (!cookbookGone) {
          final r = item.draft.recipe;
          final id = await ImportedRecipeSaver.save(
            db,
            cookbookId: _cookbookId,
            sectionHeadings: true,
            imagePath: imagePath,
            recipe: ImportedRecipe(
              title: _titleOf(item, l10n),
              description: r.description,
              servings: r.servings,
              prepTimeMinutes: r.prepTimeMinutes,
              cookTimeMinutes: r.cookTimeMinutes,
              ingredients: r.ingredients,
              instructions: r.instructions,
              notes: r.notes,
              sourceUrl: _sourceOf(item, l10n),
              suggestedCourse: r.suggestedCourse,
              suggestedCategory: r.suggestedCategory,
            ),
          );
          savedIds.add(id);
          item.saved = saved = true;
        }
      } catch (e) {
        debugPrint('[BookScan] could not save "${item.draft.recipe.title}": $e');
      }
      if (!saved) {
        // The picture was written first, for a recipe that is not there.
        if (imagePath != null) await backend.discardRecipeImage(imagePath);
        failed++;
      }
      if (!mounted) return;
      if (cookbookGone) {
        // Neither this recipe nor any after it has a cookbook to go to.
        failed += queue.length - queue.indexOf(item) - 1;
        break;
      }
      setState(() => _saveDone++);
    }

    _added += savedIds.length;
    // Should one of them turn up again on a page scanned later, its card says
    // that it is in the cookbook already.
    _existingTitles = {
      ..._existingTitles,
      for (final item in queue)
        if (item.saved) _titleOf(item, l10n).toLowerCase(),
    };
    if (savedIds.isNotEmpty) {
      try {
        await (widget.afterSave ?? _markAndSync)(savedIds);
      } catch (_) {
        // Saved locally either way; sync will pick them up later.
      }
    }
    if (!mounted) return;

    if (failed == 0) {
      // The saved recipes stay in the list: the screen closes on them, not on
      // an empty page.
      HapticFeedback.mediumImpact();
      AppSnackbar.success(context, l10n.bookScanAdded(savedIds.length, cookbook.name));
      Navigator.of(context).pop(_added);
    } else {
      setState(() {
        _gone.addAll(_items.where((item) => item.saved));
        _items.removeWhere((item) => item.saved);
        _stage = _Stage.review;
      });
      AppSnackbar.error(context, l10n.bookScanAddFailed(failed));
    }
  }

  /// The cookbook the recipes go to, looked up now: it can have been deleted
  /// since the scan began. Then the user is asked for another one, and null
  /// means there is none to add to.
  Future<Cookbook?> _cookbookToAddTo(AppLocalizations l10n) async {
    final cookbooks = ref.read(cookbookDaoProvider);
    final cookbook = await cookbooks.getCookbookById(_cookbookId);
    if (cookbook != null || !mounted) return cookbook;

    final others = [
      for (final other in await cookbooks.getAllCookbooks())
        if (_mayAddTo(other.id)) other,
    ];
    if (!mounted) return null;
    if (others.isEmpty) {
      AppSnackbar.error(context, l10n.bookScanCookbookGone(widget.bookTitle));
      return null;
    }
    final chosen = await showScanCookbookPicker(
      context,
      cookbooks: others,
      title: l10n.bookScanChooseCookbookTitle,
      message: l10n.bookScanCookbookGoneChoose(widget.bookTitle),
    );
    if (chosen == null || !mounted) return null;
    _cookbookId = chosen.id;
    unawaited(_loadExistingTitles());
    return chosen;
  }

  Future<void> _markAndSync(List<String> ids) async {
    final collab = CollabService.instance;
    if (collab.canEditCookbook(_cookbookId)) {
      for (final id in ids) {
        await collab.markRecipeDirty(id);
      }
      // A shared cookbook syncs on every plan, as it does from the recipe
      // editor.
      unawaited(SyncService.instance.sync());
      return;
    }
    // The user's own recipes leave the device only with Cloud Sync. The sync
    // provider knows the plan, and does nothing without it.
    unawaited(ref.read(syncProvider.notifier).autoSync(force: true));
  }

  // ───────────────────────── leaving ─────────────────────────

  Future<bool> _confirmLeave() async {
    if (_saving || _stage == _Stage.saving) return false;
    if (_stage == _Stage.reading) {
      _cancelReading();
      return false;
    }
    if (_items.isEmpty) return true;
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.bookScanDiscardTitle),
        content: Text(l10n.bookScanDiscardBody(_items.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.bookScanKeepReviewing),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: c.destructive, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionDiscard),
          ),
        ],
      ),
    );
    return discard == true;
  }

  // ───────────────────────── build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final reviewing = _stage == _Stage.review || _stage == _Stage.saving;
    // What is added leaves the device for a shared cookbook on any plan, and
    // for the user's own with Cloud Sync. The first screen says which it is.
    final synced = CollabService.instance.canEditCookbook(_cookbookId) ||
        (ref.watch(authProvider.select((auth) => auth.isSignedIn)) &&
            ref.watch(subscriptionProvider.select((plan) => plan.tier.hasCloudSync)));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        // Recipes added before a save that partly failed still count.
        if (await _confirmLeave() && mounted) nav.pop(_added > 0 ? _added : result);
      },
      child: Scaffold(
        backgroundColor: c.surface,
        appBar: AppBar(
          backgroundColor: c.surface,
          centerTitle: false,
          titleSpacing: 0,
          // The first two steps carry their own headline in the page.
          title: !reviewing
              ? null
              : Padding(
                  padding: const EdgeInsetsDirectional.only(end: Space.sm),
                  child: FittedBox(
                    // The count matters more than the size of the type: shrink
                    // rather than cut it off on a narrow phone with large text.
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: TouchPageTitle(
                      _items.isEmpty && _stage == _Stage.review
                          ? l10n.bookScanAction
                          : l10n.bookScanFound(_stage == _Stage.saving ? _saveTotal : _items.length),
                    ),
                  ),
                ),
          actions: [
            if (_stage == _Stage.review && _items.isNotEmpty)
              // The scanner or photos already taken: someone whose camera is
              // off, or who began with photos, needs the second way as much
              // as the first.
              PopupMenuButton<bool>(
                icon: Icon(Icons.add_a_photo_outlined, color: c.textSecondary),
                tooltip: l10n.bookScanMore,
                enabled: !_opening,
                onSelected: (fromPhotos) => _capture(fromPhotos: fromPhotos),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: false,
                    child: Row(
                      children: [
                        const Icon(Icons.document_scanner_outlined),
                        const SizedBox(width: Space.md),
                        Flexible(child: Text(l10n.bookScanAction)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: true,
                    child: Row(
                      children: [
                        const Icon(Icons.photo_library_outlined),
                        const SizedBox(width: Space.md),
                        Flexible(child: Text(l10n.bookScanChoosePhotosShort)),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(width: Space.xs),
          ],
        ),
        body: AnimatedSwitcher(
          duration: Motion.base,
          switchInCurve: Motion.standard,
          switchOutCurve: Motion.standard,
          child: KeyedSubtree(
            key: ValueKey(reviewing ? 'review' : _stage.name),
            child: switch (_stage) {
              _Stage.intro => _buildIntro(l10n),
              _Stage.reading => _buildReading(l10n),
              _Stage.review || _Stage.saving => _buildReview(l10n),
            },
          ),
        ),
        bottomNavigationBar: switch (_stage) {
          _Stage.intro => _IntroActions(
              busy: _opening,
              startLabel: l10n.bookScanStart,
              photosLabel: _error != null ? l10n.bookScanChoosePhotosShort : l10n.bookScanChoosePhotos,
              privacy: synced ? l10n.bookScanPrivacySynced : l10n.bookScanPrivacy,
              photosFirst: _error != null,
              onStart: () => _capture(fromPhotos: false),
              onPhotos: () => _capture(fromPhotos: true),
            ),
          _Stage.reading => null,
          _Stage.review || _Stage.saving => _items.isEmpty
              ? null
              : BookScanBottomBar(
                  icon: Icons.check_rounded,
                  label: _stage == _Stage.saving
                      ? l10n.bookScanAdding(
                          (_saveDone + 1).clamp(1, _saveTotal == 0 ? 1 : _saveTotal),
                          _saveTotal,
                        )
                      : l10n.bookScanAddAll(_items.length),
                  progress: _stage == _Stage.saving
                      ? (_saveTotal == 0 ? 0 : _saveDone / _saveTotal)
                      : null,
                  // Not while the scanner is being opened for more pages.
                  onPressed: _opening ? null : _addAll,
                ),
        },
      ),
    );
  }

  Widget _buildIntro(AppLocalizations l10n) {
    final c = context.appColors;
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.xxl, Space.sm, Space.xxl, Space.xxl),
          children: [
            // Once there is a notice it is what matters; the badge makes room
            // for it so the whole page still fits without a scroll.
            if (_error == null && _lostPages.isEmpty) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: c.selectedFill, shape: BoxShape.circle),
                  child: Icon(Icons.document_scanner_outlined, size: 34, color: c.accent),
                ),
              ),
              const SizedBox(height: Space.xl),
            ],
            Text(
              l10n.bookScanIntroTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.15,
                letterSpacing: -0.3,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: Space.sm),
            Text(
              l10n.bookScanIntroBody(widget.bookTitle),
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15.5, height: 1.5, color: c.textSecondary),
            ),
            const SizedBox(height: Space.xl),
            if (_error != null) ...[
              ScanNotice(
                warning: true,
                icon: _error == BookScanError.cameraDenied
                    ? Icons.no_photography_outlined
                    : Icons.error_outline_rounded,
                text: _error == BookScanError.cameraDenied
                    ? l10n.bookScanCameraDenied
                    : l10n.bookScanScannerFailed,
              ),
              const SizedBox(height: Space.lg),
            ],
            if (_lostPages.isNotEmpty) ...[
              ScanNotice(
                icon: Icons.restore_page_outlined,
                text: l10n.bookScanLostPages(_lostPages.length),
                action: ScanPillButton(
                  icon: Icons.auto_stories_outlined,
                  label: l10n.bookScanReadLostPages(_lostPages.length),
                  prominent: true,
                  onPressed: _readLostPages,
                ),
              ),
              const SizedBox(height: Space.lg),
            ],
            ScanTip(
              icon: Icons.wb_sunny_outlined,
              title: l10n.bookScanTipLightTitle,
              body: l10n.bookScanTipLightBody,
            ),
            ScanTip(
              icon: Icons.auto_stories_outlined,
              title: l10n.bookScanTipOrderTitle,
              body: l10n.bookScanTipOrderBody,
            ),
            ScanTip(
              icon: Icons.bookmark_border_rounded,
              title: l10n.bookScanTipPagesTitle,
              body: l10n.bookScanTipPagesBody,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReading(AppLocalizations l10n) {
    final c = context.appColors;
    final theme = Theme.of(context);
    final total = _readTotal == 0 ? 1 : _readTotal;
    final current = (_readDone + 1).clamp(1, total);
    final done = _readDone >= total;
    final path = _readPaths.isEmpty ? null : _readPaths[(current - 1).clamp(0, _readPaths.length - 1)];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Space.xxxl, Space.lg, Space.xxxl, Space.xxxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 356),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The page being read, so the wait shows what it is for.
              if (path != null) ...[
                SizedBox(
                  width: 132,
                  height: 176,
                  child: AnimatedSwitcher(
                    duration: Motion.slow,
                    switchInCurve: Motion.standard,
                    switchOutCurve: Motion.standard,
                    child: DecoratedBox(
                      key: ValueKey(path),
                      decoration: BoxDecoration(
                        borderRadius: Radii.lgAll,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: SizedBox.expand(
                        child: ExcludeSemantics(
                          child: ScanPageImage(path: path, borderRadius: Radii.lgAll),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Space.xxl),
              ],
              Text(
                l10n.bookScanReadingTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: Space.sm),
              Text(
                done ? l10n.bookScanFindingRecipes : l10n.bookScanReadingProgress(current, total),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: Space.xl),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _readDone / total,
                  minHeight: 6,
                  color: c.accent,
                  backgroundColor: c.textPrimary.withValues(alpha: 0.08),
                ),
              ),
              const SizedBox(height: Space.lg),
              TextButton(onPressed: _cancelReading, child: Text(l10n.actionCancel)),
            ],
          ),
        ),
      ),
    );
  }

  /// Which pages could not be read, by their place in the scan, or null when
  /// every page was read.
  String? _unreadText(AppLocalizations l10n) {
    final places = [
      for (var i = 0; i < _pages.length; i++)
        if (_pages[i].failed) i + 1,
    ];
    if (places.isEmpty) return null;
    // Past a handful, a list of places is no easier to follow than a count.
    return places.length > 6
        ? l10n.bookScanUnreadPages(places.length)
        : l10n.bookScanUnreadPhotos(places.length, places.join(', '));
  }

  /// The review step with nothing in the queue. It says why: no page could
  /// be read, none of them held a recipe, or the user has dealt with every
  /// recipe that was found.
  Widget _buildNothingToReview(AppLocalizations l10n) {
    final unread = _pages.where((p) => p.failed).length;
    final unreadText = _unreadText(l10n);
    // While pages are unread, a new scan is of those pages first.
    VoidCallback? scan({required bool fromPhotos}) =>
        _opening ? null : () => _capture(fromPhotos: fromPhotos, forUnread: unread > 0);
    final notice = unreadText == null ? null : ScanNotice(icon: Icons.info_outline_rounded, text: unreadText);

    if (_gone.isNotEmpty) {
      return ScanEmptyState(
        icon: Icons.task_alt_rounded,
        title: l10n.bookScanNothingLeftTitle,
        message: l10n.bookScanNothingLeftBody,
        notice: notice,
        scanLabel: l10n.bookScanMore,
        photosLabel: l10n.bookScanChoosePhotos,
        onScan: scan(fromPhotos: false),
        onPhotos: scan(fromPhotos: true),
      );
    }
    if (_pages.isNotEmpty && unread == _pages.length) {
      return ScanEmptyState(
        icon: Icons.image_not_supported_outlined,
        title: l10n.bookScanNothingReadTitle,
        message: l10n.bookScanNothingReadBody(unread),
        scanLabel: l10n.bookScanTryAgain,
        photosLabel: l10n.bookScanChoosePhotos,
        onScan: scan(fromPhotos: false),
        onPhotos: scan(fromPhotos: true),
      );
    }
    return ScanEmptyState(
      icon: Icons.find_in_page_outlined,
      title: l10n.bookScanEmptyTitle,
      message: l10n.bookScanEmptyBody,
      notice: notice,
      scanLabel: l10n.bookScanTryAgain,
      photosLabel: l10n.bookScanChoosePhotos,
      onScan: scan(fromPhotos: false),
      onPhotos: scan(fromPhotos: true),
    );
  }

  Widget _buildReview(AppLocalizations l10n) {
    final saving = _stage == _Stage.saving;

    if (_items.isEmpty) return _buildNothingToReview(l10n);

    final wide = Responsive.useNavRail(context);
    final side = wide ? Space.xxl : Space.lg;

    return AbsorbPointer(
      // The queue is also left alone while the scanner is being opened: the
      // pages it brings back are read into the recipes, and an editor opened
      // just before would go on showing one as it was.
      absorbing: saving || _opening,
      child: AnimatedOpacity(
        duration: Motion.base,
        opacity: saving ? 0.55 : 1,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(side, 0, side, Space.xxl),
              itemCount: _items.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return _ReviewHeader(
                    bookTitle: widget.bookTitle,
                    pageCount: _pages.length,
                    range: _pageRange(l10n),
                    unreadText: _unreadText(l10n),
                    onPageNumbers: _setPageNumbers,
                    onScanUnread: () => _capture(fromPhotos: false, forUnread: true),
                    onPhotosForUnread: () => _capture(fromPhotos: true, forUnread: true),
                  );
                }
                final item = _items[i - 1];
                return Padding(
                  key: ValueKey(item.key),
                  padding: const EdgeInsets.only(bottom: Space.md),
                  child: _card(item, l10n),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// "pp. 142-161" for the whole scan, or null when no number is known.
  String? _pageRange(AppLocalizations l10n) {
    final known = [for (final n in _pageNumbers) if (n != null) n];
    if (known.isEmpty) return null;
    final first = known.reduce((a, b) => a < b ? a : b);
    var last = known.reduce((a, b) => a > b ? a : b);
    if (_pageSpans.isNotEmpty && _pageSpans.last == 2 && _pageNumbers.isNotEmpty && _pageNumbers.last == last) {
      last += 1;
    }
    return first == last ? l10n.bookScanPage('$first') : l10n.bookScanPages('$first-$last');
  }

  Widget _card(_Item item, AppLocalizations l10n) {
    final draft = item.draft;
    final issues = draft.issues;
    final title = _titleOf(item, l10n);
    final label = draft.pageLabel?.trim();

    final meta = [
      l10n.bookScanIngredientCount(draft.ingredientCount),
      l10n.bookScanStepCount(draft.stepCount),
      if (label != null && label.isNotEmpty)
        label.contains('-') ? l10n.bookScanPages(label) : l10n.bookScanPage(label),
    ].join(_dot);

    final names = [
      for (final line in draft.recipe.ingredients)
        if (!isSectionHeading(line)) line,
    ];
    final preview = names.take(3).join(_dot);

    final page = item.image.page >= 0 && item.image.page < _pages.length ? _pages[item.image.page] : null;
    // Not on a card that is itself being added just now.
    final duplicate = !item.saved && draft.titleFound && _existingTitles.contains(title.toLowerCase());

    return Semantics(
      container: true,
      child: Dismissible(
        key: ValueKey('dismiss_${item.key}'),
        direction: DismissDirection.endToStart,
        // Past the threshold the card is as good as gone, though it is still
        // on its way out of the list.
        onUpdate: (details) => item.leaving = details.reached,
        // A card that had not got that far when adding began is being added.
        // It slides back, and is not discarded under the save.
        confirmDismiss: (_) async => !_saving,
        onDismissed: (_) => _discard(item),
        background: const _DismissBackground(),
        child: BookScanDraftCard(
          image: page == null
              ? const SizedBox.shrink()
              : ScanPageImage(path: page.imagePath, crop: item.image.crop, aspectRatio: page.aspectRatio),
          title: title,
          untitled: !draft.titleFound,
          meta: meta,
          preview: preview.isEmpty ? null : preview,
          moreTooltip: l10n.bookScanOptions,
          onTap: () => _edit(item),
          onMore: () => _showActions(item),
          pills: [
            if (issues.contains(BookDraftIssue.noTitle))
              ScanPill(icon: Icons.title_rounded, label: l10n.bookScanIssueTitle),
            if (issues.contains(BookDraftIssue.noIngredients))
              ScanPill(icon: Icons.error_outline_rounded, label: l10n.bookScanIssueIngredients),
            if (issues.contains(BookDraftIssue.noSteps))
              ScanPill(icon: Icons.error_outline_rounded, label: l10n.bookScanIssueSteps),
            if (duplicate)
              ScanPill(
                icon: Icons.bookmark_added_outlined,
                label: l10n.bookScanDuplicate,
                tone: ScanPillTone.quiet,
              ),
          ],
        ),
      ),
    );
  }
}

/// The swipe-to-discard backdrop behind a recipe card.
class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: Space.xl),
      decoration: BoxDecoration(
        color: c.destructive.withValues(alpha: 0.12),
        borderRadius: Radii.lgAll,
      ),
      child: Icon(Icons.delete_outline_rounded, color: c.destructive),
    );
  }
}

/// The book and page summary above the review list.
class _ReviewHeader extends StatelessWidget {
  final String bookTitle;
  final int pageCount;
  final String? range;
  final String? unreadText;
  final VoidCallback onPageNumbers;

  /// Scan the unread pages again, with the scanner or from photos.
  final VoidCallback onScanUnread;
  final VoidCallback onPhotosForUnread;

  const _ReviewHeader({
    required this.bookTitle,
    required this.pageCount,
    required this.range,
    required this.unreadText,
    required this.onPageNumbers,
    required this.onScanUnread,
    required this.onPhotosForUnread,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final summary = [
      l10n.bookScanPageCount(pageCount),
      range ?? l10n.bookScanNoPageNumbers,
    ].join(_dot);

    return Padding(
      padding: const EdgeInsets.only(top: Space.xs, bottom: Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bookTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, height: 1.3, fontWeight: FontWeight.w600, color: c.textSecondary),
          ),
          const SizedBox(height: Space.xs),
          // Side by side while there is room; the button drops under the
          // summary on a narrow phone or with large text.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Space.md,
              runSpacing: Space.sm,
              children: [
                Text(
                  summary,
                  style: TextStyle(fontSize: 13, height: 1.35, color: c.textTertiary),
                ),
                ScanPillButton(
                  icon: Icons.edit_outlined,
                  label: range == null ? l10n.bookScanSetPageNumbers : l10n.bookScanChangePageNumbers,
                  // No numbers yet: setting them is the thing to do here.
                  prominent: range == null,
                  onPressed: onPageNumbers,
                ),
              ],
            ),
          ),
          if (unreadText != null) ...[
            const SizedBox(height: Space.md),
            ScanNotice(
              icon: Icons.info_outline_rounded,
              text: unreadText!,
              // Its own way of scanning again: these pages go where the
              // unread ones stood, which "Scan more pages" cannot promise.
              action: Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  ScanPillButton(
                    icon: Icons.document_scanner_outlined,
                    label: l10n.bookScanTryAgain,
                    prominent: true,
                    onPressed: onScanUnread,
                  ),
                  ScanPillButton(
                    icon: Icons.photo_library_outlined,
                    label: l10n.bookScanChoosePhotosShort,
                    onPressed: onPhotosForUnread,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The two ways to start a scan, pinned to the bottom of the first screen.
class _IntroActions extends StatelessWidget {
  final bool busy;
  final String startLabel;
  final String photosLabel;
  final String privacy;

  /// The camera could not be used, so choosing photos is the main action.
  final bool photosFirst;
  final VoidCallback onStart;
  final VoidCallback onPhotos;

  const _IntroActions({
    required this.busy,
    required this.startLabel,
    required this.photosLabel,
    required this.privacy,
    required this.photosFirst,
    required this.onStart,
    required this.onPhotos,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    Widget primary(String label, IconData icon, VoidCallback onTap) => SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: busy ? null : onTap,
            icon: busy
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: c.textSecondary),
                  )
                : Icon(icon),
            label: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        );

    Widget secondary(String label, VoidCallback onTap) => TextButton(
          onPressed: busy ? null : onTap,
          style: TextButton.styleFrom(minimumSize: const Size(0, 44)),
          child: Text(label),
        );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.xxl, Space.sm, Space.xxl, Space.md),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            // Lines up with the text column of the page above.
            constraints: const BoxConstraints(maxWidth: 432),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (photosFirst) ...[
                  primary(photosLabel, Icons.photo_library_outlined, onPhotos),
                  secondary(startLabel, onStart),
                ] else ...[
                  primary(startLabel, Icons.document_scanner_outlined, onStart),
                  secondary(photosLabel, onPhotos),
                ],
                const SizedBox(height: Space.xs),
                Text(
                  privacy,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, height: 1.35, color: c.textTertiary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Asks for the printed number of the first scanned page.
class _PageNumberDialog extends StatefulWidget {
  final int? initial;
  const _PageNumberDialog({this.initial});

  @override
  State<_PageNumberDialog> createState() => _PageNumberDialogState();
}

class _PageNumberDialogState extends State<_PageNumberDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial?.toString() ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? get _value {
    final n = int.tryParse(_controller.text.trim());
    return (n != null && n > 0 && n < 100000) ? n : null;
  }

  void _submit() {
    final n = _value;
    if (n != null) Navigator.pop(context, n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      // The field takes the keyboard at once, and what is left above it can
      // be very little, in landscape next to nothing. A dialog that scrolls
      // keeps the field whole; one that does not squeezes it to no height.
      scrollable: true,
      title: Text(l10n.bookScanPageNumbersTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Above the field and not its helper underneath: when there is no
          // room for both, the number being typed is the one that shows.
          Text(l10n.bookScanFirstPageHelp),
          const SizedBox(height: Space.lg),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(labelText: l10n.bookScanFirstPageLabel),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: _value == null ? null : _submit, child: Text(l10n.actionDone)),
      ],
    );
  }
}

/// The recognized lines of one recipe; tapping one makes it the first line of
/// a second recipe.
class _SplitSheet extends StatelessWidget {
  final List<SourceLine> lines;
  final List<int?> pageNumbers;
  final bool edited;

  const _SplitSheet({required this.lines, required this.pageNumbers, required this.edited});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final theme = Theme.of(context);

    return AdaptiveDraggableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, controller) => Column(
        children: [
          const SizedBox(height: Space.sm),
          const SheetHandle(top: 0),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.xl, Space.md, Space.xl, Space.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.bookScanSplit,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: Space.xs),
                Text(
                  l10n.bookScanSplitHelp,
                  style: TextStyle(fontSize: 14, height: 1.4, color: c.textSecondary),
                ),
                if (edited) ...[
                  const SizedBox(height: Space.md),
                  ScanNotice(icon: Icons.info_outline_rounded, text: l10n.bookScanSplitEditedNote),
                ],
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: c.hairline),
          Expanded(
            child: ListView.builder(
              controller: controller,
              padding: const EdgeInsets.only(top: Space.xs, bottom: Space.xxl),
              itemCount: lines.length,
              itemBuilder: (ctx, i) {
                final line = lines[i];
                final newPage = i > 0 && lines[i - 1].page != line.page;
                final pageNumber = line.page >= 0 && line.page < pageNumbers.length
                    ? pageNumbers[line.page]
                    : null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (newPage)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Space.xl, Space.md, Space.xl, Space.xs),
                        child: Row(
                          children: [
                            Expanded(child: Divider(height: 1, thickness: 1, color: c.hairline)),
                            if (pageNumber != null) ...[
                              const SizedBox(width: Space.sm),
                              Text(
                                l10n.bookScanPage('${pageNumber + line.pageOffset}'),
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: c.textTertiary),
                              ),
                              const SizedBox(width: Space.sm),
                              Expanded(child: Divider(height: 1, thickness: 1, color: c.hairline)),
                            ],
                          ],
                        ),
                      ),
                    InkWell(
                      onTap: i == 0 ? null : () => Navigator.pop(ctx, i),
                      highlightColor: c.pressedFill,
                      splashColor: c.pressedFill,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            Space.xl,
                            line.paragraphStart && i > 0 ? Space.md : Space.xs + 2,
                            Space.xl,
                            Space.xs + 2,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              line.text,
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.35,
                                color: i == 0 ? c.textTertiary : c.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
