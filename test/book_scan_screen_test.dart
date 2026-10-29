// Scan this book, end to end on the screen: the camera and text recognition
// are replaced by a canned backend, everything else is the real thing (the
// splitter, the review queue, the saver and an in-memory database).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/book_scan/page_text.dart';
import 'package:recipespellbook/services/book_scan/photo_region.dart';
import 'package:recipespellbook/services/book_scan/scanned_page.dart';
import 'package:recipespellbook/services/collab_service.dart';
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/screens/book_scan/book_scan_entry.dart';
import 'package:recipespellbook/ui/screens/book_scan/book_scan_screen.dart';
import 'package:recipespellbook/ui/screens/book_scan/book_scan_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _soup = '''
Roasted Tomato Soup

Serves 4

3 pounds ripe tomatoes, halved
1 large onion, cut into wedges
3 tablespoons olive oil
2 cups vegetable stock

Heat the oven to 425°F. Toss the tomatoes and onion with the oil on a large tray.

Roast for 40 minutes, until the edges are charred.

142
''';

/// The soup again, all of it on one page: long enough for one line in ten to
/// be a small part of it.
const _soupInFull = '''
Roasted Tomato Soup

Serves 4

3 pounds ripe tomatoes, halved
1 large onion, cut into wedges
6 cloves garlic, unpeeled
3 tablespoons olive oil
2 cups vegetable stock
1 teaspoon smoked paprika

Heat the oven to 425°F. Toss the tomatoes and onion with the oil on a large tray.

Roast for 40 minutes, until the edges are charred.

Squeeze the garlic from its skins and blend everything with the stock.

142
''';

const _soupEndAndBread = '''
Blend everything with the stock until smooth.

Garlic Bread

Serves 4

1 baguette
100 g butter, softened
3 cloves garlic, crushed

Mix the butter and garlic and spread it between the slices.

Wrap in foil and bake for 15 minutes.

143
''';

const _untitled = '''
2 cups plain flour
1 teaspoon baking powder
1 cup milk
2 eggs

Whisk everything to a smooth batter and fry ladlefuls in a hot buttered pan.

144
''';

const _vinaigrette = '''
House Vinaigrette

3 tablespoons olive oil
1 tablespoon red wine vinegar
1 teaspoon Dijon mustard

Shake everything together in a jar until it thickens.

145
''';

const _prose = '''
A Note on Salt

Salt is the first thing most cooks reach for and the last thing they think about. I keep three kinds by the stove and use them for different jobs.

