import 'dart:math';

import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../services/craving_service.dart';
import '../../../services/community_service.dart';
import '../../../data/course_category_data.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/recipe_image.dart';
import '../../widgets/community_image.dart';

// ═══════════════════════════════════════════════════════════════
// "WHAT ARE YOU CRAVING?" — FULL-SCREEN DISCOVERY FLOW
//
// 4-page PageView:
//   0: Mood / vibe tiles (multi-select)
//   1: Category refinement chips (multi-select)
//   2: Source selection (single-select)
//   3: Results with expandable recipe cards
// ═══════════════════════════════════════════════════════════════

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

  String _moodLabel(AppLocalizations l10n, CravingMood mood) {
    switch (mood) {
      case CravingMood.sweet:
        return l10n.cravingMoodSweet;
      case CravingMood.savory:
        return l10n.cravingMoodSavory;
      case CravingMood.light:
        return l10n.cravingMoodLight;
      case CravingMood.filling:
        return l10n.cravingMoodFilling;
      case CravingMood.quick:
        return l10n.cravingMoodQuick;
      case CravingMood.special:
        return l10n.cravingMoodSpecial;
    }
  }

  ({String title, String subtitle}) _sourceLabels(AppLocalizations l10n, CravingSource source) {
    switch (source) {
      case CravingSource.myRecipes:
        return (title: l10n.cravingSourceMyRecipesTitle, subtitle: l10n.cravingSourceMyRecipesSubtitle);
      case CravingSource.community:
        return (title: l10n.cravingSourceCommunityTitle, subtitle: l10n.cravingSourceCommunitySubtitle);
      case CravingSource.both:
        return (title: l10n.cravingSourceBothTitle, subtitle: l10n.cravingSourceBothSubtitle);
    }
  }

  String _categoryLabel(AppLocalizations l10n, String labelKey) {
    switch (labelKey) {
      case 'dessert_label': return l10n.cravingCatDessert;
      case 'pastry': return l10n.cravingCatPastry;
      case 'baked_goods': return l10n.cravingCatBakedGoods;
      case 'breakfast_label': return l10n.cravingCatBreakfast;
      case 'dinner': return l10n.cravingCatDinner;
      case 'lunch': return l10n.cravingCatLunch;
      case 'appetizer_label': return l10n.cravingCatAppetizer;
      case 'soup_label': return l10n.cravingCatSoup;
      case 'sauce_label': return l10n.cravingCatSauce;
      case 'salad_label': return l10n.cravingCatSalad;
      case 'snack_label': return l10n.cravingCatSnack;
      case 'main_dish': return l10n.cravingCatMainDish;
      case 'pasta_label': return l10n.cravingCatPasta;
      case 'rice_label': return l10n.cravingCatRice;
      case 'casserole_label': return l10n.cravingCatCasserole;
      case 'under20': return l10n.cravingCatUnder20;
      case 'under30': return l10n.cravingCatUnder30;
      case 'five_ings': return l10n.cravingCat5Ings;
      case 'impressive': return l10n.cravingCatImpressive;
      case 'crowd_pleaser': return l10n.cravingCatCrowdPleaser;
      case 'favorites_label': return l10n.cravingCatFavorites;
      default: return labelKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final titles = [l10n.cravingStep1Title, l10n.cravingStep2Title, l10n.cravingStep3Title, l10n.cravingResultsTitle];

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
                  valueColor: AlwaysStoppedAnimation<Color>(context.appColors.accent),
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
    final l10n = AppLocalizations.of(context)!;
    final count = _selectedMoods.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.cravingPickOneOrMore,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  count == 0 ? l10n.cravingMoodHint : l10n.cravingCountSelected(count),
                  key: ValueKey('count_$count'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: count > 0 ? context.appColors.accent : theme.colorScheme.outline.withValues(alpha: 0.6),
                    fontWeight: count > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: CravingMood.values.map((mood) {
                final isSelected = _selectedMoods.contains(mood);
                return _MoodTile(
                  emoji: mood.emoji,
                  label: _moodLabel(l10n, mood),
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
          nextLabel: l10n.cravingNext,
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
    final l10n = AppLocalizations.of(context)!;
    final options = getCategoryOptionsForMoods(_selectedMoods);
    final count = _selectedCategories.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.cravingCategoryHint,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  count == 0 ? l10n.cravingCategoryNarrowHint : l10n.cravingCountSelected(count),
                  key: ValueKey('cat_count_$count'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: count > 0 ? context.appColors.accent : theme.colorScheme.outline.withValues(alpha: 0.6),
                    fontWeight: count > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: options.map((opt) {
                final isSelected = _selectedCategories.contains(opt.id);
                return _CategoryChip(
                  emoji: opt.emoji,
                  label: _categoryLabel(l10n, opt.labelKey),
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      isSelected ? _selectedCategories.remove(opt.id) : _selectedCategories.add(opt.id);
                    });
                  },
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
          nextLabel: l10n.cravingNext,
          nextEnabled: true,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 3: SOURCE SELECTION
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSourceStep() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: CravingSource.values.map((source) {
                final isSelected = _selectedSource == source;
                final labels = _sourceLabels(l10n, source);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SourceCard(
                    emoji: source.emoji,
                    title: labels.title,
                    subtitle: labels.subtitle,
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
          nextLabel: l10n.cravingFindRecipes,
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
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: context.appColors.accent));
    }

    if (_results.isEmpty) {
      return _buildEmptyState(theme, l10n);
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
                      ..._selectedMoods.map((m) => _FilterChip(label: _moodLabel(l10n, m))),
                      ..._selectedCategories.map((c) {
                        final course = CourseData.getById(c);
                        final cat = CategoryData.getById(c);
                        return _FilterChip(label: course?.name ?? cat?.name ?? c);
                      }),
                      if (_selectedSource != null) _FilterChip(label: _sourceLabels(l10n, _selectedSource!).title.split(' ').first),
                    ],
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _reshuffle,
                icon: const Icon(Icons.shuffle, size: 18),
                label: Text(l10n.cravingReshuffle),
                style: TextButton.styleFrom(foregroundColor: context.appColors.accent),
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
              l10n.cravingFoundRecipes(_fullPool.length),
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

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              l10n.cravingNothingFound,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cravingTryBroader,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _goToStep(0),
              icon: const Icon(Icons.tune),
              label: Text(l10n.cravingAdjustFilters),
              style: FilledButton.styleFrom(backgroundColor: context.appColors.accent, foregroundColor: context.appColors.onAccent),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRecipe(CravingResult result) {
    if (result.isLocal) {
      context.push('/recipe/${result.id}');
      return;
    }
    final src = result.communitySource;
    if (src != null && result.cookbookId != null) {
      // Navigate to the specific recipe in the community cookbook
      final communityRecipe = CommunityRecipe(
        title: src.title,
        description: src.description,
        imagePath: src.imagePath,
        servings: src.servings,
        prepTimeMinutes: src.prepTimeMinutes,
        cookTimeMinutes: src.cookTimeMinutes,
        sourceUrl: null,
        courseId: src.courseId,
        categoryId: null,
        rating: null,
        notes: null,
        nutritionJson: null,
        ingredients: src.ingredients,
        steps: src.steps,
        tags: src.tags,
      );
      context.push(
        '/community/${result.cookbookId}/recipe/0',
        extra: communityRecipe,
      );
    } else if (result.cookbookId != null) {
      // Fallback — open cookbook detail
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
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.appColors.accent.withValues(alpha: 0.14),
                      context.appColors.accent.withValues(alpha: 0.04),
                    ],
                  )
                : null,
            color: isSelected ? null : theme.colorScheme.surfaceContainer,
            border: Border.all(
              color: isSelected ? context.appColors.accent : theme.colorScheme.outline.withValues(alpha: 0.08),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [BoxShadow(color: context.appColors.accent.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))]
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? context.appColors.accent : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(color: context.appColors.accent, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.black, size: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? context.appColors.accent.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainer,
          border: Border.all(
            color: isSelected ? context.appColors.accent : theme.colorScheme.outline.withValues(alpha: 0.12),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? context.appColors.accent : theme.colorScheme.onSurface,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_circle, size: 16, color: context.appColors.accent),
            ],
          ],
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
                ? context.appColors.accent.withValues(alpha: 0.08)
                : theme.colorScheme.surfaceContainer,
            border: Border.all(
              color: isSelected ? context.appColors.accent : Colors.transparent,
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
                      color: isSelected ? context.appColors.accent : null,
                    )),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    )),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: context.appColors.accent),
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

  Widget _buildThumbnail({required double size}) {
    if (!result.isLocal && result.cookbookId != null) {
      return CommunityImage(
        publicationId: result.cookbookId!,
        imagePath: result.imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }
    return RecipeImage.thumbnail(
      imagePath: result.imagePath,
      recipeId: result.id,
      width: size,
      height: size,
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    if (!result.isLocal && result.cookbookId != null) {
      return CommunityImage(
        publicationId: result.cookbookId!,
        imagePath: result.imagePath,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        memCacheHeight: 360,
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: RecipeImage.medium(
        imagePath: result.imagePath,
        recipeId: result.id,
        height: 180,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = result.totalTimeMinutes > 0 ? '${result.totalTimeMinutes} min' : null;
    final servStr = result.servings;
    final course = result.courseId != null ? CourseData.getById(result.courseId!) : null;
    final category = result.categoryId != null ? CategoryData.getById(result.categoryId!) : null;
    final tags = <({String emoji, String name})>[
      if (course != null) (emoji: course.emoji, name: course.name),
      if (category != null) (emoji: category.emoji, name: category.name),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded ? context.appColors.accent.withValues(alpha: 0.5) : theme.colorScheme.outline.withValues(alpha: 0.08),
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: isExpanded
            ? [BoxShadow(color: context.appColors.accent.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            // Collapsed header
            InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Thumbnail with community badge overlay
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 84,
                            height: 84,
                            child: _buildThumbnail(size: 84),
                          ),
                        ),
                        if (!result.isLocal)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.public, size: 12, color: context.appColors.accent),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // Title, meta, tags
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            result.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (timeStr != null || servStr != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (timeStr != null) ...[
                                  Icon(Icons.schedule, size: 12, color: theme.colorScheme.outline),
                                  const SizedBox(width: 3),
                                  Text(timeStr, style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline, fontSize: 12,
                                  )),
                                ],
                                if (timeStr != null && servStr != null) ...[
                                  const SizedBox(width: 10),
                                  Container(width: 3, height: 3, decoration: BoxDecoration(
                                    color: theme.colorScheme.outline, shape: BoxShape.circle,
                                  )),
                                  const SizedBox(width: 10),
                                ],
                                if (servStr != null) ...[
                                  Icon(Icons.people_outline, size: 12, color: theme.colorScheme.outline),
                                  const SizedBox(width: 3),
                                  Text(servStr, style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline, fontSize: 12,
                                  )),
                                ],
                              ],
                            ),
                          ],
                          if (tags.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 5,
                              runSpacing: 4,
                              children: tags.map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(t.emoji, style: const TextStyle(fontSize: 10)),
                                    const SizedBox(width: 4),
                                    Text(
                                      t.name,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.expand_more_rounded, color: theme.colorScheme.outline, size: 24),
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
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final desc = result.description ??
        (result.stepTexts.isNotEmpty ? result.stepTexts.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero image for expanded view
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _buildHeroImage(context),
          ),
        ),

        // Description
        if (desc != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              desc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        // Ingredients
        if (result.ingredientNames.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: context.appColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.restaurant_menu, size: 13, color: context.appColors.accent),
                ),
                const SizedBox(width: 8),
                Text(l10n.tabIngredients, style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
                const SizedBox(width: 6),
                Text('(${result.totalIngredients})', style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                )),
              ],
            ),
          ),
          ...result.ingredientNames.map((name) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7, right: 10, left: 4),
                  child: Container(
                    width: 5, height: 5,
                    decoration: BoxDecoration(
                      color: context.appColors.accent.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(child: Text(name, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4))),
              ],
            ),
          )),
          if (result.totalIngredients > result.ingredientNames.length)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 6, 16, 0),
              child: Text(
                '+ ${result.totalIngredients - result.ingredientNames.length} more',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.appColors.accent, fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],

        // Instructions
        if (result.stepTexts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: context.appColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.format_list_numbered, size: 13, color: context.appColors.accent),
                ),
                const SizedBox(width: 8),
                Text(l10n.tabInstructions, style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
              ],
            ),
          ),
          ...result.stepTexts.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22, height: 22,
                  margin: const EdgeInsets.only(top: 1, right: 10),
                  decoration: BoxDecoration(
                    color: context.appColors.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('${entry.key + 1}', style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700, color: context.appColors.accent,
                    )),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
          if (result.totalSteps > result.stepTexts.length)
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 6, 16, 0),
              child: Text(
                '+ ${result.totalSteps - result.stepTexts.length} more steps',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.appColors.accent, fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],

        // Action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 14),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onCookThis,
              icon: Icon(result.isLocal ? Icons.restaurant_rounded : Icons.visibility_rounded, size: 18),
              label: Text(
                result.isLocal ? l10n.cravingCookThis : l10n.cravingViewRecipe,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: context.appColors.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
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
        color: context.appColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: context.appColors.accent, fontWeight: FontWeight.w600),
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
    final l10n = AppLocalizations.of(context)!;
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
                child: Text(l10n.cravingSkipStep),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (showBack) ...[
                  TextButton(
                    onPressed: onBack,
                    child: Text(l10n.cravingBack),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: nextEnabled ? onNext : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: context.appColors.accent,
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
