import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/database_provider.dart';
import '../../providers/usda_provider.dart';
import '../../services/bulk_nutrition_service.dart';
import '../../services/sync_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import '../../utils/responsive_utils.dart';
import 'sheet_chrome.dart';

/// Opens "Calculate nutrition" for [cookbook], or for every cookbook that
/// can be changed here when it is null.
Future<void> showBulkNutritionSheet(BuildContext context, WidgetRef ref, {Cookbook? cookbook}) {
  final service = BulkNutritionCalculator(
    db: ref.read(databaseProvider),
    calculator: ref.read(nutritionCalculatorProvider),
  );
  final router = GoRouter.maybeOf(context);
  return Responsive.showAdaptiveSheet<void>(
    context,
    desktopMaxWidth: 520,
    desktopMaxHeight: 680,
    builder: (_) => BulkNutritionSheet(
      service: service,
      cookbook: cookbook,
      onOpenRecipe: router == null ? null : (id) => router.push('/recipe/$id'),
    ),
  );
}

/// The choice (recipes without nutrition, or all of them), the run with its
/// progress and Stop, and what came of it.
class BulkNutritionSheet extends StatefulWidget {
  final BulkNutritionCalculator service;

  /// The cookbook; null for every cookbook.
  final Cookbook? cookbook;

  /// Opens a recipe from the result lists, after the sheet closes.
  final void Function(String recipeId)? onOpenRecipe;

  const BulkNutritionSheet({super.key, required this.service, this.cookbook, this.onOpenRecipe});

  @override
  State<BulkNutritionSheet> createState() => _BulkNutritionSheetState();
}

class _BulkNutritionSheetState extends State<BulkNutritionSheet> {
  List<Recipe>? _recipes;
  BulkNutritionSurvey? _survey;
  bool _failed = false;
  BulkNutritionScope _scope = BulkNutritionScope.missingOnly;

  BulkNutritionControl? _control;
  BulkNutritionProgress? _progress;
  BulkNutritionReport? _report;

