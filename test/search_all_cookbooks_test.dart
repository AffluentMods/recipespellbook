// The search screen looks through every cookbook, and shows a recipe once.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/providers/cookbook_provider.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/ui/screens/search/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late ProviderContainer container;

  Future<void> addCookbook(String id) =>
      db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: id, name: 'Cookbook $id'));

  Future<void> addRecipe(
    String id,
    String cookbookId,
    String title, {
    List<String> ingredients = const ['salt'],
    String? description,
    bool favorite = false,
    DateTime? deletedAt,
  }) async {
    await db.into(db.recipes).insert(RecipesCompanion.insert(
          id: id,
          cookbookId: cookbookId,
          title: title,
          description: Value(description),
          isFavorite: Value(favorite),
          deletedAt: Value(deletedAt),
        ));
    for (var i = 0; i < ingredients.length; i++) {
      await db.into(db.ingredients).insert(IngredientsCompanion.insert(
            id: '${id}_ing_$i',
            recipeId: id,
            sortOrder: i,
            name: ingredients[i],
          ));
    }
  }

  Future<List<String>> search(String query) async {
    container.read(searchQueryProvider.notifier).state = query;
    final results = await container.read(searchResultsProvider.future);
    return [for (final r in results) r.id];
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    await addCookbook('soups');
    await addCookbook('sauces');
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('finds recipes in every cookbook, whichever one is open', () async {
    await addRecipe('a', 'soups', 'Tomato Soup');
    await addRecipe('b', 'sauces', 'Tomato Sauce');
    container.read(selectedCookbookIdProvider.notifier).state = 'soups';

    expect(await search('tomato'), unorderedEquals(['a', 'b']));
  });

  test('finds them by ingredient and by description too', () async {
    await addRecipe('a', 'soups', 'Minestrone', ingredients: ['cannellini beans']);
    await addRecipe('b', 'sauces', 'Pesto', description: 'Good with cannellini.');

    expect(await search('cannellini'), ['b', 'a']);
  });

  test('ignores accents, across cookbooks', () async {
    await addRecipe('a', 'sauces', 'Sauce Béarnaise');

    expect(await search('bearnaise'), ['a']);
  });

  test('leaves out what is in the trash', () async {
    await addRecipe('a', 'soups', 'Tomato Soup', deletedAt: DateTime(2026, 1, 1));

    expect(await search('tomato'), isEmpty);
  });

  test('shows a recipe once when it is in several cookbooks', () async {
    await addRecipe('a', 'soups', 'Chicken Broth', ingredients: ['chicken', 'water']);
    await addRecipe('b', 'sauces', 'Chicken Broth', ingredients: ['chicken', 'water']);

    expect(await search('broth'), hasLength(1));
  });

  test('of the copies, shows the one in the open cookbook', () async {
    await addRecipe('a', 'soups', 'Chicken Broth', ingredients: ['chicken']);
    await addRecipe('b', 'sauces', 'Chicken Broth', ingredients: ['chicken']);

    container.read(selectedCookbookIdProvider.notifier).state = 'sauces';
    expect(await search('broth'), ['b']);
  });

  test('of the copies, shows a favorite before the one in the open cookbook', () async {
    await addRecipe('a', 'soups', 'Chicken Broth', ingredients: ['chicken'], favorite: true);
    await addRecipe('b', 'sauces', 'Chicken Broth', ingredients: ['chicken']);

    container.read(selectedCookbookIdProvider.notifier).state = 'sauces';
    expect(await search('broth'), ['a']);
  });

  test('keeps recipes that share a title but are not the same', () async {
    await addRecipe('a', 'soups', 'Chili', ingredients: ['beef', 'beans']);
    await addRecipe('b', 'sauces', 'Chili', ingredients: ['lentils', 'beans']);

    expect(await search('chili'), unorderedEquals(['a', 'b']));
  });

  test('keeps a copy someone changed', () async {
    await addRecipe('a', 'soups', 'Chicken Broth', ingredients: ['chicken', 'water']);
    await addRecipe('b', 'sauces', 'Chicken Broth', ingredients: ['chicken', 'water', 'ginger']);

    expect(await search('broth'), unorderedEquals(['a', 'b']));
  });

  test('an empty search finds nothing', () async {
    await addRecipe('a', 'soups', 'Tomato Soup');

    expect(await search('   '), isEmpty);
  });
}
