import 'dart:async';

/// How long a recipe has to stay open before it counts as viewed ("Jump back
/// in", the recently viewed lists). A quick look in and out does not count.
const recipeViewedAfter = Duration(seconds: 3);

/// Calls [onViewed] for a recipe once it has been on screen for [delay].
///
/// The page showing the recipe starts it, starts it again with the new id if
/// it switches to another recipe, and cancels it when it goes away.
class RecipeViewTimer {
  RecipeViewTimer(this.onViewed, {this.delay = recipeViewedAfter});

  final void Function(String recipeId) onViewed;
  final Duration delay;
  Timer? _timer;

  /// Starts counting for [recipeId], dropping a count already running.
  void start(String recipeId) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      _timer = null;
      onViewed(recipeId);
    });
  }

  /// Stops counting; nothing is stamped.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
