import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_routes.dart';

/// Elite cinematic splash screen for Deutsch Welt Akademie.
/// Features:
///   • Advanced spiral/swirl particle ring animation
///   • Herr Khaled photo with layered glow & shimmer reveal
///   • Sequenced text entrance choreography
///   • Smooth push-out transition to HomeView
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  // ── Controllers ────────────────────────────────────────────────────────────
  late final AnimationController _spiralCtrl; // endless spiral rotation
  late final AnimationController _pulseCtrl;  // avatar glow pulse
  late final AnimationController _revealCtrl; // sequential content reveal
  late final AnimationController _exitCtrl;   // full-screen swirl exit

  // ── Reveal animations ──────────────────────────────────────────────────────
  late final Animation<double> _avatarScale;
  late final Animation<double> _avatarFade;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _badgesFade;
  late final Animation<double> _buttonFade;

  // ── Exit ───────────────────────────────────────────────────────────────────
  late final Animation<double> _exitScale;
  late final Animation<double> _exitFade;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // 1. Endless spiral rotation (7 s per full rotation)
    _spiralCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    // 2. Gentle glow pulse (1.8 s)
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // 3. Content reveal sequence (total 2.4 s)
    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _avatarFade  = _curve(_revealCtrl, 0.00, 0.30);
    _avatarScale = _curveTween(_revealCtrl, 0.00, 0.30, begin: 0.6, end: 1.0);
    _logoFade    = _curve(_revealCtrl, 0.28, 0.52);
    _taglineFade = _curve(_revealCtrl, 0.45, 0.65);
    _taglineSlide = CurvedAnimation(
      parent: _revealCtrl,
      curve: const Interval(0.45, 0.70, curve: Curves.easeOut),
    ).drive(Tween(begin: const Offset(0, 0.4), end: Offset.zero));
    _subtitleFade = _curve(_revealCtrl, 0.60, 0.78);
    _badgesFade   = _curve(_revealCtrl, 0.72, 0.88);
    _buttonFade   = _curve(_revealCtrl, 0.84, 1.00);

    // 4. Exit swirl
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _exitScale = CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 1.0, end: 14.0));
    _exitFade  = CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 1.0, end: 0.0));

    // Start reveal after short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _revealCtrl.forward();
    });

    // Auto-navigate after 4.2 s
    Future.delayed(const Duration(milliseconds: 4200), _doNavigate);
  }

  // Convenience: fade interval animation
  Animation<double> _curve(AnimationController ctrl, double from, double to) {
    return CurvedAnimation(
      parent: ctrl,
      curve: Interval(from, to, curve: Curves.easeOut),
    );
  }

  // Convenience: scaled tween animation
  Animation<double> _curveTween(
      AnimationController ctrl, double from, double to,
      {required double begin, required double end}) {
    return CurvedAnimation(
      parent: ctrl,
      curve: Interval(from, to, curve: Curves.elasticOut),
    ).drive(Tween(begin: begin, end: end));
  }

  Future<void> _doNavigate() async {
    if (_navigated || !mounted) return;
    _navigated = true;
    await _exitCtrl.forward();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _spiralCtrl.dispose();
    _pulseCtrl.dispose();
    _revealCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _spiralCtrl,
          _pulseCtrl,
          _revealCtrl,
          _exitCtrl,
        ]),
        builder: (context, _) {
          return FadeTransition(
            opacity: _exitFade,
            child: ScaleTransition(
              scale: _exitScale,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Deep gradient background ──────────────────────────────
                  _buildBackground(),

                  // ── Spiral particle ring ──────────────────────────────────
                  CustomPaint(
                    painter: _SpiralPainter(
                      angle: _spiralCtrl.value * 2 * math.pi,
                      pulse: _pulseCtrl.value,
                    ),
                    size: size,
                  ),

                  // ── Main content column ───────────────────────────────────
                  SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 48),

                        // Avatar with glow
                        _buildAvatar(size),

                        const SizedBox(height: 28),

                        // Academy logo / name
                        FadeTransition(
                          opacity: _logoFade,
                          child: _buildLogoSection(),
                        ),

                        const SizedBox(height: 14),

                        // Arabic tagline
                        SlideTransition(
                          position: _taglineSlide,
                          child: FadeTransition(
                            opacity: _taglineFade,
                            child: _buildTagline(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // German subtitle
                        FadeTransition(
                          opacity: _subtitleFade,
                          child: _buildGermanSubtitle(),
                        ),

                        const SizedBox(height: 24),

                        // Level badges
                        FadeTransition(
                          opacity: _badgesFade,
                          child: _buildLevelBadges(),
                        ),

                        const Spacer(),

                        // CTA button
                        FadeTransition(
                          opacity: _buttonFade,
                          child: _buildStartButton(),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.2,
          colors: [
            Color(0xFF0A1628), // deep navy core
            Color(0xFF050D1A), // near black edges
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Size size) {
    final glow = 0.5 + (_pulseCtrl.value * 0.5);
    return FadeTransition(
      opacity: _avatarFade,
      child: ScaleTransition(
        scale: _avatarScale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring 3
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    const Color(0xFF1E3A8A).withValues(alpha: 0.0),
                    const Color(0xFF60A5FA).withValues(alpha: 0.15 * glow),
                    const Color(0xFF1E3A8A).withValues(alpha: 0.0),
                  ],
                  transform: GradientRotation(
                      _spiralCtrl.value * 2 * math.pi),
                ),
              ),
            ),
            // Outer glow ring 2
            Container(
              width: 178,
              height: 178,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.5 * glow),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: const Color(0xFF60A5FA).withValues(alpha: 0.3 * glow),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Spinning gradient border
            Transform.rotate(
              angle: _spiralCtrl.value * 2 * math.pi,
              child: Container(
                width: 168,
                height: 168,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const SweepGradient(
                    colors: [
                      Color(0xFF1E3A8A),
                      Color(0xFF60A5FA),
                      Color(0xFFFFFFFF),
                      Color(0xFF60A5FA),
                      Color(0xFF1E3A8A),
                    ],
                  ),
                ),
              ),
            ),
            // White ring separator
            Container(
              width: 162,
              height: 162,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            // Actual photo
            ClipOval(
              child: Image.asset(
                'assets/images/khaled.jpg',
                width: 158,
                height: 158,
                fit: BoxFit.cover,
                alignment: const Alignment(0.1, -0.3),
              ),
            ),
            // Shimmer overlay that sweeps across the photo
            ClipOval(
              child: SizedBox(
                width: 158,
                height: 158,
                child: _ShimmerOverlay(
                  progress: _revealCtrl.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Academy name in German
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF60A5FA), Colors.white, Color(0xFF93C5FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Deutsche Welt Akademie',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        // Herr Khaled name with gold accent
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFFD700)],
          ).createShader(bounds),
          child: Text(
            '🎓 Herr Khaled — خالد الحلواني',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'حلم الألمانية يبدأ من هنا 🇩🇪',
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildGermanSubtitle() {
    return Text(
      'Dein Deutsch beginnt hier · منصتك المتخصصة',
      textAlign: TextAlign.center,
      style: GoogleFonts.cairo(
        fontSize: 13,
        color: Colors.white.withValues(alpha: 0.6),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildLevelBadges() {
    const levels = ['A1', 'A2', 'B1', 'B2'];
    const colors = [
      Color(0xFF10B981),
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFFEF4444),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(levels.length, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 400 + i * 120),
            curve: Curves.elasticOut,
            builder: (_, val, __) {
              return Transform.scale(
                scale: val,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: colors[i].withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: colors[i].withValues(alpha: 0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: colors[i].withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    levels[i],
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _doNavigate,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 48),
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF60A5FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.6),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Shimmer sweep on button
            ClipRRect(
              borderRadius: BorderRadius.circular(27),
              child: _ButtonShimmer(rotation: _spiralCtrl.value),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ابدأ رحلتك الآن 🚀',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Spiral Painter ───────────────────────────────────────────────────────────
class _SpiralPainter extends CustomPainter {
  final double angle;
  final double pulse;

  const _SpiralPainter({required this.angle, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.32;

    // ── Outer spiral ring (80 particles) ──────────────────────────────────────
    _drawSpiral(canvas, cx, cy,
        baseRadius: 118,
        particleCount: 80,
        particleRadius: 2.2,
        colorA: const Color(0xFF1E3A8A),
        colorB: const Color(0xFF60A5FA),
        angleOffset: angle,
        twist: 6.5,
        pulse: pulse);

    // ── Inner spiral ring (50 particles, counter-rotate) ──────────────────────
    _drawSpiral(canvas, cx, cy,
        baseRadius: 90,
        particleCount: 50,
        particleRadius: 1.5,
        colorA: const Color(0xFF93C5FD),
        colorB: const Color(0xFFFFFFFF),
        angleOffset: -angle * 1.4,
        twist: 4.0,
        pulse: pulse);

    // ── Micro sparkle ring ────────────────────────────────────────────────────
    _drawSpiral(canvas, cx, cy,
        baseRadius: 100,
        particleCount: 24,
        particleRadius: 1.0,
        colorA: const Color(0xFFFFD700),
        colorB: const Color(0xFFFFA500),
        angleOffset: angle * 2.0,
        twist: 2.0,
        pulse: pulse,
        sparkle: true);
  }

  void _drawSpiral(
    Canvas canvas,
    double cx,
    double cy, {
    required double baseRadius,
    required int particleCount,
    required double particleRadius,
    required Color colorA,
    required Color colorB,
    required double angleOffset,
    required double twist,
    required double pulse,
    bool sparkle = false,
  }) {
    for (int i = 0; i < particleCount; i++) {
      final t = i / particleCount;
      final spiralOffset = t * twist;
      final a = angleOffset + t * 2 * math.pi + spiralOffset;
      final r = baseRadius + math.sin(t * math.pi * 4 + pulse * math.pi) * 8;
      final x = cx + math.cos(a) * r;
      final y = cy + math.sin(a) * r;

      final alpha = math.pow(math.sin(t * math.pi), 1.5).toDouble();
      final color = Color.lerp(colorA, colorB, t)!
          .withValues(alpha: sparkle ? alpha * 0.9 : alpha * 0.7);

      final pr = sparkle
          ? particleRadius * (0.5 + pulse * 1.5 * (1 - t))
          : particleRadius;

      final paint = Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(
            BlurStyle.normal, sparkle ? 3 : particleRadius * 0.8);

      canvas.drawCircle(Offset(x, y), pr, paint);
    }
  }

  @override
  bool shouldRepaint(_SpiralPainter old) =>
      old.angle != angle || old.pulse != pulse;
}

// ─── Shimmer Overlay ──────────────────────────────────────────────────────────
class _ShimmerOverlay extends StatelessWidget {
  final double progress;
  const _ShimmerOverlay({required this.progress});

  @override
  Widget build(BuildContext context) {
    final shimmerX = -1.0 + progress * 3.0; // sweeps left → right → gone
    final opacity = (1.0 - (progress - 0.7).clamp(0, 0.3) / 0.3) * 0.6;

    if (opacity <= 0) return const SizedBox.shrink();

    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(shimmerX - 0.4, -1),
            end: Alignment(shimmerX + 0.4, 1),
            colors: [
              Colors.transparent,
              Colors.white.withValues(alpha: 0.5),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Button Shimmer ───────────────────────────────────────────────────────────
class _ButtonShimmer extends StatelessWidget {
  final double rotation;
  const _ButtonShimmer({required this.rotation});

  @override
  Widget build(BuildContext context) {
    final shimmerX = (rotation * 2 - 1.0); // -1 → +1 sweep
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(shimmerX - 0.6, -1),
          end: Alignment(shimmerX + 0.6, 1),
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
