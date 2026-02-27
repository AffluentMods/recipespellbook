// lib/providers/hint_provider.dart
// Riverpod provider for tracking tutorial hint display state

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/rpg/rpg_hints.dart';

// ============ HINT STATE ============

class HintState {
  /// Set of hint ID names that have already been shown to the user
  final Set<String> shownHintIds;

  /// The screen the user is currently viewing (for hint filtering)
  final String? currentScreen;

  /// Whether the state is still loading from SharedPreferences
  final bool isLoading;

  /// How many times the app has been opened (persisted across sessions)
  final int appOpenCount;

  const HintState({
    this.shownHintIds = const {},
    this.currentScreen,
    this.isLoading = true,
    this.appOpenCount = 0,
  });

  HintState copyWith({
    Set<String>? shownHintIds,
    String? currentScreen,
    bool? isLoading,
    int? appOpenCount,
  }) {
    return HintState(
      shownHintIds: shownHintIds ?? this.shownHintIds,
      currentScreen: currentScreen ?? this.currentScreen,
      isLoading: isLoading ?? this.isLoading,
      appOpenCount: appOpenCount ?? this.appOpenCount,
    );
  }
}

// ============ HINT NOTIFIER ============

class HintNotifier extends Notifier<HintState> {
  static const _hintsKey = 'shown_hints';
  static const _appOpensKey = 'app_open_count';

  @override
  HintState build() {
    _loadState();
    return const HintState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // Read shown hint IDs (stored as JSON list of strings)
    final hintsJson = prefs.getString(_hintsKey);
    Set<String> shownHintIds = {};
    if (hintsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(hintsJson);
        shownHintIds = decoded.cast<String>().toSet();
      } catch (_) {
        // Corrupted data, start fresh
        shownHintIds = {};
      }
    }

    // Increment app open count
    final previousCount = prefs.getInt(_appOpensKey) ?? 0;
    final newCount = previousCount + 1;
    await prefs.setInt(_appOpensKey, newCount);

    state = state.copyWith(
      shownHintIds: shownHintIds,
      appOpenCount: newCount,
      isLoading: false,
    );
  }

  /// Get the next unshown hint appropriate for the given screen.
  ///
  /// Returns the first [HintDefinition] that:
  ///  - targets [screenName]
  ///  - has not been shown yet
  ///  - has [minAppOpens] <= current open count
  ///
  /// Returns null if no hints are available.
  HintDefinition? getNextHint(String screenName) {
    if (state.isLoading) return null;

    final hintsForScreen = HintDefinition.getHintsForScreen(screenName);

    for (final hint in hintsForScreen) {
      // Skip already-shown hints
      if (state.shownHintIds.contains(hint.id.name)) continue;

      // Skip hints the user hasn't unlocked yet (not enough app opens)
      if (hint.minAppOpens > state.appOpenCount) continue;

      return hint;
    }

    return null;
  }

  /// Mark a hint as shown so it won't appear again
  Future<void> markHintShown(HintId id) async {
    final updatedIds = Set<String>.from(state.shownHintIds)..add(id.name);
    state = state.copyWith(shownHintIds: updatedIds);

    // Persist to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hintsKey, jsonEncode(updatedIds.toList()));
  }

  /// Check whether a specific hint has already been shown
  bool hasBeenShown(HintId id) {
    return state.shownHintIds.contains(id.name);
  }

  /// Update the current screen (useful for auto-triggering hints)
  void setCurrentScreen(String screenName) {
    state = state.copyWith(currentScreen: screenName);
  }

  /// Reset all hints (for testing or user request)
  Future<void> resetAllHints() async {
    state = state.copyWith(shownHintIds: {});

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hintsKey);
  }
}

// ============ PROVIDER ============

final hintProvider = NotifierProvider<HintNotifier, HintState>(() {
  return HintNotifier();
});
