/// "What can I make?": the user's recipes, every cookbook, ranked by how much
/// of each the pantry already covers.
///
/// The library is read in two queries (recipes, then every ingredient line)
/// and each line is reduced to the food it names once per data change, in a
/// background isolate for big libraries. Ranking against the pantry is then a
/// cheap pass over the reduced lines, re-run only when the pantry changes.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/course_category_data.dart';
import '../database/database.dart';
import '../utils/ingredient_utils.dart';
import '../utils/recipe_similarity.dart';
import 'pantry_matcher.dart';

/// One ingredient line of a recipe, reduced for matching.
class LibraryIngredient {
  final String name;
  final String? amount;
  final String? unit;
  final IngredientKey key;

  /// Listed under a section the dish can do without ("Garnish", "To
  /// serve", "Optional"; see [isOptionalSectionTitle]).
  final bool inOptionalSection;

  const LibraryIngredient({
    required this.name,
    this.amount,
    this.unit,
    required this.key,
    this.inOptionalSection = false,
  });

  /// Not needed to make the dish: marked optional or a garnish itself, or
  /// under an optional section.
  bool get optional => inOptionalSection || key.optional;
}

/// A recipe as "What can I make?" sees it: copies of the same recipe in
/// several cookbooks folded into one.
class LibraryRecipe {
  /// The copy that is opened and shown.
  final Recipe recipe;

  /// Every copy's id, [recipe] first.
  final List<String> copyIds;

  /// Every cookbook a copy is in.
  final Set<String> cookbookIds;

  /// A favourite in any cookbook.
  final bool isFavorite;

  /// The latest time any copy was opened.
  final DateTime? lastViewedAt;

  final List<LibraryIngredient> ingredients;

  const LibraryRecipe({
    required this.recipe,
    required this.copyIds,
    required this.cookbookIds,
    required this.isFavorite,
    required this.lastViewedAt,
    required this.ingredients,
  });

  String get id => recipe.id;
  String get title => recipe.title;

  /// Prep plus cook time, or null when neither is known.
  int? get totalMinutes {
    final total = (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);
    return total > 0 ? total : null;
  }

  /// The built-in course id ("main") or the custom course as written.
  String? get courseKey => canonicalCourseKey(recipe.courseId);
}

/// The whole library, reduced once per data change.
class RecipeLibrary {
  final List<LibraryRecipe> recipes;
  final Map<String, LibraryRecipe> _byCopyId;

  RecipeLibrary(this.recipes)
      : _byCopyId = {
          for (final r in recipes)
            for (final id in r.copyIds) id: r,
        };

  static final empty = RecipeLibrary(const []);

  /// The entry any copy of a recipe belongs to.
  LibraryRecipe? byId(String recipeId) => _byCopyId[recipeId];
}

/// One ingredient row as read from the database.
class IngredientRow {
  final String recipeId;
  final String name;
  final String? amount;
  final String? unit;
  final String? notes;

  const IngredientRow({
    required this.recipeId,
    required this.name,
    this.amount,
    this.unit,
    this.notes,
  });
}

/// Ingredient rows that are section titles ("For the sauce"), not food.
const ingredientHeaderMarker = '__header__';

/// The built-in course id for [courseId] (stored as an id or a name), or the
/// custom course lower-cased; null when there is none.
String? canonicalCourseKey(String? courseId) {
  final raw = courseId?.trim().toLowerCase();
  if (raw == null || raw.isEmpty) return null;
  for (final course in CourseData.courses) {
    if (course.id == raw || course.name.toLowerCase() == raw) return course.id;
  }
  return raw;
}