The flaky kind is for finishing, the fine kind is for baking.
''';

/// The device side of a scan, canned.
class _FakeBackend implements BookScanBackend {
  _FakeBackend(this.pages);

  /// What each page image "says".
  final Map<String, String> pages;

  /// The next answers of the scanner and the photo picker.
  List<String>? captured;
  List<String> picked = const [];
  BookScanError? captureError;
  BookScanError? pickError;
  Duration? readDelay;
  final unreadable = <String>{};

  /// Pages an earlier scan left behind.
  List<String> lost = const [];

  /// Stands for the scanner while it is open: what it completes with is what
  /// was scanned.
  Completer<List<String>?>? capturing;

  /// Holds every picture back until it completes, when a test sets it.
  Completer<void>? saveGate;

  /// Where recipe pictures are written. None are when this is not set.
  Directory? pictures;

  /// How many times the screen opened the device side.
  int opened = 0;
  int captureCalls = 0;
  int pickCalls = 0;
  bool closed = false;
  final savedImages = <String>[];

  @override
  Future<List<String>?> capturePages({int maxPages = 60}) async {
    captureCalls++;
    if (captureError != null) throw BookScanException(captureError!);
    return capturing?.future ?? captured;
  }

  @override
  Future<List<String>> pickPhotos() async {
    pickCalls++;
    if (pickError != null) throw BookScanException(pickError!);
    return picked;
  }

  @override
  Future<List<String>> lostPages() async => lost;

  @override
  Future<ScannedPage> readPage(String sourcePath) async {
    if (readDelay != null) await Future<void>.delayed(readDelay!);
    final text = pages[sourcePath];
    if (text == null || unreadable.contains(sourcePath)) {
      return ScannedPage(imagePath: sourcePath, text: PageText.empty, failed: true);
    }
    return ScannedPage(imagePath: sourcePath, text: PageText.fromPlainText(text), width: 900, height: 1200);
  }

  @override
  Future<String?> saveRecipeImage(ScannedPage page, {PhotoRegion? crop, required String recipeId}) async {
    savedImages.add(recipeId);
    await saveGate?.future;
    final folder = pictures;
    if (folder == null) return null;
    final file = File('${folder.path}${Platform.pathSeparator}${recipeId}_${savedImages.length}.png');
    return (file..writeAsBytesSync(File(page.imagePath).readAsBytesSync())).path;
  }

  @override
  Future<void> discardRecipeImage(String path) async => File(path).deleteSync();

  @override
  Future<void> close() async => closed = true;
}

/// What the screen handed back when it closed.
class _Outcome {
  bool closed = false;
  int? added;
  List<String> savedIds = const [];
}

void main() {
  late Directory dir;
  late String p1, p2, p3, p4, pProse;

  setUpAll(() {
    // Real (tiny) image files, so the page thumbnails have something to load.
    dir = Directory.systemTemp.createTempSync('rsb_scan_screen_test_');
    final png = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
    );
    String make(String name) => (File('${dir.path}${Platform.pathSeparator}$name.png')..writeAsBytesSync(png)).path;
    p1 = make('p1');
    p2 = make('p2');
    p3 = make('p3');
    p4 = make('p4');
    pProse = make('prose');
  });

  tearDownAll(() {
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  _FakeBackend backendWith({bool numbered = true}) {
    String strip(String s) => numbered ? s : s.replaceAll(RegExp(r'\n\d+\n$'), '\n');
    return _FakeBackend({
      p1: strip(_soup),
      p2: strip(_soupEndAndBread),
      p3: strip(_untitled),
      p4: strip(_vinaigrette),
      pProse: _prose,
    })
      ..captured = [p1, p2, p3]
      ..picked = [p1, p2, p3];
  }

  Future<AppDatabase> openDb(WidgetTester tester, {List<String> existing = const []}) async {
    final db = await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(
            CookbooksCompanion.insert(id: 'book', name: 'The Weeknight Kitchen'),
            mode: drift.InsertMode.insertOrIgnore,
          );
      for (var i = 0; i < existing.length; i++) {
        await db.into(db.recipes).insert(
              RecipesCompanion.insert(id: 'existing_$i', cookbookId: 'book', title: existing[i]),
            );
      }
      return db;
    });
    return db!;
  }

  /// Opens the screen the way the app does: pushed full screen over a page.
  Future<_Outcome> open(
    WidgetTester tester,
    _FakeBackend backend,
    AppDatabase db, {
    double textScale = 1.0,
    Duration? openDelay,
    Future<void> Function(List<String> ids)? afterSave,
  }) async {
    final outcome = _Outcome();
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme(AppColorTheme.spellbook),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  outcome.added = await Navigator.of(context).push<int>(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => BookScanScreen(
                        cookbookId: 'book',
                        bookTitle: 'The Weeknight Kitchen',
                        openBackend: () async {
                          backend.opened++;
                          if (openDelay != null) await Future<void>.delayed(openDelay);
                          return backend;
                        },
                        afterSave: (ids) async {
                          outcome.savedIds = ids;
                          await afterSave?.call(ids);
                        },
                      ),
                    ),
                  );
                  outcome.closed = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await settle(tester);
    return outcome;
  }

  /// From the first screen to the review queue.
  Future<void> scan(WidgetTester tester) async {
    await tester.tap(find.text('Start scanning'));
    await settle(tester);
  }

  Finder moreButton(String title) => find.descendant(
        of: find.ancestor(of: find.text(title), matching: find.byType(BookScanDraftCard)),
        matching: find.byTooltip('More options'),
      );

  /// The facts line on a recipe's card: ingredients, steps and page.
  String metaOf(WidgetTester tester, String title) => tester
      .widget<BookScanDraftCard>(find.ancestor(of: find.text(title), matching: find.byType(BookScanDraftCard)))
      .meta;

  /// The recipes in the review queue, top to bottom.
  List<String> queued(WidgetTester tester) => [
        for (final card in tester.widgetList<BookScanDraftCard>(find.byType(BookScanDraftCard))) card.title,
      ];

  /// From the review queue, opens the scanner or the photo picker for more
  /// pages and stops there: the pages are still to be read.
  Future<void> startAddingPages(WidgetTester tester, {bool fromPhotos = false}) async {
    await tester.tap(find.byTooltip('Scan more pages'));
    await settle(tester, rounds: 2);
    await tester.tap(find.text(fromPhotos ? 'Choose photos' : 'Scan pages'));
    await tester.pump();
  }

  /// From the review queue, back to the scanner for more pages.
  Future<void> scanMore(WidgetTester tester) async {
    await startAddingPages(tester);
    await settle(tester);
  }

  Future<List<Recipe>> savedRecipes(WidgetTester tester, AppDatabase db) async =>
      (await tester.runAsync(() => db.select(db.recipes).get()))!;

  Future<List<String>> stepsOf(WidgetTester tester, AppDatabase db, String recipeId) async => [
        for (final step in (await tester.runAsync(
          () => (db.select(db.steps)
                ..where((t) => t.recipeId.equals(recipeId))
                ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
              .get(),
        ))!)
          step.instruction,
      ];

  group('finding recipes', () {
    testWidgets('the pages are read and each recipe is listed for review', (tester) async {
      final backend = backendWith();
      await open(tester, backend, await openDb(tester));

      expect(find.text('Scan pages from this book'), findsOneWidget);
      expect(find.textContaining('filed under The Weeknight Kitchen'), findsOneWidget);

      await scan(tester);

      expect(backend.captureCalls, 1);
      expect(find.text('Found 3 recipes'), findsOneWidget);
      expect(find.text('Roasted Tomato Soup'), findsOneWidget);
      expect(find.text('Garlic Bread'), findsOneWidget);
      // The soup runs onto the second page and is saved with both numbers.
      expect(find.textContaining('142-143'), findsOneWidget);
      // No title could be read for the third: flagged, not dropped.
      expect(find.text('Untitled recipe'), findsOneWidget);
      expect(find.text('Needs a title'), findsOneWidget);
      expect(find.text('Add 3 recipes'), findsOneWidget);
    });

    testWidgets('a recipe already in the cookbook is pointed out', (tester) async {
      final backend = backendWith();
      await open(tester, backend, await openDb(tester, existing: ['garlic bread']));
      await scan(tester);
      await settleUntil(tester, () => find.text('Already in this book').evaluate().isNotEmpty);
      expect(find.text('Already in this book'), findsOneWidget);
    });

    testWidgets('a page that could not be read is reported, the rest still come through', (tester) async {
      final backend = backendWith()..unreadable.add(p3);
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(find.text('Found 2 recipes'), findsOneWidget);
      // It says which of the three it was.
      expect(
        find.text('Photo 3 could not be read. Scan that page again to add what is missing.'),
        findsOneWidget,
      );
    });

    testWidgets('pages with no recipe on them say so and offer another go', (tester) async {
      final backend = backendWith()..captured = [pProse];
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      expect(find.text('No recipes found'), findsOneWidget);
      expect(find.textContaining('Add '), findsNothing);

      backend.captured = [p1, p2];
      await tester.tap(find.text('Scan again'));
      await settle(tester);
      expect(backend.captureCalls, 2);
      expect(find.text('Found 2 recipes'), findsOneWidget);
    });

    testWidgets('backing out of the scanner leaves the first screen as it was', (tester) async {
      final backend = backendWith()..captured = null;
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(find.text('Scan pages from this book'), findsOneWidget);
      expect(find.text('Start scanning'), findsOneWidget);
    });

    testWidgets('reading can be cancelled', (tester) async {
      final backend = backendWith()..readDelay = const Duration(milliseconds: 200);
      await open(tester, backend, await openDb(tester));
      await tester.tap(find.text('Start scanning'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Reading your pages'), findsOneWidget);
      expect(find.text('Page 2 of 3'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pump(const Duration(seconds: 1));
      await settle(tester);
      expect(find.text('Start scanning'), findsOneWidget);
      expect(find.textContaining('Found'), findsNothing);
    });
  });

  group('when the camera cannot be used', () {
    testWidgets('a refused permission is explained and photos become the way in', (tester) async {
      final backend = backendWith()..captureError = BookScanError.cameraDenied;
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      expect(find.textContaining('Camera access is off'), findsOneWidget);
      // Choosing photos is now the main button.
      expect(
        find.ancestor(of: find.text('Choose photos'), matching: find.byWidgetPredicate((w) => w is FilledButton)),
        findsOneWidget,
      );

      await tester.tap(find.text('Choose photos'));
      await settle(tester);
      expect(backend.pickCalls, 1);
      expect(find.text('Found 3 recipes'), findsOneWidget);
    });

    testWidgets('a scanner that fails to open says so', (tester) async {
      final backend = backendWith()..captureError = BookScanError.scannerFailed;
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(find.textContaining('could not be opened'), findsOneWidget);
    });
  });

  group('when an earlier scan was interrupted', () {
    testWidgets('its pages are offered on the first screen and read without scanning again', (tester) async {
      final backend = backendWith()..lost = [p1, p2, p3];
      await open(tester, backend, await openDb(tester));

      expect(find.text('An earlier scan was interrupted. Its 3 pages are still on this device.'), findsOneWidget);
      // Scanning afresh stays the main button.
      expect(
        find.ancestor(of: find.text('Start scanning'), matching: find.byWidgetPredicate((w) => w is FilledButton)),
        findsOneWidget,
      );

      await tester.tap(find.text('Read 3 pages'));
      await settle(tester);
      expect(backend.captureCalls, 0);
      expect(backend.pickCalls, 0);
      expect(find.text('Found 3 recipes'), findsOneWidget);
      expect(find.textContaining('142-143'), findsOneWidget);
    });

    testWidgets('a single page is offered as one', (tester) async {
      final backend = backendWith()..lost = [p4];
      await open(tester, backend, await openDb(tester));

      expect(find.text('An earlier scan was interrupted. Its page is still on this device.'), findsOneWidget);
      await tester.tap(find.text('Read 1 page'));
      await settle(tester);
      expect(find.text('Found 1 recipe'), findsOneWidget);
      expect(find.text('House Vinaigrette'), findsOneWidget);
    });

    testWidgets('nothing is offered when no pages were left behind', (tester) async {
      await open(tester, backendWith(), await openDb(tester));
      expect(find.textContaining('interrupted'), findsNothing);
      expect(find.textContaining('Read '), findsNothing);
    });

    testWidgets('the offer is still there after reading them was cancelled', (tester) async {
      final backend = backendWith()
        ..lost = [p1, p2, p3]
        ..readDelay = const Duration(milliseconds: 200);
      await open(tester, backend, await openDb(tester));

      await tester.tap(find.text('Read 3 pages'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Reading your pages'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pump(const Duration(seconds: 1));
      await settle(tester);
      expect(find.text('Read 3 pages'), findsOneWidget);

      backend.readDelay = null;
      await tester.tap(find.text('Read 3 pages'));
      await settle(tester);
      expect(find.text('Found 3 recipes'), findsOneWidget);
    });

    testWidgets('scanning afresh works as usual', (tester) async {
      final backend = backendWith()
        ..lost = [p4]
        ..captured = [p1, p2];
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      expect(backend.captureCalls, 1);
      expect(find.text('Found 2 recipes'), findsOneWidget);
      expect(find.text('House Vinaigrette'), findsNothing);
    });

    testWidgets('starting a scan while the screen is still looking for such pages opens one session', (tester) async {
      final backend = backendWith();
      await open(tester, backend, await openDb(tester), openDelay: const Duration(seconds: 5));

      await tester.tap(find.text('Start scanning'));
      await tester.pump(const Duration(seconds: 5));
      await settle(tester);

      expect(backend.opened, 1);
      expect(backend.captureCalls, 1);
      expect(find.text('Found 3 recipes'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await settle(tester);
      await tester.tap(find.text('Discard'));
      await settle(tester);
      expect(backend.closed, isTrue);
    });
  });

  group('reviewing', () {
    testWidgets('a discarded recipe can be brought back', (tester) async {
      await open(tester, backendWith(), await openDb(tester));
      await scan(tester);

      await tester.tap(moreButton('Garlic Bread'));
      await settle(tester);
      await tester.tap(find.text('Discard'));
      await settle(tester);
      expect(find.text('Found 2 recipes'), findsOneWidget);
      expect(find.text('Garlic Bread'), findsNothing);

      await tester.tap(find.text('Undo'));
      await settle(tester);
      expect(find.text('Found 3 recipes'), findsOneWidget);
      expect(find.text('Garlic Bread'), findsOneWidget);
      await clearSnackbar(tester);
    });

    testWidgets('swiping a card away discards it', (tester) async {
      await open(tester, backendWith(), await openDb(tester));
      await scan(tester);
      await tester.drag(find.text('Garlic Bread'), const Offset(-500, 0));
      await settle(tester);
      expect(find.text('Found 2 recipes'), findsOneWidget);
      expect(find.text('Garlic Bread'), findsNothing);
      await clearSnackbar(tester);
    });

    testWidgets('two recipes can be merged, split again, and the merge undone', (tester) async {
      await open(tester, backendWith(), await openDb(tester));
      await scan(tester);

      await tester.tap(moreButton('Roasted Tomato Soup'));
      await settle(tester);
      await tester.tap(find.text('Merge with next'));
      await settle(tester);
      expect(find.text('Found 2 recipes'), findsOneWidget);
      expect(find.text('Garlic Bread'), findsNothing);
      await clearSnackbar(tester);

      // Split it back at the second title.
      await tester.tap(moreButton('Roasted Tomato Soup'));
      await settle(tester);
      await tester.tap(find.text('Split in two'));
      await settle(tester);
      await tester.scrollUntilVisible(find.text('Garlic Bread'), 120, scrollable: find.byType(Scrollable).last);
      await tester.tap(find.text('Garlic Bread'));
      await settle(tester);
      expect(find.text('Found 3 recipes'), findsOneWidget);
      expect(find.text('Roasted Tomato Soup'), findsOneWidget);
      expect(find.text('Garlic Bread'), findsOneWidget);

      // And a merge can simply be undone.
      await tester.tap(moreButton('Roasted Tomato Soup'));
      await settle(tester);
      await tester.tap(find.text('Merge with next'));
      await settle(tester);
      expect(find.text('Found 2 recipes'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await settle(tester);
      expect(find.text('Found 3 recipes'), findsOneWidget);
      expect(find.text('Garlic Bread'), findsOneWidget);
      await clearSnackbar(tester);
    });

    testWidgets('the last recipe has nothing to merge with', (tester) async {
      await open(tester, backendWith(), await openDb(tester));
      await scan(tester);
      await tester.tap(moreButton('Untitled recipe'));
      await settle(tester);
      expect(find.text('Merge with next'), findsNothing);
      expect(find.text('Split in two'), findsOneWidget);
    });

    testWidgets('editing gives an untitled recipe its title', (tester) async {
      await open(tester, backendWith(), await openDb(tester));
      await scan(tester);

      await tester.tap(find.text('Untitled recipe'));
      await settle(tester);
      expect(find.text('Edit recipe'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Pancakes');
      await tester.tap(find.text('Done'));
      await settle(tester);

      expect(find.text('Pancakes'), findsOneWidget);
      expect(find.text('Untitled recipe'), findsNothing);
      expect(find.text('Needs a title'), findsNothing);
    });

    testWidgets('leaving an edit with changes asks first, and discarding keeps the recipe as it was', (tester) async {
      await open(tester, backendWith(), await openDb(tester));
      await scan(tester);

      await tester.tap(find.text('Garlic Bread'));
      await settle(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Cheesy Garlic Bread');
      await tester.pump();

      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await settle(tester);
      expect(find.text('Edit recipe'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await settle(tester);
      await tester.tap(find.text('Discard'));
      await settle(tester);
      expect(find.text('Garlic Bread'), findsOneWidget);
      expect(find.text('Cheesy Garlic Bread'), findsNothing);
    });

    testWidgets('typing the first page number numbers every recipe', (tester) async {
      await open(tester, backendWith(numbered: false), await openDb(tester));
      await scan(tester);
      expect(find.textContaining('No page numbers found'), findsOneWidget);

      await tester.tap(find.text('Set page numbers'));
      await settle(tester);
      // Nothing typed yet: nothing to confirm.
      final done = find.ancestor(of: find.text('Done'), matching: find.byWidgetPredicate((w) => w is FilledButton));
      expect(tester.widget<FilledButton>(done).onPressed, isNull);
      await tester.enterText(find.byType(TextField), '58');
      await tester.pump();
      await tester.tap(find.text('Done'));
      await settle(tester);

      expect(find.textContaining('58-60'), findsOneWidget); // the whole scan
      expect(find.textContaining('58-59'), findsOneWidget); // the soup
      expect(find.textContaining('No page numbers found'), findsNothing);
    });

    testWidgets('more pages can be scanned without losing what was already sorted out', (tester) async {
      final backend = backendWith();
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      await tester.tap(moreButton('Garlic Bread'));
      await settle(tester);
      await tester.tap(find.text('Discard'));
      await settle(tester);
      await clearSnackbar(tester);
      expect(find.text('Found 2 recipes'), findsOneWidget);

      backend.captured = [p4];
      await scanMore(tester);

      expect(find.text('Found 3 recipes'), findsOneWidget);
      expect(find.text('Garlic Bread'), findsNothing);
      await tester.scrollUntilVisible(find.text('House Vinaigrette'), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text('House Vinaigrette'), findsOneWidget);
    });
  });

  group('adding', () {
    testWidgets('every recipe is saved into the cookbook with its page', (tester) async {
      final backend = backendWith();
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      await tester.tap(find.text('Add 3 recipes'));
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);

      expect(outcome.closed, isTrue);
      expect(outcome.added, 3);
      expect(outcome.savedIds, hasLength(3));
      expect(backend.savedImages, hasLength(3));
      expect(find.text('Added 3 recipes to The Weeknight Kitchen'), findsOneWidget);
      await clearSnackbar(tester);

      final saved = await tester.runAsync(
        () => (db.select(db.recipes)..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt)])).get(),
      );
      expect(saved!.map((r) => r.cookbookId).toSet(), {'book'});
      final byTitle = {for (final r in saved) r.title: r};
      expect(byTitle.keys, containsAll(['Roasted Tomato Soup', 'Garlic Bread', 'Untitled recipe']));
      expect(byTitle['Roasted Tomato Soup']!.sourceUrl, 'The Weeknight Kitchen, pp. 142-143');
      expect(byTitle['Garlic Bread']!.sourceUrl, 'The Weeknight Kitchen, p. 143');
      expect(byTitle['Untitled recipe']!.sourceUrl, 'The Weeknight Kitchen, p. 144');
      expect(byTitle['Roasted Tomato Soup']!.servings, '4');

      final soupId = byTitle['Roasted Tomato Soup']!.id;
      final ingredients = await tester.runAsync(
        () => (db.select(db.ingredients)..where((t) => t.recipeId.equals(soupId))).get(),
      );
      final steps = await tester.runAsync(
        () => (db.select(db.steps)..where((t) => t.recipeId.equals(soupId))).get(),
      );
      expect(ingredients, hasLength(4));
      // The third step came from the second page.
      expect(steps, hasLength(3));
    });

    testWidgets('leaving with recipes waiting asks first', (tester) async {
      final backend = backendWith();
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(find.text('Discard this scan?'), findsOneWidget);
      await tester.tap(find.text('Keep reviewing'));
      await settle(tester);
      expect(outcome.closed, isFalse);
      expect(find.text('Found 3 recipes'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await settle(tester);
      await tester.tap(find.text('Discard'));
      await settle(tester);
      expect(outcome.closed, isTrue);
      expect(outcome.added, isNull);
      // The page images and the recognizer are let go.
      expect(backend.closed, isTrue);

      final saved = await tester.runAsync(() => db.select(db.recipes).get());
      expect(saved, isEmpty);
    });

    testWidgets('closing the first screen needs no confirmation', (tester) async {
      final backend = backendWith();
      final outcome = await open(tester, backend, await openDb(tester));
      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(outcome.closed, isTrue);
      expect(find.text('Discard this scan?'), findsNothing);
    });

    testWidgets('a recipe swiped away just before the tap is not added', (tester) async {
      final backend = backendWith();
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      await tester.drag(find.text('Garlic Bread'), const Offset(-500, 0));
      // The card has left but the list is still closing up behind it.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byType(BookScanBottomBar));
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);

      expect(outcome.added, 2);
      expect(find.text('Added 2 recipes to The Weeknight Kitchen'), findsOneWidget);
      expect((await savedRecipes(tester, db)).map((r) => r.title), unorderedEquals(['Roasted Tomato Soup', 'Untitled recipe']));
      await clearSnackbar(tester);
    });

    testWidgets('a discard cannot be undone once adding has begun', (tester) async {
      final backend = backendWith();
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      await tester.drag(find.text('Garlic Bread'), const Offset(-500, 0));
      await settle(tester);
      expect(find.text('Undo'), findsOneWidget);

      backend.saveGate = Completer<void>();
      await tester.tap(find.text('Add 2 recipes'));
      await settle(tester);
      expect(find.text('Adding 1 of 2'), findsOneWidget);
      expect(find.text('Undo'), findsNothing);
      expect(find.byType(BookScanDraftCard), findsNWidgets(2));

      backend.saveGate!.complete();
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);
      expect(outcome.added, 2);
      expect((await savedRecipes(tester, db)).map((r) => r.title), unorderedEquals(['Roasted Tomato Soup', 'Untitled recipe']));
      await clearSnackbar(tester);
    });

    testWidgets('the recipes stay on the screen until it closes', (tester) async {
      final backend = backendWith();
      final db = await openDb(tester);
      final afterSave = Completer<void>();
      final outcome = await open(tester, backend, db, afterSave: (_) => afterSave.future);
      await scan(tester);

      await tester.tap(find.text('Add 3 recipes'));
      await settleUntil(tester, () => backend.savedImages.length == 3);
      await settle(tester);
      expect(await savedRecipes(tester, db), hasLength(3));

      // Saved, and the cookbook is being told. Nothing here says otherwise.
      expect(outcome.closed, isFalse);
      expect(find.text('No recipes found'), findsNothing);
      expect(find.textContaining('none of them looked like a recipe'), findsNothing);
      expect(find.text('Scan again'), findsNothing);
      expect(find.byType(BookScanDraftCard), findsNWidgets(3));

      // Nor when the screen is drawn again, as on turning the phone: the
      // cards do not take themselves for recipes the cookbook had already.
      tester.view.physicalSize = tester.view.physicalSize.flipped;
      addTearDown(tester.view.reset);
      await tester.pump();
      expect(find.byType(BookScanDraftCard), findsWidgets);
      expect(find.text('Already in this book'), findsNothing);

      afterSave.complete();
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);
      expect(outcome.added, 3);
      await clearSnackbar(tester);
    });

    testWidgets('a cookbook that was deleted meanwhile is not added to', (tester) async {
      final backend = backendWith();
      final db = await openDb(tester);
      await tester.runAsync(() => db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'other', name: 'Family')));
      final outcome = await open(tester, backend, db);
      await scan(tester);

      await tester.runAsync(() => db.cookbookDao.deleteCookbook('book'));
      await tester.tap(find.text('Add 3 recipes'));
      await settle(tester);

      // Nothing is filed under a cookbook that is not there.
      expect(outcome.closed, isFalse);
      expect(await savedRecipes(tester, db), isEmpty);
      expect(find.textContaining('The Weeknight Kitchen is no longer on this device'), findsOneWidget);

      await tester.tap(find.text('Family'));
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);
      expect(outcome.added, 3);
      expect(find.text('Added 3 recipes to Family'), findsOneWidget);
      final saved = await savedRecipes(tester, db);
      expect(saved.map((r) => r.cookbookId).toSet(), {'other'});
      // The page still names the book the recipes were scanned from.
      expect(saved.singleWhere((r) => r.title == 'Garlic Bread').sourceUrl, 'The Weeknight Kitchen, p. 143');
      await clearSnackbar(tester);
    });

    testWidgets('a recipe that fails to save leaves no picture behind', (tester) async {
      final backend = backendWith()..captured = [p1, p2];
      final pictures = Directory('${dir.path}${Platform.pathSeparator}pictures_${DateTime.now().microsecondsSinceEpoch}')
        ..createSync();
      backend.pictures = pictures;
      final db = await openDb(tester);
      await tester.runAsync(() => db.customStatement(
            "CREATE TRIGGER no_bread BEFORE INSERT ON recipes WHEN NEW.title = 'Garlic Bread' "
            "BEGIN SELECT RAISE(ABORT, 'no bread today'); END",
          ));
      final outcome = await open(tester, backend, db);
      await scan(tester);

      await tester.tap(find.text('Add 2 recipes'));
      await settleUntil(tester, () => find.text('Add 1 recipe').evaluate().isNotEmpty);
      await settle(tester);
      expect(find.text('1 recipe could not be added'), findsOneWidget);
      expect(find.text('Garlic Bread'), findsOneWidget);
      expect(pictures.listSync(), hasLength(1));
      await clearSnackbar(tester);

      await tester.runAsync(() => db.customStatement('DROP TRIGGER no_bread'));
      await tester.tap(find.text('Add 1 recipe'));
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);

      // One picture for each recipe, and each recipe has its own.
      final saved = await savedRecipes(tester, db);
      expect(saved, hasLength(2));
      expect(
        pictures.listSync().map((f) => f.path).toSet(),
        saved.map((r) => r.imagePath).toSet(),
      );
      await clearSnackbar(tester);
    });

    testWidgets('a recipe nudged aside and let go is added with the rest', (tester) async {
      final backend = backendWith();
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      await tester.drag(find.text('Garlic Bread'), const Offset(-60, 0));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(BookScanBottomBar));
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);

      expect(outcome.added, 3);
      expect(await savedRecipes(tester, db), hasLength(3));
      await clearSnackbar(tester);
    });

    testWidgets('a recipe still sliding aside when adding begins is added, and is not said to be discarded',
        (tester) async {
      final backend = backendWith()..saveGate = Completer<void>();
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      // A short flick, let go well before the point of no return.
      await tester.fling(find.text('Garlic Bread'), const Offset(-60, 0), 1200);
      await tester.tap(find.byType(BookScanBottomBar));
      // Time enough for the card to have slid all the way out.
      await settle(tester, rounds: 6);

      expect(find.text('Adding 1 of 3'), findsOneWidget);
      expect(find.text('Recipe discarded'), findsNothing);
      expect(queued(tester), contains('Garlic Bread'));

      backend.saveGate!.complete();
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);
      expect(outcome.added, 3);
      expect(await savedRecipes(tester, db), hasLength(3));
      await clearSnackbar(tester);
    });

    testWidgets('a recipe swiped away just before scanning more pages stays away', (tester) async {
      final backend = backendWith();
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      await tester.drag(find.text('Garlic Bread'), const Offset(-500, 0));
      await tester.pump(const Duration(milliseconds: 100));
      backend.captured = [p4];
      await scanMore(tester);

      expect(queued(tester), ['Roasted Tomato Soup', 'Untitled recipe', 'House Vinaigrette']);
    });

    testWidgets('with no other cookbook to turn to, nothing is added and the queue is kept', (tester) async {
      final backend = backendWith();
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      await tester.runAsync(() async {
        await db.cookbookDao.deleteCookbook('book');
        await db.cookbookDao.deleteCookbook('starter');
      });
      await tester.tap(find.text('Add 3 recipes'));
      await settle(tester);

      expect(
        find.text(
          'The Weeknight Kitchen is no longer on this device, and there is no other cookbook to add these recipes to.',
        ),
        findsOneWidget,
      );
      expect(outcome.closed, isFalse);
      expect(await savedRecipes(tester, db), isEmpty);
      expect(find.text('Add 3 recipes'), findsOneWidget);
      await clearSnackbar(tester);
    });

    testWidgets('backing out of choosing another cookbook keeps the queue', (tester) async {
      final backend = backendWith();
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      await tester.runAsync(() => db.cookbookDao.deleteCookbook('book'));
      await tester.tap(find.text('Add 3 recipes'));
      await settle(tester);
      expect(find.text('Choose a cookbook'), findsOneWidget);
      expect(find.text('My Recipes'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(outcome.closed, isFalse);
      expect(await savedRecipes(tester, db), isEmpty);
      expect(find.text('Add 3 recipes'), findsOneWidget);
      expect(backend.savedImages, isEmpty);
    });

    testWidgets('a cookbook deleted while the recipes are going in gets none of them', (tester) async {
      final backend = backendWith();
      final pictures = Directory('${dir.path}${Platform.pathSeparator}pictures_${DateTime.now().microsecondsSinceEpoch}')
        ..createSync();
      backend.pictures = pictures;
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      // The first picture is being written when the cookbook goes.
      backend.saveGate = Completer<void>();
      await tester.tap(find.text('Add 3 recipes'));
      await settle(tester);
      expect(find.text('Adding 1 of 3'), findsOneWidget);
      await tester.runAsync(() => db.cookbookDao.deleteCookbook('book'));
      backend.saveGate!.complete();
      await settleUntil(tester, () => find.text('Add 3 recipes').evaluate().isNotEmpty);
      await settle(tester);

      expect(find.text('3 recipes could not be added'), findsOneWidget);
      expect(outcome.closed, isFalse);
      expect(await savedRecipes(tester, db), isEmpty);
      expect(pictures.listSync(), isEmpty);
      await clearSnackbar(tester);

      // Trying again asks where they should go instead.
      await tester.tap(find.text('Add 3 recipes'));
      await settle(tester);
      await tester.tap(find.text('My Recipes'));
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);
      expect(outcome.added, 3);
      expect((await savedRecipes(tester, db)).map((r) => r.cookbookId).toSet(), {'starter'});
      expect(pictures.listSync(), hasLength(3));
      await clearSnackbar(tester);
    });

    testWidgets('a cookbook that may only be viewed is not added to', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.runAsync(() => CollabService.instance.markCollabCookbook('book', 'read', ownerId: 'owner1'));
      addTearDown(() => CollabService.instance.setCookbookAccess(const []));
      final backend = backendWith();
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      await tester.tap(find.text('Add 3 recipes'));
      await settle(tester);
      expect(find.textContaining('You can only view this cookbook'), findsOneWidget);
      expect(outcome.closed, isFalse);
      expect(await savedRecipes(tester, db), isEmpty);
      await clearSnackbar(tester);
    });
  });

  group('when there is nothing to review', () {
    testWidgets('pages that could not be read are not said to have been read', (tester) async {
      final backend = backendWith()..unreadable.addAll([p1, p2, p3]);
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      expect(find.textContaining('The pages were read'), findsNothing);
      expect(find.text('Nothing could be read'), findsOneWidget);
      expect(find.textContaining('None of the 3 pages could be read'), findsOneWidget);

      // Scanning again takes the place of the pages that failed.
      backend.unreadable.clear();
      await tester.tap(find.text('Scan again'));
      await settle(tester);
      expect(find.text('Found 3 recipes'), findsOneWidget);
      expect(find.textContaining('3 pages'), findsOneWidget);
      expect(find.textContaining('could not be read'), findsNothing);
    });

    testWidgets('discarding every recipe is not blamed on the photos', (tester) async {
      await open(tester, backendWith(), await openDb(tester));
      await scan(tester);
      for (final title in ['Roasted Tomato Soup', 'Garlic Bread', 'Untitled recipe']) {
        await tester.drag(find.text(title), const Offset(-500, 0));
        await settle(tester);
      }
      await clearSnackbar(tester);

      expect(find.byType(BookScanDraftCard), findsNothing);
      expect(find.text('No recipes found'), findsNothing);
      expect(find.textContaining('The pages were read'), findsNothing);
    });

    testWidgets('a page that could not be read is named beside pages that held no recipe', (tester) async {
      final backend = backendWith()
        ..captured = [pProse, p1]
        ..unreadable.add(p1);
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      expect(find.text('No recipes found'), findsOneWidget);
      expect(find.textContaining('Photo 2 could not be read'), findsOneWidget);

      // Scanning again is of that page first.
      backend
        ..unreadable.clear()
        ..captured = [p1];
      await tester.tap(find.text('Scan again'));
      await settle(tester);
      expect(find.text('Found 1 recipe'), findsOneWidget);
      expect(find.textContaining('2 pages'), findsOneWidget);
      expect(find.textContaining('could not be read'), findsNothing);
    });

    testWidgets('once every recipe is dealt with, more pages can be scanned or chosen', (tester) async {
      final backend = backendWith()..captured = [p1];
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      await tester.drag(find.text('Roasted Tomato Soup'), const Offset(-500, 0));
      await settle(tester);
      await clearSnackbar(tester);

      expect(find.text('Nothing left to add'), findsOneWidget);
      expect(find.text('Scan more pages'), findsOneWidget);

      backend.picked = [p4];
      await tester.tap(find.text('Choose photos instead'));
      await settle(tester);
      expect(backend.pickCalls, 1);
      expect(queued(tester), ['House Vinaigrette']);
    });

    testWidgets('cancelling a new reading comes back to it', (tester) async {
      final backend = backendWith()..captured = [pProse];
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(find.text('No recipes found'), findsOneWidget);

      backend
        ..captured = [p1, p2]
        ..readDelay = const Duration(milliseconds: 200);
      await tester.tap(find.text('Scan again'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Reading your pages'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pump(const Duration(seconds: 1));
      await settle(tester);

      expect(find.text('No recipes found'), findsOneWidget);
      expect(find.text('Start scanning'), findsNothing);
    });
  });

  group('starting a scan', () {
    /// Pages are scanned on phones only. Runs [body] as on one.
    Future<void> onPhone(Future<void> Function() body) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await body();
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    }

    /// A page with one button that starts a scan for [cookbookId].
    Future<void> pumpStart(WidgetTester tester, AppDatabase db, String cookbookId, void Function(int) onDone) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme(AppColorTheme.spellbook),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async => onDone(await startBookScan(context, cookbookId: cookbookId)),
                  child: const Text('scan'),
                ),
              ),
            ),
          ),
        ),
      ));
    }

    testWidgets('for a cookbook that is there opens the scan for it', (tester) async {
      await onPhone(() async {
        final db = await openDb(tester);
        await pumpStart(tester, db, 'book', (_) {});
        await tester.tap(find.text('scan'));
        await settle(tester);
        expect(find.textContaining('filed under The Weeknight Kitchen'), findsOneWidget);
      });
    });

    testWidgets('for a cookbook that is not there asks which one to scan into', (tester) async {
      await onPhone(() async {
        final db = await openDb(tester);
        int? added;
        await pumpStart(tester, db, 'no-such-cookbook', (n) => added = n);
        await tester.tap(find.text('scan'));
        await settle(tester);

        expect(find.text('Choose a cookbook'), findsOneWidget);
        expect(find.text('My Recipes'), findsOneWidget);
        await tester.tap(find.text('The Weeknight Kitchen'));
        await settle(tester);
        expect(find.textContaining('filed under The Weeknight Kitchen'), findsOneWidget);
        expect(added, isNull);

        await tester.binding.handlePopRoute();
        await settle(tester);
        expect(added, 0);
      });
    });

    testWidgets('for a cookbook that is not there, and nothing chosen, opens nothing', (tester) async {
      await onPhone(() async {
        final db = await openDb(tester);
        int? added;
        await pumpStart(tester, db, 'no-such-cookbook', (n) => added = n);
        await tester.tap(find.text('scan'));
        await settle(tester);
        await tester.binding.handlePopRoute();
        await settle(tester);

        expect(added, 0);
        expect(find.text('Scan pages from this book'), findsNothing);
      });
    });

    testWidgets('with a single cookbook to scan into does not ask', (tester) async {
      await onPhone(() async {
        final db = await openDb(tester);
        await tester.runAsync(() => db.cookbookDao.deleteCookbook('book'));
        await pumpStart(tester, db, 'starter-as-the-app-once-named-it', (_) {});
        await tester.tap(find.text('scan'));
        await settle(tester);
        expect(find.text('Choose a cookbook'), findsNothing);
        expect(find.textContaining('filed under My Recipes'), findsOneWidget);
      });
    });

    testWidgets('tapped twice opens one scan', (tester) async {
      await onPhone(() async {
        final db = await openDb(tester);
        final results = <int>[];
        await pumpStart(tester, db, 'book', results.add);
        await tester.tap(find.text('scan'));
        await tester.tap(find.text('scan'));
        await settle(tester);
        expect(find.text('Scan pages from this book'), findsOneWidget);
        // The second tap came back at once with nothing added.
        expect(results, [0]);

        await tester.binding.handlePopRoute();
        await settle(tester);
        expect(results, [0, 0]);
        expect(find.text('Scan pages from this book'), findsNothing);
      });
    });
  });

  group('reading and adding at the same time', () {
    testWidgets('a page still being read after Cancel does not undo a save that began meanwhile', (tester) async {
      final backend = backendWith();
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      backend
        ..captured = [p4]
        ..readDelay = const Duration(seconds: 1);
      await startAddingPages(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Reading your pages'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      backend.saveGate = Completer<void>();
      await tester.tap(find.text('Add 3 recipes'));
      await settle(tester, rounds: 1);
      expect(find.text('Adding 1 of 3'), findsOneWidget);

      // The page that was being read when Cancel was tapped comes back now.
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('Adding 1 of 3'), findsOneWidget);
      expect(find.text('Add 3 recipes'), findsNothing);

      // Nothing on the screen can be used until the save is over.
      await tester.tap(find.text('Adding 1 of 3'), warnIfMissed: false);
      await tester.tap(find.text('Garlic Bread'), warnIfMissed: false);
      await settle(tester, rounds: 1);
      expect(find.text('Edit recipe'), findsNothing);
      await tester.binding.handlePopRoute();
      await settle(tester, rounds: 1);
      expect(find.text('Discard this scan?'), findsNothing);

      backend.saveGate!.complete();
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);
      expect(outcome.added, 3);
      expect(outcome.savedIds, hasLength(3));
      expect(await savedRecipes(tester, db), hasLength(3));
      await clearSnackbar(tester);
    });

    testWidgets('a page still being read after Cancel does not interrupt the reading that followed', (tester) async {
      final backend = backendWith()..readDelay = const Duration(seconds: 1);
      await open(tester, backend, await openDb(tester));

      await tester.tap(find.text('Start scanning'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(find.text('Start scanning'), findsOneWidget);

      await tester.tap(find.text('Start scanning'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Reading your pages'), findsOneWidget);

      // The first reading's page comes back while the second is on its first.
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Reading your pages'), findsOneWidget);
      expect(find.text('Page 1 of 3'), findsOneWidget);
      expect(find.text('Start scanning'), findsNothing);

      await tester.pump(const Duration(seconds: 3));
      await settle(tester);
      expect(find.text('Found 3 recipes'), findsOneWidget);
    });
  });

  group('scanning a page again', () {
    testWidgets('a page that could not be read is replaced where it stood', (tester) async {
      final backend = backendWith()..unreadable.add(p2);
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);
      expect(find.text('Found 2 recipes'), findsOneWidget);
      expect(find.textContaining('could not be read'), findsOneWidget);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('2 steps'));

      backend
        ..unreadable.clear()
        ..captured = [p2];
      await scanMore(tester);

      // Three pages, as before, and nothing left unread.
      expect(find.textContaining('3 pages'), findsOneWidget);
      expect(find.textContaining('142-144'), findsOneWidget);
      expect(find.textContaining('could not be read'), findsNothing);
      expect(find.text('Found 3 recipes'), findsOneWidget);
      // The end of the soup went to the soup, not to the last recipe scanned.
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('3 steps'));
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('142-143'));
      expect(metaOf(tester, 'Garlic Bread'), endsWith('p. 143'));
      expect(metaOf(tester, 'Untitled recipe'), contains('1 step'));
      expect(metaOf(tester, 'Untitled recipe'), endsWith('p. 144'));

      await tester.tap(find.text('Add 3 recipes'));
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);
      final saved = {for (final r in await savedRecipes(tester, db)) r.title: r};
      expect(saved['Garlic Bread']!.sourceUrl, 'The Weeknight Kitchen, p. 143');
      expect(await stepsOf(tester, db, saved['Roasted Tomato Soup']!.id), hasLength(3));
      expect(await stepsOf(tester, db, saved['Untitled recipe']!.id), hasLength(1));
      await clearSnackbar(tester);
    });

    testWidgets('a page that was read before takes the place of its first reading', (tester) async {
      final backend = backendWith();
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      backend.captured = [p2];
      await scanMore(tester);

      expect(find.text('Found 3 recipes'), findsOneWidget);
      expect(find.text('Garlic Bread'), findsOneWidget);
      expect(find.textContaining('3 pages'), findsOneWidget);
      expect(find.textContaining('142-144'), findsOneWidget);
      expect(metaOf(tester, 'Garlic Bread'), endsWith('p. 143'));
      expect(metaOf(tester, 'Untitled recipe'), contains('1 step'));
      expect(metaOf(tester, 'Untitled recipe'), endsWith('p. 144'));
    });

    testWidgets('the unread page of a longer scan keeps its place and its number', (tester) async {
      final backend = backendWith()
        ..captured = [p1, p2, p3, p4]
        ..unreadable.add(p3);
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);
      expect(find.textContaining('4 pages'), findsOneWidget);
      expect(find.textContaining('142-145'), findsOneWidget);
      expect(find.textContaining('could not be read'), findsOneWidget);

      backend
        ..unreadable.clear()
        ..captured = [p3];
      await scanMore(tester);

      expect(find.textContaining('4 pages'), findsOneWidget);
      expect(find.textContaining('142-145'), findsOneWidget);
      expect(find.textContaining('could not be read'), findsNothing);
      expect(metaOf(tester, 'Untitled recipe'), endsWith('p. 144'));

      await tester.scrollUntilVisible(find.text('House Vinaigrette'), 200, scrollable: find.byType(Scrollable).first);
      expect(metaOf(tester, 'House Vinaigrette'), endsWith('p. 145'));

      await tester.tap(find.text('Add 4 recipes'));
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);
      final saved = {for (final r in await savedRecipes(tester, db)) r.title: r};
      expect(saved['Untitled recipe']!.sourceUrl, 'The Weeknight Kitchen, p. 144');
      expect(saved['House Vinaigrette']!.sourceUrl, 'The Weeknight Kitchen, p. 145');
      await clearSnackbar(tester);
    });

    testWidgets('a page with no number on it is known again by its text', (tester) async {
      final backend = backendWith(numbered: false);
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      backend.captured = [p2];
      await scanMore(tester);

      expect(find.textContaining('3 pages'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread', 'Untitled recipe']);
      expect(metaOf(tester, 'Untitled recipe'), contains('1 step'));
    });

    testWidgets('a page photographed twice in one sitting is read once', (tester) async {
      final backend = backendWith()..captured = [p1, p2, p2, p3];
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      expect(find.textContaining('3 pages'), findsOneWidget);
      expect(find.textContaining('142-144'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread', 'Untitled recipe']);
      expect(metaOf(tester, 'Garlic Bread'), contains('2 steps'));
    });

    testWidgets('another page that reads the same number is not taken for it', (tester) async {
      final backend = backendWith()..captured = [p1, p2];
      // A different page, with no title to tell it by and its number read as
      // that of the bread's page.
      backend.pages[p3] = _untitled.replaceAll('144', '143');
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      backend.captured = [p3];
      await scanMore(tester);

      expect(find.textContaining('3 pages'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread', 'Untitled recipe']);
      expect(metaOf(tester, 'Garlic Bread'), contains('2 steps'));
    });

    testWidgets('two pages that read alike but carry different numbers are two pages', (tester) async {
      final backend = backendWith()..captured = [p1];
      backend.pages[p1] = _soupInFull;
      // The same recipe printed again further on in the book, line for line.
      backend.pages[p4] = _soupInFull.replaceAll('142', '150');
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      backend.captured = [p4];
      await scanMore(tester);

      expect(find.textContaining('2 pages'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Roasted Tomato Soup']);
    });

    testWidgets('two recipes set to one pattern are two pages, even when they read the same number', (tester) async {
      const rest = '''
