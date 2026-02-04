import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/shell/app_shell.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/planner/planner_screen.dart';
import '../ui/screens/shopping/shopping_screen.dart';
import '../ui/screens/recipe/recipe_screen.dart';
import '../ui/screens/recipe/recipe_edit_screen.dart';
import '../ui/screens/recipe/recipe_list_screen.dart';
import '../ui/screens/recipe/categories_browse_screen.dart';
import '../ui/screens/recipe/favorite_recipes_screen.dart';
import '../ui/screens/recipe/recent_recipes_screen.dart';
import '../ui/screens/cookbooks/cookbooks_screen.dart';
import '../ui/screens/cookbooks/cookbook_edit_screen.dart';
import '../ui/screens/settings/settings_screen.dart';
import '../ui/screens/settings/appearance_screen.dart';
import '../ui/screens/settings/allergy_settings_screen.dart';
import '../ui/screens/settings/manage_shopping_categories_screen.dart';
import '../ui/screens/settings/manage_courses_screen.dart';
import '../ui/screens/settings/manage_categories_screen.dart';
import '../ui/screens/settings/recipe_layout_settings_screen.dart';
import '../ui/screens/settings/trash_screen.dart';
import '../ui/screens/import/import_url_screen.dart';
import '../ui/screens/import/import_scan_screen.dart';
import '../ui/screens/import/import_text_screen.dart';
import '../ui/screens/import/import_pdf_screen.dart';
import '../ui/screens/import/import_guides_screen.dart';
import '../ui/screens/search/search_screen.dart';
import '../ui/widgets/cooking_mode_screen.dart';
import '../ui/screens/rpg/rpg_profile_screen.dart';
import '../ui/screens/rpg/rpg_achievements_screen.dart';
import '../ui/screens/rpg/rpg_cosmetics_screen.dart';
import '../../ui/screens/rpg/rpg_profile_screen.dart';
import '../../ui/screens/rpg/rpg_achievements_screen.dart';
import '../../ui/screens/rpg/rpg_cosmetics_screen.dart';
import '../../ui/screens/rpg/rpg_leaderboard_screen.dart';
import '../../ui/screens/rpg/rpg_boss_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Main shell with bottom nav
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        // Home tab
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        // Planner tab
        GoRoute(
          path: '/planner',
          name: 'planner',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PlannerScreen(),
          ),
        ),
        // Shopping tab
        GoRoute(
          path: '/shopping',
          name: 'shopping',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ShoppingScreen(),
          ),
        ),
      ],
    ),

    // RPG Profile - Main hub
    GoRoute(
      path: '/rpg/profile',
      name: 'rpgProfile',
      builder: (context, state) => const RpgProfileScreen(),
    ),

// RPG Achievements - Browse and track achievements
    GoRoute(
      path: '/rpg/achievements',
      name: 'rpgAchievements',
      builder: (context, state) => const RpgAchievementsScreen(),
    ),

// RPG Cosmetics - Shop and equip items
    GoRoute(
      path: '/rpg/cosmetics',
      name: 'rpgCosmetics',
      builder: (context, state) => const RpgCosmeticsScreen(),
    ),

// RPG Leaderboard - Stats and rankings
    GoRoute(
      path: '/rpg/leaderboard',
      name: 'rpgLeaderboard',
      builder: (context, state) => const RpgLeaderboardScreen(),
    ),

