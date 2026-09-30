import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import '../../utils/platform_utils.dart';

/// Height of the custom desktop title bar.
const double kDesktopTitleBarHeight = 38;

/// Width kept clear on macOS for the native traffic-light buttons.
const double _kMacTrafficLightInset = 76;

/// The window's title bar, drawn in the chrome tone so it reads as one surface
/// with the sidebar (the page content sits below it as an inset panel).
///
///  * macOS keeps the native traffic lights (window_manager's hidden title bar
///    style leaves them in place) — we only reserve room for them.
///  * Windows / Linux get themed minimise / maximise / close controls.
///  * Everything else is a drag region; double-click toggles maximise.
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
    final l10n = AppLocalizations.of(context);
    // Mounted in MaterialApp.builder, above any Scaffold — the Material gives
    // the text a proper DefaultTextStyle (no fallback yellow underline).
    return Material(
      color: context.chromeColor,
      child: SizedBox(
        height: kDesktopTitleBarHeight,
        child: Row(
          children: [
            if (isMacOS) const SizedBox(width: _kMacTrafficLightInset),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: _toggleMaximize,
                onPanStart: (_) => windowManager.startDragging(),
                child: Center(
                  child: Text(
                    l10n?.appTitle ?? '',
                    style: TextStyle(
                      color: c.textTertiary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
            if (!isMacOS) ...[
              _WindowButton(
                icon: Icons.remove_rounded,
                tooltip: l10n?.windowMinimize ?? '',
                onTap: () => windowManager.minimize(),
              ),
              _WindowButton(
                icon: _maximized
                    ? Icons.filter_none_rounded
                    : Icons.crop_square_rounded,
                iconSize: _maximized ? 13 : 15,
                tooltip:
                    (_maximized ? l10n?.windowRestore : l10n?.windowMaximize) ??
                    '',
                onTap: _toggleMaximize,
              ),
              _WindowButton(
                icon: Icons.close_rounded,
                tooltip: l10n?.windowClose ?? '',
                isClose: true,
                onTap: () => windowManager.close(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isClose;
  final double iconSize;
  const _WindowButton({
    required this.icon,
    required this.tooltip,
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
    final c = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final Color bg = _hover
        ? (widget.isClose ? scheme.error : c.hoverFill)
        : Colors.transparent;
    final Color fg = _hover && widget.isClose
        ? scheme.onError
        : c.textSecondary;
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 700),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: Motion.fast,
            width: 46,
            height: kDesktopTitleBarHeight,
            color: bg,
            alignment: Alignment.center,
            child: Icon(widget.icon, size: widget.iconSize, color: fg),
          ),
        ),
      ),
    );
  }
}
