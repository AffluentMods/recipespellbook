import 'dart:async';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/data/nutrition_data.dart';
import 'package:recipespellbook/ui/widgets/nutrition_widgets.dart';

/// Launches cooking mode for a recipe
void launchCookingMode(BuildContext context, String recipeId) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => CookingModeScreen(recipeId: recipeId),
    ),
  );
}

class CookingModeScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const CookingModeScreen({super.key, required this.recipeId});

  @override
  ConsumerState<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends ConsumerState<CookingModeScreen> {
  Recipe? _recipe;
  List<Ingredient> _ingredients = [];
  List<Step> _steps = [];
  NutritionData? _nutrition;
  int _currentStepIndex = 0;
  bool _isLoading = true;
  bool _showIngredients = false;
  bool _showNutrition = false;

  // Timer state
  Timer? _timer;
  int _timerSeconds = 0;
  bool _timerRunning = false;
  int _timerSetSeconds = 0;

  // Checked ingredients
  final Set<String> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    _loadRecipe();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _loadRecipe() async {
    final dao = ref.read(recipeDaoProvider);
    final recipe = await dao.getRecipeById(widget.recipeId);
    if (recipe == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final ingredients = await dao.getIngredientsForRecipe(widget.recipeId);
    final steps = await dao.getStepsForRecipe(widget.recipeId);

    // Load nutrition if available
    NutritionData? nutrition;
    // TODO: Load from recipe.nutritionJson when database field is added
    // if (recipe.nutritionJson != null) {
    //   nutrition = NutritionData.fromJson(jsonDecode(recipe.nutritionJson!));
    // }

    setState(() {
      _recipe = recipe;
      _ingredients = ingredients;
      _steps = steps;
      _nutrition = nutrition;
      _isLoading = false;
    });
  }

  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() => _currentStepIndex++);
      HapticFeedback.lightImpact();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() => _currentStepIndex--);
      HapticFeedback.lightImpact();
    }
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _timerSetSeconds = seconds;
      _timerSeconds = seconds;
      _timerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
        if (_timerSeconds == 10) HapticFeedback.mediumImpact();
      } else {
        timer.cancel();
        setState(() => _timerRunning = false);
        HapticFeedback.heavyImpact();
        _showTimerDoneDialog();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _timerRunning = false;
      _timerSeconds = 0;
    });
  }

  void _showTimerDoneDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('⏰ ${l10n.cookingTimerDone}'),
        content: Text(l10n.cookingTimerFinished),
        actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionOk))],
      ),
    );
  }

  void _showTimerPicker() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.cookingSetTimer, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TimerChip(label: '1 ${l10n.minutesAbbrev}', onTap: () { Navigator.pop(ctx); _startTimer(60); }),
                _TimerChip(label: '5 ${l10n.minutesAbbrev}', onTap: () { Navigator.pop(ctx); _startTimer(300); }),
                _TimerChip(label: '10 ${l10n.minutesAbbrev}', onTap: () { Navigator.pop(ctx); _startTimer(600); }),
                _TimerChip(label: '15 ${l10n.minutesAbbrev}', onTap: () { Navigator.pop(ctx); _startTimer(900); }),
                _TimerChip(label: '30 ${l10n.minutesAbbrev}', onTap: () { Navigator.pop(ctx); _startTimer(1800); }),
                _TimerChip(label: '45 ${l10n.minutesAbbrev}', onTap: () { Navigator.pop(ctx); _startTimer(2700); }),
                _TimerChip(label: '1 ${l10n.hoursAbbrev}', onTap: () { Navigator.pop(ctx); _startTimer(3600); }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExit() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cookingExitTitle),
        content: Text(l10n.cookingExitMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: Text(l10n.cookingExit)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading || _recipe == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _TopBar(
              recipeName: _recipe!.title,
              showIngredients: _showIngredients,
              hasNutrition: _nutrition?.hasAnyData ?? false,
              showNutrition: _showNutrition,
              onToggleIngredients: () => setState(() {
                _showIngredients = !_showIngredients;
                if (_showIngredients) _showNutrition = false;
              }),
              onToggleNutrition: () => setState(() {
                _showNutrition = !_showNutrition;
                if (_showNutrition) _showIngredients = false;
              }),
              onExit: _confirmExit,
            ),

            // Nutrition banner (when toggled on)
            if (_showNutrition && _nutrition != null && _nutrition!.hasAnyData)
              NutritionBanner(nutrition: _nutrition!),

            // Timer bar
            if (_timerRunning || _timerSeconds > 0)
              _TimerBar(seconds: _timerSeconds, totalSeconds: _timerSetSeconds, onStop: _stopTimer),

            // Main content
            Expanded(
              child: _showIngredients
                  ? _IngredientsView(
                ingredients: _ingredients,
                checkedIds: _checkedIngredients,
                onToggle: (id) => setState(() {
                  if (_checkedIngredients.contains(id)) {
                    _checkedIngredients.remove(id);
                  } else {
                    _checkedIngredients.add(id);
                  }
                }),
              )
                  : _steps.isEmpty
                  ? Center(child: Text(l10n.instructionsEmpty, style: const TextStyle(color: Colors.white)))
                  : _StepView(step: _steps[_currentStepIndex], stepNumber: _currentStepIndex + 1, totalSteps: _steps.length),
            ),

            // Bottom navigation
            _BottomBar(
              currentStep: _currentStepIndex,
              totalSteps: _steps.length,
              onPrevious: _currentStepIndex > 0 ? _previousStep : null,
              onNext: _currentStepIndex < _steps.length - 1 ? _nextStep : null,
              onTimer: _showTimerPicker,
              onFinish: _currentStepIndex == _steps.length - 1 ? () => Navigator.pop(context) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String recipeName;
  final bool showIngredients;
  final bool hasNutrition;
  final bool showNutrition;
  final VoidCallback onToggleIngredients;
  final VoidCallback onToggleNutrition;
  final VoidCallback onExit;

  const _TopBar({
    required this.recipeName,
    required this.showIngredients,
    required this.hasNutrition,
    required this.showNutrition,
    required this.onToggleIngredients,
    required this.onToggleNutrition,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onExit,
          ),
          Expanded(
            child: Text(
              recipeName,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          // Nutrition toggle (if available)
          if (hasNutrition)
            IconButton(
              icon: Icon(
                Icons.local_fire_department,
                color: showNutrition ? Colors.orange : Colors.white,
              ),
              onPressed: onToggleNutrition,
            ),
          // Ingredients toggle
          IconButton(
            icon: Icon(
              showIngredients ? Icons.format_list_numbered : Icons.list,
              color: showIngredients ? Colors.green : Colors.white,
            ),
            onPressed: onToggleIngredients,
          ),
        ],
      ),
    );
  }
}

