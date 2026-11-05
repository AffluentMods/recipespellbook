import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/course_category_data.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/pantry_cooking_provider.dart';
import '../../../services/pantry_cooking_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../utils/recipe_title.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/taxonomy_translator.dart';
import '../../widgets/app_controls.dart';
import '../../widgets/recipe_image.dart';
import '../../widgets/sheet_chrome.dart';
import 'pantry_cooking_widgets.dart';

/// "What can I make?": every recipe in every cookbook (copies shown once),
/// ranked by how much of it the pantry covers, with what is missing and a
/// one-tap "Add missing" to the shopping list. Quick filters for ready now,
/// one or two missing, a course or a cookbook. The pantry itself sits beside
/// the results on desktop and one tap away on phones.
class PantryCookingScreen extends ConsumerStatefulWidget {
  const PantryCookingScreen({super.key});

  @override
  ConsumerState<PantryCookingScreen> createState() => _PantryCookingScreenState();
}

class _PantryCookingScreenState extends ConsumerState<PantryCookingScreen> {
  PantryFilter _filter = PantryFilter.all;
  String? _course;
  String? _cookbook;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final pantryAsync = ref.watch(pantryProvider);
    final matchesAsync = ref.watch(pantryMatchesProvider);
    final pantry = pantryAsync.valueOrNull;
    final ranked = matchesAsync.valueOrNull;
    final desktop = Responsive.isDesktopLayout(context);

    final usable = ranked == null ? const <PantryRecipeMatch>[] : filterPantryMatches(ranked);
    final summary = pantry == null || pantry.isEmpty
        ? null
        : '${l10n.pantryCookItemsInPantry(pantry.items.length)}  ·  ${l10n.pantryCookRecipesUsing(usable.length)}';

    final Widget results;
    if (pantry == null || (ranked == null && !matchesAsync.hasError)) {
      results = const Center(child: CircularProgressIndicator());
    } else if (matchesAsync.hasError && ranked == null) {
      results = Center(child: Text('${l10n.errorGeneric}: ${matchesAsync.error}'));
    } else if (pantry.isEmpty) {
      results = _EmptyPantry(showQuickAdd: !desktop);
    } else {
      results = _Results(
        ranked: ranked!,
        filter: _filter,
        course: _course,
        cookbook: _cookbook,
        onFilter: (f) => setState(() => _filter = f),
        onCourse: (v) => setState(() => _course = v),
        onCookbook: (v) => setState(() => _cookbook = v),
        desktop: desktop,
      );
    }

    if (desktop) {
      return Scaffold(
        backgroundColor: c.surface,
        appBar: PageHeader(
          title: l10n.pantryCookTitle,
          subtitle: summary,
          leading: Navigator.of(context).canPop() ? const HeaderBackButton() : null,
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: results),
            Container(width: 1, color: c.hairline),
            SizedBox(
              width: 340,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Space.xl, Space.sm, Space.xl, Space.huge),
                children: [
                  Text(
                    l10n.myPantry,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary),
                  ),
                  const SizedBox(height: Space.md),
                  const PantryQuickAdd(),
                  const SizedBox(height: Space.xl),
                  Divider(height: 1, color: c.hairline),
                  const SizedBox(height: Space.lg),
                  const PantryBasicsEditor(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        backgroundColor: c.surface,
        title: Text(l10n.pantryCookTitle),
        actions: [
          if (pantry != null && !pantry.isEmpty)
            IconButton(
              tooltip: l10n.myPantry,
              icon: const Icon(Icons.kitchen_outlined),
              onPressed: () => showPantrySheet(context),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (summary != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.sm, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(summary, style: TextStyle(fontSize: 13, color: c.textTertiary)),
                  ),
                  TextButton(
                    onPressed: () => showPantrySheet(context),
                    style: TextButton.styleFrom(foregroundColor: c.accent),
                    child: Text(l10n.pantryCookEditPantry),
                  ),
                ],
              ),
            ),
          Expanded(child: results),
        ],
      ),
    );
  }
}

/// The pantry editor in a sheet (phones): quick adds, items, basics.
Future<void> showPantrySheet(BuildContext context) {
  return Responsive.showAdaptiveSheet(
    context,
    builder: (ctx) {
      final c = ctx.appColors;
      final l10n = AppLocalizations.of(ctx)!;
      return Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
        decoration: BoxDecoration(color: c.surface, borderRadius: SheetPresentation.surfaceRadius(ctx)),
        child: SafeArea(
          top: false,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.fromLTRB(
              Space.lg,
              Space.md,
              Space.lg,
              Space.xl + MediaQuery.viewInsetsOf(ctx).bottom,
            ),
            children: [
              const SheetHandle(top: 0),
              const SizedBox(height: Space.md),
              Text(l10n.myPantry, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary)),
              const SizedBox(height: Space.md),
              const PantryQuickAdd(),
              const SizedBox(height: Space.xl),
              const PantryBasicsEditor(),
            ],
          ),
        ),
      );
    },
  );
}

