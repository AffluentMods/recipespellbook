// The screen where an answer from a chat is pasted, previewed and imported.
// The real screen and service run against an in-memory database, under a
// router with a home page and a recipe page, the way the app hosts them.
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/cookbook_provider.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/ui/screens/import/ai_import_screen.dart';

/// Holds the rows of an import back for [delay], the way a large import takes
/// a while on a real device. The wait runs on the test's clock.
class _SlowWrites extends drift.QueryInterceptor {
  Duration delay = Duration.zero;

  @override
  Future<void> runBatched(drift.QueryExecutor executor, drift.BatchedStatements statements) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return executor.runBatched(statements);
  }
}

/// The app around the screen.
class _App {
  _App(this.db, this.navigator, this.writes);

  final AppDatabase db;
  final GlobalKey<NavigatorState> navigator;
  final _SlowWrites writes;
}

const _phone = Size(390, 844);
const _desktop = Size(1280, 800);

String _recipeJson(String title, {Map<String, Object?> extra = const {}}) => jsonEncode({
      'title': title,
      'ingredients': [
        for (var i = 0; i < 3; i++) {'amount': '1', 'unit': 'cup', 'name': 'ingredient $i'},
      ],
      'steps': [
        {'instruction': 'Step 0.'},
        {'instruction': 'Step 1.'},
      ],
      ...extra,
    });

final _six = '[${[for (var i = 1; i <= 6; i++) _recipeJson('Recipe $i')].join(',')}]';

