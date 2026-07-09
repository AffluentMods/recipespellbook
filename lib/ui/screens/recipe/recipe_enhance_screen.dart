import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../services/ai_import_service.dart';
import '../../widgets/app_snackbar.dart';

/// "Enhance with AI" — the zero-server "Use Your Own AI" path. The user copies
/// a prompt+recipe blob into any AI, pastes the returned JSON back, previews the
/// changes, and applies them onto the existing recipe.
class RecipeEnhanceScreen extends ConsumerStatefulWidget {
  final String recipeId;
  const RecipeEnhanceScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeEnhanceScreen> createState() => _RecipeEnhanceScreenState();
}

class _RecipeEnhanceScreenState extends ConsumerState<RecipeEnhanceScreen> {
  final _pasteController = TextEditingController();

  Recipe? _recipe;
  List<Ingredient> _ingredients = const [];
  List<Step> _steps = const [];
  bool _loading = true;
  bool _applying = false;
  String? _error;
  Map<String, dynamic>? _enhanced;
  bool _compare = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dao = ref.read(recipeDaoProvider);
      final recipe = await dao.getRecipeById(widget.recipeId);
      final ings = recipe == null ? const <Ingredient>[] : await dao.getIngredientsForRecipe(widget.recipeId);
      final steps = recipe == null ? const <Step>[] : await dao.getStepsForRecipe(widget.recipeId);
      if (!mounted) return;
      setState(() {
        _recipe = recipe;
        _ingredients = ings;
        _steps = steps;
        _loading = false;
      });
    } catch (e) {
      // DB read failed — drop the spinner; build() shows the error body since
      // _recipe stays null.
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _pasteController.dispose();
    super.dispose();
  }

  void _copyBlob() {
    if (_recipe == null) return;
    final blob = AiImportService.buildEnhanceBlob(_recipe!, _ingredients, _steps);
    Clipboard.setData(ClipboardData(text: blob));
    AppSnackbar.success(context, 'Copied! Paste it into ChatGPT, Claude, or any AI.');
  }

  void _preview() {
    final text = _pasteController.text.trim();
    if (text.isEmpty) return;
    try {
      final enhanced = AiImportService.parseSingleEnhancedRecipe(text);
      setState(() {
        _enhanced = enhanced;
        _error = null;
      });
      FocusScope.of(context).unfocus();
    } catch (e) {
      setState(() => _error = e is FormatException ? e.message : e.toString());
    }
  }

  Future<void> _accept() async {
    if (_enhanced == null) return;
    setState(() => _applying = true);
    try {
      await AiImportService.applyEnhancement(
        recipeId: widget.recipeId,
        enhanced: _enhanced!,
        db: ref.read(databaseProvider),
      );
      if (mounted) {
        AppSnackbar.success(context, 'Recipe updated.');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _applying = false);
        AppSnackbar.error(context, 'Couldn\'t update the recipe: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhance with AI'),
        leading: _enhanced != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back to edit',
                onPressed: () => setState(() => _enhanced = null),
              )
            : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _recipe == null
              ? _buildNotFound(theme)
              : _enhanced != null
                  ? _buildPreview(theme)
                  : _buildInput(theme),
    );
  }

  Widget _buildNotFound(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text("Couldn't load this recipe.",
                style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Input phase ──────────────────────────────────────────────
  Widget _buildInput(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          'Clean up this recipe with any AI',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'It adds section headers, writes the exact amounts into each step, and tidies the formatting — without changing your ingredients or method. Your photos, rating, and notes are kept.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),

        _stepCard(theme,
            n: '1',
            title: 'Copy your recipe + the instructions',
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _copyBlob,
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy recipe + prompt'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )),
        const SizedBox(height: 12),
        _stepCard(theme,
            n: '2',
            title: 'Paste it into ChatGPT, Claude, or any AI',
            child: Text(
              'The AI returns updated recipe JSON. Copy that JSON.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            )),
        const SizedBox(height: 12),
        _stepCard(theme,
            n: '3',
            title: 'Paste the AI\'s JSON back here',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _pasteController,
                  maxLines: 8,
                  minLines: 5,
                  style: theme.textTheme.bodySmall,
                  decoration: InputDecoration(
                    hintText: '{ "title": ... }',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(_error!,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: _preview,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Preview changes'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _stepCard(ThemeData theme, {required String n, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(n,
                    style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700, color: theme.colorScheme.onPrimaryContainer)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ── Preview phase ────────────────────────────────────────────
  Widget _buildPreview(ThemeData theme) {
    final e = _enhanced!;
    final ings = (e['ingredients'] as List?) ?? const [];
    final steps = (e['steps'] as List?) ?? const [];
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _changeSummary(theme),
              const SizedBox(height: 14),
              _viewToggle(theme),
              const SizedBox(height: 16),
              if (_compare)
                ..._buildCompare(theme, ings, steps)
              else ...[
                Text((e['title'] as String?) ?? _recipe!.title,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                if ((e['description'] as String?)?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 6),
                  Text(e['description'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
                const SizedBox(height: 20),
                _previewSectionTitle(theme, 'Ingredients'),
                const SizedBox(height: 8),
                ..._buildIngredientPreview(theme, ings),
                const SizedBox(height: 20),
                _previewSectionTitle(theme, 'Instructions'),
                const SizedBox(height: 8),
                ..._buildStepPreview(theme, steps),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _applying ? null : () => setState(() => _enhanced = null),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Discard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _applying ? null : _accept,
                    icon: _applying
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_rounded),
                    label: const Text('Accept & update recipe'),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _changeSummary(ThemeData theme) {
    final e = _enhanced!;
    final newIngs = (e['ingredients'] as List?) ?? const [];
    final newSteps = (e['steps'] as List?) ?? const [];

    bool isHdr(dynamic m) => m is Map && _isHeaderNote(m['notes']);
    final oldIngHeaders = _ingredients.where((i) => i.notes == '__header__').length;
    final oldStepHeaders = _steps.where((s) => s.notes == '__header__').length;
    final newIngHeaders = newIngs.where(isHdr).length;
    final newStepHeaders = newSteps.where(isHdr).length;

    final oldRealIng = _ingredients.length - oldIngHeaders;
    final newRealIng = newIngs.length - newIngHeaders;
    final oldRealStep = _steps.length - oldStepHeaders;
    final newRealStep = newSteps.length - newStepHeaders;
    final addedSections = ((newIngHeaders - oldIngHeaders) + (newStepHeaders - oldStepHeaders)).clamp(0, 999);

    final chips = <Widget>[];
    if (addedSections > 0) {
      chips.add(_summaryChip(theme, Icons.segment, '+$addedSections section${addedSections == 1 ? '' : 's'}',
          theme.colorScheme.primary));
    }
    if (newRealIng != oldRealIng) {
      chips.add(_summaryChip(theme, Icons.warning_amber_rounded,
          'Ingredients $oldRealIng → $newRealIng', theme.colorScheme.error));
    }
    if (newRealStep != oldRealStep) {
      chips.add(_summaryChip(theme, Icons.list_alt, 'Steps $oldRealStep → $newRealStep',
          theme.colorScheme.tertiary));
    }
    if (_recipe!.courseId == null && ((e['course'] as String?)?.trim().isNotEmpty ?? false)) {
      chips.add(_summaryChip(theme, Icons.restaurant_menu, 'Course added', theme.colorScheme.primary));
    }
    if (_recipe!.categoryId == null && ((e['category'] as String?)?.trim().isNotEmpty ?? false)) {
      chips.add(_summaryChip(theme, Icons.category_outlined, 'Category added', theme.colorScheme.primary));
    }
    if (chips.isEmpty) {
      chips.add(_summaryChip(theme, Icons.check_circle_outline, 'Formatting refined', theme.colorScheme.primary));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What changed', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
        if (newRealIng != oldRealIng) ...[
          const SizedBox(height: 8),
          Text('Heads up: the ingredient count changed — double-check nothing was dropped before accepting.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
        ],
      ],
    );
  }

  Widget _summaryChip(ThemeData theme, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _viewToggle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _toggleSeg(theme, 'Result', !_compare, () => setState(() => _compare = false))),
          Expanded(child: _toggleSeg(theme, 'Compare', _compare, () => setState(() => _compare = true))),
        ],
      ),
    );
  }

  Widget _toggleSeg(ThemeData theme, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
            )),
      ),
    );
  }

  List<Widget> _buildCompare(ThemeData theme, List newIngs, List newSteps) {
    ({String text, bool header}) ingLineOf(bool header, String? name, String? amount, String? unit) {
      if (header) return (text: name ?? '', header: true);
      final a = (amount ?? '').trim();
      final u = (unit ?? '').trim();
      final measure = [a, u].where((s) => s.isNotEmpty).join(' ');
      final nm = name ?? '';
      return (text: measure.isEmpty ? nm : '$measure $nm', header: false);
    }

    final oldIngLines =
        _ingredients.map((i) => ingLineOf(i.notes == '__header__', i.name, i.amount, i.unit)).toList();
    final newIngLines = newIngs.map((raw) {
      final m = raw as Map;
      return ingLineOf(_isHeaderNote(m['notes']), m['name'] as String?, m['amount'] as String?, m['unit'] as String?);
    }).toList();

    final oldStepLines =
        _steps.map((s) => (text: s.instruction.trim(), header: s.notes == '__header__')).toList();
    final newStepLines = newSteps.map((raw) {
      final m = raw as Map;
      return (text: ((m['instruction'] as String?) ?? '').trim(), header: _isHeaderNote(m['notes']));
    }).toList();

    final ingDiff = _lineDiff(oldIngLines, newIngLines);
    final stepDiff = _lineDiff(oldStepLines, newStepLines);

    return [
      Row(children: [
        _legendDot(theme, Colors.green, 'Added'),
        const SizedBox(width: 14),
        _legendDot(theme, Colors.red, 'Removed'),
      ]),
      const SizedBox(height: 12),
      _previewSectionTitle(theme, 'Ingredients'),
      const SizedBox(height: 8),
      ...ingDiff.map((op) => _diffRow(theme, op)),
      const SizedBox(height: 20),
      _previewSectionTitle(theme, 'Instructions'),
      const SizedBox(height: 8),
      ...stepDiff.map((op) => _diffRow(theme, op)),
    ];
  }

  Widget _legendDot(ThemeData theme, Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 5),
      Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
    ]);
  }

  Widget _diffRow(ThemeData theme, _DiffOp op) {
    final isDark = theme.brightness == Brightness.dark;
    Color? bg;
    Color marker;
    switch (op.kind) {
      case _DiffKind.add:
        bg = Colors.green.withValues(alpha: isDark ? 0.20 : 0.12);
        marker = Colors.green.shade600;
        break;
      case _DiffKind.remove:
        bg = Colors.red.withValues(alpha: isDark ? 0.18 : 0.10);
        marker = Colors.red.shade400;
        break;
      case _DiffKind.same:
        bg = null;
        marker = Colors.transparent;
        break;
    }
    final removed = op.kind == _DiffKind.remove;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 14,
          child: Text(
            op.kind == _DiffKind.add
                ? '+'
                : op.kind == _DiffKind.remove
                    ? '−'
                    : '',
            style: theme.textTheme.bodyMedium?.copyWith(color: marker, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            op.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: op.header ? FontWeight.w700 : FontWeight.normal,
              color: removed ? theme.colorScheme.outline : (op.header ? theme.colorScheme.primary : null),
              decoration: removed ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _previewSectionTitle(ThemeData theme, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ],
    );
  }

  List<Widget> _buildIngredientPreview(ThemeData theme, List ings) {
    final rows = <Widget>[];
    for (final raw in ings) {
      final ing = raw as Map;
      if (_isHeaderNote(ing['notes'])) {
        rows.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text((ing['name'] as String?) ?? '',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
        ));
      } else {
        final amount = (ing['amount'] as String?)?.trim() ?? '';
        final unit = (ing['unit'] as String?)?.trim() ?? '';
        final measure = [amount, unit].where((s) => s.isNotEmpty).join(' ');
        rows.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 70,
              child: Text(measure,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text((ing['name'] as String?) ?? '', style: theme.textTheme.bodyMedium)),
          ]),
        ));
      }
    }
    return rows;
  }

  List<Widget> _buildStepPreview(ThemeData theme, List steps) {
    final rows = <Widget>[];
    var n = 0;
    for (final raw in steps) {
      final step = raw as Map;
      if (_isHeaderNote(step['notes'])) {
        n = 0;
        rows.add(Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 4),
          child: Text((step['instruction'] as String?) ?? '',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.tertiary)),
        ));
      } else {
        n += 1;
        rows.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primaryContainer),
              child: Text('$n',
                  style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700, color: theme.colorScheme.onPrimaryContainer)),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text((step['instruction'] as String?) ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
            )),
          ]),
        ));
      }
    }
    return rows;
  }

  bool _isHeaderNote(dynamic notes) {
    if (notes is! String) return false;
    final t = notes.trim();
    return t == 'header' || t == '__header__';
  }
}

