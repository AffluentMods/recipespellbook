import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';

/// Step data model for editing
class EditableStep {
  String id;
  String instruction;
  String? imagePath;

  EditableStep({
    required this.id,
    required this.instruction,
    this.imagePath,
  });
}

/// Simplified instructions editor with drag-to-reorder
/// No timer per step, cleaner UI
class InstructionsEditor extends ConsumerStatefulWidget {
  final List<EditableStep> steps;
  final ValueChanged<List<EditableStep>> onStepsChanged;
  final bool isPremium; // For step images feature

  const InstructionsEditor({
    super.key,
    required this.steps,
    required this.onStepsChanged,
    this.isPremium = false,
  });

  @override
  ConsumerState<InstructionsEditor> createState() => _InstructionsEditorState();
}

class _InstructionsEditorState extends ConsumerState<InstructionsEditor> {
  late List<EditableStep> _steps;
  final _focusNodes = <String, FocusNode>{};

  @override
  void initState() {
    super.initState();
    _steps = List.from(widget.steps);
  }

  @override
  void didUpdateWidget(InstructionsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.steps != oldWidget.steps) {
      _steps = List.from(widget.steps);
    }
  }

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  FocusNode _getFocusNode(String id) {
    return _focusNodes.putIfAbsent(id, () => FocusNode());
  }

  void _addStep() {
    final newStep = EditableStep(
      id: 'step_${DateTime.now().millisecondsSinceEpoch}',
      instruction: '',
    );
    setState(() {
      _steps.add(newStep);
    });
    widget.onStepsChanged(_steps);

    // Focus the new step after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getFocusNode(newStep.id).requestFocus();
    });
  }

  void _removeStep(int index) {
    final removedId = _steps[index].id;
    setState(() {
      _steps.removeAt(index);
    });
    widget.onStepsChanged(_steps);
    _focusNodes.remove(removedId)?.dispose();
  }

  void _updateStep(int index, String text) {
    _steps[index].instruction = text;
    widget.onStepsChanged(_steps);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _steps.removeAt(oldIndex);
      _steps.insert(newIndex, item);
    });
    widget.onStepsChanged(_steps);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              l10n.instructionsTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${_steps.length} ${_steps.length == 1 ? 'step' : 'steps'}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Steps list with drag-to-reorder
        if (_steps.isEmpty)
          _EmptyStepsState(onAdd: _addStep)
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: _steps.length,
            onReorder: _onReorder,
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) => Material(
                  elevation: animation.value * 4,
                  borderRadius: BorderRadius.circular(12),
                  child: child,
                ),
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final step = _steps[index];
              return _StepCard(
                key: ValueKey(step.id),
                index: index,
                step: step,
                focusNode: _getFocusNode(step.id),
                isPremium: widget.isPremium,
                onTextChanged: (text) => _updateStep(index, text),
                onImageChanged: (path) {
                  setState(() {
                    _steps[index].imagePath = path;
                  });
                  widget.onStepsChanged(_steps);
                },
                onDelete: () => _removeStep(index),
                isLast: index == _steps.length - 1,
              );
            },
          ),

        const SizedBox(height: 12),

        // Add step button
        Center(
          child: OutlinedButton.icon(
            onPressed: _addStep,
            icon: const Icon(Icons.add),
            label: Text(l10n.addStep),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// ============ STEP CARD ============

class _StepCard extends StatelessWidget {
  final int index;
  final EditableStep step;
  final FocusNode focusNode;
  final bool isPremium;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String?> onImageChanged;
  final VoidCallback onDelete;
  final bool isLast;

  const _StepCard({
    super.key,
    required this.index,
    required this.step,
    required this.focusNode,
    required this.isPremium,
    required this.onTextChanged,
    required this.onImageChanged,
    required this.onDelete,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            // Header with step number, drag handle, delete
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFF5F0E8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Row(
                children: [
                  // Drag handle
                  ReorderableDragStartListener(
                    index: index,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.drag_indicator, color: theme.colorScheme.outline, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Step number badge
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8A860),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Text(
                    'Step ${index + 1}',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),

                  const Spacer(),

                  // Delete button
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: theme.colorScheme.error),
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Remove step',
                  ),
                ],
              ),
            ),

            // Instruction text field
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                focusNode: focusNode,
                controller: TextEditingController(text: step.instruction)
                  ..selection = TextSelection.collapsed(offset: step.instruction.length),
                maxLines: null,
                minLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter instruction...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: const Color(0xFFE8A860)),
                  ),
                  filled: true,
                  fillColor: isDark ? theme.colorScheme.surface : Colors.grey.shade50,
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: onTextChanged,
              ),
            ),

            // Step image (premium feature)
            if (isPremium) ...[
              if (step.imagePath != null && File(step.imagePath!).existsSync())
                _StepImagePreview(
                  imagePath: step.imagePath!,
                  onRemove: () => onImageChanged(null),
                )
              else
                _AddStepImageButton(onImageSelected: onImageChanged),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

// ============ STEP IMAGE PREVIEW ============

class _StepImagePreview extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;

  const _StepImagePreview({required this.imagePath, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(imagePath),
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ ADD STEP IMAGE BUTTON ============

class _AddStepImageButton extends StatelessWidget {
  final ValueChanged<String?> onImageSelected;

  const _AddStepImageButton({required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: InkWell(
        onTap: () => _pickImage(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 20, color: theme.colorScheme.outline),
              const SizedBox(width: 8),
              Text(
                'Add step image',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImage(BuildContext context) async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) onImageSelected(image.path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) onImageSelected(image.path);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============ EMPTY STATE ============

class _EmptyStepsState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyStepsState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.format_list_numbered, size: 48, color: theme.colorScheme.outline.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            'No instructions yet',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Add steps to guide through the recipe',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add first step'),
          ),
        ],
      ),
    );
  }
}

// ============ SIMPLE INGREDIENTS EDITOR ============

/// Simplified ingredients editor - each ingredient on its own line
/// Type an ingredient, press Enter, move to next line
class IngredientsEditor extends StatefulWidget {
  final List<String> ingredients;
  final ValueChanged<List<String>> onIngredientsChanged;

  const IngredientsEditor({
    super.key,
    required this.ingredients,
    required this.onIngredientsChanged,
  });

  @override
  State<IngredientsEditor> createState() => _IngredientsEditorState();
}

class _IngredientsEditorState extends State<IngredientsEditor> {
  late TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.ingredients.join('\n'));
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final lines = _controller.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    widget.onIngredientsChanged(lines);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    // Count non-empty lines
    final count = _controller.text
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.ingredientsTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '$count ${count == 1 ? 'ingredient' : 'ingredients'}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: null,
            minLines: 5,
            decoration: InputDecoration(
              hintText: 'Enter one ingredient per line:\n\n2 cups flour\n1 tsp salt\n3 eggs',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline.withOpacity(0.5),
              ),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tip: Enter one ingredient per line. Press Enter after each ingredient.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }
}