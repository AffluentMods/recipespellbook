import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../services/onboarding_service.dart';
import '../../widgets/new_recipe_dialog.dart';
import '../book_scan/book_scan_entry.dart';
import '../onboarding/book_intro_screen.dart';
import 'home_desktop.dart';
import 'home_mobile.dart';
import '../../../theme/tokens.dart';
// TODO: Kitchen Buddy hidden for now
// import '../../widgets/kitchen_buddy/kitchen_buddy_integration.dart';
import '../../../utils/responsive_utils.dart';
import '../../../theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static bool _onboardingChecked = false;

  /// Reset the onboarding guard so it triggers again on next build.
  static void resetOnboardingCheck() => _onboardingChecked = false;

  /// Shows the spellbook opening animation for first-time users,
  /// or falls back to the standard onboarding dialog.
  static Future<void> _showOnboarding(BuildContext context, WidgetRef ref) async {
    final offered = await OnboardingService.hasOfferedDefaultRecipes();
    if (offered) return;
    if (!context.mounted) return;

    // Use the ROOT navigator so the onboarding covers the entire screen
    // including the bottom nav bar — prevents accidental dismissal
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (ctx, animation, secondaryAnimation) =>
            const BookIntroScreen(),
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cookbookAsync = ref.watch(selectedCookbookProvider);

    return cookbookAsync.when(
      data: (cookbook) {
        final cookbookId = cookbook?.id ?? 'starter';

        // Trigger onboarding on first launch (once per app session)
        if (!_onboardingChecked) {
          _onboardingChecked = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            FlutterNativeSplash.remove();
            if (context.mounted) {
              _showOnboarding(context, ref);
            }
          });
        }

        // Desktop / pointer layout: a dashboard, not the phone stack.
        if (Responsive.isDesktopLayout(context)) {
          return DesktopHome(
            cookbook: cookbook,
            cookbookId: cookbookId,
            emptyState: _EmptyCookbookState(cookbookId: cookbookId),
          );
        }

        return MobileHome(
          cookbook: cookbook,
          cookbookId: cookbookId,
          emptyState: _EmptyCookbookState(cookbookId: cookbookId),
        );
      },
      loading: () {
        // Remove splash during loading so user sees the spinner if it takes long
        FlutterNativeSplash.remove();
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      error: (e, _) {
        FlutterNativeSplash.remove();
        return Scaffold(body: Center(child: Text('${AppLocalizations.of(context)!.errorGeneric}: $e')));
      },
    );
  }
}

// ============ EMPTY STATE ============

class _EmptyCookbookState extends StatelessWidget {
  final String cookbookId;

  const _EmptyCookbookState({required this.cookbookId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final c = context.appColors;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(color: c.selectedFill, shape: BoxShape.circle),
                child: Icon(Icons.menu_book_rounded, size: 40, color: c.accent),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.emptyStateTitle,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.recipesEmptySubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(color: c.textSecondary, height: 1.45),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => showNewRecipeDialog(context, cookbookId),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.recipeAdd),
                style: FilledButton.styleFrom(minimumSize: const Size(220, 48)),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => showImportDialog(context, cookbookId),
                icon: const Icon(Icons.download_rounded),
                label: Text(l10n.importRecipe),
                style: OutlinedButton.styleFrom(minimumSize: const Size(220, 48)),
              ),
              // A printed cookbook added by its barcode starts out empty:
              // offer to photograph its pages straight away.
              if (supportsBookScan && canAddRecipesTo(cookbookId)) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => startBookScan(context, cookbookId: cookbookId),
                  icon: const Icon(Icons.document_scanner_outlined),
                  label: Text(l10n.bookScanFromBook),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(220, 48)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
