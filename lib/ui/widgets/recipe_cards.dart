import 'package:flutter/material.dart';

import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import '../../utils/duration_format.dart';
import '../../utils/recipe_title.dart';
import 'app_context_menu.dart';
import 'recipe_image.dart';

/// "4 servings" for a bare count or range; "8 slices" keeps its own unit.
/// Null when the recipe doesn't say.
String? servingsLabel(AppLocalizations l10n, String? servings) {
  final v = servings?.trim() ?? '';
  if (v.isEmpty) return null;
  return RegExp(r'[^\d\s.,/~\-–]').hasMatch(v) ? v : '$v ${l10n.servingsUnit}';
}

/// "25 min · 4 servings" — the one-line recipe summary used on cards/rows.
String recipeMetaLine(AppLocalizations l10n, Recipe recipe) {
  final parts = <String>[
    if (formatTotalDuration(l10n, recipe.prepTimeMinutes, recipe.cookTimeMinutes)
        case final t?)
      t,
    ?servingsLabel(l10n, recipe.servings),
  ];
  return parts.join(' · ');
}

/// Picture-first recipe card for pointer UIs (library grids, the desktop home
/// dashboard). Image on top at a fixed aspect, then title and a quiet meta
/// line on the page surface — not a text-over-photo overlay, so titles stay
/// legible over any photo and in every palette.
///
/// Hover lifts the card and reveals the favourite toggle; right-click opens
/// [contextItems]; [selected] (multi-select) and [active] (open in the detail
/// pane) use the accent ring.
class RecipeGridCard extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;
  final List<ContextMenuItem> contextItems;
  final bool selected;
  final bool active;
  final bool selecting;
  final double imageAspectRatio;

  /// Small marker over the photo's top-left corner (e.g. why a recipe is in
  /// a "jump back in" row: pinned / planned).
  final Widget? badge;

  /// Long-press (touch): enter multi-select, context actions…
  final VoidCallback? onLongPress;

  const RecipeGridCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onToggleFavorite,
    this.contextItems = const [],
    this.selected = false,
    this.active = false,
    this.selecting = false,
    this.imageAspectRatio = 4 / 3,
    this.badge,
    this.onLongPress,
  });

  /// Height of the text block under the image: a fixed two-line title area
  /// plus the meta line, so every card in a row lines up.
  static const double textBlockHeight = 82;

  @override
  State<RecipeGridCard> createState() => _RecipeGridCardState();
}

class _RecipeGridCardState extends State<RecipeGridCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final recipe = widget.recipe;
    final meta = recipeMetaLine(l10n, recipe);
    final ring = widget.selected || widget.active;

    final image = AspectRatio(
      aspectRatio: widget.imageAspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: c.surfaceHigh,
            child: RecipeImage.medium(
              imagePath: recipe.imagePath,
              recipeId: recipe.id,
              recipeName: recipe.title,
              course: recipe.courseId,
              category: recipe.categoryId,
            ),
          ),
          // Favourite: always visible when set, toggle revealed on hover.
          if (!widget.selecting &&
              widget.onToggleFavorite != null &&
              (recipe.isFavorite || _hovered))
            Positioned(
              top: Space.sm,
              right: Space.sm,
              child: _ImageIconButton(
                icon: recipe.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: recipe.isFavorite ? c.favorite : null,
                tooltip: l10n.bulkFavorite,
                onTap: widget.onToggleFavorite!,
              ),
            ),
          if (widget.selecting)
            Positioned(
              top: Space.sm,
              left: Space.sm,
              child: _SelectionDot(selected: widget.selected),
            )
          else if (widget.badge != null)
            Positioned(top: Space.sm, left: Space.sm, child: widget.badge!),
        ],
      ),
    );

    final card = AnimatedContainer(
      duration: Motion.fast,
      curve: Motion.standard,
      transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: Radii.lgAll,
        border: Border.all(
          color: ring ? c.accent : (_hovered ? c.textPrimary.withValues(alpha: 0.14) : c.hairline),
          width: ring ? 2 : 1,
        ),
        boxShadow: [
          if (_hovered)
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ring ? Radii.lg - 2 : Radii.lg - 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            image,
            SizedBox(
              height: RecipeGridCard.textBlockHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Space.md, Space.sm + 2, Space.md, Space.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 36,
                      child: _ClampedTitle(
                        normalizeTitle(recipe.title).title,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.28,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: c.textTertiary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return ContextMenuRegion(
      items: widget.contextItems,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          behavior: HitTestBehavior.opaque,
          child: Semantics(button: true, selected: widget.selected, child: card),
        ),
      ),
    );
  }
}

/// A two-line title that offers the full text as a tooltip only when it is
/// actually cut off (as Finder does), instead of repeating visible text.
class _ClampedTitle extends StatelessWidget {
  final String text;
  final TextStyle style;
  const _ClampedTitle(this.text, {required this.style});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final label = Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: style);
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 2,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: constraints.maxWidth);
      final clipped = painter.didExceedMaxLines;
      painter.dispose();
      if (!clipped) return label;
      return Tooltip(
        message: text,
        waitDuration: const Duration(milliseconds: 700),
        child: label,
      );
    });
  }
}

