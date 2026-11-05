import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/cook_history_service.dart';
import '../services/pantry_cooking_service.dart';
import '../services/pantry_matcher.dart';
import '../services/pantry_service.dart';
import '../services/recipe_suggestion_service.dart';
import '../utils/week_start.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

// ── The recipe library, reduced once per data change ──

/// Goes up a short while after recipes or ingredients change, so a burst of
/// edits (an import, a sync) reduces the library once.
class RecipeLibraryVersion extends Notifier<int> {
  static const settle = Duration(milliseconds: 500);

  @override
  int build() {
    final db = ref.watch(databaseProvider);
    Timer? timer;
    final sub = db
        .tableUpdates(TableUpdateQuery.onAllTables([db.recipes, db.ingredients]))
        .listen((_) {
      timer?.cancel();
      timer = Timer(settle, () => state++);
    });
    ref.onDispose(() {
      timer?.cancel();
      sub.cancel();
    });
    return 0;
  }
}

final recipeLibraryVersionProvider =
    NotifierProvider<RecipeLibraryVersion, int>(RecipeLibraryVersion.new);

/// Every recipe in every cookbook, copies folded together and each
/// ingredient line reduced for pantry matching. Two queries per data change.
final recipeLibraryProvider = FutureProvider<RecipeLibrary>((ref) {
  ref.watch(recipeLibraryVersionProvider);
  return loadRecipeLibrary(ref.watch(databaseProvider));
});

// ── The pantry ──

/// What the user has on hand, and the basics they always have.
class PantryState {
  final List<String> items;
  final List<String> basics;

  PantryState({required this.items, required this.basics});

  late final PantryMatcher matcher = PantryMatcher(pantry: items, basics: basics);

  bool get isEmpty => items.isEmpty;
}

class PantryNotifier extends AsyncNotifier<PantryState> {
  PantryService get _service => PantryService.instance;

  @override
  Future<PantryState> build() => _read();

  Future<PantryState> _read() async =>
      PantryState(items: await _service.getAll(), basics: await _service.getBasics());

  Future<void> _change(Future<void> Function() change) async {
    await change();
    state = AsyncData(await _read());
  }

  Future<void> add(String name) => _change(() => _service.addItem(name));
  Future<void> addAll(List<String> names) => _change(() => _service.addItems(names));
  Future<void> remove(String name) => _change(() => _service.removeItem(name));
  Future<void> clear() => _change(_service.clear);
  Future<void> addBasic(String name) => _change(() => _service.addBasic(name));
  Future<void> removeBasic(String name) => _change(() => _service.removeBasic(name));
}

final pantryProvider = AsyncNotifierProvider<PantryNotifier, PantryState>(PantryNotifier.new);

/// Every recipe checked against the pantry, best first. Re-ranked when the
/// pantry or the library changes; the matching itself is cached per food.
final pantryMatchesProvider = FutureProvider<List<PantryRecipeMatch>>((ref) async {
  final library = await ref.watch(recipeLibraryProvider.future);
  final pantry = await ref.watch(pantryProvider.future);
  return rankRecipesByPantry(library, pantry.matcher);
});

/// Foods from shopping items the user ticked off lately, newest first, for
/// quick pantry adds. Leave out the ones already in the pantry with
/// [PantryMatcher.hasItem].
final recentlyBoughtProvider = StreamProvider<List<String>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.shoppingListItems)
    ..where((t) => t.isChecked.equals(true))
    ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
    ..limit(150);
  return query.watch().map((items) => recentlyBoughtNames(items, limit: 40));
});

// ── What's for dinner ──

/// Recipe meals in the planner (recipe id and day), past and future.
final plannedRecipeDaysProvider = StreamProvider<List<(String, DateTime)>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.mealPlans)
    ..where((m) => m.deletedAt.isNull() & m.recipeId.isNotNull());
  return query.watch().map((plans) => [
        for (final p in plans) (p.recipeId!, p.date),
      ]);
});

/// When each recipe was last finished in cooking mode on this device.
final cookHistoryProvider = FutureProvider<Map<String, DateTime>>(
  (ref) => CookHistoryService.lastCooked(),
);

/// Bumped by "Show others": a new shuffle that pushes back what was shown.
final dinnerShuffleProvider =
    StateProvider<({int round, Set<String> shown})>((ref) => (round: 0, shown: const {}));

/// Dinner suggestions for [day] (midnight): not planned that week or the
/// seven days after it, not made or opened lately, each with its reason.
final dinnerSuggestionsProvider =
    FutureProvider.family<List<DinnerSuggestion>, DateTime>((ref, day) async {
  final matches = await ref.watch(pantryMatchesProvider.future);
  final pantry = await ref.watch(pantryProvider.future);
  final plans = await ref.watch(plannedRecipeDaysProvider.future);
  final cooked = await ref.watch(cookHistoryProvider.future);
  final shuffle = ref.watch(dinnerShuffleProvider);
  final weekStartDay = ref.watch(settingsProvider.select((s) => s.weekStartDay));

  final today = DateTime(day.year, day.month, day.day);
  final from = startOfWeek(today, weekStartDay);
  final weekEnd = addDays(from, 7);
  final aheadEnd = addDays(today, 7);
  final to = aheadEnd.isAfter(weekEnd) ? aheadEnd : weekEnd;

  final planned = <String>{};
  final lastMade = Map<String, DateTime>.of(cooked);
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  for (final (recipeId, date) in plans) {
    if (!date.isBefore(from) && date.isBefore(to)) planned.add(recipeId);
    // A meal planned on a day that has passed was most likely made then.
    if (date.isBefore(startOfToday)) {
      final known = lastMade[recipeId];
      if (known == null || date.isAfter(known)) lastMade[recipeId] = date;
    }
  }

  final daySeed = today.year * 1000 + today.difference(DateTime(today.year)).inDays;
  return RecipeSuggestionService.suggestDinner(
    matches: matches,
    pantryEmpty: pantry.isEmpty,
    now: today.isAfter(startOfToday) ? DateTime(today.year, today.month, today.day, 18) : now,
    plannedIds: planned,
    lastMade: lastMade,
    seed: daySeed * 31 + shuffle.round,
    skipIds: shuffle.shown,
  );
});

/// Show other dinner suggestions than [shown].
void reshuffleDinner(WidgetRef ref, Iterable<DinnerSuggestion> shown) {
  final current = ref.read(dinnerShuffleProvider);
  ref.read(dinnerShuffleProvider.notifier).state = (
    round: current.round + 1,
    shown: {...current.shown, for (final s in shown) ...s.recipe.copyIds},
  );
}

/// Midnight today: the key for today's dinner suggestions.
DateTime dinnerDay([DateTime? date]) {
  final d = date ?? DateTime.now();
  return DateTime(d.year, d.month, d.day);
}
