import 'dart:convert';
import 'dart:io';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drift/drift.dart' as drift;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../database/database.dart';
import '../../../database/daos/tags_dao.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../data/course_category_data.dart';
import '../../../data/nutrition_data.dart';
import '../../widgets/taxonomy_picker.dart';
import '../../widgets/tag_picker.dart';
import '../../widgets/nutrition_calculation_sheet.dart';
import '../../widgets/rpg_rarity_picker.dart';

class RecipeEditScreen extends ConsumerStatefulWidget {
  final String? recipeId;
  final String? cookbookId;
  final Map<String, dynamic>? importedData;

  const RecipeEditScreen({
    super.key,
    this.recipeId,
    this.cookbookId,
    this.importedData,
  });

  @override
  ConsumerState<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends ConsumerState<RecipeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servingsController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _sourceUrlController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _notesController = TextEditingController();

  String? _imagePath;
  String? _imageUrl;
  String? _selectedCourseId;
  String? _selectedCategoryId;
  int _rating = 0;
  List<String> _selectedTagIds = [];

  // Nutrition state
  NutritionData? _nutrition;
  bool _isCalculatingNutrition = false;

  bool _isLoading = true;
  bool _isSaving = false;

  final List<_SimpleIngredient> _ingredients = [];

  bool get _isEditing => widget.recipeId != null;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    if (widget.importedData != null) {
      _prefillFromImport(widget.importedData!);
      setState(() => _isLoading = false);
      return;
    }

    if (!_isEditing) {
      setState(() => _isLoading = false);
      return;
    }

    final recipeDao = ref.read(recipeDaoProvider);
    final tagsDao = ref.read(tagsDaoProvider);
    final recipe = await recipeDao.getRecipeById(widget.recipeId!);

    if (recipe == null) {
      setState(() => _isLoading = false);
      return;
    }

    _titleController.text = recipe.title;
    _descriptionController.text = recipe.description ?? '';
    _servingsController.text = recipe.servings ?? '';
    _prepTimeController.text = recipe.prepTimeMinutes?.toString() ?? '';
    _cookTimeController.text = recipe.cookTimeMinutes?.toString() ?? '';
    _sourceUrlController.text = recipe.sourceUrl ?? '';
    _imagePath = recipe.imagePath;
    _rating = recipe.rating ?? 0;
    _selectedCourseId = recipe.courseId;
    _selectedCategoryId = recipe.categoryId;

    // Load existing nutrition
    if (recipe.nutritionJson != null && recipe.nutritionJson!.isNotEmpty) {
      try {
        final json = jsonDecode(recipe.nutritionJson!) as Map<String, dynamic>;
        _nutrition = NutritionData.fromJson(json);
      } catch (e) {
        // Ignore parse errors
      }
    }

    // Load existing tags
    final tags = await tagsDao.getTagsForRecipe(widget.recipeId!);
    _selectedTagIds = tags.map((t) => t.id).toList();

    // Load ingredients
    final ingredients = await recipeDao.getIngredientsForRecipe(widget.recipeId!);
    for (final ing in ingredients) {
      final parts = <String>[];
      if (ing.amount != null && ing.amount!.isNotEmpty) parts.add(ing.amount!);
      if (ing.unit != null && ing.unit!.isNotEmpty) parts.add(ing.unit!);
      parts.add(ing.name);
      if (ing.notes != null && ing.notes!.isNotEmpty) parts.add('(${ing.notes})');
      _ingredients.add(_SimpleIngredient(id: ing.id, text: parts.join(' ')));
    }

    // Load instructions
    final steps = await recipeDao.getStepsForRecipe(widget.recipeId!);
    _instructionsController.text = steps.map((s) => s.instruction).join('\n\n');
    _notesController.text = recipe.notes ?? '';