/// Picture-first grid for pointer layouts. Tiles are capped at [maxTileWidth]
/// — wider windows get more columns, never bigger cards — and every card has
/// the same height, so rows line up.
class RecipeCardGrid extends StatelessWidget {
  final List<Recipe> recipes;
  final void Function(Recipe recipe) onTap;
  final void Function(Recipe recipe)? onToggleFavorite;
  final List<ContextMenuItem> Function(BuildContext context, Recipe recipe)? contextItemsBuilder;
  final bool selecting;
  final Set<String> selectedIds;
  final double maxTileWidth;
  final EdgeInsets padding;
  final String? storageKey;
  final void Function(Recipe recipe)? onLongPress;
  final double gap;
  final ScrollPhysics? physics;

  /// Optional marker over each card's photo (why it is in this list).
  final Widget? Function(Recipe recipe)? badgeBuilder;

  const RecipeCardGrid({
    super.key,
    required this.recipes,
    required this.onTap,
    this.onToggleFavorite,
    this.contextItemsBuilder,
    this.selecting = false,
    this.selectedIds = const {},
    this.maxTileWidth = 250,
    this.padding = const EdgeInsets.fromLTRB(Space.xxxl - 4, Space.xs, Space.xxxl - 4, 96),
    this.storageKey,
    this.onLongPress,
    this.gap = Space.lg,
    this.physics,
    this.badgeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final avail = constraints.maxWidth - padding.horizontal;
      final columns = maxTileWidth >= avail
          ? 1
          : ((avail + gap) / (maxTileWidth + gap)).ceil().clamp(2, 12);
      final tileWidth = (avail - gap * (columns - 1)) / columns;
      final tileHeight = tileWidth * 3 / 4 + RecipeGridCard.textBlockHeight + 2;
      return GridView.builder(
        key: storageKey == null ? null : PageStorageKey(storageKey),
        physics: physics,
        padding: padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisExtent: tileHeight,
          crossAxisSpacing: gap,
          mainAxisSpacing: gap + 4,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, i) {
          final r = recipes[i];
          return RecipeGridCard(
            key: ValueKey(r.id),
            recipe: r,
            selecting: selecting,
            selected: selectedIds.contains(r.id),
            contextItems: contextItemsBuilder?.call(context, r) ?? const [],
            onTap: () => onTap(r),
            onLongPress: onLongPress == null ? null : () => onLongPress!(r),
            onToggleFavorite: onToggleFavorite == null ? null : () => onToggleFavorite!(r),
            badge: badgeBuilder?.call(r),
          );
        },
      );
    });
  }
}

/// Dense list row for a recipe (desktop master list, search results):
/// thumbnail, title, meta line, favourite mark. [active] = open in the detail
/// pane; [selected] = part of a multi-selection.
class RecipeListRow extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final List<ContextMenuItem> contextItems;
  final bool active;
  final bool selected;
  final bool selecting;
  final Widget? trailing;
  final VoidCallback? onLongPress;

  const RecipeListRow({
    super.key,
    required this.recipe,
    required this.onTap,
    this.contextItems = const [],
    this.active = false,
    this.selected = false,
    this.selecting = false,
    this.trailing,
    this.onLongPress,
  });

  static const double height = 60;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final meta = recipeMetaLine(l10n, recipe);
    final highlighted = active || selected;

    return ContextMenuRegion(
      items: contextItems,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 1),
        child: Material(
          color: highlighted ? c.selectedFill : Colors.transparent,
          borderRadius: Radii.mdAll,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: Radii.mdAll,
            hoverColor: c.hoverFill,
            highlightColor: c.pressedFill,
            splashFactory: NoSplash.splashFactory,
            child: SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.sm),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: Radii.mdAll,
                            child: ColoredBox(
                              color: c.surfaceHigh,
                              child: RecipeImage.thumbnail(
                                imagePath: recipe.imagePath,
                                recipeId: recipe.id,
                                recipeName: recipe.title,
                                course: recipe.courseId,
                                category: recipe.categoryId,
                                height: 44,
                              ),
                            ),
                          ),
                          if (selecting)
                            Positioned(
                              top: -2,
                              left: -2,
                              child: _SelectionDot(selected: selected, size: 18),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            normalizeTitle(recipe.title).title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                              color: c.textPrimary,
                            ),
                          ),
                          if (meta.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: c.textTertiary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (recipe.isFavorite)
                      Padding(
                        padding: const EdgeInsets.only(left: Space.sm),
                        child: Icon(Icons.favorite_rounded, size: 14, color: c.favorite),
                      ),
                    if (trailing != null) trailing!,
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

/// Round marker for [RecipeGridCard.badge]: an icon on a frosted surface
/// disc, legible over any photo.
class RecipeCardBadge extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final Color? color;
  const RecipeCardBadge({super.key, required this.icon, this.tooltip, this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final disc = Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 14, color: color ?? c.textSecondary),
    );
    return tooltip == null ? disc : Tooltip(message: tooltip!, child: disc);
  }
}

class _SelectionDot extends StatelessWidget {
  final bool selected;
  final double size;
  const _SelectionDot({required this.selected, this.size = 22});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return AnimatedContainer(
      duration: Motion.fast,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? c.accent : c.surface.withValues(alpha: 0.85),
        border: Border.all(color: selected ? c.accent : c.textPrimary.withValues(alpha: 0.35), width: 1.5),
      ),
      child: selected ? Icon(Icons.check_rounded, size: size * 0.7, color: c.onAccent) : null,
    );
  }
}

class _ImageIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String tooltip;
  final VoidCallback onTap;
  const _ImageIconButton({required this.icon, required this.tooltip, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.surface.withValues(alpha: 0.88),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(icon, size: 16, color: color ?? c.textSecondary),
          ),
        ),
      ),
    );
  }
}
