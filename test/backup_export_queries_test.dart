// A backup reads each table once, not a handful of queries per recipe: a
// library of a few thousand recipes took that many round trips before.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/export_import_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Selects extends QueryInterceptor {
  int count = 0;

  @override
  Future<List<Map<String, Object?>>> runSelect(QueryExecutor executor, String statement, List<Object?> args) {
    count++;
    return super.runSelect(executor, statement, args);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('the queries of a backup do not grow with the recipes', () async {
    SharedPreferences.setMockInitialValues({});
    final selects = _Selects();
    final db = AppDatabase.forTesting(NativeDatabase.memory().interceptWith(selects));
    addTearDown(db.close);
    await db.batch((batch) {
      for (var i = 0; i < 200; i++) {
        batch.insert(db.recipes, RecipesCompanion.insert(id: 'r$i', cookbookId: 'starter', title: 'Recipe $i'));
        batch.insert(db.ingredients, IngredientsCompanion.insert(id: 'r${i}_i', recipeId: 'r$i', sortOrder: 0, name: 'Salt'));
        batch.insert(db.steps, StepsCompanion.insert(id: 'r${i}_s', recipeId: 'r$i', sortOrder: 0, instruction: 'Stir.'));
        batch.insert(db.recipeTags, RecipeTagsCompanion.insert(recipeId: 'r$i', tagId: 'tag_quick'));
      }
    });
    selects.count = 0;

    final data = await ExportImportService(db).exportSelective(const ExportOptions.all(), embedImages: false);

    final recipes = (data['cookbooks'] as List).cast<Map>().singleWhere((c) => c['id'] == 'starter')['recipes'] as List;
    expect(recipes, hasLength(200));
    final r7 = recipes.cast<Map>().singleWhere((r) => r['id'] == 'r7');
    expect((r7['ingredients'] as List).single['name'], 'Salt');
    expect((r7['steps'] as List).single['instruction'], 'Stir.');
    expect(r7['tagIds'], ['tag_quick']);
    expect(selects.count, lessThan(30));
  });
}
