import 'package:flutter/material.dart';
import '../../utils/native_file_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/platform_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/subscription_provider.dart';
import '../../../services/feature_gate.dart';
import '../../../utils/responsive_utils.dart';
import 'recipe_image.dart';

/// Step data model for editing
class EditableStep {
  String id;
  String instruction;
  String? imagePath;

  /// Section header/divider (not a real step). Its [instruction] holds the
  /// section title; saved with notes == '__header__'. Mirrors ingredient headers.
  bool isHeader;

  EditableStep({
    required this.id,
    this.instruction = '',
    this.imagePath,
    this.isHeader = false,
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

  // ── Bulk text-edit mode ───────────────────────────────────────────
  // When toggled on, the structured per-step list is replaced with a
  // single multi-line text field where steps are separated by blank
  // lines. Images are preserved by index — snapshotted at entry so
  // they survive intermediate parse results while the user is mid-edit.
  bool _bulkEditMode = false;
  TextEditingController? _bulkController;
  final FocusNode _bulkFocusNode = FocusNode();
  // Snapshot of (id, imagePath) by index, taken when entering bulk mode.
  // Used so transient parse states during typing don't churn images.
  List<({String id, String? imagePath})> _bulkEditSnapshot = const [];

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
      // If we're in bulk edit, refresh the text content too
      if (_bulkEditMode && _bulkController != null) {
        _bulkController!.text = _serializeStepsToBulkText(_steps);
      }
    }
  }

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    _bulkController?.dispose();
    _bulkFocusNode.dispose();
    super.dispose();
  }

  // Convert the step list to a single editable string. Steps are
  // separated by a blank line (\n\n). Empty trailing steps are dropped.
  String _serializeStepsToBulkText(List<EditableStep> steps) {
    return steps
        .map((s) {
          final t = s.instruction.trim();
          if (t.isEmpty) return '';
          return s.isHeader ? '# $t' : t;
        })
        .where((s) => s.isNotEmpty)
        .join('\n\n');
  }

  // Parse bulk text back into steps using the snapshot of (id, image)
  // taken at entry time. Splits on blank lines. Preserves IDs and image
  // paths by index — items dropped past snapshot length get fresh IDs
  // and no image.
  List<EditableStep> _parseBulkTextFromSnapshot(String text) {
    final blocks = text
        .split(RegExp(r'\n\s*\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      for (var i = 0; i < blocks.length; i++)
        () {
          final raw = blocks[i];
          final isHdr = raw.startsWith('# ');
          return EditableStep(
            id: i < _bulkEditSnapshot.length
                ? _bulkEditSnapshot[i].id
                : 'step_${now}_$i',
            instruction: isHdr ? raw.substring(2).trim() : raw,
            imagePath: isHdr
                ? null
                : (i < _bulkEditSnapshot.length ? _bulkEditSnapshot[i].imagePath : null),
            isHeader: isHdr,
          );
        }(),
    ];
  }

  void _onBulkTextChanged() {
    // Re-parse and push to parent on every keystroke. This way the
    // recipe still saves correctly even if the user navigates away
    // without explicitly toggling back to list mode.
    final parsed = _parseBulkTextFromSnapshot(_bulkController?.text ?? '');
    _steps
      ..clear()
      ..addAll(parsed);
    widget.onStepsChanged(_steps);
    // Rebuild so the live step count in the header updates.
    if (mounted) setState(() {});
  }

  void _enterBulkEditMode() {
    _bulkEditSnapshot = _steps
        .map((s) => (id: s.id, imagePath: s.imagePath))
        .toList(growable: false);
    final text = _serializeStepsToBulkText(_steps);
    setState(() {
      _bulkController?.removeListener(_onBulkTextChanged);
      _bulkController?.dispose();
      _bulkController = TextEditingController(text: text)
        ..addListener(_onBulkTextChanged);
      _bulkEditMode = true;
      // Clear any active multi-select state on the list view
      _selectedStepIds.clear();
      _isSelectionMode = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bulkFocusNode.requestFocus();
    });
  }

  void _exitBulkEditMode() {
    // _steps was already kept in sync by _onBulkTextChanged. Just flip
    // the mode flag, prune stale focus nodes, and push one final
    // notification to the parent.
    setState(() {
      _bulkEditMode = false;
      _bulkController?.removeListener(_onBulkTextChanged);
      final liveIds = _steps.map((s) => s.id).toSet();
      final stale = _focusNodes.keys.where((id) => !liveIds.contains(id)).toList();
      for (final id in stale) {
        _focusNodes.remove(id)?.dispose();
      }
    });
    widget.onStepsChanged(_steps);
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

  void _addSectionHeader() {
    final header = EditableStep(
      id: 'shdr_${DateTime.now().millisecondsSinceEpoch}',
      instruction: '',
      isHeader: true,
    );
    setState(() {
      _steps.add(header);
    });
    widget.onStepsChanged(_steps);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getFocusNode(header.id).requestFocus();
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
        title: Text(count == 1 ? l10n.deleteStep : l10n.deleteSteps),
        content: Text(
          count == 1
              ? l10n.stepWillBeRemoved
              : l10n.stepsWillBeRemoved(count),
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
        // Header with selection / bulk-edit controls
        _buildHeader(theme, l10n),
        const SizedBox(height: 12),

        // ── Bulk text-edit mode ──────────────────────────────────
        if (_bulkEditMode)
          _BulkStepsEditor(
            controller: _bulkController!,
            focusNode: _bulkFocusNode,
            hint: l10n.stepsBulkEditHint,
          )
        // Steps list
        else if (_steps.isEmpty)
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
              // Display number excludes section headers.
              var stepNumber = 0;
              for (var k = 0; k <= index; k++) {
                if (!_steps[k].isHeader) stepNumber++;
              }

              return _StepCard(
                key: ValueKey(step.id),
                index: index,
                stepNumber: stepNumber,
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
                onImageGateCheck: () =>
                    checkFeatureAccess(context, ref, GatedFeature.stepPhotos),
                hasStepPhotoAccess: GatedFeature.stepPhotos.isUnlockedFor(
                    ref.watch(subscriptionProvider).tier),
              );
            },
          ),

        const SizedBox(height: 12),

        // Add step button (hidden during selection mode and bulk edit)
        if (!_isSelectionMode && !_bulkEditMode)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add),
                label: Text(l10n.addStep),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _addSectionHeader,
                icon: const Icon(Icons.segment, size: 18),
                label: Text(l10n.ingredientAddHeader),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ],
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
              l10n.selectedCount(_selectedStepIds.length),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (_selectedStepIds.length < _steps.length)
              TextButton(
                onPressed: _selectAll,
                child: Text(l10n.selectAll),
              ),
          ],
        ),
      );
    }

    // Count steps live in bulk mode by parsing the current text. This
    // gives the user feedback as they type / split / merge.
    final int bulkCount = _bulkEditMode
        ? (_bulkController?.text ?? '')
            .split(RegExp(r'\n\s*\n'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .length
        : _steps.length;

    // Single Premium indicator for the whole section, instead of an
    // amber star plastered on every step's camera icon.
    final hasStepPhotoAccess = GatedFeature.stepPhotos
        .isUnlockedFor(ref.watch(subscriptionProvider).tier);

    return Row(
      children: [
        Text(
          l10n.instructionsTitle,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (!hasStepPhotoAccess) ...[
          const SizedBox(width: 6),
          Tooltip(
            message: l10n.requiresPremium,
            child: Icon(
              Icons.workspace_premium_outlined,
              size: 16,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
        const SizedBox(width: 6),
        // Toggle: structured cards ↔ single text field
        TextButton.icon(
          onPressed: _bulkEditMode ? _exitBulkEditMode : _enterBulkEditMode,
          icon: Icon(
            _bulkEditMode ? Icons.format_list_numbered : Icons.notes,
            size: 18,
          ),
          label: Text(_bulkEditMode ? l10n.editAsList : l10n.editAsText),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
        const Spacer(),
        Text(
          l10n.stepCount(bulkCount),
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }
}

// ============ BULK STEPS EDITOR ============

/// Single multi-line text field for editing all steps at once.
/// Steps are separated by blank lines.
class _BulkStepsEditor extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;

  const _BulkStepsEditor({
    required this.controller,
    required this.focusNode,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: null,
        minLines: 8,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
      ),
    );
  }
}

// ============ STEP CARD ============

class _StepCard extends StatefulWidget {
  final int index;
  final int stepNumber;
  final EditableStep step;
  final FocusNode focusNode;
  final bool isPremium;
  final bool isSelected;
  final bool isSelectionMode;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String?> onImageChanged;
  final VoidCallback onLongPress;
  final VoidCallback? onTap;
  final bool Function() onImageGateCheck;
  final bool hasStepPhotoAccess;

  const _StepCard({
    super.key,
    required this.index,
    required this.stepNumber,
    required this.step,
    required this.focusNode,
    required this.isPremium,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTextChanged,
    required this.onImageChanged,
    required this.onLongPress,
    required this.onImageGateCheck,
    required this.hasStepPhotoAccess,
    this.onTap,
  });

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.step.instruction);
  }

  @override
  void didUpdateWidget(_StepCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the controller text if the step identity changed (e.g. reorder)
    if (oldWidget.step.instruction != widget.step.instruction &&
        _controller.text != widget.step.instruction) {
      _controller.text = widget.step.instruction;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Forward getters for cleaner access
  int get index => widget.index;
  EditableStep get step => widget.step;
  FocusNode get focusNode => widget.focusNode;
  bool get isPremium => widget.isPremium;
  bool get isSelected => widget.isSelected;
  bool get isSelectionMode => widget.isSelectionMode;
  ValueChanged<String> get onTextChanged => widget.onTextChanged;
  ValueChanged<String?> get onImageChanged => widget.onImageChanged;
  VoidCallback get onLongPress => widget.onLongPress;
  VoidCallback? get onTap => widget.onTap;
  bool Function() get onImageGateCheck => widget.onImageGateCheck;
  bool get hasStepPhotoAccess => widget.hasStepPhotoAccess;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (step.isHeader) {
      return _buildHeaderCard(context, theme);
    }
    final hasImage = step.imagePath != null &&
        step.imagePath!.isNotEmpty &&
        FileExistsCache.exists(step.imagePath!);

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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left side: checkbox (selection mode) OR camera + number
                if (isSelectionMode)
                  AnimatedContainer(
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
                else ...[
                  // Camera icon / image thumbnail
                  GestureDetector(
                    onTap: () => _showImagePicker(context),
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: hasImage
                                  ? Colors.transparent
                                  : (isDark
                                  ? theme.colorScheme.surfaceContainerHighest
                                  : theme.colorScheme.surfaceContainerLow),
                              borderRadius: BorderRadius.circular(10),
                              border: hasImage
                                  ? null
                                  : Border.all(
                                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: hasImage
                                ? buildFileImage(
                              step.imagePath!,
                              fit: BoxFit.cover,
                              cacheHeight: 76,
                            )
                                : Icon(
                              Icons.camera_alt_outlined,
                              size: 18,
                              color: theme.colorScheme.outline.withValues(alpha: 0.5),
                            ),
                          ),
                          // Premium gating is communicated once at the
                          // section header (see _buildHeader) — no need
                          // to plaster a badge on every step card.
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Step number badge — themed rounded square
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.primary.withValues(alpha: 0.25)
                          : theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.stepNumber}',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],

                const SizedBox(width: 10),

                // Center: text field
                Expanded(
                  child: AbsorbPointer(
                    absorbing: isSelectionMode,
                    child: TextField(
                      focusNode: focusNode,
                      controller: _controller,
                      maxLines: null,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.enterInstruction,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline.withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        isDense: true,
                      ),
                      style: theme.textTheme.bodyMedium,
                      onChanged: onTextChanged,
                    ),
                  ),
                ),

                // Right side: drag handle — 2-bar style
                if (!isSelectionMode)
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.drag_handle,
                        color: theme.colorScheme.outline.withValues(alpha: 0.4),
                        size: 22,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
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
                : theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withValues(alpha: 0.35),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                if (isSelectionMode)
                  AnimatedContainer(
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
                else
                  Icon(Icons.segment, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: AbsorbPointer(
                    absorbing: isSelectionMode,
                    child: TextField(
                      focusNode: focusNode,
                      controller: _controller,
                      maxLines: null,
                      minLines: 1,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: l10n.ingredientHeader,
                        hintStyle: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w700,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        isDense: true,
                      ),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                      onChanged: onTextChanged,
                    ),
                  ),
                ),
                if (!isSelectionMode)
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.drag_handle,
                        color: theme.colorScheme.outline.withValues(alpha: 0.4),
                        size: 22,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasExistingImage = step.imagePath != null && step.imagePath!.isNotEmpty;

    // Gate: adding NEW step photos requires Premium or higher.
    // Users can still remove existing photos (from imports/transfers).
    if (!hasExistingImage && !onImageGateCheck()) return;

    final picker = ImagePicker();

    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            if (step.imagePath != null && step.imagePath!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(l10n.removeImage),
                onTap: () {
                  Navigator.pop(ctx);
                  onImageChanged(null);
                },
              ),
            if (supportsCamera)
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: hasStepPhotoAccess ? null : Theme.of(context).disabledColor,
                ),
                title: Text(l10n.takePhoto),
                subtitle: hasStepPhotoAccess
                    ? null
                    : Text(l10n.requiresPremium,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    )),
                onTap: hasStepPhotoAccess
                    ? () async {
                  Navigator.pop(ctx);
                  final image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null && context.mounted) {
                    onImageChanged(image.path);
                  }
                }
                    : () {
                  Navigator.pop(ctx);
                  onImageGateCheck(); // Shows upgrade sheet
                },
              ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: hasStepPhotoAccess ? null : Theme.of(context).disabledColor,
              ),
              title: Text(l10n.chooseFromGallery),
              subtitle: hasStepPhotoAccess
                  ? null
                  : Text(l10n.requiresPremium,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  )),
              onTap: hasStepPhotoAccess
                  ? () async {
                Navigator.pop(ctx);
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null && context.mounted) {
                  onImageChanged(image.path);
                }
              }
                  : () {
                Navigator.pop(ctx);
                onImageGateCheck(); // Shows upgrade sheet
              },
            ),
          ],
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
            label: Text(l10n.deleteCount(selectedCount)),
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

// ============ EMPTY STATE ============

class _EmptyStepsState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyStepsState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
            l10n.instructionsNoSteps,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.instructionsAddStepsGuide,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(l10n.addFirstStep),
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
              l10n.ingredientCount(count),
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
              hintText: l10n.ingredientPerLineHint,
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
          l10n.ingredientTip,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }
}