import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import '../../utils/responsive_utils.dart';
import 'app_controls.dart';

/// Adaptive page scaffold: on desktop-class widths a [PageHeader] (editorial
/// title, optional subtitle / leading, right-aligned actions) over the body;
/// below that a conventional `Scaffold(appBar: AppBar(...))`, so phone and
/// tablet UX are unchanged.
///
/// When [bodyMaxWidth] is set the body becomes a capped column. If the body is
/// a scrollable, prefer building it with [Responsive.constrainScrollable]
/// instead so the wheel works across the whole pane.
class DesktopPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? leading;
  final Widget body;
  final double? bodyMaxWidth;
  final bool alignStart;
  final Widget? floatingActionButton;

  const DesktopPage({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions = const [],
    this.leading,
    this.bodyMaxWidth,
    this.alignStart = true,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    if (!Responsive.isDesktopLayout(context)) {
      return Scaffold(
        appBar: AppBar(leading: leading, title: Text(title), actions: actions),
        floatingActionButton: floatingActionButton,
        body: body,
      );
    }
    final c = context.appColors;
    Widget content = body;
    if (bodyMaxWidth != null) {
      content = Align(
        alignment: alignStart ? Alignment.topLeft : Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: bodyMaxWidth!),
          child: content,
        ),
      );
    }
    // Desktop never shows a floating action button — put the primary action
    // in [actions] instead.
    return Scaffold(
      backgroundColor: c.surface,
      appBar: DesktopHeaderBar(
        title: title,
        subtitle: subtitle,
        leading: leading,
        actions: actions,
      ),
      body: content,
    );
  }
}

/// The standalone page header row — now the design language's [PageHeader].
/// Kept as a named wrapper for screens with custom bodies.
class DesktopHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  const DesktopHeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
  });

  PageHeader get _header => PageHeader(
        title: title,
        subtitle: subtitle,
        leading: leading,
        actions: actions,
      );

  @override
  Size get preferredSize => _header.preferredSize;

  @override
  Widget build(BuildContext context) => _header;
}

/// Shared left-aligned "LABEL ——— divider (+trailing)" section header for
/// desktop pages.
class DesktopSectionHeader extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const DesktopSectionHeader({
    super.key,
    required this.label,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(Space.xs, Space.xl, Space.xs, Space.sm),
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5,
              color: c.textTertiary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(width: Space.md),
          Expanded(child: Divider(height: 1, thickness: 1, color: c.hairline)),
          if (trailing != null) ...[const SizedBox(width: Space.md), trailing!],
        ],
      ),
    );
  }
}
