// Opening Search starts from an empty box. The query lives in a provider
// that outlives the screen, and reopening Search showed the last results
// under an empty search field.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/screens/search/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  for (final initial in [null, 'stew']) {
    testWidgets('opening Search ${initial == null ? 'clears the last query' : 'takes the query it is given'}',
        (tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final db = (await tester.runAsync(() async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'c', name: 'Cookbook'));
        await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'r', cookbookId: 'c', title: 'Tomato Soup'));
        return db;
      }))!;
      final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
      addTearDown(container.dispose);
      // The last visit searched for soup.
      container.read(searchQueryProvider.notifier).state = 'soup';

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme(AppColorTheme.values.first),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SearchScreen(initialQuery: initial),
        ),
      ));
      // Not even for the first frame.
      expect(find.text('Tomato Soup'), findsNothing);
      await _settle(tester);

      expect(container.read(searchQueryProvider), initial ?? '');
      expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, initial ?? '');
      expect(find.text('Tomato Soup'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await _settle(tester);
      await tester.runAsync(() => db.close().timeout(const Duration(seconds: 2), onTimeout: () {}));
    }, timeout: const Timeout(Duration(seconds: 120)));
  }
}
