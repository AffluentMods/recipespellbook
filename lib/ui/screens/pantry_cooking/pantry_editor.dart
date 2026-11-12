import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/common_ingredient_packs.dart';
import '../../../database/database.dart' show ShoppingListItem;
import '../../../l10n/app_localizations.dart';
import '../../../providers/pantry_cooking_provider.dart';
import '../../../services/pantry_cooking_service.dart' show recentlyBoughtNames;
import '../../../services/pantry_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../utils/ingredient_utils.dart' show getShoppingCategory;
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/sheet_chrome.dart';

/// "Added 3 days ago", "In the freezer for 2 weeks".
String pantryAgeLabel(AppLocalizations l10n, PantryEntry entry, DateTime now) {
  final days = entry.ageInDays(now);
  if (days >= 14) {
    final weeks = days ~/ 7;
    return entry.frozen ? l10n.pantryFrozenWeeks(weeks) : l10n.pantryAddedWeeksAgo(weeks);
  }
  return entry.frozen ? l10n.pantryFrozenAgo(days) : l10n.pantryAddedAgo(days);
}

/// The Yes / No check before emptying everything on hand.
Future<void> confirmClearPantry(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final count = ref.read(pantryProvider).valueOrNull?.items.length ?? 0;
  if (count == 0) return;
  final yes = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.pantryClearNowTitle),
      content: Text(l10n.pantryClearNowMessage(count)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.no)),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.yes)),
      ],
    ),
  );
  if (yes == true) await ref.read(pantryProvider.notifier).clear();
}

// ── Put away after shopping ──

const _notFoodCategories = {'household', 'personalCare', 'pet', 'baby'};

/// The foods among ticked-off shopping items, cut down for the pantry
/// ("2 cups flour" is "flour"), each once. Paper towels and the like stay out.
List<String> pantryFoodsFromShopping(Iterable<ShoppingListItem> items) => recentlyBoughtNames(
      [for (final i in items) if (!_notFoodCategories.contains(getShoppingCategory(i.name))) i],
      limit: 1 << 20,
    );

/// "Put away": everything ticked off goes into On hand now, dated today.
/// The snackbar offers to take the ticked items off the list too.
Future<void> putAwayInPantry(
  BuildContext context,
  WidgetRef ref,
  List<ShoppingListItem> ticked, {
  VoidCallback? removeFromList,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final names = pantryFoodsFromShopping(ticked);
  if (names.isEmpty) {
    AppSnackbar.info(context, l10n.shoppingPutAwayNothing);
    return;
  }
  await ref.read(pantryProvider.notifier).addAll(names);
  if (!context.mounted) return;
  final message = l10n.shoppingPutAwayDone(names.length);
  if (removeFromList != null) {
    AppSnackbar.successWithAction(context, message, actionLabel: l10n.shoppingPutAwayClear, onAction: removeFromList);
  } else {
    AppSnackbar.success(context, message);
  }
}

// ── Still have these? ──

/// The items that have probably been used up or gone off, each with Keep
/// (restarts its clock) and Remove, and Remove all. Shows nothing when
/// there are none.
class PantryStillHaveCard extends ConsumerWidget {
  const PantryStillHaveCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final pantry = ref.watch(pantryProvider).valueOrNull;
    final now = DateTime.now();
    final due = pantry?.dueAt(now) ?? const <PantryEntry>[];
    if (due.isEmpty) return const SizedBox.shrink();
    final notifier = ref.read(pantryProvider.notifier);

    return Container(
      key: const ValueKey('pantry-still-have'),
      decoration: BoxDecoration(
        color: c.selectedFill,
        borderRadius: Radii.lgAll,
        border: Border.all(color: c.accent.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.sm, Space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 18, color: c.accent),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Text(
                  l10n.pantryStillHaveTitle,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary),
                ),
              ),
              TextButton(
                onPressed: () => notifier.removeAll([for (final e in due) e.name]),
                style: TextButton.styleFrom(foregroundColor: c.destructive, visualDensity: VisualDensity.compact),
                child: Text(l10n.pantryRemoveThese),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: Space.sm, bottom: Space.xs),
            child: Text(l10n.pantryStillHaveHint, style: TextStyle(fontSize: 12.5, color: c.textSecondary)),
          ),
          for (final e in due)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                      Text(pantryAgeLabel(l10n, e, now), style: TextStyle(fontSize: 12, color: c.textTertiary)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => notifier.keep([e.name]),
                  style: TextButton.styleFrom(foregroundColor: c.accent, visualDensity: VisualDensity.compact),
                  child: Text(l10n.pantryKeep),
                ),
                IconButton(
                  tooltip: l10n.actionRemove,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.close_rounded, size: 18, color: c.textTertiary),
                  onPressed: () => notifier.remove(e.name),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── On hand now ──

/// Everything on hand right now: a header with Clear all, then one row per
/// item with how long ago it was added, and buttons to put it in the
/// freezer, move it to Always have, or remove it. Frozen items are grouped
/// under "Freezer".
class PantryOnHandSection extends ConsumerStatefulWidget {
  /// Show a search field once the list is long.
  final bool searchable;

  const PantryOnHandSection({super.key, this.searchable = false});

  @override
  ConsumerState<PantryOnHandSection> createState() => _PantryOnHandSectionState();
}

class _PantryOnHandSectionState extends ConsumerState<PantryOnHandSection> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final pantry = ref.watch(pantryProvider).valueOrNull;
    if (pantry == null || pantry.isEmpty) return const SizedBox.shrink();
    final now = DateTime.now();
    final q = _query.trim().toLowerCase();
    final shown = [for (final e in pantry.entries) if (q.isEmpty || e.name.contains(q)) e];
    final fresh = [for (final e in shown) if (!e.frozen) e];
    final frozen = [for (final e in shown) if (e.frozen) e];

    return Column(
      key: const ValueKey('pantry-on-hand'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${l10n.pantryNowTitle} (${pantry.items.length})',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.textSecondary),
              ),
            ),
            TextButton.icon(
              key: const ValueKey('pantry-clear-all'),
              onPressed: () => confirmClearPantry(context, ref),
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: Text(l10n.pantryClearNow),
              style: TextButton.styleFrom(foregroundColor: c.destructive, visualDensity: VisualDensity.compact),
            ),
          ],
        ),
        Text(l10n.pantryNowHint, style: TextStyle(fontSize: 12, color: c.textTertiary)),
        if (widget.searchable && pantry.items.length > 12)
          Padding(
            padding: const EdgeInsets.only(top: Space.sm),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.pantrySearchHint,
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(borderRadius: Radii.mdAll),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        const SizedBox(height: Space.xs),
        for (final e in fresh) _PantryRow(entry: e, now: now),
        if (frozen.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: Space.md, bottom: Space.xs),
            child: Row(
              children: [
                Icon(Icons.ac_unit_rounded, size: 15, color: c.textSecondary),
                const SizedBox(width: Space.xs),
                Text(
                  l10n.pantryFreezerSection,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.textSecondary),
                ),
              ],
            ),
          ),
          for (final e in frozen) _PantryRow(entry: e, now: now),
        ],
      ],
    );
  }
}

