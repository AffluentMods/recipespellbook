import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

/// Stream of all cookbooks, auto-updates when data changes
final cookbooksProvider = StreamProvider<List<Cookbook>>((ref) {
  final dao = ref.watch(cookbookDaoProvider);
  return dao.watchAllCookbooks();
});

/// Currently selected cookbook ID — initialized from persisted settings.
///
/// When the cookbook it names is gone (deleted, left, or deleted on another
/// device) it moves to another one, and that is remembered: new recipes
/// would otherwise go into a cookbook that no longer exists and never show.
final selectedCookbookIdProvider = StateProvider<String?>((ref) {
  final settings = ref.read(settingsProvider);
  ref.listen<AsyncValue<List<Cookbook>>>(cookbooksProvider, (_, next) {
    final list = next.valueOrNull;
    if (list == null || list.isEmpty) return;
    final current = ref.controller.state;
    if (current != null && list.any((c) => c.id == current)) return;
    final fallback = fallbackCookbookId(list, current);
    ref.controller.state = fallback;
    ref.read(settingsProvider.notifier).setCurrentCookbook(fallback);
  });
  return settings.currentCookbookId ?? 'starter';
});

/// The cookbook to show instead of [missing]: the same one under the id
/// sync moved it to, else the starter cookbook, else the first.
String fallbackCookbookId(List<Cookbook> cookbooks, String? missing) {
  if (missing != null) {
    final moved = cookbooks.where((c) => c.id.startsWith('$missing~')).firstOrNull;
    if (moved != null) return moved.id;
  }
  return (cookbooks.where((c) => c.id == 'starter').firstOrNull ?? cookbooks.first).id;
}

/// Reads a provider: `ref.read` of a widget or a provider, or
/// `container.read`.
typedef ProviderRead = T Function<T>(ProviderListenable<T> provider);

/// Delete one of the user's cookbooks (see CookbookDao.deleteCookbook), and
/// when it was the one selected, select another and remember that.
Future<void> deleteCookbookAndMoveOn(ProviderRead read, String cookbookId) async {
  await read(cookbookDaoProvider).deleteCookbook(cookbookId);
  await moveOnFromCookbook(read, cookbookId);
}

/// When [removedId] was the selected cookbook, select another and remember it.
Future<void> moveOnFromCookbook(ProviderRead read, String removedId) async {
  if (read(selectedCookbookIdProvider) != removedId && read(settingsProvider).currentCookbookId != removedId) {
    return;
  }
  final remaining = (await read(cookbookDaoProvider).getAllCookbooks()).where((c) => c.id != removedId).toList();
  final next = remaining.isEmpty ? 'starter' : fallbackCookbookId(remaining, null);
  read(selectedCookbookIdProvider.notifier).state = next;
  await read(settingsProvider.notifier).setCurrentCookbook(next);
}

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