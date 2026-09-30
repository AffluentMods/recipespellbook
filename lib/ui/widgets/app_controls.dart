import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import 'keycap.dart';

// ═══════════════════════════════════════════════════════════════════
// Shared controls of the app's design language. Built pointer-first for the
// desktop shell, but token-driven and size-agnostic so phone/tablet screens
// can adopt them too.
// ═══════════════════════════════════════════════════════════════════

/// A selectable list row: leading icon, label, optional trailing (count,
/// keycap, chevron). Hover / pressed / selected / focus states all come from
/// the theme's accent and text tones, so it works in every palette.
///
/// Used by the desktop sidebar, the settings section list and the shopping
/// lists pane — anything that is "one of N places".
class NavRow extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? tooltip;

  /// Icon-only presentation (collapsed sidebar). The label moves into the
  /// tooltip.
  final bool iconOnly;
  final double height;
  final Color? iconColor;
  final void Function(Offset globalPosition)? onSecondaryTap;

  const NavRow({
    super.key,
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.selected = false,
    this.onTap,
    this.trailing,
    this.tooltip,
    this.iconOnly = false,
    this.height = DesktopMetrics.rowHeight,
    this.iconColor,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final fg = selected ? c.textPrimary : c.textSecondary;
    final iconFg = iconColor ?? (selected ? c.accent : c.textTertiary);

    Widget row = Material(
      color: selected ? c.selectedFill : Colors.transparent,
      borderRadius: Radii.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.mdAll,
        hoverColor: c.hoverFill,
        highlightColor: c.pressedFill,
        splashFactory: NoSplash.splashFactory,
        focusColor: c.accent.withValues(alpha: 0.12),
        onSecondaryTapUp: onSecondaryTap == null
            ? null
            : (d) => onSecondaryTap!(d.globalPosition),
        child: SizedBox(
          height: height,
          child: iconOnly
              ? Center(
                  child: Icon(
                    selected ? (selectedIcon ?? icon) : icon,
                    size: 19,
                    color: iconFg,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.sm + 2),
                  child: Row(
                    children: [
                      Icon(
                        selected ? (selectedIcon ?? icon) : icon,
                        size: 18,
                        color: iconFg,
                      ),
                      const SizedBox(width: Space.md - 1),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.2,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: fg,
                          ),
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: Space.sm),
                        trailing!,
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );

    final tip = tooltip ?? (iconOnly ? label : null);
    if (tip != null) {
      row = Tooltip(
        message: tip,
        waitDuration: const Duration(milliseconds: 500),
        preferBelow: false,
        verticalOffset: iconOnly ? 0 : 20,
        child: row,
      );
    }
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: row,
    );
  }
}

/// A quiet count shown at the end of a [NavRow] (item totals, not alerts).
class RowCount extends StatelessWidget {
  final int count;
  final bool emphasized;
  const RowCount(this.count, {super.key, this.emphasized = false});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Text(
      count > 999 ? '999+' : '$count',
      style: TextStyle(
        fontSize: 12,
        fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
        color: emphasized ? c.accent : c.textTertiary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// Small uppercase label that heads a group of rows ("LIBRARY", "PLAN").
class GroupLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;
  const GroupLabel(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(
      Space.sm + 2,
      Space.lg,
      Space.sm,
      Space.xs + 2,
    ),
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
                color: c.textTertiary,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Compact square icon button for toolbars and page headers: 32 px, hover
/// fill, tooltip that includes the keyboard shortcut when there is one.
class ToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final String? shortcut;
  final VoidCallback? onPressed;
  final bool selected;
  final double size;
  final double iconSize;
  final Color? color;

  const ToolbarIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.shortcut,
    this.selected = false,
    this.size = 32,
    this.iconSize = 18,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Tooltip(
      message: withShortcut(tooltip, shortcut),
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: selected ? c.selectedFill : Colors.transparent,
        borderRadius: Radii.mdAll,
        child: InkWell(
          onTap: onPressed,
          borderRadius: Radii.mdAll,
          hoverColor: c.hoverFill,
          highlightColor: c.pressedFill,
          splashFactory: NoSplash.splashFactory,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: iconSize,
              color: onPressed == null
                  ? c.textTertiary.withValues(alpha: 0.5)
                  : (color ?? (selected ? c.accent : c.textSecondary)),
            ),
          ),
        ),
      ),
    );
  }
}

