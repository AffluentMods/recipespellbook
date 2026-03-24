import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/app_enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/color_picker_dialog.dart';

// ════════════════════════════════════════════════════════════
//  CUSTOM THEME SCREEN
//  ─ Professional theme editor with system-default-aware
//    light/dark tabs, linked-mode overlay, and banner presets.
// ════════════════════════════════════════════════════════════

class CustomThemeScreen extends ConsumerStatefulWidget {
  const CustomThemeScreen({super.key});

  @override
  ConsumerState<CustomThemeScreen> createState() => _CustomThemeScreenState();
}

class _CustomThemeScreenState extends ConsumerState<CustomThemeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Light palette
  late Color _lightBg;
  late Color _lightPrimary;
  late Color _lightAccent;

  // Dark palette
  late Color _darkBg;
  late Color _darkPrimary;
  late Color _darkAccent;

  // Whether the secondary mode is auto-derived from the primary
  late bool _secondaryLinked;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final settings = ref.read(settingsProvider);

    _lightBg = settings.customBgColor ?? const Color(0xFFF5F5F5);
    _lightPrimary = settings.customPrimaryColor ?? const Color(0xFF6750A4);
    _lightAccent = settings.customAccentColor ?? const Color(0xFF7D5260);

    _secondaryLinked = settings.customDarkLinked;
    _darkBg = settings.customDarkBgColor ?? _autoDarkBg(_lightBg);
    _darkPrimary = settings.customDarkPrimaryColor ?? _autoDarkPrimary(_lightPrimary);
    _darkAccent = settings.customDarkAccentColor ?? _autoDarkAccent(_lightAccent);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── System default ───────────────────────────────────
  bool get _systemIsDark =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  bool get _isPrimaryDark => _systemIsDark;

  // ── Auto-derive helpers ──────────────────────────────
  Color _autoDarkBg(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness * 0.15).clamp(0.05, 0.12)).toColor();
  }

  Color _autoDarkPrimary(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness * 0.6 + 0.4).clamp(0.55, 0.8)).toColor();
  }

  Color _autoDarkAccent(Color c) => _autoDarkPrimary(c);

  Color _autoLightBg(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness * 0.4 + 0.55).clamp(0.88, 0.97)).toColor();
  }

  Color _autoLightPrimary(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness * 0.5).clamp(0.25, 0.45)).toColor();
  }

  Color _autoLightAccent(Color c) => _autoLightPrimary(c);

  void _syncSecondaryFromPrimary() {
    if (_isPrimaryDark) {
      _lightBg = _autoLightBg(_darkBg);
      _lightPrimary = _autoLightPrimary(_darkPrimary);
      _lightAccent = _autoLightAccent(_darkAccent);
    } else {
      _darkBg = _autoDarkBg(_lightBg);
      _darkPrimary = _autoDarkPrimary(_lightPrimary);
      _darkAccent = _autoDarkAccent(_lightAccent);
    }
  }

  // ── Palettes ─────────────────────────────────────────
  ThemePalette get _lightPreview =>
      ThemePalette.deriveFrom(bg: _lightBg, primary: _lightPrimary, accent: _lightAccent, isDark: false);
  ThemePalette get _darkPreview =>
      ThemePalette.deriveFrom(bg: _darkBg, primary: _darkPrimary, accent: _darkAccent, isDark: true);

  // ── Color picker ─────────────────────────────────────
  Future<void> _pickColor(String label, Color current, ValueChanged<Color> onPicked) async {
    final picked = await showColorPickerDialog(context, initialColor: current, title: label);
    if (picked != null) {
      setState(() {
        onPicked(picked);
        if (_secondaryLinked) _syncSecondaryFromPrimary();
      });
    }
  }

  // ── Load preset (per-tab) ────────────────────────────
  void _loadPresetForTab(AppColorTheme t, {required bool isDark}) {
    setState(() {
      if (isDark) {
        _darkBg = t.dark.background;
        _darkPrimary = t.dark.primary;
        _darkAccent = t.dark.accent;
        if (_secondaryLinked) _syncSecondaryFromPrimary();
      } else {
        _lightBg = t.light.background;
        _lightPrimary = t.light.primary;
        _lightAccent = t.light.accent;
        if (_secondaryLinked) _syncSecondaryFromPrimary();
      }
    });
  }

  // ── Save ─────────────────────────────────────────────
  void _save() {
    final notifier = ref.read(settingsProvider.notifier);
    notifier.setCustomColors(_lightBg, _lightPrimary, _lightAccent);
    notifier.setCustomDarkLinked(_secondaryLinked);
    if (!_secondaryLinked) {
      notifier.setCustomDarkColors(_darkBg, _darkPrimary, _darkAccent);
    }
    Navigator.pop(context);
  }

  // ═══════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final primaryLabel = _isPrimaryDark ? l10n.customThemeDarkMode : l10n.customThemeLightMode;
    final secondaryLabel = _isPrimaryDark ? l10n.customThemeLightMode : l10n.customThemeDarkMode;
    final primaryIcon = _isPrimaryDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded;
    final secondaryIcon = _isPrimaryDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customThemeTitle),
        actions: [
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check, size: 18),
            label: Text(l10n.actionSave),
          ),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(primaryIcon, size: 18), text: primaryLabel),
            Tab(icon: Icon(secondaryIcon, size: 18), text: secondaryLabel),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── TAB 0: PRIMARY (system default) ──
          Responsive.constrainWidth(context, child: _buildEditorTab(
            theme: theme, l10n: l10n,
            isDark: _isPrimaryDark,
            bg: _isPrimaryDark ? _darkBg : _lightBg,
            primary: _isPrimaryDark ? _darkPrimary : _lightPrimary,
            accent: _isPrimaryDark ? _darkAccent : _lightAccent,
            preview: _isPrimaryDark ? _darkPreview : _lightPreview,
            onBgPick: (c) { if (_isPrimaryDark) { _darkBg = c; } else { _lightBg = c; } },
            onPrimaryPick: (c) { if (_isPrimaryDark) { _darkPrimary = c; } else { _lightPrimary = c; } },
            onAccentPick: (c) { if (_isPrimaryDark) { _darkAccent = c; } else { _lightAccent = c; } },
            isLinked: false,
          )),

          // ── TAB 1: SECONDARY (linked by default) ──
          Responsive.constrainWidth(context, child: _buildEditorTab(
            theme: theme, l10n: l10n,
            isDark: !_isPrimaryDark,
            bg: !_isPrimaryDark ? _darkBg : _lightBg,
            primary: !_isPrimaryDark ? _darkPrimary : _lightPrimary,
            accent: !_isPrimaryDark ? _darkAccent : _lightAccent,
            preview: !_isPrimaryDark ? _darkPreview : _lightPreview,
            onBgPick: (c) { if (!_isPrimaryDark) { _darkBg = c; } else { _lightBg = c; } },
            onPrimaryPick: (c) { if (!_isPrimaryDark) { _darkPrimary = c; } else { _lightPrimary = c; } },
            onAccentPick: (c) { if (!_isPrimaryDark) { _darkAccent = c; } else { _lightAccent = c; } },
            isLinked: _secondaryLinked,
          )),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  EDITOR TAB
  // ═══════════════════════════════════════════════════════
  Widget _buildEditorTab({
    required ThemeData theme,
    required AppLocalizations l10n,
    required bool isDark,
    required Color bg,
    required Color primary,
    required Color accent,
    required ThemePalette preview,
    required ValueChanged<Color> onBgPick,
    required ValueChanged<Color> onPrimaryPick,
    required ValueChanged<Color> onAccentPick,
    required bool isLinked,
  }) {
    final primaryModeName = _isPrimaryDark
        ? l10n.customThemeDarkMode.toLowerCase()
        : l10n.customThemeLightMode.toLowerCase();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            // ── Live preview ──
            _SectionHeader(icon: Icons.visibility_rounded, label: l10n.customThemeLivePreview),
            const SizedBox(height: 12),
            _PreviewCard(palette: preview, isDark: isDark),
            const SizedBox(height: 28),

            // ── Color pickers ──
            _SectionHeader(icon: Icons.palette_rounded, label: l10n.customThemeColors),
            const SizedBox(height: 12),
            _ColorTile(
              label: l10n.customThemeBackground,
              subtitle: l10n.customThemeBackgroundDesc,
              color: bg,
              onTap: () => _pickColor(l10n.customThemeBackground, bg, onBgPick),
            ),
            const SizedBox(height: 8),
            _ColorTile(
              label: l10n.customThemePrimary,
              subtitle: l10n.customThemePrimaryDesc,
              color: primary,
              onTap: () => _pickColor(l10n.customThemePrimary, primary, onPrimaryPick),
            ),
            const SizedBox(height: 8),
            _ColorTile(
              label: l10n.customThemeAccent,
              subtitle: l10n.customThemeAccentDesc,
              color: accent,
              onTap: () => _pickColor(l10n.customThemeAccent, accent, onAccentPick),
            ),
            const SizedBox(height: 28),

            // ── Presets (with banner images) ──
            _SectionHeader(icon: Icons.auto_awesome_rounded, label: l10n.customThemeStartFromPreset),
            const SizedBox(height: 12),
            _PresetGrid(
              onSelect: (t) => _loadPresetForTab(t, isDark: isDark),
            ),

            // ── Re-link button (secondary when unlinked) ──
            if (!isLinked) ...[
              const SizedBox(height: 24),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _secondaryLinked = true;
                    _syncSecondaryFromPrimary();
                  }),
                  icon: const Icon(Icons.link_rounded, size: 16),
                  label: Text(l10n.customThemeLinkButton(primaryModeName)),
                ),
              ),
            ],
          ],
        ),

        // ── LINKED OVERLAY ──
        if (isLinked)
          _LinkedOverlay(
            modeName: primaryModeName,
            l10n: l10n,
            onUnlink: () => setState(() => _secondaryLinked = false),
          ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
//  LINKED OVERLAY
// ════════════════════════════════════════════════════════════

class _LinkedOverlay extends StatelessWidget {
  final String modeName;
  final AppLocalizations l10n;
  final VoidCallback onUnlink;

  const _LinkedOverlay({
    required this.modeName,
    required this.l10n,
    required this.onUnlink,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: Container(
        color: theme.colorScheme.surface.withValues(alpha: 0.80),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surfaceContainerHighest,
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
                  ),
                  child: Icon(Icons.link_rounded, size: 32, color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.customThemeLinkedOverlay(modeName),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant, height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.tonalIcon(
                  onPressed: onUnlink,
                  icon: const Icon(Icons.link_off_rounded, size: 18),
                  label: Text(l10n.customThemeUnlockButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SECTION HEADER
// ════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
//  COLOR TILE
// ════════════════════════════════════════════════════════════

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

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 1),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hexStr,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'monospace', fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant, letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.edit_rounded, size: 16, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  LIVE PREVIEW CARD
// ════════════════════════════════════════════════════════════

class _PreviewCard extends StatelessWidget {
  final ThemePalette palette;
  final bool isDark;

  const _PreviewCard({required this.palette, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.onSurface.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App bar mockup
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border(bottom: BorderSide(color: palette.onSurface.withValues(alpha: 0.06))),
            ),
            child: Row(children: [
              Icon(Icons.menu_book_rounded, color: palette.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text('Recipe Spellbook',
                  style: TextStyle(color: palette.onSurface, fontWeight: FontWeight.bold, fontSize: 15))),
              Icon(Icons.search_rounded, size: 20, color: palette.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 12),
              Icon(Icons.notifications_none_rounded, size: 20, color: palette.onSurface.withValues(alpha: 0.5)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe card mockup
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: palette.onSurface.withValues(alpha: 0.06)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: palette.primaryContainer, borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.restaurant_rounded, color: palette.primary, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Butter Chicken', style: TextStyle(color: palette.onSurface, fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 3),
                        Row(children: [
                          Icon(Icons.timer_outlined, size: 12, color: palette.onSurface.withValues(alpha: 0.5)),
                          const SizedBox(width: 3),
                          Text('45 min', style: TextStyle(color: palette.onSurface.withValues(alpha: 0.5), fontSize: 11)),
                          const SizedBox(width: 10),
                          Icon(Icons.people_outline_rounded, size: 12, color: palette.onSurface.withValues(alpha: 0.5)),
                          const SizedBox(width: 3),
                          Text('4 servings', style: TextStyle(color: palette.onSurface.withValues(alpha: 0.5), fontSize: 11)),
                        ]),
                      ],
                    )),
                    Icon(Icons.favorite_rounded, color: palette.accent, size: 22),
                  ]),
                ),
                const SizedBox(height: 12),
                // Chips
                Row(children: [
                  _MockChip('Dinner', palette.primaryContainer, palette.primary),
                  const SizedBox(width: 6),
                  _MockChip('Indian', palette.secondaryContainer, palette.secondary),
                  const SizedBox(width: 6),
                  _MockChip('Spicy', Color.lerp(palette.accent, palette.background, 0.7)!, palette.accent),
                ]),
                const SizedBox(height: 14),
                // Buttons
                Row(children: [
                  Expanded(child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: palette.primary, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text('Primary',
                        style: TextStyle(color: palette.onPrimary, fontWeight: FontWeight.w600, fontSize: 12))),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: palette.primary.withValues(alpha: 0.5)),
                    ),
                    child: Center(child: Text('Secondary',
                        style: TextStyle(color: palette.primary, fontWeight: FontWeight.w600, fontSize: 12))),
                  )),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.add_rounded, size: 18,
                        color: palette.accent.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                  ),
                ]),
                const SizedBox(height: 12),
                // Color bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(children: [
                    _ColorBar(palette.primary, flex: 3),
                    _ColorBar(palette.secondary, flex: 2),
                    _ColorBar(palette.accent, flex: 2),
                    _ColorBar(palette.primaryContainer, flex: 2),
                    _ColorBar(palette.surface, flex: 1),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MockChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _MockChip(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _ColorBar extends StatelessWidget {
  final Color color;
  final int flex;
  const _ColorBar(this.color, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: flex, child: Container(height: 6, color: color));
  }
}

// ════════════════════════════════════════════════════════════
//  PRESET GRID — uses actual theme banner images
// ════════════════════════════════════════════════════════════

class _PresetGrid extends StatelessWidget {
  final ValueChanged<AppColorTheme> onSelect;
  const _PresetGrid({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final themes = AppColorTheme.values.where((t) => !t.isCustom).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final t = themes[index];
        return GestureDetector(
          onTap: () => onSelect(t),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Banner image
                  Image.asset(
                    t.bannerAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [t.light.primary, t.light.accent],
                        ),
                      ),
                    ),
                  ),
                  // Label overlay at bottom
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      child: Text(
                        '${t.emoji} ${t.name[0].toUpperCase()}${t.name.substring(1)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          shadows: [Shadow(blurRadius: 3, color: Colors.black.withValues(alpha: 0.8))],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
