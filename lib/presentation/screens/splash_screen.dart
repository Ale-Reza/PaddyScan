import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paddy_scan/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _scanController;
  late AnimationController _particleController;
  late AnimationController _progressController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _scanLine;
  late Animation<double> _ringScale1;
  late Animation<double> _ringScale2;
  late Animation<double> _ringOpacity1;
  late Animation<double> _ringOpacity2;
  late Animation<double> _progressValue;
  late Animation<double> _particleRotation;

  @override
  void initState() {
    super.initState();
    // Hide status bar and nav bar — true full-screen splash
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // Background pulse
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Logo entrance
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Scanning ring animations
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _ringScale1 = Tween<double>(begin: 0.6, end: 1.4).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeOut),
    );
    _ringOpacity1 = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeOut),
    );
    _ringScale2 = Tween<double>(begin: 0.6, end: 1.4).animate(
      CurvedAnimation(
        parent: _scanController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _ringOpacity2 = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(
        parent: _scanController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Scan line
    _scanLine = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    // Text animations
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Particle rotation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _particleRotation = Tween<double>(begin: 0, end: 2 * pi).animate(
      _particleController,
    );

    // Progress bar
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _progressValue = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  void _startSequence() async {
    // Start logo animation
    await Future.delayed(const Duration(milliseconds: 3000));
    _logoController.forward();

    // Start text after logo
    await Future.delayed(const Duration(milliseconds: 4200));
    _textController.forward();
    _progressController.forward();

    // Restore system UI before leaving splash
    await Future.delayed(const Duration(milliseconds: 7000));
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _scanController.dispose();
    _particleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _bgController,
          _logoController,
          _textController,
          _scanController,
          _particleController,
          _progressController,
        ]),
        builder: (context, _) {
          return Stack(
            children: [
              // ── Deep dark background ──────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Color.lerp(
                        const Color(0xFF0A1F0A),
                        const Color(0xFF0D2B0D),
                        _bgController.value,
                      )!,
                      const Color(0xFF020802),
                    ],
                  ),
                ),
              ),

              // ── Particle dots orbiting ────────────────
              ..._buildParticles(size),

              // ── Grid lines (subtle) ───────────────────
              CustomPaint(
                size: size,
                painter: _GridPainter(),
              ),

              // ── Main content ──────────────────────────
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo zone
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: SizedBox(
                          width: 180,
                          height: 180,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulsing rings
                              _buildRing(
                                scale: _ringScale1.value,
                                opacity: _ringOpacity1.value,
                                size: 170,
                                color: const Color(0xFF4CAF50),
                              ),
                              _buildRing(
                                scale: _ringScale2.value,
                                opacity: _ringOpacity2.value,
                                size: 170,
                                color: const Color(0xFF81C784),
                              ),

                              // Hexagon logo container
                              ClipPath(
                                clipper: _HexClipper(),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF1B5E20),
                                        Color(0xFF388E3C),
                                        Color(0xFF66BB6A),
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Scan line inside logo
                                      Positioned(
                                        top: ((_scanLine.value + 1) / 2) * 120,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: 2,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                const Color(0xFF00FF41)
                                                    .withOpacity(0.8),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Rice leaf icon
                                      const Center(
                                        child: Icon(
                                          Icons.eco,
                                          size: 52,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Corner scan brackets
                              ..._buildScanBrackets(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // App name
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Paddy',
                              style: GoogleFonts.orbitron(
                                fontSize: 34,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            TextSpan(
                              text: 'Scan',
                              style: GoogleFonts.orbitron(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF4CAF50),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tagline
                    SlideTransition(
                      position: _taglineSlide,
                      child: FadeTransition(
                        opacity: _taglineOpacity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 20,
                              height: 1,
                              color: const Color(0xFF4CAF50).withOpacity(0.5),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.splashTagline,
                              style: GoogleFonts.rajdhani(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF81C784),
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 20,
                              height: 1,
                              color: const Color(0xFF4CAF50).withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom progress section ───────────────
              Positioned(
                bottom: 60 + bottomPadding,
                left: 40,
                right: 40,
                child: FadeTransition(
                  opacity: _taglineOpacity,
                  child: Column(
                    children: [
                      // Progress bar
                      Stack(
                        children: [
                          Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: _progressValue.value,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1B5E20),
                                    Color(0xFF4CAF50),
                                    Color(0xFF00E676),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(1),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4CAF50)
                                        .withOpacity(0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Status text
                      Text(
                        _getStatusText(_progressValue.value, l10n),
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.4),
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getStatusText(double progress, AppLocalizations l10n) {
    if (progress < 0.3) return l10n.initializingEngine;
    if (progress < 0.6) return l10n.loadingModels;
    if (progress < 0.85) return l10n.calibratingSensors;
    return l10n.ready;
  }

  Widget _buildRing({
    required double scale,
    required double opacity,
    required double size,
    required Color color,
  }) {
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildScanBrackets() {
    const color = Color(0xFF00E676);
    const size = 16.0;
    const thickness = 2.0;

    Widget bracket(double top, double left, double right, double bottom) {
      return Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border(
              top: top >= 0
                  ? const BorderSide(color: color, width: thickness)
                  : BorderSide.none,
              left: left >= 0
                  ? const BorderSide(color: color, width: thickness)
                  : BorderSide.none,
              right: right >= 0
                  ? const BorderSide(color: color, width: thickness)
                  : BorderSide.none,
              bottom: bottom >= 0
                  ? const BorderSide(color: color, width: thickness)
                  : BorderSide.none,
            ),
          ),
        ),
      );
    }

    return [
      bracket(0, 0, -1, -1), // top-left
      bracket(0, -1, 0, -1), // top-right
      bracket(-1, 0, -1, 0), // bottom-left
      bracket(-1, -1, 0, 0), // bottom-right
    ];
  }

  List<Widget> _buildParticles(Size size) {
    final particles = <Widget>[];
    final random = Random(42);

    for (int i = 0; i < 12; i++) {
      final angle = _particleRotation.value + (i * (2 * pi / 12));
      final radius = 140.0 + random.nextDouble() * 60;
      final x = size.width / 2 + cos(angle) * radius;
      final y = size.height / 2 + sin(angle) * radius;
      final dotSize = 1.5 + random.nextDouble() * 2;
      final opacity = 0.2 + random.nextDouble() * 0.4;

      particles.add(
        Positioned(
          left: x - dotSize / 2,
          top: y - dotSize / 2,
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4CAF50).withOpacity(opacity),
            ),
          ),
        ),
      );
    }
    return particles;
  }
}

// ── Painters & Clippers ───────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}

class _HexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_HexClipper oldClipper) => false;
}
