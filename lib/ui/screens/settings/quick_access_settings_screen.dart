import 'package:flutter/material.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/settings_provider.dart';

class QuickAccessSettingsScreen extends ConsumerWidget {
  const QuickAccessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsQuickAccess),
      ),
      body: ListView(
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
                        'Quick Access',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quick Access shows your most relevant recipes at the top of the home screen. Customize what appears here.',
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
                      'Badge Legend',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _BadgeLegendItem(
                      color: Colors.blue,
                      icon: Icons.calendar_today,
                      label: "Today's Meal Plan",
                      description: 'Recipes scheduled for today',
                    ),
                    const SizedBox(height: 8),
                    _BadgeLegendItem(
                      color: Colors.orange,
                      icon: Icons.push_pin,
                      label: 'Pinned',
                      description: 'Recipes you\'ve pinned for quick access',
                    ),
                    const SizedBox(height: 8),
                    _BadgeLegendItem(
                      color: Colors.grey,
                      icon: Icons.history,
                      label: 'Recently Viewed',
                      description: 'Recipes you\'ve opened recently',
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Toggle sections
          _SectionHeader(title: 'Display Options'),

          // Meal Plan toggle
          SwitchListTile(
            title: const Text('Show Meal Plan'),
            subtitle: const Text('Display today\'s scheduled recipes'),
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
            title: const Text('Show Pinned Recipes'),
            subtitle: const Text('Display recipes you\'ve pinned'),
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
            title: const Text('Show Recent History'),
            subtitle: const Text('Display recently viewed recipes'),
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
                        'History Count',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Maximum number of recent recipes to show',
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
      ),
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