// lib/services/recipe_suggestion_service.dart
// "What's for dinner?" decision engine
//
// Picks a handful of the user's own recipes for tonight, each with the reason
// it was picked: everything is in the pantry, a favourite not made in weeks,
// one or two things to buy, quick on a weeknight, or not cooked in a while.
// Recipes already planned for the week and ones made or opened lately are
// left out. Dependency-free and offline: it works from the reduced recipe
// library and pantry ranking ("What can I make?"), planner history and the
// cooking-mode history.

import 'dart:math';

import 'pantry_cooking_service.dart';

/// Why a recipe is suggested.
enum DinnerReasonKind {
  /// Nothing to buy.
  allInPantry,

  /// A favourite last made [DinnerReason.value] weeks ago.
  favouriteNotLately,

  /// A favourite with no record of being made.
  favourite,

  /// [DinnerReason.value] things to buy (one or two).
  almostInPantry,

  /// Ready in [DinnerReason.value] minutes.
  quick,

  /// Last made [DinnerReason.value] weeks ago.
  lastMade,

  /// Last opened [DinnerReason.value] weeks ago, never made.
  notOpened,

  /// Rated [DinnerReason.value] stars.
  highlyRated,

  /// Never opened or made.
  notTriedYet,

  /// No particular reason beyond being one of the user's recipes.
  fromLibrary,
}

class DinnerReason {
  final DinnerReasonKind kind;

  /// Weeks, minutes, things to buy or stars, depending on [kind].
  final int value;

  const DinnerReason(this.kind, [this.value = 0]);

  @override
  bool operator ==(Object other) =>
      other is DinnerReason && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);

  @override
  String toString() => '${kind.name}($value)';
}

/// One suggested recipe and why.
class DinnerSuggestion {
  final PantryRecipeMatch match;
  final DinnerReason reason;
  final double score;

  const DinnerSuggestion({
    required this.match,
    required this.reason,
    required this.score,
  });

  LibraryRecipe get recipe => match.recipe;
}

class _Candidate {
  final PantryRecipeMatch match;
  final Map<DinnerReasonKind, (DinnerReason, double)> reasons;
  final bool recent;
  double score = 0;

  _Candidate(this.match, this.reasons, {required this.recent});

  (DinnerReason, double)? get best {
    (DinnerReason, double)? top;
    for (final r in reasons.values) {
      if (top == null || r.$2 > top.$2) top = r;
    }
    return top;
  }
}

class RecipeSuggestionService {
  RecipeSuggestionService._();

  /// The most suggestions shown at once.
  static const maxSuggestions = 6;

  /// Opened or made within this many days: not "long ago".
  static const recentDays = 7;

  /// A favourite not made for this many days is worth bringing back.
  static const favouriteGapDays = 21;

  /// Any other recipe not made or opened for this many days.
  static const rediscoverDays = 28;

  /// Ready in this many minutes or less is quick.
  static const quickMinutes = 30;

  /// Courses that are not a dinner dish.
  static const _notDinner = {'beverage', 'breakfast', 'brunch', 'dessert', 'sauce', 'snack'};

