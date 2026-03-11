import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/database_provider.dart';
import '../../services/onboarding_service.dart';
import 'app_snackbar.dart';

/// Shows a first-launch onboarding screen asking if the user wants starter recipes.
/// Call this from HomeScreen's initState or after first frame.
Future<void> showOnboardingDialog(BuildContext context, WidgetRef ref) async {
  // Check if we've already offered
  final offered = await OnboardingService.hasOfferedDefaultRecipes();
  if (offered) return;

  if (!context.mounted) return;

  // Use a full-screen modal route instead of a dialog
  await Navigator.of(context).push(
    PageRouteBuilder(
      opaque: true,
      pageBuilder: (ctx, animation, secondaryAnimation) =>
          _OnboardingScreen(ref: ref),
      transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
          child: child,
        );
      },
    ),
  );
}

class _OnboardingScreen extends StatefulWidget {
  final WidgetRef ref;

  const _OnboardingScreen({required this.ref});

  @override
  State<_OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<_OnboardingScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),

                // App logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/icon.png',
                    width: 100,
                    height: 100,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  l10n.onboardingWelcomeTo,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  l10n.onboardingAppName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  l10n.onboardingDescription,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Recipe preview chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: const [
                    _RecipeChip('🇰🇷 Korean Beef Bowls'),
                    _RecipeChip('🇵🇪 Lomo Saltado'),
                    _RecipeChip('🇮🇳 Butter Chicken'),
                    _RecipeChip('🥟 Eggroll Bowl'),
                    _RecipeChip('🇮🇹 Carbonara'),
                    _RecipeChip('🍕 White Pizza'),
                    _RecipeChip('🍤 Tuscan Shrimp'),
                    _RecipeChip('🥣 Chicken Gnocchi'),
                    _RecipeChip('🌮 Street Tacos'),
                    _RecipeChip('🌶️ Stuffed Peppers'),
                  ],
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  l10n.onboardingDeleteLater,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Add recipes button (primary)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _addRecipes,
                    icon: _loading
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.auto_fix_high_rounded, size: 20),
                    label: Text(
                      _loading ? l10n.onboardingAdding : l10n.onboardingAddStarter,
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Start empty (secondary)
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _loading ? null : _startEmpty,
                    child: Text(
                      l10n.onboardingBlankCookbook,
                      style: TextStyle(
                        color: theme.colorScheme.outline,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addRecipes() async {
    setState(() => _loading = true);
    try {
      final db = widget.ref.read(databaseProvider);
      final count = await OnboardingService.seedDefaultRecipes(db);
      await OnboardingService.completeOnboarding();
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, AppLocalizations.of(context)!.starterRecipesAdded(count));
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.error(context, AppLocalizations.of(context)!.somethingWentWrong(e.toString()));
      }
    }
  }

  Future<void> _startEmpty() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.onboardingBlankConfirmTitle),
        content: Text(l10n.onboardingBlankConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.onboardingBlankConfirmYes),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await OnboardingService.declineDefaultRecipes();
      if (mounted) Navigator.of(context).pop();
    }
  }
}

class _RecipeChip extends StatelessWidget {
  final String label;
  const _RecipeChip(this.label);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}