1 oz lemon juice
3/4 oz simple syrup

Shake everything with ice and strain into a chilled glass.

Garnish with a twist of lemon peel.

7
''';
      final backend = backendWith();
      backend.pages[p3] = 'Gin Sour\n\n2 oz gin\n$rest';
      backend.pages[p4] = 'Rum Sour\n\n2 oz rum\n$rest';
      backend.captured = [p3, p4];
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      expect(find.textContaining('2 pages'), findsOneWidget);
      expect(queued(tester), ['Gin Sour', 'Rum Sour']);
    });

    testWidgets('a page read again takes its place though a letter of the title came out differently', (tester) async {
      final backend = backendWith()..captured = [p1];
      backend.pages[p1] = _soupInFull.replaceAll('Tomato Soup', 'Tornato Soup');
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(queued(tester), ['Roasted Tornato Soup']);

      backend.pages[p1] = _soupInFull;
      await scanMore(tester);

      expect(find.textContaining('1 page'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup']);
    });

    testWidgets('two recipes with no title and no page number that differ in one short line are two pages',
        (tester) async {
      final backend = backendWith(numbered: false);
      backend.pages[p4] = backend.pages[p3]!.replaceAll('2 eggs', '3 eggs');
      backend.captured = [p3, p4];
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      expect(find.textContaining('2 pages'), findsOneWidget);
      expect(queued(tester), ['Untitled recipe', 'Untitled recipe']);
    });

    testWidgets('one page of a spread photographed again by itself does not take the other page away', (tester) async {
      final backend = backendWith();
      // Both pages in one photo, read with the number of the first.
      backend.pages[p4] = '142\n\n${_soup.replaceAll('142', '')}\n${_soupEndAndBread.replaceAll('143', '')}';
      backend.captured = [p4];
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread']);

      backend.captured = [p1];
      await scanMore(tester);

      // The photo of both pages is still part of the scan, and the bread on it.
      expect(find.textContaining('2 pages'), findsOneWidget);
      expect(queued(tester), contains('Garlic Bread'));
      expect(metaOf(tester, 'Garlic Bread'), contains('2 steps'));
    });

    testWidgets('a stray number does not put a page in the place of one that could not be read', (tester) async {
      const sour = '''
