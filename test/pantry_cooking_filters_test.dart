// "What can I make?": a chosen cookbook stays on its chip while chosen, even
// when nothing in it uses the pantry any more, so it can be cleared. The chip
// used to vanish with the last match and leave "No recipes match" with
// nothing to tap. And each recipe says which pantry items it uses.
import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/providers/pantry_cooking_provider.dart';
import 'package:recipespellbook/services/pantry_service.dart';
import 'package:recipespellbook/ui/screens/pantry_cooking/pantry_cooking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('a chosen cookbook keeps its chip after its last match is gone', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'pantry_items': jsonEncode(['eggs', 'butter', 'flour', 'milk', 'lemons']),
    });
    PantryService.resetForTesting();

    final db = (await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'week', name: 'Weeknights'));
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'baking', name: 'Baking'));
      Future<void> recipe(String id, String cookbook, String title, List<String> names) async {
        await db.into(db.recipes).insert(RecipesCompanion.insert(id: id, cookbookId: cookbook, title: title));
        for (var i = 0; i < names.length; i++) {
          await db.into(db.ingredients).insert(
                IngredientsCompanion.insert(id: '${id}_$i', recipeId: id, sortOrder: i, name: names[i]),
              );
        }
      }

      await recipe('omelette', 'week', 'Omelette', ['eggs', 'butter']);
      await recipe('pancakes', 'baking', 'Pancakes', ['flour', 'milk', '1 tbsp lemon juice']);
      return db;
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

    // Which pantry items each recipe uses.
    expect(find.text('From your pantry: flour, milk, lemons'), findsOneWidget);
    expect(find.text('From your pantry: eggs, butter'), findsOneWidget);

    // Only Baking.
    await tester.ensureVisible(find.text('All cookbooks'));
    await tester.tap(find.text('All cookbooks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Baking  1'));
    await tester.pumpAndSettle();
    expect(find.text('Pancakes'), findsOneWidget);
    expect(find.text('Omelette'), findsNothing);

    // The flour, milk and lemons are used up: nothing in Baking uses the
    // pantry now, but the chip still says Baking.
    final container = ProviderScope.containerOf(tester.element(find.byType(PantryCookingScreen)));
    // In the test's own zone: the pantry's stored futures belong to it.
    unawaited(container.read(pantryProvider.notifier).removeAll(['flour', 'milk', 'lemons']));
    for (var i = 0; i < 40 && find.text('Pancakes').evaluate().isNotEmpty; i++) {
      await _settle(tester, rounds: 1);
    }
    expect(find.text('Pancakes'), findsNothing);
    expect(find.text('Baking'), findsOneWidget, reason: 'the chosen cookbook is still on its chip');

    // And it clears from there.
    await tester.tap(find.text('Baking'));
    await tester.pumpAndSettle();
    expect(find.text('Baking  0'), findsOneWidget);
    await tester.tap(find.text('All cookbooks').last);
    await tester.pumpAndSettle();
    expect(find.text('Omelette'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await _settle(tester);
    await tester.runAsync(() async {
      await db.close().timeout(const Duration(seconds: 2), onTimeout: () {});
    });
  }, timeout: const Timeout(Duration(seconds: 120)));
}
