import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:recipespellbook/data/nutrition_data.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';

import '../../../ui/widgets/nutrition_widgets.dart';
import '../../ui/widgets/font_size_control.dart';
import '../../utils/responsive_utils.dart';
// TODO: Kitchen Buddy hidden for now
// import 'kitchen_buddy/kitchen_buddy_integration.dart';

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
    final steps = await dao.getStepsForRecipe(widget.recipeId);

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
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      // Voice control toggle floats above the bottom bar so the user
      // can find it without leaving the recipe view. Hidden on web.
      floatingActionButton: kIsWeb ? null : FloatingActionButton(
        backgroundColor: _voiceListening ? const Color(0xFFE8A860) : Colors.black54,
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
                color: const Color(0xFFE8A860).withValues(alpha: 0.18),
                child: Row(
                  children: [
                    const Icon(Icons.graphic_eq, size: 14, color: Color(0xFFE8A860)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lastVoiceText.isNotEmpty
                            ? '"$_lastVoiceText"'
                            : l10n.cookModeVoiceListening,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
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
          // Font size
          IconButton(
            icon: const Icon(Icons.text_fields, color: Colors.white, size: 20),
            onPressed: onFontSize,
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
      color: isLow ? Colors.red.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.timer, color: isLow ? Colors.red : Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatTime(seconds), style: TextStyle(color: isLow ? Colors.red : Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                LinearProgressIndicator(value: progress, backgroundColor: Colors.white.withValues(alpha: 0.2), valueColor: AlwaysStoppedAnimation(isLow ? Colors.red : Colors.green)),
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

class _StepView extends ConsumerWidget {
  final Step step;
  final int stepNumber;
  final int totalSteps;
  final List<Ingredient> allIngredients;
  final List<Step> allSteps;
  final int stepIndex;

  const _StepView({required this.step, required this.stepNumber, required this.totalSteps, required this.allIngredients, required this.allSteps, required this.stepIndex});

  /// Smart ingredient matching: assigns each ingredient to its BEST step,
  /// so duplicates like "eggs" appearing 3x get distributed correctly.
  List<Ingredient> _matchIngredients() {
    // Step 1: Score every ingredient against every step
    final scores = <String, List<int>>{}; // ingredientId → [score per step]
    final nonHeaders = allIngredients.where((i) => i.notes != '__header__').toList();

    for (final ing in nonHeaders) {
      final ingScores = <int>[];
      for (final s in allSteps) {
        ingScores.add(_scoreIngredientForStep(ing, s));
      }
      scores[ing.id] = ingScores;
    }

    // Step 2: Assign each ingredient to the step where it scores highest.
    // If tied, assign to the earliest step (ingredients are usually used in order).
    // An ingredient appears in a step if:
    //   a) This step is the best match for it, OR
    //   b) It scores > 0 here AND it's the only step that mentions it
    final result = <Ingredient>[];
    for (final ing in nonHeaders) {
      final ingScores = scores[ing.id]!;
      final myScore = ingScores[stepIndex];
      if (myScore == 0) continue;

      final maxScore = ingScores.reduce((a, b) => a > b ? a : b);
      if (myScore < maxScore) continue; // A different step is a better match

      // If tied with an earlier step, only show in the earliest
      final firstBest = ingScores.indexOf(maxScore);
      if (firstBest != stepIndex) continue;

      result.add(ing);
    }

    // Step 3: Header-based context boost — if step mentions a section name,
    // pull in any unassigned ingredients from that section.
    final headerSections = _buildHeaderSections();
    final instruction = step.instruction.toLowerCase();
    final instructionTokens = instruction
        .split(RegExp(r'[\s,.\-—–;:!?()]+'))
        .where((t) => t.length > 2)
        .map(_stem)
        .toSet();

    for (final section in headerSections.entries) {
      final headerKeywords = section.key.toLowerCase()
          .replaceAll(RegExp(r'^(for\s+the\s+|para\s+(el|la|los|las)\s+|für\s+(den|die|das)\s+)', caseSensitive: false), '')
          .split(RegExp(r'[\s,]+'))
          .where((w) => w.length > 2)
          .map(_stem)
          .toSet();

      if (headerKeywords.any((kw) => instructionTokens.contains(kw) || instruction.contains(kw))) {
        for (final ing in section.value) {
          if (!result.contains(ing)) result.add(ing);
        }
      }
    }

    return result;
  }

  /// Score how well an ingredient matches a step (0 = no match).
  static int _scoreIngredientForStep(Ingredient ing, Step step) {
    final instruction = step.instruction.toLowerCase();
    final name = ing.name.toLowerCase().trim();
    if (name.isEmpty) return 0;

    final instructionTokens = instruction
        .split(RegExp(r'[\s,.\-—–;:!?()]+'))
        .where((t) => t.length > 2)
        .map(_stem)
        .toSet();

    int score = 0;

    // 1. Exact substring match (strongest signal)
    if (instruction.contains(name)) return 10;

    // 2. Stemmed full-name match
    final stemmedName = _stem(name);
    if (stemmedName.length > 3 && instruction.contains(stemmedName)) return 8;

    // 3. Token-based matching
    final nameTokens = name
        .split(RegExp(r'[\s,/()]+'))
        .where((t) => t.length > 2)
        .where((t) => !_commonWords.contains(t))
        .map(_stem)
        .where((t) => t.length > 2)
        .toList();

    if (nameTokens.isEmpty) return 0;

    for (final token in nameTokens) {
      if (instruction.contains(token) || instructionTokens.contains(token)) {
        score += 3;
      }
    }

    // Require meaningful match ratio
    final ratio = score / (nameTokens.length * 3);
    if (nameTokens.length == 1 && score >= 3) return score;
    if (nameTokens.length == 2 && score >= 3) return score;
    if (nameTokens.length >= 3 && ratio >= 0.5) return score;

    return 0;
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text('${l10n.stepNumber(stepNumber)} / $totalSteps', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16)),

          // Matched ingredients chips (scrollable, max 40% of screen)
          if (matched.isNotEmpty) ...[
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.35),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: matched.map((ing) {
                      final label = [
                        if (ing.amount != null) ing.amount!,
                        if (ing.unit != null) ing.unit!,
                        ing.name,
                      ].join(' ');
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8A860).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE8A860).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: const Color(0xFFE8A860),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    step.instruction,
                    style: TextStyle(color: Colors.white, fontSize: 28 * fontScale, height: 1.4),
                    textAlign: TextAlign.center,
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
  final Set<String> checkedIds;
  final Function(String) onToggle;

  const _IngredientsView({required this.ingredients, required this.checkedIds, required this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontScale = ref.watch(recipeFontScaleProvider);
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
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: isChecked ? 0.05 : 0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(isChecked ? Icons.check_circle : Icons.circle_outlined, color: isChecked ? Colors.green : Colors.white.withValues(alpha: 0.5)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    [if (ing.amount != null) ing.amount!, if (ing.unit != null) ing.unit!, ing.name].join(' '),
                    style: TextStyle(color: isChecked ? Colors.white.withValues(alpha: 0.5) : Colors.white, fontSize: 18 * fontScale, decoration: isChecked ? TextDecoration.lineThrough : null),
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
          IconButton(icon: const Icon(Icons.arrow_back, size: 32), color: onPrevious != null ? Colors.white : Colors.white.withValues(alpha: 0.3), onPressed: onPrevious),
          IconButton(icon: const Icon(Icons.timer, size: 32), color: Colors.white, onPressed: onTimer),
          if (onFinish != null)
            FilledButton.icon(onPressed: onFinish, icon: const Icon(Icons.check), label: Text(l10n.cookingFinish), style: FilledButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)))
          else
            IconButton(icon: const Icon(Icons.arrow_forward, size: 32), color: onNext != null ? Colors.white : Colors.white.withValues(alpha: 0.3), onPressed: onNext),
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