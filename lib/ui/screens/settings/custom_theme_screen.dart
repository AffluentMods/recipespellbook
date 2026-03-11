import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/app_enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';
import '../../widgets/color_picker_dialog.dart';

class CustomThemeScreen extends ConsumerStatefulWidget {
  const CustomThemeScreen({super.key});

  @override
  ConsumerState<CustomThemeScreen> createState() => _CustomThemeScreenState();
}

class _CustomThemeScreenState extends ConsumerState<CustomThemeScreen> {
  late Color _bg;
  late Color _primary;
  late Color _accent;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _bg = settings.customBgColor ?? const Color(0xFFF5F5F5);
    _primary = settings.customPrimaryColor ?? const Color(0xFF6750A4);
    _accent = settings.customAccentColor ?? const Color(0xFF7D5260);
  }

  ThemePalette get _lightPreview =>
      ThemePalette.deriveFrom(bg: _bg, primary: _primary, accent: _accent, isDark: false);

  Future<void> _pickColor(String label, Color current, ValueChanged<Color> onPicked) async {
    final picked = await showColorPickerDialog(
      context,
      initialColor: current,
      title: label,
    );
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  void _save() {
    ref.read(settingsProvider.notifier).setCustomColors(_bg, _primary, _accent);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = _lightPreview;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customThemeTitle),
        actions: [
          FilledButton(
            onPressed: _save,
            child: Text(l10n.actionSave),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Live preview ──
          _PreviewCard(palette: preview),
          const SizedBox(height: 24),

          // ── Color pickers ──
          Text(
            l10n.customThemeColors,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          _ColorTile(
            label: l10n.customThemeBackground,
            subtitle: l10n.customThemeBackgroundDesc,
            color: _bg,
            onTap: () => _pickColor(l10n.customThemeBackground, _bg, (c) => _bg = c),
          ),
          const SizedBox(height: 8),
          _ColorTile(
            label: l10n.customThemePrimary,
            subtitle: l10n.customThemePrimaryDesc,
            color: _primary,
            onTap: () => _pickColor(l10n.customThemePrimary, _primary, (c) => _primary = c),
          ),
          const SizedBox(height: 8),
          _ColorTile(
            label: l10n.customThemeAccent,
            subtitle: l10n.customThemeAccentDesc,
            color: _accent,
            onTap: () => _pickColor(l10n.customThemeAccent, _accent, (c) => _accent = c),
          ),
          const SizedBox(height: 24),

          // ── Preset starting points ──
          Text(
            l10n.customThemeStartFromPreset,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in AppColorTheme.values)
                if (!t.isCustom)
                  _PresetChip(
                    label: t.emoji,
                    bg: t.light.background,
                    primary: t.light.primary,
                    accent: t.light.accent,
                    onTap: () {
                      setState(() {
                        _bg = t.light.background;
                        _primary = t.light.primary;
                        _accent = t.light.accent;
                      });
                    },
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  COLOR TILE
// ════════════════════════════════════════════

class _ColorTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ColorTile({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hexStr = '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
        ),
        title: Text(label),
        subtitle: Text(subtitle),
        trailing: Text(
          hexStr,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  LIVE PREVIEW CARD
// ════════════════════════════════════════════

class _PreviewCard extends StatelessWidget {
  final ThemePalette palette;

  const _PreviewCard({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.onSurface.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App bar mockup
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.menu_book, color: palette.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Recipe Spellbook',
                  style: TextStyle(
                    color: palette.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(Icons.search, color: palette.onSurface.withValues(alpha: 0.6), size: 18),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Recipe card mockup
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: palette.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.restaurant, color: palette.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Butter Chicken',
                        style: TextStyle(
                          color: palette.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '45 min · 4 servings',
                        style: TextStyle(
                          color: palette.onSurface.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.favorite, color: palette.accent, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Buttons row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Primary',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Accent',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.accent.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  PRESET CHIP
// ════════════════════════════════════════════

class _PresetChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color primary;
  final Color accent;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.bg,
    required this.primary,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, accent],
          ),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
