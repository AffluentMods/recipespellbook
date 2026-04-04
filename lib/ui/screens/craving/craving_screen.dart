import 'dart:math';

import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/database_provider.dart';
import '../../../services/craving_service.dart';
import '../../../data/course_category_data.dart';
import '../../widgets/recipe_image.dart';

// ═══════════════════════════════════════════════════════════════
// "WHAT ARE YOU CRAVING?" — FULL-SCREEN DISCOVERY FLOW
//
// 4-page PageView:
//   0: Mood / vibe tiles (multi-select)
//   1: Category refinement chips (multi-select)
//   2: Source selection (single-select)
//   3: Results with expandable recipe cards
// ═══════════════════════════════════════════════════════════════

const _amber = Color(0xFFE8A860);

class CravingScreen extends ConsumerStatefulWidget {
  const CravingScreen({super.key});

  @override
  ConsumerState<CravingScreen> createState() => _CravingScreenState();
}

class _CravingScreenState extends ConsumerState<CravingScreen> {
  late PageController _pageController;
  int _currentStep = 0;

  // Step 1
  final Set<CravingMood> _selectedMoods = {};

  // Step 2
  final Set<String> _selectedCategories = {};

  // Step 3
  CravingSource? _selectedSource;

  // Results
  List<CravingResult> _fullPool = [];
  List<CravingResult> _results = [];
  bool _isLoading = false;
  String? _expandedResultId;
  final Set<int> _visibleItems = {};
  int _poolOffset = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _fetchResults() async {
    setState(() => _isLoading = true);

    final service = CravingService(ref.read(recipeDaoProvider));
    final pool = await service.findRecipes(
      moods: _selectedMoods,
      selectedCategories: _selectedCategories,
      source: _selectedSource ?? CravingSource.both,
    );

    if (!mounted) return;
    setState(() {
      _fullPool = pool;
      _poolOffset = 0;
      _takeNextPage();
      _isLoading = false;
    });
    _triggerStaggerIn();
  }

  void _takeNextPage() {
    final end = (_poolOffset + 10).clamp(0, _fullPool.length);
    _results = _fullPool.sublist(_poolOffset, end);
    _poolOffset = end;
    _expandedResultId = null;
    _visibleItems.clear();
  }

  void _reshuffle() {
    if (_poolOffset >= _fullPool.length) {
      // Pool exhausted — re-shuffle and restart
      _fullPool.shuffle(Random());
      _poolOffset = 0;
    }
    setState(() {
      _takeNextPage();
    });
    _triggerStaggerIn();
  }