class _TimerBar extends StatelessWidget {
  final int seconds;
  final int totalSeconds;
  final VoidCallback onStop;

  const _TimerBar({required this.seconds, required this.totalSeconds, required this.onStop});

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? seconds / totalSeconds : 0.0;
    final isLow = seconds <= 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isLow ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.timer, color: isLow ? Colors.red : Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatTime(seconds), style: TextStyle(color: isLow ? Colors.red : Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                LinearProgressIndicator(value: progress, backgroundColor: Colors.white.withOpacity(0.2), valueColor: AlwaysStoppedAnimation(isLow ? Colors.red : Colors.green)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.stop, color: Colors.white), onPressed: onStop),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _StepView extends StatelessWidget {
  final Step step;
  final int stepNumber;
  final int totalSteps;

  const _StepView({required this.step, required this.stepNumber, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${l10n.stepNumber(stepNumber)} / $totalSteps', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
          const SizedBox(height: 32),
          Text(step.instruction, style: const TextStyle(color: Colors.white, fontSize: 28, height: 1.4), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _IngredientsView extends StatelessWidget {
  final List<Ingredient> ingredients;
  final Set<String> checkedIds;
  final Function(String) onToggle;

  const _IngredientsView({required this.ingredients, required this.checkedIds, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ing = ingredients[index];
        final isChecked = checkedIds.contains(ing.id);

        return GestureDetector(
          onTap: () => onToggle(ing.id),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(isChecked ? 0.05 : 0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(isChecked ? Icons.check_circle : Icons.circle_outlined, color: isChecked ? Colors.green : Colors.white.withOpacity(0.5)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    [if (ing.amount != null) ing.amount!, if (ing.unit != null) ing.unit!, ing.name].join(' '),
                    style: TextStyle(color: isChecked ? Colors.white.withOpacity(0.5) : Colors.white, fontSize: 18, decoration: isChecked ? TextDecoration.lineThrough : null),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onTimer;
  final VoidCallback? onFinish;

  const _BottomBar({required this.currentStep, required this.totalSteps, this.onPrevious, this.onNext, required this.onTimer, this.onFinish});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, size: 32), color: onPrevious != null ? Colors.white : Colors.white.withOpacity(0.3), onPressed: onPrevious),
          IconButton(icon: const Icon(Icons.timer, size: 32), color: Colors.white, onPressed: onTimer),
          if (onFinish != null)
            FilledButton.icon(onPressed: onFinish, icon: const Icon(Icons.check), label: Text(l10n.cookingFinish), style: FilledButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)))
          else
            IconButton(icon: const Icon(Icons.arrow_forward, size: 32), color: onNext != null ? Colors.white : Colors.white.withOpacity(0.3), onPressed: onNext),
        ],
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TimerChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}