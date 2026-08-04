import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_routes.dart';

/// Full-screen animated splash that transitions to HomeView.
/// Features:
///  - Advanced spiral / vortex reveal animation for Herr Khaled's photo
///  - Rotating DNA-helix ring particles
///  - Golden shimmer text reveal
///  - Smooth fade-out to home
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  // ── Master timeline ──────────────────────────────────────────────────────────
  late final AnimationController _master;

  // ── Spiral / vortex ─────────────────────────────────────────────────────────
  late final AnimationController _spiralCtrl;
  late final Animation<double> _spiralAngle;
  late final Animation<double> _spiralScale;
  late final Animation<double> _spiralOpacity;

  // ── Ring particles ───────────────────────────────────────────────────────────
  late final AnimationController _ringCtrl;

  // ── Photo clip / reveal ──────────────────────────────────────────────────────
  late final Animation<double> _photoReveal; // 0→1 clip radius
  late final Animation<double> _photoScale;
  late final Animation<double> _photoOpacity;

  // ── Text & logo ─────────────────────────────────────────────────────────────
  late final Animation<double> _textSlide;
  late final Animation<double> _textOpacity;
  late final Animation<double> _taglineOpacity;

  // ── Shimmer ─────────────────────────────────────────────────────────────────
  late final AnimationController _shimmerCtrl;

  // ── Glow pulse ──────────────────────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _glowPulse;

  // ── Exit fade ───────────────────────────────────────────────────────────────
  late final AnimationController _exitCtrl;
  late final Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // ── Spiral controller (0 → 2π × 2.5 turns while scaling in) ─────────────
    _spiralCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _spiralAngle = Tween<double>(begin: math.pi * 5, end: 0).animate(
      CurvedAnimation(parent: _spiralCtrl, curve: Curves.easeOut),
    );
    _spiralScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _spiralCtrl, curve: Curves.easeOut),
    );
    _spiralOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _spiralCtrl,
          curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    // ── Ring – endless slow rotation ─────────────────────────────────────────
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // ── Master (photo + text) ────────────────────────────────────────────────
    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _photoReveal = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _master,
          curve: const Interval(0.20, 0.75, curve: Curves.easeOutCubic)),
    );
    _photoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
          parent: _master,
          curve: const Interval(0.20, 0.80, curve: Curves.elasticOut)),
    );
    _photoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _master,
          curve: const Interval(0.20, 0.55, curve: Curves.easeIn)),
    );
    _textSlide = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(
          parent: _master,
          curve: const Interval(0.55, 0.90, curve: Curves.easeOutCubic)),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _master,
          curve: const Interval(0.55, 0.88, curve: Curves.easeIn)),
    );
    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _master,
          curve: const Interval(0.72, 1.0, curve: Curves.easeIn)),
    );

    // ── Shimmer ──────────────────────────────────────────────────────────────
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // ── Glow pulse ───────────────────────────────────────────────────────────
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // ── Exit ─────────────────────────────────────────────────────────────────
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );

    // ── Sequence ──────────────────────────────────────────────────────────────
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _spiralCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _master.forward();
    // Hold for viewer to enjoy
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;
    await _exitCtrl.forward();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  void dispose() {
    _master.dispose();
    _spiralCtrl.dispose();
    _ringCtrl.dispose();
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final photoSize = size.width * 0.72;

    return FadeTransition(
      opacity: _exitOpacity,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Deep gradient background ───────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 1.4,
                  colors: [
                    Color(0xFF172554), // Deep navy center
                    Color(0xFF0F172A), // Almost-black edge
                  ],
                ),
              ),
            ),

            // ── Animated background grid lines (subtle) ───────────────────
            AnimatedBuilder(
              animation: _ringCtrl,
              builder: (_, __) => CustomPaint(
                painter: _GridPainter(progress: _ringCtrl.value),
              ),
            ),

            // ── Outer glow ring behind photo ──────────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _glowPulse,
                builder: (_, __) {
                  return Container(
                    width: photoSize + 60,
                    height: photoSize + 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF60A5FA)
                              .withValues(alpha: 0.18 * _glowPulse.value),
                          blurRadius: 80 * _glowPulse.value,
                          spreadRadius: 20 * _glowPulse.value,
                        ),
                        BoxShadow(
                          color: const Color(0xFF1E3A8A)
                              .withValues(alpha: 0.35 * _glowPulse.value),
                          blurRadius: 120,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Rotating DNA-helix particle ring ──────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _ringCtrl,
                builder: (_, __) => SizedBox(
                  width: photoSize + 80,
                  height: photoSize + 80,
                  child: CustomPaint(
                    painter: _SpiralRingPainter(
                      progress: _ringCtrl.value,
                      particleCount: 32,
                      innerRingColor: const Color(0xFF60A5FA),
                      outerRingColor: const Color(0xFF1E3A8A),
                    ),
                  ),
                ),
              ),
            ),

            // ── Spiral vortex entrance ────────────────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _spiralCtrl,
                builder: (_, __) => Opacity(
                  opacity: _spiralOpacity.value,
                  child: Transform.scale(
                    scale: _spiralScale.value,
                    child: Transform.rotate(
                      angle: _spiralAngle.value,
                      child: CustomPaint(
                        size: Size(photoSize + 100, photoSize + 100),
                        painter: _VortexPainter(
                            progress: _spiralCtrl.value),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Photo (circular clipped, scales + reveals) ────────────────
            Center(
              child: AnimatedBuilder(
                animation: _master,
                builder: (_, __) => Opacity(
                  opacity: _photoOpacity.value,
                  child: Transform.scale(
                    scale: _photoScale.value,
                    child: _CircularPhotoReveal(
                      size: photoSize,
                      revealProgress: _photoReveal.value,
                    ),
                  ),
                ),
              ),
            ),

            // ── Inner thin golden arc on top of photo border ──────────────
            Center(
              child: AnimatedBuilder(
                animation: _ringCtrl,
                builder: (_, __) => SizedBox(
                  width: photoSize + 12,
                  height: photoSize + 12,
                  child: CustomPaint(
                    painter: _ArcBorderPainter(
                        rotation: _ringCtrl.value * math.pi * 2),
                  ),
                ),
              ),
            ),

            // ── Bottom text panel ─────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _master,
                builder: (_, __) => Opacity(
                  opacity: _textOpacity.value,
                  child: Transform.translate(
                    offset: Offset(0, _textSlide.value),
                    child: _buildTextPanel(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 52),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFF0F172A), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Herr Khaled name with shimmer
          _ShimmerText(
            controller: _shimmerCtrl,
            text: 'Herr Khaled',
            style: GoogleFonts.playfairDisplay(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: _taglineOpacity,
            builder: (_, __) => Opacity(
              opacity: _taglineOpacity.value,
              child: Text(
                'خالد الحلواني',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  color: const Color(0xFF93C5FD),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _taglineOpacity,
            builder: (_, __) => Opacity(
              opacity: _taglineOpacity.value,
              child: Container(
                height: 1.5,
                width: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xFF60A5FA),
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _taglineOpacity,
            builder: (_, __) => Opacity(
              opacity: _taglineOpacity.value,
              child: Text(
                'Deutsche Welt Akademie\nحلم الألمانية يبدأ من هنا 🇩🇪',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Circular Photo with custom reveal clip ────────────────────────────────────
class _CircularPhotoReveal extends StatelessWidget {
  final double size;
  final double revealProgress; // 0 → 1

  const _CircularPhotoReveal(
      {required this.size, required this.revealProgress});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _SpiralRevealClipper(progress: revealProgress),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF60A5FA).withValues(alpha: 0.6),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/khaled.jpg',
            fit: BoxFit.cover,
            width: size,
            height: size,
          ),
        ),
      ),
    );
  }
}

// ─── Spiral Reveal Clipper ─────────────────────────────────────────────────────
/// Reveals the photo by expanding a circular clip from center outward
/// while rotating, creating a spiral wipe effect.
class _SpiralRevealClipper extends CustomClipper<Path> {
  final double progress;

  _SpiralRevealClipper({required this.progress});

  @override
  Path getClip(Size size) {
    if (progress >= 1.0) {
      return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.7;

    final path = Path();
    final sweepAngle = math.pi * 2 * progress;

    // Build spiral path: starts from center, expands outward with rotation
    path.moveTo(center.dx, center.dy);
    const steps = 120;
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final angle = -math.pi / 2 + sweepAngle * t;
      final radius = maxRadius * t * progress;
      path.lineTo(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
    }
    path.close();

    // Add the full circle once progress is high enough for smooth finish
    if (progress > 0.85) {
      final blend = (progress - 0.85) / 0.15;
      path.addOval(Rect.fromCircle(
        center: center,
        radius: maxRadius * blend,
      ));
    }

    return path;
  }

  @override
  bool shouldReclip(_SpiralRevealClipper old) => old.progress != progress;
}

// ─── Vortex Painter ──────────────────────────────────────────────────────────
class _VortexPainter extends CustomPainter {
  final double progress;
  _VortexPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const arms = 6;
    const turns = 2.5;

    for (int arm = 0; arm < arms; arm++) {
      final armOffset = (arm / arms) * math.pi * 2;
      final path = Path();
      bool first = true;

      for (int i = 0; i < 120; i++) {
        final t = i / 120.0;
        final angle = armOffset + t * turns * math.pi * 2;
        final radius = t * size.width * 0.48 * progress;
        final x = center.dx + math.cos(angle) * radius;
        final y = center.dy + math.sin(angle) * radius;

        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }

      final opacity = (1.0 - progress) * 0.6 + 0.05;
      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFF60A5FA),
          const Color(0xFF1E3A8A),
          arm / arms.toDouble(),
        )!.withValues(alpha: opacity)
        ..strokeWidth = 1.5 - progress * 1.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_VortexPainter old) => old.progress != progress;
}

// ─── Spiral Ring Painter ──────────────────────────────────────────────────────
class _SpiralRingPainter extends CustomPainter {
  final double progress;
  final int particleCount;
  final Color innerRingColor;
  final Color outerRingColor;

  _SpiralRingPainter({
    required this.progress,
    required this.particleCount,
    required this.innerRingColor,
    required this.outerRingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Two counter-rotating rings of dots
    for (int ring = 0; ring < 2; ring++) {
      final ringProgress = ring == 0 ? progress : 1.0 - progress;
      final color = ring == 0 ? innerRingColor : outerRingColor;
      final dotRadius = ring == 0 ? 3.0 : 2.0;
      final ringR = ring == 0 ? radius : radius - 12;

      for (int i = 0; i < particleCount; i++) {
        final angle =
            (i / particleCount) * math.pi * 2 + ringProgress * math.pi * 2;
        final x = center.dx + math.cos(angle) * ringR;
        final y = center.dy + math.sin(angle) * ringR;

        // Fade in/out by position
        final alphaMult =
            0.3 + 0.7 * math.pow(math.sin(angle + ringProgress * math.pi), 2);
        final paint = Paint()
          ..color = color.withValues(alpha: alphaMult * 0.8)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), dotRadius, paint);

        // Connecting dashes between dots
        if (i % 3 == 0 && i + 1 < particleCount) {
          final nextAngle = ((i + 1) / particleCount) * math.pi * 2 +
              ringProgress * math.pi * 2;
          final nx = center.dx + math.cos(nextAngle) * ringR;
          final ny = center.dy + math.sin(nextAngle) * ringR;

          final linePaint = Paint()
            ..color = color.withValues(alpha: alphaMult * 0.25)
            ..strokeWidth = 0.8
            ..style = PaintingStyle.stroke;

          canvas.drawLine(Offset(x, y), Offset(nx, ny), linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_SpiralRingPainter old) => old.progress != progress;
}

// ─── Arc Border Painter ───────────────────────────────────────────────────────
class _ArcBorderPainter extends CustomPainter {
  final double rotation;
  _ArcBorderPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    const arcCount = 4;
    for (int i = 0; i < arcCount; i++) {
      final startAngle = rotation + (i / arcCount) * math.pi * 2;
      final sweepAngle = math.pi * 0.4;
      final opacity = 0.5 + 0.5 * math.sin(rotation + i * math.pi / 2);

      final paint = Paint()
        ..color = const Color(0xFF60A5FA).withValues(alpha: opacity * 0.9)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcBorderPainter old) => old.rotation != old.rotation;
}

// ─── Grid Background Painter ──────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  final double progress;
  _GridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3A8A).withValues(alpha: 0.12)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    final offsetX = (progress * spacing) % spacing;
    final offsetY = (progress * spacing * 0.6) % spacing;

    for (double x = -spacing + offsetX; x < size.width + spacing; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = -spacing + offsetY; y < size.height + spacing; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.progress != progress;
}

// ─── Shimmer Text ─────────────────────────────────────────────────────────────
class _ShimmerText extends StatelessWidget {
  final AnimationController controller;
  final String text;
  final TextStyle style;

  const _ShimmerText({
    required this.controller,
    required this.text,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final shimmerPos = controller.value;
            return LinearGradient(
              colors: const [
                Color(0xFFFFFFFF),
                Color(0xFFE0F2FE),
                Color(0xFF60A5FA),
                Color(0xFFBAE6FD),
                Color(0xFFFFFFFF),
              ],
              stops: [
                (shimmerPos - 0.3).clamp(0.0, 1.0),
                (shimmerPos - 0.1).clamp(0.0, 1.0),
                shimmerPos.clamp(0.0, 1.0),
                (shimmerPos + 0.1).clamp(0.0, 1.0),
                (shimmerPos + 0.3).clamp(0.0, 1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds);
          },
          child: Text(text, style: style, textAlign: TextAlign.center),
        );
      },
    );
  }
}
