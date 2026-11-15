// Settings > Home screen on Home itself: each switch takes its section off
// the phone and the desktop Home, leaving nothing of it behind, and "Edit
// Home screen" at the foot of Home opens the page. With every section off,
// Home is the greeting, the search and the add button, and says so.
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
import 'package:recipespellbook/ui/screens/cookbooks/cookbook_update_sheet.dart';
import 'package:recipespellbook/ui/screens/home/home_desktop.dart';
import 'package:recipespellbook/ui/screens/home/home_mobile.dart';
import 'package:recipespellbook/ui/screens/pantry_cooking/pantry_cooking_widgets.dart';
import 'package:recipespellbook/ui/screens/settings/home_screen_settings_screen.dart';
import 'package:recipespellbook/ui/widgets/backup_reminder_banner.dart';
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

  Future<(AppDatabase, Cookbook)> openDb(WidgetTester tester) async {
    final now = DateTime.now();
    return (await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'book', name: 'Family Cookbook'));
      for (var i = 0; i < 8; i++) {
        await db.into(db.recipes).insert(RecipesCompanion.insert(
              id: 'r$i',
              cookbookId: 'book',
              title: 'Recipe $i',
              courseId: drift.Value(i.isEven ? 'main' : 'dessert'),
              isFavorite: drift.Value(i < 3),
              lastViewedAt: drift.Value(now.subtract(Duration(hours: i))),
            ));
      }
      final cookbook = await (db.select(db.cookbooks)..where((c) => c.id.equals('book'))).getSingle();
      return (db, cookbook);
    }))!;
  }

  Future<(AppDatabase, ProviderContainer)> open(
    WidgetTester tester, {
    required bool desktop,
    Map<String, Object> prefs = const {},
  }) async {
    tester.view.physicalSize = desktop ? const Size(1400, 1000) : const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(prefs);
    final (db, cookbook) = await openDb(tester);
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    container.read(settingsProvider);
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => desktop
            ? DesktopHome(cookbook: cookbook, cookbookId: 'book', emptyState: const Text('Empty'))
            : MobileHome(cookbook: cookbook, cookbookId: 'book', emptyState: const Text('Empty')),
      ),
      GoRoute(path: homeScreenSettingsPath, builder: (_, _) => const HomeScreenSettingsScreen()),
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
    for (var i = 0; i < 60 && find.text('Recipe 0', skipOffstage: false).evaluate().isEmpty; i++) {
      await _settle(tester, rounds: 1);
    }
    await _settle(tester, rounds: 8);
    return (db, container);
  }

  Future<void> close(WidgetTester tester, AppDatabase db, ProviderContainer container) async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await _settle(tester);
    await tester.runAsync(() => db.close().timeout(const Duration(seconds: 2), onTimeout: () {}));
  }

  /// What each section puts on Home. Text that also shows elsewhere (the
  /// Favorites and Cookbooks chips on the phone) is counted, not required to
  /// vanish.
  Map<HomeSection, Finder> sectionFinders() => {
        HomeSection.libraryChips: find.text('All recipes', skipOffstage: false),
        HomeSection.nextSevenDays: find.text('Next 7 days', skipOffstage: false),
        HomeSection.shoppingList: find.text('Open list', skipOffstage: false),
        HomeSection.whatCanIMake: find.byType(PantryCookingHomeCard, skipOffstage: false),
        HomeSection.dinnerIdeas: find.byType(DinnerSuggestionsSection, skipOffstage: false),
        HomeSection.jumpBackIn: find.text('Jump back in', skipOffstage: false),
        HomeSection.favorites: find.text('Favorites', skipOffstage: false),
        HomeSection.browse: find.text('Courses', skipOffstage: false),
        HomeSection.cookbookShelf: find.text('Cookbooks', skipOffstage: false),
        HomeSection.guidesTip: find.byType(GuidesTipCard, skipOffstage: false),
        HomeSection.backupReminder: find.byType(BackupReminderBanner, skipOffstage: false),
        HomeSection.cookbookUpdates: find.byType(CookbookUpdateBanner, skipOffstage: false),
      };

  for (final desktop in [false, true]) {
    final layout = desktop ? 'desktop' : 'phone';

    testWidgets('$layout: each switch takes its section off Home and puts it back', (tester) async {
      final (db, container) = await open(tester, desktop: desktop);
      final notifier = container.read(settingsProvider.notifier);
      final finders = sectionFinders();

      for (final section in HomeSection.values) {
        // The desktop has no library chips: the sidebar has those.
        if (desktop && section == HomeSection.libraryChips) {
          expect(finders[section], findsNothing);
          continue;
        }
        final shown = finders[section]!.evaluate().length;
        expect(shown, greaterThan(0), reason: '${section.name} is on Home');

        await tester.runAsync(() => notifier.setHomeSectionShown(section, false));
        await _settle(tester, rounds: 2);
        final hidden = finders[section]!.evaluate().length;
        expect(hidden, lessThan(shown), reason: '${section.name} is off');
        if (section != HomeSection.favorites && section != HomeSection.cookbookShelf) {
          expect(hidden, 0, reason: '${section.name} leaves nothing behind');
        }

        await tester.runAsync(() => notifier.setHomeSectionShown(section, true));
        await _settle(tester, rounds: 2);
        expect(finders[section]!.evaluate().length, shown, reason: '${section.name} is back');
      }
      expect(find.text('Edit Home screen', skipOffstage: false), findsOneWidget);
      expect(find.text('Every section of Home is turned off.', skipOffstage: false), findsNothing);
      expect(tester.takeException(), isNull);

      await close(tester, db, container);
    });

    testWidgets('$layout: one of the week and the shopping list fills the row alone', (tester) async {
      final (db, container) = await open(tester, desktop: desktop, prefs: {
        SettingsNotifier.homeHiddenSectionsKey: ['nextSevenDays'],
      });
      expect(find.text('Next 7 days', skipOffstage: false), findsNothing);
      final list = find.text('Open list', skipOffstage: false);
      expect(list, findsOneWidget);
      expect(tester.takeException(), isNull);

      await close(tester, db, container);
    });

    testWidgets('$layout: with every section off, Home says so and Edit Home screen opens the page', (tester) async {
      final (db, container) = await open(tester, desktop: desktop, prefs: {
        SettingsNotifier.homeHiddenSectionsKey: [for (final s in HomeSection.values) s.name],
      });

      for (final finder in sectionFinders().values) {
        expect(finder, findsNothing);
      }
      expect(find.text('Every section of Home is turned off.'), findsOneWidget);
      // The greeting and the way to add a recipe stay.
      expect(find.textContaining('Good ', skipOffstage: false), findsWidgets);
      expect(find.text('Add Recipe', skipOffstage: false), findsWidgets);
      if (!desktop) expect(find.text('Search recipes...'), findsOneWidget);

      await tester.tap(find.text('Edit Home screen'));
      await _settle(tester, rounds: 4);
      expect(find.byType(HomeScreenSettingsScreen), findsOneWidget);
      expect(find.text('Home screen'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await close(tester, db, container);
    });
  }
}
