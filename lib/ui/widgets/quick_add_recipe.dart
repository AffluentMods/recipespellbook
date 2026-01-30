import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../database/database.dart';
import '../../providers/database_provider.dart';

/// Shows a quick add recipe dialog for fast entry
void showQuickAddRecipeDialog(BuildContext context, WidgetRef ref, {String? cookbookId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _QuickAddRecipeSheet(cookbookId: cookbookId),
  );
}

class _QuickAddRecipeSheet extends ConsumerStatefulWidget {
  final String? cookbookId;
  const _QuickAddRecipeSheet({this.cookbookId});

  @override
  ConsumerState<_QuickAddRecipeSheet> createState() => _QuickAddRecipeSheetState();
}

class _QuickAddRecipeSheetState extends ConsumerState<_QuickAddRecipeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _servingsController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();

  bool _isSaving = false;
  bool _showMoreFields = false;

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _servingsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.bolt, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Quick Add Recipe', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Just the essentials', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                  ])),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ]),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Recipe Name *',
                    hintText: 'e.g., Grandma\'s Apple Pie',
                    prefixIcon: Icon(Icons.restaurant_menu),
                  ),
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(
                    labelText: 'Ingredients',
                    hintText: 'One per line:\n2 cups flour\n1 tsp salt\n...',
                    prefixIcon: Icon(Icons.list),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(
                    labelText: 'Instructions',
                    hintText: 'Separate steps with blank lines:\nMix dry ingredients.\n\nAdd wet ingredients.\n\n...',
                    prefixIcon: Icon(Icons.format_list_numbered),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                ),

                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => setState(() => _showMoreFields = !_showMoreFields),
                  icon: Icon(_showMoreFields ? Icons.expand_less : Icons.expand_more),
                  label: Text(_showMoreFields ? 'Less options' : 'More options'),
                ),

                if (_showMoreFields) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextFormField(
                      controller: _servingsController,
                      decoration: const InputDecoration(labelText: 'Servings', prefixIcon: Icon(Icons.people)),
                      keyboardType: TextInputType.number,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(
                      controller: _prepTimeController,
                      decoration: const InputDecoration(labelText: 'Prep (min)', prefixIcon: Icon(Icons.timer_outlined)),
                      keyboardType: TextInputType.number,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(
                      controller: _cookTimeController,
                      decoration: const InputDecoration(labelText: 'Cook (min)', prefixIcon: Icon(Icons.local_fire_department)),
                      keyboardType: TextInputType.number,
                    )),
                  ]),
                ],

                const SizedBox(height: 24),

                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _saveRecipe,
                      icon: _isSaving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Saving...' : 'Save Recipe'),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Center(child: Text('You can add more details later', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final recipeDao = ref.read(recipeDaoProvider);
      final recipeId = 'recipe_${DateTime.now().millisecondsSinceEpoch}';
      String cookbookId = widget.cookbookId ?? 'cookbook_default';

      await recipeDao.insertRecipe(RecipesCompanion.insert(
        id: recipeId,
        cookbookId: cookbookId,
        title: _titleController.text.trim(),
        servings: drift.Value(_servingsController.text.trim().isNotEmpty ? _servingsController.text.trim() : null),
        prepTimeMinutes: drift.Value(int.tryParse(_prepTimeController.text.trim())),
        cookTimeMinutes: drift.Value(int.tryParse(_cookTimeController.text.trim())),
      ));

      final ingredientLines = _ingredientsController.text.split('\n').where((line) => line.trim().isNotEmpty).toList();
      for (var i = 0; i < ingredientLines.length; i++) {
        final line = ingredientLines[i].trim();
        final parsed = _parseIngredientLine(line);
        await recipeDao.insertIngredient(IngredientsCompanion.insert(
          id: 'ing_${recipeId}_$i',
          recipeId: recipeId,
          name: parsed['name']!,
          amount: drift.Value(parsed['amount']),
          unit: drift.Value(parsed['unit']),
          sortOrder: i,
        ));
      }

      final steps = _instructionsController.text.split(RegExp(r'\n\n+')).where((step) => step.trim().isNotEmpty).toList();
      for (var i = 0; i < steps.length; i++) {
        await recipeDao.insertStep(StepsCompanion.insert(
          id: 'step_${recipeId}_$i',
          recipeId: recipeId,
          instruction: steps[i].trim(),
          sortOrder: i,
        ));
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Created "${_titleController.text.trim()}"'),
          action: SnackBarAction(label: 'View', onPressed: () => context.push('/recipe/$recipeId')),
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Map<String, String?> _parseIngredientLine(String line) {
    final amountPattern = RegExp(r'^([\d./]+)\s*');
    final unitPattern = RegExp(r'^(cup|cups|tbsp|tablespoon|tablespoons|tsp|teaspoon|teaspoons|oz|ounce|ounces|lb|lbs|pound|pounds|g|gram|grams|kg|ml|l|liter|liters|pinch|dash|clove|cloves|can|cans|package|packages|bunch|bunches|slice|slices|piece|pieces)s?\b\s*', caseSensitive: false);

    String remaining = line;
    String? amount;
    String? unit;

    final amountMatch = amountPattern.firstMatch(remaining);
    if (amountMatch != null) {
      amount = amountMatch.group(1);
      remaining = remaining.substring(amountMatch.end).trim();
    }

    final unitMatch = unitPattern.firstMatch(remaining);
    if (unitMatch != null) {
      unit = unitMatch.group(1);
      remaining = remaining.substring(unitMatch.end).trim();
    }

    return {'amount': amount, 'unit': unit, 'name': remaining.isNotEmpty ? remaining : line};
  }
}

class RecipeFabMenu extends StatefulWidget {
  final String? cookbookId;
  const RecipeFabMenu({super.key, this.cookbookId});

  @override
  State<RecipeFabMenu> createState() => _RecipeFabMenuState();
}

class _RecipeFabMenuState extends State<RecipeFabMenu> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isExpanded) ...[
          _MiniFab(icon: Icons.bolt, label: 'Quick Add', onTap: () => setState(() => _isExpanded = false)),
          const SizedBox(height: 8),
          _MiniFab(icon: Icons.link, label: 'Import URL', onTap: () { setState(() => _isExpanded = false); context.push('/import/url'); }),
          const SizedBox(height: 8),
          _MiniFab(icon: Icons.camera_alt, label: 'Scan', onTap: () { setState(() => _isExpanded = false); context.push('/import/scan'); }),
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          child: AnimatedRotation(duration: const Duration(milliseconds: 200), turns: _isExpanded ? 0.125 : 0, child: const Icon(Icons.add)),
        ),
      ],
    );
  }
}

class _MiniFab extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MiniFab({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)),
        child: Text(label, style: theme.textTheme.labelMedium),
      ),
      const SizedBox(width: 8),
      FloatingActionButton.small(heroTag: label, onPressed: onTap, child: Icon(icon)),
    ]);
  }
}