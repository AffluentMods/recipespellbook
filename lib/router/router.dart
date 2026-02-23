import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/barcode_scanner_service.dart';
import '../ui/screens/cookbooks/cookbook_edit_screen.dart';
import '../ui/screens/cookbooks/cookbooks_screen.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/import/import_pdf_screen.dart';
import '../ui/screens/import/transfer_screen.dart';
import '../ui/screens/planner/planner_screen.dart';
import '../ui/screens/premium/paywall_screen.dart';
import '../ui/screens/recipe/categories_browse_screen.dart';
import '../ui/screens/recipe/favorite_recipes_screen.dart';
import '../ui/screens/recipe/quick_access_screen.dart';
import '../ui/screens/recipe/recent_recipes_screen.dart';
import '../ui/screens/recipe/recipe_edit_screen.dart';
import '../ui/screens/recipe/recipe_list_screen.dart';
import '../ui/screens/recipe/recipe_screen.dart';
import '../ui/screens/recipe/uncategorized_recipes_screen.dart';
import '../ui/screens/rpg/rpg_achievements_screen.dart';
import '../ui/screens/rpg/rpg_boss_screen.dart';
import '../ui/screens/rpg/rpg_cosmetics_screen.dart';
import '../ui/screens/rpg/rpg_leaderboard_screen.dart';
// RPG imports
import '../ui/screens/rpg/rpg_profile_screen.dart';
import '../ui/screens/search/search_screen.dart';
import '../ui/screens/settings/allergy_settings_screen.dart';
import '../ui/screens/settings/appearance_screen.dart';
import '../ui/screens/settings/ingredient_substitutions_screen.dart';
import '../ui/screens/settings/manage_categories_screen.dart';
import '../ui/screens/settings/manage_courses_screen.dart';
import '../ui/screens/settings/manage_shopping_categories_screen.dart';
import '../ui/screens/settings/manage_tags_screen.dart';
import '../ui/screens/settings/nutrition_settings_screen.dart';
import '../ui/screens/settings/placeholder_settings_screen.dart';
import '../ui/screens/settings/quick_access_settings_screen.dart';
import '../ui/screens/settings/recipe_layout_settings_screen.dart';
import '../ui/screens/settings/settings_screen.dart';
import '../ui/screens/settings/trash_screen.dart';
import '../ui/screens/shopping/kroger_callback_screen.dart';
import '../ui/screens/shopping/shopping_screen.dart';
import '../ui/screens/splash/splash_screen.dart';
import '../ui/shell/app_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // Search (outside shell)
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    // Filtered recipe list (outside shell)
    GoRoute(
      path: '/recipes',
      name: 'recipe-list',
      builder: (context, state) {
        final courseId = state.uri.queryParameters['course'];
        final categoryId = state.uri.queryParameters['category'];
        final cookbookId = state.uri.queryParameters['cookbook'] ?? 'starter';
        return RecipeListScreen(
          title: 'Recipes',
          cookbookId: cookbookId,
          courseId: courseId,
          categoryId: categoryId,
        );
      },
    ),

    // Browse all categories (categories first)
    GoRoute(
      path: '/categories',
      name: 'categories',
      builder: (context, state) => const CategoriesBrowseScreen(mode: BrowseMode.categories),
    ),

    // Browse all courses (courses first)
    GoRoute(
      path: '/courses',
      name: 'courses',
      builder: (context, state) => const CategoriesBrowseScreen(mode: BrowseMode.courses),
    ),

    // All recipes for a cookbook (View All from categories/courses browse)
    GoRoute(
      path: '/recipes/all',
      name: 'all-recipes',
      builder: (context, state) {
        final cookbookId = state.uri.queryParameters['cookbook'] ?? 'starter';
        return RecipeListScreen(
          title: 'All Recipes',
          cookbookId: cookbookId,
        );
      },
    ),

    // Uncategorized recipes
    GoRoute(
      path: '/recipes/uncategorized',
      name: 'uncategorized-recipes',
      builder: (context, state) => const UncategorizedRecipesScreen(),
    ),

    GoRoute(
      path: '/settings/tags',
      name: 'manage-tags',
      builder: (context, state) => const ManageTagsScreen(),
    ),

    GoRoute(
      path: '/cookbook/:cookbookId/edit',
      name: 'cookbook-edit',
      builder: (context, state) {
        final cookbookId = state.pathParameters['cookbookId']!;
        return CookbookEditScreen(cookbookId: cookbookId);
      },
    ),

    // Recently viewed recipes
    GoRoute(
      path: '/recipes/recent',
      name: 'recent-recipes',
      builder: (context, state) => const RecentRecipesScreen(),
    ),

    GoRoute(
      path: '/settings/appearance',
      name: 'appearance',
      builder: (context, state) => const AppearanceScreen(),
    ),

    GoRoute(
      path: '/settings/allergies',
      name: 'allergy-settings',
      builder: (context, state) => const AllergySettingsScreen(),
    ),

    GoRoute(
      path: '/settings/recipe-layout',
      name: 'recipe-layout',
      builder: (context, state) => const RecipeLayoutSettingsScreen(),
    ),

    GoRoute(
      path: '/settings/nutrition',
      name: 'nutrition-settings',
      builder: (context, state) => const NutritionSettingsScreen(),
    ),

    GoRoute(
      path: '/substitutions',
      name: 'substitutions',
      builder: (context, state) => IngredientSubstitutionsScreen(
        initialSearch: state.uri.queryParameters['q'],
      ),
    ),

    GoRoute(
      path: '/settings/quick-access',
      name: 'quick-access-settings',
      builder: (context, state) => const QuickAccessSettingsScreen(),
    ),

    GoRoute(
      path: '/settings/placeholders',
      name: 'placeholders',
      builder: (context, state) => const PlaceholderSettingsScreen(),
    ),

    GoRoute(
      path: '/settings/courses',
      name: 'manage-courses',
      builder: (context, state) => const ManageCoursesScreen(),
    ),

    GoRoute(
      path: '/settings/categories',
      name: 'manage-categories',
      builder: (context, state) => const ManageCategoriesScreen(),
    ),

    GoRoute(
      path: '/settings/shopping-categories',
      name: 'manage-shopping-categories',
      builder: (context, state) => const ManageShoppingCategoriesScreen(),
    ),

    GoRoute(
      path: '/recipes/quick-access',
      name: 'quick-access',
      builder: (context, state) => const QuickAccessScreen(),
    ),
    GoRoute(
      path: '/recipes/list',
      name: 'recipes-list-extra',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return RecipeListScreen(
          cookbookId: extra?['cookbookId'] ?? 'starter',
          courseId: extra?['courseId'],
          categoryId: extra?['categoryId'],
          title: extra?['title'] ?? 'Recipes',
        );
      },
    ),

    // Favorite recipes
    GoRoute(
      path: '/recipes/favorites',
      name: 'favorite-recipes',
      builder: (context, state) => const FavoriteRecipesScreen(),
    ),

    // ============ RPG ROUTES ============
    GoRoute(
      path: '/rpg/profile',
      name: 'rpg-profile',
      builder: (context, state) => const RpgProfileScreen(),
    ),
    GoRoute(
      path: '/rpg/achievements',
      name: 'rpg-achievements',
      builder: (context, state) => const RpgAchievementsScreen(),
    ),
    GoRoute(
      path: '/rpg/cosmetics',
      name: 'rpg-cosmetics',
      builder: (context, state) => const RpgCosmeticsScreen(),
    ),
    GoRoute(
      path: '/rpg/leaderboard',
      name: 'rpg-leaderboard',
      builder: (context, state) => const RpgLeaderboardScreen(),
    ),
    GoRoute(
      path: '/rpg/boss',
      name: 'rpg-boss',
      builder: (context, state) => const RpgBossScreen(),
    ),
    // ============ END RPG ROUTES ============

    // Main shell with bottom navigation
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/shopping',
          name: 'shopping',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ShoppingScreen(),
          ),
        ),
        GoRoute(
          path: '/cookbooks',
          name: 'cookbooks',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CookbooksScreen(),
          ),
        ),
        GoRoute(
          path: '/planner',
          name: 'planner',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PlannerScreen(),
          ),
        ),
      ],
    ),

    // Import routes (only PDF — other import flows are inline in new_recipe_dialog)
    GoRoute(
      path: '/import/pdf',
      name: 'import-pdf',
      builder: (context, state) => const ImportPdfScreen(),
    ),

    // Barcode scanner
    GoRoute(
      path: '/scan-barcode',
      name: 'scan-barcode',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const BarcodeScannerScreen(),
    ),

    // Kroger OAuth callback (deep link: recipespellbook://kroger-callback?code=XXX)
    GoRoute(
      path: '/kroger-callback',
      name: 'kroger-callback',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final code = state.uri.queryParameters['code'];
        final error = state.uri.queryParameters['error'];
        return KrogerCallbackScreen(authCode: code, error: error);
      },
    ),

    // Settings
    GoRoute(
      path: '/settings',
      name: 'settings',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),

    // Recipe view
    GoRoute(
      path: '/recipe/:id',
      name: 'recipe',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return RecipeScreen(recipeId: id);
      },
    ),

    // ── Upgrade & Transfer — full-screen pushes via rootNavigatorKey ──
    GoRoute(
      path: '/upgrade',
      name: 'upgrade',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const PaywallScreen(),
    ),
    GoRoute(
      path: '/transfer',
      name: 'transfer',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const TransferScreen(),
    ),

    GoRoute(
      path: '/settings/trash',
      name: 'trash',
      builder: (context, state) => const TrashScreen(),
    ),
    // Recipe edit (existing recipe)
    GoRoute(
      path: '/recipe/:id/edit',
      name: 'recipe-edit',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return RecipeEditScreen(recipeId: id);
      },
    ),

    // New recipe (optionally with imported data)
    GoRoute(
      path: '/cookbook/:cookbookId/new-recipe',
      name: 'new-recipe',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final cookbookId = state.pathParameters['cookbookId']!;
        final extra = state.extra as Map<String, dynamic>?;
        return RecipeEditScreen(
          cookbookId: cookbookId,
          importedData: extra,
        );
      },
    ),
  ],
);