import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

/// Where a Quick Access recipe comes from.
enum QuickAccessSource { mealPlan, pinned, recent }

typedef QuickAccessItem = ({Recipe recipe, QuickAccessSource source});

/// "Jump back in" on the home screen, phone and desktop alike: today's
/// planned recipes, then pinned ones, then recently viewed ones. Each part
/// follows its switch in Settings > Quick Access, and the recent part its
/// history count.
final jumpBackInProvider = FutureProvider.autoDispose
    .family<List<QuickAccessItem>, String>((ref, cookbookId) async {
  ref.watch(recipesInCookbookProvider(cookbookId));
  final (showMealPlan, showPinned, showHistory, historyCount) = ref.watch(
    settingsProvider.select(
      (s) => (
        s.quickAccessShowMealPlan,
        s.quickAccessShowPinned,
        s.quickAccessShowHistory,
        s.quickAccessHistoryCount,
      ),
    ),
  );
  final dao = ref.watch(recipeDaoProvider);
  final items = <QuickAccessItem>[];
  final seen = <String>{};
  if (showMealPlan) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final plan in await ref.watch(mealPlansForDateProvider(today).future)) {
      final recipe = plan.recipe;
      if (recipe == null || recipe.deletedAt != null) continue;
      if (seen.add(recipe.id)) {
        items.add((recipe: recipe, source: QuickAccessSource.mealPlan));
      }
    }
  }
  if (showPinned) {
    for (final r in await dao.getPinnedRecipes(cookbookId)) {
      if (seen.add(r.id)) items.add((recipe: r, source: QuickAccessSource.pinned));
    }
  }
  if (showHistory) {
    final recent =
        await dao.watchRecentlyViewed(cookbookId, limit: historyCount).first;
    for (final r in recent) {
      if (seen.add(r.id)) items.add((recipe: r, source: QuickAccessSource.recent));
    }
  }
  return items;
});
