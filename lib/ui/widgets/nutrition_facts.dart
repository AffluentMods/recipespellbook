import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';

/// Shared pieces for every place that shows nutrition: the recipe page, the
/// nutrition calculator, the settings preview and a scanned product. One
/// look for all of them: a soft outlined card, a row of headline tiles and a
/// facts table with the numbers lined up on the right.

/// Digits that keep their width, so a column of values lines up.
const _tabular = [FontFeature.tabularFigures()];

/// A nutrient amount for display: one decimal below 10 ("3.2", "0.4"),
/// whole numbers above, and never a trailing ".0".
String formatNutrientAmount(double value) {
  if (value.abs() < 10 && value != value.roundToDouble()) {
    final text = value.toStringAsFixed(1);
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }
  return value.round().toString();
}

/// The outlined card the nutrition blocks sit in.
class NutritionPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const NutritionPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.lg),
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: Radii.xlAll,
        border: Border.all(color: c.hairline),
      ),
      child: child,
    );
  }
}

/// A small heading inside a nutrition card ("Nutrition (per 100g)").
class NutritionSectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  final IconData? icon;

  const NutritionSectionTitle(this.text, {super.key, this.trailing, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final theme = Theme.of(context);
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: c.accent),
          const SizedBox(width: Space.sm),
        ],
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// One headline number: calories or a macro.
class NutritionTileData {
  final String label;
  final String value;
  final String unit;
  final Color color;

  /// Extra line under the value, such as a share of the calories.
  final String? caption;

  const NutritionTileData({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.caption,
  });
}

/// A row of equal tiles with the headline numbers. The first tile is the
/// one to read first (calories) and gets a tinted fill.
class NutritionTiles extends StatelessWidget {
  final List<NutritionTileData> tiles;

  const NutritionTiles({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: Space.sm),
            Expanded(child: _Tile(data: tiles[i], emphasized: i == 0)),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final NutritionTileData data;
  final bool emphasized;

  const _Tile({required this.data, required this.emphasized});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.sm, Space.md),
      decoration: BoxDecoration(
        color: emphasized ? data.color.withValues(alpha: 0.10) : c.textPrimary.withValues(alpha: 0.035),
        borderRadius: Radii.lgAll,
        border: Border.all(color: emphasized ? data.color.withValues(alpha: 0.25) : c.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: data.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: c.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: data.value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                    height: 1.0,
                    fontFeatures: _tabular,
                  ),
                ),
                TextSpan(
                  text: ' ${data.unit}',
                  style: theme.textTheme.labelMedium?.copyWith(color: c.textTertiary),
                ),
              ]),
              maxLines: 1,
            ),
          ),
          if (data.caption != null) ...[
            const SizedBox(height: 2),
            Text(
              data.caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: c.textTertiary, fontFeatures: _tabular),
            ),
          ],
        ],
      ),
    );
  }
}

/// One line of a [NutritionFactsTable].
class NutritionFact {
  final String label;
  final double value;
  final String unit;

  /// The reference daily amount, for the "% of daily value" column.
  final double? dailyValue;

  /// Indented under the line above (saturated fat under fat).
  final bool isSubItem;

  /// A bar under the line showing the share of the daily value.
  final Color? barColor;

  /// The energy line at the top: a larger number.
  final bool isHeadline;

  const NutritionFact({
    required this.label,
    required this.value,
    required this.unit,
    this.dailyValue,
    this.isSubItem = false,
    this.barColor,
    this.isHeadline = false,
  });

  double? get dailyFraction =>
      dailyValue != null && dailyValue! > 0 ? value / dailyValue! : null;
}

/// A nutrition facts table: label on the left, amount and unit lined up on
/// the right, the share of the daily value in its own column, light rules
/// between the groups. [moreFacts] (minerals and vitamins) start folded
/// away under [moreLabel].
class NutritionFactsTable extends StatefulWidget {
  final List<NutritionFact> facts;
  final List<NutritionFact> moreFacts;
  final String? moreLabel;
  final bool showDailyValue;

  /// Draw a thin bar under each line that has a daily value.
  final bool showBars;

