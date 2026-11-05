import 'dart:convert';

import '../database/database.dart';
import '../utils/recipe_title.dart';
import '../utils/widget_links.dart';

/// Shared-storage key the snapshot is written under. The Android providers
/// (`widgets/WidgetSnapshot.kt`) and the iOS extension
/// (`ios/RecipeWidgets/WidgetSnapshot.swift`) read this exact key.
const homeWidgetSnapshotKey = 'rsb_widget_snapshot';

/// SharedPreferences key of the list the Shopping screen last showed. The
/// shopping widget shows the same list, so a tap on it lands where it points.
const shoppingLastListPrefKey = 'shoppingLastListId';

/// Id of the built-in shopping list every install starts with.
const _builtInListId = 'list_default';

/// Words the widgets show around the user's data, in the app's language (which
/// can differ from the phone's). The widgets fall back to their own
/// translations until the app has written a snapshot.
class HomeWidgetLabels {
  final String mealsTitle;
  final String mealsEmpty;
  final String shoppingTitle;
  final String shoppingEmpty;

  const HomeWidgetLabels({
    required this.mealsTitle,
    required this.mealsEmpty,
    required this.shoppingTitle,
    required this.shoppingEmpty,
  });

  Map<String, Object?> toJson() => {
        'mealsTitle': mealsTitle,
        'mealsEmpty': mealsEmpty,
        'shoppingTitle': shoppingTitle,
        'shoppingEmpty': shoppingEmpty,
      };
}

/// The small JSON document the home screen widgets draw from.
///
/// ```json
/// {
///   "v": 1,
///   "today": "2026-11-05",
///   "labels": {"mealsTitle": "...", "mealsEmpty": "...", ...},
///   "meals": {
///     "link": "recipespellbook://planner",
///     "days": {
///       "2026-11-05": {
///         "total": 3,
///         "items": [{"title": "Pancakes", "type": "Breakfast",
///                    "typeLabel": "Breakfast", "time": "08:30",
///                    "recipeId": "...", "link": "recipespellbook://recipe/..."}]
///       }
///     }
///   },
///   "shopping": {"link": "recipespellbook://shopping", "listId": "...",
///                "name": "Weekly shop", "unchecked": 12,
///                "items": [{"name": "Milk", "detail": "2 l"}]}
/// }
/// ```
///
/// Meals cover today and the next [daysAhead] - 1 days, so a widget can move
/// on to the new day at midnight without the app running. Only days that have
/// meals are listed; a missing day means nothing is planned.
abstract final class HomeWidgetSnapshot {
  static const version = 1;

  /// Days of meals written, today included.
  static const daysAhead = 7;

  /// Meals listed per day. `total` still counts every meal of the day.
  static const maxMealsPerDay = 8;

  /// Unchecked items listed. `unchecked` still counts all of them.
  static const maxShoppingItems = 8;