// RPG Boss Fight - Combat system
    GoRoute(
      path: '/rpg/boss',
      name: 'rpgBoss',
      builder: (context, state) => const RpgBossScreen(),
    ),

    GoRoute(
      path: '/rpg/profile',
      name: 'rpgProfile',
      builder: (context, state) => const RpgProfileScreen(),
    ),
    GoRoute(
      path: '/rpg/achievements',
      name: 'rpgAchievements',
      builder: (context, state) => const RpgAchievementsScreen(),
    ),
    GoRoute(
      path: '/rpg/cosmetics',
      name: 'rpgCosmetics',
      builder: (context, state) => const RpgCosmeticsScreen(),
    ),
    GoRoute(
      path: '/rpg/leaderboard',
      name: 'rpgLeaderboard',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('🏆 Leaderboard')),
        body: const Center(child: Text('Coming soon!')),
      ),
    ),
    GoRoute(
      path: '/rpg/boss',
      name: 'rpgBoss',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('⚔️ Boss Fight')),
        body: const Center(child: Text('Coming soon!')),
      ),
    ),

    // Recipe routes (outside shell for full-screen experience)
    GoRoute(
      path: '/recipe/:id',
      name: 'recipe',
      builder: (context, state) => RecipeScreen(
        recipeId: state.pathParameters['id']!,
      ),
      routes: [
        GoRoute(
          path: 'edit',
          name: 'recipe-edit',
          builder: (context, state) => RecipeEditScreen(
            recipeId: state.pathParameters['id'],
          ),
        ),
        GoRoute(
          path: 'cook',
          name: 'recipe-cook',
          builder: (context, state) => CookingModeScreen(
            recipeId: state.pathParameters['id']!,
          ),
        ),
      ],
    ),

    // New recipe
    GoRoute(
      path: '/recipe/new',
      name: 'recipe-new',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return RecipeEditScreen(
          recipeId: null,
          importedData: extra?['importedData'],
        );
      },
    ),

    // Recipe list - requires cookbookId and title
    GoRoute(
      path: '/recipes',
      name: 'recipes',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return RecipeListScreen(
          cookbookId: extra?['cookbookId'] ?? 'starter',
          title: extra?['title'] ?? 'Recipes',
          courseId: extra?['courseId'],
          categoryId: extra?['categoryId'],
          showAllRecipes: extra?['showAllRecipes'] ?? false,
        );
      },
    ),

    // Cookbooks
    GoRoute(
      path: '/cookbooks',
      name: 'cookbooks',
      builder: (context, state) => const CookbooksScreen(),
      routes: [
        GoRoute(
          path: ':id/edit',
          name: 'cookbook-edit',
          builder: (context, state) => CookbookEditScreen(
            cookbookId: state.pathParameters['id'],
          ),
        ),
        GoRoute(
          path: 'new',
          name: 'cookbook-new',
          builder: (context, state) => const CookbookEditScreen(),
        ),
      ],
    ),

    // Browse routes - CategoriesBrowseScreen requires mode parameter
    GoRoute(
      path: '/browse/categories',
      name: 'browse-categories',
      builder: (context, state) => const CategoriesBrowseScreen(
        mode: BrowseMode.categories,
      ),
    ),
    GoRoute(
      path: '/browse/courses',
      name: 'browse-courses',
      builder: (context, state) => const CategoriesBrowseScreen(
        mode: BrowseMode.courses,
      ),
    ),
    GoRoute(
      path: '/browse/favorites',
      name: 'browse-favorites',
      builder: (context, state) => const FavoriteRecipesScreen(),
    ),
    GoRoute(
      path: '/browse/recent',
      name: 'browse-recent',
      builder: (context, state) => const RecentRecipesScreen(),
    ),

    // Search
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),

    // Import routes - ImportUrlScreen has no parameters
    GoRoute(
      path: '/import/url',
      name: 'import-url',
      builder: (context, state) => const ImportUrlScreen(),
    ),
    GoRoute(
      path: '/import/scan',
      name: 'import-scan',
      builder: (context, state) => const ImportScanScreen(),
    ),
    GoRoute(
      path: '/import/text',
      name: 'import-text',
      builder: (context, state) => const ImportTextScreen(),
    ),
    GoRoute(
      path: '/import/pdf',
      name: 'import-pdf',
      builder: (context, state) => const ImportPdfScreen(),
    ),
    GoRoute(
      path: '/import-guides',
      name: 'import-guides',
      builder: (context, state) => const ImportGuidesScreen(),
    ),

    // Settings routes
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'appearance',
          name: 'settings-appearance',
          builder: (context, state) => const AppearanceScreen(),
        ),
        GoRoute(
          path: 'allergies',
          name: 'settings-allergies',
          builder: (context, state) => const AllergySettingsScreen(),
        ),
        GoRoute(
          path: 'recipe-layout',
          name: 'settings-recipe-layout',
          builder: (context, state) => const RecipeLayoutSettingsScreen(),
        ),
        GoRoute(
          path: 'shopping-categories',
          name: 'settings-shopping-categories',
          builder: (context, state) => const ManageShoppingCategoriesScreen(),
        ),
        GoRoute(
          path: 'courses',
          name: 'settings-courses',
          builder: (context, state) => const ManageCoursesScreen(),
        ),
        GoRoute(
          path: 'categories',
          name: 'settings-categories',
          builder: (context, state) => const ManageCategoriesScreen(),
        ),
        GoRoute(
          path: 'trash',
          name: 'settings-trash',
          builder: (context, state) => const TrashScreen(),
        ),
      ],
    ),
  ],
);

/// Extension to add typed extra data
extension GoRouterExtraExtension on GoRouter {
  void goWithExtra(String location, {Object? extra}) {
    go(location, extra: extra);
  }
}