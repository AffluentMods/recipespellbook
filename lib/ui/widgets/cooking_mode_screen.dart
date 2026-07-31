import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:recipespellbook/data/food_synonyms.dart';
import 'package:recipespellbook/data/nutrition_data.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';

import '../../../ui/widgets/nutrition_widgets.dart';
import '../../ui/widgets/font_size_control.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/ingredient_utils.dart'
    show scaleInstructionText, scaledIngredientLabel;
import '../../theme/app_colors.dart';
// TODO: Kitchen Buddy hidden for now
// import 'kitchen_buddy/kitchen_buddy_integration.dart';

/// Launches cooking mode for a recipe
void launchCookingMode(BuildContext context, String recipeId,
    {double scaleFactor = 1.0}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) =>
          CookingModeScreen(recipeId: recipeId, scaleFactor: scaleFactor),
    ),
  );
}

class CookingModeScreen extends ConsumerStatefulWidget {
  final String recipeId;

  /// Recipe scale carried over from the recipe screen, so embedded amounts in
  /// the steps and the ingredient list match what the user scaled to. 1.0 = off.
  final double scaleFactor;

  const CookingModeScreen(
      {super.key, required this.recipeId, this.scaleFactor = 1.0});

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

  // Page controller for swipeable steps
  late PageController _pageController;