  void _triggerStaggerIn() {
    _visibleItems.clear();
    for (var i = 0; i < _results.length; i++) {
      Future.delayed(Duration(milliseconds: i * 40), () {
        if (mounted) setState(() => _visibleItems.add(i));
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titles = ['What are you feeling?', 'Anything more specific?', 'Where should we look?', "Here's what we found"];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentStep]),
        leading: _currentStep == 0
            ? IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
            : IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => _goToStep(_currentStep - 1)),
        bottom: _currentStep < 3
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 3,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: const AlwaysStoppedAnimation<Color>(_amber),
                ),
              )
            : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildMoodStep(),
          _buildCategoryStep(),
          _buildSourceStep(),
          _buildResultsPage(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 1: MOOD / VIBE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMoodStep() {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            'Pick one or more',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.8,
              children: CravingMood.values.map((mood) {
                final isSelected = _selectedMoods.contains(mood);
                return _MoodTile(
                  emoji: mood.emoji,
                  label: mood.label,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      isSelected ? _selectedMoods.remove(mood) : _selectedMoods.add(mood);
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
        _StepBottomBar(
          showSkip: true,
          onSkip: () {
            _selectedMoods.clear();
            _goToStep(1);
          },
          onNext: () => _goToStep(1),
          nextLabel: 'Next',
          nextEnabled: true,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 2: CATEGORY REFINEMENT
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCategoryStep() {
    final theme = Theme.of(context);
    final options = getCategoryOptionsForMoods(_selectedMoods);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            'Optional — skip if you\'re open to anything',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((opt) {
                final isSelected = _selectedCategories.contains(opt.id);
                return FilterChip(
                  label: Text(opt.label),
                  selected: isSelected,
                  onSelected: (v) {
                    setState(() {
                      v ? _selectedCategories.add(opt.id) : _selectedCategories.remove(opt.id);
                    });
                  },
                  selectedColor: _amber.withValues(alpha: 0.15),
                  checkmarkColor: _amber,
                  side: BorderSide(
                    color: isSelected ? _amber : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
          ),
        ),
        _StepBottomBar(
          showSkip: true,
          showBack: true,
          onSkip: () {
            _selectedCategories.clear();
            _goToStep(2);
          },
          onBack: () => _goToStep(0),
          onNext: () => _goToStep(2),
          nextLabel: 'Next',
          nextEnabled: true,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 3: SOURCE SELECTION
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSourceStep() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: CravingSource.values.map((source) {
                final isSelected = _selectedSource == source;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SourceCard(
                    emoji: source.emoji,
                    title: source.label,
                    subtitle: source.subtitle,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedSource = source),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        _StepBottomBar(
          showBack: true,
          onBack: () => _goToStep(1),
          onNext: () async {
            _goToStep(3);
            await _fetchResults();
          },
          nextLabel: 'Find recipes',
          nextEnabled: _selectedSource != null,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RESULTS PAGE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildResultsPage() {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _amber));
    }

    if (_results.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      children: [
        // Filter summary + reshuffle
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._selectedMoods.map((m) => _FilterChip(label: m.label)),
                      ..._selectedCategories.map((c) {
                        final course = CourseData.getById(c);
                        final cat = CategoryData.getById(c);
                        return _FilterChip(label: course?.name ?? cat?.name ?? c);
                      }),
                      if (_selectedSource != null) _FilterChip(label: _selectedSource!.label.split(' ').first),
                    ],
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _reshuffle,
                icon: const Icon(Icons.shuffle, size: 18),
                label: const Text('Reshuffle'),
                style: TextButton.styleFrom(foregroundColor: _amber),
              ),
            ],
          ),
        ),

        // Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Found ${_fullPool.length} recipes matching your vibe',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final result = _results[index];
              final isExpanded = _expandedResultId == result.id;
              final isVisible = _visibleItems.contains(index);

              return AnimatedOpacity(
                opacity: isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: AnimatedSlide(
                  offset: isVisible ? Offset.zero : const Offset(0, 0.05),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: _ResultCard(
                    result: result,
                    isExpanded: isExpanded,
                    onToggle: () {
                      setState(() {
                        _expandedResultId = isExpanded ? null : result.id;
                      });
                    },
                    onCookThis: () => _navigateToRecipe(result),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'Nothing found for these filters',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Try broader options or reshuffle',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _goToStep(0),
              icon: const Icon(Icons.tune),
              label: const Text('Adjust filters'),
              style: FilledButton.styleFrom(backgroundColor: _amber),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRecipe(CravingResult result) {
    if (result.isLocal) {
      context.push('/recipe/${result.id}');
    } else if (result.cookbookId != null) {
      context.push('/community/${result.cookbookId}');
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════

class _MoodTile extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodTile({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isSelected
                ? _amber.withValues(alpha: 0.08)
                : theme.colorScheme.surfaceContainer,
            border: Border.all(
              color: isSelected ? _amber : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? _amber : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SourceCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? _amber.withValues(alpha: 0.08)
                : theme.colorScheme.surfaceContainer,
            border: Border.all(
              color: isSelected ? _amber : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? _amber : null,
                    )),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    )),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: _amber),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final CravingResult result;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onCookThis;

  const _ResultCard({
    required this.result,
    required this.isExpanded,
    required this.onToggle,
    required this.onCookThis,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = result.totalTimeMinutes > 0 ? '${result.totalTimeMinutes}m' : null;
    final servStr = result.servings;
    final meta = [if (timeStr != null) timeStr, if (servStr != null) '$servStr srv'].join(' · ');
    final course = result.courseId != null ? CourseData.getById(result.courseId!) : null;
    final category = result.categoryId != null ? CategoryData.getById(result.categoryId!) : null;
    final tags = [if (course != null) course.name, if (category != null) category.name];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Collapsed header
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: RecipeImage.thumbnail(
                        imagePath: result.imagePath,
                        recipeId: result.id,
                        width: 56,
                        height: 56,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.title,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (meta.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(meta, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                        ],
                        if (tags.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            children: tags.map((t) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(t, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
                            )).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!result.isLocal) ...[
                    Icon(Icons.public, size: 14, color: theme.colorScheme.outline),
                    const SizedBox(width: 4),
                  ],
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more, color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: _buildExpandedContent(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, ThemeData theme) {
    final desc = result.description ??
        (result.stepTexts.isNotEmpty ? result.stepTexts.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.1)),

        // Description
        if (desc != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              desc,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        // Ingredients
        if (result.ingredientNames.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text('Ingredients', style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold, color: theme.colorScheme.primary,
            )),
          ),
          ...result.ingredientNames.map((name) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.fiber_manual_record, size: 6, color: theme.colorScheme.outline),
                const SizedBox(width: 8),
                Expanded(child: Text(name, style: theme.textTheme.bodySmall)),
              ],
            ),
          )),
          if (result.totalIngredients > result.ingredientNames.length)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '+ ${result.totalIngredients - result.ingredientNames.length} more',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _amber, fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],

        // Instructions
        if (result.stepTexts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text('Instructions', style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold, color: theme.colorScheme.primary,
            )),
          ),
          ...result.stepTexts.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 20, child: Text('${entry.key + 1}.', style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600, color: theme.colorScheme.primary,
                ))),
                Expanded(
                  child: Text(entry.value, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          )),
          if (result.totalSteps > result.stepTexts.length)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '+ ${result.totalSteps - result.stepTexts.length} more steps',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _amber, fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],

        // Action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onCookThis,
                  style: FilledButton.styleFrom(backgroundColor: _amber),
                  child: const Text('Cook this!'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: _amber, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StepBottomBar extends StatelessWidget {
  final bool showSkip;
  final bool showBack;
  final VoidCallback? onSkip;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool nextEnabled;

  const _StepBottomBar({
    this.showSkip = false,
    this.showBack = false,
    this.onSkip,
    this.onBack,
    this.onNext,
    required this.nextLabel,
    required this.nextEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSkip)
              TextButton(
                onPressed: onSkip,
                child: const Text('Skip this step →'),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (showBack) ...[
                  TextButton(
                    onPressed: onBack,
                    child: const Text('Back'),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: nextEnabled ? onNext : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: _amber,
                    ),
                    child: Text(nextLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