    setState(() => _isLoading = false);
  }

  void _prefillFromImport(Map<String, dynamic> data) {
    _titleController.text = data['title'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _servingsController.text = data['servings']?.toString() ?? '';
    _prepTimeController.text = data['prepTime']?.toString() ?? '';
    _cookTimeController.text = data['cookTime']?.toString() ?? '';
    _sourceUrlController.text = data['sourceUrl'] ?? '';
    _imageUrl = data['imageUrl'];

    if (data['ingredients'] is List) {
      for (final ing in data['ingredients']) {
        _ingredients.add(_SimpleIngredient(
          id: DateTime.now().millisecondsSinceEpoch.toString() + _ingredients.length.toString(),
          text: ing.toString(),
        ));
      }
    }

    if (data['instructions'] is List) {
      _instructionsController.text = (data['instructions'] as List).join('\n\n');
    } else if (data['instructions'] is String) {
      _instructionsController.text = data['instructions'];
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _sourceUrlController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final isRpgMode = settings.nerdMode;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEditing ? l10n.recipeEdit : l10n.recipeAdd)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.recipeEdit : l10n.recipeAdd),
        actions: [
          FilledButton(
            onPressed: _isSaving ? null : _saveRecipe,
            child: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.actionSave),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PhotoPicker(imagePath: _imagePath, onImageSelected: (path) => setState(() => _imagePath = path)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l10n.recipeFieldTitle, hintText: 'e.g., Grandma\'s Apple Pie'),
                textCapitalization: TextCapitalization.words,
                validator: (value) => (value == null || value.trim().isEmpty) ? l10n.errorGeneric : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: l10n.recipeFieldDescription, hintText: 'A brief description of the recipe'),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),
              CoursePicker(selectedCourseId: _selectedCourseId, onChanged: (id) => setState(() => _selectedCourseId = id)),
              const SizedBox(height: 16),
              CategoryPicker(selectedCategoryId: _selectedCategoryId, onChanged: (id) => setState(() => _selectedCategoryId = id)),
              const SizedBox(height: 20),
              TagPicker(recipeId: widget.recipeId ?? '', initialTagIds: _selectedTagIds, onTagsChanged: (tagIds) => setState(() => _selectedTagIds = tagIds)),
              const SizedBox(height: 20),
              // Show RPG rarity picker or standard star rating based on settings
              if (isRpgMode)
                RpgRarityPicker(
                  initialRating: _rating == 0 ? 1 : _rating,
                  onChanged: (r) => setState(() => _rating = r),
                  enableAnimations: settings.rpgAnimationsEnabled,
                )
              else
                _RatingSelector(rating: _rating, onChanged: (r) => setState(() => _rating = r)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: TextFormField(controller: _servingsController, decoration: InputDecoration(labelText: l10n.recipeFieldServings, hintText: 'e.g., 4'))),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: _prepTimeController, decoration: const InputDecoration(labelText: 'Prep (min)'), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: _cookTimeController, decoration: const InputDecoration(labelText: 'Cook (min)'), keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 16),
              TextFormField(controller: _sourceUrlController, decoration: InputDecoration(labelText: l10n.recipeFieldSource, hintText: 'https://...', prefixIcon: const Icon(Icons.link)), keyboardType: TextInputType.url),
              const SizedBox(height: 32),
              _SectionTitle(title: l10n.ingredientsTitle),
              const SizedBox(height: 12),
              ..._ingredients.asMap().entries.map((entry) => _IngredientRow(
                key: ValueKey(entry.value.id),
                ingredient: entry.value,
                onChanged: (text) => setState(() => _ingredients[entry.key].text = text),
                onDelete: () => setState(() => _ingredients.removeAt(entry.key)),
              )),
              _AddIngredientButton(onTap: _addIngredient),
              const SizedBox(height: 32),
              _SectionTitle(title: l10n.instructionsTitle),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructionsController,
                decoration: InputDecoration(hintText: 'Write your instructions here...\n\n1. First step\n2. Second step', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), alignLabelWithHint: true),
                maxLines: 10,
                minLines: 5,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),
              _SectionTitle(title: l10n.recipeFieldNotes),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(hintText: 'Tips, variations, storage instructions...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), alignLabelWithHint: true),
                maxLines: 5,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),
              _SectionTitle(title: l10n.nutritionTitle),
              const SizedBox(height: 12),
              _NutritionSection(nutrition: _nutrition, isCalculating: _isCalculatingNutrition, onCalculate: _calculateNutrition, onClear: () => setState(() => _nutrition = null)),
            ],
          ),
        ),
      ),
    );
  }

  void _addIngredient() {
    setState(() => _ingredients.add(_SimpleIngredient(id: DateTime.now().millisecondsSinceEpoch.toString(), text: '')));
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  Future<void> _calculateNutrition() async {
    final l10n = AppLocalizations.of(context)!;

    final ingredientTexts = _ingredients.where((i) => i.text.trim().isNotEmpty).map((i) => i.text.trim()).toList();

    if (ingredientTexts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.ingredientsEmpty)));
      return;
    }

    // If existing nutrition, ask for confirmation
    if (_nutrition != null && !_nutrition!.isEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.nutritionOverwriteTitle),
          content: Text(l10n.nutritionOverwriteMessage),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.actionContinue)),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _isCalculatingNutrition = true);

    try {
      final ingredients = ingredientTexts.map((text) {
        final parsed = _parseIngredient(text);
        return Ingredient(id: 'temp_${text.hashCode}', recipeId: widget.recipeId ?? 'new', sortOrder: 0, name: parsed.name, amount: parsed.amount, unit: parsed.unit, notes: parsed.notes);
      }).toList();

      final result = await NutritionCalculationSheet.show(context: context, ingredients: ingredients, servings: _servingsController.text.isNotEmpty ? _servingsController.text : '1', existingNutrition: null);

      if (result != null && mounted) {
        setState(() => _nutrition = result);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.nutritionCalculated)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.nutritionCalculationFailed}: $e')));
    } finally {
      if (mounted) setState(() => _isCalculatingNutrition = false);
    }
  }

  Future<void> _saveRecipe() async {
    final l10n = AppLocalizations.of(context)!;
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final recipeDao = ref.read(recipeDaoProvider);
      final tagsDao = ref.read(tagsDaoProvider);
      final prepTime = int.tryParse(_prepTimeController.text.trim());
      final cookTime = int.tryParse(_cookTimeController.text.trim());

      String? finalImagePath = _imagePath;
      if (_imageUrl != null && _imagePath == null) {
        final recipeId = widget.recipeId ?? 'recipe_${DateTime.now().millisecondsSinceEpoch}';
        finalImagePath = await _downloadImage(_imageUrl!, recipeId);
      }

      final nutritionJson = _nutrition != null && !_nutrition!.isEmpty ? jsonEncode(_nutrition!.toJson()) : null;
      String recipeId;

      if (_isEditing) {
        recipeId = widget.recipeId!;
        final recipe = RecipesCompanion(
          title: drift.Value(_titleController.text.trim()),
          description: drift.Value(_descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim()),
          servings: drift.Value(_servingsController.text.trim().isEmpty ? null : _servingsController.text.trim()),
          prepTimeMinutes: drift.Value(prepTime),
          cookTimeMinutes: drift.Value(cookTime),
          sourceUrl: drift.Value(_sourceUrlController.text.trim().isEmpty ? null : _sourceUrlController.text.trim()),
          imagePath: drift.Value(finalImagePath),
          courseId: drift.Value(_selectedCourseId),
          categoryId: drift.Value(_selectedCategoryId),
          rating: drift.Value(_rating),
          notes: drift.Value(_notesController.text.trim().isEmpty ? null : _notesController.text.trim()),
          nutritionJson: drift.Value(nutritionJson),
          updatedAt: drift.Value(DateTime.now()),
        );
        await recipeDao.updateRecipeFields(widget.recipeId!, recipe);

        await recipeDao.deleteIngredientsForRecipe(widget.recipeId!);
        for (var i = 0; i < _ingredients.length; i++) {
          if (_ingredients[i].text.trim().isNotEmpty) {
            final parsed = _parseIngredient(_ingredients[i].text);
            await recipeDao.insertIngredient(IngredientsCompanion.insert(id: '${widget.recipeId}_ing_$i', recipeId: widget.recipeId!, sortOrder: i, name: parsed.name, amount: drift.Value(parsed.amount), unit: drift.Value(parsed.unit), notes: drift.Value(parsed.notes)));
          }
        }

        await recipeDao.deleteStepsForRecipe(widget.recipeId!);
        final steps = _instructionsController.text.trim().split(RegExp(r'\n\n+'));
        for (var i = 0; i < steps.length; i++) {
          if (steps[i].trim().isNotEmpty) {
            await recipeDao.insertStep(StepsCompanion.insert(id: '${widget.recipeId}_step_$i', recipeId: widget.recipeId!, sortOrder: i, instruction: steps[i].trim()));
          }
        }
      } else {
        recipeId = 'recipe_${DateTime.now().millisecondsSinceEpoch}';
        final cookbookId = widget.cookbookId ?? 'starter';

        await recipeDao.insertRecipe(RecipesCompanion.insert(
          id: recipeId,
          cookbookId: cookbookId,
          title: _titleController.text.trim(),
          description: drift.Value(_descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim()),
          servings: drift.Value(_servingsController.text.trim().isEmpty ? null : _servingsController.text.trim()),
          prepTimeMinutes: drift.Value(prepTime),
          cookTimeMinutes: drift.Value(cookTime),
          sourceUrl: drift.Value(_sourceUrlController.text.trim().isEmpty ? null : _sourceUrlController.text.trim()),
          imagePath: drift.Value(finalImagePath),
          courseId: drift.Value(_selectedCourseId),
          categoryId: drift.Value(_selectedCategoryId),
          rating: drift.Value(_rating),
          notes: drift.Value(_notesController.text.trim().isEmpty ? null : _notesController.text.trim()),
          nutritionJson: drift.Value(nutritionJson),
        ));

        for (var i = 0; i < _ingredients.length; i++) {
          if (_ingredients[i].text.trim().isNotEmpty) {
            final parsed = _parseIngredient(_ingredients[i].text);
            await recipeDao.insertIngredient(IngredientsCompanion.insert(id: '${recipeId}_ing_$i', recipeId: recipeId, sortOrder: i, name: parsed.name, amount: drift.Value(parsed.amount), unit: drift.Value(parsed.unit), notes: drift.Value(parsed.notes)));
          }
        }

        final steps = _instructionsController.text.trim().split(RegExp(r'\n\n+'));
        for (var i = 0; i < steps.length; i++) {
          if (steps[i].trim().isNotEmpty) {
            await recipeDao.insertStep(StepsCompanion.insert(id: '${recipeId}_step_$i', recipeId: recipeId, sortOrder: i, instruction: steps[i].trim()));
          }
        }
      }

      await tagsDao.setTagsForRecipe(recipeId, _selectedTagIds);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditing ? 'Recipe updated!' : l10n.successSaved)));
        context.pop(true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving recipe: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<String?> _downloadImage(String url, String recipeId) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;
      final dir = await getApplicationDocumentsDirectory();
      final ext = p.extension(url).split('?').first;
      final filename = 'recipe_$recipeId${ext.isEmpty ? '.jpg' : ext}';
      final file = File(p.join(dir.path, 'images', filename));
      await file.parent.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } catch (e) { return null; }
  }

  _ParsedIngredient _parseIngredient(String text) {
    final trimmed = text.trim();
    const units = ['tablespoons?', 'teaspoons?', 'fluid\\s*ounces?', 'milliliters?', 'kilograms?', 'gallons?', 'liters?', 'litres?', 'quarts?', 'pints?', 'cups?', 'ounces?', 'pounds?', 'grams?', 'tbsps?', 'tbsp', 'tsps?', 'fl\\.?\\s*oz', 'lbs?', 'kgs?', 'pkg', 'oz', 'ml', 'kg', 'tbs', 'tsp', 'lb', 'qt', 'pt', 'c', 'g', 'l', 'pinche?s?', 'dashe?s?', 'cloves?', 'slices?', 'pieces?', 'cans?', 'packages?', 'bunche?s?', 'stalks?', 'sprigs?', 'heads?', 'sticks?', 'large', 'medium', 'small', 'whole'];
    final unitPattern = '(?:' + units.join('|') + r')(?=\s|$)';
    final pattern = RegExp(r'^([\d½¼¾⅓⅔⅛⅜⅝⅞\s\.\/\-]+)?\s*(' + unitPattern + r')?\s*(.+?)(?:\s*\(([^)]+)\))?$', caseSensitive: false);
    final match = pattern.firstMatch(trimmed);
    if (match != null) {
      final amount = match.group(1)?.trim();
      final unit = match.group(2)?.trim();
      final name = match.group(3)?.trim() ?? trimmed;
      final notes = match.group(4)?.trim();
      if (name.isEmpty && unit != null) return _ParsedIngredient(name: trimmed);
      return _ParsedIngredient(amount: amount, unit: unit, name: name, notes: notes);
    }
    return _ParsedIngredient(name: trimmed);
  }
}