  // ── Voice control ──
  // Hands-free step navigation while cooking. The mic stays open until
  // the user toggles it off; we restart listening after each result so
  // commands keep working without re-tapping. Disabled on web (no
  // permissions plumbing) and on platforms where init fails.
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _voiceAvailable = false;
  bool _voiceListening = false;
  String _lastVoiceText = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadRecipe();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Keep the screen on while cooking — nothing worse than your phone locking
    // mid-recipe with messy hands.
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    if (_voiceListening) _speech.stop();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
    super.dispose();
  }

  // ── Voice control ────────────────────────────────────────────────

  Future<void> _toggleVoice() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.cookModeVoiceUnavailable)),
      );
      return;
    }
    if (_voiceListening) {
      await _speech.stop();
      if (mounted) setState(() => _voiceListening = false);
      return;
    }
    if (!_voiceAvailable) {
      // Lazy init — avoids the mic-permission prompt on screen open.
      try {
        _voiceAvailable = await _speech.initialize(
          onStatus: (s) {
            // Auto-restart after a "done" result so the user doesn't
            // have to tap again between commands.
            if (s == 'done' && _voiceListening && mounted) {
              _speech.listen(
                onResult: _handleVoiceResult,
                listenFor: const Duration(seconds: 30),
                partialResults: false,
                cancelOnError: false,
              );
            }
            if (s == 'notListening' && mounted) {
              setState(() {});
            }
          },
          onError: (e) {
            // Don't tear down on transient "no_match" — that fires
            // whenever the user just doesn't say anything in time.
            debugPrint('[Voice] error: ${e.errorMsg}');
          },
        );
      } catch (e) {
        _voiceAvailable = false;
      }
      if (!_voiceAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.cookModeVoiceUnavailable)),
      );
        }
        return;
      }
    }
    await _speech.listen(
      onResult: _handleVoiceResult,
      listenFor: const Duration(seconds: 30),
      partialResults: false,
      cancelOnError: false,
    );
    if (mounted) setState(() => _voiceListening = true);
  }

  void _handleVoiceResult(dynamic result) {
    final text = (result.recognizedWords as String? ?? '').toLowerCase().trim();
    if (text.isEmpty || !mounted) return;
    setState(() => _lastVoiceText = text);

    // Match coarse commands. Short circuit on first hit so "set timer
    // for the next ten minutes" doesn't also trigger "next".
    if (_matches(text, const ['next', 'forward', 'continue'])) {
      _nextStep();
      return;
    }
    if (_matches(text, const ['back', 'previous', 'go back'])) {
      _previousStep();
      return;
    }
    if (_matches(text, const ['pause', 'stop', 'stop timer', 'cancel timer'])) {
      if (_timerRunning) _stopTimer();
      return;
    }
    // "set timer for 5 minutes" / "timer 90 seconds"
    final mTimer = RegExp(r'(?:set\s+)?timer\s+(?:for\s+)?(\d+)\s*(minute|minutes|min|second|seconds|sec)?')
        .firstMatch(text);
    if (mTimer != null) {
      final n = int.tryParse(mTimer.group(1)!) ?? 0;
      final unit = mTimer.group(2) ?? 'minute';
      final seconds = unit.startsWith('sec') ? n : n * 60;
      if (seconds > 0) _startTimer(seconds);
      return;
    }
  }

  bool _matches(String text, List<String> phrases) {
    for (final p in phrases) {
      if (text == p || text.contains(' $p ') || text.startsWith('$p ') || text.endsWith(' $p')) {
        return true;
      }
    }
    return false;
  }

  Future<void> _loadRecipe() async {
    final dao = ref.read(recipeDaoProvider);
    final recipe = await dao.getRecipeById(widget.recipeId);
    if (recipe == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final ingredients = await dao.getIngredientsForRecipe(widget.recipeId);
    // Section headers are display-only dividers, not steps to cook through.
    final steps = (await dao.getStepsForRecipe(widget.recipeId))
        .where((s) => s.notes != '__header__')
        .toList();

    // Load nutrition if available
    NutritionData? nutrition;
    if (recipe.nutritionJson != null) {
      try {
        nutrition = NutritionData.fromJson(jsonDecode(recipe.nutritionJson!));
      } catch (_) {}
    }

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
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
    Responsive.showAdaptiveSheet(
      context,
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

  void _finishCooking() {
    // TODO: Kitchen Buddy hidden for now
    // KitchenBuddyIntegration.onRecipeCooked(ref);
    Navigator.pop(context);
  }

  void _confirmExit() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading || _recipe == null) {
      return Scaffold(
        backgroundColor: context.appColors.surface,
        body: Center(child: CircularProgressIndicator(color: context.appColors.accent)),
      );
    }

    return Scaffold(
      backgroundColor: context.appColors.surface,
      // Voice control toggle floats above the bottom bar so the user
      // can find it without leaving the recipe view. Hidden on web.
      floatingActionButton: kIsWeb ? null : FloatingActionButton(
        backgroundColor: _voiceListening ? context.appColors.accent : context.appColors.surfaceHigh,
        foregroundColor: Colors.white,
        onPressed: _toggleVoice,
        tooltip: l10n.cookModeVoiceTitle,
        child: Icon(_voiceListening ? Icons.mic : Icons.mic_none),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
              onFontSize: () => showFontSizeSheet(context),
              onExit: _confirmExit,
            ),

            // Voice control "listening" hint banner
            if (_voiceListening)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: context.appColors.accent.withValues(alpha: 0.18),
                child: Row(
                  children: [
                    Icon(Icons.graphic_eq, size: 14, color: context.appColors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lastVoiceText.isNotEmpty
                            ? '"$_lastVoiceText"'
                            : l10n.cookModeVoiceListening,
                        style: TextStyle(color: context.appColors.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
                scaleFactor: widget.scaleFactor,
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
                  ? Center(child: Text(l10n.instructionsEmpty, style: TextStyle(color: context.appColors.textPrimary)))
                  : PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() => _currentStepIndex = index);
                  HapticFeedback.selectionClick();
                },
                itemBuilder: (context, index) => _StepView(
                  step: _steps[index],
                  stepNumber: index + 1,
                  totalSteps: _steps.length,
                  allIngredients: _ingredients,
                  allSteps: _steps,
                  stepIndex: index,
                  scaleFactor: widget.scaleFactor,
                ),
              ),
            ),

            // Bottom navigation
            _BottomBar(
              currentStep: _currentStepIndex,
              totalSteps: _steps.length,
              onPrevious: _currentStepIndex > 0 ? _previousStep : null,
              onNext: _currentStepIndex < _steps.length - 1 ? _nextStep : null,
              onTimer: _showTimerPicker,
              onFinish: _currentStepIndex == _steps.length - 1 ? _finishCooking : null,
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
  final VoidCallback onFontSize;
  final VoidCallback onExit;

  const _TopBar({
    required this.recipeName,
    required this.showIngredients,
    required this.hasNutrition,
    required this.showNutrition,
    required this.onToggleIngredients,
    required this.onToggleNutrition,
    required this.onFontSize,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: context.appColors.textPrimary),
            onPressed: onExit,
          ),
          Expanded(
            child: Text(
              recipeName,
              style: TextStyle(color: context.appColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
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
                color: showNutrition ? context.appColors.accent : context.appColors.textSecondary,
              ),
              onPressed: onToggleNutrition,
            ),
          // Font size
          IconButton(
            icon: Icon(Icons.text_fields, color: context.appColors.textPrimary, size: 20),
            onPressed: onFontSize,
          ),
          // Ingredients toggle
          IconButton(
            icon: Icon(
              showIngredients ? Icons.format_list_numbered : Icons.list,
              color: showIngredients ? context.appColors.accent : context.appColors.textSecondary,
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
      color: isLow ? context.appColors.destructive.withValues(alpha: 0.3) : context.appColors.surfaceRaised,
      child: Row(
        children: [
          Icon(Icons.timer, color: isLow ? context.appColors.destructive : context.appColors.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatTime(seconds), style: TextStyle(color: isLow ? context.appColors.destructive : context.appColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                LinearProgressIndicator(value: progress, backgroundColor: context.appColors.outline, valueColor: AlwaysStoppedAnimation(isLow ? context.appColors.destructive : context.appColors.accent)),
              ],
            ),
          ),
          IconButton(icon: Icon(Icons.stop, color: context.appColors.textPrimary), onPressed: onStop),
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

class _StepView extends ConsumerWidget {
  final Step step;
  final int stepNumber;
  final int totalSteps;
  final List<Ingredient> allIngredients;
  final List<Step> allSteps;
  final int stepIndex;
  final double scaleFactor;

  const _StepView({required this.step, required this.stepNumber, required this.totalSteps, required this.allIngredients, required this.allSteps, required this.stepIndex, this.scaleFactor = 1.0});

  /// Returns the ingredients to show for THIS step. Two-tier logic:
  ///   1. Direct match (NOT exclusive) — if the step's text names the
  ///      ingredient, it shows here, even if other steps name it too. An
  ///      ingredient genuinely used across several steps (water, salt, lime)
  ///      should appear in all of them.
  ///   2. Header grouping (exclusive) — an ingredient never named in ANY
  ///      step is attached to the single first step that references ITS
  ///      section header (e.g. "make the sauce" pulls in the unnamed sauce
  ///      items), so a whole section isn't dumped onto every step.
  /// Ingredients matched by neither stay off the per-step view (they're still
  /// in the full ingredient list).
  List<Ingredient> _matchIngredients() {
    final nonHeaders =
        allIngredients.where((i) => i.notes != '__header__').toList();
    if (nonHeaders.isEmpty || allSteps.isEmpty) return const [];

    // ingredientId → its section header name ('' if none).
    final sectionOf = <String, String>{};
    String currentSection = '';
    for (final ing in allIngredients) {
      if (ing.notes == '__header__') {
        currentSection = ing.name;
      } else {
        sectionOf[ing.id] = currentSection;
      }
    }

    final sections = _buildHeaderSections();

    // Header name → its stemmed keyword set (built once).
    final sectionKeywords = <String, Set<String>>{};
    for (final name in sections.keys) {
      final kws = name
          .toLowerCase()
          .replaceAll(
              RegExp(r'^(for\s+the\s+|para\s+(el|la|los|las)\s+|für\s+(den|die|das)\s+)',
                  caseSensitive: false),
              '')
          .split(RegExp(r'[\s,]+'))
          .where((w) => w.length > 2)
          .map(_stem)
          .toSet();
      if (kws.isNotEmpty) sectionKeywords[name] = kws;
    }

    // Stemmed token set per step (reused below).
    final stepTokens = allSteps.map((s) {
      final instr = s.instruction.toLowerCase();
      final toks = instr
          .split(RegExp(r'[\s,.\-—–;:!?()]+'))
          .where((t) => t.length > 2)
          .map(_stem)
          .toSet();
      return (instr, toks);
    }).toList();

    bool stepNamesSection(int si, Set<String> kws) {
      final (instr, toks) = stepTokens[si];
      return kws.any((kw) => toks.contains(kw) || instr.contains(kw));
    }

    // section → earliest step that names it (tier-2 fallback anchor).
    final sectionStep = <String, int>{};
    for (final entry in sectionKeywords.entries) {
      for (var si = 0; si < allSteps.length; si++) {
        if (stepNamesSection(si, entry.value)) {
          sectionStep[entry.key] = si;
          break;
        }
      }
    }

    // step → its component section, carried forward from the last step that
    // named one ("Make the pâte sucrée" tags that step and the ones after it,
    // until another component is named).
    final stepSection = List<String>.filled(allSteps.length, '');
    var current = '';
    for (var si = 0; si < allSteps.length; si++) {
      for (final entry in sectionKeywords.entries) {
        if (stepNamesSection(si, entry.value)) {
          current = entry.key;
          break;
        }
      }
      stepSection[si] = current;
    }
    final curSection = stepSection[stepIndex];

    final result = <Ingredient>[];
    for (final ing in nonHeaders) {
      // Tier 1 (non-exclusive): the ingredient is named in THIS step's text.
      if (_scoreIngredientForStep(ing, allSteps[stepIndex]) > 0) {
        // Cross-component guard: in a recipe with sections, don't pull in an
        // ingredient from a DIFFERENT component just because this step used a
        // generic word (sugar/butter/flour) that several components share.
        final ingSec = sectionOf[ing.id] ?? '';
        if (curSection.isNotEmpty && ingSec.isNotEmpty && ingSec != curSection) {
          continue;
        }
        result.add(ing);
        continue;
      }
      // Tier 2 (exclusive): only ingredients never named in ANY step fall
      // back to their section's single anchor step.
      final sec = sectionOf[ing.id] ?? '';
      if (sec.isEmpty || sectionStep[sec] != stepIndex) continue;
      final namedAnywhere =
          allSteps.any((s) => _scoreIngredientForStep(ing, s) > 0);
      if (!namedAnywhere) result.add(ing);
    }
    return result;
  }

  /// Score how well an ingredient matches a step (0 = no match). Matching is
  /// WHOLE-WORD (via the tokenized step text), not substring — that's what
  /// keeps "oil" from matching "boil", "ice" from matching "slice", etc.
  static int _scoreIngredientForStep(Ingredient ing, Step step) {
    // Collapse synonyms (green onion ↔ scallion, courgette ↔ zucchini, …) on
    // both sides so either name matches. canonicalizeFoodText also accent-folds
    // and lowercases.
    final instruction = canonicalizeFoodText(step.instruction);
    final name = canonicalizeFoodText(ing.name).trim();
    if (name.isEmpty) return 0;

    // Whole-word, stemmed token set of the step text.
    final instructionTokens = instruction
        .split(RegExp(r'[\s,.\-—–;:!?()/]+'))
        .where((t) => t.length > 2)
        .map(_stem)
        .toSet();

    // A multi-word ingredient appearing verbatim ("lime juice") is a strong,
    // low-false-positive signal. (A single short word as a substring is NOT —
    // hence no bare instruction.contains(name) for one-word names.)
    if (name.contains(' ') && instruction.contains(name)) return 10;

    // Meaningful name tokens (drop filler/common words), stemmed.
    final nameTokens = name
        .split(RegExp(r'[\s,/()]+'))
        .where((t) => t.length > 2 && !_commonWords.contains(t))
        .map(_stem)
        .where((t) => t.length > 2)
        .toList();
    if (nameTokens.isEmpty) return 0;

    // Whole-word matches only.
    final matched = nameTokens.where(instructionTokens.contains).length;
    if (matched == 0) return 0;

    // 1–2 token names: any whole-word match counts. 3+: need at least half.
    if (nameTokens.length <= 2) return matched * 3;
    return (matched / nameTokens.length) >= 0.5 ? matched * 3 : 0;
  }

  /// Build a map of header name → ingredients in that section.
  Map<String, List<Ingredient>> _buildHeaderSections() {
    final sections = <String, List<Ingredient>>{};
    String? currentHeader;

    for (final ing in allIngredients) {
      if (ing.notes == '__header__') {
        currentHeader = ing.name;
        sections[currentHeader] = [];
      } else if (currentHeader != null) {
        sections[currentHeader]!.add(ing);
      }
    }

    return sections;
  }

  /// Basic English/multilingual stemmer — strips common suffixes to normalize
  /// "tomatoes" → "tomato", "sliced" → "slic", "cooking" → "cook", etc.
  static String _stem(String word) {
    var w = word.toLowerCase().trim();
    if (w.length <= 3) return w;

    // Irregular plurals
    const irregulars = {
      'potatoes': 'potato', 'tomatoes': 'tomato', 'mangoes': 'mango',
      'halves': 'half', 'leaves': 'leaf', 'loaves': 'loaf',
      'knives': 'knife', 'selves': 'self', 'calves': 'calf',
    };
    if (irregulars.containsKey(w)) return irregulars[w]!;

    // -ies → -y (berries → berry, cherries → cherry)
    if (w.endsWith('ies') && w.length > 4) return '${w.substring(0, w.length - 3)}y';
    // -ves → -f (halves → half -- catch any not in irregulars)
    if (w.endsWith('ves') && w.length > 4) return '${w.substring(0, w.length - 3)}f';
    // -es (tomatoes → tomato, potatoes → potato, sauces → sauc)
    if (w.endsWith('es') && w.length > 4) {
      // Keep words ending in -ss (e.g., "bless") or -us
      if (!w.endsWith('ss') && !w.endsWith('us')) {
        final without = w.substring(0, w.length - 2);
        // If removing -es leaves a word ending in a consonant + 'o', keep it
        if (without.endsWith('o') || without.endsWith('c') ||
            without.endsWith('sh') || without.endsWith('ch') ||
            without.endsWith('x') || without.endsWith('z')) {
          return without;
        }
        // Otherwise just remove the -s
        return w.substring(0, w.length - 1);
      }
    }
    // -s (onions → onion, cloves → clove)
    if (w.endsWith('s') && !w.endsWith('ss') && w.length > 3) {
      return w.substring(0, w.length - 1);
    }

    return w;
  }

  static const _commonWords = {
    // English - articles/prepositions
    'the', 'and', 'for', 'with', 'cut', 'all', 'into', 'from', 'some',
    // English - sizes/amounts
    'large', 'small', 'medium', 'whole', 'half', 'cup', 'cups',
    'tablespoon', 'tablespoons', 'teaspoon', 'teaspoons',
    'pound', 'pounds', 'ounce', 'ounces', 'piece', 'pieces',
    // English - prep descriptors (these describe HOW the ingredient is prepped, not WHAT it is)
    'fresh', 'dried', 'frozen', 'canned', 'raw', 'cooked',
    'sliced', 'diced', 'chopped', 'minced', 'grated', 'shredded',
    'crushed', 'ground', 'peeled', 'seeded', 'deveined', 'trimmed',
    'boneless', 'skinless', 'optional', 'taste', 'needed',
    'purpose', 'divided', 'packed', 'lightly', 'finely', 'roughly',
    'thinly', 'thickly', 'softened', 'melted', 'room', 'temperature',
    // German
    'und', 'mit', 'für', 'alle', 'frisch', 'getrocknet',
    'groß', 'große', 'klein', 'kleine', 'mittel', 'ganz', 'halb',
    'tasse', 'tassen', 'stück', 'stücke', 'geschnitten', 'gewürfelt',
    'gehackt', 'fein', 'nach', 'geschmack', 'bedarf',
    // Spanish
    'con', 'para', 'todo', 'toda', 'fresco', 'fresca', 'seco', 'seca',
    'grande', 'pequeño', 'pequeña', 'mediano', 'mediana', 'entero', 'entera', 'medio', 'media',
    'taza', 'tazas', 'trozo', 'trozos', 'cortado', 'cortada', 'picado', 'picada',
    'opcional', 'gusto', 'necesario',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fontScale = ref.watch(recipeFontScaleProvider);
    final matched = _matchIngredients();
    // Ingredient names anchor bare-count scaling in the step text ("3 jalapeños").
    final ingredientNames = allIngredients
        .where((i) => i.notes != '__header__')
        .map((i) => i.name)
        .toList();
    final instruction = scaleFactor == 1.0
        ? step.instruction
        : scaleInstructionText(step.instruction, scaleFactor, ingredientNames);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            scaleFactor == 1.0
                ? '${l10n.stepNumber(stepNumber)} / $totalSteps'
                : '${l10n.stepNumber(stepNumber)} / $totalSteps  ·  ${scaleFactor}x',
            style: TextStyle(color: context.appColors.textSecondary, fontSize: 16),
          ),

          // Matched ingredients chips (scrollable, max 40% of screen)
          if (matched.isNotEmpty) ...[
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.35, maxWidth: 760),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.appColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.appColors.outline),
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: matched.map((ing) {
                      final label = scaledIngredientLabel(
                          ing.amount, ing.unit, ing.name, scaleFactor);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.appColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: context.appColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: context.appColors.accent,
                            fontSize: 13 * fontScale,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],

          // Instruction text
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      instruction,
                      style: TextStyle(color: context.appColors.textPrimary, fontSize: 28 * fontScale, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientsView extends ConsumerWidget {
  final List<Ingredient> ingredients;
  final double scaleFactor;
  final Set<String> checkedIds;
  final Function(String) onToggle;

  const _IngredientsView({required this.ingredients, this.scaleFactor = 1.0, required this.checkedIds, required this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontScale = ref.watch(recipeFontScaleProvider);
    return Responsive.constrainWidth(
      context,
      maxWidth: 700,
      child: ListView.builder(
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
              decoration: BoxDecoration(color: context.appColors.surfaceRaised.withValues(alpha: isChecked ? 0.5 : 1.0), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(isChecked ? Icons.check_circle : Icons.circle_outlined, color: isChecked ? context.appColors.accent : context.appColors.textTertiary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ing.notes == '__header__'
                          ? ing.name
                          : scaledIngredientLabel(ing.amount, ing.unit, ing.name, scaleFactor),
                      style: TextStyle(color: isChecked ? context.appColors.textTertiary : context.appColors.textPrimary, fontSize: 18 * fontScale, decoration: isChecked ? TextDecoration.lineThrough : null),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(icon: const Icon(Icons.arrow_back, size: 32), color: onPrevious != null ? context.appColors.textPrimary : context.appColors.textTertiary, onPressed: onPrevious),
            IconButton(icon: const Icon(Icons.timer, size: 32), color: context.appColors.textPrimary, onPressed: onTimer),
            if (onFinish != null)
              FilledButton.icon(onPressed: onFinish, icon: const Icon(Icons.check), label: Text(l10n.cookingFinish), style: FilledButton.styleFrom(backgroundColor: context.appColors.accent, foregroundColor: context.appColors.onAccent, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)))
            else
              IconButton(icon: const Icon(Icons.arrow_forward, size: 32), color: onNext != null ? context.appColors.textPrimary : context.appColors.textTertiary, onPressed: onNext),
          ],
        ),
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