class _EmptyPantry extends StatelessWidget {
  final bool showQuickAdd;
  const _EmptyPantry({required this.showQuickAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.xl, Space.xxl, Space.xl, Space.huge),
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: c.selectedFill, shape: BoxShape.circle),
            child: Icon(Icons.kitchen_rounded, size: 34, color: c.accent),
          ),
        ),
        const SizedBox(height: Space.lg),
        Text(
          l10n.pantryCookEmptyTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
        ),
        const SizedBox(height: Space.sm),
        Text(
          l10n.pantryCookEmptyBody,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.45, color: c.textSecondary),
        ),
        if (showQuickAdd) ...[
          const SizedBox(height: Space.xl),
          const PantryQuickAdd(showItems: false),
        ],
      ],
    );
  }
}

class _Results extends ConsumerWidget {
  final List<PantryRecipeMatch> ranked;
  final PantryFilter filter;
  final String? course;
  final String? cookbook;
  final ValueChanged<PantryFilter> onFilter;
  final ValueChanged<String?> onCourse;
  final ValueChanged<String?> onCookbook;
  final bool desktop;

  const _Results({
    required this.ranked,
    required this.filter,
    required this.course,
    required this.cookbook,
    required this.onFilter,
    required this.onCourse,
    required this.onCookbook,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final translator = TaxonomyTranslator(l10n);

    // Counts for the quick filters follow the course and cookbook chosen.
    final scoped = filterPantryMatches(ranked, courseKey: course, cookbookId: cookbook);
    int count(PantryFilter f) => scoped.where((m) => pantryFilterAccepts(f, m)).length;
    final shown = [for (final m in scoped) if (pantryFilterAccepts(filter, m)) m];

    // Courses and cookbooks that have something to show.
    final usable = filterPantryMatches(ranked);
    final courseCounts = <String, int>{};
    final cookbookCounts = <String, int>{};
    for (final m in usable) {
      final key = m.recipe.courseKey;
      if (key != null) courseCounts[key] = (courseCounts[key] ?? 0) + 1;
      for (final id in m.recipe.cookbookIds) {
        cookbookCounts[id] = (cookbookCounts[id] ?? 0) + 1;
      }
    }
    String courseName(String key) {
      final builtIn = CourseData.getById(key);
      return builtIn != null ? translator.translateCourse(builtIn.name) : key;
    }

    final cookbooks = [
      for (final cb in ref.watch(cookbooksProvider).valueOrNull ?? const <Cookbook>[])
        if ((cookbookCounts[cb.id] ?? 0) > 0) cb,
    ];
    final courses = courseCounts.keys.toList()..sort((a, b) => courseName(a).compareTo(courseName(b)));
    final side = desktop ? Space.xxxl - 4 : Space.lg;

    final filters = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(side, Space.sm, side, Space.md),
      child: Row(
        children: [
          for (final f in PantryFilter.values) ...[
            TouchChip(
              label: '${switch (f) {
                PantryFilter.all => l10n.pantryCookFilterAll,
                PantryFilter.readyNow => l10n.pantryCookFilterReady,
                PantryFilter.missingFew => l10n.pantryCookFilterFew,
              }}  ${count(f)}',
              selected: filter == f,
              onTap: () => onFilter(f),
            ),
            const SizedBox(width: Space.sm),
          ],
          if (courses.isNotEmpty) ...[
            _MenuChip<String?>(
              label: course == null ? l10n.pantryCookAllCourses : courseName(course!),
              active: course != null,
              value: course,
              options: [
                (null, l10n.pantryCookAllCourses),
                for (final k in courses) (k, '${courseName(k)}  ${courseCounts[k]}'),
              ],
              onSelected: onCourse,
            ),
            const SizedBox(width: Space.sm),
          ],
          if (cookbooks.length > 1)
            _MenuChip<String?>(
              label: cookbook == null
                  ? l10n.pantryCookAllCookbooks
                  : cookbooks.where((cb) => cb.id == cookbook).firstOrNull?.name ?? l10n.pantryCookAllCookbooks,
              active: cookbook != null,
              value: cookbook,
              options: [
                (null, l10n.pantryCookAllCookbooks),
                for (final cb in cookbooks) (cb.id, '${cb.name}  ${cookbookCounts[cb.id]}'),
              ],
              onSelected: onCookbook,
            ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        filters,
        Expanded(
          child: shown.isEmpty
              ? _NoResults(anyUsable: usable.isNotEmpty)
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(side, 0, side, Space.huge + Space.xxl),
                  itemCount: shown.length,
                  separatorBuilder: (_, _) => const SizedBox(height: Space.sm),
                  itemBuilder: (context, i) => _MatchTile(match: shown[i], desktop: desktop),
                ),
        ),
        if (!desktop) Container(height: 1, color: c.hairline),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  final bool anyUsable;
  const _NoResults({required this.anyUsable});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: c.textTertiary),
            const SizedBox(height: Space.md),
            Text(
              anyUsable ? l10n.pantryCookNoFilterResults : l10n.pantryCookNoResults,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary),
            ),
            if (!anyUsable) ...[
              const SizedBox(height: Space.xs),
              Text(
                l10n.pantryCookNoResultsHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: c.textTertiary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// An outlined pill that opens a menu of [options] (value, label).
class _MenuChip<T> extends StatelessWidget {
  final String label;
  final bool active;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onSelected;

  const _MenuChip({
    required this.label,
    required this.active,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(c.surface),
        side: WidgetStatePropertyAll(BorderSide(color: c.hairline)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: Radii.mdAll)),
      ),
      menuChildren: [
        for (final (v, text) in options)
          MenuItemButton(
            leadingIcon: Icon(
              v == value ? Icons.check_rounded : null,
              size: 18,
              color: c.accent,
            ),
            onPressed: () => onSelected(v),
            child: Text(text),
          ),
      ],
      builder: (context, controller, _) => Material(
        color: active ? c.selectedFill : Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: active ? c.accent.withValues(alpha: 0.4) : c.hairline)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => controller.isOpen ? controller.close() : controller.open(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: active ? c.accent : c.textSecondary,
                  ),
                ),
                Icon(Icons.expand_more_rounded, size: 18, color: active ? c.accent : c.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One recipe: photo, title, how much the pantry covers, what is missing
/// (tap one you do have to add it to the pantry) and "Add missing".
class _MatchTile extends ConsumerWidget {
  final PantryRecipeMatch match;
  final bool desktop;

  const _MatchTile({required this.match, required this.desktop});

  static const _missingShown = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final recipe = match.recipe.recipe;
    final ready = match.readyNow;
    final thumb = desktop ? 72.0 : 64.0;
    final percent = (match.share * 100).round();

    final coverage = Row(
      children: [
        SizedBox(
          width: 64,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: match.share,
              minHeight: 5,
              backgroundColor: c.textPrimary.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(c.accent),
            ),
          ),
        ),
        const SizedBox(width: Space.sm),
        Flexible(
          child: Text(
            ready
                ? l10n.pantryCookFilterReady
                : '${l10n.pantryCookCovered(match.covered, match.counted)}  ·  $percent%',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: ready ? FontWeight.w700 : FontWeight.w500,
              color: ready ? c.accent : c.textSecondary,
            ),
          ),
        ),
      ],
    );

    final missing = match.missing;
    final missingRow = missing.isEmpty
        ? null
        : Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.pantryCookMissingLabel,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textTertiary),
              ),
              for (final i in missing.take(_missingShown))
                Tooltip(
                  message: l10n.pantryCookHaveIt(i.key.label),
                  waitDuration: const Duration(milliseconds: 500),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => addToPantryWithUndo(context, ref, i.key.label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: c.hairline),
                      ),
                      child: Text(
                        i.key.label,
                        style: TextStyle(fontSize: 12, color: c.textPrimary),
                      ),
                    ),
                  ),
                ),
              if (missing.length > _missingShown)
                Text(
                  l10n.pantryCookMoreMissing(missing.length - _missingShown),
                  style: TextStyle(fontSize: 12, color: c.textTertiary),
                ),
            ],
          );

    final Widget action = missing.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(Space.sm),
            child: Icon(Icons.check_circle_rounded, color: c.accent, size: 22),
          )
        : desktop
            ? OutlinedButton.icon(
                onPressed: () => addMissingToShoppingList(context, ref, match),
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 17),
                label: Text(l10n.pantryCookAddMissing),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.accent,
                  side: BorderSide(color: c.accent.withValues(alpha: 0.4)),
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              )
            : IconButton(
                tooltip: l10n.pantryCookAddMissingTooltip,
                onPressed: () => addMissingToShoppingList(context, ref, match),
                icon: Icon(Icons.add_shopping_cart_rounded, color: c.accent),
              );

    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(borderRadius: Radii.lgAll, side: BorderSide(color: c.hairline)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/recipe/${recipe.id}'),
        hoverColor: c.hoverFill,
        child: Padding(
          padding: const EdgeInsets.all(Space.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: Radii.mdAll,
                child: SizedBox(
                  width: thumb,
                  height: thumb,
                  child: RecipeImage.thumbnail(
                    imagePath: recipe.imagePath,
                    recipeId: recipe.id,
                    recipeName: recipe.title,
                    course: recipe.courseId,
                    category: recipe.categoryId,
                    width: thumb,
                    height: thumb,
                  ),
                ),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            normalizeTitle(recipe.title).title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary),
                          ),
                        ),
                        if (match.recipe.isFavorite)
                          Padding(
                            padding: const EdgeInsets.only(left: Space.xs),
                            child: Icon(Icons.favorite_rounded, size: 15, color: c.favorite),
                          ),
                      ],
                    ),
                    const SizedBox(height: Space.xs + 2),
                    coverage,
                    if (missingRow != null) ...[
                      const SizedBox(height: Space.sm),
                      missingRow,
                    ],
                  ],
                ),
              ),
              action,
            ],
          ),
        ),
      ),
    );
  }
}