1 oz lemon juice
3/4 oz simple syrup

Shake everything with ice and strain into a chilled glass.
''';
      final backend = backendWith();
      // Pages 142 to 145, the second of them read as page 1.
      backend.pages[p2] = _vinaigrette.replaceAll('145', '1');
      backend.pages[p4] = 'Gin Sour\n\n2 oz gin\n$sour\n145\n';
      backend.captured = [p1, p2, p3, p4];
      backend.unreadable.add(p3);
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(find.textContaining('Photo 3 could not be read'), findsOneWidget);

      // The next page of the book, read as page 2.
      backend.pages[pProse] = 'Rum Sour\n\n2 oz rum\n$sour\n2\n';
      backend.captured = [pProse];
      await scanMore(tester);

      expect(find.textContaining('Photo 3 could not be read'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'House Vinaigrette', 'Gin Sour', 'Rum Sour']);
    });

    testWidgets('a page left out the first time goes where it belongs in the book', (tester) async {
      final backend = backendWith()..captured = [p1, p3];
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('2 steps'));

      backend.captured = [p2];
      await scanMore(tester);

      expect(find.textContaining('3 pages'), findsOneWidget);
      expect(find.textContaining('142-144'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread', 'Untitled recipe']);
      // The soup ends on the page that was missing.
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('3 steps'));
      expect(metaOf(tester, 'Untitled recipe'), contains('1 step'));
      expect(metaOf(tester, 'Untitled recipe'), endsWith('p. 144'));
    });

    testWidgets('pages skipped and gone back for in one sitting are read in the order of the book', (tester) async {
      final backend = backendWith()..captured = [p1, p3, p2];
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      expect(find.textContaining('142-144'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread', 'Untitled recipe']);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('3 steps'));
      expect(metaOf(tester, 'Untitled recipe'), contains('1 step'));
    });

    // A recipe on a page with no number, taken between two that follow on.
    // The second one begins with an amount, which is no page number either.
    for (final (name, unnumbered) in [
      ('House Vinaigrette', _vinaigrette.replaceAll('145', '')),
      ('Untitled recipe', _vinaigrette.replaceAll('145', '').replaceAll('House Vinaigrette\n', '')),
    ]) {
      testWidgets('a page with no number stays where it was photographed ($name)', (tester) async {
        final backend = backendWith();
        backend.pages[p4] = unnumbered;
        backend.captured = [p1, p4, p2, p3];
        await open(tester, backend, await openDb(tester));
        await scan(tester);

        expect(find.textContaining('4 pages'), findsOneWidget);
        expect(queued(tester), ['Roasted Tomato Soup', name, 'Garlic Bread', 'Untitled recipe']);
      });
    }

    // The second of five pages and the last, read as two pages that follow
    // on from each other: the later one first, then the earlier one first.
    for (final (second, last) in const [(1, 2), (3, 2)]) {
      testWidgets('a stray number at the foot of two pages does not move one of them ($second and $last)',
          (tester) async {
        const sour = '''