class _NutritionSection extends StatelessWidget {
  final NutritionData? nutrition;
  final bool isCalculating;
  final VoidCallback onCalculate;
  final VoidCallback onClear;
  const _NutritionSection({required this.nutrition, required this.isCalculating, required this.onCalculate, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (nutrition == null || nutrition!.isEmpty) {
      return _CalculateNutritionCard(isCalculating: isCalculating, onCalculate: onCalculate);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.local_fire_department, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(l10n.nutritionPerServing, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          if (nutrition!.calories != null) Text('${nutrition!.calories!.round()} cal', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _MacroChip(label: l10n.nutritionProtein, value: nutrition!.protein, unit: 'g', theme: theme)),
          const SizedBox(width: 8),
          Expanded(child: _MacroChip(label: l10n.nutritionCarbs, value: nutrition!.carbohydrates, unit: 'g', theme: theme)),
          const SizedBox(width: 8),
          Expanded(child: _MacroChip(label: l10n.nutritionFat, value: nutrition!.fat, unit: 'g', theme: theme)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: isCalculating ? null : onCalculate,
            icon: isCalculating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.refresh, size: 18),
            label: Text(l10n.nutritionRecalculate),
          )),
          const SizedBox(width: 8),
          IconButton(onPressed: onClear, icon: const Icon(Icons.delete_outline), tooltip: l10n.actionDelete, style: IconButton.styleFrom(foregroundColor: theme.colorScheme.error)),
        ]),
      ]),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label; final double? value; final String unit; final ThemeData theme;
  const _MacroChip({required this.label, required this.value, required this.unit, required this.theme});
  @override Widget build(BuildContext context) {
    final displayValue = value == null ? '-' : value! < 1 ? value!.toStringAsFixed(1) : value!.round().toString();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text('$displayValue$unit', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
      ]),
    );
  }
}