/// The page header of the design language: an editorial Fraunces title with
/// an optional subtitle / leading control, actions right-aligned, and an
/// optional second row (filters, tabs, search) underneath. Replaces the
/// mobile AppBar on desktop-class widths.
///
/// Implements [PreferredSizeWidget] so it can be a `Scaffold.appBar`.
class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  /// Custom title content (e.g. a switcher); overrides [title].
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? bottom;
  final double bottomHeight;
  final EdgeInsetsGeometry padding;

  /// Hairline under the header (use when content scrolls beneath it).
  final bool divider;

  const PageHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.bottom,
    this.bottomHeight = 44,
    this.padding = const EdgeInsets.fromLTRB(
      Space.xxxl - 4,
      Space.lg + 2,
      Space.xl,
      Space.md,
    ),
    this.divider = false,
  }) : assert(title != null || titleWidget != null);

  @override
  Size get preferredSize => Size.fromHeight(
    DesktopMetrics.pageHeaderHeight +
        6 +
        (subtitle != null ? 18 : 0) +
        (bottom != null ? bottomHeight : 0),
  );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.appColors;
    final titleStyle = t.textTheme.headlineSmall?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.15,
      color: c.textPrimary,
    );
    return Material(
      color: c.surface,
      child: Container(
        decoration: divider
            ? BoxDecoration(
                border: Border(bottom: BorderSide(color: c.hairline)),
              )
            : null,
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 36 + (subtitle != null ? 18 : 0),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: Space.sm),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DefaultTextStyle.merge(
                          style: titleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          child: titleWidget ?? Text(title!),
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.textTheme.bodySmall?.copyWith(
                                color: c.textTertiary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  for (var i = 0; i < actions.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        left: i == 0 ? Space.md : Space.xs + 2,
                      ),
                      child: actions[i],
                    ),
                ],
              ),
            ),
            if (bottom != null) ...[
              const SizedBox(height: Space.sm),
              SizedBox(height: bottomHeight - Space.sm, child: bottom!),
            ],
          ],
        ),
      ),
    );
  }
}

/// Back button sized for [PageHeader] / pointer UI.
class HeaderBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const HeaderBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ToolbarIconButton(
      icon: Icons.arrow_back_rounded,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
    );
  }
}

/// A search field sized for toolbars (34 px) with a leading magnifier, an
/// optional keycap hint and a clear button once text is entered.
class ToolbarSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? shortcutHint;
  final bool autofocus;
  final double width;

  const ToolbarSearchField({
    super.key,
    this.controller,
    this.focusNode,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.shortcutHint,
    this.autofocus = false,
    this.width = 240,
  });

  @override
  State<ToolbarSearchField> createState() => _ToolbarSearchFieldState();
}