/// Reduce [recipes] and their ingredient [rows] (in recipe and sort order)
/// to a [RecipeLibrary]. Copies with the same title and ingredient names
/// (see [RecipeSimilarity.copyKey]) become one entry, shown as the favourite
/// copy, else the one opened last.
///
/// [keys] keeps the reduced form of each distinct line ("salt", "2 eggs")
/// between calls; without it each call reduces every line again.
RecipeLibrary buildRecipeLibrary(List<Recipe> recipes, List<IngredientRow> rows, {Map<String, IngredientKey>? keys}) {
  final rowsByRecipe = <String, List<IngredientRow>>{};
  for (final row in rows) {
    (rowsByRecipe[row.recipeId] ??= []).add(row);
  }

  // The same line turns up in many recipes ("salt", "2 eggs"): reduce each
  // distinct line once.
  final keyCache = keys ?? <String, IngredientKey>{};
  IngredientKey keyFor(IngredientRow row) {
    final notes = row.notes ?? '';
    return keyCache[_lineKey(row)] ??= ingredientKeyFor(row.name, notes: notes.isEmpty ? null : notes);
  }

  final groups = <String, List<Recipe>>{};
  for (final recipe in recipes) {
    if (recipe.deletedAt != null) continue;
    final names = [for (final row in rowsByRecipe[recipe.id] ?? const <IngredientRow>[]) row.name];
    (groups[RecipeSimilarity.copyKey(recipe.title, names)] ??= []).add(recipe);
  }

  final entries = <LibraryRecipe>[];
  for (final copies in groups.values) {
    copies.sort(_preferredCopyFirst);
    final shown = copies.first;
    DateTime? viewed;
    for (final c in copies) {
      final v = c.lastViewedAt;
      if (v != null && (viewed == null || v.isAfter(viewed))) viewed = v;
    }
    entries.add(LibraryRecipe(
      recipe: shown,
      copyIds: [for (final c in copies) c.id],
      cookbookIds: {for (final c in copies) c.cookbookId},
      isFavorite: copies.any((c) => c.isFavorite),
      lastViewedAt: viewed,
      ingredients: _libraryIngredients(rowsByRecipe[shown.id] ?? const <IngredientRow>[], keyFor),
    ));
  }
  return RecipeLibrary(entries);
}

/// A recipe's ingredient [rows] as lines for matching. Section titles are
/// not food, but they say whether the lines under them are needed: those
/// under "Garnish" or "To serve" are not.
List<LibraryIngredient> _libraryIngredients(List<IngredientRow> rows, IngredientKey Function(IngredientRow) keyFor) {
  final out = <LibraryIngredient>[];
  var optionalSection = false;
  for (final row in rows) {
    if (row.notes == ingredientHeaderMarker) {
      optionalSection = isOptionalSectionTitle(row.name);
      continue;
    }
    if (row.name.trim().isEmpty) continue;
    out.add(LibraryIngredient(
      name: row.name,
      amount: row.amount,
      unit: row.unit,
      key: keyFor(row),
      inOptionalSection: optionalSection,
    ));
  }
  return out;
}

int _preferredCopyFirst(Recipe a, Recipe b) {
  if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
  final av = a.lastViewedAt, bv = b.lastViewedAt;
  if (av != null && bv != null && av != bv) return bv.compareTo(av);
  if ((av == null) != (bv == null)) return av != null ? -1 : 1;
  return a.id.compareTo(b.id);
}

String _lineKey(IngredientRow row) => '${row.name}\u0000${row.notes ?? ''}';

/// Reduces a big library off the UI thread and hands back the lines it
/// reduced, so the next load can reuse them.
(RecipeLibrary, Map<String, IngredientKey>) _buildLibraryJob((List<Recipe>, List<IngredientRow>) input) {
  final keys = <String, IngredientKey>{};
  return (buildRecipeLibrary(input.$1, input.$2, keys: keys), keys);
}

// Opening a recipe stamps it as viewed, which changes the recipes table and
// reloads the library. Ingredient lines change far less often, so they and
// their reduced form are kept between loads: a reload after a recipes-only
// change is one query and a regroup, not every line read and reduced again.
AppDatabase? _rowsDb;
List<IngredientRow>? _rows;
final Map<String, IngredientKey> _keyCache = {};
const _keyCacheLimit = 200000;

/// The ingredients table changed: read the lines again on the next load.
void markIngredientRowsChanged() => _rows = null;

@visibleForTesting
void resetRecipeLibraryCacheForTesting() {
  _rows = null;
  _rowsDb = null;
  _keyCache.clear();
}

