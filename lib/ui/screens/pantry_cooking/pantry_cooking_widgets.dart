import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/pantry_cooking_provider.dart';
import '../../../services/pantry_cooking_service.dart';
import '../../../services/recipe_suggestion_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../utils/recipe_title.dart';
import '../../widgets/app_controls.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/recipe_image.dart';
import 'pantry_editor.dart';

/// Where "What can I make?" lives.
const pantryCookingPath = '/pantry-cooking';

// ── Shared actions ──

/// Put the missing lines of [match] on the active shopping list and say so,
/// with a way to open the list.
Future<void> addMissingToShoppingList(
  BuildContext context,
  WidgetRef ref,
  PantryRecipeMatch match,
) async {
  final l10n = AppLocalizations.of(context)!;
  final router = GoRouter.of(context);
  try {
    final result = await addIngredientsToShoppingList(
      dao: ref.read(shoppingDaoProvider),
      recipe: match.recipe,
      ingredients: match.missing,
      newListName: l10n.defaultShoppingListName,
    );
    if (!context.mounted) return;
    final listName = result.list.name;
    final message = result.combined > 0 && result.added > 0
        ? l10n.shoppingAddedAndCombined(result.added, result.combined, listName)
        : result.combined > 0
            ? l10n.shoppingItemsUpdated(result.combined, listName)
            : l10n.shoppingAddedToList(result.added, listName);
    AppSnackbar.successWithAction(
      context,
      message,
      actionLabel: l10n.viewList,
      onAction: () => router.go('/shopping'),
    );
  } catch (e) {
    if (context.mounted) AppSnackbar.error(context, l10n.shoppingAddError(e.toString()));
  }
}

/// Add [name] to the pantry, with an undo.
Future<void> addToPantryWithUndo(BuildContext context, WidgetRef ref, String name) async {
  final l10n = AppLocalizations.of(context)!;
  final notifier = ref.read(pantryProvider.notifier);
  await notifier.add(name);
  if (!context.mounted) return;
  AppSnackbar.successWithAction(
    context,
    l10n.pantryCookAddedToPantry(name),
    actionLabel: l10n.actionUndo,
    onAction: () => notifier.remove(name),
  );
}

/// Open "What can I make?".
void openPantryCooking(BuildContext context) => context.push(pantryCookingPath);

// ── Dinner reasons ──

String dinnerReasonLabel(AppLocalizations l10n, DinnerReason reason) => switch (reason.kind) {
      DinnerReasonKind.allInPantry => l10n.dinnerReasonAllInPantry,
      DinnerReasonKind.favouriteNotLately => l10n.dinnerReasonFavouriteWeeks(reason.value),
      DinnerReasonKind.favourite => l10n.dinnerReasonFavourite,
      DinnerReasonKind.almostInPantry => l10n.dinnerReasonMissing(reason.value),
      DinnerReasonKind.quick => l10n.dinnerReasonQuick(reason.value),
      DinnerReasonKind.lastMade => l10n.dinnerReasonLastMade(reason.value),
      DinnerReasonKind.notOpened => l10n.dinnerReasonNotOpened(reason.value),
      DinnerReasonKind.highlyRated => l10n.dinnerReasonRated(reason.value),
      DinnerReasonKind.notTriedYet => l10n.dinnerReasonNew,
      DinnerReasonKind.fromLibrary => l10n.dinnerReasonFromLibrary,
    };

IconData _reasonIcon(DinnerReasonKind kind) => switch (kind) {
      DinnerReasonKind.allInPantry => Icons.kitchen_rounded,
      DinnerReasonKind.favouriteNotLately || DinnerReasonKind.favourite => Icons.favorite_rounded,
      DinnerReasonKind.almostInPantry => Icons.shopping_basket_rounded,
      DinnerReasonKind.quick => Icons.bolt_rounded,
      DinnerReasonKind.lastMade || DinnerReasonKind.notOpened => Icons.history_rounded,
      DinnerReasonKind.highlyRated => Icons.star_rounded,
      DinnerReasonKind.notTriedYet => Icons.auto_awesome_rounded,
      DinnerReasonKind.fromLibrary => Icons.menu_book_rounded,
    };