1 oz lemon juice
3/4 oz simple syrup

Shake everything with ice and strain into a chilled glass.
''';
        final backend = backendWith();
        // A scan of pages 142 to 146.
        backend.pages[p2] = _vinaigrette.replaceAll('145', '$second');
        backend.pages[p4] = 'Gin Sour\n\n2 oz gin\n$sour\n145\n';
        backend.pages[pProse] = 'Rum Sour\n\n2 oz rum\n$sour\n$last\n';
        backend.captured = [p1, p2, p3, p4, pProse];
        // Tall enough for five cards at once.
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await open(tester, backend, await openDb(tester));
        await scan(tester);

        // As they were photographed.
        expect(
          queued(tester),
          ['Roasted Tomato Soup', 'House Vinaigrette', 'Untitled recipe', 'Gin Sour', 'Rum Sour'],
        );
      });
    }

    // In many books the page number shares its line with a running title,
    // after it or in front of it.
    String withRunningTitle(String page, int number, {bool numberFirst = false}) => page.replaceAll(
          '\n$number\n',
          numberFirst ? '\n$number Soups and Starters\n' : '\nSoups and Starters $number\n',
        );

    testWidgets('a number set beside a running title puts a page scanned again in its place', (tester) async {
      final backend = backendWith()..unreadable.add(p2);
      backend.pages[p1] = withRunningTitle(_soup, 142);
      backend.pages[p2] = withRunningTitle(_soupEndAndBread, 143);
      backend.pages[p3] = withRunningTitle(_untitled, 144);
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(find.textContaining('142-144'), findsOneWidget);
      expect(find.textContaining('could not be read'), findsOneWidget);

      backend
        ..unreadable.clear()
        ..captured = [p2];
      await scanMore(tester);

      expect(find.textContaining('3 pages'), findsOneWidget);
      expect(find.textContaining('142-144'), findsOneWidget);
      expect(find.textContaining('could not be read'), findsNothing);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread', 'Untitled recipe']);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('3 steps'));
    });

    testWidgets('two pages photographed the wrong way round are put right by numbers set beside a running title',
        (tester) async {
      final backend = backendWith()..captured = [p2, p1];
      backend.pages[p1] = withRunningTitle(_soup, 142, numberFirst: true);
      backend.pages[p2] = withRunningTitle(_soupEndAndBread, 143, numberFirst: true);
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      expect(find.textContaining('142-143'), findsWidgets);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread']);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('3 steps'));
    });

    testWidgets('a page from before the first one scanned goes in front', (tester) async {
      final backend = backendWith()..captured = [p2, p3];
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(queued(tester), ['Garlic Bread', 'Untitled recipe']);

      // The user edits the bread, then scans the page before it.
      await tester.tap(find.text('Garlic Bread'));
      await settle(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Cheesy Garlic Bread');
      await tester.tap(find.text('Done'));
      await settle(tester);

      backend.captured = [p1];
      await scanMore(tester);

      expect(find.textContaining('142-144'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Cheesy Garlic Bread', 'Untitled recipe']);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('3 steps'));
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('142-143'));
      // The edited recipe still points at its own page, one further on now.
      expect(metaOf(tester, 'Cheesy Garlic Bread'), endsWith('p. 143'));
      await tester.tap(find.text('Cheesy Garlic Bread'));
      await settle(tester);
      expect(find.byType(ScanPageImage), findsOneWidget);
      expect(tester.widget<ScanPageImage>(find.byType(ScanPageImage)).path, p2);
    });

    testWidgets('an edited recipe stays as it was edited when its page is scanned again', (tester) async {
      final backend = backendWith();
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      await tester.tap(find.text('Garlic Bread'));
      await settle(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Cheesy Garlic Bread');
      await tester.tap(find.text('Done'));
      await settle(tester);

      backend.captured = [p2];
      await scanMore(tester);

      expect(queued(tester), ['Roasted Tomato Soup', 'Cheesy Garlic Bread', 'Untitled recipe']);
    });

    testWidgets('an edited recipe stays the only one of its kind when its page reads a little differently',
        (tester) async {
      final backend = backendWith();
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      await tester.tap(find.text('Garlic Bread'));
      await settle(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Cheesy Garlic Bread');
      await tester.tap(find.text('Done'));
      await settle(tester);

      // The heading comes out with a small letter this time.
      backend
        ..pages[p2] = _soupEndAndBread.replaceAll('Garlic Bread', 'Garlic bread')
        ..captured = [p2];
      await scanMore(tester);

      expect(find.textContaining('3 pages'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Cheesy Garlic Bread', 'Untitled recipe']);
    });

    testWidgets('a merged recipe is not offered in part again when one of its pages reads a little differently',
        (tester) async {
      final backend = backendWith();
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      await tester.tap(moreButton('Garlic Bread'));
      await settle(tester);
      await tester.tap(find.text('Merge with next'));
      await settle(tester);
      await clearSnackbar(tester);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread']);

      backend
        ..pages[p3] = _untitled.replaceAll('2 eggs', '3 eggs')
        ..captured = [p3];
      await scanMore(tester);

      expect(find.textContaining('3 pages'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread']);
    });

    testWidgets('an edited recipe is offered again, beside the edit, when its page reads much better', (tester) async {
      const soupEnd = '''
Blend everything with the stock until smooth.

Season with salt and plenty of black pepper.

Pour the soup back into the pan and warm it through.

Ladle into warm bowls and add a spoonful of cream.

Scatter with torn basil leaves just before serving.
''';
      final backend = backendWith()..captured = [p1, p2];
      // The lower half of the page is a blur: of the bread, only the heading
      // came out right.
      backend.pages[p2] = '''
$soupEnd
Garlic Bread

1 bagvette
100 g bvtter, softened
3 doves garlic, crvshed

Mix the bvtter and garlic and spread it between the slices.

Wrap in foil and bake for 15 minvtes.

143
''';
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread']);

      // The user starts on it by hand, then photographs the page again.
      await tester.tap(find.text('Garlic Bread'));
      await settle(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Cheesy Garlic Bread');
      await tester.tap(find.text('Done'));
      await settle(tester);

      backend
        ..pages[p2] = '''
$soupEnd
Garlic Bread

1 baguette
100 g butter, softened
3 cloves garlic, crushed

Mix the butter and garlic and spread it between the slices.

Wrap in foil and bake for 15 minutes.

143
'''
        ..captured = [p2];
      await scanMore(tester);

      expect(find.textContaining('2 pages'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread', 'Cheesy Garlic Bread']);
      expect(find.textContaining('1 baguette'), findsOneWidget);
    });

    // The soup is edited, then the page after it is photographed again and
    // comes out worse: the bread on it has lost its heading, and its lines
    // run on from the end of the soup. The edited soup does not take them, so
    // nothing stands in for the bread.
    Future<void> editSoupAndScanAgain(WidgetTester tester, _FakeBackend backend, String poorPage) async {
      await tester.tap(find.text('Roasted Tomato Soup'));
      await settle(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Tomato Soup');
      await tester.tap(find.text('Done'));
      await settle(tester);

      backend
        ..pages[p2] = poorPage
        ..captured = [p2];
      await scanMore(tester);
    }

    testWidgets('a recipe stays when its page, read again, no longer shows where it begins', (tester) async {
      // A third recipe on the page, which reads well both times.
      final vinaigrette = _vinaigrette.replaceAll('145', '');
      final backend = backendWith()..captured = [p1, p2];
      backend.pages[p2] = '${_soupEndAndBread.replaceAll('143', '')}\n$vinaigrette\n143\n';
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread', 'House Vinaigrette']);

      // The heading of the bread and the amounts down the left edge are
      // missing. The foot of the page is in the photo this time, with a
      // fourth recipe on it.
      await editSoupAndScanAgain(tester, backend, '''
