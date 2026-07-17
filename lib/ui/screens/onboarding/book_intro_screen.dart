import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../utils/platform_utils.dart' show isMobile;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../services/onboarding_service.dart';
import '../../../theme/recipe_tile_generator.dart';
import '../../widgets/app_snackbar.dart';

// ════════════════════════════════════════════
//  FIXED PARCHMENT PALETTE
// ════════════════════════════════════════════
// This onboarding page is deliberately its OWN palette (aged-paper look), NOT
// the app's AppColors theme roles. It is a fixed themed illustration — the
// book-opening video zooms into this page, so it must look identical in every
// theme. A later theming sweep must not "fix" these into semantic colors.
const _parchCenter = Color(0xFFF3E7C8); // warm paper, page center
const _parchMid = Color(0xFFEDDCB4);
const _parchEdge = Color(0xFFDEC99A); // aged paper, page edge
const _ink = Color(0xFF3A2410); // primary body ink
const _inkSoft = Color(0xFF5D4037); // secondary ink (descriptions, link)
const _rust = Color(0xFF8E4A21); // section headers, drop cap
const _gold = Color(0xFFDAA520); // rules, frames, button accents
const _keyline = Color(0x59785528); // inner printed page border
const _vignette = Color(0x595A3C19); // worn-edge darkening
const _coverBrown = Color(0xFF4A2E1C); // leather-cover brown (primary button)

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

  // Starter recipes for the viewer. Titles, ingredients, and preparation
  // openings mirror the REAL seeded recipes in data/default_recipes.dart so
  // the preview is trustworthy — never invent filler here.
  static const _recipes = [
    _BookRecipe(
      title: 'Korean Ground Beef Bowls',
      description: 'Savory-sweet gochujang glaze over rice with crisp veggies and a fried egg.',
      asset: 'assets/images/default_recipes/korean_beef_bowls.png',
      ingredients: ['1.5 lbs ground beef', '4 garlic cloves, minced', 'Fresh ginger, grated', '1/4 cup soy sauce', '2 tbsp brown sugar', '1 tbsp gochujang', '1 tbsp sesame oil', '3 cups cooked rice'],
      preparation: 'Heat a skillet over medium-high heat. Add the ground beef and cook until browned, breaking it apart as it cooks. Add garlic and ginger, then stir in soy sauce, brown sugar, gochujang, vinegar, and sesame oil. Simmer until the glaze turns thick and glossy, about 3 to 5 minutes...',
    ),
    _BookRecipe(
      title: 'Butter Chicken',
      description: 'Creamy tomato-spiced sauce enveloping tender marinated chicken.',
      asset: 'assets/images/default_recipes/butter_chicken.png',
      ingredients: ['2 lbs chicken thighs', '1 cup yogurt', '2 tsp garam masala', 'Ginger-garlic paste', '14 oz tomato sauce', '1 cup heavy cream', '3 tbsp butter', 'Fresh cilantro'],
      preparation: 'Whisk the yogurt with lemon juice, ginger-garlic paste, garam masala, cumin, turmeric, and chili powder. Coat the chicken and refrigerate at least 2 hours. Grill or pan-sear the marinated pieces until charred outside but not quite cooked through, then set aside for the sauce...',
    ),
    _BookRecipe(
      title: 'Spaghetti alla Carbonara',
      description: 'Silky egg-and-cheese sauce clinging to perfectly cooked pasta.',
      asset: 'assets/images/default_recipes/carbonara.png',
      ingredients: ['1 lb spaghetti', '6 oz guanciale', '4 egg yolks', '2 whole eggs', '1 cup Pecorino Romano', 'Black pepper', 'Reserved pasta water', 'Kosher salt'],
      preparation: 'Start the guanciale in a cold skillet over medium-low heat and let the fat render slowly, 8 to 10 minutes, until golden and crisp. Cook the spaghetti one minute shy of al dente in well-salted water, reserving a cup of the starchy pasta water before draining...',
    ),
    _BookRecipe(
      title: 'Mexican Street Tacos',
      description: 'Quick, punchy flavors on warm soft corn tortillas.',
      asset: 'assets/images/default_recipes/street_tacos.png',
      ingredients: ['1 lb flank steak', '12 corn tortillas', '2 tbsp soy sauce', '3 limes', '2 tbsp chili powder', '1 tsp cumin', '1 white onion', 'Fresh cilantro'],
      preparation: 'Whisk together soy sauce, lime juice, oil, garlic, chili powder, cumin, and oregano. Toss the steak in the marinade and let it rest at least an hour. Sear in a hot skillet until browned and the sauce has reduced to a glaze, then pile onto warm tortillas...',
    ),
    _BookRecipe(
      title: 'Creamy Tuscan Shrimp',
      description: 'Shrimp and crisp bacon in a Parmesan cream with blistered tomatoes and spinach.',
      asset: 'assets/images/default_recipes/tuscan_shrimp.png',
      ingredients: ['1.5 lbs raw shrimp', '4 slices bacon, diced', '1 pint grape tomatoes', '4 garlic cloves', '1 cup heavy cream', '4 oz Parmesan', '5 oz baby spinach', 'Fresh basil'],
      preparation: 'Cook the diced bacon in a large skillet until crisp, then set it aside, leaving the drippings. Blister the halved tomatoes with Italian seasoning and red pepper flakes, add the garlic and shrimp, and sear just until pink, 1 to 2 minutes per side...',
    ),
    _BookRecipe(
      title: 'Lomo Saltado',
      description: 'Peruvian stir-fried beef with onions, tomatoes, and crispy fries.',
      asset: 'assets/images/default_recipes/lomo_saltado.png',
      ingredients: ['1.5 lbs sirloin', '2 red onions', '3 tomatoes', '2 tbsp soy sauce', '2 tbsp vinegar', '1 aji amarillo', 'French fries', 'Fresh parsley'],
      preparation: 'Sear the steak in a very hot pan in small batches so it browns rather than steams. Season with salt and pepper and set aside. Stir-fry the onion wedges for a minute, add garlic and aji amarillo, then bring it all back together with soy sauce and vinegar...',
    ),
    _BookRecipe(
      title: 'Chicken Potato Gnocchi Soup',
      description: 'A hearty, creamy soup with pillowy gnocchi and tender chicken.',
      asset: 'assets/images/default_recipes/chicken_gnocchi.png',
      ingredients: ['2 chicken breasts', '1 lb potato gnocchi', '4 cups chicken broth', '1 cup heavy cream', '2 cups spinach', '3 cloves garlic', '1 onion', 'Fresh thyme'],
      preparation: 'Melt butter with olive oil in a soup pot. Cook the celery until softened, 5 to 7 minutes, then add the garlic. Stir in the carrots and seasonings, pour in the broth, and bring everything to a gentle simmer for the chicken and gnocchi...',
    ),
    _BookRecipe(
      title: 'Stuffed Hungarian Wax Peppers',
      description: 'Blistered wax peppers with a sausage and cheese filling, drizzled in chive oil.',
      asset: 'assets/images/default_recipes/stuffed_peppers.png',
      ingredients: ['12 Hungarian wax peppers', '1 lb Italian sausage', '8 oz cream cheese', '1 cup sharp cheddar', '1 cup fresh chives', '3/4 cup canola oil', 'Red chili flakes', 'Fresh ciabatta'],
      preparation: 'Blend the chives with canola oil and a pinch of salt until smooth and vibrant green. Brown the sausage, breaking it into crumbles, and let it cool before mixing with cream cheese, cheddar, and chili flakes. Slit each pepper, scrape out the seeds, and stuff generously...',
    ),
    _BookRecipe(
      title: 'Eggroll Bowl',
      description: 'All the flavor of an egg roll, no wrapper needed.',
      asset: 'assets/images/default_recipes/eggroll_bowl.png',
      ingredients: ['2 lbs ground turkey', '2 bags coleslaw mix', 'Mushrooms, diced', '1 tbsp hoisin sauce', '1 tbsp sesame oil', 'Soy sauce', 'Sriracha mayo', 'Sesame seeds'],
      preparation: 'Sear the ground turkey in an even layer without stirring so it caramelizes, then break it up with the diced mushrooms and cook through. Season, add the coleslaw mix with soy, hoisin, and oyster sauce, and toss 5 to 7 minutes until the cabbage turns glossy...',
    ),
    _BookRecipe(
      title: 'White Pizza',
      description: 'Garlic cream sauce, mozzarella, ricotta, and fresh herbs.',
      asset: 'assets/images/default_recipes/white_pizza.png',
      ingredients: ['1 pizza dough ball', '1/2 cup ricotta', '2 cups mozzarella', '3 cloves garlic', '2 tbsp olive oil', 'White pizza sauce', 'Fresh basil', 'Red pepper flakes'],
      preparation: 'Preheat the oven to 525°F. Mix softened butter with minced garlic for the base. Stretch the dough into a round, brush it with the garlic butter, then layer on the white sauce, mozzarella, and dollops of ricotta before it goes into the heat...',
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
    // Only play video on mobile — skip on web and desktop
    if (!isMobile) {
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
    // Only pause video on mobile — controller was never initialized elsewhere
    if (isMobile) {
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
    if (isMobile) {
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
      // Aged-paper base: warm center falling off to darker, worn edges.
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.35,
          colors: [_parchCenter, _parchMid, _parchEdge],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Paper grain speckle (~5% opacity).
          const IgnorePointer(
            child: CustomPaint(painter: _ParchmentGrainPainter()),
          ),
          // Edge vignette — the page's worn, shadowed border.
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.35,
                  colors: [Color(0x00000000), Color(0x00000000), _vignette],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),
          // Inner printed keyline, like a book's page border.
          const IgnorePointer(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(color: _keyline, width: 1.5),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              // Width-capped content column: on wide screens (web/desktop)
              // the page composition stays book-like instead of full-bleed.
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    // Eyebrow — small tracked line; the recipe title is the hero.
                    Padding(
                      padding: const EdgeInsets.only(top: 22, bottom: 2),
                      child: Text(
                        l10n.onboardingSpellbookAwaits.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.uncialAntiqua(
                          fontSize: 12.5,
                          letterSpacing: 3.0,
                          color: _rust,
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
                            left: 0,
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
                            right: 0,
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

                    // Footer band: slightly darker paper seats the actions on
                    // the page instead of floating generic form controls.
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                      decoration: BoxDecoration(
                        color: const Color(0x0F5A3C19),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x33785528), width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Primary: width-capped ink/gold button, never full-bleed.
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 260),
                            child: SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: loading ? null : onAddRecipes,
                                icon: loading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: _gold),
                                      )
                                    : const Icon(Icons.auto_fix_high_rounded, size: 19),
                                label: Text(
                                  loading ? l10n.onboardingSummoning : l10n.onboardingAddStarter,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _coverBrown,
                                  foregroundColor: _gold,
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: _gold.withValues(alpha: 0.65), width: 1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Secondary: underlined ink text link.
                          TextButton(
                            onPressed: loading ? null : onStartEmpty,
                            style: TextButton.styleFrom(foregroundColor: _inkSoft),
                            child: Text(
                              l10n.onboardingBlankSpellbook,
                              style: const TextStyle(
                                color: _inkSoft,
                                fontSize: 14.5,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0x8C5D4037),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
//  SINGLE RECIPE PAGE
// ════════════════════════════════════════════

class _RecipePage extends StatelessWidget {
  final _BookRecipe recipe;
  final int pageNumber;

  const _RecipePage({required this.recipe, required this.pageNumber});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Short phones get a tighter plate + type scale so the page never clips
    // the preparation opening.
    final compact = MediaQuery.of(context).size.height < 700;
    final plateH = compact ? 84.0 : 130.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
      child: Stack(
        children: [
          // Page content. Clamping physics: on tall screens the page fits and
          // never scrolls; on short phones the tail (fading preparation text)
          // stays reachable instead of silently clipping.
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: compact ? 4 : 10),

                // Framed dish engraving — the page's focal anchor.
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gold.withValues(alpha: 0.75), width: 1.6),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33402A10),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: _gold.withValues(alpha: 0.45), width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: plateH * 1.35,
                          height: plateH,
                          child: Image.asset(
                            recipe.asset,
                            fit: BoxFit.cover,
                            // No illustration → deterministic generated tile.
                            errorBuilder: (_, __, ___) =>
                                _GeneratedTileFallback(name: recipe.title),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: compact ? 10 : 14),

                // Title — the hero of the page.
                Text(
                  recipe.title,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: compact ? 24 : 27,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3E2723),
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),

                // Description
                Text(
                  recipe.description,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 14.5,
                    color: _inkSoft,
                    fontStyle: FontStyle.italic,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: compact ? 9 : 13),

                const _FlourishRule(),
                SizedBox(height: compact ? 9 : 13),

                // Ingredients \u2014 two columns, like a set recipe page.
                _SectionHeader(l10n.ingredientsTitle),
                const SizedBox(height: 8),
                _IngredientColumns(
                  items: recipe.ingredients,
                  fontSize: compact ? 13.5 : 14.5,
                ),

                SizedBox(height: compact ? 9 : 13),
                const _FlourishRule(),
                SizedBox(height: compact ? 9 : 13),

                _SectionHeader(l10n.preparationTitle),
                const SizedBox(height: 8),
                // Real opening steps with an illuminated initial, fading out
                // to suggest the rest of the page.
                _PreparationOpening(
                  text: recipe.preparation,
                  fontSize: compact ? 13.5 : 14.5,
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
                color: _parchCenter.withValues(alpha: 0.85),
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
  final String asset;
  final List<String> ingredients;
  final String preparation;

  const _BookRecipe({
    required this.title,
    required this.description,
    required this.asset,
    required this.ingredients,
    required this.preparation,
  });
}

// ════════════════════════════════════════════
//  PARCHMENT PAGE PIECES
// ════════════════════════════════════════════

/// Small, tracked, uppercase section header in the display face.
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      textAlign: TextAlign.center,
      style: GoogleFonts.uncialAntiqua(
        fontSize: 13,
        letterSpacing: 2.4,
        color: _rust,
      ),
    );
  }
}

/// The little horizontal rule with a center glyph, reused between sections.
class _FlourishRule extends StatelessWidget {
  const _FlourishRule();

  @override
  Widget build(BuildContext context) {
    Widget line() => Container(
          width: 34,
          height: 1,
          color: _gold.withValues(alpha: 0.4),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        line(),
        const SizedBox(width: 8),
        Text(
          '~',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 16,
            color: _gold.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 8),
        line(),
      ],
    );
  }
}

/// Ingredients split across two columns, like a printed recipe page.
class _IngredientColumns extends StatelessWidget {
  final List<String> items;
  final double fontSize;
  const _IngredientColumns({required this.items, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final mid = (items.length + 1) ~/ 2;

    Widget bulletRow(String ing) => Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•  ',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: fontSize,
                  color: const Color(0xFF8B6914),
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              Expanded(
                child: Text(
                  ing,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: fontSize,
                    color: _ink,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );

    Widget column(List<String> list) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [for (final ing in list) bulletRow(ing)],
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: column(items.sublist(0, mid))),
        const SizedBox(width: 18),
        Expanded(child: column(items.sublist(mid))),
      ],
    );
  }
}

/// Opening preparation paragraph: illuminated drop cap, dark legible ink,
/// fading toward the bottom to suggest the rest of the recipe.
class _PreparationOpening extends StatelessWidget {
  final String text;
  final double fontSize;
  const _PreparationOpening({required this.text, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final initial = text.substring(0, 1);
    final rest = text.substring(1);

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_ink, Color(0x003A2410)],
        stops: [0.35, 1.0],
      ).createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 8),
            child: Text(
              initial,
              style: GoogleFonts.uncialAntiqua(
                fontSize: 38,
                color: _rust,
                height: 0.9,
              ),
            ),
          ),
          Expanded(
            child: Text(
              rest,
              style: GoogleFonts.cormorantGaramond(
                fontSize: fontSize,
                color: _ink,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fallback plate when a recipe has no bundled illustration: the same
/// deterministic generated tile used across the app (name-derived gradient).
class _GeneratedTileFallback extends StatelessWidget {
  final String name;
  const _GeneratedTileFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final tile = generateRecipeTile(name: name);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tile.gradient,
        ),
      ),
      child: Center(
        child: tile.glyph != null
            ? Icon(tile.glyph, size: 34, color: Colors.white.withValues(alpha: 0.9))
            : Text(
                tile.letter,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
      ),
    );
  }
}

/// Low-opacity speckle grain so the parchment reads as paper, not a flat
/// fill. Deterministic (seeded) and painted once — never repaints.
class _ParchmentGrainPainter extends CustomPainter {
  const _ParchmentGrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(7);
    final paint = Paint();
    final count = (size.width * size.height / 900).clamp(400, 2600).toInt();
    for (var i = 0; i < count; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final dark = rnd.nextBool();
      paint.color = (dark ? const Color(0xFF6B4A20) : Colors.white)
          .withValues(alpha: 0.03 + rnd.nextDouble() * 0.04);
      canvas.drawCircle(Offset(dx, dy), 0.5 + rnd.nextDouble() * 1.1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParchmentGrainPainter oldDelegate) => false;
}