class _PantryRow extends ConsumerWidget {
  final PantryEntry entry;
  final DateTime now;

  const _PantryRow({required this.entry, required this.now});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final notifier = ref.read(pantryProvider.notifier);
    final due = entry.isDue(now);
    return Padding(
      key: ValueKey('pantry-row-${entry.name}'),
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: TextStyle(fontSize: 14, color: c.textPrimary)),
                Text(
                  pantryAgeLabel(l10n, entry, now),
                  style: TextStyle(fontSize: 11.5, color: due ? c.accent : c.textTertiary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: entry.frozen ? l10n.pantryTakeOutOfFreezer : l10n.pantryMoveToFreezer,
            visualDensity: VisualDensity.compact,
            isSelected: entry.frozen,
            icon: Icon(Icons.ac_unit_rounded, size: 18, color: c.textTertiary),
            selectedIcon: Icon(Icons.ac_unit_rounded, size: 18, color: c.accent),
            onPressed: () => notifier.setFrozen(entry.name, !entry.frozen),
          ),
          IconButton(
            key: ValueKey('pantry-always-${entry.name}'),
            tooltip: l10n.pantryMakeAlwaysHave,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.push_pin_outlined, size: 18, color: c.textTertiary),
            onPressed: () async {
              await notifier.moveToBasics(entry.name);
              if (context.mounted) AppSnackbar.info(context, l10n.pantryMovedToAlwaysHave(entry.name));
            },
          ),
          IconButton(
            tooltip: l10n.actionRemove,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close_rounded, size: 18, color: c.textTertiary),
            onPressed: () => notifier.remove(entry.name),
          ),
        ],
      ),
    );
  }
}

// ── Common ingredients ──

/// Opens the ready-made ingredient lists.
class CommonIngredientsButton extends StatelessWidget {
  const CommonIngredientsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    return OutlinedButton.icon(
      key: const ValueKey('pantry-common-button'),
      onPressed: () => showCommonIngredientsSheet(context),
      icon: Icon(Icons.playlist_add_rounded, size: 20, color: c.accent),
      label: Text(l10n.pantryCommonButton),
      style: OutlinedButton.styleFrom(
        foregroundColor: c.accent,
        side: BorderSide(color: c.hairline),
        padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.md),
        shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
      ),
    );
  }
}

/// The ready-made lists: tick what is in the kitchen, choose Always have or
/// On hand now, add them all at once.
Future<void> showCommonIngredientsSheet(BuildContext context) {
  return Responsive.showAdaptiveSheet(
    context,
    builder: (ctx) => const _CommonIngredientsSheet(),
  );
}