  /// Builds the snapshot from data that is already loaded.
  ///
  /// [meals] may hold any days; only today and the following days up to
  /// [daysAhead] are kept. [listItems] are the items of [list] in list order.
  static Map<String, Object?> build({
    required DateTime now,
    required List<MealPlanWithRecipe> meals,
    required ShoppingList? list,
    required List<ShoppingListItem> listItems,
    required HomeWidgetLabels labels,
    required String Function(String mealType) mealTypeLabel,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(today.year, today.month, today.day + daysAhead);

    final byDay = <String, List<MealPlanWithRecipe>>{};
    for (final m in meals) {
      final plan = m.mealPlan;
      if (plan.deletedAt != null) continue;
      final day = DateTime(plan.date.year, plan.date.month, plan.date.day);
      if (day.isBefore(today) || !day.isBefore(end)) continue;
      byDay.putIfAbsent(dayKey(day), () => []).add(m);
    }

    final days = <String, Object?>{};
    for (final key in byDay.keys.toList()..sort()) {
      final dayMeals = byDay[key]!..sort(_compareMeals);
      days[key] = {
        'total': dayMeals.length,
        'items': [
          for (final m in dayMeals.take(maxMealsPerDay)) _mealJson(m, mealTypeLabel),
        ],
      };
    }

    final unchecked = [
      for (final item in listItems)
        if (!item.isChecked && item.deletedAt == null) item,
    ];

    return {
      'v': version,
      'today': dayKey(today),
      'labels': labels.toJson(),
      'meals': {
        'link': WidgetLinks.planner.toString(),
        'days': days,
      },
      'shopping': {
        'link': WidgetLinks.shopping.toString(),
        'listId': list?.id,
        'name': list?.name.trim(),
        'unchecked': list == null ? 0 : unchecked.length,
        'items': [
          if (list != null)
            for (final item in unchecked.take(maxShoppingItems)) _itemJson(item),
        ],
      },
    };
  }

  /// Loads what the widgets need from [db] and builds the snapshot.
  ///
  /// The shopping widget shows [preferredListId] (the list the Shopping screen
  /// last showed) when it still exists, else the list marked as default, else
  /// the built-in list, else the first list by name.
  static Future<Map<String, Object?>> load(
    AppDatabase db, {
    required DateTime now,
    required HomeWidgetLabels labels,
    required String Function(String mealType) mealTypeLabel,
    String? preferredListId,
  }) async {
    final today = DateTime(now.year, now.month, now.day);
    final meals = await db.mealPlanDao
        .watchMealPlansWithRecipesForRange(
          today,
          DateTime(today.year, today.month, today.day + daysAhead),
        )
        .first;

    final list = await _activeList(db, preferredListId);
    final items = list == null
        ? const <ShoppingListItem>[]
        : await db.shoppingDao.getItemsForList(list.id);

    return build(
      now: now,
      meals: meals,
      list: list,
      listItems: items,
      labels: labels,
      mealTypeLabel: mealTypeLabel,
    );
  }

  /// The snapshot as the string that goes into widget storage.
  static String encode(Map<String, Object?> snapshot) => jsonEncode(snapshot);

  /// `yyyy-MM-dd` of [day] in local time, the key of [build]'s `days` map.
  static String dayKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  // ── Internals ──────────────────────────────────────────────────────

  static Future<ShoppingList?> _activeList(AppDatabase db, String? preferredId) async {
    final dao = db.shoppingDao;
    bool live(ShoppingList? l) => l != null && l.deletedAt == null;

    if (preferredId != null) {
      final l = await dao.getListById(preferredId);
      if (live(l)) return l;
    }
    final marked = await dao.getDefaultList();
    if (live(marked)) return marked;
    final builtIn = await dao.getListById(_builtInListId);
    if (live(builtIn)) return builtIn;
    for (final l in await dao.getAllLists()) {
      if (live(l)) return l;
    }
    return null;
  }

  static Map<String, Object?> _mealJson(
    MealPlanWithRecipe m,
    String Function(String mealType) mealTypeLabel,
  ) {
    final plan = m.mealPlan;
    final recipe = m.recipe;
    final typeLabel = mealTypeLabel(plan.mealType);
    final time = plan.time;
    // A meal whose recipe is in the trash (or gone) opens the planner instead.
    final recipeId = recipe != null &&
            recipe.deletedAt == null &&
            WidgetLinks.isValidRecipeId(recipe.id)
        ? recipe.id
        : null;

    return {
      'title': _mealTitle(m, typeLabel),
      'type': plan.mealType,
      'typeLabel': typeLabel,
      'time': time == null ? null : _clock(time.hour, time.minute),
      'recipeId': recipeId,
      'link': (recipeId != null ? WidgetLinks.recipe(recipeId) : WidgetLinks.planner).toString(),
    };
  }

  /// Same order of preference as the planner: the recipe's title, then the
  /// meal's own name, then the custom meal text, then the meal type.
  static String _mealTitle(MealPlanWithRecipe m, String typeLabel) {
    final recipeTitle = m.recipe == null ? '' : normalizeTitle(m.recipe!.title).title;
    for (final candidate in [recipeTitle, m.mealPlan.name, m.mealPlan.customMeal]) {
      final t = candidate?.trim() ?? '';
      if (t.isNotEmpty) return t;
    }
    return typeLabel;
  }

  static Map<String, Object?> _itemJson(ShoppingListItem item) {
    final detail = [item.quantity, item.unit]
        .map((s) => s?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .join(' ');
    return {
      'name': item.name.trim(),
      'detail': detail.isEmpty ? null : detail,
    };
  }

  /// Meals in the order of the day: by their clock time, or the meal type's
  /// usual slot when they have none (the planner's timeline uses the same
  /// slots), then in the order they were planned.
  static int _compareMeals(MealPlanWithRecipe a, MealPlanWithRecipe b) {
    final byTime = _minuteOfDay(a.mealPlan).compareTo(_minuteOfDay(b.mealPlan));
    if (byTime != 0) return byTime;
    return a.mealPlan.createdAt.compareTo(b.mealPlan.createdAt);
  }

  static int _minuteOfDay(MealPlan plan) {
    final t = plan.time;
    if (t != null) return t.hour * 60 + t.minute;
    return switch (plan.mealType.toLowerCase()) {
      'breakfast' => 8 * 60,
      'lunch' => 12 * 60,
      'snack' => 15 * 60,
      'appetizer' => 17 * 60,
      'dinner' => 18 * 60,
      'dessert' => 19 * 60 + 30,
      _ => 12 * 60,
    };
  }

  static String _clock(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
