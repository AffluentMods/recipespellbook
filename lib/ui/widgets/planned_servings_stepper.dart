import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import '../../utils/planned_servings.dart';

/// The "− 6 people +" pill for how many people a planned meal feeds.
///
/// [value] is the number chosen, or null for the recipe's own servings.
/// [recipeServings] is the recipe's servings as written (null when no recipe
/// is chosen yet). When the recipe plainly counts people the pill starts
/// there and never goes below 1; otherwise null shows "Recipe's servings",
/// "+" goes to 1 and "−" from 1 goes back to it.
class PlannedServingsStepper extends StatelessWidget {
  final int? value;
  final String? recipeServings;
  final ValueChanged<int?> onChanged;

  const PlannedServingsStepper({
    super.key,
    required this.value,
    required this.recipeServings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final recipeDefault = recipeServingsDefault(recipeServings);
    final shown = value ?? recipeDefault;
    final changed = normalizePlannedServings(value, recipeServings) != null;
    final canDecrease = shown != null && (shown > 1 || recipeDefault == null);
    final canIncrease = shown == null || shown < maxPlannedServings;

    void step(int dir) {
      HapticFeedback.selectionClick();
      if (shown == null) {
        onChanged(1);
      } else if (dir < 0 && shown <= 1) {
        onChanged(null);
      } else {
        onChanged((shown + dir).clamp(1, maxPlannedServings));
      }
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: Radii.lgAll,
        border: Border.all(color: c.textPrimary.withValues(alpha: 0.14)),
      ),
      child: SizedBox(
        height: 44,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_rounded, size: 20),
              color: c.textSecondary,
              tooltip: l10n.plannedServingsFewer,
              onPressed: canDecrease ? () => step(-1) : null,
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 72, maxWidth: 170),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_alt_outlined, size: 17, color: changed ? c.accent : c.textTertiary),
                  const SizedBox(width: Space.xs + 2),
                  Flexible(
                    child: Text(
                      shown != null ? l10n.plannedServingsPeople(shown) : l10n.plannedServingsRecipeDefault,
                      key: const ValueKey('plannedServingsValue'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: changed ? c.accent : c.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_rounded, size: 20),
              color: c.textSecondary,
              tooltip: l10n.plannedServingsMore,
              onPressed: canIncrease ? () => step(1) : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// "Save as our usual" beside the stepper: makes the shown number the
/// household's usual (Settings > Household size), so new meals start there.
/// Shows a quiet "Our usual" once it already is. Nothing when there is no
/// number to save.
class PlannedServingsUsualAction extends StatelessWidget {
  /// The number of people on the stepper now (chosen or the recipe's).
  final int? shown;

  /// The household's usual number, 0 when none is set.
  final int household;
  final ValueChanged<int> onSave;

  const PlannedServingsUsualAction({
    super.key,
    required this.shown,
    required this.household,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final people = shown;
    if (people == null) return const SizedBox.shrink();
    if (people == household) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 16, color: c.textTertiary),
          const SizedBox(width: Space.xs),
          Text(l10n.plannedServingsUsual, style: TextStyle(fontSize: 13, color: c.textTertiary)),
        ],
      );
    }
    return TextButton(
      onPressed: () => onSave(people),
      style: TextButton.styleFrom(
        foregroundColor: c.accent,
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      child: Text(l10n.plannedServingsSaveUsual),
    );
  }
}

/// The small "people" badge a planner entry carries when it is planned for a
/// number other than its recipe's: an icon and the count, sized to [fontSize].
class PlannedServingsBadge extends StatelessWidget {
  final int people;
  final Color color;
  final double fontSize;

  const PlannedServingsBadge({
    super.key,
    required this.people,
    required this.color,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.plannedServingsPeople(people),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_alt_outlined, size: fontSize + 1, color: color),
          const SizedBox(width: 2),
          Text(
            '$people',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