Blend everything with the stock until smooth.

baguette
butter, softened
garlic, crushed

Mix the butter and garlic and spread it between the slices.

Wrap in foil and bake for 15 minutes.

$vinaigrette
Rum Sour

2 oz rum
1 oz lemon juice

Shake everything with ice and strain into a chilled glass.

143
''');

      expect(find.textContaining('2 pages'), findsOneWidget);
      expect(queued(tester), ['Tomato Soup', 'Garlic Bread', 'House Vinaigrette', 'Rum Sour']);
      expect(metaOf(tester, 'Garlic Bread'), contains('3 ingredients'));
    });

    testWidgets('a recipe stays when its page, read again, gives no line of it back', (tester) async {
      const soupEnd = '''
Blend everything with the stock until smooth.

Season with salt and plenty of black pepper.

Pour the soup back into the pan and warm it through.

Ladle into warm bowls and add a spoonful of cream.

Scatter with torn basil leaves just before serving.
''';
      final backend = backendWith()..captured = [p1, p2];
      backend.pages[p2] = '''
$soupEnd
Garlic Bread

1 baguette
100 g butter, softened
3 cloves garlic, crushed

Mix the butter and garlic and spread it between the slices.

Wrap in foil and bake for 15 minutes.

143
''';
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread']);

      // Blurred down its lower half as well.
      await editSoupAndScanAgain(tester, backend, '''
$soupEnd
1 bagvette
100 g bvtter, softened
3 doves garlic, crvshed

Mix the bvtter and garlic and spread it between the slices.

Wrap in foil and bake for 15 minvtes.

143
''');

      expect(find.textContaining('2 pages'), findsOneWidget);
      expect(queued(tester), ['Tomato Soup', 'Garlic Bread']);
      expect(find.textContaining('1 baguette'), findsOneWidget);
    });

    testWidgets('an edited recipe gets its end once the top of the next page is in the photo', (tester) async {
      final backend = backendWith()..captured = [p1, p2];
      // The first photo of the second page cut off its first line.
      backend.pages[p2] = _soupEndAndBread.replaceAll('Blend everything with the stock until smooth.\n', '');
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('2 steps'));

      await editSoupAndScanAgain(tester, backend, _soupEndAndBread);

      expect(find.textContaining('2 pages'), findsOneWidget);
      expect(queued(tester), ['Tomato Soup', 'Garlic Bread']);
      expect(metaOf(tester, 'Tomato Soup'), contains('3 steps'));
      expect(metaOf(tester, 'Tomato Soup'), contains('142-143'));
    });

    testWidgets('a recipe whose heading is missing from a second photo of its page is kept', (tester) async {
      // Nothing was edited: the soup takes the new reading of its last page,
      // and the bread, which that reading no longer finds, stays as it was.
      final backend = backendWith()..captured = [p1, p2];
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread']);

      backend.pages[p2] = '''
Blend everything with the stock until smooth.

baguette
butter, softened
garlic, crushed

Mix the butter and garlic and spread it between the slices.

Wrap in foil and bake for 15 minutes.

143
''';
      backend.captured = [p2];
      await scanMore(tester);

      expect(find.textContaining('2 pages'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread']);
      expect(metaOf(tester, 'Garlic Bread'), contains('3 ingredients'));
    });

    testWidgets('a recipe kept from an earlier reading gets its page once the page numbers are known', (tester) async {
      const breadPage = '''
Blend everything with the stock until smooth.

Garlic Bread

1 baguette
100 g butter, softened
3 cloves garlic, crushed

Mix the butter and garlic and spread it between the slices.

Wrap in foil and bake for 15 minutes.

Open the foil for the last few minutes to crisp the top.

Leave to stand for a minute before slicing.

Serve warm, straight from the oven.
''';
      // No page of the first two has a number on it.
      final backend = backendWith(numbered: false)..captured = [p1, p2];
      backend.pages[p2] = breadPage;
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread']);

      // The same page again, without the heading of the bread.
      backend
        ..pages[p2] = breadPage.replaceAll('Garlic Bread\n', '')
        ..captured = [p2];
      await scanMore(tester);
      expect(find.textContaining('2 pages'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread']);
      expect(metaOf(tester, 'Garlic Bread'), isNot(contains('p.')));

      // The next page has its number, and the others are counted from it.
      backend
        ..pages[p3] = _untitled
        ..captured = [p3];
      await scanMore(tester);
      expect(find.textContaining('142-144'), findsOneWidget);
      expect(metaOf(tester, 'Garlic Bread'), endsWith('143'));
    });

    // The soup is all on its own page here, and the bread, a longer recipe
    // than the soup, begins the next.
    for (final discarded in [false, true]) {
      testWidgets(
          'an edited recipe is not given the lines of the one after it, whose page read worse '
          '(${discarded ? 'discarded' : 'still in the queue'})', (tester) async {
        const bread = '''
Garlic Bread

1 baguette
100 g butter, softened
3 cloves garlic, crushed

Mix the butter and garlic and spread it between the slices.

Wrap in foil and bake for 15 minutes.

Open the foil for the last few minutes to crisp the top.

Leave to stand for a minute before slicing.

Cut through the last of the crust with a bread knife.

Serve warm, straight from the oven.

143
''';
        final backend = backendWith()..captured = [p1, p2];
        backend.pages[p2] = bread;
        await open(tester, backend, await openDb(tester));
        await scan(tester);
        expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread']);
        if (discarded) {
          await tester.drag(find.text('Garlic Bread'), const Offset(-500, 0));
          await settle(tester);
          await clearSnackbar(tester);
        }

        await editSoupAndScanAgain(
          tester,
          backend,
          bread
              .replaceAll('Garlic Bread\n', '')
              .replaceAll('1 baguette', 'baguette')
              .replaceAll('100 g butter', 'butter')
              .replaceAll('3 cloves garlic', 'garlic'),
        );

        expect(find.textContaining('2 pages'), findsOneWidget);
        expect(queued(tester), ['Tomato Soup', if (!discarded) 'Garlic Bread']);
        expect(metaOf(tester, 'Tomato Soup'), contains('2 steps'));
        if (!discarded) expect(metaOf(tester, 'Garlic Bread'), contains('3 ingredients'));
      });
    }

    testWidgets('a recipe that read badly gives way to a better reading of its page', (tester) async {
      const vinaigrette = '''
House Vinaigrette

3 tablespoons olive oil
1 tablespoon red wine vinegar
1 teaspoon Dijon mustard
1 small shallot, finely chopped

Shake everything together in a jar until it thickens.
''';
      final backend = backendWith()..captured = [p2];
      // A photo blurred down its lower half: no line of the bread came out
      // right, its heading included.
      backend.pages[p2] = '''
$vinaigrette
Garlc Bred

1 bagvette
100 g bvtter, softened
3 doves garlic, crvshed

Mix the bvtter and garlic and spread it between the slices.

Wrap in foil and bake for 15 minvtes.

143
''';
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(queued(tester), ['House Vinaigrette', 'Garlc Bred']);

      backend.pages[p2] = '''
$vinaigrette
Garlic Bread

1 baguette
100 g butter, softened
3 cloves garlic, crushed

Mix the butter and garlic and spread it between the slices.

Wrap in foil and bake for 15 minutes.

