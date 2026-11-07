import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/pantry_cooking_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../utils/responsive_utils.dart';
import '../import/faq_screen.dart' show openFaqHowTo;
import '../pantry_cooking/pantry_cooking_widgets.dart';

/// The pantry: what is on hand now (dated, so the app can ask "Still have
/// these?"), the ready-made ingredient lists, and the Always have basics.
///
/// Items in the pantry are auto-unchecked in the shopping list generator
/// since the user presumably already has them on hand, and "What can I
/// make?" ranks recipes by them. Shares its state with that page.
class PantryScreen extends ConsumerWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final loading = ref.watch(pantryProvider).valueOrNull == null;

    /// Leave this screen (a settings panel on desktop, a page on phones) for
    /// "What can I make?".
    void openCooking() {
      final router = GoRouter.of(context);
      Navigator.of(context).maybePop();
      router.push(pantryCookingPath);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myPantry),
        actions: [
          IconButton(
            tooltip: l10n.pantryHowItWorks,
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => openFaqHowTo(context, 'pantry'),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Responsive.constrainWidth(
              context,
              maxWidth: Responsive.settingsListMaxWidth,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  // Info card
                  Card(
                    margin: EdgeInsets.zero,
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.pantryInfoMessage,
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // What can I make with all this?
                  Material(
                    color: c.selectedFill,
                    borderRadius: Radii.lgAll,
                    child: InkWell(
                      borderRadius: Radii.lgAll,
                      onTap: openCooking,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.restaurant_menu_rounded, size: 20, color: c.accent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.pantryCookSeeRecipes,
                                style: TextStyle(fontWeight: FontWeight.w600, color: c.accent),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: c.accent),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Still have these? / add / common lists / recently bought / on hand
                  const PantryQuickAdd(searchable: true),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                  ),

                  // Basics that never count as missing in "What can I make?"
                  const PantryBasicsEditor(),
                ],
              ),
            ),
    );
  }
}
