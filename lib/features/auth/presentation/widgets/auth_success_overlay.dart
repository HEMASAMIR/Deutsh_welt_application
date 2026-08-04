import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

/// Shows a premium animated success overlay after Login or Registration.
Future<void> showAuthSuccessOverlay({
  required BuildContext context,
  required String firstName,
  required bool isRegister,
}) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'auth_success_barrier',
    barrierColor: Colors.black.withValues(alpha: 0.65),
    transitionDuration: const Duration(milliseconds: 400),
    transitionBuilder: (ctx, animation, _, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    pageBuilder: (ctx, _, __) => _AuthSuccessOverlayWidget(
      firstName: firstName,
      isRegister: isRegister,
    ),
  );
}

class _AuthSuccessOverlayWidget extends StatefulWidget {
  final String firstName;
  final bool isRegister;

  const _AuthSuccessOverlayWidget({
    required this.firstName,
    required this.isRegister,
  });

  @override
  State<_AuthSuccessOverlayWidget> createState() => _AuthSuccessOverlayWidgetState();
}

class _AuthSuccessOverlayWidgetState extends State<_AuthSuccessOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _particlesController;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    // Generate random particles
    final random = Random();
    final colors = [
      AppColors.primaryBlue,
      AppColors.primaryBlueLight,
      const Color(0xFF6366F1),
      Colors.amber,
      AppColors.success,
    ];

    for (int i = 0; i < 22; i++) {
      _particles.add(
        _Particle(
          angle: random.nextDouble() * 2 * pi,
          speed: 0.5 + random.nextDouble() * 1.5,
          size: 3 + random.nextDouble() * 5,
          color: colors[random.nextInt(colors.length)],
        ),
      );
    }

    // Auto-dismiss after 2.2s
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleKey = widget.isRegister ? 'register_success_title' : 'login_success_title';
    final bodyKey = widget.isRegister ? 'register_success_body' : 'login_success_body';

    final localizedTitle = context.translate(titleKey);
    final localizedBody = context.translate(bodyKey).replaceAll('[name]', widget.firstName);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: FadeInUp(
          duration: const Duration(milliseconds: 600),
          child: Container(
            width: 290,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated Icon & Background Ring ──
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Particles
                    AnimatedBuilder(
                      animation: _particlesController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(180, 180),
                          painter: _SuccessParticlesPainter(
                            particles: _particles,
                            progress: _particlesController.value,
                          ),
                        );
                      },
                    ),
                    // Rotating dotted line border
                    RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBlueLight.withValues(alpha: 0.4),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                    // Main Scaling/Pulsing Badge
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                      ),
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              Color(0xFF6366F1), // Elegant Indigo
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(alpha: 0.35),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── Title ──
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    localizedTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Greeting Body ──
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: Text(
                    localizedBody,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class _SuccessParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _SuccessParticlesPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      final distance = progress * p.speed * 60;
      final x = center.dx + distance * cos(p.angle);
      final y = center.dy + distance * sin(p.angle);

      // Fade out as it expands
      paint.color = p.color.withValues(alpha: (1.0 - progress).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), p.size * (1.0 - progress * 0.4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SuccessParticlesPainter oldDelegate) => true;
}
