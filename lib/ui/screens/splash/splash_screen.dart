import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/settings_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback onInitComplete;

  const SplashScreen({super.key, required this.onInitComplete});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _progressAnimation;

  final List<String> _nerdMessages = const [
    'Conjuring Ingredients...',
    'Summoning Recipes...',
    'Brewing Potions...',
    'Enchanting Cookware...',
    'Casting Flavor Spells...',
    'Awakening the Kitchen...',
  ];

  final List<String> _normalMessages = const [
    'Loading...',
    'Getting recipes ready...',
    'Preparing your kitchen...',
  ];

  String _currentMessage = 'Loading...';
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
    );

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 1.0, curve: Curves.easeInOut),
    );

    _controller.forward();
    _startMessageCycle();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) widget.onInitComplete();
        });
      }
    });
  }

  Future<void> _startMessageCycle() async {
    final settings = ref.read(settingsProvider);
    final messages = settings.nerdMode ? _nerdMessages : _normalMessages;

    // Initialize message immediately based on mode
    _currentMessage = messages.first;
    _messageIndex = 0;

    while (mounted && _controller.isAnimating) {
      await Future.delayed(const Duration(milliseconds: 650));
      if (!mounted || !_controller.isAnimating) break;

      setState(() {
        _messageIndex = (_messageIndex + 1) % messages.length;
        _currentMessage = messages[_messageIndex];
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isNerdMode = settings.nerdMode;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F3EE),
              Color(0xFFEDE9E0),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Cap logo size so it looks good on tablets and small phones.
                final maxLogoSize =
                (constraints.maxWidth * 0.55).clamp(140.0, 240.0);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),

                      // Logo
                      Center(
                        child: SizedBox(
                          width: maxLogoSize,
                          height: maxLogoSize,
                          child: Image.asset(
                            'assets/images/splash_logo.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackLogo(isNerdMode);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // App name
                      const Text(
                        'RECIPE SPELLBOOK',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D4F5F),
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 14),

                      // Loading message (fixed height to prevent jump)
                      SizedBox(
                        height: 28,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: Text(
                            _currentMessage,
                            key: ValueKey(_currentMessage),
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color(0xFF6B7280),
                              fontStyle: isNerdMode
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),

                      // Progress bar
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF3D4F5F),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return LinearProgressIndicator(
                                  value: _progressAnimation.value,
                                  backgroundColor: Colors.transparent,
                                  valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFCBA135),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 4),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackLogo(bool isNerdMode) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3D4F5F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book,
              size: 80,
              color: Color(0xFFCBA135),
            ),
            const SizedBox(height: 10),
            if (isNerdMode)
              const Icon(
                Icons.auto_awesome,
                size: 32,
                color: Color(0xFFCBA135),
              ),
          ],
        ),
      ),
    );
  }
}