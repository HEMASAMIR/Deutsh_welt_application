import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeChangeDialog {
  static void show(BuildContext context, {required bool isDarkNow}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => _ThemeDialogContent(isDarkNow: isDarkNow),
    );
  }
}

class _ThemeDialogContent extends StatefulWidget {
  final bool isDarkNow;

  const _ThemeDialogContent({required this.isDarkNow});

  @override
  State<_ThemeDialogContent> createState() => _ThemeDialogContentState();
}

class _ThemeDialogContentState extends State<_ThemeDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // Auto dismiss after 1.8 seconds
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkNow;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final primaryColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A);
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    final titleText = isArabic
        ? (isDark ? 'تم تفعيل الوضع المظلم في Deutsch Welt 🌙' : 'تم تفعيل الوضع الفاتح في Deutsch Welt ☀️')
        : (isDark ? 'Dunkler Modus aktiviert 🌙' : 'Heller Modus aktiviert ☀️');

    final subText = isArabic
        ? (isDark
            ? 'تجربة قراءة مريحة للعين في تطبيق Deutsch Welt ✨'
            : 'تجربة واضحة ومشرقة في أكاديمية Deutsch Welt 🇩🇪')
        : (isDark
            ? 'Augenschonendes Leseerlebnis in Deutsch Welt App ✨'
            : 'Klares und helles Erlebnis in der Deutsch Welt Akademie 🇩🇪');

    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
            width: 290,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RotationTransition(
                  turns: _rotateAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: isDark ? const Color(0xFFFBBF24) : primaryColor,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  titleText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}
