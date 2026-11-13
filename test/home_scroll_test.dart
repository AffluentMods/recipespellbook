// The phone Home dashboard keeps every section while scrolling. As a lazy
// list it dropped the sections scrolled out of view and rebuilt them on the
// way back at their loading height, so they grew a frame later and the page
// jumped against the finger. Folding the add button must not rebuild the page.
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
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/screens/home/home_mobile.dart';
import 'package:recipespellbook/ui/widgets/app_controls.dart';
import 'package:recipespellbook/ui/widgets/guides_tip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('phone Home keeps its sections while scrolling down and back up', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});

    final now = DateTime.now();
    final db = (await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'book', name: 'Family Cookbook'));
      for (var i = 0; i < 12; i++) {
        await db.into(db.recipes).insert(RecipesCompanion.insert(
              id: 'r$i',
              cookbookId: 'book',
              title: 'Recipe $i',
              courseId: drift.Value(i.isEven ? 'main' : 'dessert'),
              isFavorite: drift.Value(i < 4),
              lastViewedAt: drift.Value(now.subtract(Duration(hours: i))),
            ));
      }
      await db.mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
        id: 'm1',
        date: DateTime(now.year, now.month, now.day),
        recipeId: const drift.Value('r1'),
      ));
      return db;
    }))!;
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    container.read(settingsProvider);

    final cookbook = (await tester.runAsync(
      () => (db.select(db.cookbooks)..where((c) => c.id.equals('book'))).getSingle(),
    ))!;
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => MobileHome(cookbook: cookbook, cookbookId: 'book', emptyState: const Text('Empty')),
      ),
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
    for (var i = 0; i < 60 && find.byType(GuidesTipCard, skipOffstage: false).evaluate().isEmpty; i++) {
      await _settle(tester, rounds: 1);
    }
    await _settle(tester, rounds: 8);

    final tip = tester.state(find.byType(GuidesTipCard, skipOffstage: false));
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable).first);
    final position = scrollable.position;
    expect(position.maxScrollExtent, greaterThan(800), reason: 'a page taller than the screen');
    bool fabExtended() => tester.widget<AccentFab>(find.byType(AccentFab)).extended;
    expect(fabExtended(), isTrue);

    // Down to the bottom with the finger: the add button folds.
    for (var i = 0; i < 12 && position.pixels < position.maxScrollExtent; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await _settle(tester, rounds: 2);
    }
    expect(position.pixels, position.maxScrollExtent);
    expect(fabExtended(), isFalse);
    expect(tester.getRect(find.byType(GuidesTipCard)).bottom, lessThan(0), reason: 'scrolled out of view');
    expect(tester.state(find.byType(GuidesTipCard, skipOffstage: false)), same(tip),
        reason: 'kept, not rebuilt at zero height');

    // Back up in steps: each lands exactly where the finger left it.
    while (position.pixels > 0) {
      final before = position.pixels;
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 300));
      await tester.pump();
      final landed = position.pixels;
      expect(landed, lessThan(before));
      await _settle(tester, rounds: 3);
      expect(position.pixels, landed, reason: 'nothing grows under the finger and moves the page');
    }
    expect(fabExtended(), isTrue);
    expect(tester.state(find.byType(GuidesTipCard)), same(tip));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await _settle(tester);
    await tester.runAsync(() => db.close().timeout(const Duration(seconds: 2), onTimeout: () {}));
  });
}
