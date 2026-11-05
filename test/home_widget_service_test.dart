// When the app rewrites the home screen widgets' snapshot: on start, after a
// burst of changes (once), never for unchanged data, in the app's language.
import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/home_widget_service.dart';
import 'package:recipespellbook/services/home_widget_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late List<String> published;
  late HomeWidgetService service;
  var language = 'en';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.select(db.cookbooks).get();
    published = [];
    language = 'en';
    service = HomeWidgetService(
      publish: (json) async => published.add(json),
      clock: () => DateTime(2026, 11, 5, 9),
      debounce: const Duration(milliseconds: 150),
    );
  });

  tearDown(() async {
    await service.stop();
    await db.close();
  });

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 400));

  Map<String, dynamic> last() => jsonDecode(published.last) as Map<String, dynamic>;

  Future<void> addItem(String id, String name) => db.into(db.shoppingListItems).insert(
      ShoppingListItemsCompanion.insert(id: id, listId: 'list_default', name: name));

  test('writes a snapshot when it starts', () async {
    await service.start(db, languageCode: () => language);
    expect(published, hasLength(1));
    expect(last()['today'], '2026-11-05');
  });

  test('does not rewrite the same data', () async {
    await service.start(db, languageCode: () => language);
    await service.refresh();
    await service.refresh();
    expect(published, hasLength(1));
  });

  test('a burst of shopping changes is written once, after the debounce', () async {
    await service.start(db, languageCode: () => language);
    await addItem('a', 'Milk');
    await addItem('b', 'Bread');
    await addItem('c', 'Eggs');
    expect(published, hasLength(1), reason: 'nothing before the debounce has passed');
    await settle();
    expect(published, hasLength(2));
    expect((last()['shopping'] as Map)['unchecked'], 3);
  });

  test('a planned meal reaches the widgets', () async {
    await service.start(db, languageCode: () => language);
    await db.into(db.mealPlans).insert(MealPlansCompanion.insert(
          id: 'm1',
          date: DateTime(2026, 11, 5),
          mealType: const Value('Breakfast'),
        ));
    await settle();
    final today = ((last()['meals'] as Map)['days'] as Map)['2026-11-05'] as Map;
    expect((today['items'] as List).single['typeLabel'], 'Breakfast');
  });

  test("the widgets' words follow the app's language", () async {
    language = 'de';
    await service.start(db, languageCode: () => language);
    expect((last()['labels'] as Map)['mealsTitle'], 'Mahlzeiten heute');
    expect((last()['labels'] as Map)['shoppingEmpty'], 'Deine Liste ist leer');

    language = 'ja';
    await service.refresh();
    expect((last()['labels'] as Map)['mealsTitle'], '今日の食事');
  });

  test('a failed write is tried again on the next refresh', () async {
    var fail = true;
    final flaky = HomeWidgetService(
      publish: (json) async {
        if (fail) throw StateError('no widget storage');
        published.add(json);
      },
      clock: () => DateTime(2026, 11, 5, 9),
    );
    await flaky.start(db, languageCode: () => language);
    expect(published, isEmpty);
    fail = false;
    await flaky.refresh();
    expect(published, hasLength(1));
    await flaky.stop();
  });

  test('after stop, changes are no longer written', () async {
    await service.start(db, languageCode: () => language);
    await service.stop();
    await addItem('a', 'Milk');
    await settle();
    await service.refresh();
    expect(published, hasLength(1));
  });

  test('switching shopping lists is picked up from the Shopping screen setting', () async {
    await db.into(db.shoppingLists).insert(ShoppingListsCompanion.insert(id: 'weekly', name: 'Weekly shop'));
    await service.start(db, languageCode: () => language);
    expect((last()['shopping'] as Map)['listId'], 'list_default');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(shoppingLastListPrefKey, 'weekly');
    service.scheduleRefresh();
    await settle();
    expect((last()['shopping'] as Map)['name'], 'Weekly shop');
  });

  group('language', () {
    test("'system' follows the phone, a choice wins, unknown falls back to English", () {
      expect(HomeWidgetService.resolveLocale('system', const Locale('fr', 'CA')), const Locale('fr'));
      expect(HomeWidgetService.resolveLocale('ko', const Locale('fr')), const Locale('ko'));
      expect(HomeWidgetService.resolveLocale('system', const Locale('sv')), const Locale('en'));
      expect(HomeWidgetService.resolveLocale('xx', const Locale('de')), const Locale('en'));
    });

    test('meal types are translated, custom ones stay as typed', () {
      final de = lookupAppLocalizations(const Locale('de'));
      expect(HomeWidgetService.mealTypeLabel(de, 'Dinner'), de.mealTypeDinner);
      expect(HomeWidgetService.mealTypeLabel(de, 'Brunch'), 'Brunch');
    });

    test('every language has its own widget words', () {
      final english = lookupAppLocalizations(const Locale('en'));
      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = lookupAppLocalizations(locale);
        for (final text in [
          l10n.widgetTodaysMealsTitle,
          l10n.widgetTodaysMealsEmpty,
          l10n.widgetTodaysMealsDescription,
          l10n.widgetShoppingListTitle,
          l10n.widgetShoppingListEmpty,
          l10n.widgetShoppingListDescription,
        ]) {
          expect(text.trim(), isNotEmpty, reason: '$locale');
          expect(text, isNot(contains(String.fromCharCode(0x2014))), reason: 'no em dashes ($locale)');
        }
        if (locale.languageCode != 'en') {
          expect(l10n.widgetTodaysMealsEmpty, isNot(english.widgetTodaysMealsEmpty),
              reason: '$locale is translated');
        }
      }
    });
  });
}
