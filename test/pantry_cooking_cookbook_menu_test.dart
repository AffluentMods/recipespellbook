// "What can I make?": the cookbook filter shows each cookbook's cover, as a
// small rounded thumbnail in its menu entry and in the chip once chosen, with
// the same rule as the rest of the app (the cover file if it is there, else
// the cookbook placeholder). "All cookbooks" gets a plain library mark.
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/pantry_service.dart';
import 'package:recipespellbook/ui/screens/pantry_cooking/pantry_cooking_screen.dart';
import 'package:recipespellbook/ui/widgets/cookbook_cover_thumb.dart';
import 'package:recipespellbook/ui/widgets/placeholder_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('the cookbook menu and chip show each cookbook\'s cover', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'pantry_items': jsonEncode(['eggs', 'butter', 'flour', 'milk']),
    });
    PantryService.resetForTesting();

    final (db, coverDir) = (await tester.runAsync(() async {
      // A cover photo on disk for one cookbook; the other has none.
      final dir = await Directory.systemTemp.createTemp('rsb_cover_');
      final cover = File('${dir.path}${Platform.pathSeparator}baking.png');
      await cover.writeAsBytes(base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
      ));
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'week', name: 'Weeknights'));
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
            id: 'baking',
            name: 'Baking',
            imagePath: drift.Value(cover.path),
          ));
      Future<void> recipe(String id, String cookbook, String title, List<String> names) async {
        await db.into(db.recipes).insert(RecipesCompanion.insert(id: id, cookbookId: cookbook, title: title));
        for (var i = 0; i < names.length; i++) {
          await db.into(db.ingredients).insert(
                IngredientsCompanion.insert(id: '${id}_$i', recipeId: id, sortOrder: i, name: names[i]),
              );
        }
      }

      await recipe('omelette', 'week', 'Omelette', ['eggs', 'butter']);
      await recipe('pancakes', 'baking', 'Pancakes', ['flour', 'eggs', 'milk']);
      return (db, dir);
    }))!;

    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const PantryCookingScreen()),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    bool ready() => find.text('Pancakes').evaluate().isNotEmpty && find.text('All cookbooks').evaluate().isNotEmpty;
    for (var i = 0; i < 80 && !ready(); i++) {
      await _settle(tester, rounds: 1);
    }
    expect(find.text('Omelette'), findsOneWidget);

    // Nothing chosen: the chip is text only.
    final chip = find.text('All cookbooks');
    await tester.ensureVisible(chip);
    expect(find.byType(CookbookCoverThumb), findsNothing);

    await tester.tap(chip);
    await tester.pumpAndSettle();

    Finder entry(String label) => find.ancestor(of: find.text(label), matching: find.byType(MenuItemButton));
    Finder inEntry(String label, Finder what) => find.descendant(of: entry(label), matching: what);

    // Each cookbook's cover at the start of its entry, about 28px.
    expect(inEntry('Weeknights  1', find.byType(CookbookCoverThumb)), findsOneWidget);
    expect(inEntry('Weeknights  1', find.byType(CookbookPlaceholderImage)), findsOneWidget,
        reason: 'no cover: the placeholder');
    expect(inEntry('Baking  1', find.byType(CookbookCoverThumb)), findsOneWidget);
    expect(inEntry('Baking  1', find.byType(Image)), findsOneWidget, reason: 'its cover file');
    expect(inEntry('Baking  1', find.byType(CookbookPlaceholderImage)), findsNothing);
    expect(tester.getSize(inEntry('Weeknights  1', find.byType(CookbookCoverThumb))), const Size(28, 28));
    expect(
      tester.getTopLeft(inEntry('Baking  1', find.byType(CookbookCoverThumb))).dx,
      lessThan(tester.getTopLeft(find.text('Baking  1')).dx),
      reason: 'at the start of the entry',
    );
    // "All cookbooks": a plain library mark, and the check on the chosen entry.
    final all = find.ancestor(of: find.text('All cookbooks').last, matching: find.byType(MenuItemButton));
    expect(find.descendant(of: all, matching: find.byIcon(Icons.local_library_outlined)), findsOneWidget);
    expect(find.descendant(of: all, matching: find.byIcon(Icons.check_rounded)), findsOneWidget);

    // Choosing a cookbook puts its cover in the chip.
    await tester.tap(find.text('Weeknights  1'));
    await tester.pumpAndSettle();
    expect(find.text('Pancakes'), findsNothing);
    final chipThumb = find.ancestor(of: find.text('Weeknights'), matching: find.byType(InkWell));
    expect(find.descendant(of: chipThumb, matching: find.byType(CookbookCoverThumb)), findsOneWidget);
    expect(tester.getSize(find.byType(CookbookCoverThumb)), const Size(22, 22));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await _settle(tester);
    await tester.runAsync(() async {
      await db.close().timeout(const Duration(seconds: 2), onTimeout: () {});
      try {
        await coverDir.delete(recursive: true);
      } catch (_) {}
    });
  });
}
