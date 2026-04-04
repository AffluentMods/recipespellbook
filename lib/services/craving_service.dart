import 'dart:math';

import '../database/database.dart';
import 'community_service.dart';

// ═══════════════════════════════════════════════════════════════
// CRAVING DISCOVERY SERVICE
//
// Pure client-side matching — no AI, no backend changes.
// Maps user mood/category/source selections into filtered,
// shuffled recipe results from local DB and/or community API.
// ═══════════════════════════════════════════════════════════════

enum CravingMood {
  sweet('Sweet', '🍰'),
  savory('Savory', '🍖'),
  light('Light', '🥗'),
  filling('Filling', '🍜'),
  quick('Quick', '⚡'),
  special('Something Special', '🎉');

  final String label;
  final String emoji;
  const CravingMood(this.label, this.emoji);
}

enum CravingSource {
  myRecipes('My saved recipes', '📚', 'From your personal library'),
  community('Discover something new', '🌍', 'From the community'),
  both('Both — surprise me', '✨', 'Mix of yours and community');

  final String label;
  final String emoji;
  final String subtitle;
  const CravingSource(this.label, this.emoji, this.subtitle);
}

/// A unified recipe result from either local DB or community.
class CravingResult {
  final String id;
  final String title;
  final String? description;
  final String? imagePath;
  final String? servings;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final String? courseId;
  final String? categoryId;
  final int? rating;
  final bool isFavorite;
  final bool isLocal;
  final String? cookbookId; // community cookbook ID for navigation

  /// First N ingredient display strings
  final List<String> ingredientNames;
  final int totalIngredients;

  /// First N step instruction strings
  final List<String> stepTexts;
  final int totalSteps;

  const CravingResult({
    required this.id,
    required this.title,
    this.description,
    this.imagePath,
    this.servings,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.courseId,
    this.categoryId,
    this.rating,
    this.isFavorite = false,
    required this.isLocal,
    this.cookbookId,
    this.ingredientNames = const [],
    this.totalIngredients = 0,
    this.stepTexts = const [],
    this.totalSteps = 0,
  });

  int get totalTimeMinutes => (prepTimeMinutes ?? 0) + (cookTimeMinutes ?? 0);
}

// ─── Mood → filter mapping ───────────────────────────────────

const _moodCourses = <CravingMood, Set<String>>{
  CravingMood.sweet: {'dessert', 'breakfast'},
  CravingMood.savory: {'main', 'appetizer', 'sauce'},
  CravingMood.light: {'snack', 'side'},
  CravingMood.filling: {'main'},
  // quick + special use special filter logic, not course/category
};

const _moodCategories = <CravingMood, Set<String>>{
  CravingMood.sweet: {'dessert', 'muffin', 'bread'},
  CravingMood.savory: {
    'chicken-steak-meat', 'fish', 'pasta', 'rice',
    'casserole', 'soup', 'burrito-taco', 'sandwich',
  },
  CravingMood.light: {'salad', 'vegetable', 'fruit'},
  CravingMood.filling: {'casserole', 'pasta', 'rice'},
};

/// Category options shown in Step 2 for each mood.
const _moodCategoryOptions = <CravingMood, List<_CategoryOption>>{
  CravingMood.sweet: [
    _CategoryOption('Dessert', 'dessert', true),
    _CategoryOption('Pastry', 'muffin', false),
    _CategoryOption('Baked Goods', 'bread', false),
    _CategoryOption('Breakfast', 'breakfast', true),
  ],
  CravingMood.savory: [
    _CategoryOption('Dinner', 'main', true),
    _CategoryOption('Lunch', 'main', true),
    _CategoryOption('Appetizer', 'appetizer', true),
    _CategoryOption('Soup', 'soup', false),
    _CategoryOption('Sauce', 'sauce', true),
  ],
  CravingMood.light: [
    _CategoryOption('Salad', 'salad', false),
    _CategoryOption('Snack', 'snack', true),
    _CategoryOption('Breakfast', 'breakfast', true),
  ],
  CravingMood.filling: [
    _CategoryOption('Main Dish', 'main', true),
    _CategoryOption('Pasta', 'pasta', false),
    _CategoryOption('Rice Dishes', 'rice', false),
    _CategoryOption('Casserole', 'casserole', false),
  ],
  CravingMood.quick: [
    _CategoryOption('Under 20 min', '__under20', false),
    _CategoryOption('Under 30 min', '__under30', false),
    _CategoryOption('5 ingredients or less', '__5ings', false),
  ],
  CravingMood.special: [
    _CategoryOption('Impressive', '__impressive', false),
    _CategoryOption('Crowd Pleaser', '__crowd', false),
    _CategoryOption('Favorites', '__favorites', false),
  ],
};