/// The small "why" pill on a dinner suggestion.
class DinnerReasonChip extends StatelessWidget {
  final DinnerReason reason;
  const DinnerReasonChip({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final favourite = reason.kind == DinnerReasonKind.favouriteNotLately ||
        reason.kind == DinnerReasonKind.favourite;
    final strong = favourite ||
        reason.kind == DinnerReasonKind.allInPantry ||
        reason.kind == DinnerReasonKind.almostInPantry;
    final tone = favourite ? c.favorite : (strong ? c.accent : c.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 3),
      decoration: BoxDecoration(
        color: strong ? tone.withValues(alpha: 0.12) : c.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_reasonIcon(reason.kind), size: 13, color: tone),
          const SizedBox(width: Space.xs),
          Flexible(
            child: Text(
              dinnerReasonLabel(l10n, reason),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, height: 1.2, fontWeight: FontWeight.w600, color: tone),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dinner suggestion cards ──

/// A dinner suggestion: photo, title and the reason it was picked. Opens the
/// recipe, or runs [onTap] (the planner adds it to the day).
class DinnerSuggestionCard extends StatelessWidget {
  final DinnerSuggestion suggestion;
  final VoidCallback? onTap;

  const DinnerSuggestionCard({super.key, required this.suggestion, this.onTap});

  /// Height of the block under the photo: two title lines and the reason.
  static const double textBlockHeight = 78;

  static double heightFor(double width) => width * 3 / 4 + textBlockHeight + 2;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final recipe = suggestion.recipe.recipe;
    return Clickable(
      semanticLabel: recipe.title,
      onTap: onTap ?? () => context.push('/recipe/${recipe.id}'),
      builder: (context, hovered) => AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.standard,
        transform: Matrix4.translationValues(0, hovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: Radii.lgAll,
          border: Border.all(color: hovered ? c.textPrimary.withValues(alpha: 0.14) : c.hairline),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Radii.lg - 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: ColoredBox(
                  color: c.surfaceHigh,
                  child: RecipeImage.medium(
                    imagePath: recipe.imagePath,
                    recipeId: recipe.id,
                    recipeName: recipe.title,
                    course: recipe.courseId,
                    category: recipe.categoryId,
                  ),
                ),
              ),
              SizedBox(
                height: textBlockHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Space.md, Space.sm + 2, Space.md, Space.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 36,
                        child: Text(
                          normalizeTitle(recipe.title).title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.28,
                            fontWeight: FontWeight.w600,
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      DinnerReasonChip(reason: suggestion.reason),
                    ],
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

/// "What's for dinner?": a header with "Show others" and three to six
/// suggestions for [day]. Lays them out across [fitWidth] when given (the
/// desktop dashboard), else as a horizontal strip of [tileWidth] cards.
class DinnerSuggestionsSection extends ConsumerWidget {
  final DateTime day;
  final EdgeInsets padding;
  final double? fitWidth;
  final double tileWidth;

  /// Header above the cards; null for none (the caller has its own).
  final Widget Function(BuildContext context, VoidCallback? onShuffle)? headerBuilder;

  /// Runs instead of opening the recipe (the planner adds it to the day).
  final void Function(DinnerSuggestion suggestion)? onPick;

  const DinnerSuggestionsSection({
    super.key,
    required this.day,
    this.padding = EdgeInsets.zero,
    this.fitWidth,
    this.tileWidth = 156,
    this.headerBuilder,
    this.onPick,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(dinnerSuggestionsProvider(day)).valueOrNull ?? const <DinnerSuggestion>[];
    if (suggestions.isEmpty) return const SizedBox.shrink();
    void shuffle() => reshuffleDinner(ref, suggestions);

    Widget card(DinnerSuggestion s) => DinnerSuggestionCard(
          suggestion: s,
          onTap: onPick == null ? null : () => onPick!(s),
        );

    final Widget cards;
    final fit = fitWidth;
    if (fit != null) {
      const gap = Space.lg;
      const maxTile = 230.0;
      final columns = ((fit + gap) / (maxTile + gap)).ceil().clamp(3, RecipeSuggestionService.maxSuggestions);
      final width = (fit - gap * (columns - 1)) / columns;
      final shown = suggestions.take(columns).toList();
      cards = SizedBox(
        height: DinnerSuggestionCard.heightFor(width) + 4,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const SizedBox(width: gap),
              SizedBox(width: width, height: DinnerSuggestionCard.heightFor(width), child: card(shown[i])),
            ],
          ],
        ),
      );
    } else {
      cards = SizedBox(
        height: DinnerSuggestionCard.heightFor(tileWidth),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: padding.left, right: padding.right),
          itemCount: suggestions.length,
          separatorBuilder: (_, _) => const SizedBox(width: Space.md),
          itemBuilder: (context, i) => SizedBox(width: tileWidth, child: card(suggestions[i])),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (headerBuilder != null) headerBuilder!(context, shuffle),
        if (fit != null) Padding(padding: EdgeInsets.only(left: padding.left, right: padding.right), child: cards) else cards,
      ],
    );
  }
}

// ── Home entry: "What can I make?" ──

/// The Home panel that leads to "What can I make?": how many recipes are
/// ready and how many need one or two things, or an invitation to fill the
/// pantry when it is empty.
class PantryCookingHomeCard extends ConsumerWidget {
  final bool compact;
  const PantryCookingHomeCard({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final pantry = ref.watch(pantryProvider).valueOrNull;
    final matches = ref.watch(pantryMatchesProvider).valueOrNull;
    final empty = pantry == null || pantry.isEmpty;

    String subtitle;
    if (empty) {
      subtitle = l10n.pantryCookHomeEmpty;
    } else if (matches == null) {
      subtitle = l10n.pantryCookItemsInPantry(pantry.items.length);
    } else {
      final ready = matches.where((m) => m.readyNow).length;
      final few = matches.where((m) => pantryFilterAccepts(PantryFilter.missingFew, m)).length;
      subtitle = '${l10n.pantryCookHomeReady(ready)}  ·  ${l10n.pantryCookHomeFew(few)}';
    }

    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(borderRadius: Radii.lgAll, side: BorderSide(color: c.hairline)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openPantryCooking(context),
        hoverColor: c.hoverFill,
        highlightColor: c.pressedFill,
        splashColor: c.pressedFill,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Space.lg, vertical: compact ? Space.md : Space.md + 2),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: c.selectedFill, borderRadius: Radii.mdAll),
                child: Icon(Icons.kitchen_rounded, size: 21, color: c.accent),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.pantryCookTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: c.textTertiary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Space.sm),
              Text(
                empty ? l10n.pantryCookHomeSetUp : l10n.pantryCookHomeOpen,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.accent),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: c.accent),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Fast pantry adds ──

/// Adding to the pantry in a few taps: a field that takes one item or a
/// comma-separated list, the ready-made ingredient lists, and recently
/// bought shopping items (each leaves once it is in the pantry). With
/// [showItems], also "Still have these?" and everything on hand.
class PantryQuickAdd extends ConsumerStatefulWidget {
  /// Show "Still have these?" and the items on hand too.
  final bool showItems;

  /// Offer a search field once the list of items is long.
  final bool searchable;

  const PantryQuickAdd({super.key, this.showItems = true, this.searchable = false});

  @override
  ConsumerState<PantryQuickAdd> createState() => _PantryQuickAddState();
}

class _PantryQuickAddState extends ConsumerState<PantryQuickAdd> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit(String text) async {
    final names = [
      for (final part in text.split(RegExp(r'[,;\n]')))
        if (part.trim().isNotEmpty) part.trim(),
    ];
    if (names.isEmpty) return;
    await ref.read(pantryProvider.notifier).addAll(names);
    _controller.clear();
    if (mounted) _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final pantry = ref.watch(pantryProvider).valueOrNull;
    if (pantry == null) return const SizedBox(height: 48);
    final matcher = pantry.matcher;
    final bought = [
      for (final name in ref.watch(recentlyBoughtProvider).valueOrNull ?? const <String>[])
        if (!matcher.hasItem(name)) name,
    ].take(12).toList();
    final notifier = ref.read(pantryProvider.notifier);

    Widget label(String text, {Widget? trailing}) => Padding(
          padding: const EdgeInsets.only(top: Space.lg, bottom: Space.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.textSecondary),
                ),
              ),
              ?trailing,
            ],
          ),
        );

