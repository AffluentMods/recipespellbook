import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _iconFade;
  late Animation<double> _iconScale;
  late Animation<double> _titleFade;
  late Animation<double> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _glowPulse;
  late Animation<double> _shimmerPosition;
  late Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    // Main sequence: 0.0 → 1.0 over 2.8 seconds
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Looping glow pulse
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Shimmer sweep across the book
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Icon fades in and scales up: 0.0 → 0.35
    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _iconScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    // Title fades in and slides up: 0.25 → 0.55
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Subtitle fades in: 0.45 → 0.7
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.45, 0.7, curve: Curves.easeOut),
      ),
    );

    // Exit fade: 0.82 → 1.0
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.82, 1.0, curve: Curves.easeIn),
      ),
    );

    // Glow pulse
    _glowPulse = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Shimmer sweep
    _shimmerPosition = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    _fadeController.forward();

    // Start glow after icon starts appearing
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _glowController.repeat(reverse: true);

    // Fire shimmer once
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _shimmerController.forward();

    // Navigate when done
    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEBE8D),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _fadeController,
          _glowController,
          _shimmerController,
        ]),
        builder: (context, _) {
          return Opacity(
            opacity: _exitFade.value,
            child: Center(
              child: FittedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconWithGlow(),
                    const SizedBox(height: 36),
                    _buildTitle(),
                    const SizedBox(height: 14),
                    _buildDivider(),
                    const SizedBox(height: 14),
                    _buildTagline(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Book icon with golden glow and shimmer ───

  Widget _buildIconWithGlow() {
    return Opacity(
      opacity: _iconFade.value,
      child: Transform.scale(
        scale: _iconScale.value,
        child: SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700)
                          .withValues(alpha: _glowPulse.value * 0.35),
                      blurRadius: 35,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: const Color(0xFFE8A850)
                          .withValues(alpha: _glowPulse.value * 0.25),
                      blurRadius: 60,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),

              // Icon image + shimmer
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/icon_splash.png',
                      width: 260,
                      height: 260,
                      fit: BoxFit.contain,
                    ),
                    // Shimmer overlay
                    if (_shimmerController.isAnimating ||
                        _shimmerController.isCompleted)
                      Positioned.fill(
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                              stops: [
                                (_shimmerPosition.value - 0.3).clamp(0.0, 1.0),
                                _shimmerPosition.value.clamp(0.0, 1.0),
                                (_shimmerPosition.value + 0.3).clamp(0.0, 1.0),
                              ],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcATop,
                          child: Container(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Sparkles
              ..._buildSparkles(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── "Recipe Spellbook" title ───

  Widget _buildTitle() {
    final l10n = AppLocalizations.of(context)!;
    return Opacity(
      opacity: _titleFade.value,
      child: Transform.translate(
        offset: Offset(0, _titleSlide.value),
        child: Column(
          children: [
            Text(
              l10n.splashRecipe,
              style: GoogleFonts.uncialAntiqua(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5D3A1A),
                letterSpacing: 2,
                height: 1.1,
                shadows: [
                  Shadow(
                    color: const Color(0xFF5D3A1A).withValues(alpha: 0.25),
                    offset: const Offset(1, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            Text(
              l10n.splashSpellbook,
              style: GoogleFonts.uncialAntiqua(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5D3A1A),
                letterSpacing: 2,
                height: 1.1,
                shadows: [
                  Shadow(
                    color: const Color(0xFF5D3A1A).withValues(alpha: 0.25),
                    offset: const Offset(1, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Decorative divider with sparkle icon ───

  Widget _buildDivider() {
    return Opacity(
      opacity: _subtitleFade.value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFF8B6914).withValues(alpha: 0.0),
                const Color(0xFF8B6914).withValues(alpha: 0.6),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: const Color(0xFF8B6914).withValues(alpha: 0.7),
            ),
          ),
          Container(
            width: 50,
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFF8B6914).withValues(alpha: 0.6),
                const Color(0xFF8B6914).withValues(alpha: 0.0),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tagline ───

  Widget _buildTagline() {
    return Opacity(
      opacity: _subtitleFade.value,
      child: Text(
        'Your culinary adventure awaits',
        style: GoogleFonts.cormorantGaramond(
          fontSize: 17,
          fontStyle: FontStyle.italic,
          color: const Color(0xFF7A5030).withValues(alpha: 0.8),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ─── Floating sparkle particles ───

  List<Widget> _buildSparkles() {
    if (_subtitleFade.value < 0.1) return [];

    final sparkles = <Widget>[];
    final random = math.Random(42); // Fixed seed = consistent positions

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi + (_glowPulse.value * 0.6);
      final radius = 120.0 + random.nextDouble() * 20;
      final size = 2.5 + random.nextDouble() * 3.5;
      final opacity = (_subtitleFade.value * (0.2 + _glowPulse.value * 0.6))
          .clamp(0.0, 1.0);

      sparkles.add(
        Positioned(
          left: 150 + math.cos(angle) * radius - size / 2,
          top: 150 + math.sin(angle) * radius - size / 2,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return sparkles;
  }
}