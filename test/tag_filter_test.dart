// The tag filter of the recipe list: the recipes carrying every chosen tag,
// from one query that follows tags being added and taken off.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    for (final (id, tags) in const [
      ('brownies', ['tag_quick', 'tag_kid']),
      ('soup', ['tag_quick']),
      ('stew', ['tag_kid', 'tag_comfort']),
      ('salad', <String>[]),
    ]) {
      await db.into(db.recipes).insert(RecipesCompanion.insert(id: id, cookbookId: 'starter', title: id));
      for (final tag in tags) {
        await db.into(db.recipeTags).insert(RecipeTagsCompanion.insert(recipeId: id, tagId: tag));
      }
    }
  });

  tearDown(() => db.close());

  test('a recipe has to carry every chosen tag', () async {
    final dao = db.tagsDao;
    expect(await dao.watchRecipeIdsWithAllTags({'tag_quick'}).first, {'brownies', 'soup'});
    expect(await dao.watchRecipeIdsWithAllTags({'tag_quick', 'tag_kid'}).first, {'brownies'});
    expect(await dao.watchRecipeIdsWithAllTags({'tag_quick', 'tag_kid', 'tag_comfort'}).first, isEmpty);
  });

  test('a tag added to a recipe shows in the filter without asking again', () async {
    final dao = db.tagsDao;
    final seen = <Set<String>>[];
    final sub = dao.watchRecipeIdsWithAllTags({'tag_quick', 'tag_kid'}).listen(seen.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();
    expect(seen.last, {'brownies'});

    await dao.addTagToRecipe('soup', 'tag_kid');
    await pumpEventQueue();
    expect(seen.last, {'brownies', 'soup'});

    await dao.removeTagFromRecipe('brownies', 'tag_quick');
    await pumpEventQueue();
    expect(seen.last, {'soup'});
  });
}
