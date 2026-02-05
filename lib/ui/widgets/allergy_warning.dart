import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/allergen_data.dart';
import '../../providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';

/// Widget that displays allergen warnings for a recipe
/// Shows a prominent warning banner when allergens are detected
class AllergyWarningBanner extends ConsumerWidget {
  /// List of ingredient names/texts to check
  final List<String> ingredients;

  /// Whether to show a compact version
  final bool compact;

  /// Called when user taps "View Details"
  final VoidCallback? onTapDetails;

  const AllergyWarningBanner({
    super.key,
    required this.ingredients,
    this.compact = false,
    this.onTapDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final userAllergens = settings.allergens;

    // No allergens set, don't show anything
    if (userAllergens.isEmpty) return const SizedBox.shrink();

    // Check ingredients
    final matches = AllergenDetector.getRecipeAllergenSummary(
      ingredients,
      userAllergens,
    );

    // No matches found
    if (matches.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Separate definite and possible matches
    final definiteMatches = matches.where(
            (m) => m.matchType == AllergenMatchType.definite
    ).toList();
    final possibleMatches = matches.where(
            (m) => m.matchType == AllergenMatchType.possible
    ).toList();

    if (compact) {
      return _buildCompactWarning(
        context, theme, l10n, definiteMatches, possibleMatches,
      );
    }

    return _buildFullWarning(
      context, theme, l10n, definiteMatches, possibleMatches,
    );
  }

  Widget _buildCompactWarning(
      BuildContext context,
      ThemeData theme,
      AppLocalizations l10n,
      List<AllergenMatch> definiteMatches,
      List<AllergenMatch> possibleMatches,
      ) {
    final hasDefinite = definiteMatches.isNotEmpty;
    final color = hasDefinite ? Colors.red : Colors.orange;

    final allergenEmojis = [
      ...definiteMatches.map((m) => m.allergen.emoji),
      ...possibleMatches.map((m) => m.allergen.emoji),
    ].take(5).join(' ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            hasDefinite ? Icons.dangerous : Icons.warning_amber,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              allergenEmojis,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            hasDefinite ? l10n.allergyContainsAllergens : l10n.allergyMayContain,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWarning(
      BuildContext context,
      ThemeData theme,
      AppLocalizations l10n,
      List<AllergenMatch> definiteMatches,
      List<AllergenMatch> possibleMatches,
      ) {
    final hasDefinite = definiteMatches.isNotEmpty;
    final primaryColor = hasDefinite ? Colors.red : Colors.orange;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(
                  hasDefinite ? Icons.dangerous : Icons.warning_amber,
                  color: primaryColor.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasDefinite
                        ? l10n.allergyWarningTitle
                        : l10n.allergyWarningTitlePossible,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: primaryColor.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Definite matches
                if (definiteMatches.isNotEmpty) ...[
                  Text(
                    l10n.allergyContains,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: definiteMatches.map((match) => _buildAllergenChip(
                      theme,
                      match.allergen,
                      l10n,
                      isDefinite: true,
                    )).toList(),
                  ),
                ],

                // Possible matches
                if (possibleMatches.isNotEmpty) ...[
                  if (definiteMatches.isNotEmpty) const SizedBox(height: 12),
                  Text(
                    l10n.allergyMayContain,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: possibleMatches.map((match) => _buildAllergenChip(
                      theme,
                      match.allergen,
                      l10n,
                      isDefinite: false,
                    )).toList(),
                  ),
                ],

                // Link to settings
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.push('/settings/allergies'),
                  child: Text(
                    l10n.allergyManageSettings,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergenChip(
      ThemeData theme,
      Allergen allergen,
      AppLocalizations l10n, {
        required bool isDefinite,
      }) {
    final color = isDefinite ? Colors.red : Colors.orange;
    final name = allergen.getLocalizedName(l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(allergen.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            name,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline allergen indicator for use in ingredient lists
/// Shows a small warning icon next to allergenic ingredients
class AllergenIndicator extends ConsumerWidget {
  final String ingredientText;

  const AllergenIndicator({
    super.key,
    required this.ingredientText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final userAllergens = settings.allergens;

    if (userAllergens.isEmpty) return const SizedBox.shrink();

    final matches = AllergenDetector.checkIngredient(ingredientText, userAllergens);
    if (matches.isEmpty) return const SizedBox.shrink();

    final hasDefinite = matches.any((m) => m.matchType == AllergenMatchType.definite);
    final color = hasDefinite ? Colors.red : Colors.orange;

    return Tooltip(
      message: matches.map((m) => m.allergen.displayName).join(', '),
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(
          hasDefinite ? Icons.dangerous : Icons.warning_amber,
          color: color,
          size: 16,
        ),
      ),
    );
  }
}

/// Shows a dialog with detailed allergen information for a recipe
class AllergenDetailDialog extends StatelessWidget {
  final List<AllergenMatch> matches;

  const AllergenDetailDialog({
    super.key,
    required this.matches,
  });

  static Future<void> show(BuildContext context, List<AllergenMatch> matches) {
    return showDialog(
      context: context,
      builder: (context) => AllergenDetailDialog(matches: matches),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final definiteMatches = matches.where(
            (m) => m.matchType == AllergenMatchType.definite
    ).toList();
    final possibleMatches = matches.where(
            (m) => m.matchType == AllergenMatchType.possible
    ).toList();

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange),
          const SizedBox(width: 12),
          Text(l10n.allergyDetailsTitle),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (definiteMatches.isNotEmpty) ...[
              Text(
                l10n.allergyContains,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...definiteMatches.map((m) => _buildMatchRow(theme, m, true)),
              const SizedBox(height: 16),
            ],
            if (possibleMatches.isNotEmpty) ...[
              Text(
                l10n.allergyMayContain,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...possibleMatches.map((m) => _buildMatchRow(theme, m, false)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.push('/settings/allergies'),
          child: Text(l10n.allergyManageSettings),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionClose),
        ),
      ],
    );
  }

  Widget _buildMatchRow(ThemeData theme, AllergenMatch match, bool isDefinite) {
    final color = isDefinite ? Colors.red : Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(match.allergen.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.allergen.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'in "${match.ingredientName}"',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isDefinite ? Icons.dangerous : Icons.help_outline,
            color: color,
            size: 18,
          ),
        ],
      ),
    );
  }
}