/// Read every recipe (one query) and, when they changed, every ingredient
/// line, and reduce them. Big libraries with new lines are reduced off the UI
/// thread.
Future<RecipeLibrary> loadRecipeLibrary(AppDatabase db) async {
  final recipes = await (db.select(db.recipes)..where((r) => r.deletedAt.isNull())).get();
  if (_rows == null || !identical(_rowsDb, db)) {
    // Every line, also those of recipes in the trash: restoring one is a
    // recipes-only change, and its lines have to be here then.
    final result = await db.customSelect(
      'SELECT recipe_id AS rid, name, amount, unit, notes FROM ingredients ORDER BY recipe_id, sort_order',
      readsFrom: {db.ingredients},
    ).get();
    _rows = [
      for (final row in result)
        IngredientRow(
          recipeId: row.read<String>('rid'),
          name: row.read<String>('name'),
          amount: row.readNullable<String>('amount'),
          unit: row.readNullable<String>('unit'),
          notes: row.readNullable<String>('notes'),
        ),
    ];
    _rowsDb = db;
  }
  final rows = _rows!;
  if (_keyCache.length > _keyCacheLimit) _keyCache.clear();
  final present = {for (final r in recipes) r.id};
  final allKnown = rows.every((r) => !present.contains(r.recipeId) || _keyCache.containsKey(_lineKey(r)));
  if (kIsWeb || recipes.length < 300 || allKnown) return buildRecipeLibrary(recipes, rows, keys: _keyCache);
  final (library, keys) = await compute(_buildLibraryJob, (recipes, rows));
  _keyCache.addAll(keys);
  return library;
}

// ── Ranking ────────────────────────────────────────────────────────────────

/// A counted line the pantry lacks, and what of it is still needed.
class MissingLine {
  final LibraryIngredient ingredient;

  /// The foods of the line not on hand, as the recipe writes them: only
  /// "maraschino cherry" of "pineapple leaf and maraschino cherry" when
  /// pineapple is in the pantry.
  final List<String> foods;

  /// Some of the line is on hand, so only [foods] are needed.
  final bool partly;

  const MissingLine({required this.ingredient, required this.foods, this.partly = false});
}

/// How much of one recipe the pantry covers.
class PantryRecipeMatch {
  final LibraryRecipe recipe;

  /// Lines that count: not always-have basics, not optional.
  final int counted;

  /// Counted lines the pantry has.
  final int covered;

  /// Lines that are always-have basics (water, salt, pepper).
  final int basics;

  /// Counted lines the pantry lacks, in recipe order.
  final List<LibraryIngredient> missing;

  /// What [missing] still needs, line by line in the same order.
  final List<MissingLine> missingLines;

  /// Lines the pantry has, in recipe order, each with the pantry items that
  /// cover it as the user wrote them. Optional lines on hand are here too;
  /// only counted ones are in [covered].
  final List<(LibraryIngredient, List<String>)> coveredBy;

  /// Foods of optional lines (a garnish, "to serve") that are not on hand,
  /// as the recipe writes them, each once. Shown, never counted.
  final List<String> optionalMissing;

  const PantryRecipeMatch({
    required this.recipe,
    required this.counted,
    required this.covered,
    required this.basics,
    required this.missing,
    this.missingLines = const [],
    this.coveredBy = const [],
    this.optionalMissing = const [],
  });

  /// The pantry items this recipe uses, each once, in recipe order.
  List<String> get pantryItemsUsed => {
        for (final (_, items) in coveredBy) ...items,
      }.toList();

  /// The foods to get, each once, in recipe order: what the missing chips
  /// name, and what a tap on one adds to the pantry.
  List<String> get missingFoods {
    final seen = <String>{};
    return [
      for (final line in missingLines)
        for (final food in line.foods)
          if (seen.add(food.toLowerCase())) food,
    ];
  }

  /// What "Add missing" puts on the shopping list: a line that is wholly
  /// lacking as written (amount and all), and of a line partly on hand only
  /// the foods still needed.
  List<LibraryIngredient> get toBuy => [
        for (final line in missingLines)
          if (line.partly)
            for (final food in line.foods) LibraryIngredient(name: food, key: ingredientKeyFor(food))
          else
            line.ingredient,
      ];

  /// Share of the counted lines in the pantry, 0 to 1.
  double get share => counted == 0 ? (basics > 0 ? 1 : 0) : covered / counted;

  int get missingCount => missing.length;

