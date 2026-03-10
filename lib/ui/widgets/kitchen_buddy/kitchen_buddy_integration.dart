// lib/ui/widgets/kitchen_buddy/kitchen_buddy_integration.dart
// Static helper to award coins and update achievements from anywhere in the app.
// Replaces RpgIntegration from rpg_navigation_shell.dart.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/kitchen_buddy/kitchen_buddy_models.dart';
import '../../../providers/kitchen_buddy_provider.dart';

class KitchenBuddyIntegration {
  KitchenBuddyIntegration._();

  // ── Coin awards ──

  static void onRecipeSaved(WidgetRef ref) {
    ref.read(kitchenBuddyProvider.notifier).earnCoins(CoinAction.saveRecipe);
  }

  static void onRecipeImported(WidgetRef ref) {
    ref.read(kitchenBuddyProvider.notifier).earnCoins(CoinAction.importRecipe);
  }

  static void onRecipeCooked(WidgetRef ref) {
    ref.read(kitchenBuddyProvider.notifier).earnCoins(CoinAction.cookRecipe);
  }

  static void onRecipeShared(WidgetRef ref) {
    ref.read(kitchenBuddyProvider.notifier).earnCoins(CoinAction.shareRecipe);
  }

  static void onCookbookPublished(WidgetRef ref) {
    ref.read(kitchenBuddyProvider.notifier).earnCoins(CoinAction.publishCookbook);
  }

  static void onMealPlanCompleted(WidgetRef ref) {
    ref.read(kitchenBuddyProvider.notifier).earnCoins(CoinAction.completeMealPlan);
  }

  // ── Achievement progress updates ──

  static void updateRecipeCount(WidgetRef ref, int count) {
    final notifier = ref.read(kitchenBuddyProvider.notifier);
    notifier.setProgress('ach_recipes_1', count);
    notifier.setProgress('ach_recipes_10', count);
    notifier.setProgress('ach_recipes_50', count);
    notifier.setProgress('ach_recipes_100', count);
    notifier.setProgress('ach_recipes_250', count);
    notifier.setProgress('ach_recipes_500', count);
  }

  static void updateImportCount(WidgetRef ref, int count) {
    final notifier = ref.read(kitchenBuddyProvider.notifier);
    notifier.setProgress('ach_import_1', count);
    notifier.setProgress('ach_import_25', count);
    notifier.setProgress('ach_import_100', count);
  }

  static void updateCookCount(WidgetRef ref, int count) {
    final notifier = ref.read(kitchenBuddyProvider.notifier);
    notifier.setProgress('ach_cook_1', count);
    notifier.setProgress('ach_cook_10', count);
    notifier.setProgress('ach_cook_50', count);
    notifier.setProgress('ach_cook_100', count);
    notifier.setProgress('ach_cook_500', count);
  }

  static void updatePhotoCount(WidgetRef ref, int count) {
    final notifier = ref.read(kitchenBuddyProvider.notifier);
    notifier.setProgress('ach_photos_10', count);
    notifier.setProgress('ach_photos_50', count);
  }

  static void updateUploadCount(WidgetRef ref, int count) {
    final notifier = ref.read(kitchenBuddyProvider.notifier);
    notifier.setProgress('ach_upload_1', count);
    notifier.setProgress('ach_upload_5', count);
    notifier.setProgress('ach_upload_10', count);
  }

  static void updateDownloadCount(WidgetRef ref, int count) {
    final notifier = ref.read(kitchenBuddyProvider.notifier);
    notifier.setProgress('ach_downloads_10', count);
    notifier.setProgress('ach_downloads_50', count);
    notifier.setProgress('ach_downloads_100', count);
    notifier.setProgress('ach_downloads_500', count);
  }

  static void updateCookbookCount(WidgetRef ref, int count) {
    final notifier = ref.read(kitchenBuddyProvider.notifier);
    notifier.setProgress('ach_cookbooks_3', count);
    notifier.setProgress('ach_cookbooks_10', count);
  }

  static void updateShoppingCompleteCount(WidgetRef ref, int count) {
    ref.read(kitchenBuddyProvider.notifier).setProgress('ach_shopping_complete', count);
  }

  static void updateMealPlanDays(WidgetRef ref, int count) {
    ref.read(kitchenBuddyProvider.notifier).setProgress('ach_meal_plan_week', count);
  }

  static void updateTagCount(WidgetRef ref, int count) {
    ref.read(kitchenBuddyProvider.notifier).setProgress('ach_tags_used', count);
  }

  static void updateNutritionCount(WidgetRef ref, int count) {
    ref.read(kitchenBuddyProvider.notifier).setProgress('ach_nutrition_10', count);
  }

  static void incrementImportMethodUsed(WidgetRef ref) {
    ref.read(kitchenBuddyProvider.notifier).incrementProgress('ach_all_import_methods');
  }
}