enum _DiffKind { same, add, remove }

class _DiffOp {
  final String text;
  final bool header;
  final _DiffKind kind;
  const _DiffOp(this.text, this.header, this.kind);
}

/// Classic LCS line diff: returns the merged old→new sequence tagged
/// same / added / removed.
List<_DiffOp> _lineDiff(
  List<({String text, bool header})> a,
  List<({String text, bool header})> b,
) {
  final n = a.length, m = b.length;
  final dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));
  for (var i = n - 1; i >= 0; i--) {
    for (var j = m - 1; j >= 0; j--) {
      dp[i][j] = a[i].text == b[j].text
          ? dp[i + 1][j + 1] + 1
          : (dp[i + 1][j] >= dp[i][j + 1] ? dp[i + 1][j] : dp[i][j + 1]);
    }
  }
  final ops = <_DiffOp>[];
  var i = 0, j = 0;
  while (i < n && j < m) {
    if (a[i].text == b[j].text) {
      ops.add(_DiffOp(b[j].text, b[j].header, _DiffKind.same));
      i++;
      j++;
    } else if (dp[i + 1][j] >= dp[i][j + 1]) {
      ops.add(_DiffOp(a[i].text, a[i].header, _DiffKind.remove));
      i++;
    } else {
      ops.add(_DiffOp(b[j].text, b[j].header, _DiffKind.add));
      j++;
    }
  }
  while (i < n) {
    ops.add(_DiffOp(a[i].text, a[i].header, _DiffKind.remove));
    i++;
  }
  while (j < m) {
    ops.add(_DiffOp(b[j].text, b[j].header, _DiffKind.add));
    j++;
  }
  return ops;
}
