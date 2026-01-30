import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../database/database.dart';
import '../../providers/database_provider.dart';
import '../../providers/cookbook_provider.dart';

/// Copy/Duplicate recipe dialog
void showCopyRecipeDialog(BuildContext context, WidgetRef ref, Recipe recipe) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _CopyRecipeSheet(recipe: recipe, ref: ref),
  );
}

class _CopyRecipeSheet extends StatefulWidget {
  final Recipe recipe;
  final WidgetRef ref;

  const _CopyRecipeSheet({required this.recipe, required this.ref});

  @override
  State<_CopyRecipeSheet> createState() => _CopyRecipeSheetState();
}

class _CopyRecipeSheetState extends State<_CopyRecipeSheet> {
  late TextEditingController _titleController;
  bool _copyIngredients = true;
  bool _copyInstructions = true;
  bool _copyNotes = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: '${widget.recipe.title} (Copy)');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.copy, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Copy Recipe',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // New title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'New Recipe Name',
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 16),

            // Copy options
            Text('What to copy:', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _CopyOption(
              label: 'Ingredients',
              value: _copyIngredients,
              onChanged: (v) => setState(() => _copyIngredients = v ?? true),
            ),
            _CopyOption(
              label: 'Instructions',
              value: _copyInstructions,
              onChanged: (v) => setState(() => _copyInstructions = v ?? true),
            ),
            _CopyOption(
              label: 'Notes',
              value: _copyNotes,
              onChanged: (v) => setState(() => _copyNotes = v ?? true),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _copyRecipe,
                icon: _isSaving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Copying...' : 'Create Copy'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyRecipe() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final recipeDao = widget.ref.read(recipeDaoProvider);
      final newId = 'recipe_${DateTime.now().millisecondsSinceEpoch}';

      // Create the new recipe
      await recipeDao.insertRecipe(RecipesCompanion.insert(
        id: newId,
        cookbookId: widget.recipe.cookbookId,
        title: _titleController.text.trim(),
        description: drift.Value(widget.recipe.description),
        servings: drift.Value(widget.recipe.servings),
        prepTimeMinutes: drift.Value(widget.recipe.prepTimeMinutes),
        cookTimeMinutes: drift.Value(widget.recipe.cookTimeMinutes),
        sourceUrl: drift.Value(widget.recipe.sourceUrl),
        courseId: drift.Value(widget.recipe.courseId),
        categoryId: drift.Value(widget.recipe.categoryId),
        notes: drift.Value(_copyNotes ? widget.recipe.notes : null),
      ));

      // Copy ingredients
      if (_copyIngredients) {
        final ingredients = await recipeDao.getIngredientsForRecipe(widget.recipe.id);
        for (var i = 0; i < ingredients.length; i++) {
          final ing = ingredients[i];
          await recipeDao.insertIngredient(IngredientsCompanion.insert(
            id: 'ing_${newId}_$i',
            recipeId: newId,
            name: ing.name,
            amount: drift.Value(ing.amount),
            unit: drift.Value(ing.unit),
            notes: drift.Value(ing.notes),
            sortOrder: ing.sortOrder,
          ));
        }
      }

      // Copy instructions
      if (_copyInstructions) {
        final steps = await recipeDao.getStepsForRecipe(widget.recipe.id);
        for (var i = 0; i < steps.length; i++) {
          final step = steps[i];
          await recipeDao.insertStep(StepsCompanion.insert(
            id: 'step_${newId}_$i',
            recipeId: newId,
            instruction: step.instruction,
            sortOrder: step.sortOrder,
          ));
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created "${_titleController.text.trim()}"'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => context.push('/recipe/$newId'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _CopyOption extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CopyOption({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// Move to cookbook dialog
void showMoveRecipeDialog(BuildContext context, WidgetRef ref, Recipe recipe) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _MoveRecipeSheet(recipe: recipe, ref: ref),
  );
}

class _MoveRecipeSheet extends StatefulWidget {
  final Recipe recipe;
  final WidgetRef ref;

  const _MoveRecipeSheet({required this.recipe, required this.ref});

  @override
  State<_MoveRecipeSheet> createState() => _MoveRecipeSheetState();
}

class _MoveRecipeSheetState extends State<_MoveRecipeSheet> {
  String? _selectedCookbookId;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cookbooksAsync = widget.ref.watch(cookbooksProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.drive_file_move, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Move Recipe',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Move "${widget.recipe.title}" to another cookbook',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 16),

            // Cookbook list
            Expanded(
              child: cookbooksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (cookbooks) {
                  final available = cookbooks.where((c) => c.id != widget.recipe.cookbookId).toList();

                  if (available.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.book, size: 48, color: theme.colorScheme.outline),
                          const SizedBox(height: 16),
                          Text('No other cookbooks available', style: theme.textTheme.bodyLarge),
                          const SizedBox(height: 8),
                          Text('Create another cookbook first', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: available.length,
                    itemBuilder: (context, index) {
                      final cookbook = available[index];
                      return ListTile(
                        title: Text(cookbook.name),
                        subtitle: cookbook.description != null ? Text(cookbook.description!) : null,
                        leading: Radio<String>(
                          value: cookbook.id,
                          groupValue: _selectedCookbookId,
                          onChanged: (v) => setState(() => _selectedCookbookId = v),
                        ),
                        onTap: () => setState(() => _selectedCookbookId = cookbook.id),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Move button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _selectedCookbookId == null || _isSaving ? null : _moveRecipe,
                icon: _isSaving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.check),
                label: Text(_isSaving ? 'Moving...' : 'Move Recipe'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _moveRecipe() async {
    if (_selectedCookbookId == null) return;

    setState(() => _isSaving = true);

    try {
      final recipeDao = widget.ref.read(recipeDaoProvider);

      await recipeDao.updateRecipeFields(
        widget.recipe.id,
        RecipesCompanion(cookbookId: drift.Value(_selectedCookbookId!)),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe moved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

/// Add to multiple cookbooks dialog
void showAddToCookbooksDialog(BuildContext context, WidgetRef ref, Recipe recipe) {
  showDialog(
    context: context,
    builder: (ctx) => _AddToCookbooksDialog(recipe: recipe),
  );
}

class _AddToCookbooksDialog extends ConsumerStatefulWidget {
  final Recipe recipe;

  const _AddToCookbooksDialog({required this.recipe});

  @override
  ConsumerState<_AddToCookbooksDialog> createState() => _AddToCookbooksDialogState();
}

class _AddToCookbooksDialogState extends ConsumerState<_AddToCookbooksDialog> {
  final Set<String> _selectedCookbookIds = {};
  List<Cookbook> _cookbooks = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCookbooks();
  }

  Future<void> _loadCookbooks() async {
    final cookbookDao = ref.read(cookbookDaoProvider);
    final cookbooks = await cookbookDao.getAllCookbooks();
    setState(() {
      _cookbooks = cookbooks.where((cb) => cb.id != widget.recipe.cookbookId).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.library_add, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          const Text('Add to Cookbooks'),
        ],
      ),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cookbooks.isEmpty
          ? const Text('No other cookbooks available.')
          : Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add a copy of "${widget.recipe.title}" to:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ..._cookbooks.map((cb) {
            final isSelected = _selectedCookbookIds.contains(cb.id);
            return CheckboxListTile(
              value: isSelected,
              title: Text(cb.name),
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _selectedCookbookIds.add(cb.id);
                  } else {
                    _selectedCookbookIds.remove(cb.id);
                  }
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedCookbookIds.isEmpty || _isSaving ? null : _addToCookbooks,
          child: Text(_isSaving ? 'Adding...' : 'Add to ${_selectedCookbookIds.length} Cookbook(s)'),
        ),
      ],
    );
  }

  Future<void> _addToCookbooks() async {
    if (_selectedCookbookIds.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final recipeDao = ref.read(recipeDaoProvider);
      final ingredients = await recipeDao.getIngredientsForRecipe(widget.recipe.id);
      final steps = await recipeDao.getStepsForRecipe(widget.recipe.id);

      for (final cookbookId in _selectedCookbookIds) {
        final newId = 'recipe_${DateTime.now().millisecondsSinceEpoch}_$cookbookId';

        // Create copy
        await recipeDao.insertRecipe(RecipesCompanion.insert(
          id: newId,
          cookbookId: cookbookId,
          title: widget.recipe.title,
          description: drift.Value(widget.recipe.description),
          servings: drift.Value(widget.recipe.servings),
          prepTimeMinutes: drift.Value(widget.recipe.prepTimeMinutes),
          cookTimeMinutes: drift.Value(widget.recipe.cookTimeMinutes),
          sourceUrl: drift.Value(widget.recipe.sourceUrl),
          imagePath: drift.Value(widget.recipe.imagePath),
          courseId: drift.Value(widget.recipe.courseId),
          categoryId: drift.Value(widget.recipe.categoryId),
          notes: drift.Value(widget.recipe.notes),
        ));

        // Copy ingredients
        for (var i = 0; i < ingredients.length; i++) {
          final ing = ingredients[i];
          await recipeDao.insertIngredient(IngredientsCompanion.insert(
            id: 'ing_${newId}_$i',
            recipeId: newId,
            name: ing.name,
            amount: drift.Value(ing.amount),
            unit: drift.Value(ing.unit),
            notes: drift.Value(ing.notes),
            sortOrder: ing.sortOrder,
          ));
        }

        // Copy steps
        for (var i = 0; i < steps.length; i++) {
          final step = steps[i];
          await recipeDao.insertStep(StepsCompanion.insert(
            id: 'step_${newId}_$i',
            recipeId: newId,
            instruction: step.instruction,
            sortOrder: step.sortOrder,
          ));
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added to ${_selectedCookbookIds.length} cookbook(s)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}