  const NutritionFactsTable({
    super.key,
    required this.facts,
    this.moreFacts = const [],
    this.moreLabel,
    this.showDailyValue = true,
    this.showBars = false,
  });

  @override
  State<NutritionFactsTable> createState() => _NutritionFactsTableState();
}

class _NutritionFactsTableState extends State<NutritionFactsTable> {
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final theme = Theme.of(context);
    final more = widget.moreFacts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._rows(context, widget.facts),
        if (more.isNotEmpty) ...[
          if (widget.facts.isNotEmpty) Divider(height: 1, thickness: 1, color: c.hairline),
          InkWell(
            onTap: () => setState(() => _showMore = !_showMore),
            borderRadius: Radii.mdAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.md),
              child: Row(
                children: [
                  Expanded(
                    child: widget.moreLabel == null
                        ? const SizedBox.shrink()
                        : Text(
                            widget.moreLabel!,
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                    decoration: BoxDecoration(
                      color: c.textPrimary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${more.length}',
                      style: theme.textTheme.labelSmall?.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: Space.xs),
                  AnimatedRotation(
                    turns: _showMore ? 0.5 : 0,
                    duration: Motion.base,
                    curve: Motion.standard,
                    child: Icon(Icons.expand_more_rounded, size: 20, color: c.textTertiary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: Motion.base,
            curve: Motion.standard,
            alignment: Alignment.topCenter,
            child: _showMore
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _rows(context, more),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ],
    );
  }

  List<Widget> _rows(BuildContext context, List<NutritionFact> facts) {
    final c = context.appColors;
    final rows = <Widget>[];
    for (var i = 0; i < facts.length; i++) {
      final fact = facts[i];
      // A rule before each top-level line keeps a parent with its sub-items.
      if (i > 0 && !fact.isSubItem) {
        rows.add(Divider(height: 1, thickness: 1, color: c.hairline));
      }
      rows.add(_FactRow(fact: fact, showDailyValue: widget.showDailyValue, showBar: widget.showBars));
    }
    return rows;
  }
}

class _FactRow extends StatelessWidget {
  final NutritionFact fact;
  final bool showDailyValue;
  final bool showBar;

  const _FactRow({required this.fact, required this.showDailyValue, required this.showBar});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final theme = Theme.of(context);
    final sub = fact.isSubItem;
    final headline = fact.isHeadline;
    final fraction = fact.dailyFraction;
    final labelStyle = sub
        ? theme.textTheme.bodySmall?.copyWith(color: c.textSecondary)
        : (headline ? theme.textTheme.bodyLarge : theme.textTheme.bodyMedium)
            ?.copyWith(fontWeight: headline ? FontWeight.w700 : FontWeight.w600, color: c.textPrimary);
    final valueStyle = (sub
            ? theme.textTheme.bodySmall
            : headline
                ? theme.textTheme.titleLarge
                : theme.textTheme.bodyMedium)
        ?.copyWith(
      fontWeight: sub ? FontWeight.w500 : (headline ? FontWeight.w700 : FontWeight.w600),
      color: sub ? c.textSecondary : c.textPrimary,
      fontFeatures: _tabular,
      height: headline ? 1.1 : null,
    );

    final barColor = fact.barColor ??
        (fraction == null
            ? c.accent
            : fraction > 1
                ? c.destructive
                : c.accent);

    return Padding(
      padding: EdgeInsets.only(
        left: sub ? Space.lg : 0,
        top: sub ? 5 : 9,
        bottom: sub ? 5 : 9,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(fact.label, style: labelStyle)),
              const SizedBox(width: Space.sm),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: formatNutrientAmount(fact.value), style: valueStyle),
                  TextSpan(
                    text: ' ${fact.unit}',
                    style: theme.textTheme.bodySmall?.copyWith(color: c.textTertiary),
                  ),
                ]),
              ),
              if (showDailyValue)
                SizedBox(
                  width: 52,
                  child: fraction == null
                      ? null
                      : Text(
                          '${(fraction * 100).round()}%',
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: c.textTertiary,
                            fontFeatures: _tabular,
                          ),
                        ),
                ),
            ],
          ),
          if (showBar && fraction != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: fraction.clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: c.textPrimary.withValues(alpha: 0.07),
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
