import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../services/barcode_scanner_service.dart';
import '../ui/screens/cookbooks/cookbook_edit_screen.dart';
import '../ui/screens/cookbooks/cookbooks_screen.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/import/transfer_screen.dart';
import '../ui/screens/planner/planner_screen.dart';
import '../ui/screens/premium/family_screen.dart';
import '../ui/screens/premium/paywall_screen.dart';
import '../ui/screens/recipe/categories_browse_screen.dart';
import '../ui/screens/recipe/favorite_recipes_screen.dart';
import '../ui/screens/recipe/quick_access_screen.dart';
import '../ui/screens/recipe/recent_recipes_screen.dart';
import '../ui/screens/recipe/recipe_edit_screen.dart';
import '../ui/screens/recipe/recipe_list_screen.dart';
import '../ui/screens/recipe/recipe_screen.dart';
import '../ui/screens/recipe/uncategorized_recipes_screen.dart';
// TODO: Kitchen Buddy hidden for now
// import '../ui/screens/kitchen_buddy/kitchen_buddy_screen.dart';
// import '../ui/screens/kitchen_buddy/buddy_naming_screen.dart';
import '../ui/screens/search/search_screen.dart';
import '../ui/screens/settings/about_screen.dart';
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
import '../ui/screens/settings/ingredient_layout_settings_screen.dart';
import '../ui/screens/settings/notification_settings_screen.dart';
import '../ui/screens/settings/account_screen.dart';
import '../ui/screens/settings/settings_screen.dart';
import '../ui/screens/notifications/notifications_screen.dart';
import '../ui/screens/community/community_screen.dart';
import '../ui/screens/community/community_detail_screen.dart';
import '../ui/screens/community/community_publish_screen.dart';
import '../ui/screens/community/community_my_publications_screen.dart';
import '../ui/screens/community/community_recipe_full_screen.dart';
import '../ui/screens/community/creator_profile_screen.dart';
import '../services/community_service.dart' show CommunityRecipe;
import '../ui/screens/settings/trash_screen.dart';
import '../ui/screens/shopping/kroger_callback_screen.dart';
import '../ui/screens/shopping/shopping_screen.dart';
import '../ui/screens/share/share_viewer_screen.dart';
import '../ui/screens/splash/splash_screen.dart';
import '../ui/shell/app_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // ── Screens OUTSIDE the shell (truly modal / fullscreen) ──
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Share link viewer (public, no auth required)
    GoRoute(
      path: '/s/:code',
      name: 'share-viewer',
      builder: (context, state) {
        final code = state.pathParameters['code']!;
        return ShareViewerScreen(code: code);
      },
    ),

    // Recipe edit (fullscreen modal — no sidebar)
    GoRoute(
      path: '/recipe/:id/edit',
      name: 'recipe-edit',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return RecipeEditScreen(recipeId: id);
      },
    ),

    // New recipe (fullscreen modal — no sidebar)
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

    // Upgrade paywall (fullscreen modal)
    GoRoute(
      path: '/upgrade',
      name: 'upgrade',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const PaywallScreen(),
    ),

    // Transfer data (fullscreen modal)
    GoRoute(
      path: '/transfer',
      name: 'transfer',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const TransferScreen(),
    ),

    // Barcode scanner (fullscreen camera)
    GoRoute(
      path: '/scan-barcode',
      name: 'scan-barcode',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const BarcodeScannerScreen(),
    ),

    // Kroger OAuth callback
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

    // Notifications (fullscreen overlay)
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NotificationsScreen(),
    ),

    // ═══════════════════════════════════════════════════════
    // SHELL ROUTE — sidebar/nav-rail/bottom-nav visible
    // All screens that should show the sidebar on desktop
    // ═══════════════════════════════════════════════════════
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        // ── Main tabs (no transition animation) ──
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

        // ── Recipe browse screens (sidebar visible) ──
        GoRoute(
          path: '/recipes',
          name: 'recipe-list',
          builder: (context, state) {
            final courseId = state.uri.queryParameters['course'];
            final categoryId = state.uri.queryParameters['category'];
            final cookbookId = state.uri.queryParameters['cookbook'] ?? 'starter';
            final l10n = AppLocalizations.of(context)!;
            return RecipeListScreen(
              title: l10n.recipesTitle,
              cookbookId: cookbookId,
              courseId: courseId,
              categoryId: categoryId,
            );
          },
        ),
        GoRoute(
          path: '/recipes/all',
          name: 'all-recipes',
          builder: (context, state) {
            final cookbookId = state.uri.queryParameters['cookbook'] ?? 'starter';
            final l10n = AppLocalizations.of(context)!;
            return RecipeListScreen(
              title: l10n.browseViewAll,
              cookbookId: cookbookId,
            );
          },
        ),
        GoRoute(
          path: '/recipes/uncategorized',
          name: 'uncategorized-recipes',
          builder: (context, state) => const UncategorizedRecipesScreen(),
        ),
        GoRoute(
          path: '/recipes/recent',
          name: 'recent-recipes',
          builder: (context, state) => const RecentRecipesScreen(),
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
        GoRoute(
          path: '/recipes/favorites',
          name: 'favorite-recipes',
          builder: (context, state) => const FavoriteRecipesScreen(),
        ),

        // ── Category/Course browse (sidebar visible) ──
        GoRoute(
          path: '/categories',
          name: 'categories',
          builder: (context, state) => const CategoriesBrowseScreen(mode: BrowseMode.categories),
        ),
        GoRoute(
          path: '/courses',
          name: 'courses',
          builder: (context, state) => const CategoriesBrowseScreen(mode: BrowseMode.courses),
        ),

        // ── Recipe detail view (sidebar visible on desktop) ──
        GoRoute(
          path: '/recipe/:id',
          name: 'recipe',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return RecipeScreen(recipeId: id);
          },
        ),

        // ── Search (sidebar visible) ──
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (context, state) => const SearchScreen(),
        ),

        // ── Substitutions (sidebar visible) ──
        GoRoute(
          path: '/substitutions',
          name: 'substitutions',
          builder: (context, state) => IngredientSubstitutionsScreen(
            initialSearch: state.uri.queryParameters['q'],
          ),
        ),

        // ── Cookbook edit (sidebar visible) ──
        GoRoute(
          path: '/cookbook/:cookbookId/edit',
          name: 'cookbook-edit',
          builder: (context, state) {
            final cookbookId = state.pathParameters['cookbookId']!;
            return CookbookEditScreen(cookbookId: cookbookId);
          },
        ),

        // ── Community (sidebar visible) ──
        GoRoute(
          path: '/community',
          name: 'community',
          builder: (context, state) => const CommunityScreen(),
        ),
        GoRoute(
          path: '/community/publish',
          name: 'community-publish',
          builder: (context, state) => const CommunityPublishScreen(),
        ),
        GoRoute(
          path: '/community/my-publications',
          name: 'community-my-publications',
          builder: (context, state) => const CommunityMyPublicationsScreen(),
        ),
        GoRoute(
          path: '/community/creator/:userId',
          name: 'creator-profile',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return CreatorProfileScreen(userId: userId);
          },
        ),
        GoRoute(
          path: '/community/:id',
          name: 'community-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return CommunityDetailScreen(publicationId: id);
          },
        ),
        GoRoute(
          path: '/community/:id/recipe/:index',
          name: 'community-recipe',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final recipe = state.extra as CommunityRecipe;
            return CommunityRecipeFullScreen(
              publicationId: id,
              recipe: recipe,
            );
          },
        ),

        // ── Settings (sidebar visible) ──
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/settings/account',
          name: 'account',
          builder: (context, state) => const AccountScreen(),
        ),
        GoRoute(
          path: '/settings/tags',
          name: 'manage-tags',
          builder: (context, state) => const ManageTagsScreen(),
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
          path: '/settings/ingredient-layout',
          name: 'ingredient-layout',
          builder: (context, state) => const IngredientLayoutSettingsScreen(),
        ),
        GoRoute(
          path: '/settings/nutrition',
          name: 'nutrition-settings',
          builder: (context, state) => const NutritionSettingsScreen(),
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
          path: '/settings/trash',
          name: 'trash',
          builder: (context, state) => const TrashScreen(),
        ),
        GoRoute(
          path: '/settings/family',
          name: 'family',
          builder: (context, state) => const FamilyScreen(),
        ),
        GoRoute(
          path: '/settings/notifications',
          name: 'notification-settings',
          builder: (context, state) => const NotificationSettingsScreen(),
        ),
        GoRoute(
          path: '/about',
          name: 'about',
          builder: (context, state) => const AboutScreen(),
        ),
      ],
    ),
  ],
);