143
''';
      await scanMore(tester);

      expect(find.textContaining('1 page'), findsOneWidget);
      expect(queued(tester), ['House Vinaigrette', 'Garlic Bread']);
    });

    testWidgets('a discarded recipe stays discarded when its page is scanned again', (tester) async {
      final backend = backendWith();
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      await tester.drag(find.text('Garlic Bread'), const Offset(-500, 0));
      await settle(tester);
      await clearSnackbar(tester);

      backend.captured = [p2];
      await scanMore(tester);

      expect(queued(tester), ['Roasted Tomato Soup', 'Untitled recipe']);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('3 steps'));
    });

    testWidgets('a discarded recipe is offered again when its page reads differently the second time', (tester) async {
      final backend = backendWith();
      // The page as a poor photo gave it.
      backend.pages[p2] = _soupEndAndBread
          .replaceAll('1 baguette', '1 bagvette')
          .replaceAll('3 cloves garlic, crushed', '3 doves garlic, crvshed');
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      await tester.drag(find.text('Garlic Bread'), const Offset(-500, 0));
      await settle(tester);
      await clearSnackbar(tester);

      backend
        ..pages[p2] = _soupEndAndBread
        ..captured = [p2];
      await scanMore(tester);

      expect(find.textContaining('3 pages'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread', 'Untitled recipe']);
      expect(find.textContaining('1 baguette'), findsOneWidget);
      expect(find.textContaining('bagvette'), findsNothing);
    });

    testWidgets('a recipe already added says so when its page is scanned again and reads differently', (tester) async {
      final backend = backendWith();
      final db = await openDb(tester);
      await tester.runAsync(() => db.customStatement(
            "CREATE TRIGGER no_bread BEFORE INSERT ON recipes WHEN NEW.title = 'Garlic Bread' "
            "BEGIN SELECT RAISE(ABORT, 'no bread today'); END",
          ));
      await open(tester, backend, db);
      await scan(tester);
      await tester.tap(find.text('Add 3 recipes'));
      await settleUntil(tester, () => find.text('Add 1 recipe').evaluate().isNotEmpty);
      await settle(tester);
      await clearSnackbar(tester);
      expect(queued(tester), ['Garlic Bread']);

      backend
        ..pages[p1] = _soup.replaceAll('2 cups vegetable stock', '3 cups vegetable stock')
        ..captured = [p1];
      await scanMore(tester);

      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread']);
      expect(find.text('Already in this book'), findsOneWidget);
    });
  });

  group('pages that could not be read', () {
    testWidgets('are named, and scanned again from the notice they go where they stood', (tester) async {
      // No page numbers to go by: only the notice says what the new page is.
      final backend = backendWith(numbered: false)..unreadable.add(p2);
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(
        find.text('Photo 2 could not be read. Scan that page again to add what is missing.'),
        findsOneWidget,
      );
      expect(queued(tester), ['Roasted Tomato Soup', 'Untitled recipe']);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('2 steps'));

      backend
        ..unreadable.clear()
        ..captured = [p2];
      await tester.tap(find.text('Scan again'));
      await settle(tester);

      expect(backend.captureCalls, 2);
      expect(find.textContaining('could not be read'), findsNothing);
      expect(find.textContaining('3 pages'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread', 'Untitled recipe']);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('3 steps'));
      expect(metaOf(tester, 'Untitled recipe'), contains('1 step'));
    });

    testWidgets('can be replaced from photos as well', (tester) async {
      final backend = backendWith(numbered: false)..unreadable.add(p2);
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      backend
        ..unreadable.clear()
        ..picked = [p2];
      await tester.tap(find.text('Choose photos'));
      await settle(tester);

      expect(backend.pickCalls, 1);
      expect(find.textContaining('could not be read'), findsNothing);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread', 'Untitled recipe']);
    });

    testWidgets('are each named, and the notice follows what is still unread', (tester) async {
      final backend = backendWith()
        ..captured = [p1, p2, p3, p4]
        ..unreadable.addAll([p2, p4]);
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(
        find.text('Photos 2, 4 could not be read. Scan those pages again to add what is missing.'),
        findsOneWidget,
      );

      // Only the last page is scanned again. Its number puts it in its place.
      backend
        ..unreadable.remove(p4)
        ..captured = [p4];
      await tester.tap(find.text('Scan again'));
      await settle(tester);

      expect(find.textContaining('4 pages'), findsOneWidget);
      expect(
        find.text('Photo 2 could not be read. Scan that page again to add what is missing.'),
        findsOneWidget,
      );
      expect(queued(tester), ['Roasted Tomato Soup', 'Untitled recipe', 'House Vinaigrette']);
      expect(metaOf(tester, 'House Vinaigrette'), endsWith('p. 145'));
    });

    testWidgets('stay unread when the page scanned from the notice is another one, by its number', (tester) async {
      final backend = backendWith()..unreadable.add(p2);
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(find.textContaining('Photo 2 could not be read'), findsOneWidget);

      // Page 145, which cannot stand between pages 142 and 144.
      backend.captured = [p4];
      await tester.tap(find.text('Scan again'));
      await settle(tester);

      expect(find.textContaining('4 pages'), findsOneWidget);
      expect(find.textContaining('Photo 2 could not be read'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Untitled recipe', 'House Vinaigrette']);
    });

    testWidgets('stay unread when scanning them again fails again', (tester) async {
      final backend = backendWith(numbered: false)..unreadable.add(p2);
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      backend.captured = [p2];
      await tester.tap(find.text('Scan again'));
      await settle(tester);

      expect(find.textContaining('3 pages'), findsOneWidget);
      expect(find.textContaining('Photo 2 could not be read'), findsOneWidget);
      expect(queued(tester), ['Roasted Tomato Soup', 'Untitled recipe']);
    });

    testWidgets('are counted when there are too many to name', (tester) async {
      final backend = backendWith()..captured = [p1, for (var i = 0; i < 7; i++) 'no_such_page_$i'];
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(
        find.text('7 pages could not be read. Scan them again to add what is missing.'),
        findsOneWidget,
      );
    });
  });

  group('scanning more pages after sorting out the queue', () {
    testWidgets('looking at a recipe without changing it leaves it open to the next page', (tester) async {
      final backend = backendWith()..captured = [p1];
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('2 steps'));

      await tester.tap(find.text('Roasted Tomato Soup'));
      await settle(tester);
      await tester.tap(find.text('Done'));
      await settle(tester);

      // It does not count as edited: cutting it in two warns of no lost edits.
      await tester.tap(moreButton('Roasted Tomato Soup'));
      await settle(tester);
      await tester.tap(find.text('Split in two'));
      await settle(tester);
      expect(find.text('Tap the line where the second recipe starts.'), findsOneWidget);
      expect(find.textContaining('your edits'), findsNothing);
      await tester.binding.handlePopRoute();
      await settle(tester);

      backend.captured = [p2];
      await scanMore(tester);

      expect(find.text('Found 2 recipes'), findsOneWidget);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('3 steps'));
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('142-143'));
    });

    testWidgets('a recipe that was edited still gets the end that is on the next page', (tester) async {
      final backend = backendWith()..captured = [p1];
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      await tester.tap(find.text('Roasted Tomato Soup'));
      await settle(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Tomato Soup');
      await tester.tap(find.text('Done'));
      await settle(tester);

      backend.captured = [p2];
      await scanMore(tester);

      expect(find.text('Found 2 recipes'), findsOneWidget);
      // The edit stands and the last step has joined it.
      expect(find.text('Roasted Tomato Soup'), findsNothing);
      expect(metaOf(tester, 'Tomato Soup'), contains('3 steps'));
      expect(metaOf(tester, 'Tomato Soup'), contains('142-143'));

      await tester.tap(find.text('Add 2 recipes'));
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);
      final soup = (await savedRecipes(tester, db)).singleWhere((r) => r.title == 'Tomato Soup');
      expect(await stepsOf(tester, db, soup.id), contains('Blend everything with the stock until smooth.'));
      expect(soup.sourceUrl, 'The Weeknight Kitchen, pp. 142-143');
      await clearSnackbar(tester);
    });

    testWidgets('discarding one recipe does not cost another the end that is on the next page', (tester) async {
      final backend = backendWith()..captured = [p3, p1];
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      await tester.drag(find.text('Untitled recipe'), const Offset(-500, 0));
      await settle(tester);
      await clearSnackbar(tester);
      expect(find.text('Found 1 recipe'), findsOneWidget);

      backend.captured = [p2];
      await scanMore(tester);
      expect(find.text('Found 2 recipes'), findsOneWidget);
      expect(find.text('Untitled recipe'), findsNothing);

      await tester.tap(find.text('Add 2 recipes'));
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);
      final soup = (await savedRecipes(tester, db)).singleWhere((r) => r.title == 'Roasted Tomato Soup');
      expect(await stepsOf(tester, db, soup.id), hasLength(3));
      await clearSnackbar(tester);
    });

    testWidgets('recipes that were all discarded stay discarded', (tester) async {
      final backend = backendWith();
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      for (final title in ['Roasted Tomato Soup', 'Garlic Bread', 'Untitled recipe']) {
        await tester.drag(find.text(title), const Offset(-500, 0));
        await settle(tester);
      }
      await clearSnackbar(tester);
      expect(find.byType(BookScanDraftCard), findsNothing);

      backend.captured = [p4];
      await tester.tap(find.byType(FilledButton));
      await settle(tester);

      expect(find.text('Found 1 recipe'), findsOneWidget);
      expect(find.text('House Vinaigrette'), findsOneWidget);
      expect(find.text('Roasted Tomato Soup'), findsNothing);
      expect(find.text('Garlic Bread'), findsNothing);
      expect(find.text('Untitled recipe'), findsNothing);
    });

    testWidgets('a merged recipe gets the end that is on the next page', (tester) async {
      final backend = backendWith()..captured = [p3, p1];
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      await tester.tap(moreButton('Untitled recipe'));
      await settle(tester);
      await tester.tap(find.text('Merge with next'));
      await settle(tester);
      await clearSnackbar(tester);
      expect(queued(tester), ['Roasted Tomato Soup']);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('3 steps'));

      backend.captured = [p2];
      await scanMore(tester);

      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread']);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('4 steps'));
    });

    testWidgets('of a recipe cut in two, the second half gets the end that is on the next page', (tester) async {
      final backend = backendWith()..captured = [p1];
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      await tester.tap(moreButton('Roasted Tomato Soup'));
      await settle(tester);
      await tester.tap(find.text('Split in two'));
      await settle(tester);
      final firstStep = find.textContaining('Heat the oven');
      await tester.scrollUntilVisible(firstStep, 120, scrollable: find.byType(Scrollable).last);
      await tester.tap(firstStep);
      await settle(tester);
      expect(queued(tester), ['Roasted Tomato Soup', 'Untitled recipe']);
      expect(metaOf(tester, 'Untitled recipe'), contains('2 steps'));

      backend.captured = [p2];
      await scanMore(tester);

      expect(queued(tester), ['Roasted Tomato Soup', 'Untitled recipe', 'Garlic Bread']);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('No steps'));
      expect(metaOf(tester, 'Untitled recipe'), contains('3 steps'));
    });

    testWidgets('the end of a discarded recipe does not come back on its own', (tester) async {
      final backend = backendWith()..captured = [p1];
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      await tester.drag(find.text('Roasted Tomato Soup'), const Offset(-500, 0));
      await settle(tester);
      await clearSnackbar(tester);

      backend.captured = [p2];
      await tester.tap(find.text('Scan more pages'));
      await settle(tester);

      expect(queued(tester), ['Garlic Bread']);
      expect(metaOf(tester, 'Garlic Bread'), contains('2 steps'));
    });

    testWidgets('a discarded recipe does not come back with the page that could not be read before', (tester) async {
      final backend = backendWith()
        ..captured = [p1, p2]
        ..unreadable.add(p2);
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      await tester.drag(find.text('Roasted Tomato Soup'), const Offset(-500, 0));
      await settle(tester);
      await clearSnackbar(tester);

      // The page that ends the soup reads now. The soup stays where it went.
      backend
        ..unreadable.clear()
        ..captured = [p2];
      await tester.tap(find.text('Scan more pages'));
      await settle(tester);

      expect(find.textContaining('could not be read'), findsNothing);
      expect(queued(tester), ['Garlic Bread']);
    });

    testWidgets('a step the page break cut off goes on where it stopped in an edited recipe', (tester) async {
      final backend = backendWith();
      backend.pages[p1] = _soup.replaceAll('Roast for 40 minutes, until the edges are charred.', 'Roast for 40 minutes, then tip');
      backend.pages[p2] = _soupEndAndBread.replaceAll(
        'Blend everything with the stock until smooth.',
        'everything into a pan with the stock and blend until smooth.',
      );
      backend.captured = [p1];
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      await tester.tap(find.text('Roasted Tomato Soup'));
      await settle(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Tomato Soup');
      await tester.tap(find.text('Done'));
      await settle(tester);

      backend.captured = [p2];
      await scanMore(tester);
      expect(metaOf(tester, 'Tomato Soup'), contains('2 steps'));

      await tester.tap(find.text('Add 2 recipes'));
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);
      final soup = (await savedRecipes(tester, db)).singleWhere((r) => r.title == 'Tomato Soup');
      expect(
        (await stepsOf(tester, db, soup.id)).last,
        'Roast for 40 minutes, then tip everything into a pan with the stock and blend until smooth.',
      );
      await clearSnackbar(tester);
    });

    testWidgets('a page typed in by hand is kept when the recipe gains a page', (tester) async {
      final backend = backendWith()..captured = [p1];
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      await tester.tap(find.text('Roasted Tomato Soup'));
      await settle(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Page'), 'xii');
      await tester.tap(find.text('Done'));
      await settle(tester);

      backend.captured = [p2];
      await scanMore(tester);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('3 steps'));
      expect(metaOf(tester, 'Roasted Tomato Soup'), endsWith('p. xii'));

      await tester.tap(find.text('Add 2 recipes'));
      await settleUntil(tester, () => outcome.closed);
      await settle(tester);
      final soup = (await savedRecipes(tester, db)).singleWhere((r) => r.title == 'Roasted Tomato Soup');
      expect(soup.sourceUrl, 'The Weeknight Kitchen, p. xii');
      await clearSnackbar(tester);
    });

    testWidgets('recipes already added do not come back when a failed one is tried again', (tester) async {
      final backend = backendWith();
      final db = await openDb(tester);
      await tester.runAsync(() => db.customStatement(
            "CREATE TRIGGER no_bread BEFORE INSERT ON recipes WHEN NEW.title = 'Garlic Bread' "
            "BEGIN SELECT RAISE(ABORT, 'no bread today'); END",
          ));
      final outcome = await open(tester, backend, db);
      await scan(tester);

      await tester.tap(find.text('Add 3 recipes'));
      await settleUntil(tester, () => find.text('Add 1 recipe').evaluate().isNotEmpty);
      await settle(tester);
      expect(queued(tester), ['Garlic Bread']);
      await clearSnackbar(tester);

      backend.captured = [p4];
      await scanMore(tester);
      expect(queued(tester), ['Garlic Bread', 'House Vinaigrette']);

      // Leaving now still reports the two that were added.
      await tester.binding.handlePopRoute();
      await settle(tester);
      await tester.tap(find.text('Discard'));
      await settle(tester);
      expect(outcome.closed, isTrue);
      expect(outcome.added, 2);
      expect(await savedRecipes(tester, db), hasLength(2));
    });
  });

  group('the page number dialog with the keyboard up', () {
    for (final (size, scale, keyboard) in const [
      (Size(360, 640), 1.0, 260.0),
      (Size(375, 667), 1.3, 260.0),
      (Size(360, 800), 1.5, 300.0),
      (Size(390, 844), 2.0, 336.0),
      (Size(320, 568), 2.0, 216.0),
      (Size(800, 360), 1.0, 200.0),
      (Size(844, 390), 1.0, 200.0),
      (Size(667, 375), 1.0, 162.0),
    ]) {
      testWidgets('shows what is typed at ${size.width.toInt()}x${size.height.toInt()}, text x$scale', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await open(tester, backendWith(numbered: false), await openDb(tester), textScale: scale);
        await scan(tester);
        await tester.ensureVisible(find.text('Set page numbers'));
        await tester.pump();
        await tester.tap(find.text('Set page numbers'));
        await settle(tester);

        tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
        await settle(tester);
        await tester.enterText(find.byType(TextField), '58');
        await settle(tester);

        // A line of type at this size, all of it above the keyboard.
        final typed = tester.getRect(find.byType(EditableText));
        expect(typed.height, greaterThanOrEqualTo(18 * scale));
        expect(typed.top, greaterThanOrEqualTo(0));
        expect(typed.bottom, lessThanOrEqualTo(size.height - keyboard));
        final field = tester.getRect(find.byType(TextField));
        expect(field.height, greaterThanOrEqualTo(typed.height));

        await tester.tap(find.text('Done'));
        await settle(tester);
        tester.view.resetViewInsets();
        await settle(tester);
        await tester.scrollUntilVisible(find.textContaining('58-60'), -120, scrollable: find.byType(Scrollable).first);
        expect(find.textContaining('58-60'), findsOneWidget);
      });
    }
  });

  group('adding pages from the review queue', () {
    for (final error in [BookScanError.cameraDenied, BookScanError.scannerFailed]) {
      testWidgets('a scanner that will not open says so and photos can be chosen (${error.name})', (tester) async {
        final backend = backendWith()
          ..captureError = error
          ..picked = [p1, p2];
        await open(tester, backend, await openDb(tester));
        await scan(tester);
        await tester.tap(find.text('Choose photos'));
        await settle(tester);
        expect(find.text('Found 2 recipes'), findsOneWidget);

        await scanMore(tester);
        expect(backend.captureCalls, 2);
        expect(
          find.textContaining(error == BookScanError.cameraDenied ? 'Camera access is off' : 'could not be opened'),
          findsOneWidget,
        );
        await clearSnackbar(tester);

        backend.picked = [p3];
        await startAddingPages(tester, fromPhotos: true);
        await settle(tester);
        expect(backend.pickCalls, 2);
        expect(find.text('Found 3 recipes'), findsOneWidget);
      });
    }

    testWidgets('with nothing found, a scanner that will not open says so and photos can be chosen', (tester) async {
      final backend = backendWith()..captured = [pProse];
      await open(tester, backend, await openDb(tester));
      await scan(tester);
      expect(find.text('No recipes found'), findsOneWidget);

      backend.captureError = BookScanError.cameraDenied;
      await tester.tap(find.text('Scan again'));
      await settle(tester);
      expect(backend.captureCalls, 2);
      expect(find.textContaining('Camera access is off'), findsOneWidget);
      await clearSnackbar(tester);

      backend.picked = [p1, p2];
      await tester.tap(find.text('Choose photos instead'));
      await settle(tester);
      expect(backend.pickCalls, 1);
      expect(find.text('Found 2 recipes'), findsOneWidget);
    });

    testWidgets('the message about the scanner leads straight to photos', (tester) async {
      final backend = backendWith()..captured = [p1, p2];
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      backend
        ..captureError = BookScanError.scannerFailed
        ..picked = [p3];
      await scanMore(tester);
      expect(find.textContaining('could not be opened'), findsOneWidget);

      await tester.tap(find.text('Choose photos'));
      await settle(tester);
      expect(backend.pickCalls, 1);
      expect(find.text('Found 3 recipes'), findsOneWidget);
      await clearSnackbar(tester);
    });

    testWidgets('photos that cannot be opened say so too', (tester) async {
      final backend = backendWith()..captured = [p1, p2];
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      backend.pickError = BookScanError.scannerFailed;
      await startAddingPages(tester, fromPhotos: true);
      await settle(tester);

      expect(backend.pickCalls, 1);
      expect(find.textContaining('could not be opened'), findsOneWidget);
      expect(find.text('Found 2 recipes'), findsOneWidget);
      await clearSnackbar(tester);
    });

    testWidgets('nothing can be added while the scanner is being opened for more', (tester) async {
      final backend = backendWith();
      final db = await openDb(tester);
      final outcome = await open(tester, backend, db);
      await scan(tester);

      final scanner = Completer<List<String>?>();
      backend.capturing = scanner;
      await startAddingPages(tester);
      await tester.tap(find.byType(BookScanBottomBar), warnIfMissed: false);
      await settle(tester);
      expect(outcome.closed, isFalse);
      expect(await savedRecipes(tester, db), isEmpty);

      scanner.complete([p4]);
      await settle(tester);
      expect(find.text('Found 4 recipes'), findsOneWidget);
    });

    testWidgets('a recipe cannot be opened while the scanner is being opened for more', (tester) async {
      final backend = backendWith()..captured = [p1];
      await open(tester, backend, await openDb(tester));
      await scan(tester);

      final scanner = Completer<List<String>?>();
      backend.capturing = scanner;
      await startAddingPages(tester);
      await tester.tap(find.text('Roasted Tomato Soup'), warnIfMissed: false);
      await settle(tester);
      expect(find.text('Edit recipe'), findsNothing);

      // What the scanner brings back is read into the queue as it stood.
      scanner.complete([p2]);
      await settle(tester);
      expect(queued(tester), ['Roasted Tomato Soup', 'Garlic Bread']);
      expect(metaOf(tester, 'Roasted Tomato Soup'), contains('3 steps'));
    });
  });

  group('layout', () {
    for (final size in const [Size(320, 568), Size(568, 320), Size(820, 1180)]) {
      for (final scale in const [1.0, 2.0]) {
        final at = '${size.width.toInt()}x${size.height.toInt()}, text x$scale';

        testWidgets('with nothing to review, every reason and both ways on fit at $at', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          // No page could be read.
          final backend = backendWith()..unreadable.addAll([p1, p2, p3]);
          await open(tester, backend, await openDb(tester), textScale: scale);
          await scan(tester);
          expect(find.text('Nothing could be read'), findsOneWidget);

          // One page read, with nothing on it, and two still unread.
          backend.unreadable.remove(p1);
          backend.pages[p1] = _prose;
          backend.captured = [p1];
          await tester.ensureVisible(find.text('Scan again'));
          await tester.pump();
          await tester.tap(find.text('Scan again'));
          await settle(tester);
          expect(find.text('No recipes found'), findsOneWidget);
          expect(find.textContaining('Photos 2, 3 could not be read'), findsOneWidget);

          // The rest read, and every recipe on them discarded.
          backend.unreadable.clear();
          backend.captured = [p2, p3];
          await tester.ensureVisible(find.text('Scan again'));
          await tester.pump();
          await tester.tap(find.text('Scan again'));
          await settle(tester);
          expect(find.textContaining('Found'), findsOneWidget);
          while (find.byType(BookScanDraftCard).evaluate().isNotEmpty) {
            await tester.ensureVisible(find.byType(BookScanDraftCard).first);
            await tester.pump();
            await tester.drag(find.byType(BookScanDraftCard).first, Offset(-size.width, 0));
            await settle(tester);
            await clearSnackbar(tester);
          }
          expect(find.text('Nothing left to add'), findsOneWidget);
          await tester.ensureVisible(find.text('Choose photos instead'));
          await tester.pump();
          expect(find.text('Scan more pages'), findsOneWidget);
        });

        testWidgets('the ways to add pages and the choice of a cookbook fit at $at', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          final backend = backendWith();
          final db = await openDb(tester);
          await tester.runAsync(() async {
            for (var i = 0; i < 12; i++) {
              await db.into(db.cookbooks).insert(
                    CookbooksCompanion.insert(id: 'shelf_$i', name: 'A cookbook with a rather long name, number $i'),
                  );
            }
          });
          final outcome = await open(tester, backend, db, textScale: scale);
          await scan(tester);

          await tester.tap(find.byTooltip('Scan more pages'));
          await settle(tester);
          expect(find.text('Scan pages'), findsOneWidget);
          expect(find.text('Choose photos'), findsOneWidget);
          await tester.binding.handlePopRoute();
          await settle(tester);

          await tester.runAsync(() => db.cookbookDao.deleteCookbook('book'));
          await tester.tap(find.byType(BookScanBottomBar));
          await settle(tester);
          expect(find.text('Choose a cookbook'), findsOneWidget);
          final last = find.text('My Recipes');
          await tester.scrollUntilVisible(last, 200, scrollable: find.byType(Scrollable).last);
          await tester.tap(last);
          await settleUntil(tester, () => outcome.closed);
          await settle(tester);
          expect(outcome.added, 3);
          await clearSnackbar(tester);
        });
      }
    }

    for (final size in const [Size(320, 568), Size(390, 844), Size(820, 1180)]) {
      for (final scale in const [1.0, 1.5]) {
        testWidgets('nothing overflows at ${size.width.toInt()}x${size.height.toInt()}, text x$scale', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          final backend = backendWith(numbered: false)..unreadable.add(p3);
          await open(tester, backend, await openDb(tester, existing: ['Garlic Bread']), textScale: scale);
          await scan(tester);
          expect(find.textContaining('Found'), findsOneWidget);

          await tester.tap(find.text('Set page numbers'));
          await settle(tester);
          await tester.tap(find.text('Cancel'));
          await settle(tester);

          // With a page unread, the summary and its notice fill a small
          // screen and the recipes start below the fold.
          await tester.scrollUntilVisible(find.text('Roasted Tomato Soup'), 120, scrollable: find.byType(Scrollable).first);
          await tester.pump();
          await tester.tap(find.byTooltip('More options').first);
          await settle(tester);
          await tester.tap(find.text('Split in two'));
          await settle(tester);
          await tester.binding.handlePopRoute();
          await settle(tester);

          await tester.ensureVisible(find.text('Roasted Tomato Soup'));
          await tester.pump();
          await tester.tap(find.text('Roasted Tomato Soup'));
          await settle(tester);
          expect(find.text('Edit recipe'), findsOneWidget);
          await tester.tap(find.byType(ScanPageImage).first);
          await settle(tester);
          await tester.binding.handlePopRoute();
          await settle(tester);
          await tester.binding.handlePopRoute();
          await settle(tester);

          await tester.binding.handlePopRoute();
          await settle(tester);
          expect(find.text('Discard this scan?'), findsOneWidget);
        });
      }
    }

    for (final size in const [Size(320, 568), Size(820, 1180)]) {
      testWidgets('both notices fit the first screen at ${size.width.toInt()}x${size.height.toInt()}, text x1.5',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final backend = backendWith()
          ..lost = [p1, p2, p3]
          ..captureError = BookScanError.cameraDenied;
        await open(tester, backend, await openDb(tester), textScale: 1.5);
        await scan(tester);

        // With large text on a small phone the notices start below the fold.
        final page = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(find.textContaining('Camera access is off'), 120, scrollable: page);
        await tester.scrollUntilVisible(find.textContaining('interrupted'), 120, scrollable: page);
        await tester.scrollUntilVisible(find.text('Read 3 pages'), 120, scrollable: page);
        await tester.pump();
        await tester.tap(find.text('Read 3 pages'));
        await settle(tester);
        expect(find.text('Found 3 recipes'), findsOneWidget);
      });
    }

    for (final size in const [Size(320, 568), Size(568, 320), Size(820, 1180)]) {
      testWidgets(
          'the first screen fits when it says the recipes are synced at '
          '${size.width.toInt()}x${size.height.toInt()}, text x2.0', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        // A cookbook shared with the user, which syncs on every plan.
        SharedPreferences.setMockInitialValues({});
        await tester.runAsync(() => CollabService.instance.markCollabCookbook('book', 'edit', ownerId: 'owner1'));
        addTearDown(() => CollabService.instance.setCookbookAccess(const []));

        final backend = backendWith()..captureError = BookScanError.cameraDenied;
        await open(tester, backend, await openDb(tester), textScale: 2.0);
        expect(
          find.text('Pages are read on this device. The recipes you add are synced with their pictures.'),
          findsOneWidget,
        );
        await scan(tester);
        await tester.tap(find.text('Choose photos'));
        await settle(tester);
        expect(find.text('Found 3 recipes'), findsOneWidget);
      });
    }
  });
}

/// Lets a transition, a sheet or a database call finish.
///
/// The database lives outside the test's fake clock, so its answers only
/// arrive when real time passes; the animations only move when fake time
/// does. Turn about, a few times, covers both.
Future<void> settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// [settle] until [done], for work that takes several database calls.
Future<void> settleUntil(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 80 && !done(); i++) {
    await settle(tester, rounds: 1);
  }
}

/// Snackbars dismiss themselves on a timer; run it out so none is pending
/// when the test ends.
Future<void> clearSnackbar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 6));
  await tester.pump(const Duration(seconds: 1));
}
