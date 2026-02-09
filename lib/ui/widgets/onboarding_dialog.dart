import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/onboarding_service.dart';
import '../../providers/database_provider.dart';

/// Shows a first-launch dialog asking if the user wants starter recipes.
/// Call this from HomeScreen's initState or after first frame.
Future<void> showOnboardingDialog(BuildContext context, WidgetRef ref) async {
  // Check if we've already offered
  final offered = await OnboardingService.hasOfferedDefaultRecipes();
  if (offered) return;

  if (!context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _OnboardingDialog(ref: ref),
  );
}

class _OnboardingDialog extends StatefulWidget {
  final WidgetRef ref;

  const _OnboardingDialog({required this.ref});

  @override
  State<_OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<_OnboardingDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_fix_high_rounded,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Welcome to Recipe Spellbook!',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            'Want to start with 10 handpicked recipes from around the world? '
                'Korean beef bowls, butter chicken, stuffed peppers, carbonara, and more.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'You can always delete them later.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Recipe preview chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
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
          const SizedBox(height: 8),
        ],
      ),
      actions: [
        // No thanks
        TextButton(
          onPressed: _loading
              ? null
              : () async {
            await OnboardingService.declineDefaultRecipes();
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Text(
            'Start empty',
            style: TextStyle(color: theme.colorScheme.outline),
          ),
        ),

        // Add recipes
        FilledButton.icon(
          onPressed: _loading
              ? null
              : () async {
            setState(() => _loading = true);
            try {
              final db = widget.ref.read(databaseProvider);
              final count = await OnboardingService.seedDefaultRecipes(db);
              await OnboardingService.completeOnboarding();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added $count starter recipes! 🎉'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Something went wrong: $e'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
          icon: _loading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(Icons.add_rounded, size: 18),
          label: Text(_loading ? 'Adding...' : 'Add recipes'),
        ),
      ],
    );
  }
}

class _RecipeChip extends StatelessWidget {
  final String label;
  const _RecipeChip(this.label);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}