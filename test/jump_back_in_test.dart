// "Jump back in" on the home screen (phone and desktop) shows today's planned
// recipes, pinned ones and recently viewed ones, each part switched by
// Settings > Quick Access.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/providers/quick_access_provider.dart';
import 'package:recipespellbook/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;

  Future<void> addRecipe(String id, {bool pinned = false, DateTime? viewed}) =>
      db.into(db.recipes).insert(RecipesCompanion.insert(
            id: id,
            cookbookId: 'book',
            title: 'Recipe $id',
            isPinned: Value(pinned),
            lastViewedAt: Value(viewed),
          ));

  Future<List<(String, QuickAccessSource)>> jumpBackIn(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    container.read(settingsProvider);
    await pumpEventQueue(); // settings load from SharedPreferences
    final sub = container.listen(jumpBackInProvider('book'), (_, _) {});
    addTearDown(sub.close);
    final items = await container.read(jumpBackInProvider('book').future);
    return [for (final i in items) (i.recipe.id, i.source)];
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'book', name: 'Book'));
    final now = DateTime.now();
    await addRecipe('planned');
    await addRecipe('pinned', pinned: true);
    await addRecipe('seen1', viewed: now.subtract(const Duration(minutes: 1)));
    await addRecipe('seen2', viewed: now.subtract(const Duration(minutes: 2)));
    await db.into(db.mealPlans).insert(MealPlansCompanion.insert(
          id: 'm1',
          date: DateTime(now.year, now.month, now.day),
          recipeId: const Value('planned'),
        ));
  });

  tearDown(() => db.close());

  test('shows today\'s plan, then pinned, then recently viewed', () async {
    expect(await jumpBackIn({}), [
      ('planned', QuickAccessSource.mealPlan),
      ('pinned', QuickAccessSource.pinned),
      ('seen1', QuickAccessSource.recent),
      ('seen2', QuickAccessSource.recent),
    ]);
  });

  test('"Show meal plan" off leaves today\'s plan out', () async {
    final items = await jumpBackIn({'quick_access_show_meal_plan': false});
    expect(items.map((i) => i.$1), ['pinned', 'seen1', 'seen2']);
  });

  test('pinned and history follow their switches and the history count', () async {
    expect(
      (await jumpBackIn({'quick_access_show_pinned': false, 'quick_access_history_count': 1}))
          .map((i) => i.$1),
      ['planned', 'seen1'],
    );
    expect(
      (await jumpBackIn({'quick_access_show_history': false})).map((i) => i.$1),
      ['planned', 'pinned'],
    );
  });
}