  /// Suggest up to [maxCount] recipes for dinner.
  ///
  /// [matches] is every recipe checked against the pantry (see
  /// [rankRecipesByPantry]). [plannedIds] holds recipe ids already planned
  /// around the day; a recipe is left out when any copy of it is planned.
  /// [lastMade] maps recipe ids to when they were last made (cooking mode or
  /// a past planner meal). [seed] fixes the shuffle, so the picks hold still
  /// until the user asks for others; [skipIds] (the picks shown before) are
  /// pushed back on a reshuffle.
  static List<DinnerSuggestion> suggestDinner({
    required List<PantryRecipeMatch> matches,
    required bool pantryEmpty,
    required DateTime now,
    Set<String> plannedIds = const {},
    Map<String, DateTime> lastMade = const {},
    int seed = 0,
    Set<String> skipIds = const {},
    int maxCount = maxSuggestions,
  }) {
    final random = Random(seed);
    final weeknight = now.weekday <= DateTime.friday;
    final candidates = <_Candidate>[];

    for (final m in matches) {
      final r = m.recipe;
      if (r.copyIds.any(plannedIds.contains)) continue;
      final course = r.courseKey;
      if (course != null && _notDinner.contains(course)) continue;

      DateTime? made;
      for (final id in r.copyIds) {
        final d = lastMade[id];
        if (d != null && (made == null || d.isAfter(made))) made = d;
      }
      final viewed = r.lastViewedAt;
      final seen = _latest(made, viewed);
      final daysMade = made == null ? null : now.difference(made).inDays;
      final daysSeen = seen == null ? null : now.difference(seen).inDays;

      final reasons = <DinnerReasonKind, (DinnerReason, double)>{};
      void add(DinnerReasonKind kind, int value, double strength) =>
          reasons[kind] = (DinnerReason(kind, value), strength);

      if (!pantryEmpty && m.readyNow && m.counted >= 2) {
        add(DinnerReasonKind.allInPantry, 0, 3.0);
      }
      if (r.isFavorite) {
        if (daysMade != null && daysMade >= favouriteGapDays) {
          add(DinnerReasonKind.favouriteNotLately, daysMade ~/ 7, 2.6);
        } else if (made == null && (daysSeen == null || daysSeen >= favouriteGapDays)) {
          add(DinnerReasonKind.favourite, 0, 2.0);
        }
      }
      if (!pantryEmpty &&
          m.missingCount >= 1 &&
          m.missingCount <= 2 &&
          m.counted >= 3 &&
          m.share >= 0.6) {
        add(DinnerReasonKind.almostInPantry, m.missingCount, 1.6);
      }
      final minutes = r.totalMinutes;
      if (minutes != null && minutes <= quickMinutes) {
        add(DinnerReasonKind.quick, minutes, weeknight ? 1.4 : 0.9);
      }
      if (!r.isFavorite) {
        if (daysMade != null && daysMade >= rediscoverDays) {
          add(DinnerReasonKind.lastMade, daysMade ~/ 7, 1.3);
        } else if (made == null && daysSeen != null && daysSeen >= rediscoverDays) {
          add(DinnerReasonKind.notOpened, daysSeen ~/ 7, 1.0);
        }
      }
      final rating = r.recipe.rating ?? 0;
      if (rating >= 4) add(DinnerReasonKind.highlyRated, rating, 0.8);
      if (seen == null) add(DinnerReasonKind.notTriedYet, 0, 0.5);

      final c = _Candidate(m, reasons, recent: daysSeen != null && daysSeen < recentDays);
      final best = c.best?.$2 ?? 0;
      final others = reasons.values.fold<double>(0, (sum, r) => sum + r.$2) - best;
      c.score = best +
          others * 0.35 +
          (pantryEmpty ? 0 : m.share * 0.8) +
          (course == 'main' ? 0.3 : 0) +
          random.nextDouble() * 1.2 -
          (r.copyIds.any(skipIds.contains) ? 3.0 : 0);
      candidates.add(c);
    }

    // "Not lately": leave out what was made or opened this week, unless that
    // leaves too little to choose from.
    final settled = candidates.where((c) => !c.recent).toList();
    final pool = settled.length >= 3 ? settled : candidates;
    pool.sort((a, b) => b.score.compareTo(a.score));

    final picks = <DinnerSuggestion>[];
    final picked = <String>{};
    void take(_Candidate c, DinnerReason reason) {
      picked.add(c.match.recipe.id);
      picks.add(DinnerSuggestion(match: c.match, reason: reason, score: c.score));
    }

    // A mix: the best recipe for each kind of reason first, then the
    // highest scores.
    const mix = [
      DinnerReasonKind.allInPantry,
      DinnerReasonKind.favouriteNotLately,
      DinnerReasonKind.almostInPantry,
      DinnerReasonKind.quick,
      DinnerReasonKind.lastMade,
      DinnerReasonKind.favourite,
      DinnerReasonKind.notOpened,
    ];
    for (final kind in mix) {
      if (picks.length >= maxCount) break;
      for (final c in pool) {
        if (picked.contains(c.match.recipe.id)) continue;
        final reason = c.reasons[kind];
        if (reason == null) continue;
        take(c, reason.$1);
        break;
      }
    }
    for (final c in pool) {
      if (picks.length >= maxCount) break;
      if (picked.contains(c.match.recipe.id)) continue;
      take(c, c.best?.$1 ?? const DinnerReason(DinnerReasonKind.fromLibrary));
    }
    return picks;
  }

  static DateTime? _latest(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }
}
