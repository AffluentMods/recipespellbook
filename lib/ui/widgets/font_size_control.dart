import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/responsive_utils.dart';

/// Font size scale provider for recipe reading
final recipeFontScaleProvider = StateNotifierProvider<RecipeFontScaleNotifier, double>((ref) {
  return RecipeFontScaleNotifier();
});

class RecipeFontScaleNotifier extends StateNotifier<double> {
  RecipeFontScaleNotifier() : super(1.0) {
    _loadScale();
  }

  static const _key = 'recipe_font_scale';
  static const double minScale = 0.8;
  static const double maxScale = 1.6;
  static const double step = 0.1;

  Future<void> _loadScale() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_key) ?? 1.0;
  }

  Future<void> setScale(double scale) async {
    state = scale.clamp(minScale, maxScale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, state);
  }

  void increase() => setScale(state + step);
  void decrease() => setScale(state - step);
  void reset() => setScale(1.0);
}

/// Font size control widget - shows A- / A+ buttons
class FontSizeControl extends ConsumerWidget {
  const FontSizeControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final scale = ref.watch(recipeFontScaleProvider);
    final notifier = ref.read(recipeFontScaleProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease
          IconButton(
            icon: const Text('A-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            onPressed: scale > RecipeFontScaleNotifier.minScale ? notifier.decrease : null,
            tooltip: l10n.smallerText,
            visualDensity: VisualDensity.compact,
          ),
          // Current scale indicator
          GestureDetector(
            onTap: notifier.reset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${(scale * 100).round()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ),
          // Increase
          IconButton(
            icon: const Text('A+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            onPressed: scale < RecipeFontScaleNotifier.maxScale ? notifier.increase : null,
            tooltip: l10n.largerText,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for font size adjustment
class FontSizeSheet extends ConsumerWidget {
  const FontSizeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final scale = ref.watch(recipeFontScaleProvider);
    final notifier = ref.read(recipeFontScaleProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.textSize,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Preview text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ingredientPreview,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• 2 cups all-purpose flour',
                  style: TextStyle(fontSize: 15 * scale),
                ),
                Text(
                  '• 1 tsp vanilla extract',
                  style: TextStyle(fontSize: 15 * scale),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Slider
          Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: scale,
                  min: RecipeFontScaleNotifier.minScale,
                  max: RecipeFontScaleNotifier.maxScale,
                  divisions: ((RecipeFontScaleNotifier.maxScale - RecipeFontScaleNotifier.minScale) / RecipeFontScaleNotifier.step).round(),
                  label: '${(scale * 100).round()}%',
                  onChanged: notifier.setScale,
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 16),

          // Reset button
          TextButton(
            onPressed: notifier.reset,
            child: Text(l10n.resetToDefault),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Show font size bottom sheet
void showFontSizeSheet(BuildContext context) {
  Responsive.showAdaptiveSheet(
    context,
    builder: (context) => const FontSizeSheet(),
  );
}