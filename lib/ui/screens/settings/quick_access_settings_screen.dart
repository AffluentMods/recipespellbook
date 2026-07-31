import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/responsive_utils.dart';

class QuickAccessSettingsScreen extends ConsumerWidget {
  const QuickAccessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsQuickAccess),
      ),
      body: Responsive.constrainWidth(context, maxWidth: Responsive.settingsListMaxWidth, child: ListView(
        children: [
          // Explanation card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flash_on, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.settingsQuickAccess,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.quickAccessSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),

          // Badge legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.quickAccessHelpIntro,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _BadgeLegendItem(
                      color: Colors.blue,
                      icon: Icons.calendar_today,
                      label: l10n.quickAccessHelpMealPlan,
                      description: l10n.homeMealPlan,
                    ),
                    const SizedBox(height: 8),
                    _BadgeLegendItem(
                      color: Colors.orange,
                      icon: Icons.push_pin,
                      label: l10n.quickAccessHelpPinned,
                      description: l10n.homePinnedRecipes,
                    ),
                    const SizedBox(height: 8),
                    _BadgeLegendItem(
                      color: Colors.grey,
                      icon: Icons.history,
                      label: l10n.quickAccessHelpRecent,
                      description: l10n.homeRecentRecipes,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Toggle sections
          _SectionHeader(title: l10n.displayOptions),

          // Meal Plan toggle
          SwitchListTile(
            title: Text(l10n.showMealPlan),
            subtitle: Text(l10n.showMealPlanSubtitle),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today, size: 20, color: Colors.white),
            ),
            value: settings.quickAccessShowMealPlan,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setQuickAccessShowMealPlan(value);
            },
          ),

          // Pinned toggle
          SwitchListTile(
            title: Text(l10n.showPinnedRecipes),
            subtitle: Text(l10n.showPinnedSubtitle),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.push_pin, size: 20, color: Colors.white),
            ),
            value: settings.quickAccessShowPinned,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setQuickAccessShowPinned(value);
            },
          ),

          // History toggle
          SwitchListTile(
            title: Text(l10n.showRecentHistory),
            subtitle: Text(l10n.showRecentSubtitle),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.history, size: 20, color: Colors.white),
            ),
            value: settings.quickAccessShowHistory,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setQuickAccessShowHistory(value);
            },
          ),

          // History count (only if history is enabled)
          if (settings.quickAccessShowHistory) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.historyCount,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.historyCountSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('${settings.quickAccessHistoryCount}', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Slider(
                              value: settings.quickAccessHistoryCount.toDouble(),
                              min: 3,
                              max: 20,
                              divisions: 17,
                              label: '${settings.quickAccessHistoryCount}',
                              onChanged: (value) {
                                ref.read(settingsProvider.notifier).setQuickAccessHistoryCount(value.round());
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      )),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _BadgeLegendItem extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String description;

  const _BadgeLegendItem({
    required this.color,
    required this.icon,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text(description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            ],
          ),
        ),
      ],
    );
  }
}