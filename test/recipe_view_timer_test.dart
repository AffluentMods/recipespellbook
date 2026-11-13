// "Jump back in" and the recently viewed lists count a recipe as viewed only
// after it has been open for 3 seconds: a quick look in and out does not
// count, and tapping a recipe in a list no longer counts by itself.
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/providers/settings_provider.dart';
import 'package:recipespellbook/router/router.dart' show recipeRouteScreen;
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/utils/recipe_view_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('RecipeViewTimer', () {
    testWidgets('counts a recipe after 3 seconds, not before', (tester) async {
      final viewed = <String>[];
      final timer = RecipeViewTimer(viewed.add);
      expect(timer.delay, const Duration(seconds: 3));

      timer.start('soup');
      await tester.pump(const Duration(milliseconds: 2999));
      expect(viewed, isEmpty);
      await tester.pump(const Duration(milliseconds: 1));
      expect(viewed, ['soup']);
      await tester.pump(const Duration(seconds: 10));
      expect(viewed, ['soup'], reason: 'once');
    });

    testWidgets('cancelled (the page closed) before 3 seconds, nothing counts', (tester) async {
      final viewed = <String>[];
      final timer = RecipeViewTimer(viewed.add);
      timer.start('soup');
      await tester.pump(const Duration(seconds: 2));
      timer.cancel();
      await tester.pump(const Duration(seconds: 10));
      expect(viewed, isEmpty);
    });

    testWidgets('a different recipe starts the count again', (tester) async {
      final viewed = <String>[];
      final timer = RecipeViewTimer(viewed.add);
      timer.start('soup');
      await tester.pump(const Duration(seconds: 2));
      timer.start('stew');
      await tester.pump(const Duration(seconds: 2));
      expect(viewed, isEmpty, reason: 'soup was left after 2 seconds, stew only open for 2');
      await tester.pump(const Duration(seconds: 1));
      expect(viewed, ['stew']);
      timer.cancel();
    });
  });

  group('the recipe page', () {
    Future<void> realTime(WidgetTester tester) =>
        tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));

    Future<(AppDatabase, ProviderContainer, GoRouter)> open(WidgetTester tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final db = (await tester.runAsync(() async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'book', name: 'Book'),
            mode: drift.InsertMode.insertOrIgnore);
        await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'soup', cookbookId: 'book', title: 'Soup'));
        return db;
      }))!;
      final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
      container.read(settingsProvider);
      final router = GoRouter(routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: Center(
              child: TextButton(onPressed: () => context.push('/recipe/soup'), child: const Text('Open')),
            ),
          ),
        ),
        GoRoute(path: '/recipe/:id', builder: (_, state) => recipeRouteScreen(state)),
      ]);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme(AppColorTheme.spellbook),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ));
      await realTime(tester);
      await tester.pump();
      return (db, container, router);
    }

    Future<DateTime?> lastViewed(WidgetTester tester, AppDatabase db) async {
      final recipe = await tester.runAsync(
        () => (db.select(db.recipes)..where((r) => r.id.equals('soup'))).getSingle(),
      );
      return recipe!.lastViewedAt;
    }

    Future<void> close(WidgetTester tester, AppDatabase db, ProviderContainer container) async {
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      var closed = false;
      db.close().whenComplete(() => closed = true);
      for (var round = 0; round < 20 && !closed; round++) {
        await realTime(tester);
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    /// Advances the test clock in steps, letting database calls finish.
    Future<void> wait(WidgetTester tester, Duration total) async {
      const step = Duration(milliseconds: 250);
      for (var t = Duration.zero; t < total; t += step) {
        await realTime(tester);
        await tester.pump(step);
      }
    }

    testWidgets('open for 3 seconds: counted as viewed', (tester) async {
      final (db, container, _) = await open(tester);
      await tester.tap(find.text('Open'));
      await wait(tester, const Duration(milliseconds: 2500));
      expect(find.text('Soup'), findsWidgets, reason: 'the recipe page is showing');
      expect(await lastViewed(tester, db), isNull, reason: 'two and a half seconds is a quick look');

      await wait(tester, const Duration(seconds: 1));
      await realTime(tester);
      expect(await lastViewed(tester, db), isNotNull);
      await close(tester, db, container);
    });

    testWidgets('back out within 3 seconds: not counted', (tester) async {
      final (db, container, router) = await open(tester);
      await tester.tap(find.text('Open'));
      await wait(tester, const Duration(seconds: 2));
      router.pop();
      await wait(tester, const Duration(seconds: 5));
      expect(find.text('Open'), findsOneWidget);
      expect(await lastViewed(tester, db), isNull);
      await close(tester, db, container);
    });
  });
}