void main() {
  setUpAll(() => drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  /// Starts the app on its home page. [selectedCookbook] is the cookbook the
  /// app believes is open, whether or not it still exists. With [nested] the
  /// home page lives in a navigator of its own, below the one sheets open on.
  Future<_App> pumpApp(
    WidgetTester tester, {
    Size size = _phone,
    String? selectedCookbook = 'starter',
    bool nested = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final writes = _SlowWrites();
    final db = await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory().interceptWith(writes));
      // Opens it, with the starter cookbook and the built-in tags.
      await db.select(db.cookbooks).get();
      return db;
    });

    const home = Scaffold(body: Center(child: Text('HOME')));
    final root = GlobalKey<NavigatorState>();
    final inner = GlobalKey<NavigatorState>();
    final router = GoRouter(
      navigatorKey: root,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => nested
              ? Navigator(key: inner, onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => home))
              : home,
        ),
        GoRoute(path: '/recipe/:id', builder: (_, state) => Scaffold(body: Text('RECIPE ${state.pathParameters['id']}'))),
      ],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db!),
        selectedCookbookIdProvider.overrideWith((ref) => selectedCookbook),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    await tester.pump();
    return _App(db, nested ? inner : root, writes);
  }

  /// Opens the screen the way the import sheet does: pushed over the page
  /// that is showing.
  Future<void> openImport(WidgetTester tester, _App app, {String? cookbookId}) async {
    app.navigator.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => AiImportScreen(cookbookId: cookbookId)),
    );
    await settle(tester);
  }

  /// Pastes [answer] and opens the preview sheet.
  Future<void> preview(WidgetTester tester, String answer) async {
    await tester.enterText(find.byType(TextField), answer);
    await tester.pump();
    await tester.ensureVisible(find.text('Preview & Import'));
    await tester.pump();
    await tester.tap(find.text('Preview & Import'));
    await settle(tester);
  }

  /// From the pasted answer to the end of the import.
  Future<void> import(WidgetTester tester, String answer, {String button = 'Import to Cookbook'}) async {
    await preview(tester, answer);
    await tester.tap(find.text(button));
    await settle(tester, rounds: 6);
  }

  Future<List<Recipe>> imported(WidgetTester tester, _App app) async {
    final rows = await tester.runAsync(() => (app.db.select(app.db.recipes)..where((t) => t.id.like('ai_%'))).get());
    return rows!;
  }

  /// The filled button with this label: the one at the foot of the page, which
  /// also shows that an import is under way, or the one on the sheet.
  FilledButton filledButton(WidgetTester tester, String label) => tester.widget<FilledButton>(
        find.ancestor(of: find.text(label), matching: find.byWidgetPredicate((w) => w is FilledButton)),
      );

  group('importing', () {
    for (final size in const [_phone, _desktop]) {
      testWidgets('tapping Import again does not import twice, at ${size.width.toInt()}x${size.height.toInt()}',
          (tester) async {
        final app = await pumpApp(tester, size: size);
        await openImport(tester, app);
        await preview(tester, _six);
        expect(find.text('6 Recipes Found'), findsOneWidget);

        app.writes.delay = const Duration(milliseconds: 600);
        final spot = tester.getCenter(find.text('Import 6 Recipes'));
        // Twice before the screen can react, and once more while it saves.
        await tester.tapAt(spot);
        await tester.tapAt(spot);
        await settle(tester, rounds: 1);
        expect(find.text('Importing...'), findsOneWidget);
        expect(filledButton(tester, 'Importing...').onPressed, isNull);
        await tester.tapAt(spot);

        await settleUntil(tester, () => find.text('HOME').evaluate().isNotEmpty);
        await settle(tester);
        app.writes.delay = Duration.zero;

        expect(tester.takeException(), isNull);
        // Only the sheet and the import screen closed.
        expect(find.text('HOME'), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('6 recipes imported successfully!'), findsOneWidget);
        final rows = await imported(tester, app);
        expect(rows.map((r) => r.title), [for (var i = 1; i <= 6; i++) 'Recipe $i']);
        await clearSnackbar(tester);
      });
    }

    testWidgets('confirming twice at once closes the sheet and nothing below it', (tester) async {
      // The screen sits in a navigator of its own while the sheet covers the
      // whole app, so a second close would reach the page that holds both.
      final app = await pumpApp(tester, nested: true);
      await openImport(tester, app);
      await preview(tester, _six);

      // Activated twice before the first press has closed the sheet, as an
      // assistive tool can do: the framework only swallows a second touch.
      final importButton = filledButton(tester, 'Import 6 Recipes');
      importButton.onPressed!();
      importButton.onPressed!();
      await settleUntil(tester, () => find.text('HOME').evaluate().isNotEmpty);
      await settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('6 recipes imported successfully!'), findsOneWidget);
      expect(await imported(tester, app), hasLength(6));
      await clearSnackbar(tester);
    });

    testWidgets('two previews of the same answer, both confirmed, import it once', (tester) async {
      final app = await pumpApp(tester);
      await openImport(tester, app);
      await tester.enterText(find.byType(TextField), _six);
      await tester.pump();
      // Activated twice before the first sheet is up.
      final previewButton = filledButton(tester, 'Preview & Import');
      previewButton.onPressed!();
      previewButton.onPressed!();
      await settle(tester);
      expect(find.text('Import 6 Recipes'), findsNWidgets(2));

      // The sheet underneath is confirmed while the first import is saving.
      app.writes.delay = const Duration(milliseconds: 600);
      await tester.tap(find.text('Import 6 Recipes').last);
      await settle(tester, rounds: 1);
      await tester.tap(find.text('Import 6 Recipes').first, warnIfMissed: false);
      await settleUntil(tester, () => find.text('HOME').evaluate().isNotEmpty);
      await settle(tester);
      app.writes.delay = Duration.zero;

      expect(tester.takeException(), isNull);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(await imported(tester, app), hasLength(6));
      await clearSnackbar(tester);
    });

    testWidgets('going back just before the import ends closes nothing else', (tester) async {
      final app = await pumpApp(tester);
      await openImport(tester, app);
      await preview(tester, _six);

      app.writes.delay = const Duration(milliseconds: 300);
      await tester.tap(find.text('Import 6 Recipes'));
      await settle(tester, rounds: 1);
      expect(find.text('Importing...'), findsOneWidget);

      // The screen is on its way out when the import finishes.
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await settle(tester);
      app.writes.delay = Duration.zero;

      expect(tester.takeException(), isNull);
      expect(find.text('HOME'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('6 recipes imported successfully!'), findsOneWidget);
      expect(await imported(tester, app), hasLength(6));
      await clearSnackbar(tester);
    });

    testWidgets('leaving long before the import ends still saves it, quietly', (tester) async {
      final app = await pumpApp(tester);
      await openImport(tester, app);
      await preview(tester, _six);

      app.writes.delay = const Duration(seconds: 2);
      await tester.tap(find.text('Import 6 Recipes'));
      await settle(tester, rounds: 1);
      await tester.binding.handlePopRoute();
      await settle(tester, rounds: 12);
      app.writes.delay = Duration.zero;

      expect(tester.takeException(), isNull);
      expect(find.text('HOME'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(await imported(tester, app), hasLength(6));
    });

    testWidgets('an import that fails says so on the page and saves nothing, retry included', (tester) async {
      final app = await pumpApp(tester);
      await tester.runAsync(() => app.db.customStatement(
            "CREATE TRIGGER fail_step BEFORE INSERT ON steps WHEN NEW.instruction = 'Step 1.' "
            "BEGIN SELECT RAISE(ABORT, 'boom'); END;",
          ));
      await openImport(tester, app);

      for (var attempt = 0; attempt < 2; attempt++) {
        await import(tester, _recipeJson('Chicken Stew'));

        // The sheet is gone and the reason is where the user is looking.
        expect(find.text('Import to Cookbook'), findsNothing);
        expect(find.textContaining('nothing was saved').hitTestable(), findsOneWidget);
        expect(find.textContaining('SqliteException'), findsNothing);
        expect(filledButton(tester, 'Preview & Import').onPressed, isNotNull);
        expect(tester.takeException(), isNull);

        expect(await imported(tester, app), isEmpty);
        expect(await tester.runAsync(() => app.db.select(app.db.ingredients).get()), isEmpty);
      }
    });

    testWidgets('View on the banner opens the recipe once the screen has closed', (tester) async {
      final app = await pumpApp(tester);
      await openImport(tester, app);
      await import(tester, _recipeJson('Solo Soup'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('Recipe imported successfully!'), findsOneWidget);

      await tester.tap(find.text('View'));
      await settle(tester);
      expect(tester.takeException(), isNull);
      final recipe = (await imported(tester, app)).single;
      expect(find.text('RECIPE ${recipe.id}'), findsOneWidget);
      await clearSnackbar(tester);
    });

    testWidgets('the banner still shows when the device has animations switched off', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

      final app = await pumpApp(tester);
      await openImport(tester, app);
      await preview(tester, _recipeJson('Solo Soup'));
      await tester.tap(find.text('Import to Cookbook'));
      // Frame by frame: the screen is gone a few frames after it closes.
      for (var i = 0; i < 60; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 1)));
        await tester.pump(const Duration(milliseconds: 10));
      }

      expect(tester.takeException(), isNull);
      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('Recipe imported successfully!'), findsOneWidget);
      expect(await imported(tester, app), hasLength(1));
      await clearSnackbar(tester);
    });
  });

  group('the cookbook', () {
    Future<void> addCookbook(WidgetTester tester, _App app, String id, String name) => tester.runAsync(
          () => app.db.into(app.db.cookbooks).insert(CookbooksCompanion.insert(id: id, name: name)),
        );

    testWidgets('recipes go into the cookbook the screen was opened for', (tester) async {
      final app = await pumpApp(tester);
      await addCookbook(tester, app, 'baking', 'Baking');
      await openImport(tester, app, cookbookId: 'baking');
      await import(tester, _recipeJson('Scones'));

      expect((await imported(tester, app)).single.cookbookId, 'baking');
      expect(find.text('Recipe imported successfully!'), findsOneWidget);
      await clearSnackbar(tester);
    });

    testWidgets('opened without one, they go into the selected cookbook', (tester) async {
      final app = await pumpApp(tester, selectedCookbook: 'baking');
      await addCookbook(tester, app, 'baking', 'Baking');
      await openImport(tester, app);
      await import(tester, _recipeJson('Scones'));

      expect((await imported(tester, app)).single.cookbookId, 'baking');
      await clearSnackbar(tester);
    });

    testWidgets('a cookbook that is gone is never written to: the starter cookbook is used, and named', (tester) async {
      final app = await pumpApp(tester, selectedCookbook: 'cookbook_deleted');
      await openImport(tester, app);
      await import(tester, _recipeJson('Soup A'));
      expect(find.text('Recipe imported into My Recipes.'), findsOneWidget);
      await clearSnackbar(tester);

      await openImport(tester, app, cookbookId: 'gone');
      await import(tester, '[${_recipeJson('Soup B')},${_recipeJson('Soup C')}]', button: 'Import 2 Recipes');
      expect(find.text('2 recipes imported into My Recipes.'), findsOneWidget);
      await clearSnackbar(tester);

      final rows = await imported(tester, app);
      expect(rows.map((r) => r.title), ['Soup A', 'Soup B', 'Soup C']);
      expect(rows.map((r) => r.cookbookId).toSet(), {'starter'});
    });

    testWidgets('with no cookbook at all the import is refused with a message', (tester) async {
      final app = await pumpApp(tester);
      await tester.runAsync(() => app.db.delete(app.db.cookbooks).go());
      await openImport(tester, app);
      await import(tester, _recipeJson('Soup A'));

      expect(find.text('There is no cookbook to import into. Add a cookbook first.').hitTestable(), findsOneWidget);
      expect(filledButton(tester, 'Preview & Import').onPressed, isNotNull);
      expect(await imported(tester, app), isEmpty);
    });
  });

  group('the preview', () {
    testWidgets('fields the answer typed loosely are shown and imported as what they mean', (tester) async {
      final app = await pumpApp(tester);
      await openImport(tester, app);
      await preview(
        tester,
        _recipeJson('Baked Ziti', extra: {
          'servings': 6,
          'prepTimeMinutes': '20',
          'course': ['Main Dish'],
          'category': ['Pasta', 'Casserole'],
          'cuisine': 'Italian',
          'tags': ['quick', 'weeknight'],
        }),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(find.text('1 Recipe Found'), findsOneWidget);
      expect(find.text('Main Dish'), findsOneWidget);
      expect(find.text('Pasta, Casserole'), findsOneWidget);

      // Opened up, the card lists the tags the recipe will carry.
      await tester.tap(find.text('Baked Ziti'));
      await settle(tester);
      expect(find.text('6 servings'), findsOneWidget);
      expect(find.text('20m prep'), findsOneWidget);
      for (final tag in ['Italian', 'quick', 'weeknight']) {
        expect(find.text(tag), findsOneWidget);
      }

      await tester.tap(find.text('Import to Cookbook'));
      await settle(tester, rounds: 6);
      final recipe = (await imported(tester, app)).single;
      expect(recipe.courseId, 'main');
      expect(recipe.categoryId, 'pasta,casserole');
      final tags = await tester.runAsync(() => app.db.tagsDao.getTagsForRecipe(recipe.id));
      expect(tags!.map((t) => t.name), unorderedEquals(['Italian', 'Quick & Easy', 'Weeknight Dinner']));
      await clearSnackbar(tester);
    });

    testWidgets('an answer that cannot be read is explained on the page, with no sheet', (tester) async {
      final app = await pumpApp(tester);
      await openImport(tester, app);
      await preview(tester, '${_recipeJson('Soup A')}\n{"title":"Soup B","ingredients":[{"name":"car');

      expect(find.textContaining('The answer may have been cut off'), findsOneWidget);
      expect(find.textContaining('Found'), findsNothing);
      expect(await imported(tester, app), isEmpty);
    });
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
