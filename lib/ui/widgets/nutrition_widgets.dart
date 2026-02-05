import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../data/nutrition_data.dart';

/// Displays nutrition information in a compact card format
class NutritionCard extends StatelessWidget {
  final NutritionData nutrition;
  final double scaleFactor;
  final VoidCallback? onEdit;

  const NutritionCard({
    super.key,
    required this.nutrition,
    this.scaleFactor = 1.0,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final scaledNutrition = nutrition.scaled(scaleFactor);

    if (!nutrition.hasAnyData) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.local_fire_department,
                    color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.nutrientsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (scaleFactor != 1.0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${scaleFactor}x',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: onEdit,
                    tooltip: l10n.recipeEdit,
                  ),
              ],
            ),

            // Serving size
            if (nutrition.servingSize != null) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.perServing}: ${nutrition.servingSize}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Main macros row (calories, protein, carbs, fat)
            Row(
              children: [
                if (scaledNutrition.calories != null)
                  Expanded(child: _MacroChip(
                    label: l10n.calories,
                    value: '${scaledNutrition.calories!.round()}',
                    unit: 'kcal',
                    color: Colors.orange,
                  )),
                if (scaledNutrition.protein != null)
                  Expanded(child: _MacroChip(
                    label: l10n.protein,
                    value: _formatGrams(scaledNutrition.protein!),
                    unit: 'g',
                    color: Colors.red,
                  )),
                if (scaledNutrition.carbohydrates != null)
                  Expanded(child: _MacroChip(
                    label: l10n.carbohydrates,
                    value: _formatGrams(scaledNutrition.carbohydrates!),
                    unit: 'g',
                    color: Colors.blue,
                  )),
                if (scaledNutrition.fat != null)
                  Expanded(child: _MacroChip(
                    label: l10n.fat,
                    value: _formatGrams(scaledNutrition.fat!),
                    unit: 'g',
                    color: Colors.amber,
                  )),
              ],
            ),

            // Additional nutrients (if any)
            if (_hasAdditionalNutrients(scaledNutrition)) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (scaledNutrition.fiber != null)
                    _SmallNutrient(label: l10n.fiber, value: '${_formatGrams(scaledNutrition.fiber!)}g'),
                  if (scaledNutrition.sugar != null)
                    _SmallNutrient(label: l10n.sugar, value: '${_formatGrams(scaledNutrition.sugar!)}g'),
                  if (scaledNutrition.sodium != null)
                    _SmallNutrient(label: l10n.sodium, value: '${scaledNutrition.sodium!.round()}mg'),
                  if (scaledNutrition.cholesterol != null)
                    _SmallNutrient(label: l10n.cholesterol, value: '${scaledNutrition.cholesterol!.round()}mg'),
                  if (scaledNutrition.saturatedFat != null)
                    _SmallNutrient(label: l10n.saturatedFat, value: '${_formatGrams(scaledNutrition.saturatedFat!)}g'),
                  if (scaledNutrition.transFat != null)
                    _SmallNutrient(label: l10n.transFat, value: '${_formatGrams(scaledNutrition.transFat!)}g'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasAdditionalNutrients(NutritionData n) {
    return n.fiber != null || n.sugar != null || n.sodium != null ||
        n.cholesterol != null || n.saturatedFat != null || n.transFat != null;
  }

  String _formatGrams(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SmallNutrient extends StatelessWidget {
  final String label;
  final String value;

  const _SmallNutrient({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Compact nutrition display for cooking mode
class NutritionBanner extends StatelessWidget {
  final NutritionData nutrition;

  const NutritionBanner({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    if (!nutrition.hasAnyData) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (nutrition.calories != null)
            _NutrientPill(label: 'Cal', value: '${nutrition.calories!.round()}'),
          if (nutrition.protein != null)
            _NutrientPill(label: 'Protein', value: '${nutrition.protein!.round()}g'),
          if (nutrition.carbohydrates != null)
            _NutrientPill(label: 'Carbs', value: '${nutrition.carbohydrates!.round()}g'),
          if (nutrition.fat != null)
            _NutrientPill(label: 'Fat', value: '${nutrition.fat!.round()}g'),
        ],
      ),
    );
  }
}

class _NutrientPill extends StatelessWidget {
  final String label;
  final String value;

  const _NutrientPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet for editing nutrition data
class NutritionEditSheet extends StatefulWidget {
  final NutritionData? initialData;
  final Function(NutritionData) onSave;
  final VoidCallback? onCalculate; // Callback for premium auto-calculate feature

  const NutritionEditSheet({
    super.key,
    this.initialData,
    required this.onSave,
    this.onCalculate,
  });

  @override
  State<NutritionEditSheet> createState() => _NutritionEditSheetState();
}

class _NutritionEditSheetState extends State<NutritionEditSheet> {
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late final TextEditingController _fiberController;
  late final TextEditingController _sugarController;
  late final TextEditingController _sodiumController;
  late final TextEditingController _cholesterolController;
  late final TextEditingController _saturatedFatController;
  late final TextEditingController _transFatController;
  late final TextEditingController _servingSizeController;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData ?? NutritionData.empty;
    _caloriesController = TextEditingController(text: data.calories?.toString() ?? '');
    _proteinController = TextEditingController(text: data.protein?.toString() ?? '');
    _carbsController = TextEditingController(text: data.carbohydrates?.toString() ?? '');
    _fatController = TextEditingController(text: data.fat?.toString() ?? '');
    _fiberController = TextEditingController(text: data.fiber?.toString() ?? '');
    _sugarController = TextEditingController(text: data.sugar?.toString() ?? '');
    _sodiumController = TextEditingController(text: data.sodium?.toString() ?? '');
    _cholesterolController = TextEditingController(text: data.cholesterol?.toString() ?? '');
    _saturatedFatController = TextEditingController(text: data.saturatedFat?.toString() ?? '');
    _transFatController = TextEditingController(text: data.transFat?.toString() ?? '');
    _servingSizeController = TextEditingController(text: data.servingSize ?? '');
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    _cholesterolController.dispose();
    _saturatedFatController.dispose();
    _transFatController.dispose();
    _servingSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      l10n.addNutrients,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Disclaimer
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: theme.colorScheme.tertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.nutrientsDisclaimer,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Form fields
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Calculate button (premium feature)
                    if (widget.onCalculate != null) ...[
                      OutlinedButton.icon(
                        onPressed: widget.onCalculate,
                        icon: const Icon(Icons.calculate),
                        label: Text(l10n.calculateNutrients),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(l10n.orDivider, style: theme.textTheme.bodySmall),
                          ),
                          Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3))),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Serving size
                    TextFormField(
                      controller: _servingSizeController,
                      decoration: InputDecoration(
                        labelText: l10n.servingSize,
                        hintText: 'e.g., 1 cup, 100g',
                        prefixIcon: const Icon(Icons.restaurant),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Main macros
                    Text(
                      'Main Nutrients',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(child: _buildField(_caloriesController, l10n.calories, 'kcal')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField(_proteinController, l10n.protein, 'g')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildField(_carbsController, l10n.carbohydrates, 'g')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField(_fatController, l10n.fat, 'g')),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Additional nutrients
                    Text(
                      'Additional Nutrients',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(child: _buildField(_fiberController, l10n.fiber, 'g')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField(_sugarController, l10n.sugar, 'g')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildField(_sodiumController, l10n.sodium, 'mg')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField(_cholesterolController, l10n.cholesterol, 'mg')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildField(_saturatedFatController, l10n.saturatedFat, 'g')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField(_transFatController, l10n.transFat, 'g')),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Save button
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: Text(l10n.actionSave),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildField(TextEditingController controller, String label, String suffix) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        isDense: true,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
    );
  }

  void _save() {
    final data = NutritionData(
      calories: double.tryParse(_caloriesController.text),
      protein: double.tryParse(_proteinController.text),
      carbohydrates: double.tryParse(_carbsController.text),
      fat: double.tryParse(_fatController.text),
      fiber: double.tryParse(_fiberController.text),
      sugar: double.tryParse(_sugarController.text),
      sodium: double.tryParse(_sodiumController.text),
      cholesterol: double.tryParse(_cholesterolController.text),
      saturatedFat: double.tryParse(_saturatedFatController.text),
      transFat: double.tryParse(_transFatController.text),
      servingSize: _servingSizeController.text.isEmpty ? null : _servingSizeController.text,
    );

    widget.onSave(data);
    Navigator.pop(context);
  }
}

/// Button to add nutrition info (used in recipe edit screen)
class AddNutritionButton extends StatelessWidget {
  final NutritionData? currentData;
  final Function(NutritionData) onSave;
  final VoidCallback? onCalculate;

  const AddNutritionButton({
    super.key,
    this.currentData,
    required this.onSave,
    this.onCalculate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasData = currentData?.hasAnyData ?? false;

    return Card(
      child: InkWell(
        onTap: () => _showEditSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasData
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: hasData
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.nutrientsTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (hasData && currentData!.calories != null)
                      Text(
                        '${currentData!.calories!.round()} ${l10n.calories}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      )
                    else
                      Text(
                        l10n.addNutrients,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                hasData ? Icons.edit : Icons.add,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NutritionEditSheet(
        initialData: currentData,
        onSave: onSave,
        onCalculate: onCalculate,
      ),
    );
  }
}