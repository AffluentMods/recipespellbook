/// Servings per planned meal: how many people a recipe feeds as written, and
/// how far a planned meal scales it.
///
/// A recipe's servings is free text ("4", "4-6", "Serves 4", "About 1 1/4
/// cups", "12 cookies"). Only text that plainly counts people is used to
/// scale; anything else falls back to the recipe as written, so a yield in
/// cups or cookies is never mistaken for a number of people.
library;

import '../database/database.dart';
import 'ingredient_utils.dart' show parseAmountRange;

/// The most people a meal can be planned for.
const maxPlannedServings = 99;

/// Words a servings line may wrap its number in and still count people:
/// "Serves 4", "4 servings", "for 4 people", "4 Portionen", "pour 4
/// personnes". Lower case, without trailing punctuation.
const _countWords = {
  // English
  'serves', 'serve', 'serving', 'servings', 'makes', 'yield', 'yields',
  'feeds', 'for', 'people', 'persons', 'person', 'portions', 'portion', 'pax',
  'about', 'approx', 'approximately', 'around', 'roughly', 'ca', 'circa',
  // German
  'portionen', 'personen', 'für', 'etwa', 'ergibt',
  // Spanish, Portuguese, Italian
  'porciones', 'porción', 'porcion', 'personas', 'persona', 'para', 'raciones',
  'ración', 'racion', 'porções', 'porção', 'pessoas', 'pessoa', 'rende',
  'porzioni', 'porzione', 'persone', 'per', 'dosi',
  // French
  'personnes', 'personne', 'pour', 'parts', 'environ',
  // Dutch
  'porties', 'portie', 'persoon', 'voor',
  // Polish
  'porcje', 'porcji', 'porcja', 'osoby', 'osób', 'osob', 'dla',
  // Russian
  'порции', 'порций', 'порция', 'персоны', 'персон', 'человек', 'чел', 'на',
};

/// Words that join the two ends of a range, which [parseAmountRange] reads.
const _rangeWords = {'to', 'bis', 'à', 'a', 'ou', 'tot'};

/// "4人分", "4 人前", "2인분", "4人份": the count with its East Asian unit.
final _cjkCount = RegExp(r'(?<=\d)\s*(?:人分|人前|人份|份|人|名|인분|명)');
final _letter = RegExp(r'\p{L}', unicode: true);
final _space = RegExp(r'\s+');

/// How many people [servings] says the recipe feeds, or null when it doesn't
/// plainly say ("About 1 1/4 cups", "12 cookies", "", null). A range reads
/// as its low end, the number the recipe page's servings stepper starts from.
double? recipeServingsCount(String? servings) {
  var text = (servings ?? '').toLowerCase().trim();
  if (text.isEmpty) return null;
  text = text.replaceAll(_cjkCount, ' ').replaceAll(RegExp(r'[~≈:()]'), ' ');
  final kept = <String>[];
  for (final raw in text.split(_space)) {
    final word = raw.replaceAll(RegExp(r'[.,;]+$'), '');
    if (word.isEmpty || _countWords.contains(word)) continue;
    if (_letter.hasMatch(word) && !_rangeWords.contains(word)) return null;
    kept.add(word);
  }
  if (kept.isEmpty) return null;
  final bounds = parseAmountRange(kept.join(' '));
  if (bounds == null) return null;
  final low = bounds.$1;
  return low > 0 && low.isFinite ? low : null;
}

/// [recipeServingsCount] as the whole number of people a stepper starts at.
int? recipeServingsDefault(String? servings) {
  final count = recipeServingsCount(servings);
  if (count == null) return null;
  return count.round().clamp(1, maxPlannedServings);
}

/// How much a meal planned for [planned] people scales a recipe that serves
/// [recipeServings]. 1.0 (the recipe as written) when nothing is planned or
/// the recipe doesn't plainly count people.
double plannedServingsScale(int? planned, String? recipeServings) {
  if (planned == null || planned <= 0) return 1.0;
  final count = recipeServingsCount(recipeServings);
  if (count == null) return 1.0;
  return planned / count;
}

/// The value to store for a meal planned for [chosen] people: null when it is
/// what the recipe already serves, so the meal keeps following the recipe.
int? normalizePlannedServings(int? chosen, String? recipeServings) {
  if (chosen == null) return null;
  final count = recipeServingsCount(recipeServings);
  if (count != null && (count - chosen).abs() < 0.001) return null;
  return chosen.clamp(1, maxPlannedServings);
}

/// The planned number of people to show on a planner entry: only when the
/// meal is planned for a number other than the recipe's own.
int? plannedServingsToShow(MealPlan meal, Recipe? recipe) {
  final planned = meal.servings;
  if (planned == null) return null;
  final count = recipeServingsCount(recipe?.servings);
  if (count != null && (count - planned).abs() < 0.001) return null;
  return planned;
}

/// Where the planner opens a meal's recipe: scaled to the planned number of
/// people when one is set.
String plannedRecipeLocation(String recipeId, MealPlan meal) {
  final planned = meal.servings;
  return planned == null ? '/recipe/$recipeId' : '/recipe/$recipeId?servings=$planned';
}

/// One recipe going into a shopping list from the planner, at the size it
/// was planned.
class PlannedRecipe {
  final String recipeId;

  /// Planned / recipe servings, summed over every time it is planned.
  final double scale;

  /// The people all those meals feed together, when every one is known.
  final int? servings;

  const PlannedRecipe({required this.recipeId, this.scale = 1.0, this.servings});

  @override
  String toString() => 'PlannedRecipe($recipeId, ×$scale, $servings)';
}

/// Folds planned meals into one entry per recipe for the shopping list. Each
/// meal adds its own scale, so a recipe planned twice in a week is bought for
/// twice, and one planned for 6 that serves 4 counts as 1.5. Meals without a
/// recipe are skipped. Order follows the first time each recipe appears.
List<PlannedRecipe> plannedRecipesFor(Iterable<MealPlanWithRecipe> meals) {
  final scales = <String, double>{};
  final people = <String, int?>{};
  for (final m in meals) {
    final recipe = m.recipe;
    if (recipe == null) continue;
    final id = recipe.id;
    final planned = m.mealPlan.servings;
    scales[id] = (scales[id] ?? 0) + plannedServingsScale(planned, recipe.servings);
    final feeds = planned ?? recipeServingsDefault(recipe.servings);
    final before = people.containsKey(id) ? people[id] : 0;
    people[id] = before == null || feeds == null ? null : before + feeds;
  }
  return [
    for (final id in scales.keys)
      PlannedRecipe(recipeId: id, scale: scales[id]!, servings: people[id]),
  ];
}