    Widget addChip(String name) => ActionChip(
          avatar: Icon(Icons.add_rounded, size: 16, color: c.accent),
          label: Text(name),
          visualDensity: VisualDensity.compact,
          side: BorderSide(color: c.hairline),
          backgroundColor: c.surface,
          labelStyle: TextStyle(fontSize: 13, color: c.textPrimary),
          onPressed: () => notifier.add(name),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showItems && pantry.dueAt(DateTime.now()).isNotEmpty) ...[
          const PantryStillHaveCard(),
          const SizedBox(height: Space.lg),
        ],
        TextField(
          controller: _controller,
          focusNode: _focus,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: l10n.pantryAddHint,
            isDense: true,
            prefixIcon: const Icon(Icons.add_rounded, size: 20),
            suffixIcon: IconButton(
              tooltip: l10n.actionAdd,
              icon: const Icon(Icons.check_rounded),
              onPressed: () => _submit(_controller.text),
            ),
            border: OutlineInputBorder(borderRadius: Radii.mdAll),
          ),
          onSubmitted: _submit,
        ),
        const SizedBox(height: Space.sm),
        const CommonIngredientsButton(),
        if (bought.isNotEmpty) ...[
          label(
            l10n.pantryCookRecentlyBought,
            trailing: TextButton(
              onPressed: () => notifier.addAll(bought),
              style: TextButton.styleFrom(
                foregroundColor: c.accent,
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              child: Text(l10n.pantryCookAddAll),
            ),
          ),
          Wrap(spacing: Space.xs + 2, runSpacing: Space.xs + 2, children: [for (final n in bought) addChip(n)]),
        ],
        if (widget.showItems && pantry.items.isNotEmpty) ...[
          const SizedBox(height: Space.lg),
          PantryOnHandSection(searchable: widget.searchable),
        ],
      ],
    );
  }
}

