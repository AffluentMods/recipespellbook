import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

/// Stream of all cookbooks, auto-updates when data changes
final cookbooksProvider = StreamProvider<List<Cookbook>>((ref) {
  final dao = ref.watch(cookbookDaoProvider);
  return dao.watchAllCookbooks();
});

/// Currently selected cookbook ID — initialized from persisted settings
final selectedCookbookIdProvider = StateProvider<String?>((ref) {
  final settings = ref.read(settingsProvider);
  return settings.currentCookbookId ?? 'starter';
});

/// The currently selected cookbook
final selectedCookbookProvider = Provider<AsyncValue<Cookbook?>>((ref) {
  final selectedId = ref.watch(selectedCookbookIdProvider);
  final cookbooks = ref.watch(cookbooksProvider);

  return cookbooks.when(
    data: (list) {
      final cookbook = list.where((c) => c.id == selectedId).firstOrNull;
      return AsyncValue.data(cookbook);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

/// Recipes in the currently selected cookbook
final recipesInSelectedCookbookProvider = StreamProvider<List<Recipe>>((ref) {
  final selectedId = ref.watch(selectedCookbookIdProvider);
  if (selectedId == null) return Stream.value([]);

  final dao = ref.watch(recipeDaoProvider);
  return dao.watchRecipesForCookbook(selectedId);
});