class _CategoryOption {
  final String label;
  final String id;
  final bool isCourse; // true = course ID, false = category ID

  const _CategoryOption(this.label, this.id, this.isCourse);
}

/// Get the category chip options for the user's selected moods.
List<({String label, String id})> getCategoryOptionsForMoods(Set<CravingMood> moods) {
  final seen = <String>{};
  final result = <({String label, String id})>[];

  if (moods.isEmpty) {
    // Show all if no mood selected
    for (final entry in _moodCategoryOptions.values) {
      for (final opt in entry) {
        if (seen.add(opt.id)) {
          result.add((label: opt.label, id: opt.id));
        }
      }
    }
    return result;
  }

  for (final mood in moods) {
    final options = _moodCategoryOptions[mood] ?? [];
    for (final opt in options) {
      if (seen.add(opt.id)) {
        result.add((label: opt.label, id: opt.id));
      }
    }
  }
  return result;
}

// ─── Service ─────────────────────────────────────────────────

class CravingService {
  final RecipeDao _recipeDao;

  CravingService(this._recipeDao);

  /// Find recipes matching the user's mood/category/source selections.
  /// Returns up to [poolSize] results for reshuffling; caller takes first 10.
  Future<List<CravingResult>> findRecipes({
    required Set<CravingMood> moods,
    required Set<String> selectedCategories,
    required CravingSource source,
    String? cookbookId,
    int poolSize = 50,
  }) async {
    final local = <CravingResult>[];
    final community = <CravingResult>[];

    if (source == CravingSource.myRecipes || source == CravingSource.both) {
      local.addAll(await _findLocalRecipes(moods, selectedCategories, cookbookId, poolSize));
    }

    if (source == CravingSource.community || source == CravingSource.both) {
      community.addAll(await _findCommunityRecipes(moods, selectedCategories, poolSize));
    }

    switch (source) {
      case CravingSource.myRecipes:
        return local.take(poolSize).toList();
      case CravingSource.community:
        return community.take(poolSize).toList();
      case CravingSource.both:
        return _interleave(local, community, poolSize);
    }
  }

  // ─── Local recipes ─────────────────────────────────────────

  Future<List<CravingResult>> _findLocalRecipes(
    Set<CravingMood> moods,
    Set<String> selectedCategories,
    String? cookbookId,
    int limit,
  ) async {
    final allRecipes = await _recipeDao.getAllRecipes(cookbookId: cookbookId);

    var filtered = allRecipes.where((r) => _matchesMoods(r, moods)).toList();

    if (selectedCategories.isNotEmpty) {
      filtered = filtered.where((r) => _matchesSelectedCategories(r, selectedCategories)).toList();
    }

    filtered.shuffle(Random());

    final results = <CravingResult>[];
    for (final r in filtered.take(limit)) {
      final ings = await _recipeDao.getIngredientsForRecipe(r.id);
      final steps = await _recipeDao.getStepsForRecipe(r.id);
      // Filter out headers
      final realIngs = ings.where((i) => i.notes != '__header__').toList();

      results.add(CravingResult(
        id: r.id,
        title: r.title,
        description: r.description,
        imagePath: r.imagePath,
        servings: r.servings,
        prepTimeMinutes: r.prepTimeMinutes,
        cookTimeMinutes: r.cookTimeMinutes,
        courseId: r.courseId,
        categoryId: r.categoryId,
        rating: r.rating,
        isFavorite: r.isFavorite,
        isLocal: true,
        ingredientNames: realIngs.take(4).map((i) {
          final parts = <String>[];
          if (i.amount != null && i.amount!.isNotEmpty) parts.add(i.amount!);
          if (i.unit != null && i.unit!.isNotEmpty) parts.add(i.unit!);
          parts.add(i.name);
          return parts.join(' ');
        }).toList(),
        totalIngredients: realIngs.length,
        stepTexts: steps.take(2).map((s) => s.instruction).toList(),
        totalSteps: steps.length,
      ));
    }
    return results;
  }

  bool _matchesMoods(Recipe r, Set<CravingMood> moods) {
    if (moods.isEmpty) return true;

    for (final mood in moods) {
      switch (mood) {
        case CravingMood.quick:
          final total = (r.prepTimeMinutes ?? 0) + (r.cookTimeMinutes ?? 0);
          if (total > 0 && total < 30) return true;
        case CravingMood.special:
          if ((r.rating ?? 0) >= 4 || r.isFavorite) return true;
        case CravingMood.filling:
          final courses = _moodCourses[mood] ?? {};
          final cats = _moodCategories[mood] ?? {};
          final matchesCourse = r.courseId != null && courses.contains(r.courseId!.toLowerCase());
          final matchesCategory = r.categoryId != null && cats.contains(r.categoryId!.toLowerCase());
          if (matchesCourse || matchesCategory) {
            final servings = int.tryParse(r.servings ?? '') ?? 0;
            if (servings == 0 || servings >= 3) return true;
          }
        default:
          final courses = _moodCourses[mood] ?? {};
          final cats = _moodCategories[mood] ?? {};
          if (r.courseId != null && courses.contains(r.courseId!.toLowerCase())) return true;
          if (r.categoryId != null && cats.contains(r.categoryId!.toLowerCase())) return true;
      }
    }
    return false;
  }

