import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drift/drift.dart' as drift;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../database/database.dart';
import '../../../database/daos/recipe_dao.dart' show RecipeLinkInfo;
import '../../../database/daos/tags_dao.dart';
import '../../../providers/database_provider.dart';
import '../../../utils/default_recipe_images.dart';
import '../../../providers/settings_provider.dart';
import '../../../data/course_category_data.dart';
import '../../../data/nutrition_data.dart';
import '../../widgets/taxonomy_picker.dart';
import '../../widgets/tag_picker.dart';
import '../../widgets/nutrition_calculation_sheet.dart';
import '../../widgets/rpg/rpg_rarity_picker.dart';
import '../../widgets/rpg/rpg_navigation_shell.dart';
import '../../widgets/recipe_edit_instructions.dart';
import '../../../services/image_service.dart';
import '../../../services/auth_service.dart';
import '../../../providers/subscription_provider.dart';
import '../../widgets/app_snackbar.dart';

// ============ IMAGE PREVIEW/CONFIRM HELPER ============

/// Shows a full-screen preview of a picked image with crop support.
/// The user can pinch-to-zoom and pan to frame the photo.
/// Returns the cropped image path if accepted, or null if rejected.
Future<String?> showImagePreviewDialog(BuildContext context, String imagePath) async {
  return showDialog<String?>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ImageCropDialog(imagePath: imagePath),
  );
}

class _ImageCropDialog extends StatefulWidget {
  final String imagePath;
  const _ImageCropDialog({required this.imagePath});

  @override
  State<_ImageCropDialog> createState() => _ImageCropDialogState();
}

