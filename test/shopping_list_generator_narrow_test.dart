// The shopping list generator on a narrow phone: a recipe card opened to
// pick its ingredients shows "All", "None" and the scale buttons in one
// line where they fit, and on two where they do not, in every language.
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/ingredient_resolver_service.dart';
import 'package:recipespellbook/services/pantry_service.dart';
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/screens/shopping/shopping_list_generator_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

RecipeResolutionResult _oneRecipe() {
  const recipe = 'r1';
  ResolvedIngredient ingredient(int i, String name) => ResolvedIngredient(
        ingredient: Ingredient(id: 'i$i', recipeId: recipe, sortOrder: i, amount: '2', unit: 'cups', name: name),
        sourceRecipeId: recipe,
        sourceRecipeName: 'Weeknight Lasagne',
      );
  return RecipeResolutionResult(
    recipes: [
      ResolvedRecipeNode(
        recipeId: recipe,
        title: 'Weeknight Lasagne',
        directIngredients: [ingredient(0, 'flour'), ingredient(1, 'crushed tomatoes')],
        linkedIngredients: const [],
      ),
    ],
    conflicts: const [],
  );
}

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  for (final width in [320.0, 360.0, 420.0]) {
    for (final language in ['en', 'de', 'pl']) {
      testWidgets('an opened recipe card fits $width px in $language', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({});
        PantryService.resetForTesting();
        final db = (await tester.runAsync(() async {
          final db = AppDatabase.forTesting(NativeDatabase.memory());
          await db.select(db.shoppingLists).get();
          return db;
        }))!;

        await tester.pumpWidget(ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            locale: Locale(language),
            theme: AppTheme.lightTheme(AppColorTheme.values.first),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ShoppingListGeneratorScreen(resolutionResult: _oneRecipe()),
          ),
        ));
        await _settle(tester);

        await tester.tap(find.text('Weeknight Lasagne'));
        await _settle(tester);

        final l10n = lookupAppLocalizations(Locale(language));
        expect(find.text(l10n.all), findsOneWidget);
        expect(find.text(l10n.none), findsOneWidget);
        expect(find.text('2×'), findsOneWidget);
        // An overflow is reported as an exception of the test.
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox());
        await _settle(tester);
        await tester.runAsync(() => db.close().timeout(const Duration(seconds: 2), onTimeout: () {}));
      }, timeout: const Timeout(Duration(seconds: 120)));
    }
  }
}
