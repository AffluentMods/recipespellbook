import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../services/onboarding_service.dart';
import '../../widgets/app_snackbar.dart';

// ════════════════════════════════════════════
//  BOOK INTRO SCREEN
// ════════════════════════════════════════════
//
// Two-phase first-time experience:
//  1. Video phase: plays book_intro.mp4 (~8s) — book opens, flips, zooms to blank page
//  2. Recipe viewer: interactive page-flip through starter recipes on parchment
//
// Skip button (top-right) during video.
// After video → crossfades to recipe book viewer.

class BookIntroScreen extends ConsumerStatefulWidget {
  const BookIntroScreen({super.key});

  @override
  ConsumerState<BookIntroScreen> createState() => _BookIntroScreenState();
}

class _BookIntroScreenState extends ConsumerState<BookIntroScreen>
    with TickerProviderStateMixin {
  // ── Video ──
  late VideoPlayerController _videoController;
  bool _videoReady = false;
  bool _videoComplete = false;
  bool _showSkip = false;

  // ── Crossfade ──
  late AnimationController _crossfadeController;
  late Animation<double> _crossfade;

  // ── Recipe viewer ──
  late PageController _pageController;
  late AnimationController _autoFlipController;
  Timer? _autoFlipTimer;
  int _currentPage = 0;
  bool _loading = false;

  // Starter recipes for the viewer
  static const _recipes = [
    _BookRecipe(
      title: 'Korean Ground Beef Bowls',
      description: 'Savory-sweet gochujang glaze over rice with crisp veggies and a fried egg.',
      ingredients: ['1 lb ground beef', '3 tbsp soy sauce', '2 tbsp gochujang', '1 tbsp sesame oil', '2 cloves garlic', '4 cups steamed rice', '2 green onions', 'Sesame seeds'],
    ),
    _BookRecipe(
      title: 'Butter Chicken',
      description: 'Creamy tomato-spiced sauce enveloping tender marinated chicken.',
      ingredients: ['2 lbs chicken thighs', '1 cup yogurt', '2 tbsp garam masala', '14 oz tomato sauce', '1 cup heavy cream', '3 tbsp butter', '1 onion, diced', 'Fresh cilantro'],
    ),
    _BookRecipe(
      title: 'Spaghetti alla Carbonara',
      description: 'Silky egg-and-cheese sauce clinging to perfectly cooked pasta.',
      ingredients: ['1 lb spaghetti', '6 oz guanciale', '4 egg yolks', '1 cup Pecorino Romano', 'Black pepper', '2 whole eggs', 'Pasta water'],
    ),
    _BookRecipe(
      title: 'Mexican Street Tacos',
      description: 'Quick, punchy flavors on warm soft corn tortillas.',
      ingredients: ['1 lb flank steak', '12 corn tortillas', '1 white onion', 'Fresh cilantro', '3 limes', '2 tbsp chili powder', '1 tsp cumin', 'Salsa verde'],
    ),
    _BookRecipe(
      title: 'Creamy Tuscan Shrimp',
      description: 'Garlicky sun-dried tomato cream sauce with plump shrimp.',
      ingredients: ['1 lb large shrimp', '4 cloves garlic', '1/2 cup sun-dried tomatoes', '1 cup heavy cream', '2 cups spinach', '1/2 cup Parmesan', '2 tbsp olive oil', 'Italian seasoning'],
    ),
    _BookRecipe(
      title: 'Lomo Saltado',
      description: 'Peruvian stir-fried beef with onions, tomatoes, and crispy fries.',
      ingredients: ['1.5 lbs sirloin', '2 red onions', '3 tomatoes', '2 tbsp soy sauce', '2 tbsp vinegar', '1 aji amarillo', 'French fries', 'Fresh parsley'],
    ),
    _BookRecipe(
      title: 'Chicken Potato Gnocchi Soup',
      description: 'A hearty, creamy soup with pillowy gnocchi and tender chicken.',
      ingredients: ['2 chicken breasts', '1 lb potato gnocchi', '4 cups chicken broth', '1 cup heavy cream', '2 cups spinach', '3 cloves garlic', '1 onion', 'Thyme'],
    ),
    _BookRecipe(
      title: 'Stuffed Hungarian Wax Peppers',
      description: 'Spicy peppers filled with a savory meat and rice mixture.',
      ingredients: ['8 Hungarian wax peppers', '1 lb ground pork', '1 cup cooked rice', '1 egg', '14 oz tomato sauce', '1 onion', '2 cloves garlic', 'Paprika'],
    ),
    _BookRecipe(
      title: 'Eggroll Bowl',
      description: 'All the flavors of an eggroll, deconstructed in a bowl.',
      ingredients: ['1 lb ground pork', '1 bag coleslaw mix', '3 tbsp soy sauce', '1 tbsp sesame oil', '2 cloves garlic', '1 tbsp ginger', 'Green onions', 'Sriracha'],
    ),
    _BookRecipe(
      title: 'White Pizza',
      description: 'Garlic cream sauce, mozzarella, ricotta, and fresh herbs.',
      ingredients: ['1 pizza dough ball', '1/2 cup ricotta', '2 cups mozzarella', '3 cloves garlic', '2 tbsp olive oil', 'White pizza sauce', 'Fresh basil', 'Red pepper flakes'],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _crossfadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _crossfade = CurvedAnimation(parent: _crossfadeController, curve: Curves.easeInOut);

    _pageController = PageController();

    _autoFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _initVideo();

    // Show skip button after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_videoComplete) setState(() => _showSkip = true);
    });
  }

  Future<void> _initVideo() async {
    // Skip video entirely on web — browser codec support is unreliable
    if (kIsWeb) {
      if (mounted) _skipToViewer();
      return;
    }

    _videoController = VideoPlayerController.asset('assets/animations/book_intro.mp4');

    try {
      await _videoController.initialize();
      if (!mounted) return;
      setState(() => _videoReady = true);
      _videoController.play();

      // Listen for video completion
      _videoController.addListener(_onVideoUpdate);
    } catch (e) {
      // If video fails to load, skip directly to recipe viewer
      debugPrint('[BookIntro] Video failed: $e');
      if (mounted) _skipToViewer();
    }
  }

  void _onVideoUpdate() {
    if (!mounted) return;
    final pos = _videoController.value.position;
    final dur = _videoController.value.duration;

    if (dur.inMilliseconds > 0 && pos >= dur && !_videoComplete) {
      _skipToViewer();
    }
  }

  void _skipToViewer() {
    if (_videoComplete) return;
    setState(() => _videoComplete = true);
    // Skip video pause on web — controller was never initialized there
    if (!kIsWeb) {
      _videoController.pause();
    }
    _crossfadeController.forward();

    // Start auto-flip after a short delay
    _autoFlipTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _nextPage();
    });
  }

  void _nextPage() {
    _currentPage = (_currentPage + 1) % _recipes.length;
    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _videoController.removeListener(_onVideoUpdate);
      _videoController.dispose();
    }
    _crossfadeController.dispose();
    _pageController.dispose();
    _autoFlipController.dispose();
    _autoFlipTimer?.cancel();
    super.dispose();
  }

  // ════ Onboarding actions ════

  Future<void> _addRecipes() async {
    setState(() => _loading = true);
    _autoFlipTimer?.cancel();
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
    _autoFlipTimer?.cancel();
    await OnboardingService.declineDefaultRecipes();
    if (mounted) Navigator.of(context).pop();
  }

  // ════ Build ════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1206),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Loading indicator while video loads ──
          if (!_videoReady && !_videoComplete)
            const Center(child: CircularProgressIndicator(color: Color(0xFFDAA520))),

          // ── Video layer ──
          if (_videoReady)
            AnimatedBuilder(
              animation: _crossfade,
              builder: (_, __) => Opacity(
                opacity: 1.0 - _crossfade.value,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              ),
            ),

          // ── Recipe viewer layer (fades in) ──
          if (_videoComplete)
            AnimatedBuilder(
              animation: _crossfade,
              builder: (_, __) => Opacity(
                opacity: _crossfade.value,
                child: _RecipeBookViewer(
                  recipes: _recipes,
                  pageController: _pageController,
                  currentPage: _currentPage,
                  loading: _loading,
                  onAddRecipes: _addRecipes,
                  onStartEmpty: _startEmpty,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page % _recipes.length);
                    // Reset auto-flip timer on manual interaction
                    _autoFlipTimer?.cancel();
                    _autoFlipTimer = Timer.periodic(const Duration(seconds: 4), (_) {
                      if (!mounted) return;
                      _nextPage();
                    });
                  },
                ),
              ),
            ),

          // ── Skip button (video phase only) ──
          if (!_videoComplete && _showSkip)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: AnimatedOpacity(
                opacity: _showSkip ? 0.7 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: _skipToViewer,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.onboardingSkip,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.skip_next, color: Colors.white70, size: 18),
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
}