class _CalculateNutritionCard extends StatelessWidget {
  final bool isCalculating; final VoidCallback onCalculate;
  const _CalculateNutritionCard({required this.isCalculating, required this.onCalculate});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: isCalculating ? null : onCalculate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3))),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
            child: isCalculating
                ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimaryContainer))
                : Icon(Icons.calculate_outlined, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.nutritionCalculate, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            const SizedBox(height: 4),
            Text(l10n.nutritionMatchingIngredients, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ])),
          Icon(Icons.chevron_right, color: theme.colorScheme.primary),
        ]),
      ),
    );
  }
}

class _SimpleIngredient { final String id; String text; _SimpleIngredient({required this.id, this.text = ''}); }
class _ParsedIngredient { final String? amount; final String? unit; final String name; final String? notes; _ParsedIngredient({this.amount, this.unit, required this.name, this.notes}); }

class _PhotoPicker extends StatelessWidget {
  final String? imagePath; final ValueChanged<String?> onImageSelected;
  const _PhotoPicker({required this.imagePath, required this.onImageSelected});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showImageOptions(context),
      child: Container(
        height: 200, width: double.infinity,
        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outlineVariant, width: 1), image: imagePath != null ? DecorationImage(image: FileImage(File(imagePath!)), fit: BoxFit.cover) : null),
        child: imagePath == null
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.add_photo_alternate_outlined, size: 32, color: theme.colorScheme.primary)),
          const SizedBox(height: 12),
          Text('Add Photo', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 4),
          Text('Tap to select from gallery or camera', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        ])
            : Stack(children: [Positioned(top: 8, right: 8, child: Row(children: [_ImageActionButton(icon: Icons.edit, onTap: () => _showImageOptions(context)), const SizedBox(width: 8), _ImageActionButton(icon: Icons.close, onTap: () => onImageSelected(null))]))]),
      ),
    );
  }
  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.photo_library), title: const Text('Choose from gallery'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
      ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Take a photo'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
    ])));
  }
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 1200, maxHeight: 1200, imageQuality: 85);
    if (image != null) onImageSelected(image.path);
  }
}

