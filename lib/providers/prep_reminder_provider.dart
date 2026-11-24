import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/prep_reminder_service.dart' show loadPrepRecipes;
import '../services/prep_reminders.dart';
import 'database_provider.dart';
import 'pantry_cooking_provider.dart';

/// The pantry as prep reminders see it: what is in the freezer and needs
/// thawing, and what is on hand otherwise.
final prepPantryProvider = FutureProvider<PrepPantry>((ref) async {
  final pantry = await ref.watch(pantryProvider.future);
  return PrepPantry(
    items: [for (final e in pantry.entries) (e.name, e.frozen)],
    basics: pantry.basics,
  );
});

/// What a recipe needs done the day before (thawing, soaking, marinating,
/// time ahead), for the planner's "Prep the day before" line. Worked out
/// again when the recipe or the pantry changes.
final recipePrepProvider = FutureProvider.autoDispose.family<List<PrepTask>, String>((ref, recipeId) async {
  // Recipe and ingredient edits, then step edits.
  ref.watch(recipeLibraryVersionProvider);
  final db = ref.watch(databaseProvider);
  final steps = db.tableUpdates(TableUpdateQuery.onTable(db.steps)).listen((_) => ref.invalidateSelf());
  ref.onDispose(steps.cancel);
  final pantry = await ref.watch(prepPantryProvider.future);
  final recipe = (await loadPrepRecipes(db, {recipeId}))[recipeId];
  return recipe == null ? const <PrepTask>[] : prepTasksFor(recipe, pantry);
});
