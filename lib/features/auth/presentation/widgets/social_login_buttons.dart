import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../cubit/auth_cubit.dart';

/// أزرار Social Login - UI فقط، جاهزة للربط بالباك اند لاحقاً
class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ─── Google Button ──────────────────────────────────────────────
        _SocialButton(
          isWhite: false,
          onPressed: () {
            context.read<AuthCubit>().signInWithGoogle();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GoogleLogo(size: 22),
              const SizedBox(width: 12),
              Text(
                'المتابعة بـ Google',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
              ),
            ],
          ),
        ),

        // ─── Apple Button (iOS فقط) ─────────────────────────────────────
        if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS)) ...[
          const SizedBox(height: 12),
          _SocialButton(
            isWhite: true,
            onPressed: () {
              // TODO: تفعيل Apple Sign-In عند ربط الباك اند
              _showComingSoon(context, 'Apple');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.apple_rounded,
                  color: Color(0xFF1D1D1F),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'المتابعة بـ Apple',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF1D1D1F),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showComingSoon(BuildContext context, String provider) {
    CustomSnackBar.show(
      context,
      message: 'سيتم تفعيل تسجيل الدخول بـ $provider قريباً',
      type: SnackBarType.info,
    );
  }
}

// ─── Reusable Social Button ───────────────────────────────────────────────────
class _SocialButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool isWhite;

  const _SocialButton({
    required this.onPressed,
    required this.child,
    this.isWhite = false,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        transform: Matrix4.diagonal3Values(
          _isPressed ? 0.97 : 1.0,
          _isPressed ? 0.97 : 1.0,
          1.0,
        ),
        decoration: BoxDecoration(
          color: widget.isWhite
              ? Colors.white
              : AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(14),
          border: widget.isWhite
              ? null
              : Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isPressed ? 0.05 : 0.15),
              blurRadius: _isPressed ? 4 : 10,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

// ─── Google G Logo (Painted) ──────────────────────────────────────────────────
class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final sw = size.width * 0.14;
    const pi = 3.14159265;

    // White background
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = Colors.white,
    );

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.7);

    void arc(double start, double sweep, Color color) {
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.butt,
      );
    }

    arc(-pi * 0.12, pi * 0.57, const Color(0xFF4285F4)); // Blue
    arc(pi * 0.44, pi * 0.56, const Color(0xFFEA4335)); // Red
    arc(pi * 1.0, pi * 0.56, const Color(0xFFFBBC05)); // Yellow
    arc(-pi * 0.56, pi * 0.44, const Color(0xFF34A853)); // Green

    // White gap for the G horizontal bar
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.7, cy),
      Paint()
        ..color = Colors.white
        ..strokeWidth = sw + 1
        ..style = PaintingStyle.stroke,
    );

    // Blue G bar
    canvas.drawLine(
      Offset(cx + r * 0.08, cy),
      Offset(cx + r * 0.7, cy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = sw
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
