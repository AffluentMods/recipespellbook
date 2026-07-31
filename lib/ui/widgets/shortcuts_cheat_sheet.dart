import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import 'command_palette.dart';

/// Whether the keyboard-shortcuts cheat sheet is showing (Ctrl/Cmd+/).
final shortcutsCheatSheetOpenProvider = StateProvider<bool>((ref) => false);

/// Toggle the cheat sheet, closing the command palette first so the two never
/// stack.
void toggleShortcutsCheatSheet(WidgetRef ref) {
  ref.read(commandPaletteOpenProvider.notifier).state = false;
  final n = ref.read(shortcutsCheatSheetOpenProvider.notifier);
  n.state = !n.state;
}

/// Mounts the cheat-sheet overlay above [child]; renders nothing until opened.
class ShortcutsCheatSheetHost extends ConsumerWidget {
  final Widget child;
  const ShortcutsCheatSheetHost({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(shortcutsCheatSheetOpenProvider);
    return Stack(
      children: [
        child,
        if (open) const _CheatSheetOverlay(),
      ],
    );
  }
}

class _ShortcutGroup {
  final String title;
  final List<(String, String)> rows; // (label, keys)
  const _ShortcutGroup(this.title, this.rows);
}

class _CheatSheetOverlay extends ConsumerStatefulWidget {
  const _CheatSheetOverlay();

  @override
  ConsumerState<_CheatSheetOverlay> createState() => _CheatSheetOverlayState();
}

class _CheatSheetOverlayState extends ConsumerState<_CheatSheetOverlay>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focus = FocusNode(onKeyEvent: _onKey);
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
  )..forward();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _close() {
    if (mounted) ref.read(shortcutsCheatSheetOpenProvider.notifier).state = false;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.escape) {
      _close();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final mod = defaultTargetPlatform == TargetPlatform.macOS ? 'Cmd' : 'Ctrl';
    final groups = <_ShortcutGroup>[
      _ShortcutGroup('General', [
        ('Command palette', '$mod K'),
        ('Search', '$mod F'),
        ('New recipe', '$mod N'),
        ('Settings', '$mod ,'),
        ('Keyboard shortcuts', '$mod /'),
        ('Dismiss', 'Esc'),
      ]),
      _ShortcutGroup('Navigation', [
        ('Home', '$mod 1'),
        ('Cookbooks', '$mod 2'),
        ('Planner', '$mod 3'),
        ('Shopping', '$mod 4'),
        ('Community', '$mod 5'),
      ]),
      _ShortcutGroup('Recipes', [
        ('Move selection', '↑  ↓'),
        ('Open recipe', 'Enter'),
        ('Move to trash', 'Del'),
      ]),
      _ShortcutGroup('Editor', [
        ('Save recipe', '$mod S'),
      ]),
    ];

    return Positioned.fill(
      child: FadeTransition(
        opacity: _anim,
        child: Focus(
          focusNode: _focus,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: _close,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(color: Colors.black.withValues(alpha: 0.42)),
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.35),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.97, end: 1).animate(
                    CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: c.surfaceHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: c.outline.withValues(alpha: 0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
                            child: Row(
                              children: [
                                Icon(Icons.keyboard_outlined, size: 20, color: c.textTertiary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text('Keyboard shortcuts',
                                      style: TextStyle(
                                          color: c.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                ),
                                _KeyCap(text: 'Esc', c: c),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: c.outline.withValues(alpha: 0.3)),
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final g in groups) ...[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 6),
                                      child: Text(
                                        g.title.toUpperCase(),
                                        style: TextStyle(
                                          color: c.textTertiary,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                    for (final row in g.rows)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(row.$1,
                                                  style: TextStyle(
                                                      color: c.textSecondary, fontSize: 13.5)),
                                            ),
                                            _KeyCap(text: row.$2, c: c),
                                          ],
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyCap extends StatelessWidget {
  final String text;
  final AppColors c;
  const _KeyCap({required this.text, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.outline.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: c.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
