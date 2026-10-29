// Small recipes for the text import tests: one line of interest set into a
// recipe that is otherwise plain, so a test can say what became of that line.
import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';

/// Text typed or pasted into the import sheet.
ImportedRecipe typed(String text) => RecipeImportEngine.parseTextMulti(text).single;

/// Text recognised from a photo, a screenshot or a PDF page.
ImportedRecipe scanned(String text) => RecipeImportEngine.parseOcrText(text);

/// Text shared to the app or read from a .txt file.
ImportedRecipe shared(String text) => RecipeImportEngine.parseFromText(text);

/// A .md, .txt or other file picked in the import sheet.
ImportedRecipe file(String content, String name) => RecipeImportEngine.parseFromFile(content, name);

/// Text as the recogniser hands it over: one entry for each printed line and
/// a blank line after each paragraph.
String page(List<List<String>> paragraphs) => paragraphs.map((lines) => lines.join('\n')).join('\n\n');

/// The entries of a list that are not sub-headings.
List<String> items(List<String> list) => list.where((line) => !line.endsWith(':')).toList();

const stewIngredients = ['1 cup flour', '2 tbsp sugar'];
const stewSteps = [
  'Mix everything together in a large bowl.',
  'Spoon into bowls and garnish with parsley.',
];

/// A small recipe with [line] in the middle of its ingredient list.
String withIngredient(String line) => [
      'Sunday Stew',
      'Ingredients',
      '1 cup flour',
      line,
      '2 tbsp sugar',
      'Instructions',
      ...stewSteps,
    ].join('\n');

/// A small recipe with [line] in the middle of its method.
String withStep(String line) => [
      'Sunday Stew',
      'Ingredients',
      ...stewIngredients,
      'Instructions',
      stewSteps[0],
      line,
      stewSteps[1],
    ].join('\n');

/// A small recipe with [line] between the title and the ingredient list.
String withFact(String line) => [
      'Sunday Stew',
      line,
      'Ingredients',
      ...stewIngredients,
      'Instructions',
      ...stewSteps,
    ].join('\n');

/// A small recipe titled [title].
String withTitle(String title) => [
      title,
      'Serves 4',
      'Ingredients',
      ...stewIngredients,
      'Instructions',
      ...stewSteps,
    ].join('\n');

/// Every piece of text the recipe ended up with, for "this line is gone" checks.
List<String> everyLine(ImportedRecipe r) => [
      r.title,
      if (r.description != null) r.description!,
      ...r.ingredients,
      ...r.instructions,
      if (r.notes != null) r.notes!,
    ];

/// Servings, prep minutes and cook minutes, in that order.
List<Object?> facts(ImportedRecipe r) => [r.servings, r.prepTimeMinutes, r.cookTimeMinutes];
