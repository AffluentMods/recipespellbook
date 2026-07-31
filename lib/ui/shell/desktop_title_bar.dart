import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../theme/app_colors.dart';
import '../widgets/command_palette.dart';

/// Height of the custom desktop title bar.
const double kDesktopTitleBarHeight = 44;

/// A custom, themed window title bar drawn in place of the native one
/// (the native bar is hidden via [DesktopWindowService]). Gives the desktop
/// app real window chrome: draggable region, app mark, a Ctrl+K search pill,
/// and themed minimize / maximize / close controls.
class DesktopTitleBar extends ConsumerStatefulWidget {
  const DesktopTitleBar({super.key});

  @override
  ConsumerState<DesktopTitleBar> createState() => _DesktopTitleBarState();
}

class _DesktopTitleBarState extends ConsumerState<DesktopTitleBar>
    with WindowListener {
  bool _maximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _syncMaximized();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _syncMaximized() async {
    final m = await windowManager.isMaximized();
    if (mounted && m != _maximized) setState(() => _maximized = m);
  }

  @override
  void onWindowMaximize() => setState(() => _maximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _maximized = false);

  Future<void> _toggleMaximize() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    // The title bar is mounted in MaterialApp.builder, ABOVE any Scaffold/
    // Material — so its Text widgets would otherwise inherit Flutter's fallback
    // text style (the yellow double-underline). Wrapping in a Material supplies
    // a proper DefaultTextStyle so all title-bar text renders cleanly.
    return Material(
      type: MaterialType.transparency,
      child: Container(
      height: kDesktopTitleBarHeight,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(
          bottom: BorderSide(color: c.outline.withValues(alpha: 0.35), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Draggable region: app mark + name.
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: _toggleMaximize,
              onPanStart: (_) => windowManager.startDragging(),
              child: Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Row(
                  children: [
                    Icon(Icons.auto_stories_outlined, size: 18, color: c.accent),
                    const SizedBox(width: 9),
                    Text(
                      'Recipe Spellbook',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Command palette pill.
          _SearchPill(colors: c, onTap: () => openCommandPalette(ref)),
          const SizedBox(width: 8),
          // Window controls.
          _WindowButton(
            icon: Icons.remove,
            colors: c,
            onTap: () => windowManager.minimize(),
          ),
          _WindowButton(
            icon: _maximized ? Icons.filter_none : Icons.crop_square,
            colors: c,
            iconSize: _maximized ? 13 : 15,
            onTap: _toggleMaximize,
          ),
          _WindowButton(
            icon: Icons.close,
            colors: c,
            isClose: true,
            onTap: () => windowManager.close(),
          ),
        ],
      ),
    ),
    );
  }
}

class _SearchPill extends StatefulWidget {
  final AppColors colors;
  final VoidCallback onTap;
  const _SearchPill({required this.colors, required this.onTap});

  @override
  State<_SearchPill> createState() => _SearchPillState();
}

class _SearchPillState extends State<_SearchPill> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: _hover ? c.surfaceHigh : c.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 15, color: c.textTertiary),
              const SizedBox(width: 8),
              Text('Search',
                  style: TextStyle(color: c.textTertiary, fontSize: 12.5)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: c.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: c.outline.withValues(alpha: 0.5)),
                ),
                child: Text('Ctrl K',
                    style: TextStyle(color: c.textTertiary, fontSize: 10.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final AppColors colors;
  final VoidCallback onTap;
  final bool isClose;
  final double iconSize;
  const _WindowButton({
    required this.icon,
    required this.colors,
    required this.onTap,
    this.isClose = false,
    this.iconSize = 16,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final Color bg = _hover
        ? (widget.isClose ? const Color(0xFFE81123) : c.surfaceHigh)
        : Colors.transparent;
    final Color fg = _hover && widget.isClose ? Colors.white : c.textSecondary;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 46,
          height: kDesktopTitleBarHeight,
          color: bg,
          alignment: Alignment.center,
          child: Icon(widget.icon, size: widget.iconSize, color: fg),
        ),
      ),
    );
  }
}
