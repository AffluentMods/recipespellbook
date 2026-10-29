// Shared by the JSON import tests: what the sample files are made of and how
// they are read.
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';

/// A small photo the way the apps embed it: JPEG bytes in base64.
final String photo = base64Encode(Uint8List.fromList([
  0xFF, 0xD8, 0xFF, 0xE0,
  for (var i = 4; i < 48; i++) (i * 37 + 11) & 0xFF,
]));

Uint8List bytesOf(Object json) => Uint8List.fromList(utf8.encode(jsonEncode(json)));

Uint8List zipOf(Map<String, List<int>> entries) {
  final archive = Archive();
  entries.forEach((name, data) => archive.addFile(ArchiveFile(name, data.length, data)));
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

/// Every recipe in a JSON file, read the way the file import reads it.
List<ImportedRecipe> recipesIn(Object json, [String filename = 'recipes.json']) =>
    RecipeImportEngine.parseFromFileBulk(jsonEncode(json), filename);

ImportedRecipe recipeIn(Object json, [String filename = 'recipe.json']) => recipesIn(json, filename).single;

/// A recipe in the plain shape tools and people write, with [fields]
/// replacing or adding to it.
Map<String, dynamic> plainRecipe([Map<String, dynamic> fields = const {}]) => {
      'title': 'Banana Bread',
      'ingredients': ['3 ripe bananas', '1 1/2 cups flour'],
      'instructions': ['Mash the bananas.', 'Bake at 350F for 60 minutes.'],
      ...fields,
    };

/// A recipe the way Mela writes it, with [fields] replacing or adding to it.
Map<String, dynamic> melaRecipe([Map<String, dynamic> fields = const {}]) => {
      'id': 'example.com/lemon-ricotta-pancakes',
      'title': 'Lemon Ricotta Pancakes',
      'text': 'Fluffy pancakes with a bright lemon flavor.',
      'images': [photo],
      'categories': ['Breakfast', 'Brunch'],
      'yield': '4 servings',
      'prepTime': '15 min',
      'cookTime': '20 min',
      'totalTime': '35 min',
      'ingredients': '1 1/2 cups all-purpose flour\n2 tbsp sugar\n1 cup ricotta\n2 large eggs',
      'instructions': 'Whisk the flour and sugar.\nFold in ricotta and eggs.\nCook on a buttered griddle.',
      'notes': 'Batter keeps one day.',
      'nutrition': 'Calories: 410',
      'link': 'https://example.com/lemon-ricotta-pancakes',
      'favorite': true,
      'wantToCook': false,
      'date': 687214800.0,
      ...fields,
    };

/// One recipe of a Paprika export, with [fields] replacing or adding to it.
Map<String, dynamic> paprikaRecipe([Map<String, dynamic> fields = const {}]) => {
      'uid': 'B5C2E0F1-0000-4000-8000-000000000001',
      'name': 'Pancakes',
      'directions': 'Whisk the dry ingredients.\n\nAdd milk and eggs, then cook on a hot griddle.',
      'servings': '4 servings',
      'rating': 5,
      'difficulty': '',
      'ingredients': '1 1/2 cups flour\n2 eggs\n1 cup milk',
      'notes': '',
      'created': '2021-03-14 09:26:53',
      'image_url': null,
      'on_favorites': 0,
      'cook_time': '10 mins',
      'prep_time': '5 mins',
      'total_time': '',
      'source': 'Example Kitchen',
      'source_url': 'https://example.com/pancakes',
      'photo_hash': null,
      'photo': null,
      'nutritional_info': '',
      'scale': null,
      'categories': ['Breakfast', 'Kids'],
      'hash': 'DEADBEEF',
      'description': '',
      'photo_data': null,
      'photos': <Object>[],
      ...fields,
    };