/// The always-have basics (water, salt, pepper...): left out of every
/// recipe's count. Removable chips and a field to add more.
class PantryBasicsEditor extends ConsumerStatefulWidget {
  const PantryBasicsEditor({super.key});

  @override
  ConsumerState<PantryBasicsEditor> createState() => _PantryBasicsEditorState();
}

class _PantryBasicsEditorState extends ConsumerState<PantryBasicsEditor> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add(String text) async {
    final name = text.trim();
    if (name.isEmpty) return;
    await ref.read(pantryProvider.notifier).addBasic(name);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final basics = ref.watch(pantryProvider).valueOrNull?.basics ?? const <String>[];
    final notifier = ref.read(pantryProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.pantryCookAlwaysHave,
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(l10n.pantryCookAlwaysHaveHint, style: TextStyle(fontSize: 12, color: c.textTertiary)),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.xs + 2,
          runSpacing: Space.xs + 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final b in basics)
              // Tap for "Move to On hand now", or the cross to remove.
              PopupMenuButton<String>(
                key: ValueKey('pantry-basic-$b'),
                tooltip: '',
                onSelected: (_) => notifier.moveBasicToPantry(b),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'move',
                    child: Row(
                      children: [
                        const Icon(Icons.kitchen_outlined, size: 18),
                        const SizedBox(width: Space.sm),
                        Text(l10n.pantryMoveToNow),
                      ],
                    ),
                  ),
                ],
                child: InputChip(
                  avatar: Icon(Icons.push_pin_rounded, size: 14, color: c.accent),
                  label: Text(b),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(color: c.hairline),
                  backgroundColor: c.surface,
                  labelStyle: TextStyle(fontSize: 13, color: c.textPrimary),
                  deleteIcon: const Icon(Icons.close_rounded, size: 15),
                  deleteButtonTooltipMessage: l10n.actionRemove,
                  onDeleted: () => notifier.removeBasic(b),
                ),
              ),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: l10n.pantryCookAddBasicHint,
                  isDense: true,
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.add_rounded, size: 18, color: c.textTertiary),
                  prefixIconConstraints: const BoxConstraints(minWidth: 28),
                ),
                style: const TextStyle(fontSize: 13),
                onSubmitted: _add,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
