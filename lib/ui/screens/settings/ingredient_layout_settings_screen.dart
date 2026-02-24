import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';

class IngredientLayoutSettingsScreen extends ConsumerWidget {
  const IngredientLayoutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final current = settings.ingredientLayout;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsIngredientLayout),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.settingsIngredientLayoutDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          _LayoutOptionCard(
            title: l10n.ingredientLayoutInline,
            description: l10n.ingredientLayoutInlineDescription,
            isSelected: current == IngredientLayout.inline,
            onTap: () {
              ref.read(settingsProvider.notifier).setIngredientLayout(IngredientLayout.inline);
            },
            preview: _InlinePreview(isSelected: current == IngredientLayout.inline),
          ),

          const SizedBox(height: 16),

          _LayoutOptionCard(
            title: l10n.ingredientLayoutColumnar,
            description: l10n.ingredientLayoutColumnarDescription,
            isSelected: current == IngredientLayout.columnar,
            onTap: () {
              ref.read(settingsProvider.notifier).setIngredientLayout(IngredientLayout.columnar);
            },
            preview: _ColumnarPreview(isSelected: current == IngredientLayout.columnar),
          ),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.ingredientLayoutInfoText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
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
}

// ═══════════════════════════════════════════════════════════════════
// OPTION CARD
// ═══════════════════════════════════════════════════════════════════

class _LayoutOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget preview;

  const _LayoutOptionCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  size: 24,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: preview,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// INLINE PREVIEW — "2 tbsp butter" flowing naturally
// ═══════════════════════════════════════════════════════════════════

class _InlinePreview extends StatelessWidget {
  final bool isSelected;
  const _InlinePreview({this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isSelected ? theme.colorScheme.primary : theme.colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inlineRow(theme, accent, '🧈', '2 tbsp ', 'butter'),
          const SizedBox(height: 10),
          _inlineRow(theme, accent, '🧄', '3 ', 'garlic cloves, minced'),
          const SizedBox(height: 10),
          _inlineRow(theme, accent, '🫑', '', 'banana peppers'),
          const SizedBox(height: 10),
          _inlineRow(theme, accent, '🧀', '1 cup ', 'shredded mozzarella'),
        ],
      ),
    );
  }

  Widget _inlineRow(ThemeData theme, Color accent, String emoji, String amountUnit, String name) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                if (amountUnit.isNotEmpty)
                  TextSpan(text: amountUnit, style: TextStyle(fontWeight: FontWeight.w600, color: accent)),
                TextSpan(text: name),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// COLUMNAR PREVIEW — amounts aligned in a fixed column
// ═══════════════════════════════════════════════════════════════════

class _ColumnarPreview extends StatelessWidget {
  final bool isSelected;
  const _ColumnarPreview({this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isSelected ? theme.colorScheme.primary : theme.colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _columnarRow(theme, accent, '🧈', '2 tbsp', 'butter'),
          const SizedBox(height: 10),
          _columnarRow(theme, accent, '🧄', '3', 'garlic cloves, minced'),
          const SizedBox(height: 10),
          _columnarRow(theme, accent, '🫑', '', 'banana peppers'),
          const SizedBox(height: 10),
          _columnarRow(theme, accent, '🧀', '1 cup', 'shredded mozzarella'),
        ],
      ),
    );
  }

  Widget _columnarRow(ThemeData theme, Color accent, String emoji, String amountUnit, String name) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        SizedBox(
          width: 60,
          child: amountUnit.isNotEmpty
              ? Text(amountUnit, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: accent))
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(name, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}