// ════════════════════════════════════════════
//  RECIPE BOOK VIEWER
// ════════════════════════════════════════════

class _RecipeBookViewer extends StatelessWidget {
  final List<_BookRecipe> recipes;
  final PageController pageController;
  final int currentPage;
  final bool loading;
  final VoidCallback onAddRecipes;
  final VoidCallback onStartEmpty;
  final ValueChanged<int> onPageChanged;

  const _RecipeBookViewer({
    required this.recipes,
    required this.pageController,
    required this.currentPage,
    required this.loading,
    required this.onAddRecipes,
    required this.onStartEmpty,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        // Parchment background
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5E6C8), Color(0xFFEDD9B5)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Text(
                l10n.onboardingSpellbookAwaits,
                style: GoogleFonts.uncialAntiqua(
                  fontSize: 22,
                  color: const Color(0xFF3E2723),
                ),
              ),
            ),

            // Recipe pages
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: pageController,
                    onPageChanged: onPageChanged,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index % recipes.length];
                      return _RecipePage(
                        recipe: recipe,
                        pageNumber: (index % recipes.length) + 1,
                      );
                    },
                  ),

                  // Page flip hint arrows
                  Positioned(
                    left: 8,
                    top: 0, bottom: 0,
                    child: Center(
                      child: Icon(
                        Icons.chevron_left,
                        size: 28,
                        color: const Color(0xFF8B6914).withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 0, bottom: 0,
                    child: Center(
                      child: Icon(
                        Icons.chevron_right,
                        size: 28,
                        color: const Color(0xFF8B6914).withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: loading ? null : onAddRecipes,
                      icon: loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.auto_fix_high_rounded, size: 20),
                      label: Text(
                        loading ? l10n.onboardingSummoning : l10n.onboardingAddStarter,
                        style: const TextStyle(fontSize: 15),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF5D4037),
                        foregroundColor: const Color(0xFFDAA520),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: loading ? null : onStartEmpty,
                    child: Text(
                      l10n.onboardingBlankSpellbook,
                      style: const TextStyle(color: Color(0xFF5D4037), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  SINGLE RECIPE PAGE
// ════════════════════════════════════════════

class _RecipePage extends StatelessWidget {
  final _BookRecipe recipe;
  final int pageNumber;

  const _RecipePage({required this.recipe, required this.pageNumber});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
      child: Stack(
        children: [
          // Page content
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Decorative top rule
                Center(
                  child: Container(
                    width: 80,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        const Color(0xFFDAA520).withValues(alpha: 0.0),
                        const Color(0xFFDAA520).withValues(alpha: 0.6),
                        const Color(0xFFDAA520).withValues(alpha: 0.0),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Center(
                  child: Text(
                    recipe.title,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3E2723),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Center(
                  child: Text(
                    recipe.description,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 15,
                      color: const Color(0xFF5D4037).withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // Divider
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 30, height: 1, color: const Color(0xFFDAA520).withValues(alpha: 0.4)),
                      const SizedBox(width: 8),
                      Text('~', style: GoogleFonts.cormorantGaramond(fontSize: 16, color: const Color(0xFFDAA520).withValues(alpha: 0.6))),
                      const SizedBox(width: 8),
                      Container(width: 30, height: 1, color: const Color(0xFFDAA520).withValues(alpha: 0.4)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Ingredients header
                Text(
                  'Ingredients',
                  style: GoogleFonts.uncialAntiqua(
                    fontSize: 16,
                    color: const Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 8),

                // Ingredients list
                ...recipe.ingredients.map((ing) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '  \u2022  ',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 14,
                          color: const Color(0xFF8B6914),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          ing,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 15,
                            color: const Color(0xFF3E2723),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

                // Steps trailing off...
                const SizedBox(height: 16),
                Text(
                  'Preparation',
                  style: GoogleFonts.uncialAntiqua(
                    fontSize: 16,
                    color: const Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 8),
                // Fading text to suggest there's more
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF3E2723),
                      const Color(0xFF3E2723).withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 1.0],
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: Text(
                    'Begin by preparing all ingredients. Season generously and let the flavors develop as you work through each step of this beloved recipe...',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 14,
                      color: const Color(0xFF5D4037),
                      height: 1.5,
                    ),
                  ),
                ),
                // Clearance for Roman numeral page number
                const SizedBox(height: 28),
              ],
            ),
          ),

          // Roman numeral page number — bottom right
          Positioned(
            bottom: 8,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF5E6C8).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _toRoman(pageNumber),
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 16,
                  color: const Color(0xFF8B6914).withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Convert integer to Roman numeral.
  static String _toRoman(int num) {
    if (num <= 0) return '';
    const values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    const symbols = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];
    final sb = StringBuffer();
    var n = num;
    for (var i = 0; i < values.length; i++) {
      while (n >= values[i]) {
        sb.write(symbols[i]);
        n -= values[i];
      }
    }
    return sb.toString();
  }
}

// ════════════════════════════════════════════
//  DATA CLASS
// ════════════════════════════════════════════

class _BookRecipe {
  final String title;
  final String description;
  final List<String> ingredients;

  const _BookRecipe({
    required this.title,
    required this.description,
    required this.ingredients,
  });
}
