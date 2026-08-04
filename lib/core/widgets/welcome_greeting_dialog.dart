import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../di/service_locator.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';

class WelcomeGreetingDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
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
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Auto-close after 2 seconds
    _autoCloseTimer = Timer(const Duration(seconds: 2), () {
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
        'sub': isArabic
            ? 'صباح الخير والنشاط في تطبيق Deutsch Welt! يوم جديد للتميز في اللغة الألمانية 🇩🇪'
            : 'Guten Morgen bei Deutsch Welt! Ein neuer Tag für Deutsch-Erfolg 🇩🇪',
        'btn': isArabic ? 'ابدأ رحلة التعلم 🚀' : 'Lernreise starten 🚀',
        'tag': isArabic ? 'Deutsch Welt • ألمانية بإتقان' : 'Deutsch Welt • Deutsch Meistern',
        'welcome': isArabic ? 'أهلاً بك' : 'Willkommen',
      };
    } else if (hour >= 12 && hour < 18) {
      return {
        'title': 'Guten Tag! ☀️',
        'sub': isArabic
            ? 'نهار سعيد في تطبيق Deutsch Welt! واصل تطوير مهاراتك اليوم مع Herr خالد الحلواني 🚀'
            : 'Schönen Tag bei Deutsch Welt! Verbessere deine Fähigkeiten mit Herr Khaled 🚀',
        'btn': isArabic ? 'ابدأ رحلة التعلم 🚀' : 'Lernreise starten 🚀',
        'tag': isArabic ? 'Deutsch Welt • ألمانية بإتقان' : 'Deutsch Welt • Deutsch Meistern',
        'welcome': isArabic ? 'أهلاً بك' : 'Willkommen',
      };
    } else {
      return {
        'title': 'Guten Abend! 🌙',
        'sub': isArabic
            ? 'مساء الخير في تطبيق Deutsch Welt! وقت مثالي للمراجعة والاسترخاء مع كورساتنا ✨'
            : 'Guten Abend bei Deutsch Welt! Perfekte Zeit zum Wiederholen & Lernen ✨',
        'btn': isArabic ? 'ابدأ رحلة التعلم 🚀' : 'Lernreise starten 🚀',
        'tag': isArabic ? 'Deutsch Welt • ألمانية بإتقان' : 'Deutsch Welt • Deutsch Meistern',
        'welcome': isArabic ? 'أهلاً بك' : 'Willkommen',
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
            child: Container(
              width: 320,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? AppColors.primaryBlueLight.withValues(alpha: 0.35)
                      : AppColors.primaryBlue.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppColors.primaryBlueLight.withValues(alpha: 0.15)
                        : AppColors.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 35,
                    spreadRadius: 2,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Badge Icon with Logo
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isDark
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF60A5FA), Color(0xFF1E3A8A)],
                                )
                              : AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? AppColors.primaryBlueLight.withValues(alpha: 0.4)
                                  : AppColors.primaryBlue.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                      ClipOval(
                        child: Image.asset(
                          'assets/images/khaled.jpg',
                          width: 78,
                          height: 78,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // German Greeting Title
                  Text(
                    greeting['title']!,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
                    ),
                  ),
                  if (firstName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${greeting['welcome']}, $firstName 👋',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    greeting['sub']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Brand Pill Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryBlueLight.withValues(alpha: 0.15)
                          : AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      greeting['tag']!,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Primary Action Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
                      foregroundColor: isDark ? AppColors.primaryBlueDark : Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      greeting['btn']!,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
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
