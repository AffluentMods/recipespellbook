// Scan this book, end to end on the screen: the camera and text recognition
// are replaced by a canned backend, everything else is the real thing (the
// splitter, the review queue, the saver and an in-memory database).
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
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
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/screens/book_scan/book_scan_screen.dart';
import 'package:recipespellbook/ui/screens/book_scan/book_scan_widgets.dart';

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
  Duration? readDelay;
  final unreadable = <String>{};

  int captureCalls = 0;
  int pickCalls = 0;
  bool closed = false;
  final savedImages = <String>[];

  @override
  Future<List<String>?> capturePages({int maxPages = 60}) async {
    captureCalls++;
    if (captureError != null) throw BookScanException(captureError!);
    return captured;
  }

  @override
  Future<List<String>> pickPhotos() async {
    pickCalls++;
    return picked;
  }

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
    return null;
  }

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
                        openBackend: () async => backend,
                        afterSave: (ids) async => outcome.savedIds = ids,
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
      expect(find.textContaining('1 page could not be read'), findsOneWidget);
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
      await tester.tap(find.byTooltip('Scan more pages'));
      await settle(tester);

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
  });

  group('layout', () {
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

          await tester.tap(find.byTooltip('More options').first);
          await settle(tester);
          await tester.tap(find.text('Split in two'));
          await settle(tester);
          await tester.binding.handlePopRoute();
          await settle(tester);

          await tester.tap(find.text('Set page numbers'));
          await settle(tester);
          await tester.tap(find.text('Cancel'));
          await settle(tester);

          // On the smallest phone with the largest text the summary fills
          // the screen and the first recipe starts below the fold.
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
