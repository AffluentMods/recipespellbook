import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../l10n/app_localizations.dart';

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

/// Simplified instructions editor with:
/// - Drag handle on RIGHT side
/// - Long-press to select (multi-select support)
/// - No visible delete button
/// - Confirm dialog before deleting
class InstructionsEditor extends ConsumerStatefulWidget {
  final List<EditableStep> steps;
  final ValueChanged<List<EditableStep>> onStepsChanged;
  final bool isPremium;

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
  final Set<String> _selectedStepIds = {};
  bool _isSelectionMode = false;

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
      // Clear selection if steps changed externally
      _selectedStepIds.clear();
      _isSelectionMode = false;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getFocusNode(newStep.id).requestFocus();
    });
  }

  void _removeSteps(List<String> stepIds) async {
    if (stepIds.isEmpty) return;

    final count = stepIds.length;
    final l10n = AppLocalizations.of(context)!;

    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(count == 1 ? 'Delete Step?' : 'Delete $count Steps?'),
        content: Text(
          count == 1
              ? 'This step will be permanently removed.'
              : 'These $count steps will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _steps.removeWhere((s) => stepIds.contains(s.id));
        for (final id in stepIds) {
          _focusNodes.remove(id)?.dispose();
          _selectedStepIds.remove(id);
        }
        _isSelectionMode = _selectedStepIds.isNotEmpty;
      });
      widget.onStepsChanged(_steps);
    }
  }

  void _updateStep(int index, String text) {
    _steps[index].instruction = text;
    widget.onStepsChanged(_steps);
  }

  void _onReorder(int oldIndex, int newIndex) {
    // Can't reorder while in selection mode
    if (_isSelectionMode) return;

    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _steps.removeAt(oldIndex);
      _steps.insert(newIndex, item);
    });
    widget.onStepsChanged(_steps);
    HapticFeedback.mediumImpact();
  }

  void _toggleSelection(String stepId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedStepIds.contains(stepId)) {
        _selectedStepIds.remove(stepId);
        if (_selectedStepIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedStepIds.add(stepId);
        _isSelectionMode = true;
      }
    });
  }

  void _onLongPress(String stepId) {
    if (!_isSelectionMode) {
      HapticFeedback.mediumImpact();
      setState(() {
        _selectedStepIds.add(stepId);
        _isSelectionMode = true;
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedStepIds.clear();
      _isSelectionMode = false;
    });
  }

  void _selectAll() {
    setState(() {
      _selectedStepIds.addAll(_steps.map((s) => s.id));
      _isSelectionMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with selection controls
        _buildHeader(theme, l10n),
        const SizedBox(height: 12),

        // Steps list
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
                  elevation: animation.value * 6,
                  borderRadius: BorderRadius.circular(12),
                  shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                  child: child,
                ),
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final step = _steps[index];
              final isSelected = _selectedStepIds.contains(step.id);

              return _StepCard(
                key: ValueKey(step.id),
                index: index,
                step: step,
                focusNode: _getFocusNode(step.id),
                isPremium: widget.isPremium,
                isSelected: isSelected,
                isSelectionMode: _isSelectionMode,
                onTextChanged: (text) => _updateStep(index, text),
                onImageChanged: (path) {
                  setState(() {
                    _steps[index].imagePath = path;
                  });
                  widget.onStepsChanged(_steps);
                },
                onLongPress: () => _onLongPress(step.id),
                onTap: _isSelectionMode ? () => _toggleSelection(step.id) : null,
              );
            },
          ),

        const SizedBox(height: 12),

        // Add step button (hidden during selection mode)
        if (!_isSelectionMode)
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

        // Selection action bar
        if (_isSelectionMode)
          _SelectionActionBar(
            selectedCount: _selectedStepIds.length,
            totalCount: _steps.length,
            onDelete: () => _removeSteps(_selectedStepIds.toList()),
            onSelectAll: _selectAll,
            onClear: _clearSelection,
          ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    if (_isSelectionMode) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSelection,
              visualDensity: VisualDensity.compact,
            ),
            Text(
              '${_selectedStepIds.length} selected',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (_selectedStepIds.length < _steps.length)
              TextButton(
                onPressed: _selectAll,
                child: const Text('Select All'),
              ),
          ],
        ),
      );
    }

    return Row(
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
    );
  }
}

// ============ STEP CARD ============

class _StepCard extends StatelessWidget {
  final int index;
  final EditableStep step;
  final FocusNode focusNode;
  final bool isPremium;
  final bool isSelected;
  final bool isSelectionMode;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String?> onImageChanged;
  final VoidCallback onLongPress;
  final VoidCallback? onTap;

  const _StepCard({
    super.key,
    required this.index,
    required this.step,
    required this.focusNode,
    required this.isPremium,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTextChanged,
    required this.onImageChanged,
    required this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onLongPress: onLongPress,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                : (isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.15),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: step number or selection checkbox
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 14),
                child: isSelectionMode
                    ? AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                )
                    : Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8A860),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              // Center: text field
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
                  child: AbsorbPointer(
                    absorbing: isSelectionMode,
                    child: TextField(
                      focusNode: focusNode,
                      controller: TextEditingController(text: step.instruction)
                        ..selection = TextSelection.collapsed(offset: step.instruction.length),
                      maxLines: null,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Enter instruction...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline.withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        isDense: true,
                      ),
                      style: theme.textTheme.bodyMedium,
                      onChanged: onTextChanged,
                    ),
                  ),
                ),
              ),

              // Right side: drag handle (only when not selecting)
              if (!isSelectionMode)
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, right: 8, left: 4),
                    child: Icon(
                      Icons.drag_indicator,
                      color: theme.colorScheme.outline.withValues(alpha: 0.4),
                      size: 20,
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

// ============ SELECTION ACTION BAR ============

class _SelectionActionBar extends StatelessWidget {
  final int selectedCount;
  final int totalCount;
  final VoidCallback onDelete;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;

  const _SelectionActionBar({
    required this.selectedCount,
    required this.totalCount,
    required this.onDelete,
    required this.onSelectAll,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton.tonalIcon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            label: Text('Delete $selectedCount'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
          ),
        ],
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
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
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
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.format_list_numbered, size: 48, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
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
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
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
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
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