class _ToolbarSearchFieldState extends State<ToolbarSearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onText);
  }

  void _onText() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onText);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final hasText = _controller.text.isNotEmpty;
    return SizedBox(
      width: widget.width,
      height: DesktopMetrics.controlHeight,
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: TextStyle(fontSize: 13.5, color: c.textPrimary),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: c.textPrimary.withValues(alpha: 0.045),
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 13.5, color: c.textTertiary),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Space.sm,
            vertical: 0,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 17,
            color: c.textTertiary,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          suffixIcon: hasText
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: c.textTertiary,
                  ),
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).deleteButtonTooltip,
                  splashRadius: 14,
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                  },
                )
              : (widget.shortcutHint != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: Space.sm),
                        child: Keycap(widget.shortcutHint!, dense: true),
                      )
                    : null),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 28,
            minHeight: 28,
          ),
          border: OutlineInputBorder(
            borderRadius: Radii.mdAll,
            borderSide: BorderSide(color: c.hairline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: Radii.mdAll,
            borderSide: BorderSide(color: c.hairline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: Radii.mdAll,
            borderSide: BorderSide(color: c.accent, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Touch lists — the phone / tablet counterpart of [NavRow]: the same tones
// and hairlines, sized for fingers.
// ═══════════════════════════════════════════════════════════════════

/// A hairline-outlined group of [TouchRow]s (the "inset grouped" list of the
/// More page and settings). Rows are separated by hairlines inset past the
/// leading icon.
class TouchGroup extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  const TouchGroup({
    super.key,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: Space.lg),
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: margin,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: Radii.lgAll,
          border: Border.all(color: c.hairline),
        ),
        child: Material(
          color: c.surface,
          borderRadius: Radii.lgAll,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 52),
                    child: Divider(height: 1, thickness: 1, color: c.hairline),
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One row of a [TouchGroup]: leading icon, title, optional subtitle and a
/// trailing widget (count, switch, value) followed by a chevron when it
/// navigates. At least 52 px tall.
class TouchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Show a disclosure chevron (navigates somewhere). Off for actions that
  /// open a sheet or dialog in place and for rows with a control.
  final bool chevron;
  final bool destructive;
  final Color? iconColor;

  const TouchRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.chevron = true,
    this.destructive = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final fg = destructive ? c.destructive : c.textPrimary;
    return InkWell(
      onTap: onTap,
      highlightColor: c.pressedFill,
      splashColor: c.pressedFill,
      hoverColor: c.hoverFill,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.lg, Space.sm + 2, Space.md, Space.sm + 2),
          child: Row(
            children: [
              Icon(
                icon,
                size: 21,
                color: destructive ? c.destructive : (iconColor ?? c.textSecondary),
              ),
              const SizedBox(width: Space.lg - 1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        color: fg,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.3,
                          color: c.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: Space.sm),
                trailing!,
              ],
              if (chevron && onTap != null) ...[
                const SizedBox(width: Space.xs),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: c.textTertiary.withValues(alpha: 0.7),
                ),
              ] else
                const SizedBox(width: Space.xs),
            ],
          ),
        ),
      ),
    );
  }
}

/// Title for touch app bars: the Fraunces page title at 24 px, one line.
/// Pair with `centerTitle: false` and the page tone as the bar colour.
class TouchPageTitle extends StatelessWidget {
  final String text;
  const TouchPageTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: context.appColors.textPrimary,
          ),
    );
  }
}

/// Section heading for touch layouts: the [GroupLabel] style with page
/// gutters, sitting above a [TouchGroup].
class TouchGroupLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const TouchGroupLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => GroupLabel(
    text,
    trailing: trailing,
    // Text lines up with the icons of the rows below (group gutter + row
    // padding).
    padding: const EdgeInsets.fromLTRB(
      Space.xxxl,
      Space.xxl,
      Space.xl,
      Space.sm,
    ),
  );
}

/// The primary floating action on touch layouts: an accent pill with an icon
/// and label that folds to the icon alone ([extended] false) — pages fold it
/// while the user scrolls into content.
class AccentFab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool extended;
  final VoidCallback? onPressed;

  const AccentFab({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.extended = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Tooltip(
      message: label,
      child: Material(
        color: c.accent,
        elevation: 3,
        shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.4),
        borderRadius: Radii.xlAll,
        child: InkWell(
          borderRadius: Radii.xlAll,
          onTap: onPressed,
          child: AnimatedSize(
            duration: Motion.slow,
            curve: Motion.standard,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: extended ? Space.xl : Space.lg),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 24, color: c.onAccent),
                    if (extended) ...[
                      const SizedBox(width: Space.sm),
                      Text(
                        label,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.onAccent),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Search field for touch layouts (46 px): the same quiet fill and hairline
/// as [ToolbarSearchField], with a clear button once there is text.
class TouchSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final TextInputAction? textInputAction;

  const TouchSearchField({
    super.key,
    this.controller,
    this.focusNode,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.textInputAction,
  });

  @override
  State<TouchSearchField> createState() => _TouchSearchFieldState();
}

class _TouchSearchFieldState extends State<TouchSearchField> {
  late final TextEditingController _controller = widget.controller ?? TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onText);
  }

  void _onText() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onText);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final border = OutlineInputBorder(
      borderRadius: Radii.lgAll,
      borderSide: BorderSide(color: c.hairline),
    );
    return SizedBox(
      height: 46,
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: widget.textInputAction ?? TextInputAction.search,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        style: TextStyle(fontSize: 15, color: c.textPrimary),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: c.textPrimary.withValues(alpha: 0.045),
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 15, color: c.textTertiary),
          contentPadding: const EdgeInsets.symmetric(horizontal: Space.md),
          prefixIcon: Icon(Icons.search_rounded, size: 21, color: c.textTertiary),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close_rounded, size: 19, color: c.textTertiary),
                  tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                  },
                ),
          border: border,
          enabledBorder: border,
          focusedBorder: OutlineInputBorder(
            borderRadius: Radii.lgAll,
            borderSide: BorderSide(color: c.accent, width: 1.5),
          ),
        ),
      ),
    );
  }
}

