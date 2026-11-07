// The 2.0.1 pantry: dated items with a shelf life and "Still have these?",
// the freezer, moving items to and from Always have, Clear all with a Yes /
// No check, and the ready-made ingredient lists.
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/common_ingredient_packs.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/pantry_service.dart';
import 'package:recipespellbook/services/pantry_shelf_life.dart';
import 'package:recipespellbook/ui/screens/settings/pantry_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _day = DateTime(2026, 11, 7, 9);

void main() {
  group('shelf life', () {
    test('fresh food is checked, shelf-stable food never is', () {
      expect(pantryShelfLifeDays('salmon'), 2);
      expect(pantryShelfLifeDays('ground beef'), 3);
      expect(pantryShelfLifeDays('cilantro'), 4);
      expect(pantryShelfLifeDays('milk'), 10);
      expect(pantryShelfLifeDays('eggs'), 28);
      expect(pantryShelfLifeDays('butter'), 60);
      expect(pantryShelfLifeDays('potatoes'), 21);
      for (final keeps in ['all-purpose flour', 'cumin', 'olive oil', 'soy sauce', 'white rice', 'black beans',
          'canned tuna', 'peanut butter', 'garlic powder', 'ground ginger', 'breadcrumbs', 'something unknown']) {
        expect(pantryShelfLifeDays(keeps), isNull, reason: keeps);
      }
    });

    test('the freezer keeps things for months', () {
      expect(pantryShelfLifeDays('chicken breasts', frozen: true), freezerShelfLifeDays);
      expect(pantryItemIsDue('ground beef', _day, frozen: true, now: _day.add(const Duration(days: 30))), isFalse);
      expect(pantryItemIsDue('ground beef', _day, now: _day.add(const Duration(days: 3))), isTrue);
      expect(pantryItemIsDue('ground beef', _day, now: _day.add(const Duration(days: 2))), isFalse);
    });

    test('ready-made items are known in every language', () {
      expect(pantryShelfLifeDays('Milch'), 10);
      expect(pantryShelfLifeDays('huevos'), 28);
      expect(pantryShelfLifeDays('Olivenöl'), isNull);
      expect(commonIngredientEnglishName('Oregano (getrocknet)'), 'dried oregano');
    });

    test('every list has an entry in all twelve languages', () {
      for (final id in ingredientPackIds) {
        final en = ingredientPackItems(id, 'en');
        expect(en, isNotEmpty);
        for (final lang in ingredientPackLanguages) {
          final items = ingredientPackItems(id, lang);
          expect(items.length, en.length);
          expect(items.every((i) => i.trim().isNotEmpty), isTrue, reason: '$id $lang');
        }
        expect(ingredientPackItems(id, 'xx'), en, reason: 'unknown languages fall back to English');
      }
    });
  });

  group('PantryService', () {
    late DateTime now;

    setUp(() {
      PantryService.resetForTesting();
      now = _day;
      PantryService.instance.now = () => now;
    });

    test('items from before 2.0.1 start their clock on the first load', () async {
      SharedPreferences.setMockInitialValues({'pantry_items': jsonEncode(['salmon', 'flour'])});
      final entries = await PantryService.instance.getEntries();
      expect([for (final e in entries) e.name], ['flour', 'salmon']);
      expect(entries.every((e) => e.addedAt == _day && !e.frozen), isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('pantry_item_info'), contains('salmon'));
    });

    test('dates, keep, freezer, clear', () async {
      SharedPreferences.setMockInitialValues({});
      final pantry = PantryService.instance;
      await pantry.addItems(['salmon', 'flour', 'ground beef']);
      now = _day.add(const Duration(days: 4));
      var due = [for (final e in await pantry.getEntries()) if (e.isDue(now)) e.name];
      expect(due, ['ground beef', 'salmon']);

      await pantry.keepItems(['salmon']);
      await pantry.setFrozen('ground beef', true);
      due = [for (final e in await pantry.getEntries()) if (e.isDue(now)) e.name];
      expect(due, isEmpty);
      final beef = (await pantry.getEntries()).firstWhere((e) => e.name == 'ground beef');
      expect(beef.frozen, isTrue);
      expect(beef.addedAt, now);

      // Buying it again restarts the clock and keeps it in the freezer.
      now = now.add(const Duration(days: 10));
      await pantry.addItem('Ground Beef');
      final again = (await pantry.getEntries()).firstWhere((e) => e.name == 'ground beef');
      expect(again.addedAt, now);
      expect(again.frozen, isTrue);

      // Survives a restart.
      PantryService.resetForTesting();
      PantryService.instance.now = () => now;
      expect((await PantryService.instance.getEntries()).firstWhere((e) => e.name == 'ground beef').frozen, isTrue);

      await PantryService.instance.addBasic('olive oil');
      await PantryService.instance.clear();
      expect(await PantryService.instance.getAll(), isEmpty);
      expect(await PantryService.instance.getBasics(), contains('olive oil'), reason: 'Always have stays');
    });

    test('moving between On hand now and Always have', () async {
      SharedPreferences.setMockInitialValues({});
      final pantry = PantryService.instance;
      await pantry.addItems(['flour', 'milk']);
      await pantry.moveToBasics('flour');
      expect(await pantry.getAll(), ['milk']);
      expect(await pantry.getBasics(), contains('flour'));

      await pantry.moveBasicToPantry('salt');
      expect(await pantry.getAll(), ['milk', 'salt']);
      expect(await pantry.getBasics(), isNot(contains('salt')));

      // Adding a list to Always have takes those items off the pantry.
      await pantry.addBasics(['milk', 'cumin']);
      expect(await pantry.getAll(), ['salt']);
      expect(await pantry.getBasics(), containsAll(['milk', 'cumin', 'flour']));
    });

    test('the shopping list leaves out pantry items and Always have basics', () async {
      SharedPreferences.setMockInitialValues({'pantry_basics': jsonEncode(['water', 'flour'])});
      final pantry = PantryService.instance;
      await pantry.addItems(['eggs', 'olive oil']);
      final matches = await pantry.filterPantryMatches({
        'a': 'large eggs',
        'b': 'extra virgin olive oil',
        'c': 'all-purpose flour',
        'd': 'watermelon',
        'e': 'milk',
      });
      expect(matches, {'a', 'b', 'c'});
    });
  });

  group('pantry screen', () {
    Future<AppDatabase> openDb(WidgetTester tester) async =>
        (await tester.runAsync(() async => AppDatabase.forTesting(NativeDatabase.memory())))!;

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> open(WidgetTester tester, AppDatabase db) async {
      tester.view.physicalSize = const Size(411, 2400); // a Pixel phone's width
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PantryScreen(),
        ),
      ));
      await settle(tester);
    }

    Future<void> close(WidgetTester tester, AppDatabase db) async {
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpWidget(const SizedBox());
      await settle(tester);
      await tester.runAsync(() => db.close().timeout(const Duration(seconds: 2), onTimeout: () {}));
    }

    setUp(() {
      drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final old = DateTime.now().subtract(const Duration(days: 6)).millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        'pantry_items': jsonEncode(['cilantro', 'ground beef', 'flour']),
        'pantry_item_info': jsonEncode({
          'cilantro': {'a': old},
          'ground beef': {'a': DateTime.now().millisecondsSinceEpoch},
          'flour': {'a': old},
        }),
      });
      PantryService.resetForTesting();
    });

    testWidgets('still have these, freezer, Always have, clear all', (tester) async {
      final db = await openDb(tester);
      await open(tester, db);

      // Six-day-old cilantro is due; flour never is.
      expect(find.text('Still have these?'), findsOneWidget);
      expect(find.text('On hand now (3)'), findsOneWidget);
      await tester.tap(find.text('Keep'));
      await settle(tester);
      expect(find.text('Still have these?'), findsNothing);

      // Ground beef goes in the freezer.
      await tester.tap(find.descendant(
        of: find.byKey(const ValueKey('pantry-row-ground beef')),
        matching: find.byTooltip('Put in the freezer'),
      ));
      await settle(tester);
      expect(find.text('Freezer'), findsOneWidget);
      expect(find.text('Frozen today'), findsOneWidget);

      // Flour moves to Always have.
      await tester.tap(find.byKey(const ValueKey('pantry-always-flour')));
      await settle(tester);
      expect(find.text('On hand now (2)'), findsOneWidget);
      expect(find.byKey(const ValueKey('pantry-basic-flour')), findsOneWidget);

      // Clear all asks Yes or No; No keeps everything.
      await tester.tap(find.byKey(const ValueKey('pantry-clear-all')));
      await settle(tester);
      expect(find.text('Clear everything on hand?'), findsOneWidget);
      await tester.tap(find.text('No'));
      await settle(tester);
      expect(find.text('On hand now (2)'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('pantry-clear-all')));
      await settle(tester);
      await tester.tap(find.text('Yes'));
      await settle(tester);
      expect(find.byKey(const ValueKey('pantry-on-hand')), findsNothing);
      expect(await tester.runAsync(() => PantryService.instance.getAll()), isEmpty);
      expect(await tester.runAsync(() => PantryService.instance.getBasics()), contains('flour'));

      await close(tester, db);
    });

    testWidgets('common ingredients: select all, add to Always have or On hand now', (tester) async {
      final db = await openDb(tester);
      await open(tester, db);

      await tester.tap(find.byKey(const ValueKey('pantry-common-button')));
      await settle(tester);
      expect(find.text('Common ingredients'), findsOneWidget);
      // Flour is already on hand, so its chip is ticked and not counted.
      await tester.tap(find.byKey(const ValueKey('pack-all-spices')));
      await settle(tester);
      final spices = ingredientPackItems(IngredientPackId.spices, 'en')
          .where((s) => s != 'salt' && s != 'black pepper') // default Always have basics
          .length;
      expect(find.text('Add $spices ingredients'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('pantry-common-add')));
      await settle(tester);
      final basics = await tester.runAsync(() => PantryService.instance.getBasics());
      expect(basics, containsAll(['cumin', 'paprika', 'nutmeg']));

      // The same sheet can add fresh things to On hand now instead.
      await tester.tap(find.byKey(const ValueKey('pantry-common-button')));
      await settle(tester);
      await tester.tap(find.text('On hand now').last);
      await settle(tester);
      await tester.scrollUntilVisible(
        find.text('eggs'),
        300,
        scrollable: find.descendant(
          of: find.byKey(const ValueKey('pantry-common-sheet')),
          matching: find.byType(Scrollable),
        ).first,
      );
      await tester.tap(find.text('eggs'));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('pantry-common-add')));
      await settle(tester);
      expect(await tester.runAsync(() => PantryService.instance.getAll()), contains('eggs'));

      await close(tester, db);
    });
  });
}
