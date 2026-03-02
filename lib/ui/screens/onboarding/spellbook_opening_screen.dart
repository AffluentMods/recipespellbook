// lib/ui/screens/onboarding/spellbook_opening_screen.dart
// Animated first-time experience: a spellbook opens to reveal recipes.
//
// 4 phases:
//  1. Candle Phase (0-2s): black → candle flame fades in, warm glow expands
//  2. Book Entrance (2-4s): book slides up from below
//  3. Book Opening (4-6s): cover rotates open with perspective transform
//  4. Recipe Pages (6s+): interactive PageView on parchment, ending with onboarding buttons

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../services/onboarding_service.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/rpg/candle_flame_painter.dart';

// ============ SPELLBOOK OPENING SCREEN ============

class SpellbookOpeningScreen extends ConsumerStatefulWidget {
  const SpellbookOpeningScreen({super.key});

  @override
  ConsumerState<SpellbookOpeningScreen> createState() =>
      _SpellbookOpeningScreenState();
}

class _SpellbookOpeningScreenState
    extends ConsumerState<SpellbookOpeningScreen>
    with TickerProviderStateMixin {
  // Main sequencer
  late AnimationController _sequenceController;

  // Candle phase (0.0 - 0.3 of sequence)
  late Animation<double> _candleGlow;
  late Animation<double> _candleOpacity;

  // Book entrance (0.3 - 0.55)
  late Animation<double> _bookSlide;
  late Animation<double> _bookOpacity;

  // Book opening (0.55 - 0.8)
  late Animation<double> _coverRotation;

  // Pages reveal (0.8 - 1.0)
  late Animation<double> _pagesOpacity;

  // Particle system
  late AnimationController _particleController;
  late CandleParticleSystem _particleSystem;

  // State
  bool _pagesReady = false;
  bool _loading = false;
  final _pageController = PageController();

  // Starter recipe previews
  static const _starterRecipes = [
    _RecipePreview('Korean Beef Bowls', '🇰🇷', 'A savory-sweet gochujang glaze over rice with crisp veggies.'),
    _RecipePreview('Butter Chicken', '🇮🇳', 'Creamy tomato-spiced sauce enveloping tender marinated chicken.'),
    _RecipePreview('Carbonara', '🇮🇹', 'Silky egg-and-cheese sauce clinging to perfectly cooked pasta.'),
    _RecipePreview('Street Tacos', '🌮', 'Quick, punchy flavors on soft corn tortillas.'),
    _RecipePreview('Tuscan Shrimp', '🍤', 'Garlicky, sun-dried tomato cream with plump shrimp.'),
  ];

  @override
  void initState() {
    super.initState();

    // Main sequence: 6 seconds for the intro, then stops
    _sequenceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );

    // Phase 1: candle glow (0% - 30%)
    _candleGlow = Tween<double>(begin: 0.0, end: 120.0).animate(
      CurvedAnimation(
        parent: _sequenceController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _candleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sequenceController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    // Phase 2: book slides up (30% - 55%)
    _bookSlide = Tween<double>(begin: 300.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _sequenceController,
        curve: const Interval(0.3, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _bookOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sequenceController,
        curve: const Interval(0.3, 0.45, curve: Curves.easeOut),
      ),
    );

    // Phase 3: cover opens (55% - 80%)
    _coverRotation = Tween<double>(begin: 0.0, end: -pi * 0.85).animate(
      CurvedAnimation(
        parent: _sequenceController,
        curve: const Interval(0.55, 0.8, curve: Curves.easeInOutCubic),
      ),
    );

    // Phase 4: pages appear (80% - 100%)
    _pagesOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sequenceController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    // Particle controller for continuous flame animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();
    _particleSystem = CandleParticleSystem(targetCount: 18);
    _particleController.addListener(_onParticleTick);

    // Start the sequence
    _sequenceController.forward();
    _sequenceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _pagesReady = true);
      }
    });
  }

  void _onParticleTick() {
    _particleSystem.update(0.016);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _sequenceController.dispose();
    _particleController.removeListener(_onParticleTick);
    _particleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ============ ONBOARDING ACTIONS ============

  Future<void> _addRecipes() async {
    setState(() => _loading = true);
    try {
      final db = ref.read(databaseProvider);
      final count = await OnboardingService.seedDefaultRecipes(db);
      await OnboardingService.completeOnboarding();
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, AppLocalizations.of(context)!.starterRecipesAdded(count));
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.error(context, AppLocalizations.of(context)!.somethingWentWrong(e.toString()));
      }
    }
  }

  Future<void> _startEmpty() async {
    await OnboardingService.declineDefaultRecipes();
    if (mounted) Navigator.of(context).pop();
  }

  // ============ BUILD ============

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([_sequenceController, _particleController]),
        builder: (context, _) {
          return Stack(
            children: [
              // Phase 1: Candle flame
              if (_candleOpacity.value > 0.01)
                Positioned.fill(
                  child: Opacity(
                    opacity: _candleOpacity.value,
                    child: CustomPaint(
                      painter: CandleFlamePainter(
                        particles: _particleSystem.particles,
                        glowRadius: _candleGlow.value,
                        glowOpacity: _candleOpacity.value,
                      ),
                    ),
                  ),
                ),

              // Phase 2+3: Book
              if (_bookOpacity.value > 0.01)
                Center(
                  child: Transform.translate(
                    offset: Offset(0, _bookSlide.value),
                    child: Opacity(
                      opacity: _bookOpacity.value,
                      child: _buildBook(size),
                    ),
                  ),
                ),

              // Phase 4: Pages content
              if (_pagesReady)
                Positioned.fill(
                  child: Opacity(
                    opacity: _pagesOpacity.value.clamp(0.0, 1.0),
                    child: _buildPagesContent(size),
                  ),
                ),

              // Skip button (visible after 1 second)
              if (!_pagesReady)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 16,
                  child: AnimatedOpacity(
                    opacity: _sequenceController.value > 0.15 ? 0.6 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: TextButton(
                      onPressed: () {
                        _sequenceController.value = 1.0;
                        setState(() => _pagesReady = true);
                      },
                      child: Text(AppLocalizations.of(context)!.onboardingSkip, style: const TextStyle(color: Colors.white54)),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ============ BOOK WIDGET ============

  Widget _buildBook(Size screenSize) {
    final bookWidth = screenSize.width * 0.7;
    final bookHeight = bookWidth * 1.35;

    return SizedBox(
      width: bookWidth,
      height: bookHeight,
      child: Stack(
        children: [
          // Book interior (parchment) - visible as cover opens
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5E6C8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD4A574), width: 2),
            ),
            child: Center(
              child: Opacity(
                opacity: (_coverRotation.value.abs() / (pi * 0.85)).clamp(0.0, 1.0),
                child: Text(
                  '✨',
                  style: TextStyle(
                    fontSize: 48,
                    color: Colors.amber.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),

          // Book cover (rotates open from left edge)
          Align(
            alignment: Alignment.centerLeft,
            child: Transform(
              alignment: Alignment.centerLeft,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateY(_coverRotation.value),
              child: Container(
                width: bookWidth,
                height: bookHeight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDAA520), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(5, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📖', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        'Recipe\nSpellbook',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.uncialAntiqua(
                          fontSize: 28,
                          color: const Color(0xFFDAA520),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ PAGES CONTENT ============

  Widget _buildPagesContent(Size screenSize) {
    final theme = Theme.of(context);

    return Container(
      color: const Color(0xFFF5E6C8), // Parchment background
      child: SafeArea(
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                AppLocalizations.of(context)!.onboardingSpellbookAwaits,
                style: GoogleFonts.uncialAntiqua(
                  fontSize: 24,
                  color: const Color(0xFF3E2723),
                ),
              ),
            ),

            // Recipe page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _starterRecipes.length + 1, // +1 for final page
                itemBuilder: (context, index) {
                  if (index < _starterRecipes.length) {
                    return _buildRecipePage(_starterRecipes[index]);
                  }
                  return _buildFinalPage(theme);
                },
              ),
            ),

            // Page dots
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PageDots(
                controller: _pageController,
                count: _starterRecipes.length + 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipePage(_RecipePreview recipe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(recipe.emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            recipe.title,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3E2723),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 2,
            color: const Color(0xFFDAA520).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            recipe.description,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 18,
              color: const Color(0xFF5D4037),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFinalPage(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✨', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingYourSpellbookAwaits,
            style: GoogleFonts.uncialAntiqua(
              fontSize: 22,
              color: const Color(0xFF3E2723),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingDescription,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 16,
              color: const Color(0xFF5D4037),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Add recipes button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _addRecipes,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_fix_high_rounded, size: 20),
              label: Text(
                _loading ? l10n.onboardingSummoning : l10n.onboardingAddStarter,
                style: const TextStyle(fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF5D4037),
                foregroundColor: const Color(0xFFDAA520),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Start empty button
          TextButton(
            onPressed: _loading ? null : _startEmpty,
            child: Text(
              l10n.onboardingBlankSpellbook,
              style: const TextStyle(color: Color(0xFF5D4037), fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ HELPER CLASSES ============

class _RecipePreview {
  final String title;
  final String emoji;
  final String description;

  const _RecipePreview(this.title, this.emoji, this.description);
}

/// Animated page indicator dots for the recipe PageView.
class _PageDots extends StatelessWidget {
  final PageController controller;
  final int count;

  const _PageDots({required this.controller, required this.count});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final page = controller.hasClients
            ? (controller.page ?? 0.0).round()
            : 0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (i) {
            final isActive = i == page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFDAA520)
                    : const Color(0xFFDAA520).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}
