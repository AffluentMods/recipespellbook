import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// When the user last cooked each recipe, on this device: recorded when they
/// finish cooking mode. Dinner suggestions read it (with past planner meals)
/// to bring back favourites that have not been made in a while.
///
/// Kept in shared preferences, not the database: it is a small, per-device
/// history that does not sync.
class CookHistoryService {
  CookHistoryService._();

  static const _key = 'cook_history_v1';

  /// The most recipes remembered; the oldest are dropped first.
  static const maxEntries = 600;

  /// Recipe id to the last time it was cooked.
  static Future<Map<String, DateTime>> lastCooked() async {
    final prefs = await SharedPreferences.getInstance();
    return _decode(prefs.getString(_key));
  }

  /// Note that [recipeId] was cooked [at] (now by default).
  static Future<void> recordCooked(String recipeId, {DateTime? at}) async {
    final prefs = await SharedPreferences.getInstance();
    final history = _decode(prefs.getString(_key));
    history[recipeId] = at ?? DateTime.now();
    final entries = history.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    await prefs.setString(_key, jsonEncode({
      for (final e in entries.take(maxEntries)) e.key: e.value.millisecondsSinceEpoch,
    }));
  }

  static Map<String, DateTime> _decode(String? json) {
    if (json == null || json.isEmpty) return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return {
        for (final e in map.entries)
          if (e.value is int) e.key: DateTime.fromMillisecondsSinceEpoch(e.value as int),
      };
    } catch (_) {
      return {};
    }
  }
}