  bool get _running => _control != null && _report == null && !_failed;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    // Closed while running: the recipes done so far are kept.
    _control?.stop();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final cookbook = widget.cookbook;
      final recipes = cookbook == null
          ? await widget.service.recipesOfLibrary()
          : await widget.service.recipesOfCookbook(cookbook.id);
      if (!mounted) return;
      setState(() {
        _recipes = recipes;
        _survey = BulkNutritionSurvey.of(recipes);
      });
    } catch (e) {
      debugPrint('[BulkNutritionSheet] load: $e');
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _start() async {
    final recipes = _recipes;
    if (recipes == null || _control != null) return;
    final control = BulkNutritionControl();
    final languageCode = Localizations.localeOf(context).languageCode;
    setState(() {
      _control = control;
      _progress = BulkNutritionProgress(done: 0, total: _survey?.countFor(_scope) ?? 0);
    });
    BulkNutritionReport report;
    try {
      report = await widget.service.run(
        recipes,
        scope: _scope,
        languageCode: languageCode,
        control: control,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
    } catch (e) {
      debugPrint('[BulkNutritionSheet] run: $e');
      if (mounted) setState(() => _failed = true);
      return;
    }
    // Edits in a shared cookbook go out with the next sync; start it now.
    if (report.sharedChanged) unawaited(SyncService.instance.sync());
    if (mounted) setState(() => _report = report);
  }

  void _open(String recipeId) {
    final open = widget.onOpenRecipe;
    if (open == null) return;
    Navigator.of(context).pop();
    open(recipeId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    final Widget body;
    final Widget actions;
    if (_failed) {
      body = _message(context, Icons.error_outline_rounded, l10n.nutritionCalculationFailed);
      actions = FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionClose));
    } else if (_report != null) {
      body = Flexible(child: _result(context, _report!));
      actions = FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionDone));
    } else if (_running) {
      body = _runningBody(context);
      final control = _control!;
      actions = OutlinedButton.icon(
        onPressed: control.stopRequested ? null : () => setState(control.stop),
        icon: const Icon(Icons.stop_rounded, size: 18),
        label: Text(l10n.bulkNutritionStop),
      );
    } else if (_survey == null) {
      body = const Padding(
        padding: EdgeInsets.all(Space.xxl),
        child: Center(child: CircularProgressIndicator()),
      );
      actions = TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel));
    } else {
      body = Flexible(child: _choice(context, _survey!));
      final count = _survey!.countFor(_scope);
      actions = Wrap(
        alignment: WrapAlignment.end,
        spacing: Space.sm,
        runSpacing: Space.sm,
        children: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
          FilledButton.icon(
            onPressed: count == 0 ? null : _start,
            icon: const Icon(Icons.calculate_outlined, size: 18),
            label: Text(l10n.nutritionCalculate),
          ),
        ],
      );
    }

    return PopScope(
      canPop: !_running,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.xl, Space.lg, Space.xl, Space.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.bulkNutritionAction,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.cookbook?.name ?? l10n.bulkNutritionAllCookbooks,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            body,
            Divider(height: 1, color: c.hairline),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, Space.lg),
              child: Align(alignment: Alignment.centerRight, child: actions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.xxl, Space.lg, Space.xxl, Space.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: c.textTertiary),
          const SizedBox(height: Space.md),
          Text(text, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: c.textSecondary)),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, IconData icon, String text, {Color? color}) {
    final theme = Theme.of(context);
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.xl, vertical: Space.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color ?? c.textTertiary),
          const SizedBox(width: Space.md),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: c.textPrimary))),
        ],
      ),
    );
  }

  Widget _choice(BuildContext context, BulkNutritionSurvey survey) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    if (survey.total == 0) {
      return _message(context, Icons.menu_book_rounded, l10n.bulkNutritionNoRecipes);
    }
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: Space.sm),
      children: [
        _line(context, Icons.radio_button_unchecked_rounded, l10n.bulkNutritionMissing(survey.missing)),
        _line(context, Icons.check_circle_outline_rounded, l10n.bulkNutritionExisting(survey.existing)),
        if (survey.entered > 0) _line(context, Icons.edit_note_rounded, l10n.bulkNutritionEntered(survey.entered)),
        const SizedBox(height: Space.md),
        for (final scope in BulkNutritionScope.values)
          _ScopeOption(
            selected: _scope == scope,
            title: scope == BulkNutritionScope.missingOnly ? l10n.bulkNutritionOnlyMissing : l10n.bulkNutritionAll,
            hint: scope == BulkNutritionScope.missingOnly ? l10n.bulkNutritionOnlyMissingHint : l10n.bulkNutritionAllHint,
            count: survey.countFor(scope),
            accent: c.accent,
            onTap: () => setState(() => _scope = scope),
          ),
      ],
    );
  }

  Widget _runningBody(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final p = _progress ?? const BulkNutritionProgress(done: 0, total: 0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.xl, Space.md, Space.xl, Space.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(value: p.total == 0 ? null : p.fraction),
          const SizedBox(height: Space.md),
          Text(
            l10n.bulkNutritionProgress(p.total == 0 ? 0 : (p.done + 1).clamp(1, p.total), p.total),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: Space.xs),
          Text(
            p.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _result(BuildContext context, BulkNutritionReport report) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final low = report.lowMatch;
    final notCalculated = report.notCalculated;

    Widget recipeRow(BulkNutritionRecipe r, String detail) => ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: Space.xxxl + Space.lg, right: Space.lg),
          title: Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(detail),
          trailing: widget.onOpenRecipe == null ? null : Icon(Icons.chevron_right_rounded, color: c.textTertiary),
          onTap: widget.onOpenRecipe == null ? null : () => _open(r.recipeId),
        );

    Widget group(IconData icon, Color color, String title, List<Widget> rows) => Theme(
          // No divider lines above and below an open group.
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(icon, size: 20, color: color),
            title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: c.textPrimary)),
            tilePadding: const EdgeInsets.symmetric(horizontal: Space.xl),
            childrenPadding: EdgeInsets.zero,
            children: rows,
          ),
        );

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: Space.sm),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.xl, Space.xs, Space.xl, Space.sm),
          child: Text(
            report.stopped ? l10n.bulkNutritionStopped : l10n.nutrientsCalculated,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
          ),
        ),
        _line(context, Icons.check_circle_rounded, l10n.bulkNutritionCalculatedCount(report.calculated.length),
            color: c.accent),
        if (report.externalCount > 0)
          Padding(
            padding: const EdgeInsets.only(left: Space.xxxl - Space.xs),
            child: _line(context, Icons.subdirectory_arrow_right_rounded,
                l10n.bulkNutritionExternalCount(report.externalCount)),
          ),
        _line(context, Icons.skip_next_rounded, l10n.bulkNutritionSkippedCount(report.skipped)),
        if (low.isNotEmpty)
          group(
            Icons.warning_amber_rounded,
            c.textSecondary,
            l10n.bulkNutritionLowMatchCount(low.length),
            [for (final r in low) recipeRow(r, l10n.nutritionMatchedCount(r.matched, r.ingredients))],
          ),
        if (notCalculated.isNotEmpty)
          group(
            Icons.block_rounded,
            c.textSecondary,
            l10n.bulkNutritionNotCalculatedCount(notCalculated.length),
            [
              for (final r in report.noIngredients) recipeRow(r, l10n.bulkNutritionNoIngredients),
              for (final r in report.noMatch) recipeRow(r, l10n.bulkNutritionNoMatch),
            ],
          ),
      ],
    );
  }
}

/// One of the two choices: recipes without nutrition, or all of them.
class _ScopeOption extends StatelessWidget {
  final bool selected;
  final String title;
  final String hint;
  final int count;
  final Color accent;
  final VoidCallback onTap;

  const _ScopeOption({
    required this.selected,
    required this.title,
    required this.hint,
    required this.count,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.xs),
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: Material(
          color: selected ? c.selectedFill : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: Radii.lgAll,
            side: BorderSide(color: selected ? accent : c.hairline),
          ),
          child: InkWell(
            borderRadius: Radii.lgAll,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(Space.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: selected ? accent : c.textTertiary,
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$title ($count)',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(hint, style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