class _ImageCropDialogState extends State<_ImageCropDialog> {
  final _boundaryKey = GlobalKey();
  final _transformController = TransformationController();
  bool _isSaving = false;
  bool _hasZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformController.addListener(() {
      if (!_hasZoomed && _transformController.value != Matrix4.identity()) {
        setState(() => _hasZoomed = true);
      }
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  /// Capture the visible cropped region and save to a temp file.
  Future<String?> _captureAndCrop() async {
    if (!_hasZoomed) {
      // No zoom applied — return original image as-is
      return widget.imagePath;
    }

    setState(() => _isSaving = true);
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return widget.imagePath;

      // Capture at 3x pixel ratio for high-res output
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return widget.imagePath;

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      debugPrint('Crop capture failed: $e');
      return widget.imagePath; // Fallback to original
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.previewPhoto),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, null),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ClipRect(
              child: RepaintBoundary(
                key: _boundaryKey,
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _hasZoomed
                  ? 'Pinch to zoom · Cropped area will be saved'
                  : 'Pinch to zoom and crop · Or use as-is',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : () => Navigator.pop(context, null),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retake),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : () async {
                        final cropped = await _captureAndCrop();
                        if (mounted) Navigator.pop(context, cropped);
                      },
                      icon: _isSaving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check),
                      label: Text(_isSaving ? 'Saving...' : 'Use Photo'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _RecipeEditScreenState extends ConsumerState<RecipeEditScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servingsController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _sourceUrlController = TextEditingController();
  final _notesController = TextEditingController();

  String? _imagePath;
  String? _imageUrl;
  String? _defaultAssetPath; // For default recipes: asset image shown as preview only
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
  final List<EditableStep> _steps = [];
  Map<String, List<RecipeLinkInfo>> _ingredientLinksMap = {};
  bool _ingredientSortMode = false;

  // Tab controller for tabbed layout
  late TabController _tabController;

  bool get _isEditing => widget.recipeId != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRecipe();
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
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipe() async {
    if (widget.importedData != null) {
      _prefillFromImport(widget.importedData!);
      setState(() => _isLoading = false);
      return;
    }

    if (!_isEditing) {
      // Add one empty step for new recipes
      _steps.add(EditableStep(id: 'step_${DateTime.now().millisecondsSinceEpoch}', instruction: ''));
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
    // For default recipes with bundled asset images (no user-set imagePath)
    if (_imagePath == null) {
      _defaultAssetPath = defaultRecipeImageAsset(recipe.id);
    }
    _rating = recipe.rating ?? 0;
    _selectedCourseId = recipe.courseId;
    _selectedCategoryId = recipe.categoryId;
    _notesController.text = recipe.notes ?? '';

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
      // Detect section headers (stored with notes='__header__')
      if (ing.notes == '__header__') {
        _ingredients.add(_SimpleIngredient(id: ing.id, text: ing.name, isHeader: true));
        continue;
      }
      final parts = <String>[];
      if (ing.amount != null && ing.amount!.isNotEmpty) parts.add(ing.amount!);
      if (ing.unit != null && ing.unit!.isNotEmpty) parts.add(ing.unit!);
      parts.add(ing.name);
      if (ing.notes != null && ing.notes!.isNotEmpty) parts.add('(${ing.notes})');
      _ingredients.add(_SimpleIngredient(id: ing.id, text: parts.join(' ')));
    }

    // Load steps with images
    final steps = await recipeDao.getStepsForRecipe(widget.recipeId!);
    for (final step in steps) {
      _steps.add(EditableStep(
        id: step.id,
        instruction: step.instruction,
        imagePath: step.imagePath,
      ));
    }

    // Add empty step if none exist
    if (_steps.isEmpty) {
      _steps.add(EditableStep(id: 'step_${DateTime.now().millisecondsSinceEpoch}', instruction: ''));
    }

    // Load linked recipes (per-ingredient)
    final linksMap = await recipeDao.getIngredientLinksMap(widget.recipeId!);
    _ingredientLinksMap = linksMap;

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
      for (var i = 0; i < (data['instructions'] as List).length; i++) {
        final instruction = data['instructions'][i];
        _steps.add(EditableStep(
          id: 'step_${DateTime.now().millisecondsSinceEpoch}_$i',
          instruction: instruction.toString(),
        ));
      }
    } else if (data['instructions'] is String) {
      // Split by double newlines
      final instructionList = (data['instructions'] as String).split(RegExp(r'\n\n+'));
      for (var i = 0; i < instructionList.length; i++) {
        if (instructionList[i].trim().isNotEmpty) {
          _steps.add(EditableStep(
            id: 'step_${DateTime.now().millisecondsSinceEpoch}_$i',
            instruction: instructionList[i].trim(),
          ));
        }
      }
    }

    // Add empty step if none parsed
    if (_steps.isEmpty) {
      _steps.add(EditableStep(id: 'step_${DateTime.now().millisecondsSinceEpoch}', instruction: ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final isRpgMode = settings.nerdMode;
    final useTabbed = settings.recipeEditLayoutMode == RecipeEditLayoutMode.tabbed;

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
          // Layout toggle
          IconButton(
            icon: Icon(useTabbed ? Icons.view_agenda : Icons.tab),
            onPressed: () {
              final newMode = useTabbed ? RecipeEditLayoutMode.stacked : RecipeEditLayoutMode.tabbed;
              ref.read(settingsProvider.notifier).setRecipeEditLayout(newMode);
            },
            tooltip: useTabbed ? l10n.editLayoutStacked : l10n.editLayoutTabbed,
          ),
          FilledButton(
            onPressed: _isSaving ? null : _saveRecipe,
            child: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.actionSave),
          ),
          const SizedBox(width: 8),
        ],
        bottom: useTabbed ? TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.info_outline, size: 20), text: l10n.tabDetails),
            Tab(icon: const Icon(Icons.checklist, size: 20), text: l10n.ingredientsTitle),
            Tab(icon: const Icon(Icons.format_list_numbered, size: 20), text: l10n.instructionsTitle),
          ],
        ) : null,
      ),
      body: useTabbed
          ? _buildTabbedLayout(theme, l10n, isRpgMode, settings)
          : _buildStackedLayout(theme, l10n, isRpgMode, settings),
    );
  }

  Widget _buildStackedLayout(ThemeData theme, AppLocalizations l10n, bool isRpgMode, AppSettings settings) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PhotoPicker(imagePath: _imagePath, defaultAssetPath: _defaultAssetPath, onImageSelected: (path) => setState(() { _imagePath = path; if (path != null) _defaultAssetPath = null; })),
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
            if (_ingredientSortMode)
              Row(
                children: [
                  Text(l10n.ingredientsTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.check, size: 16),
                    label: Text(l10n.actionDone),
                    onPressed: _toggleSortMode,
                  ),
                ],
              )
            else
              _SectionTitleWithAdd(
                title: l10n.ingredientsTitle,
                onAddIngredient: _addIngredient,
                onAddHeader: _addHeader,
              ),
            const SizedBox(height: 12),
            _buildIngredientList(),
            if (!_ingredientSortMode)
              _AddIngredientButton(onTap: _addIngredient, onAddHeader: _addHeader),
            const SizedBox(height: 32),
            InstructionsEditor(
              steps: _steps,
              onStepsChanged: (steps) => setState(() {
                _steps.clear();
                _steps.addAll(steps);
              }),
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
    );
  }

  Widget _buildTabbedLayout(ThemeData theme, AppLocalizations l10n, bool isRpgMode, AppSettings settings) {
    return TabBarView(
      controller: _tabController,
      children: [
        // Tab 1: Details
        Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PhotoPicker(imagePath: _imagePath, defaultAssetPath: _defaultAssetPath, onImageSelected: (path) => setState(() { _imagePath = path; if (path != null) _defaultAssetPath = null; })),
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
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        // Tab 2: Ingredients
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_ingredientSortMode)
                Row(
                  children: [
                    Text(l10n.ingredientsTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.check, size: 16),
                      label: Text(l10n.actionDone),
                      onPressed: _toggleSortMode,
                    ),
                  ],
                )
              else
                _SectionTitleWithAdd(
                  title: l10n.ingredientsTitle,
                  onAddIngredient: _addIngredient,
                  onAddHeader: _addHeader,
                ),
              const SizedBox(height: 12),
              _buildIngredientList(),
              if (!_ingredientSortMode)
                _AddIngredientButton(onTap: _addIngredient, onAddHeader: _addHeader),
              const SizedBox(height: 100),
            ],
          ),
        ),
        // Tab 3: Instructions
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InstructionsEditor(
                steps: _steps,
                onStepsChanged: (steps) => setState(() {
                  _steps.clear();
                  _steps.addAll(steps);
                }),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  void _addIngredient() {
    setState(() => _ingredients.add(_SimpleIngredient(id: DateTime.now().millisecondsSinceEpoch.toString(), text: '')));
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  void _addHeader() {
    setState(() => _ingredients.add(_SimpleIngredient(id: 'hdr_${DateTime.now().millisecondsSinceEpoch}', text: '', isHeader: true)));
    // Don't scroll — headers are usually added between existing items
  }

  void _toggleSortMode() {
    setState(() => _ingredientSortMode = !_ingredientSortMode);
  }

  Widget _buildIngredientList() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_ingredientSortMode) {
      return ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _ingredients.length,
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) => Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surfaceContainerHigh,
              child: child,
            ),
            child: child,
          );
        },
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) newIndex -= 1;
            final item = _ingredients.removeAt(oldIndex);
            _ingredients.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final ing = _ingredients[index];
          return ListTile(
            key: ValueKey(ing.id),
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: ing.isHeader
                ? Icon(Icons.menu, size: 18, color: theme.colorScheme.primary)
                : Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
            ),
            title: Text(
              ing.text.isEmpty ? (ing.isHeader ? '(empty header)' : '(empty ingredient)') : ing.text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: ing.isHeader ? FontWeight.w700 : FontWeight.normal,
                color: ing.isHeader ? theme.colorScheme.primary : null,
                fontStyle: ing.text.isEmpty ? FontStyle.italic : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_handle, color: theme.colorScheme.outline),
            ),
          );
        },
      );
    }

    // Normal mode
    return Column(
      children: _ingredients.asMap().entries.map((entry) {
        if (entry.value.isHeader) {
          return _IngredientHeaderRow(
            key: ValueKey(entry.value.id),
            ingredient: entry.value,
            onChanged: (text) => setState(() => _ingredients[entry.key].text = text),
            onDelete: () => setState(() => _ingredients.removeAt(entry.key)),
            onSortMode: _toggleSortMode,
          );
        }
        return _IngredientRow(
          key: ValueKey(entry.value.id),
          ingredient: entry.value,
          onChanged: (text) => setState(() => _ingredients[entry.key].text = text),
          onDelete: () => setState(() => _ingredients.removeAt(entry.key)),
          onLinkRecipe: _isEditing ? () => _showLinkRecipePicker(entry.value.id, entry.value.text) : null,
          linkedRecipes: (_ingredientLinksMap[entry.value.id] ?? []).map((info) => info.recipe).toList(),
          onSortMode: _toggleSortMode,
        );
      }).toList(),
    );
  }

  Future<void> _calculateNutrition() async {
    final l10n = AppLocalizations.of(context)!;

    final activeIngredients = _ingredients.where((i) => i.text.trim().isNotEmpty && !i.isHeader).toList();

    if (activeIngredients.isEmpty) {
      AppSnackbar.info(context, l10n.ingredientsEmpty);
      return;
    }

    // Proceed directly - user can cancel via the save button if they don't want changes
    setState(() => _isCalculatingNutrition = true);

    try {
      final ingredients = activeIngredients.map((ing) {
        final parsed = _parseIngredient(ing.text.trim());
        return Ingredient(id: ing.id, recipeId: widget.recipeId ?? 'new', sortOrder: 0, name: parsed.name, amount: parsed.amount, unit: parsed.unit, notes: parsed.notes);
      }).toList();

      final result = await NutritionCalculationSheet.show(
          context: context,
          ingredients: ingredients,
          servings: _servingsController.text.isNotEmpty ? _servingsController.text : '1',
          existingNutrition: null,
          recipeId: widget.recipeId
      );

      if (result != null && mounted) {
        setState(() => _nutrition = result);
        AppSnackbar.info(context, l10n.nutritionCalculated);
      }
    } catch (e) {
      if (mounted) AppSnackbar.info(context, '${l10n.nutritionCalculationFailed}: $e');
    } finally {
      if (mounted) setState(() => _isCalculatingNutrition = false);
    }
  }

  // ============ LINKED RECIPE MANAGEMENT ============

  Future<void> _showLinkRecipePicker(String ingredientId, String ingredientName) async {
    if (widget.recipeId == null) return;
    final recipeDao = ref.read(recipeDaoProvider);
    final allRecipes = await recipeDao.getAllRecipes();
    final currentLinkInfos = _ingredientLinksMap[ingredientId] ?? [];
    final currentLinks = currentLinkInfos.map((info) => info.recipe).toList();
    final linkedIds = currentLinks.map((r) => r.id).toSet();
    final available = allRecipes
        .where((r) => r.id != widget.recipeId && !linkedIds.contains(r.id))
        .toList();

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _RecipeLinkScreen(
          available: available,
          currentlyLinked: currentLinks,
          ingredientName: ingredientName,
          onLink: (recipe) async {
            await _linkRecipeToIngredient(ingredientId, recipe);
          },
          onUnlink: (id) async {
            await _unlinkRecipeFromIngredient(ingredientId, id);
          },
        ),
      ),
    );

    // Refresh links when returning
    if (mounted && widget.recipeId != null) {
      final linksMap = await recipeDao.getIngredientLinksMap(widget.recipeId!);
      setState(() {
        _ingredientLinksMap = linksMap;
      });
    }
  }

  Future<void> _linkRecipeToIngredient(String ingredientId, Recipe recipe) async {
    if (widget.recipeId == null) return;
    final recipeDao = ref.read(recipeDaoProvider);
    try {
      await recipeDao.addIngredientRecipeLink(widget.recipeId!, ingredientId, recipe.id);
      final linksMap = await recipeDao.getIngredientLinksMap(widget.recipeId!);
      setState(() {
        _ingredientLinksMap = linksMap;
      });
    } catch (_) {}
  }

  Future<void> _unlinkRecipeFromIngredient(String ingredientId, String linkedId) async {
    if (widget.recipeId == null) return;
    final recipeDao = ref.read(recipeDaoProvider);
    await recipeDao.removeIngredientRecipeLink(widget.recipeId!, ingredientId, linkedId);
    final linksMap = await recipeDao.getIngredientLinksMap(widget.recipeId!);
    setState(() {
      _ingredientLinksMap = linksMap;
    });
  }

  Future<void> _saveRecipe() async {
    final l10n = AppLocalizations.of(context)!;
    if (_titleController.text.trim().isEmpty) {
      AppSnackbar.info(context, l10n.errorGeneric);
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

      // Upload to cloud if user has cloud sync and image is a local file
      if (finalImagePath != null &&
          !ImageService.isServerPath(finalImagePath) &&
          AuthService.instance.isSignedIn &&
          ref.read(subscriptionProvider).tier.hasCloudSync) {
        final uploadResult = await ImageService.instance.uploadFile(File(finalImagePath));
        if (uploadResult != null) {
          finalImagePath = uploadResult.path; // Store server path instead
        }
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

        // Save ingredients
        await recipeDao.deleteIngredientsForRecipe(widget.recipeId!);
        for (var i = 0; i < _ingredients.length; i++) {
          if (_ingredients[i].text.trim().isNotEmpty) {
            if (_ingredients[i].isHeader) {
              // Save header as ingredient with __header__ marker
              await recipeDao.insertIngredient(IngredientsCompanion.insert(id: '${widget.recipeId}_ing_$i', recipeId: widget.recipeId!, sortOrder: i, name: _ingredients[i].text.trim(), amount: const drift.Value(null), unit: const drift.Value(null), notes: const drift.Value('__header__')));
            } else {
              final parsed = _parseIngredient(_ingredients[i].text);
              await recipeDao.insertIngredient(IngredientsCompanion.insert(id: '${widget.recipeId}_ing_$i', recipeId: widget.recipeId!, sortOrder: i, name: parsed.name, amount: drift.Value(parsed.amount), unit: drift.Value(parsed.unit), notes: drift.Value(parsed.notes)));
            }
          }
        }

        // Save steps with images
        await recipeDao.deleteStepsForRecipe(widget.recipeId!);
        for (var i = 0; i < _steps.length; i++) {
          final step = _steps[i];
          if (step.instruction.trim().isNotEmpty) {
            // Copy step image to permanent location if it's a temp file
            String? stepImagePath = step.imagePath;
            if (stepImagePath != null && !stepImagePath.contains('images/steps')) {
              stepImagePath = await _copyStepImage(stepImagePath, widget.recipeId!, i);
            }
            await recipeDao.insertStep(StepsCompanion.insert(
              id: '${widget.recipeId}_step_$i',
              recipeId: widget.recipeId!,
              sortOrder: i,
              instruction: step.instruction.trim(),
              durationMinutes: const drift.Value(null),
              imagePath: drift.Value(stepImagePath),
            ));
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

        // Save ingredients
        for (var i = 0; i < _ingredients.length; i++) {
          if (_ingredients[i].text.trim().isNotEmpty) {
            if (_ingredients[i].isHeader) {
              await recipeDao.insertIngredient(IngredientsCompanion.insert(id: '${recipeId}_ing_$i', recipeId: recipeId, sortOrder: i, name: _ingredients[i].text.trim(), amount: const drift.Value(null), unit: const drift.Value(null), notes: const drift.Value('__header__')));
            } else {
              final parsed = _parseIngredient(_ingredients[i].text);
              await recipeDao.insertIngredient(IngredientsCompanion.insert(id: '${recipeId}_ing_$i', recipeId: recipeId, sortOrder: i, name: parsed.name, amount: drift.Value(parsed.amount), unit: drift.Value(parsed.unit), notes: drift.Value(parsed.notes)));
            }
          }
        }

        // Save steps with images
        for (var i = 0; i < _steps.length; i++) {
          final step = _steps[i];
          if (step.instruction.trim().isNotEmpty) {
            // Copy step image to permanent location
            String? stepImagePath = step.imagePath;
            if (stepImagePath != null) {
              stepImagePath = await _copyStepImage(stepImagePath, recipeId, i);
            }
            await recipeDao.insertStep(StepsCompanion.insert(
              id: '${recipeId}_step_$i',
              recipeId: recipeId,
              sortOrder: i,
              instruction: step.instruction.trim(),
              durationMinutes: const drift.Value(null),
              imagePath: drift.Value(stepImagePath),
            ));
          }
        }
      }

      await tagsDao.setTagsForRecipe(recipeId, _selectedTagIds);

      if (mounted) {
        AppSnackbar.info(context, _isEditing ? 'Recipe updated!' : l10n.successSaved);

        // RPG XP - only for new recipes
        if (!_isEditing) {
          final isImported = widget.importedData != null;
          if (isImported) {
            RpgIntegration.onRecipeImported(ref);
          } else {
            RpgIntegration.onRecipeCreated(
              ref,
              stepCount: _steps.where((s) => s.instruction.trim().isNotEmpty).length,
              ingredientCount: _ingredients.where((i) => i.text.trim().isNotEmpty).length,
            );
          }
          if (finalImagePath != null) {
            RpgIntegration.onPhotoAdded(ref);
          }
          if (_nutrition != null && !_nutrition!.isEmpty) {
            RpgIntegration.onNutritionAdded(ref);
          }
        }

        context.pop(true);
      }
    } catch (e) {
      if (mounted) AppSnackbar.info(context, '${l10n.errorSavingRecipe}: $e');
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

  Future<String?> _copyStepImage(String sourcePath, String recipeId, int stepIndex) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final ext = p.extension(sourcePath);
      final filename = 'step_${recipeId}_$stepIndex$ext';
      final destPath = p.join(dir.path, 'images', 'steps', filename);
      final destFile = File(destPath);
      await destFile.parent.create(recursive: true);
      await File(sourcePath).copy(destPath);
      return destPath;
    } catch (e) {
      return sourcePath; // Return original path if copy fails
    }
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

// ============ DATA MODELS ============

class _SimpleIngredient {
  final String id;
  String text;
  bool isHeader; // Section header/divider (not a real ingredient)
  _SimpleIngredient({required this.id, this.text = '', this.isHeader = false});
}

class _ParsedIngredient {
  final String? amount;
  final String? unit;
  final String name;
  final String? notes;
  _ParsedIngredient({this.amount, this.unit, required this.name, this.notes});
}

// ============ HELPER WIDGETS ============

class ImprovedNutritionSection extends StatefulWidget {
  final NutritionData? nutrition;
  final int servingsCount;
  final bool isCalculating;
  final VoidCallback onCalculate;
  final VoidCallback onClear;
  final bool showExpandedByDefault;

  const ImprovedNutritionSection({
    super.key,
    required this.nutrition,
    required this.servingsCount,
    required this.isCalculating,
    required this.onCalculate,
    required this.onClear,
    this.showExpandedByDefault = false,
  });

  @override
  State<ImprovedNutritionSection> createState() => _ImprovedNutritionSectionState();
}

class _ImprovedNutritionSectionState extends State<ImprovedNutritionSection> {
  bool _showPerServing = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.showExpandedByDefault;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (widget.nutrition == null || widget.nutrition!.isEmpty) {
      return _CalculateNutritionCard(
        isCalculating: widget.isCalculating,
        onCalculate: widget.onCalculate,
      );
    }

    final nutrition = widget.nutrition!;
    final servings = widget.servingsCount > 0 ? widget.servingsCount : 1;

    // Calculate display values based on toggle
    final displayCalories = _showPerServing
        ? nutrition.calories
        : (nutrition.calories ?? 0) * servings;
    final displayProtein = _showPerServing
        ? nutrition.protein
        : (nutrition.protein ?? 0) * servings;
    final displayCarbs = _showPerServing
        ? nutrition.carbohydrates
        : (nutrition.carbohydrates ?? 0) * servings;
    final displayFat = _showPerServing
        ? nutrition.fat
        : (nutrition.fat ?? 0) * servings;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with all 3 values summary
          _NutritionSummaryHeader(
            servingsCount: servings,
            totalCalories: (nutrition.calories ?? 0) * servings,
            caloriesPerServing: nutrition.calories ?? 0,
            theme: theme,
          ),

          const SizedBox(height: 12),

          // Toggle: Per Serving / Total
          _ViewToggle(
            showPerServing: _showPerServing,
            onChanged: (value) => setState(() => _showPerServing = value),
            theme: theme,
            l10n: l10n,
          ),

          const SizedBox(height: 16),

          // Macro donut chart
          _MacroDonutChart(
            calories: displayCalories ?? 0,
            protein: displayProtein ?? 0,
            carbs: displayCarbs ?? 0,
            fat: displayFat ?? 0,
            theme: theme,
          ),

          const SizedBox(height: 16),

          // Macro chips row
          Row(
            children: [
              Expanded(child: _MacroChip(
                label: l10n.nutritionProtein,
                value: displayProtein,
                unit: 'g',
                color: const Color(0xFF4CAF50),
                theme: theme,
              )),
              const SizedBox(width: 8),
              Expanded(child: _MacroChip(
                label: l10n.nutritionCarbs,
                value: displayCarbs,
                unit: 'g',
                color: const Color(0xFF2196F3),
                theme: theme,
              )),
              const SizedBox(width: 8),
              Expanded(child: _MacroChip(
                label: l10n.nutritionFat,
                value: displayFat,
                unit: 'g',
                color: const Color(0xFFFF9800),
                theme: theme,
              )),
            ],
          ),

          // Expanded nutrition info (optional)
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _ExpandedNutritionInfo(
              nutrition: nutrition,
              multiplier: _showPerServing ? 1.0 : servings.toDouble(),
              theme: theme,
              l10n: l10n,
            ),
          ],

          const SizedBox(height: 16),

          // Action buttons row
          Row(
            children: [
              // Expand/collapse button
              TextButton.icon(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                ),
                label: Text(_isExpanded ? 'Less info' : 'More info'),
              ),
              const Spacer(),
              // Recalculate button (no confirmation needed)
              OutlinedButton.icon(
                onPressed: widget.isCalculating ? null : widget.onCalculate,
                icon: widget.isCalculating
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(l10n.nutritionRecalculate),
              ),
              const SizedBox(width: 8),
              // Clear button
              IconButton(
                onPressed: widget.onClear,
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.actionDelete,
                style: IconButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ SUMMARY HEADER ============

class _NutritionSummaryHeader extends StatelessWidget {
  final int servingsCount;
  final double totalCalories;
  final double caloriesPerServing;
  final ThemeData theme;

  const _NutritionSummaryHeader({
    required this.servingsCount,
    required this.totalCalories,
    required this.caloriesPerServing,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            value: servingsCount.toString(),
            label: 'Servings',
            icon: Icons.restaurant,
            theme: theme,
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          _SummaryItem(
            value: '${totalCalories.round()}',
            label: 'Total cal',
            icon: Icons.local_fire_department,
            theme: theme,
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          _SummaryItem(
            value: '${caloriesPerServing.round()}',
            label: 'Cal/serving',
            icon: Icons.person,
            theme: theme,
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final ThemeData theme;
  final bool isPrimary;

  const _SummaryItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.theme,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isPrimary ? theme.colorScheme.primary : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

// ============ VIEW TOGGLE ============

class _ViewToggle extends StatelessWidget {
  final bool showPerServing;
  final ValueChanged<bool> onChanged;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _ViewToggle({
    required this.showPerServing,
    required this.onChanged,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: l10n.nutritionPerServing,
              isSelected: showPerServing,
              onTap: () => onChanged(true),
              theme: theme,
            ),
          ),
          Expanded(
            child: _ToggleOption(
              label: 'Total',
              isSelected: !showPerServing,
              onTap: () => onChanged(false),
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ============ MACRO DONUT CHART ============

class _MacroDonutChart extends StatelessWidget {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final ThemeData theme;

  const _MacroDonutChart({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentages (protein=4cal/g, carbs=4cal/g, fat=9cal/g)
    final proteinCal = protein * 4;
    final carbsCal = carbs * 4;
    final fatCal = fat * 9;
    final total = proteinCal + carbsCal + fatCal;

    if (total == 0) {
      return const SizedBox(height: 80);
    }

    final proteinPct = proteinCal / total;
    final carbsPct = carbsCal / total;
    final fatPct = fatCal / total;

    return SizedBox(
      height: 100,
      child: Row(
        children: [
          // Donut chart
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _DonutPainter(
                proteinPct: proteinPct,
                carbsPct: carbsPct,
                fatPct: fatPct,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${calories.round()}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'cal',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Legend
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendItem(
                  color: const Color(0xFF4CAF50),
                  label: 'Protein',
                  percentage: (proteinPct * 100).round(),
                  theme: theme,
                ),
                const SizedBox(height: 8),
                _LegendItem(
                  color: const Color(0xFF2196F3),
                  label: 'Carbs',
                  percentage: (carbsPct * 100).round(),
                  theme: theme,
                ),
                const SizedBox(height: 8),
                _LegendItem(
                  color: const Color(0xFFFF9800),
                  label: 'Fat',
                  percentage: (fatPct * 100).round(),
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double proteinPct;
  final double carbsPct;
  final double fatPct;

  _DonutPainter({
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 12.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background
    paint.color = Colors.grey.withValues(alpha: 0.2);
    canvas.drawCircle(center, radius - strokeWidth / 2, paint);

    // Draw segments
    var startAngle = -math.pi / 2; // Start from top

    // Protein (green)
    if (proteinPct > 0) {
      paint.color = const Color(0xFF4CAF50);
      final sweepAngle = 2 * math.pi * proteinPct;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Carbs (blue)
    if (carbsPct > 0) {
      paint.color = const Color(0xFF2196F3);
      final sweepAngle = 2 * math.pi * carbsPct;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Fat (orange)
    if (fatPct > 0) {
      paint.color = const Color(0xFFFF9800);
      final sweepAngle = 2 * math.pi * fatPct;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int percentage;
  final ThemeData theme;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.percentage,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: theme.textTheme.bodySmall),
        const Spacer(),
        Text(
          '$percentage%',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ============ MACRO CHIP ============

class _MacroChip extends StatelessWidget {
  final String label;
  final double? value;
  final String unit;
  final Color color;
  final ThemeData theme;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value == null
        ? '-'
        : value! < 1
        ? value!.toStringAsFixed(1)
        : value!.round().toString();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$displayValue$unit',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ EXPANDED NUTRITION INFO ============

class _ExpandedNutritionInfo extends StatelessWidget {
  final NutritionData nutrition;
  final double multiplier;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _ExpandedNutritionInfo({
    required this.nutrition,
    required this.multiplier,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Nutrition',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _NutritionRow(label: l10n.nutritionSaturatedFat, value: nutrition.saturatedFat, unit: 'g', multiplier: multiplier, theme: theme),
        _NutritionRow(label: l10n.nutritionFiber, value: nutrition.fiber, unit: 'g', multiplier: multiplier, theme: theme),
        _NutritionRow(label: l10n.nutritionSugar, value: nutrition.sugar, unit: 'g', multiplier: multiplier, theme: theme),
        _NutritionRow(label: l10n.nutritionSodium, value: nutrition.sodium, unit: 'mg', multiplier: multiplier, theme: theme),
        _NutritionRow(label: l10n.nutritionCholesterol, value: nutrition.cholesterol, unit: 'mg', multiplier: multiplier, theme: theme),
      ],
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final double? value;
  final String unit;
  final double multiplier;
  final ThemeData theme;

  const _NutritionRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.multiplier,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value == null
        ? '-'
        : ((value! * multiplier) < 1
        ? (value! * multiplier).toStringAsFixed(1)
        : (value! * multiplier).round().toString());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value == null ? '-' : '$displayValue$unit',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ CALCULATE NUTRITION CARD ============

class _CalculateNutritionCard extends StatelessWidget {
  final bool isCalculating;
  final VoidCallback onCalculate;

  const _CalculateNutritionCard({
    required this.isCalculating,
    required this.onCalculate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: isCalculating ? null : onCalculate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isCalculating
                  ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              )
                  : Icon(
                Icons.calculate_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.nutritionCalculate,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.nutritionMatchingIngredients,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final String? imagePath;
  final String? defaultAssetPath;
  final ValueChanged<String?> onImageSelected;
  const _PhotoPicker({required this.imagePath, this.defaultAssetPath, required this.onImageSelected});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasImage = imagePath != null;
    final hasAsset = defaultAssetPath != null;
    final showImage = hasImage || hasAsset;

    // Build the appropriate DecorationImage
    DecorationImage? decorationImage;
    if (hasImage) {
      if (ImageService.isServerPath(imagePath!)) {
        // Server-hosted image — we'll show it via a FutureBuilder below
        decorationImage = null; // handled separately
      } else {
        decorationImage = DecorationImage(image: FileImage(File(imagePath!)), fit: BoxFit.cover);
      }
    } else if (hasAsset) {
      decorationImage = DecorationImage(image: AssetImage(defaultAssetPath!), fit: BoxFit.cover);
    }

    return GestureDetector(
      onTap: () => _showImageOptions(context),
      child: Container(
        height: 200, width: double.infinity,
        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outlineVariant, width: 1), image: decorationImage),
        child: !showImage
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.add_photo_alternate_outlined, size: 32, color: theme.colorScheme.primary)),
          const SizedBox(height: 12),
          Text(l10n.addPhoto, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 4),
          Text(l10n.tapToSelectPhoto, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        ])
            : Stack(children: [
          // Show "Default" badge for asset images
          if (hasAsset && !hasImage)
            Positioned(top: 8, left: 8, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
              child: Text(l10n.defaultLabel, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            )),
          Positioned(top: 8, right: 8, child: Row(children: [_ImageActionButton(icon: Icons.edit, onTap: () => _showImageOptions(context)), const SizedBox(width: 8), _ImageActionButton(icon: Icons.close, onTap: () => onImageSelected(null))])),
        ]),
      ),
    );
  }
  void _showImageOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.photo_library), title: Text(l10n.chooseFromGallery), onTap: () { Navigator.pop(ctx); _pickImageWithPreview(context, ImageSource.gallery); }),
      ListTile(leading: const Icon(Icons.camera_alt), title: Text(l10n.takePhoto), onTap: () { Navigator.pop(ctx); _pickImageWithPreview(context, ImageSource.camera); }),
    ])));
  }
  Future<void> _pickImageWithPreview(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 1200, maxHeight: 1200, imageQuality: 85);
    if (image != null && context.mounted) {
      final confirmed = await showImagePreviewDialog(context, image.path);
      if (confirmed != null) onImageSelected(confirmed);
    }
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
    final l10n = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.rating, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
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

class _SectionTitleWithAdd extends StatelessWidget {
  final String title;
  final VoidCallback onAddIngredient;
  final VoidCallback onAddHeader;

  const _SectionTitleWithAdd({
    required this.title,
    required this.onAddIngredient,
    required this.onAddHeader,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const Spacer(),
        PopupMenuButton<String>(
          icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary, size: 22),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: l10n.addIngredient,
          onSelected: (value) {
            if (value == 'ingredient') onAddIngredient();
            if (value == 'header') onAddHeader();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'ingredient',
              child: Row(children: [
                Icon(Icons.add, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(l10n.addIngredient),
              ]),
            ),
            PopupMenuItem(
              value: 'header',
              child: Row(children: [
                Icon(Icons.menu, size: 18, color: theme.colorScheme.outline),
                const SizedBox(width: 10),
                Text(l10n.ingredientAddHeader),
              ]),
            ),
          ],
        ),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final _SimpleIngredient ingredient;
  final ValueChanged<String> onChanged;
  final VoidCallback onDelete;
  final VoidCallback? onLinkRecipe;
  final VoidCallback? onSortMode;
  final List<Recipe> linkedRecipes;

  const _IngredientRow({
    super.key,
    required this.ingredient,
    required this.onChanged,
    required this.onDelete,
    this.onLinkRecipe,
    this.onSortMode,
    this.linkedRecipes = const [],
  });

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(initialValue: ingredient.text, decoration: const InputDecoration(hintText: 'e.g., 2 cups flour', isDense: true, border: OutlineInputBorder()), textCapitalization: TextCapitalization.sentences, onChanged: onChanged)),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 20, color: theme.colorScheme.outline),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              switch (value) {
                case 'delete': onDelete(); break;
                case 'link_recipe': onLinkRecipe?.call(); break;
                case 'sort_order': onSortMode?.call(); break;
              }
            },
            itemBuilder: (context) => [
              if (onLinkRecipe != null)
                PopupMenuItem(
                  value: 'link_recipe',
                  child: Row(children: [
                    Icon(Icons.link, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(l10n.linkRecipe),
                  ]),
                ),
              PopupMenuItem(
                value: 'sort_order',
                child: Row(children: [
                  Icon(Icons.swap_vert, size: 18, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 8),
                  Text(l10n.sortOrder),
                ]),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Text(l10n.actionDelete),
                ]),
              ),
            ],
          ),
        ]),
        // Show linked recipes inline
        ...linkedRecipes.map((recipe) => Padding(
          padding: const EdgeInsets.only(left: 20, top: 4),
          child: Row(
            children: [
              Icon(Icons.subdirectory_arrow_right, size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              // Recipe image thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildRecipeThumb(recipe, 20),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  recipe.title,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            ],
          ),
        )),
      ],
    ));
  }

  Widget _buildRecipeThumb(Recipe recipe, double size) {
    final hasImage = recipe.imagePath != null && File(recipe.imagePath!).existsSync();
    final defaultAsset = defaultRecipeImageAsset(recipe.id);
    if (hasImage) {
      return Image.file(File(recipe.imagePath!), width: size, height: size, fit: BoxFit.cover);
    } else if (defaultAsset != null) {
      return Image.asset(defaultAsset, width: size, height: size, fit: BoxFit.cover);
    }
    return SizedBox(width: size, height: size);
  }
}

class _AddIngredientButton extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onAddHeader;
  const _AddIngredientButton({required this.onTap, this.onAddHeader});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(onTap: onTap, child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.outlineVariant), borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add, color: theme.colorScheme.primary, size: 20), const SizedBox(width: 8), Text(l10n.addIngredient, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary))]),
          )),
        ),
        if (onAddHeader != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onAddHeader,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu, color: theme.colorScheme.outline, size: 18),
                    const SizedBox(width: 6),
                    Text(l10n.ingredientAddHeader, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _IngredientHeaderRow extends StatelessWidget {
  final _SimpleIngredient ingredient;
  final ValueChanged<String> onChanged;
  final VoidCallback onDelete;
  final VoidCallback? onSortMode;

  const _IngredientHeaderRow({
    super.key,
    required this.ingredient,
    required this.onChanged,
    required this.onDelete,
    this.onSortMode,
  });

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(padding: const EdgeInsets.only(bottom: 8, top: 8), child: Row(children: [
      Icon(Icons.menu, size: 18, color: theme.colorScheme.primary),
      const SizedBox(width: 10),
      Expanded(child: TextFormField(
        initialValue: ingredient.text,
        decoration: InputDecoration(
          hintText: l10n.ingredientHeaderHint,
          isDense: true,
          border: InputBorder.none,
          hintStyle: TextStyle(color: theme.colorScheme.outline),
        ),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: theme.colorScheme.primary,
          letterSpacing: 0.3,
        ),
        textCapitalization: TextCapitalization.sentences,
        onChanged: onChanged,
      )),
      PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, size: 20, color: theme.colorScheme.outline),
        padding: EdgeInsets.zero,
        onSelected: (value) {
          switch (value) {
            case 'sort_order': onSortMode?.call(); break;
            case 'delete': onDelete(); break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'sort_order',
            child: Row(children: [
              Icon(Icons.swap_vert, size: 18, color: theme.colorScheme.onSurface),
              const SizedBox(width: 8),
              Text(l10n.sortOrder),
            ]),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(children: [
              Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Text(l10n.actionDelete),
            ]),
          ),
        ],
      ),
    ]));
  }
}

class _NutritionSection extends StatelessWidget {
  final NutritionData? nutrition;
  final bool isCalculating;
  final VoidCallback onCalculate;
  final VoidCallback onClear;

  const _NutritionSection({
    required this.nutrition,
    required this.isCalculating,
    required this.onCalculate,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (nutrition == null) {
      return _CalculateNutritionCard(
        isCalculating: isCalculating,
        onCalculate: onCalculate,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with calories
          Row(
            children: [
              Icon(Icons.local_fire_department, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '${nutrition!.calories?.toInt() ?? 0} cal',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: isCalculating ? null : onCalculate,
                tooltip: 'Recalculate',
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClear,
                tooltip: 'Clear',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Macros row
          Row(
            children: [
              Expanded(child: _MacroChip(label: 'Protein', value: nutrition!.protein, unit: 'g', color: const Color(0xFF4CAF50), theme: theme)),
              const SizedBox(width: 8),
              Expanded(child: _MacroChip(label: 'Carbs', value: nutrition!.carbohydrates, unit: 'g', color: const Color(0xFF2196F3), theme: theme)),
              const SizedBox(width: 8),
              Expanded(child: _MacroChip(label: 'Fat', value: nutrition!.fat, unit: 'g', color: const Color(0xFFFF9800), theme: theme)),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ FULL-SCREEN RECIPE LINK PICKER ============

class _RecipeLinkScreen extends StatefulWidget {
  final List<Recipe> available;
  final List<Recipe> currentlyLinked;
  final String ingredientName;
  final Future<void> Function(Recipe) onLink;
  final Future<void> Function(String) onUnlink;

  const _RecipeLinkScreen({
    required this.available,
    required this.currentlyLinked,
    required this.ingredientName,
    required this.onLink,
    required this.onUnlink,
  });

  @override
  State<_RecipeLinkScreen> createState() => _RecipeLinkScreenState();
}

class _RecipeLinkScreenState extends State<_RecipeLinkScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  late List<Recipe> _linked;
  late List<Recipe> _available;

  @override
  void initState() {
    super.initState();
    _linked = List.from(widget.currentlyLinked);
    _available = List.from(widget.available);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Recipe> get _filteredAvailable {
    if (_search.isEmpty) return _available;
    final q = _search.toLowerCase();
    return _available.where((r) => r.title.toLowerCase().contains(q)).toList();
  }

  Future<void> _handleLink(Recipe recipe) async {
    await widget.onLink(recipe);
    setState(() {
      _linked.add(recipe);
      _available.removeWhere((r) => r.id == recipe.id);
    });
  }

  Future<void> _handleUnlink(Recipe recipe) async {
    await widget.onUnlink(recipe.id);
    setState(() {
      _linked.removeWhere((r) => r.id == recipe.id);
      _available.add(recipe);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final filtered = _filteredAvailable;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.linkToIngredient(widget.ingredientName)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Currently linked section
          if (_linked.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.link, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Currently Linked (${_linked.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _linked.length,
                itemBuilder: (_, i) {
                  final recipe = _linked[i];
                  return _LinkedRecipeCard(
                    recipe: recipe,
                    onUnlink: () => _handleUnlink(recipe),
                  );
                },
              ),
            ),
            const Divider(height: 24),
          ],

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search recipes to link...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _search = '');
                  },
                )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Available count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Available (${filtered.length})',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Available recipes list
          Expanded(
            child: filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 48, color: theme.colorScheme.outline),
                  const SizedBox(height: 12),
                  Text(
                    _search.isNotEmpty
                        ? 'No recipes match "$_search"'
                        : 'No recipes available to link',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final recipe = filtered[i];
                return _AvailableRecipeCard(
                  recipe: recipe,
                  onLink: () => _handleLink(recipe),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onUnlink;

  const _LinkedRecipeCard({required this.recipe, required this.onUnlink});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = recipe.imagePath != null &&
        recipe.imagePath!.isNotEmpty &&
        File(recipe.imagePath!).existsSync();
    final defaultAsset = defaultRecipeImageAsset(recipe.id);

    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: hasImage
                    ? Image.file(File(recipe.imagePath!), fit: BoxFit.cover)
                    : defaultAsset != null
                    ? Image.asset(defaultAsset, fit: BoxFit.cover)
                    : Container(
                  color: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.restaurant_menu,
                    color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  recipe.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onUnlink,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 14, color: theme.colorScheme.onError),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onLink;

  const _AvailableRecipeCard({required this.recipe, required this.onLink});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = recipe.imagePath != null &&
        recipe.imagePath!.isNotEmpty &&
        File(recipe.imagePath!).existsSync();
    final defaultAsset = defaultRecipeImageAsset(recipe.id);
    final totalTime = (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onLink,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasImage
                    ? Image.file(File(recipe.imagePath!), fit: BoxFit.cover)
                    : defaultAsset != null
                    ? Image.asset(defaultAsset, fit: BoxFit.cover)
                    : Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 24,
                    color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (recipe.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        recipe.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (totalTime > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 12, color: theme.colorScheme.outline),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(totalTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_link,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours hr';
    return '$hours hr $mins min';
  }
}