  /// Nothing to buy.
  bool get readyNow => missing.isEmpty && (counted > 0 || basics > 0);

  /// Something in the pantry goes into it.
  bool get usesPantry => covered > 0 || readyNow;
}

/// Check one recipe against the pantry. A food listed twice (butter for the
/// sauce and butter for the pan) counts once. Optional lines (a garnish, "to
/// serve", anything under such a section) never count, and never stand in
/// for a needed line of the same food.
PantryRecipeMatch matchRecipe(LibraryRecipe recipe, PantryMatcher matcher) {
  var counted = 0, covered = 0, basics = 0;
  final missing = <LibraryIngredient>[];
  final missingLines = <MissingLine>[];
  final coveredBy = <(LibraryIngredient, List<String>)>[];
  final optionalMissing = <String>[];
  final seen = <String>{};
  final seenOptional = <String>{};
  final seenOptionalFood = <String>{};
  for (final ingredient in recipe.ingredients) {
    final key = ingredient.key;
    if (key.isEmpty) continue;
    var cover = matcher.coverOf(key);
    if (ingredient.inOptionalSection && cover != IngredientCover.basic) cover = IngredientCover.ignored;
    if (cover == IngredientCover.ignored) {
      if (!seenOptional.add(key.signature)) continue;
      final lacking = matcher.missingFoodsFor(key);
      if (lacking.isEmpty) {
        final items = matcher.pantryItemsFor(key);
        if (items.isNotEmpty) coveredBy.add((ingredient, items));
      } else {
        for (final food in lacking) {
          final label = key.labelOf(food);
          if (seenOptionalFood.add(label.toLowerCase())) optionalMissing.add(label);
        }
      }
      continue;
    }
    if (!seen.add(key.signature)) continue;
    switch (cover) {
      case IngredientCover.basic:
        basics++;
      case IngredientCover.ignored:
        break;
      case IngredientCover.covered:
        counted++;
        covered++;
        coveredBy.add((ingredient, matcher.pantryItemsFor(key)));
      case IngredientCover.missing:
        counted++;
        missing.add(ingredient);
        final alternative = matcher.closestAlternative(key)!;
        final lacking = [for (final p in alternative) if (!matcher.hasFood(p)) p];
        missingLines.add(MissingLine(
          ingredient: ingredient,
          foods: [for (final p in lacking) key.labelOf(p)],
          partly: lacking.length < alternative.length,
        ));
    }
  }
  // Mint to garnish and mint in the glass: named once, as missing.
  if (optionalMissing.isNotEmpty && missingLines.isNotEmpty) {
    final needed = {for (final l in missingLines) for (final f in l.foods) f.toLowerCase()};
    optionalMissing.removeWhere((f) => needed.contains(f.toLowerCase()));
  }
  return PantryRecipeMatch(
    recipe: recipe,
    counted: counted,
    covered: covered,
    basics: basics,
    missing: missing,
    missingLines: missingLines,
    coveredBy: coveredBy,
    optionalMissing: optionalMissing,
  );
}

/// Ready first, then by the share covered, fewest missing, most covered,
/// favourites, title.
int comparePantryMatches(PantryRecipeMatch a, PantryRecipeMatch b) {
  if (a.readyNow != b.readyNow) return a.readyNow ? -1 : 1;
  final byShare = b.share.compareTo(a.share);
  if (byShare != 0) return byShare;
  if (a.missingCount != b.missingCount) return a.missingCount.compareTo(b.missingCount);
  if (a.covered != b.covered) return b.covered.compareTo(a.covered);
  if (a.recipe.isFavorite != b.recipe.isFavorite) return a.recipe.isFavorite ? -1 : 1;
  final byTitle = a.recipe.title.toLowerCase().compareTo(b.recipe.title.toLowerCase());
  return byTitle != 0 ? byTitle : a.recipe.id.compareTo(b.recipe.id);
}

/// Every recipe in [library] checked against the pantry, best first.
List<PantryRecipeMatch> rankRecipesByPantry(RecipeLibrary library, PantryMatcher matcher) {
  final matches = [for (final r in library.recipes) matchRecipe(r, matcher)];
  matches.sort(comparePantryMatches);
  return matches;
}

