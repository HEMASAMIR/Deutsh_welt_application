import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

/// Shows an animated logout confirmation dialog.
/// Returns [true] if user confirmed, [false] otherwise.
Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'logout_barrier',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 350),
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );
      return ScaleTransition(scale: curved, child: child);
    },
    pageBuilder: (ctx, _, __) => const _LogoutConfirmDialog(),
  );
  return result ?? false;
}

/// Shows a full-screen post-logout success animation, then auto-dismisses.
Future<void> showLogoutSuccessOverlay(BuildContext context, {required String firstName}) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'logout_success_barrier',
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 400),
    transitionBuilder: (ctx, animation, _, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    pageBuilder: (ctx, _, __) => _LogoutSuccessOverlay(firstName: firstName),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Confirmation Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _LogoutConfirmDialog extends StatelessWidget {
  const _LogoutConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          // Increased horizontal margin to 36 so it has elegant spacing from screen edges
          margin: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32), // More rounded premium corners
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.03),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 35,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: const Color(0xFFFF6B6B).withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            // Extra padding to give all elements inside generous breathing room
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated Icon ──
                ElasticIn(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF5252),
                          Color(0xFFFF7A45),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5252).withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 28), // Spacious gap

                // ── Title ──
                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    context.translate('logout_dialog_title'),
                    style: GoogleFonts.cairo(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 12), // Elegant spacing

                // ── Body ──
                FadeInUp(
                  delay: const Duration(milliseconds: 250),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      context.translate('logout_dialog_body'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36), // Generous gap before buttons to avoid "تلزق"

                // ── Buttons ──
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.border.withValues(alpha: 0.8),
                              width: 1.8,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            context.translate('cancel_btn'),
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16), // Increased spacing between buttons

                      // Confirm Button
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF5252), Color(0xFFFF7A45)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF5252).withValues(alpha: 0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              context.translate('confirm_btn'),
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Post-Logout Success Overlay
// ─────────────────────────────────────────────────────────────────────────────

class _LogoutSuccessOverlay extends StatefulWidget {
  final String firstName;
  const _LogoutSuccessOverlay({required this.firstName});

  @override
  State<_LogoutSuccessOverlay> createState() => _LogoutSuccessOverlayState();
}

class _LogoutSuccessOverlayState extends State<_LogoutSuccessOverlay>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _rotationController;
  late AnimationController _particlesController;
  final List<_LogoutParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

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
      const Color(0xFF388E3C),
      const Color(0xFF66BB6A),
      Colors.teal,
      Colors.lightGreen,
      Colors.amber,
    ];

    for (int i = 0; i < 20; i++) {
      _particles.add(
        _LogoutParticle(
          angle: random.nextDouble() * 2 * pi,
          speed: 0.5 + random.nextDouble() * 1.5,
          size: 3 + random.nextDouble() * 5,
          color: colors[random.nextInt(colors.length)],
        ),
      );
    }

    // Auto-dismiss after 1.8s
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _rotationController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: FadeInUp(
          duration: const Duration(milliseconds: 500),
          child: Container(
            width: 260,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.02),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 35,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated icon & background particles ──
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Particles
                    AnimatedBuilder(
                      animation: _particlesController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(160, 160),
                          painter: _LogoutParticlesPainter(
                            particles: _particles,
                            progress: _particlesController.value,
                          ),
                        );
                      },
                    ),
                    // Rotating outer dotted/solid line border
                    RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF66BB6A).withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    // Main Badge
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _checkController,
                        curve: Curves.elasticOut,
                      ),
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF388E3C), Color(0xFF66BB6A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF388E3C).withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    context.translate('logged_out'),
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    widget.firstName.isNotEmpty
                        ? 'إلى اللقاء يا ${widget.firstName}! 👋'
                        : context.translate('goodbye'),
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
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

class _LogoutParticle {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  _LogoutParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class _LogoutParticlesPainter extends CustomPainter {
  final List<_LogoutParticle> particles;
  final double progress;

  _LogoutParticlesPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      final distance = progress * p.speed * 50;
      final x = center.dx + distance * cos(p.angle);
      final y = center.dy + distance * sin(p.angle);

      paint.color = p.color.withValues(alpha: (1.0 - progress).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), p.size * (1.0 - progress * 0.4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LogoutParticlesPainter oldDelegate) => true;
}