class _ImageActionButton extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _ImageActionButton({required this.icon, required this.onTap});
  @override Widget build(BuildContext context) => Material(color: Colors.black54, shape: const CircleBorder(), child: InkWell(onTap: onTap, customBorder: const CircleBorder(), child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, color: Colors.white, size: 20))));
}

class _RatingSelector extends StatelessWidget {
  final int rating; final ValueChanged<int> onChanged;
  const _RatingSelector({required this.rating, required this.onChanged});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Rating', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
      const SizedBox(height: 8),
      Row(children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isSelected = starIndex <= rating;
        return GestureDetector(onTap: () => onChanged(starIndex == rating ? 0 : starIndex), child: Padding(padding: const EdgeInsets.only(right: 4), child: Icon(isSelected ? Icons.star_rounded : Icons.star_outline_rounded, color: isSelected ? Colors.amber : theme.colorScheme.outline, size: 36)));
      })),
    ]);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700));
}

class _IngredientRow extends StatelessWidget {
  final _SimpleIngredient ingredient; final ValueChanged<String> onChanged; final VoidCallback onDelete;
  const _IngredientRow({super.key, required this.ingredient, required this.onChanged, required this.onDelete});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle)),
      const SizedBox(width: 12),
      Expanded(child: TextFormField(initialValue: ingredient.text, decoration: const InputDecoration(hintText: 'e.g., 2 cups flour', isDense: true, border: OutlineInputBorder()), textCapitalization: TextCapitalization.sentences, onChanged: onChanged)),
      IconButton(icon: Icon(Icons.close, size: 20, color: theme.colorScheme.outline), onPressed: onDelete, visualDensity: VisualDensity.compact),
    ]));
  }
}

class _AddIngredientButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddIngredientButton({required this.onTap});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.outlineVariant), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add, color: theme.colorScheme.primary, size: 20), const SizedBox(width: 8), Text('Add Ingredient', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary))]),
    ));
  }
}