/// The quick filters on "What can I make?".
enum PantryFilter {
  /// Everything that uses something from the pantry.
  all,

  /// Nothing to buy.
  readyNow,

  /// One or two things to buy.
  missingFew,
}

bool pantryFilterAccepts(PantryFilter filter, PantryRecipeMatch m) => switch (filter) {
      PantryFilter.all => m.usesPantry,
      PantryFilter.readyNow => m.readyNow,
      PantryFilter.missingFew => m.missingCount >= 1 && m.missingCount <= 2 && m.covered > 0,
    };

/// [ranked] narrowed to [filter], and to one course and one cookbook when
/// given (a recipe counts as in a cookbook when any copy is there).
List<PantryRecipeMatch> filterPantryMatches(
  List<PantryRecipeMatch> ranked, {
  PantryFilter filter = PantryFilter.all,
  String? courseKey,
  String? cookbookId,
}) {
  return [
    for (final m in ranked)
      if (pantryFilterAccepts(filter, m) &&
          (courseKey == null || m.recipe.courseKey == courseKey) &&
          (cookbookId == null || m.recipe.cookbookIds.contains(cookbookId)))
        m,
  ];
}

// ── Add missing to the shopping list ───────────────────────────────────────

/// The shopping list the user is working in: the one last open on the
/// Shopping tab, else their default list, else the built-in one, else the
/// first; a new list called [newListName] when there are none.
Future<ShoppingList> resolveActiveShoppingList(ShoppingDao dao, {required String newListName}) async {
  String? lastId;
  try {
    lastId = (await SharedPreferences.getInstance()).getString('shoppingLastListId');
  } catch (_) {}
  ShoppingList? list;
  if (lastId != null) list = await dao.getListById(lastId);
  list ??= await dao.getDefaultList();
  list ??= await dao.getListById('list_default');
  if (list == null) {
    final lists = await dao.getAllLists();
    if (lists.isNotEmpty) list = lists.first;
  }
  if (list != null) return list;
  final id = 'list_${DateTime.now().millisecondsSinceEpoch}';
  await dao.insertList(ShoppingListsCompanion.insert(id: id, name: newListName));
  return (await dao.getListById(id))!;
}

/// Put [ingredients] of [recipe] on a shopping list with the same stacking
/// and aisle grouping as "Add to shopping list" on a recipe. Returns how many
/// lines were added and how many joined a line already on the list.
Future<({int added, int combined, ShoppingList list})> addIngredientsToShoppingList({
  required ShoppingDao dao,
  required LibraryRecipe recipe,
  required List<LibraryIngredient> ingredients,
  required String newListName,
  String? listId,
}) async {
  final list = listId != null
      ? (await dao.getListById(listId)) ?? await resolveActiveShoppingList(dao, newListName: newListName)
      : await resolveActiveShoppingList(dao, newListName: newListName);
  if (ingredients.isEmpty) return (added: 0, combined: 0, list: list);
  final mappings = await dao.getUserIngredientMappings();
  final result = await dao.addItemsFromRecipeWithStacking(
    listId: list.id,
    recipeId: recipe.id,
    recipeName: recipe.title,
    ingredients: [
      for (final i in ingredients)
        <String, String?>{
          'name': i.name,
          'amount': i.amount ?? '',
          'unit': i.unit ?? '',
          'categoryId': getShoppingCategory(i.name, userMappings: mappings),
        },
    ],
  );
  return (added: result.added, combined: result.combined, list: list);
}

/// Names of shopping items the user ticked off lately, newest first, cut
/// down to the food ("2 cups flour" is "flour"), each once. Ready to offer
/// as quick pantry adds.
List<String> recentlyBoughtNames(Iterable<ShoppingListItem> checkedNewestFirst, {int limit = 16}) {
  final seen = <String>{};
  final out = <String>[];
  for (final item in checkedNewestFirst) {
    final parsed = parseIngredient(item.name);
    final key = ingredientKeyFor(parsed.name.isNotEmpty ? parsed.name : item.name);
    if (key.isEmpty) continue;
    if (!seen.add(key.signature)) continue;
    out.add(key.label);
    if (out.length >= limit) break;
  }
  return out;
}
