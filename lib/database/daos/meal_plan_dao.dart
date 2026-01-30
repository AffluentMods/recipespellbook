import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/meal_plans.dart';
import '../tables/recipes.dart';

part 'meal_plan_dao.g.dart';

@DriftAccessor(tables: [MealPlans, Recipes])
class MealPlanDao extends DatabaseAccessor<AppDatabase> with _$MealPlanDaoMixin {
  MealPlanDao(super.db);

  Stream<List<MealPlanWithRecipe>> watchMealPlansWithRecipesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = select(mealPlans).join([
      leftOuterJoin(recipes, recipes.id.equalsExp(mealPlans.recipeId)),
    ])
      ..where(mealPlans.date.isBiggerOrEqualValue(startOfDay))
      ..where(mealPlans.date.isSmallerThanValue(endOfDay))
      ..orderBy([OrderingTerm(expression: mealPlans.time)]);

    return query.map((row) => MealPlanWithRecipe(
      mealPlan: row.readTable(mealPlans),
      recipe: row.readTableOrNull(recipes),
    )).watch();
  }

  Future<void> insertMealPlan(MealPlansCompanion mealPlan) {
    return into(mealPlans).insert(mealPlan);
  }

  Future<void> deleteMealPlan(String id) {
    return (delete(mealPlans)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deletePastMealPlans() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return (delete(mealPlans)..where((t) => t.date.isSmallerThanValue(startOfDay))).go();
  }

  Stream<List<MealPlan>> watchMealPlansForDate(String cookbookId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(mealPlans)
      ..where((t) => t.date.isBiggerOrEqualValue(startOfDay))
      ..where((t) => t.date.isSmallerThanValue(endOfDay))
      ..orderBy([(t) => OrderingTerm(expression: t.time)]))
        .watch();
  }

  /// Get meal plans within a date range (inclusive)
  Future<List<MealPlan>> getMealPlansForDateRange(DateTime start, DateTime end) {
    final startNormalized = DateTime(start.year, start.month, start.day);
    final endNormalized = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return (select(mealPlans)
      ..where((t) => t.date.isBiggerOrEqualValue(startNormalized))
      ..where((t) => t.date.isSmallerOrEqualValue(endNormalized))
      ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .get();
  }

  Future<List<MealPlan>> getMealPlansInRange(String cookbookId, DateTime start, DateTime end) {
    return (select(mealPlans)
      ..where((t) => t.date.isBiggerOrEqualValue(start))
      ..where((t) => t.date.isSmallerThanValue(end)))
        .get();
  }

  Future<void> updateMealPlanDate(String id, DateTime newDate) {
    return (update(mealPlans)..where((t) => t.id.equals(id)))
        .write(MealPlansCompanion(date: Value(newDate)));
  }

  Future<void> updateMealPlanNotes(String id, String? notes) {
    return (update(mealPlans)..where((t) => t.id.equals(id)))
        .write(MealPlansCompanion(notes: Value(notes)));
  }

  Stream<Map<DateTime, int>> watchMealCountsForDateRange(DateTime startDate, DateTime endDate) {
    // Query to get count of meal plans per day in the date range
    final query = customSelect(
      '''
    SELECT date, COUNT(*) as count 
    FROM meal_plans 
    WHERE date >= ? AND date <= ?
    GROUP BY date
    ''',
      variables: [
        Variable.withDateTime(startDate),
        Variable.withDateTime(endDate),
      ],
      readsFrom: {mealPlans},
    );

    return query.watch().map((rows) {
      final Map<DateTime, int> result = {};
      for (final row in rows) {
        final dateInt = row.read<int>('date');
        final date = DateTime.fromMillisecondsSinceEpoch(dateInt);
        // Normalize to just date (no time)
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final count = row.read<int>('count');
        result[normalizedDate] = count;
      }
      return result;
    });
  }

// Alternative implementation if the above doesn't work with your Drift version:

  Stream<Map<DateTime, int>> watchMealCountsForDateRangeAlt(DateTime startDate, DateTime endDate) {
    // Watch all meal plans in the date range
    final query = select(mealPlans)
      ..where((mp) => mp.date.isBiggerOrEqualValue(startDate))
      ..where((mp) => mp.date.isSmallerOrEqualValue(endDate));

    return query.watch().map((plans) {
      final Map<DateTime, int> result = {};
      for (final plan in plans) {
        final normalizedDate = DateTime(plan.date.year, plan.date.month, plan.date.day);
        result[normalizedDate] = (result[normalizedDate] ?? 0) + 1;
      }
      return result;
    });
  }
}

class MealPlanWithRecipe {
  final MealPlan mealPlan;
  final Recipe? recipe;

  MealPlanWithRecipe({required this.mealPlan, this.recipe});
}