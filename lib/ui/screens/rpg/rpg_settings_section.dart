// lib/ui/widgets/rpg/rpg_settings_section.dart
// RPG Settings Section for Settings Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/data/rpg/rpg_models.dart';
import 'package:recipespellbook/providers/rpg_provider.dart';
import 'package:recipespellbook/providers/settings_provider.dart';

class RpgSettingsSection extends ConsumerWidget {
  const RpgSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final rpgEnabled = ref.watch(rpgEnabledProvider);
    final profile = ref.watch(playerProfileProvider);

    // Don't show RPG settings if nerd mode is off
    if (!settings.nerdMode) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '🎮 RPG Mode',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),

        // RPG Enabled toggle
        SwitchListTile(
          title: const Text('Enable RPG Mode'),
          subtitle: Text(
            rpgEnabled
                ? 'Level ${profile.level} ${profile.playerClass.displayName}'
                : 'Gamify your cooking experience!',
          ),
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: rpgEnabled
                  ? profile.playerClass.color.withOpacity(0.2)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              rpgEnabled ? Icons.shield : Icons.shield_outlined,
              color: rpgEnabled ? profile.playerClass.color : null,
            ),
          ),
          value: rpgEnabled,
          onChanged: (value) {
            ref.read(rpgProvider.notifier).setEnabled(value);
          },
        ),

        if (rpgEnabled) ...[
          // Quick stats preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatBadge(
                    icon: Icons.military_tech,
                    label: 'Level',
                    value: '${profile.level}',
                    color: Colors.amber,
                  ),
                  _StatBadge(
                    icon: Icons.monetization_on,
                    label: 'Gold',
                    value: '${profile.gold}',
                    color: Colors.amber,
                  ),
                  _StatBadge(
                    icon: Icons.diamond,
                    label: 'Gems',
                    value: '${profile.gems}',
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ),

          // View Profile button
          ListTile(
            leading: Icon(
              Icons.person,
              color: profile.playerClass.color,
            ),
            title: const Text('View Profile'),
            subtitle: const Text('See your stats, achievements, and more'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/rpg/profile'),
          ),

          // Change Class
          ListTile(
            leading: Text(
              profile.playerClass.icon,
              style: const TextStyle(fontSize: 24),
            ),
            title: const Text('Player Class'),
            subtitle: Text(profile.playerClass.displayName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClassPicker(context, ref),
          ),

          // Reset Progress
          ListTile(
            leading: Icon(
              Icons.restart_alt,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Reset Progress',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Start over from level 1'),
            onTap: () => _confirmReset(context, ref),
          ),
        ],
      ],
    );
  }

  void _showClassPicker(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentClass = ref.read(playerProfileProvider).playerClass;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Choose Your Class',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...PlayerClass.values.map((playerClass) {
              final isSelected = playerClass == currentClass;
              return ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: playerClass.color.withOpacity(isSelected ? 0.3 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: playerClass.color, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      playerClass.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                title: Text(
                  playerClass.displayName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : null,
                    color: isSelected ? playerClass.color : null,
                  ),
                ),
                subtitle: Text(playerClass.description),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: playerClass.color)
                    : null,
                onTap: () {
                  ref.read(rpgProvider.notifier).changeClass(playerClass);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning, color: theme.colorScheme.error, size: 48),
        title: const Text('Reset All Progress?'),
        content: const Text(
          'This will permanently delete:\n'
              '• Your level and XP\n'
              '• All gold and gems\n'
              '• All achievements\n'
              '• All unlocked cosmetics\n\n'
              'This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () {
              ref.read(rpgProvider.notifier).resetProgress();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress reset. Starting fresh!')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}