class _CommonIngredientsSheet extends ConsumerStatefulWidget {
  const _CommonIngredientsSheet();

  @override
  ConsumerState<_CommonIngredientsSheet> createState() => _CommonIngredientsSheetState();
}

class _CommonIngredientsSheetState extends ConsumerState<_CommonIngredientsSheet> {
  final _picked = <String>{};
  bool _toAlwaysHave = true;

  String _packTitle(AppLocalizations l10n, IngredientPackId id) => switch (id) {
        IngredientPackId.baking => l10n.pantryPackBaking,
        IngredientPackId.spices => l10n.pantryPackSpices,
        IngredientPackId.herbs => l10n.pantryPackHerbs,
        IngredientPackId.oils => l10n.pantryPackOils,
        IngredientPackId.sauces => l10n.pantryPackSauces,
        IngredientPackId.grains => l10n.pantryPackGrains,
        IngredientPackId.canned => l10n.pantryPackCanned,
        IngredientPackId.fridge => l10n.pantryPackFridge,
        IngredientPackId.fresh => l10n.pantryPackFresh,
      };

  Future<void> _add() async {
    final names = _picked.toList();
    final notifier = ref.read(pantryProvider.notifier);
    if (_toAlwaysHave) {
      await notifier.addBasics(names);
    } else {
      await notifier.addAll(names);
    }
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.of(context).pop();
    messenger?.showSnackBar(SnackBar(
      content: Text(l10n.pantryCommonAdded(names.length)),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final lang = Localizations.localeOf(context).languageCode;
    final pantry = ref.watch(pantryProvider).valueOrNull;
    // Exact names only: "all-purpose flour" on hand should still leave
    // "bread flour" to tick.
    final owned = {...?pantry?.items, ...?pantry?.basics};
    bool have(String name) => owned.contains(name.toLowerCase().trim());

    return Container(
      key: const ValueKey('pantry-common-sheet'),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: BoxDecoration(color: c.surface, borderRadius: SheetPresentation.surfaceRadius(context)),
      child: Material(type: MaterialType.transparency, child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SheetHandle(top: 0),
                  const SizedBox(height: Space.md),
                  Text(
                    l10n.pantryCommonTitle,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary),
                  ),
                  const SizedBox(height: Space.xs),
                  Text(l10n.pantryCommonHint, style: TextStyle(fontSize: 13, color: c.textSecondary)),
                  const SizedBox(height: Space.md),
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: true,
                        icon: const Icon(Icons.push_pin_outlined, size: 18),
                        label: Text(l10n.pantryCookAlwaysHave),
                      ),
                      ButtonSegment(
                        value: false,
                        icon: const Icon(Icons.kitchen_outlined, size: 18),
                        label: Text(l10n.pantryNowTitle),
                      ),
                    ],
                    selected: {_toAlwaysHave},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => setState(() => _toAlwaysHave = s.first),
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    _toAlwaysHave ? l10n.pantryCommonAlwaysHint : l10n.pantryCommonNowHint,
                    style: TextStyle(fontSize: 12, color: c.textTertiary),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, Space.md),
                children: [
                  for (final id in ingredientPackIds) ...[
                    Builder(builder: (context) {
                      final items = ingredientPackItems(id, lang);
                      final open = [for (final n in items) if (!have(n)) n];
                      final allPicked = open.isNotEmpty && open.every(_picked.contains);
                      return Padding(
                        padding: const EdgeInsets.only(top: Space.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _packTitle(l10n, id),
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary),
                                  ),
                                ),
                                if (open.isNotEmpty)
                                  TextButton(
                                    key: ValueKey('pack-all-${id.name}'),
                                    onPressed: () => setState(() {
                                      if (allPicked) {
                                        _picked.removeAll(open);
                                      } else {
                                        _picked.addAll(open);
                                      }
                                    }),
                                    style: TextButton.styleFrom(
                                      foregroundColor: c.accent,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: Text(allPicked ? l10n.pantryCommonSelectNone : l10n.pantryCommonSelectAll),
                                  ),
                              ],
                            ),
                            Wrap(
                              spacing: Space.xs + 2,
                              runSpacing: Space.xs + 2,
                              children: [
                                for (final name in items)
                                  FilterChip(
                                    label: Text(name),
                                    visualDensity: VisualDensity.compact,
                                    selected: have(name) || _picked.contains(name),
                                    onSelected: have(name)
                                        ? null
                                        : (on) => setState(() => on ? _picked.add(name) : _picked.remove(name)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, Space.lg + MediaQuery.viewInsetsOf(context).bottom),
              child: FilledButton(
                key: const ValueKey('pantry-common-add'),
                onPressed: _picked.isEmpty ? null : _add,
                style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                child: Text(l10n.pantryCommonAddCount(_picked.length)),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