/// One option of a [TouchSegmented] control.
class TouchSegment<T> {
  final T value;
  final String label;
  final IconData? icon;
  const TouchSegment({required this.value, required this.label, this.icon});
}

/// Two-to-four-way switch for touch layouts: a quiet track with a paper
/// thumb under the chosen option (lifted a tone in dark mode). [expand]
/// shares the full width equally.
class TouchSegmented<T> extends StatelessWidget {
  final List<TouchSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool expand;

  const TouchSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    Widget segment(TouchSegment<T> s) {
      final on = s.value == selected;
      final child = Semantics(
        selected: on,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!on) {
              HapticFeedback.selectionClick();
              onChanged(s.value);
            }
          },
          child: AnimatedContainer(
            duration: Motion.fast,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: Space.md),
            decoration: BoxDecoration(
              color: on ? (dark ? c.surfaceHigh : c.surface) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: on ? Border.all(color: c.hairline) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (s.icon != null) ...[
                  Icon(s.icon, size: 16, color: on ? c.accent : c.textTertiary),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    s.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                      color: on ? c.textPrimary : c.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return expand ? Expanded(child: child) : child;
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.textPrimary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [for (final s in segments) segment(s)],
      ),
    );
  }
}

/// Selectable pill for touch filter rows (sort orders, quick filters): a
/// hairline pill that fills with the soft accent when chosen.
class TouchChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const TouchChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? c.selectedFill : Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: selected ? c.accent.withValues(alpha: 0.4) : c.hairline)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? c.accent : c.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Square outlined icon button that sits beside a [TouchSearchField] (tags,
/// sort, filters): 46 px, hairline, accent when [active].
class TouchFieldButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool active;
  final int badge;

  const TouchFieldButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.active = false,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    Widget iconWidget = Icon(icon, size: 21, color: active ? c.accent : c.textSecondary);
    if (badge > 0) {
      iconWidget = Badge(
        label: Text('$badge'),
        backgroundColor: c.accent,
        textColor: c.onAccent,
        child: iconWidget,
      );
    }
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? c.selectedFill : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.lgAll,
          side: BorderSide(color: active ? c.accent.withValues(alpha: 0.4) : c.hairline),
        ),
        child: InkWell(
          borderRadius: Radii.lgAll,
          onTap: onPressed,
          child: SizedBox(width: 46, height: 46, child: Center(child: iconWidget)),
        ),
      ),
    );
  }
}

/// Wraps a clickable surface that isn't an InkWell (bare GestureDetector,
/// custom painter…) with the pointer cursor, a hover flag and keyboard focus +
/// activation, so every clickable thing behaves like a control.
class Clickable extends StatefulWidget {
  final Widget Function(BuildContext context, bool hovered) builder;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const Clickable({
    super.key,
    required this.builder,
    this.onTap,
    this.semanticLabel,
  });

  @override
  State<Clickable> createState() => _ClickableState();
}

class _ClickableState extends State<Clickable> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: widget.builder(context, _hovered || _focused),
        ),
      ),
    );
  }
}
