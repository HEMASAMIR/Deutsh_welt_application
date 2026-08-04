import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_routes.dart';

/// Ultra-Premium Herr Khaled Hero Section with Advanced Animated Spiral & Glowing Aura
class HerrKhaledSpiralHero extends StatefulWidget {
  final bool compact;
  final VoidCallback? onExplorePressed;

  const HerrKhaledSpiralHero({
    super.key,
    this.compact = false,
    this.onExplorePressed,
  });

  @override
  State<HerrKhaledSpiralHero> createState() => _HerrKhaledSpiralHeroState();
}

class _HerrKhaledSpiralHeroState extends State<HerrKhaledSpiralHero>
    with TickerProviderStateMixin {
  late final AnimationController _spiralController;
  late final AnimationController _pulseController;
  late final AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    // 1. Continuous rotation of spiral arms (6s per loop)
    _spiralController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // 2. Breathing pulse effect for avatar glow (2s per cycle)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // 3. Fast particle orbit motion (4s)
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _spiralController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp(String phone) async {
    final url = Uri.parse("https://wa.me/2$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ]
              : [
                  const Color(0xFFEFF6FF),
                  Colors.white,
                  const Color(0xFFF0F9FF),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.25 : 0.12),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark
              ? AppColors.primaryBlue.withValues(alpha: 0.3)
              : AppColors.primaryBlue.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Background subtle grid decoration
            Positioned.fill(
              child: CustomPaint(
                painter: _GridBackgroundPainter(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : AppColors.primaryBlue.withValues(alpha: 0.03),
                ),
              ),
            ),

            // Top ambient gradient glow
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                      blurRadius: 90,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Main Content Layout
            Padding(
              padding: EdgeInsets.all(widget.compact ? 18.0 : (isMobile ? 20.0 : 32.0)),
              child: Column(
                children: [
                  // Header badge tag
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBlue.withValues(alpha: 0.15),
                            const Color(0xFFD97706).withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFF59E0B),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Deutsch Welt Akademie • الهير خالد الحلواني',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF93C5FD) : AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── Center Advanced Spiral & Avatar ───────────────────
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _spiralController,
                      _pulseController,
                      _particleController,
                    ]),
                    builder: (context, child) {
                      final pulse = _pulseController.value;
                      final avatarSize = widget.compact ? 130.0 : (isMobile ? 160.0 : 190.0);
                      final totalSize = avatarSize + 70.0;

                      return SizedBox(
                        width: totalSize,
                        height: totalSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 1. Advanced CustomPainter Spiral Vortex Arms
                            CustomPaint(
                              size: Size(totalSize, totalSize),
                              painter: _AdvancedSpiralPainter(
                                rotationAngle: _spiralController.value * 2 * math.pi,
                                particleProgress: _particleController.value,
                                pulse: pulse,
                                isDark: isDark,
                              ),
                            ),

                            // 2. Outer Glow Ring Container
                            Container(
                              width: avatarSize + 16 + (pulse * 8),
                              height: avatarSize + 16 + (pulse * 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryBlue.withValues(alpha: 0.6 + (pulse * 0.3)),
                                    const Color(0xFFF59E0B).withValues(alpha: 0.5 + (pulse * 0.3)),
                                    const Color(0xFF3B82F6).withValues(alpha: 0.6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.4 + (pulse * 0.2)),
                                    blurRadius: 25 + (pulse * 10),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),

                            // 3. Inner White/Dark Gap Ring
                            Container(
                              width: avatarSize + 8,
                              height: avatarSize + 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                              ),
                            ),

                            // 4. Herr Khaled Photo
                            Hero(
                              tag: 'herr_khaled_hero_avatar',
                              child: Container(
                                width: avatarSize,
                                height: avatarSize,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/khaled.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            // 5. Glassmorphism Highlight overlay ring
                            Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 2.5,
                                ),
                              ),
                            ),

                            // 6. Floating Golden Verified Crown Badge
                            Positioned(
                              bottom: 8,
                              right: isMobile ? 8 : 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.verified_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'خبير الألمانية',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ─── Text & Highlights ────────────────────────────────
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: Text(
                      'Herr / خالد الحلواني',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  FadeInUp(
                    delay: const Duration(milliseconds: 150),
                    duration: const Duration(milliseconds: 700),
                    child: Text(
                      'كبير معلمي ومحاضري اللغة الألمانية • مؤسس Deutsch Welt',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ─── Feature Achievement Badges ───────────────────────
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    duration: const Duration(milliseconds: 700),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildStatChip(
                          icon: Icons.workspace_premium_rounded,
                          label: '+10 سنوات خبرة',
                          color: const Color(0xFF3B82F6),
                          isDark: isDark,
                        ),
                        _buildStatChip(
                          icon: Icons.groups_rounded,
                          label: '+5000 طالب ناجح',
                          color: const Color(0xFF10B981),
                          isDark: isDark,
                        ),
                        _buildStatChip(
                          icon: Icons.translate_rounded,
                          label: 'A1 • A2 • B1 • B2',
                          color: const Color(0xFFF59E0B),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  if (!widget.compact) ...[
                    const SizedBox(height: 24),

                    // ─── CTA Buttons ─────────────────────────────────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 450),
                      duration: const Duration(milliseconds: 700),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.onExplorePressed ??
                                  () {
                                    Navigator.pushNamed(context, AppRoutes.instructorBio);
                                  },
                              icon: const Icon(Icons.person_pin_rounded, color: Colors.white, size: 20),
                              label: Text(
                                'السيرة الذاتية ورؤيتنا',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 13 : 14,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                shadowColor: AppColors.primaryBlue.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _launchWhatsApp('01055287454'),
                              icon: const FaIcon(
                                FontAwesomeIcons.whatsapp,
                                color: Color(0xFF25D366),
                                size: 18,
                              ),
                              label: Text(
                                'تواصل مع الهير',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 13 : 14,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(
                                  color: isDark ? const Color(0xFF475569) : AppColors.border,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter that renders high-precision rotating dual Archimedean spiral arms & orbiting particles
class _AdvancedSpiralPainter extends CustomPainter {
  final double rotationAngle;
  final double particleProgress;
  final double pulse;
  final bool isDark;

  _AdvancedSpiralPainter({
    required this.rotationAngle,
    required this.particleProgress,
    required this.pulse,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;
    final minRadius = maxRadius - 38;

    // Save canvas state for rotational matrix transformation
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    // ─── 1. Primary Spiral Arm (Golden / Blue Gradient) ─────────────────
    final spiralPaint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    const turns = 2.2;
    const points = 120;

    for (int i = 0; i <= points; i++) {
      final t = i / points;
      final angle = t * turns * 2 * math.pi;
      final r = minRadius + (maxRadius - minRadius) * math.sin(t * math.pi);

      final x = r * math.cos(angle);
      final y = r * math.sin(angle);

      if (i == 0) {
        path1.moveTo(x, y);
      } else {
        path1.lineTo(x, y);
      }
    }

    final shader1 = SweepGradient(
      colors: [
        AppColors.primaryBlue.withValues(alpha: 0.1),
        const Color(0xFF3B82F6),
        const Color(0xFFF59E0B),
        AppColors.primaryBlue.withValues(alpha: 0.9),
      ],
      stops: const [0.0, 0.35, 0.7, 1.0],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: maxRadius));

    spiralPaint1.shader = shader1;
    canvas.drawPath(path1, spiralPaint1);

    // ─── 2. Secondary Counter-Rotating Spiral Ring ──────────────────────
    final spiralPaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path2 = Path();
    for (int i = 0; i <= points; i++) {
      final t = i / points;
      final angle = -t * (turns + 0.5) * 2 * math.pi;
      final r = (minRadius - 10) + (maxRadius - minRadius + 5) * math.cos(t * math.pi / 2);

      final x = r * math.cos(angle);
      final y = r * math.sin(angle);

      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }

    final shader2 = SweepGradient(
      colors: [
        const Color(0xFF10B981).withValues(alpha: 0.2),
        const Color(0xFF60A5FA),
        const Color(0xFFF59E0B).withValues(alpha: 0.8),
      ],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: maxRadius));

    spiralPaint2.shader = shader2;
    canvas.drawPath(path2, spiralPaint2);

    // ─── 3. Orbiting Energy Particles ──────────────────────────────────
    final particlePaint = Paint()..style = PaintingStyle.fill;

    final particleColors = [
      const Color(0xFFF59E0B),
      const Color(0xFF60A5FA),
      const Color(0xFF34D399),
      Colors.white,
    ];

    for (int p = 0; p < 8; p++) {
      final offsetAngle = (p / 8.0) * 2 * math.pi + (particleProgress * 2 * math.pi);
      final radiusVar = minRadius + (p % 3 == 0 ? 8 : (p % 2 == 0 ? 16 : -4));

      final px = radiusVar * math.cos(offsetAngle);
      final py = radiusVar * math.sin(offsetAngle);

      final color = particleColors[p % particleColors.length];
      particlePaint.color = color.withValues(alpha: 0.7 + 0.3 * math.sin(offsetAngle + pulse));
      particlePaint.maskFilter = MaskFilter.blur(BlurStyle.solid, 2.0 + (p % 2));

      canvas.drawCircle(Offset(px, py), 2.5 + (p % 3), particlePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AdvancedSpiralPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.particleProgress != particleProgress ||
        oldDelegate.pulse != pulse ||
        oldDelegate.isDark != isDark;
  }
}

/// Subtle grid pattern painter for background texturing
class _GridBackgroundPainter extends CustomPainter {
  final Color color;

  _GridBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const step = 28.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridBackgroundPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
