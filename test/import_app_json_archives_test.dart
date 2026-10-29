// Importing the archives Mela and Paprika pack their recipes into, through
// the importers that unpack them.
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/services/recipe_file_importers/mela_importer.dart';
import 'package:recipespellbook/services/recipe_file_importers/paprika_importer.dart';

import 'json_import_helpers.dart';

void main() {
  test('a single Mela recipe file and an archive of them import alike', () async {
    final single = await MelaImporter.importSingle(bytesOf(melaRecipe()), 'Lemon Ricotta Pancakes.melarecipe');
    final archive = await MelaImporter.importMulti(
      zipOf({
        'Lemon Ricotta Pancakes.melarecipe': bytesOf(melaRecipe()),
        'Waffles.melarecipe': bytesOf(melaRecipe({'title': 'Waffles', 'ingredients': '2 cups flour'})),
      }),
      'Recipes.melarecipes',
    );

    expect(single.single.ingredients, hasLength(4));
    expect(single.single.instructions, hasLength(3));
    expect(archive.map((r) => r.title), ['Lemon Ricotta Pancakes', 'Waffles']);
    expect(archive.first.ingredients, single.single.ingredients);
    expect(archive.last.ingredients, ['2 cups flour']);
  });

  test('a Paprika export archive imports every recipe with its categories and link', () async {
    List<int> entry(Map<String, dynamic> recipe) => GZipEncoder().encode(utf8.encode(jsonEncode(recipe)))!;

    final recipes = await PaprikaImporter.import_(
      zipOf({
        'Pancakes.paprikarecipe': entry(paprikaRecipe({'photo_data': photo})),
        'Mushroom Risotto.paprikarecipe': entry(paprikaRecipe({
          'name': 'Mushroom Risotto',
          'categories': ['Dinner', 'Italian', 'Vegetarian'],
          'source': 'seriouseats.com',
          'source_url': 'https://www.seriouseats.com/mushroom-risotto',
        })),
      }),
      'My Recipes.paprikarecipes',
    );

    expect(recipes.map((r) => r.title), ['Pancakes', 'Mushroom Risotto']);
    expect(recipes.first.tags, ['Breakfast', 'Kids']);
    expect(recipes.first.imageData, photo);
    expect(recipes.last.tags, ['Dinner', 'Italian', 'Vegetarian']);
    expect(recipes.last.sourceUrl, 'https://www.seriouseats.com/mushroom-risotto');
  });
}
