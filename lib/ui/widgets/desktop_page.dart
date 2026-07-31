import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive_utils.dart';

/// Adaptive page scaffold for the "Codex" desktop makeover.
///
/// On desktop (>=900 content width) it renders a warm, LEFT-aligned editorial
/// header (title + optional subtitle + right-aligned actions + a hairline
/// divider) over an optionally width-constrained body. Below that width it
/// degrades to a conventional `Scaffold(appBar: AppBar(...))`, so mobile and
/// tablet UX are unchanged.
///
/// IMPORTANT: when [bodyMaxWidth] is set, [body] must be a *scrollable*
/// (ListView / CustomScrollView / SingleChildScrollView) — it is placed in an
/// Expanded with loose height, so a `Column(mainAxisSize: min)` body would
/// collapse. Constrain inner scroll content instead for tabbed bodies.
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
    return Scaffold(
      backgroundColor: c.surface,
      floatingActionButton: floatingActionButton,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DesktopHeaderBar(
            title: title,
            subtitle: subtitle,
            leading: leading,
            actions: actions,
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}

/// The standalone editorial header row (leading? + title/subtitle + actions),
/// used by [DesktopPage] and reusable by screens with custom bodies (e.g. a
/// TabBar body that can't be handed to DesktopPage directly).
class DesktopHeaderBar extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.outline.withValues(alpha: 0.25))),
      ),
      padding: const EdgeInsets.fromLTRB(32, 18, 20, 16),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: t.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: c.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: t.textTheme.bodyMedium?.copyWith(color: c.textTertiary),
                  ),
                ],
              ],
            ),
          ),
          for (final a in actions)
            Padding(padding: const EdgeInsets.only(left: 6), child: a),
        ],
      ),
    );
  }
}

/// Shared left-aligned "LABEL ——— divider (+trailing)" section header for
/// desktop, replacing the many ad-hoc private section titles.
class DesktopSectionHeader extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const DesktopSectionHeader({
    super.key,
    required this.label,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(4, 20, 4, 8),
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.appColors;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: t.textTheme.labelMedium?.copyWith(
              color: c.textTertiary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(height: 1, color: c.outline.withValues(alpha: 0.2))),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}
