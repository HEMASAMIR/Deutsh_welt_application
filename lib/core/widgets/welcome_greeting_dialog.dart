import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../di/service_locator.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';

/// A sleek, compact welcome popup that appears on home launch
/// and automatically fades away smoothly after 2 seconds.
class WelcomeGreetingDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => const _WelcomeDialogWidget(),
    );
  }
}

class _WelcomeDialogWidget extends StatefulWidget {
  const _WelcomeDialogWidget();

  @override
  State<_WelcomeDialogWidget> createState() => _WelcomeDialogWidgetState();
}

class _WelcomeDialogWidgetState extends State<_WelcomeDialogWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Auto-close smoothly after 2 seconds
    _autoCloseTimer = Timer(const Duration(milliseconds: 2000), () async {
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Map<String, String> _getGreetingInfo(BuildContext context) {
    final hour = DateTime.now().hour;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (hour >= 5 && hour < 12) {
      return {
        'title': 'Guten Morgen! ☀️',
        'sub': isArabic ? 'صباح النشاط في Deutsch Welt 🇩🇪' : 'Guten Morgen bei Deutsch Welt 🇩🇪',
      };
    } else if (hour >= 12 && hour < 18) {
      return {
        'title': 'Guten Tag! ☀️',
        'sub': isArabic ? 'نهار سعيد مع Deutsch Welt 🚀' : 'Schönen Tag bei Deutsch Welt 🚀',
      };
    } else {
      return {
        'title': 'Guten Abend! 🌙',
        'sub': isArabic ? 'مساء الخير، وقت مراجعة ممتع ✨' : 'Guten Abend bei Deutsch Welt ✨',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userStr = sl<StorageService>().user;
    final userData = userStr != null ? jsonDecode(userStr) : null;
    final firstName = userData?['first_name'] ?? '';

    final greeting = _getGreetingInfo(context);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Material(
            type: MaterialType.transparency,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 270,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark
                        ? AppColors.primaryBlueLight.withValues(alpha: 0.3)
                        : AppColors.primaryBlue.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Small Avatar Badge
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isDark
                            ? const LinearGradient(
                                colors: [Color(0xFF60A5FA), Color(0xFF1E3A8A)],
                              )
                            : AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/khaled.jpg',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Greeting Title
                    Text(
                      greeting['title']!,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
                      ),
                    ),
                    if (firstName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'أهلاً بك، $firstName 👋',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),

                    // Short Subtitle
                    Text(
                      greeting['sub']!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