  bool _matchesSelectedCategories(Recipe r, Set<String> categories) {
    for (final catId in categories) {
      // Special pseudo-filters
      switch (catId) {
        case '__under20':
          final t = (r.prepTimeMinutes ?? 0) + (r.cookTimeMinutes ?? 0);
          if (t > 0 && t < 20) return true;
          continue;
        case '__under30':
          final t = (r.prepTimeMinutes ?? 0) + (r.cookTimeMinutes ?? 0);
          if (t > 0 && t < 30) return true;
          continue;
        case '__5ings':
          // Can't check ingredient count without fetching — skip this filter for initial pass
          return true;
        case '__impressive':
          final t = (r.cookTimeMinutes ?? 0);
          if (t > 45) return true;
          continue;
        case '__crowd':
          final s = int.tryParse(r.servings ?? '') ?? 0;
          if (s >= 6) return true;
          continue;
        case '__favorites':
          if (r.isFavorite || (r.rating ?? 0) >= 4) return true;
          continue;
        default:
          if (r.courseId?.toLowerCase() == catId.toLowerCase()) return true;
          if (r.categoryId?.toLowerCase() == catId.toLowerCase()) return true;
      }
    }
    return false;
  }

  // ─── Community recipes ─────────────────────────────────────

  Future<List<CravingResult>> _findCommunityRecipes(
    Set<CravingMood> moods,
    Set<String> selectedCategories,
    int limit,
  ) async {
    try {
      final result = await CommunityService.instance.browseRecipes(
        sort: 'random',
        limit: limit,
      );
      if (result == null) return [];

      var recipes = result.recipes;

      // Apply mood filter
      if (moods.isNotEmpty) {
        recipes = recipes.where((r) => _communityMatchesMoods(r, moods)).toList();
      }

      return recipes.take(limit).map((r) {
        final realIngs = r.ingredients.where((i) => i.notes != '__header__').toList();
        return CravingResult(
          id: r.id ?? r.title,
          title: r.title,
          description: r.description,
          imagePath: r.imagePath,
          servings: r.servings,
          prepTimeMinutes: r.prepTimeMinutes,
          cookTimeMinutes: r.cookTimeMinutes,
          courseId: r.courseId,
          isLocal: false,
          cookbookId: r.cookbook.id,
          ingredientNames: realIngs.take(4).map((i) {
            final parts = <String>[];
            if (i.amount != null && i.amount!.isNotEmpty) parts.add(i.amount!);
            if (i.unit != null && i.unit!.isNotEmpty) parts.add(i.unit!);
            parts.add(i.name);
            return parts.join(' ');
          }).toList(),
          totalIngredients: realIngs.length,
          stepTexts: r.steps.take(2).map((s) => s.instruction).toList(),
          totalSteps: r.steps.length,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  bool _communityMatchesMoods(CommunityRecipeFeedItem r, Set<CravingMood> moods) {
    for (final mood in moods) {
      switch (mood) {
        case CravingMood.quick:
          final total = (r.prepTimeMinutes ?? 0) + (r.cookTimeMinutes ?? 0);
          if (total > 0 && total < 30) return true;
        case CravingMood.special:
          if (r.downloadCount > 10) return true; // popular = special for community
        default:
          final courses = _moodCourses[mood] ?? {};
          if (r.courseId != null && courses.contains(r.courseId!.toLowerCase())) return true;
      }
    }
    return false;
  }

  // ─── Helpers ───────────────────────────────────────────────

  List<CravingResult> _interleave(
    List<CravingResult> a,
    List<CravingResult> b,
    int total,
  ) {
    final result = <CravingResult>[];
    final half = total ~/ 2;
    final fromA = a.take(half).toList();
    final fromB = b.take(half).toList();

    // Interleave
    final maxLen = fromA.length > fromB.length ? fromA.length : fromB.length;
    for (var i = 0; i < maxLen; i++) {
      if (i < fromA.length) result.add(fromA[i]);
      if (i < fromB.length) result.add(fromB[i]);
    }

    // Fill remaining from whichever has more
    if (result.length < total) {
      final remaining = total - result.length;
      if (a.length > half) {
        result.addAll(a.skip(half).take(remaining));
      } else if (b.length > half) {
        result.addAll(b.skip(half).take(remaining));
      }
    }

    return result.take(total).toList();
  }
}
